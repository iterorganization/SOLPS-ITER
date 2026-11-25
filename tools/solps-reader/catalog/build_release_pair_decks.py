#!/usr/bin/env python3
"""Release-pair diff decks — old vs new per changed case.

For every non-identical tarball of a release pair (catalog-deltarun-diff/1), build the variance-highlighted A/B state-diff
deck on the old/new extracted copies (cache) with SOLPS-Reader's own
CLI — the pinned call, VERBATIM (build_diff_decks.py:9):

    cli.main(["state", "diff", <old b2fstate>, <new b2fstate>, "-o", deck])

A = old, B = new.  The same-grid + same-species precondition is the
CLI's own (_diff_precheck, SOLPS-Reader cli.py:667 — guard-box check :679,
species-signature check :689-91); a mismatch is parser.exit(2) with the
reason on stderr, which this builder catches and records as an honest
skip, never a silent gap.  Pair rule: run dirs are discovered by the
manifest MARKERS convention (build_manifests.py:96, single-sourced with
read_stamps/find_run_dirs) and paired by RELATIVE NAME across the two
extracts, sorted; the FIRST same-name pair passing the precondition
becomes the case's ONE deck (the first-passing-pair rule).

Convergence verdict per side: the EXISTING b2time rule, single-sourced
(build_manifests.convergence_block — verdict over ACTIVE monitors, 3
GiB guard, size guard) run on every extracted run dir's b2time.nc.  Only
the compact verdict record ships here; full sparkline blocks stay in
the catalog manifests.  "Converged in both releases?" is then a lookup
of the decked pair's two verdicts.

Regime reality (measured, FORMATS.md /): ZERO old sides
of the golden pair 79bb46bc..ab87f750 are carried by the Zenodo concept
(the zenodo-absent question — that publish state predates it), so on the real cache every
golden-pair case records its skip verbatim and no deck exists;
the both-sides regime is exercised by fixtures through the REAL
machinery (tests/test_deltarun_pairdecks.py).  A real release-pair deck
appears the moment a pair's old side IS concept-carried (drift-matrix
steps, FORMATS.md ): fetch those sides with
fetch_release_tarballs.py and rerun this script — no code change.

Determinism: deck bytes are the CLI's own (byte-identical double
regeneration); the report is a pure function of the diff JSON
+ fetch reports + cache state (sorted walks, sort_keys, no timestamps).

No network: the network belongs to the fetch stage only; everything read
here is local (a source tripwire test pins it).

Usage (venv interpreter, house rule):
    ../.venv/bin/python build_release_pair_decks.py <diff.json> \
        [--reports-dir out/deltarun/reports] [--decks-root figures/deltarun] \
        [--cache-root DIR] [--only NAME ...] [-o out.json]
Default output: out/deltarun/decks/<diff-stem>.json (cache, gitignored).
"""
from __future__ import annotations

import contextlib
import hashlib
import io
import json
import shutil
import sys
from pathlib import Path

from solps_reader.cli import main as solps_reader_cli

from build_manifests import MARKERS, convergence_block
from build_release_code_diff import load_fetch_sides

SCHEMA = "catalog-deltarun-pairdecks/1"
DIFF_SCHEMA = "catalog-deltarun-diff/1"

HERE = Path(__file__).resolve().parent
OUT = HERE / "out" / "deltarun"
USAGE = ("usage: build_release_pair_decks.py <diff.json> "
         "[--reports-dir DIR] [--decks-root DIR] [--cache-root DIR] "
         "[--only NAME ...] [-o out.json]")


def run_dirs(extract_dir: Path) -> list[Path]:
    """Sorted MARKERS run dirs under one extracted copy — the same
    discovery rule read_stamps/find_run_dirs use (build_manifests.py:96),
    so deck pairing and stamp/manifest discovery can never drift."""
    return sorted(d for d in extract_dir.rglob("*")
                  if d.is_dir() and any((d / m).exists() for m in MARKERS))


def compact_convergence(run_dir: Path) -> dict:
    """One run dir -> compact verdict record via the EXISTING b2time rule
    (build_manifests.convergence_block).  Absent file / over-guard /
    unreadable are honest records, never gaps."""
    nc = run_dir / "b2time.nc"
    if not nc.is_file():
        return {"absent": "no b2time.nc in run dir"}
    block = convergence_block(nc)
    if "verdict" in block:
        return {k: block[k] for k in ("verdict", "n_active", "nrecords")}
    return block  # the skipped / error dicts, verbatim


def side_convergence(extract_dir: Path) -> dict:
    return {str(d.relative_to(extract_dir)): compact_convergence(d)
            for d in run_dirs(extract_dir)}


