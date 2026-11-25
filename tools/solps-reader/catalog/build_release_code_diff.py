#!/usr/bin/env python3
"""Stamped-commit code-diff layer.

For each changed case of a release pair, read the CODE STAMPS from the
extracted copies' fort.44 / fort.46 / b2fstate headers — via the
EXISTING provenance readers, the same ones the run manifests use — and
attach the code delta the stamps name: old/new commits + version
strings, `git diff --stat`, the GitHub compare URL, and the doc/LOG
changelog range of the publish pair.

Stamp readers (cite-on-use, never reimplemented here):
  fort.44  solps_reader.ft44.read_header   (src/SOLPS-Reader/ft44.py:67, git_hash
           token 4 of line 1 — writer eirmod_extrab25.F90:149) — the
           call build_manifests.py:530-536 wraps for manifests;
  fort.46  solps_reader.ft46.read_header   (src/SOLPS-Reader/ft46.py, git_hash
           token 3 — eirmod_extrab25.F90:564) — build_manifests.py:
           145-154 fort46_provenance;
  b2fstate solps_reader.state.read_header  (src/SOLPS-Reader/state.py:248, version
           + character*32 hash via _read_version_line, cfverw
           b2mod_version.F:52-67).

Stamp repos, pinned from the REAL golden tarballs (criterion: "pin the
actual stamp repos from the real tarballs"): the ITER_2275 3.0.10
extract stamps fort.44 git 68af8ded — resolves in modules/Eirene ONLY
(superproject and B2.5 reject it) — and b2fstate git 4a81a2ca-dirty —
base 4a81a2ca resolves in modules/B2.5 ONLY ("Initial 3.0.10 commit").
fort.44/46 are EIRENE output, b2fstate B2.5 output; the code never
ASSUMES that mapping — every stamp is resolved against superproject +
every initialized submodule, and the repo it answers in is recorded.

Compare-URL rerouting follows the askthedocs srclink rules
(web/src/lib/srclink.js:63-82 MODULE_REPOS): the main repo 404s
submodule paths, so a submodule stamp compares in the module's OWN
public repo — url taken from .gitmodules (`../B2.5.git`) resolved
against the superproject's origin, never hardcoded.

Honest absent (criterion: never a silent gap): a stamp that resolves
nowhere, a header without a stamp, or a `-dirty` build stamp records
"code state not publicly reproducible" with the reason — no diffstat,
no compare URL.  A side whose bytes were never fetched (zenodo-absent skip, or simply not fetched) records that verbatim; the
golden pair's old side is the known case (the zenodo-absent question).

All git access is read-only plumbing against the local clone
(`git rev-parse`, `git log`, `git diff --stat`, `git config --file`)
— the clone is never written, never checked out.  Offline by
construction (/b own the network).

Input: a catalog-deltarun-diff/1 JSON + the catalog-deltarun-fetch/1 reports for the same pair (default
out/deltarun/reports/; the fetch report is the index of what was
fetched/extracted/skipped and why).  Output (stdout or -o PATH):
JSON schema catalog-deltarun-codediff/1 — pair block (publish
commits, doc/LOG changelog range verbatim, publish compare URL) +
per-case sides with per-run-dir stamps, resolutions, and per-repo
stamp_pairs {diffstat, compare_url, version jump}.  Deterministic:
sorted walks, sort_keys JSON, no timestamps, no machine-dependent
paths (repo-relative only, the manifest convention).

Run with the SOLPS-Reader venv interpreter (house rule):
    ../.venv/bin/python build_release_code_diff.py <diff.json> \
        [--reports-dir out/deltarun/reports] [--only NAME ...] [-o out.json]
"""
from __future__ import annotations

import json
import posixpath
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlsplit, urlunsplit

from build_manifests import MARKERS, default_examples

from solps_reader import ft44, ft46
from solps_reader.state import read_header as read_b2fstate_header

HERE = Path(__file__).resolve().parent
OUT = HERE / "out" / "deltarun"


def __getattr__(name: str):
    """PEP 562: ``REPO`` resolves lazily — importing this module on a
    data-less machine (the site builder imports it for its constants)
    must not walk the runs ladder; only using REPO does."""
    if name == "REPO":
        # .../SOLPS-ITER (read-only clone), from the resolved runs root
        return default_examples().parent.parent
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")

