#!/usr/bin/env python3
"""Release manifest-diff layer (the release diff).

Diff `runs/examples/*.tar.gz.md5` between two commits of the read-only
SOLPS-ITER clone: the changed-example set of a release pair, with the
publish narrative.  The mechanism (authority: runs/examples/Makefile
publish rule :28-40) is that `make publish` computes the tarball md5
(`md5sum | cut -c 1-32`), writes it bare into `<dir>.tar.gz.md5` and
git-adds it — the git history of those files IS the release timeline,
their commit subjects the narrative.

All git access is plumbing against the local clone — `git rev-parse`,
`git ls-tree`, `git show`, `git log` — NEVER a worktree checkout (the
clone is a read-only reference).  Offline by construction: no network,
no downloads (the version axis/b own the network).

Output (stdout, or -o PATH): JSON schema catalog-deltarun-diff/1 —
per tarball {path, name, old_md5, new_md5, status, subjects} with
status in {identical, changed, added, removed}; md5s are the bare
32-lowercase-hex strings the Makefile writes (anything else is a hard
ValueError, never a guess); added/removed sides carry null.  `subjects`
lists the commits in <old>..<new> that touched the tarball's .md5 file
(full sha + the single-line subject, newest first — git log order);
computed for non-identical entries, [] for identical ones.  `counts`
summarizes the four statuses; added/removed surface as their own
statuses, never silently dropped.  No machine-dependent paths in the
JSON (repo-root-relative paths only, the manifest convention).

Run with the SOLPS-Reader venv interpreter (house rule):
    ../.venv/bin/python build_release_manifest_diff.py <old> <new> [-o out.json]
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

from build_manifests import default_examples

HERE = Path(__file__).resolve().parent
def __getattr__(name: str):
    """PEP 562: ``REPO`` resolves lazily (same contract as
    build_release_code_diff) — import must not walk the ladder."""
    if name == "REPO":
        # .../SOLPS-ITER (read-only clone), from the resolved runs root
        return default_examples().parent.parent
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")

MD5_SUFFIX = ".tar.gz.md5"
PREFIX = "runs/examples/"
MD5_RE = re.compile(r"[0-9a-f]{32}")   # md5sum emits lowercase hex
SCHEMA = "catalog-deltarun-diff/1"
STATUSES = ("identical", "changed", "added", "removed")


def _git(repo: Path, *args: str) -> str:
    """Run one git plumbing command; hard-error with git's own stderr."""
    proc = subprocess.run(
        ["git", "-C", str(repo), *args],
        capture_output=True, text=True, encoding="utf-8",
   )
    if proc.returncode != 0:
        raise SystemExit(
            f"git {' '.join(args)} failed in {repo}:\n{proc.stderr.strip()}"
       )
    return proc.stdout


def resolve_commit(repo: Path, rev: str) -> str:
    """Full sha of rev, which must name a commit (never a guess)."""
    return _git(repo, "rev-parse", "--verify", f"{rev}^{{commit}}").strip()


def md5_files_at(repo: Path, commit: str) -> dict[str, str]:
    """{repo-relative .md5 path -> bare md5} at one commit.

    Listing = `git ls-tree -r` over runs/examples/ filtered to the
    Makefile's *.tar.gz.md5 suffix (ls-tree pathspecs do not glob);
    content = `git show`, validated as the bare 32-lowercase-hex
    string the publish rule writes (Makefile :33-34).
    """
    out: dict[str, str] = {}
    listing = _git(repo, "ls-tree", "-r", "--name-only", commit, PREFIX)
    for line in listing.splitlines():
        if not line.endswith(MD5_SUFFIX):
            continue
        blob = _git(repo, "show", f"{commit}:{line}").strip()
        if not MD5_RE.fullmatch(blob):
            raise ValueError(
                f"{line}@{commit}: not a bare md5 ({blob!r}) — the publish "
                "rule writes `md5sum | cut -c 1-32`"
           )
        out[line] = blob
    return out


def subjects_for(repo: Path, old: str, new: str, path: str) -> list[dict]:
    """Commits in <old>..<new> that touched path, newest first.

    Separator: %x00 expands to a NUL in git's OUTPUT (safe — a NUL
    cannot occur inside a subject), while a literal NUL in argv would
    be rejected by execve.
    """
    sep = "\x00"
    log = _git(repo, "log", "--format=%H%x00%s", f"{old}..{new}", "--", path)
    entries = []
    for line in log.splitlines():
        if line:
            commit, _, subject = line.partition(sep)
            entries.append({"commit": commit, "subject": subject})
    return entries


def release_manifest_diff(repo: Path, old_rev: str, new_rev: str) -> dict:
    """The the release diff JSON for one release pair (see module docstring)."""
    old = resolve_commit(repo, old_rev)
    new = resolve_commit(repo, new_rev)
    old_map = md5_files_at(repo, old)
    new_map = md5_files_at(repo, new)

    tarballs = []
    for path in sorted(set(old_map) | set(new_map)):
        old_md5 = old_map.get(path)
        new_md5 = new_map.get(path)
        if old_md5 is None:
            status = "added"
        elif new_md5 is None:
            status = "removed"
        elif old_md5 != new_md5:
            status = "changed"
        else:
            status = "identical"
        tarballs.append({
            "path": path,
            "name": path[len(PREFIX):-len(".md5")],   # ...tar.gz.md5 -> ...tar.gz
            "old_md5": old_md5,
            "new_md5": new_md5,
            "status": status,
            "subjects": (subjects_for(repo, old, new, path)
                         if status != "identical" else []),
        })

    counts = {s: sum(1 for t in tarballs if t["status"] == s) for s in STATUSES}
    return {
        "schema": SCHEMA,
        "old": {"commit": old, "n_md5_files": len(old_map)},
        "new": {"commit": new, "n_md5_files": len(new_map)},
        "counts": counts,
        "tarballs": tarballs,
    }


def main(argv: list[str]) -> int:
    args = list(argv)
    out_path = None
    if "-o" in args:
        i = args.index("-o")
        if i + 1 >= len(args):
            print("usage: build_release_manifest_diff.py <old> <new> [-o out.json]",
                  file=sys.stderr)
            return 2
        out_path = Path(args[i + 1])
        del args[i:i + 2]
    if len(args) != 2:
        print("usage: build_release_manifest_diff.py <old> <new> [-o out.json]",
              file=sys.stderr)
        return 2
    diff = release_manifest_diff(REPO, args[0], args[1])  # lazy: resolves now
    text = json.dumps(diff, indent=2, sort_keys=True) + "\n"
    if out_path is not None:
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(text, encoding="utf-8")
    else:
        sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