def deck_inventory(deck: Path) -> dict:
    """The deck's own record: figure/field/line counts parsed from the
    deck itself (pattern — never re-derived) + the artifacts inventory (path-relative name, bytes, MD5)."""
    files = {}
    for f in sorted(p for p in deck.rglob("*") if p.is_file()):
        files[f.name] = {"bytes": f.stat().st_size,
                         "md5": hashlib.md5(f.read_bytes()).hexdigest()}
    lines = (deck / "diff_summary.txt").read_text(encoding="utf-8").splitlines()
    fields = next((l.split()[1:] for l in lines if l.startswith("fields")), [])
    return {"n_figures": len(list(deck.glob("*.png"))),
            "fields": fields, "summary_lines": len(lines), "files": files}


def try_deck(a_state: Path, b_state: Path, deck: Path) -> tuple[bool, str]:
    """One cli.main call -> (ok, reason).  rc 0 = deck written;
    SystemExit(2) carries the precondition reason on stderr (captured
    VERBATIM — the CLI's own words, never paraphrased)."""
    if deck.exists():
        shutil.rmtree(deck)  # clean deck: no stale fields linger
    err = io.StringIO()
    try:
        with contextlib.redirect_stderr(err):
            rc = solps_reader_cli(["state", "diff", str(a_state), str(b_state),
                             "-o", str(deck)])
    except SystemExit as exc:
        reason = err.getvalue().strip() or f"exit {exc.code}"
        return False, reason
    if rc != 0:
        return False, f"exit {rc}"
    return True, ""


def side_block(entry: dict | None, md5: str | None, which: str,
               cache_root: Path) -> dict:
    """One fetch-report side -> outcome block (vocabulary)."""
    if entry is None:
        return {"md5": md5, "outcome": "not-fetched",
                "note": f"no {which}-side entry in any fetch report for "
                        f"this pair"}
    out: dict = {"md5": md5 if md5 is not None else entry.get("md5")}
    if entry.get("outcome") == "skipped":
        out.update(outcome="skipped", skip_kind=entry.get("skip_kind"),
                   skip_reason=entry.get("skip_reason"))
        return out
    ex = entry.get("extract_path")
    if not ex:
        out.update(outcome="not-extracted",
                   note="fetch report records no extract_path")
        return out
    d = cache_root / ex
    if not d.is_dir():
        out.update(outcome="extract-missing",
                   note=f"recorded extract dir absent on disk: {ex}")
        return out
    out.update(outcome="extracted", extract_path=ex,
               run_dirs=[str(r.relative_to(d)) for r in run_dirs(d)],
               convergence=side_convergence(d))
    return out


def case_decks(name: str, old_blk: dict, new_blk: dict,
               decks_root: Path, cache_root: Path) -> dict:
    """One changed case -> the deck record.  Same-name run-dir pairs in
    sorted order; first passing the precondition is THE deck (rule); every failure/mismatch recorded honestly."""
    rec: dict = {"deck": None, "skipped_pairs": [], "unmatched": []}
    if old_blk.get("outcome") != "extracted" or \
            new_blk.get("outcome") != "extracted":
        return rec
    od = cache_root / old_blk["extract_path"]
    nd = cache_root / new_blk["extract_path"]
    o_runs = {str(r.relative_to(od)): r for r in run_dirs(od)}
    n_runs = {str(r.relative_to(nd)): r for r in run_dirs(nd)}
    for r in sorted(o_runs):
        if r not in n_runs:
            rec["unmatched"].append(
                {"run": r, "side": "old",
                 "skipped": "run dir has no same-name partner on the new side"})
    for r in sorted(n_runs):
        if r not in o_runs:
            rec["unmatched"].append(
                {"run": r, "side": "new",
                 "skipped": "run dir has no same-name partner on the old side"})
    common = sorted(set(o_runs) & set(n_runs))
    for i, r in enumerate(common):
        a, b = o_runs[r] / "b2fstate", n_runs[r] / "b2fstate"
        if not (a.is_file() and b.is_file()):
            rec["skipped_pairs"].append(
                {"run": r,
                 "skipped": f"b2fstate absent in run dir "
                            f"(old side: {a.is_file()}, new side: {b.is_file()})"})
            continue
        case = name[: -len(".tar.gz")] if name.endswith(".tar.gz") else name
        deck = decks_root / f"{case}__diff"
        ok, reason = try_deck(a, b, deck)
        if not ok:
            rec["skipped_pairs"].append({"run": r, "skipped": reason})
            continue
        rel = (deck.relative_to(cache_root) if deck.is_relative_to(cache_root)
               else deck)
        rec["deck"] = {
            "run": r,
            "a": f"{old_blk['extract_path']}/{r}/b2fstate",
            "b": f"{new_blk['extract_path']}/{r}/b2fstate",
            "deck": str(rel),
            "convergence": {"a": old_blk["convergence"].get(r),
                            "b": new_blk["convergence"].get(r)},
            **deck_inventory(deck),
        }
        if i + 1 < len(common):
            rec["note"] = (f"{len(common) - i - 1} later same-name pair(s) "
                           "not attempted — one deck per case (first-passing-pair rule)")
        break
    return rec