DIFF_SCHEMA = "catalog-deltarun-diff/1"
FETCH_SCHEMA = "catalog-deltarun-fetch/1"
SCHEMA = "catalog-deltarun-codediff/1"
CHANGELOG_PATH = "doc/LOG"

#: A git stamp's commit part: 7-40 lowercase hex leading the string
#: (`git describe --always` emits >=7; the real stamps are 8).  Anything
#: after it (e.g. `-dirty`) is a suffix, recorded and flagged.
STAMP_RE = re.compile(r"([0-9a-f]{7,40})(.*)")

#: The honest-absent verdict (criterion 4) — one string, reused.
NOT_REPRODUCIBLE = "code state not publicly reproducible"


def _git(repo: Path, *args: str, check: bool = True) -> subprocess.CompletedProcess:
    """Run one read-only git command; hard-error with git's own stderr."""
    proc = subprocess.run(
        ["git", "-C", str(repo), *args],
        capture_output=True, text=True, encoding="utf-8",
 )
    if check and proc.returncode != 0:
        raise SystemExit(
            f"git {' '.join(args)} failed in {repo}:\n{proc.stderr.strip()}"
     )
    return proc


def _git_out(repo: Path, *args: str) -> str:
    return _git(repo, *args).stdout


def _submodules(clone: Path) -> dict[str, str]:
    """{submodule path -> url} straight from .gitmodules (file order).

    Section names may contain dots ('submodule.B2.5.path'), so the
    field is split off the END of the key, never the front.
    """
    conf = _git_out(
        clone, "config", "--file", str(clone / ".gitmodules"),
        "--get-regexp", r"submodule\..*\.(path|url)",
 )
    sections: dict[str, dict[str, str]] = {}
    for line in conf.splitlines():
        key, _, value = line.partition(" ")
        sec, _, field = key.rpartition(".")
        sections.setdefault(sec, {})[field] = value.strip()
    return {v["path"]: v["url"] for v in sections.values()
            if "path" in v and "url" in v}


def candidate_repos(clone: Path) -> list[tuple[str, Path]]:
    """[(label, path)] for the superproject + every INITIALIZED submodule.

    Labels are repo-relative ('.', 'modules/B2.5', ...); an uninitialized
    submodule (no checkout, e.g. modules/adas here) cannot resolve
    anything and is excluded rather than errored on.
    """
    repos: list[tuple[str, Path]] = [(".", clone)]
    for path in _submodules(clone):
        if (clone / path / ".git").exists():
            repos.append((path, clone / path))
    return repos


def github_url(clone: Path, label: str,
               urls: dict[str, str] | None = None) -> str | None:
    """Public https compare base of one candidate repo, or None.

    Superproject: its origin url.  Submodule: the .gitmodules url
    (``../B2.5.git``) resolved against the superproject origin — the
    askthedocs MODULE_REPOS rerouting rule (the main repo 404s submodule
    paths; the compare belongs in the module's own repo) — read from
    the clone's own config, never a hardcoded table.  Non-https
    remotes (e.g. modules/adas' ssh://git.iter.org) answer None: no
    public compare target, never a fabricated URL.
    """
    if urls is None:
        urls = _submodules(clone)
    if label == ".":
        url = _git_out(clone, "remote", "get-url", "origin").strip()
        if not url.startswith("https://"):
            return None
    else:
        rel = urls.get(label)
        origin = _git_out(clone, "remote", "get-url", "origin").strip()
        if rel is None or not origin.startswith("https://"):
            return None
        if rel.startswith("https://"):
            url = rel
        else:                            # '../B2.5.git' against the origin
            parts = urlsplit(origin)
            path = posixpath.normpath(posixpath.join(parts.path, rel))
            url = urlunsplit((parts.scheme, parts.netloc, path, "", ""))
    return url[:-4] if url.endswith(".git") else url


def resolve_stamp(clone: Path, repos: list[tuple[str, Path]], stamp: str | None) -> dict:
    """Resolve one header stamp against every candidate repo.

    Honest outcomes, never a guess: {state} in
    - 'resolved'    — exactly one repo answers; full sha + subject +
                      compare base recorded;
    - 'ambiguous'   — several repos answer (all recorded);
    - 'unresolved'  — no repo knows the hash (NOT_REPRODUCIBLE);
    - 'dirty'       — hex resolves but the stamp carries a suffix
                      (`-dirty`: uncommitted changes at build time) —
                      the exact state is not reproducible even though
                      the base commit is;
    - 'no-stamp'    — the header carried no hash token at all.
    """
    if stamp is None:
        return {"state": "no-stamp", "stamp": None,
                "note": "header carries no git stamp"}
    out: dict = {"state": None, "stamp": stamp}
    m = STAMP_RE.match(stamp)
    if m is None:
        return {**out, "state": "unresolved",
                "note": f"stamp is not a hex commit prefix: {stamp!r} — "
                + NOT_REPRODUCIBLE}
    hex_part, suffix = m.group(1), m.group(2)
    hits = []
    for label, path in repos:
        proc = _git(path, "rev-parse", "--verify", "--quiet",
                    f"{hex_part}^{{commit}}", check=False)
        if proc.returncode == 0:
            full = proc.stdout.strip()
            subject = _git_out(path, "log", "-1", "--format=%s", full).strip()
            hits.append({"repo": label, "commit": full, "subject": subject,
                         "github": github_url(clone, label)})
    if not hits:
        return {**out, "state": "unresolved", "hex": hex_part,
                "note": f"{hex_part} answers in no local repository — "
                + NOT_REPRODUCIBLE}
    if suffix.strip():
        base = hits[0]
        return {**out, "state": "dirty", "hex": hex_part, "suffix": suffix,
                "base": base,
                "note": f"stamped {stamp!r}: build tree had uncommitted "
                f"changes on {base['repo']}@{hex_part} — exact state "
                + NOT_REPRODUCIBLE}
    if len(hits) > 1:
        return {**out, "state": "ambiguous", "hex": hex_part, "hits": hits,
                "note": f"{hex_part} answers in {len(hits)} repositories — "
                "cannot attribute the code state to one"}
    return {**out, "state": "resolved", "hex": hex_part, "hit": hits[0]}


def read_stamps(extract_dir: Path) -> list[dict]:
    """All run dirs under one extracted copy, each with its stamps.

    Run dirs are found by the manifest convention (build_manifests.py
    MARKERS: fort.44 / b2fstate / b2time.nc — sorted walk).  Per stamp
    file: {file, kind, version, git_stamp} with the header's strings
    VERBATIM (version as written — fort.44/46 integers, b2fstate
    NN.NNN.NNN; a dirty suffix stays attached).  A unreadable header is
    an honest error entry, never a silent drop.
    """
    runs = []
    for d in sorted(p for p in extract_dir.rglob("*") if p.is_dir()):
        if not any((d / mk).exists() for mk in MARKERS):
            continue
        stamps = []
        for name, kind in (("fort.44", "fort44"), ("fort.46", "fort46"),
                           ("b2fstate", "b2fstate")):
            f = d / name
            if not f.is_file():
                continue
            try:
                with open(f, encoding="ascii") as fh:
                    if kind == "fort44":
                        h = ft44.read_header(fh)
                    elif kind == "fort46":
                        h = ft46.read_header(fh)
                    else:
                        h = read_b2fstate_header(fh)
                stamps.append({"file": name, "kind": kind,
                               "version": str(h.version),
                               "git_stamp": h.git_hash})
            except Exception as exc:
                stamps.append({"file": name, "kind": kind,
                               "error": f"{type(exc).__name__}: {exc}"})
        runs.append({"run": str(d.relative_to(extract_dir)), "stamps": stamps})
    return runs