def pair_decks(diff_path: Path, reports_dir: Path, decks_root: Path,
               cache_root: Path = HERE, only: list[str] | None = None) -> dict:
    """The JSON for one release pair (see module docstring)."""
    diff = json.loads(diff_path.read_text(encoding="utf-8"))
    if diff.get("schema") != DIFF_SCHEMA:
        raise SystemExit(f"{diff_path}: schema {diff.get('schema')!r} is not "
                         f"{DIFF_SCHEMA!r}")
    old, new = diff["old"]["commit"], diff["new"]["commit"]
    sides = load_fetch_sides(reports_dir, old, new)

    cases = []
    n_decks = 0
    for t in diff["tarballs"]:
        name = t["name"]
        if t["status"] == "identical":
            continue  # same bytes — an A/B deck would be all zeros
        if only and name not in only:
            continue
        old_entry, new_entry = sides.get((name, "old")), sides.get((name, "new"))
        if t["status"] == "added":
            old_entry = {"outcome": "skipped", "skip_kind": "side-absent",
                         "skip_reason": "tarball added in the new release — "
                                        "no old side exists"}
        if t["status"] == "removed":
            new_entry = {"outcome": "skipped", "skip_kind": "side-absent",
                         "skip_reason": "tarball removed in the new release — "
                                        "no new side exists"}
        ob = side_block(old_entry, t.get("old_md5"), "old", cache_root)
        nb = side_block(new_entry, t.get("new_md5"), "new", cache_root)
        dr = (case_decks(name, ob, nb, decks_root, cache_root)
              if t["status"] == "changed" else {"deck": None})
        if dr["deck"] is not None:
            n_decks += 1
        cases.append({"name": name, "status": t["status"],
                      "old": ob, "new": nb, **dr})

    return {
        "schema": SCHEMA,
        "diff_path": str(diff_path),
        "old": old, "new": new,
        "counts": {
            "cases": len(cases),
            "decks": n_decks,
            "sides_extracted": sum(1 for c in cases for s in ("old", "new")
                                   if c[s].get("outcome") == "extracted"),
            "sides_skipped": sum(1 for c in cases for s in ("old", "new")
                                 if c[s].get("outcome") == "skipped"),
            # the nothing-dropped proof: extracted + skipped + not-fetched
            # == 2 * cases (every side of every non-identical tarball)
            "sides_not_fetched": sum(1 for c in cases for s in ("old", "new")
                                     if c[s].get("outcome") == "not-fetched"),
        },
        "cases": cases,
    }


def main(argv: list[str]) -> int:
    args = list(argv)
    out_path = None
    reports_dir = OUT / "reports"
    decks_root = HERE / "figures" / "deltarun"
    cache_root = HERE
    only: list[str] = []

    def take(flag: str, nargs: int = 1) -> list[str]:
        i = args.index(flag)
        if i + nargs > len(args):
            print(USAGE, file=sys.stderr)
            sys.exit(2)
        vals = args[i + 1:i + 1 + nargs]
        del args[i:i + 1 + nargs]
        return vals

    try:
        if "-o" in args:
            out_path = Path(take("-o")[0])
        if "--reports-dir" in args:
            reports_dir = Path(take("--reports-dir")[0])
        if "--decks-root" in args:
            decks_root = Path(take("--decks-root")[0])
        if "--cache-root" in args:
            cache_root = Path(take("--cache-root")[0])
        while "--only" in args:
            only.append(take("--only")[0])
    except ValueError:
        pass
    if len(args) != 1:
        print(USAGE, file=sys.stderr)
        return 2
    diff_path = Path(args[0])
    if out_path is None:
        out_path = OUT / "decks" / f"{diff_path.stem}.json"

    result = pair_decks(diff_path, reports_dir, decks_root, cache_root,
                        only or None)
    text = json.dumps(result, indent=2, sort_keys=True) + "\n"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(text, encoding="utf-8")
    c = result["counts"]
    print(f"{c['cases']} cases, {c['decks']} deck(s), "
          f"{c['sides_extracted']} extracted / {c['sides_skipped']} skipped "
          f"sides -> {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