def load_fetch_sides(reports_dir: Path, old: str, new: str) -> dict:
    """{(tarball name, side): side-entry} from the pair's fetch reports.

    The report is the index of what was fetched/extracted/
    skipped and why (zenodo-absent etc.); multiple reports for one pair
    (e.g. per-case runs) merge, later reports winning on conflict.
    """
    sides: dict[tuple[str, str], dict] = {}
    if not reports_dir.is_dir():
        return sides
    for rp in sorted(reports_dir.glob("*.json")):
        try:
            rep = json.loads(rp.read_text(encoding="utf-8"))
        except (OSError, ValueError):
            continue
        if rep.get("schema") != FETCH_SCHEMA:
            continue
        d = rep.get("diff") or {}
        if d.get("old") != old or d.get("new") != new:
            continue
        for s in rep.get("sides", []):
            sides[(s.get("name"), s.get("side"))] = s
    return sides


def changelog_block(clone: Path, old: str, new: str) -> dict:
    """The doc/LOG range of the publish pair, VERBATIM (criterion 3).

    Default `git log` format, unmodified text + a machine list.  Empty
    is a measured, honest answer (the golden pair's publish commits
    touch no doc/LOG entry — 826 commits, 0 on doc/LOG).
    """
    text = _git_out(clone, "log", f"{old}..{new}", "--", CHANGELOG_PATH)
    fmt = _git_out(clone, "log", "--format=%H%x00%ad%x00%s",
                   "--date=short", f"{old}..{new}", "--", CHANGELOG_PATH)
    entries = []
    for line in fmt.splitlines():
        if line:
            commit, _, rest = line.partition("\x00")
            date, _, subject = rest.partition("\x00")
            entries.append({"commit": commit, "date": date, "subject": subject})
    return {"path": CHANGELOG_PATH, "n_entries": len(entries),
            "entries": entries, "text": text}


def side_block(clone: Path, repos: list[tuple[str, Path]], entry: dict | None,
               md5: str | None) -> dict:
    """One side of a case: fetch outcome + per-run stamps + resolutions."""
    block: dict = {"md5": md5}
    if entry is None:
        return {**block, "side_state": "not-fetched",
                "note": "no fetch report covers this side — run "
                "fetch_release_tarballs.py first"}
    if entry.get("outcome") == "skipped":
        return {**block, "side_state": "skipped",
                "skip_kind": entry.get("skip_kind"),
                "reason": entry.get("skip_reason"),
                "note": "side bytes never obtained — " + NOT_REPRODUCIBLE}
    extract = entry.get("extract_path")
    if not extract:
        return {**block, "side_state": "no-extract",
                "note": f"fetch outcome {entry.get('outcome')!r} carried "
                "no extract_path"}
    extract_dir = (HERE / extract).resolve() if not Path(extract).is_absolute() \
        else Path(extract)
    if not extract_dir.is_dir():
        raise SystemExit(f"report names extract dir that is missing: {extract_dir}")
    runs = []
    for run in read_stamps(extract_dir):
        for s in run["stamps"]:
            if "error" in s:
                s["resolution"] = {"state": "read-error",
                                   "note": s.pop("error")}
            else:
                s["resolution"] = resolve_stamp(clone, repos, s.get("git_stamp"))
        runs.append(run)
    return {**block, "side_state": "extracted", "extract_path": extract,
            "runs": runs}


def stamp_pairs(clone: Path, old_block: dict, new_block: dict) -> list[dict]:
    """Join sides per (run dir, resolution repo) -> the code delta.

    A pair is emitted only where BOTH sides resolved the SAME repo
    cleanly (state resolved, no dirty suffix) — the two states the
    diffstat and compare URL honestly describe.  Everything else is
    already recorded honestly in the side blocks; nothing is silently
    dropped, and no pair is manufactured from an absent side.
    """
    def keyed(block: dict) -> dict:
        out = {}
        for run in block.get("runs") or []:
            for s in run["stamps"]:
                res = s.get("resolution") or {}
                if res.get("state") != "resolved":
                    continue
                hit = res["hit"]
                out.setdefault((run["run"], hit["repo"]), []).append(
                    {"file": s["file"], "kind": s["kind"],
                     "version": s.get("version"), "stamp": s.get("git_stamp"),
                     "hit": hit})
        return out

    old_keyed, new_keyed = keyed(old_block), keyed(new_block)
    pairs = []
    for key in sorted(set(old_keyed) & set(new_keyed)):
        run, repo = key
        o, n = old_keyed[key], new_keyed[key]
        o_hit, n_hit = o[0]["hit"], n[0]["hit"]
        repo_path = clone / repo
        diffstat = _git_out(repo_path, "diff", "--stat",
                            o_hit["commit"], n_hit["commit"])
        base = o_hit.get("github")
        compare_url = (f"{base}/compare/{o_hit['commit']}...{n_hit['commit']}"
                       if base else None)
        pairs.append({
            "run": run, "repo": repo,
            "old": {"commit": o_hit["commit"], "stamp": o[0]["stamp"],
                    "version": o[0]["version"], "subject": o_hit["subject"]},
            "new": {"commit": n_hit["commit"], "stamp": n[0]["stamp"],
                    "version": n[0]["version"], "subject": n_hit["subject"]},
            "version_jump": {"old": o[0]["version"], "new": n[0]["version"]},
            "diffstat": diffstat,
            "compare_url": compare_url,
        })
    return pairs


def code_diff(diff_path: Path, reports_dir: Path,
              only: list[str] | None = None,
              clone: Path | None = None) -> dict:
    """The JSON for one release pair (see module docstring)."""
    clone = REPO if clone is None else clone
    diff = json.loads(diff_path.read_text(encoding="utf-8"))
    if diff.get("schema") != DIFF_SCHEMA:
        raise SystemExit(f"{diff_path}: schema {diff.get('schema')!r} is not "
                         f"{DIFF_SCHEMA!r}")
    old, new = diff["old"]["commit"], diff["new"]["commit"]
    repos = candidate_repos(clone)
    sides = load_fetch_sides(reports_dir, old, new)

    cases = []
    for t in diff["tarballs"]:
        name = t["name"]
        if t["status"] == "identical":
            continue                       # same bytes — no code delta
        if only and name not in only:
            continue
        old_entry = sides.get((name, "old"))
        new_entry = sides.get((name, "new"))
        if t["status"] == "added":
            old_entry = {"outcome": "skipped", "skip_kind": "side-absent",
                         "skip_reason": "tarball added in the new release — "
                         "no old side exists"}
        if t["status"] == "removed":
            new_entry = {"outcome": "skipped", "skip_kind": "side-absent",
                         "skip_reason": "tarball removed in the new release — "
                         "no new side exists"}
        ob = side_block(clone, repos, old_entry, t.get("old_md5"))
        nb = side_block(clone, repos, new_entry, t.get("new_md5"))
        cases.append({
            "name": name, "status": t["status"],
            "old": ob, "new": nb, "stamp_pairs": stamp_pairs(clone, ob, nb),
        })

    super_url = github_url(clone, ".")
    return {
        "schema": SCHEMA,
        "diff_path": str(diff_path),
        "old": old, "new": new,
        "publish_compare_url": (
            f"{super_url}/compare/{old}...{new}" if super_url else None),
        "changelog": changelog_block(clone, old, new),
        "cases": cases,
    }


def main(argv: list[str], clone: Path | None = None) -> int:
    args = list(argv)
    out_path = None
    reports_dir = OUT / "reports"
    only: list[str] = []
    if "-o" in args:
        i = args.index("-o")
        if i + 1 >= len(args):
            print("usage: build_release_code_diff.py <diff.json> "
                  "[--reports-dir DIR] [--only NAME ...] [-o out.json]",
                  file=sys.stderr)
            return 2
        out_path = Path(args[i + 1])
        del args[i:i + 2]
    if "--reports-dir" in args:
        i = args.index("--reports-dir")
        reports_dir = Path(args[i + 1])
        del args[i:i + 2]
    while "--only" in args:
        i = args.index("--only")
        if i + 1 >= len(args):
            print("--only needs a tarball NAME", file=sys.stderr)
            return 2
        only.append(args[i + 1])
        del args[i:i + 2]
    if len(args) != 1:
        print("usage: build_release_code_diff.py <diff.json> "
              "[--reports-dir DIR] [--only NAME ...] [-o out.json]",
              file=sys.stderr)
        return 2
    result = code_diff(Path(args[0]), reports_dir, only or None, clone)
    text = json.dumps(result, indent=2, sort_keys=True) + "\n"
    if out_path is not None:
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(text, encoding="utf-8")
    else:
        sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
