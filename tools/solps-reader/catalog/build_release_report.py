#!/usr/bin/env python3
"""The selection layer: version resolver + one-command driver.

*As a physicist facing a version jump, I want to ask "3.0.9 vs 3.0.10,
analyze the ITER cases" in one command and get the report — selection
at the moment of intent, budget decided there, nothing pre-built
nobody asked for.*

Two pieces:

  RESOLVER — the pinned version axis {version -> publish commit},
  axis-ordered (RELEASE_VERSIONS below).  A version string resolves
  through the table ONLY; anything else must name a commit in the
  read-only clone (raw shas keep working — the golden pair's 79bb46bc
  is not a pinned version).  An unknown version is a HARD SystemExit
  naming the whole table (never a guess, never a prefix match).

  DRIVER — build_release_report.py OLD NEW [--analyze NAME ...]: resolves
  the pair, then chains the existing release-pair scripts IN ORDER,
  importing each (never a reimplementation; the cite is the function
  each stage calls):

    1 build_release_manifest_diff.release_manifest_diff  :110
    2 fetch_release_tarballs.run                         :314
    3 build_release_code_diff.code_diff                   :396
    4 build_release_pair_decks.pair_decks                 :220
    5 build_release_impact_stats.impact_stats             :257
    6 join    build_release_page_data.page_data                   :163
    7 site    build_catalog.main (lazy import — no import cycle)

  Stages 3-5 run UNRESTRICTED (every non-identical case): the page-data
  join hard-refuses any layer whose case set differs from the diff's,
  and the analysis tier "follows the fetched sides" anyway — only stage
  2 (the fetch) is narrowed by the selection, which is where the budget
  is decided (the 2026-09-29 owner ruling: per-pair fetch budget is
  decided AT SELECTION TIME, no standing rule).

  --analyze DEFAULTS to the ITER families (tarballs whose name starts
  ITER_ among the pair's non-identical set).  The selection + budgets +
  the exact command + every stage's output path are recorded INTO the
  pair's record (out/deltarun/runs/<stem>.json, schema
  catalog-deltarun-driver/1) and from there into the committed page-data
  join's `selection` block — the report page's audit layer renders them.

  Range pairs: ANY two versions, adjacent or spanning — the diff layers
  are git-range queries, so ranges are free; the analysis tier follows
  whatever sides the (budget-gated) fetch actually obtained.

  Zenodo availability gate: inherited from stage 2 verbatim — the
  cached axis keyed by RECORD ID (the versionless-record question: never version
  inference), a side no record serves is the recorded zenodo-absent
  honest skip (the zenodo-absent question), never a failure.  The driver adds no
  availability logic of its own and never bypasses a guard.

The version-axis INDEX page (site/deltarun/index.html) is rendered by
build_catalog from this module's RELEASE_VERSIONS + the committed joins
— the resolver table is single-sourced here (build_catalog imports it;
the driver imports build_catalog lazily inside the site stage only).

Network: only stage 2 touches it (/b own the network); warm
cache runs fully offline.  Run with the SOLPS-Reader venv interpreter:

    ../.venv/bin/python build_release_report.py 3.0.9 3.0.10
    ../.venv/bin/python build_release_report.py 79bb46bc ab87f750 \
        --analyze ITER_2275_Donly_20MW.tar.gz
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

import fetch_release_tarballs as frt
import build_release_code_diff as rcd
import build_release_impact_stats as ris
import build_release_manifest_diff as mrd
import build_release_page_data as rpg
import build_release_pair_decks as rpd
import build_release_wall_deck as rwd

HERE = Path(__file__).resolve().parent
DEFAULT_ROOT = HERE / "out" / "deltarun"       # the DR cache root
DEFAULT_DECKS = HERE / "figures" / "deltarun"  # committed deck staging
DEFAULT_PAGES = HERE / "out" / "deltarun_pages"  # committed joins

SCHEMA = "catalog-deltarun-driver/1"

#: The pinned version axis, in axis order (oldest first — the
#: resolver table, tested against the git history subjects: each pinned
#: commit's own subject names its version, tests/test_deltarun_driver.py).
#: A dict keyed by version would need semantic sorting ("3.0.10" sorts
#: before "3.0.8" lexically); the tuple IS the order, never sorted.
RELEASE_VERSIONS: tuple[tuple[str, str], ...] = (
    ("3.0.8", "e0e580b562036837ce6aec87468b181ea1c01d3f"),
    ("3.0.9", "753cbdf2b069f050ea76fddb29530183262d8d42"),
    ("3.0.10", "ab87f75097b1426fd39b0b7b951f61c6e589c00a"),
)

DEFAULT_RULE = "ITER_"      # --analyze default: the ITER families

USAGE = ("usage: build_release_report.py <old> <new> [--analyze NAME ...] "
         "[--per-tarball-budget B] [--total-budget B] [--force-full-record] "
         "[--refresh-records] [--no-site]")


def version_table_text() -> str:
    """The resolver table as one honest string — the unknown-version error
    NAMES the table (criterion), never a truncated hint."""
    return "; ".join(f"{v} -> {c[:12]}… ({c})" for v, c in RELEASE_VERSIONS)


def resolve_side(repo: Path, rev: str) -> dict:
    """One side of the pair: {input, commit, version}.

    A pinned version resolves through the table; anything else must name
    a commit in the clone (mrd.resolve_commit :65 — rev-parse --verify,
    never a guess) and carries version null (raw sha, e.g. the golden
    pair's 79bb46bc prep commit).  Unknown version/commit = hard exit.
    """
    for v, c in RELEASE_VERSIONS:
        if rev == v:
            return {"input": rev, "commit": c, "version": v}
    try:
        commit = mrd.resolve_commit(repo, rev)
    except SystemExit as err:
        raise SystemExit(
            f"unknown version or commit: {rev!r} — the pinned version "
            f"table is {{{version_table_text()}}}; anything else must "
            f"name a commit in the read-only clone\n({err})")
    return {"input": rev, "commit": commit, "version": None}


def resolve_pair(repo: Path, old: str, new: str) -> dict:
    old_side = resolve_side(repo, old)
    new_side = resolve_side(repo, new)
    if old_side["commit"] == new_side["commit"]:
        raise SystemExit(
            f"old and new resolve to the SAME commit {old_side['commit']} "
            "— a release pair needs two commits")
    return {"old": old_side, "new": new_side}


def default_selection(diff: dict) -> list[str]:
    """The ITER families of THIS pair: non-identical tarballs whose name
    starts with the default rule (an ITER_* tarball unchanged between
    the pair needs no fetch — identical sides are never wanted,
    fetch_release_tarballs.wanted_sides :237)."""
    names = [t["name"] for t in diff["tarballs"]
             if t["status"] != "identical" and t["name"].startswith(DEFAULT_RULE)]
    if not names:
        raise SystemExit(
            "default selection (ITER families) is EMPTY for this pair — no "
            "non-identical ITER_* tarball; pass --analyze NAME … explicitly")
    return sorted(names)


def selection_tag(names: list[str], is_default: bool) -> str:
    """Deterministic fetch-report tag (out/deltarun/reports/<stem>__tag):
    the default selection reports under its rule name; an explicit
    single case under the tarball base; anything else under a stable
    hash (the report is cache; the driver record names its paths)."""
    if is_default:
        return "ITER-default"
    if len(names) == 1:
        return names[0][:-len(".tar.gz")] if names[0].endswith(".tar.gz") \
            else names[0]
    return (f"{len(names)}-"
            + hashlib.md5("\x00".join(sorted(names)).encode()).hexdigest()[:8])


def _write_json(path: Path, obj: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2, sort_keys=True) + "\n",
                    encoding="utf-8")


def _rel(p: Path) -> str:
    """Catalog-dir-relative when inside the catalog (manifest convention)."""
    try:
        return p.resolve().relative_to(HERE).as_posix()
    except ValueError:
        return p.as_posix()


def run(old_rev: str, new_rev: str,
        analyze: list[str] | None = None,
        per_tarball_budget: int = frt.PER_TARBALL_DEFAULT,
        total_budget: int = frt.TOTAL_DEFAULT,
        force_full_record: bool = False,
        refresh_records: bool = False,
        site: bool = True,
        repo: Path | None = None,
        root: Path = DEFAULT_ROOT,
        decks_root: Path = DEFAULT_DECKS,
        pages_root: Path = DEFAULT_PAGES,
        command: str | None = None) -> dict:
    """Chain the six stages for one release pair; returns the driver
    record (also written to <root>/runs/<stem>.json)."""
    repo = mrd.REPO if repo is None else repo  # lazy: import stays data-less-safe
    pair = resolve_pair(repo, old_rev, new_rev)
    oldc, newc = pair["old"]["commit"], pair["new"]["commit"]
    stem = f"{oldc[:8]}_{newc[:8]}"
    reports_dir = root / "reports"

    # --- stage 1: the changed-example set  ----------------------
    diff = mrd.release_manifest_diff(repo, oldc, newc)
    diff_path = root / "diffs" / f"{stem}.json"
    _write_json(diff_path, diff)

    # --- the selection (the budget decision lives with it) --------------
    is_default = analyze is None
    names = default_selection(diff) if is_default else sorted(analyze)
    known = {t["name"] for t in diff["tarballs"]}
    unknown = [n for n in names if n not in known]
    if unknown:
        raise SystemExit(f"--analyze names not in the pair's diff: {unknown}")

    tag = selection_tag(names, is_default)
    fetch_report_path = reports_dir / f"{stem}__{tag}.json"

    # --- stage 2: selective fetch, three-way md5  --------------
    fetch = frt.run(diff_path, root, names, per_tarball_budget,
                    total_budget, force_full_record, refresh_records)
    _write_json(fetch_report_path, fetch)

    # --- stage 3: stamped-commit code delta  -------------------
    codediff = rcd.code_diff(diff_path, reports_dir, None, repo)
    codediff_path = root / "codediffs" / f"{stem}.json"
    _write_json(codediff_path, codediff)

    # --- stage 4: release-pair decks  --------------------------
    decks = rpd.pair_decks(diff_path, reports_dir, decks_root, HERE, None)
    decks_path = root / "decks" / f"{stem}.json"
    _write_json(decks_path, decks)

    # --- stage 5: per-case impact stats  -----------------------
    impact = ris.impact_stats(decks_path, HERE)
    impact_path = decks_path.with_name(decks_path.stem + ".impact.json")
    _write_json(impact_path, impact)

    # --- stage 5b: wall-load delta deck  -------------------------
    wall = rwd.wall_deck(decks_path, HERE)
    wall_path = decks_path.with_name(decks_path.stem + ".wall.json")
    _write_json(wall_path, wall)

    # --- the pair's record: selection + budget + chain (audit layer) ----
    # Written BEFORE the join so the join can embed it verbatim.  It lists
    # the six stages that PRODUCE the join; the site rebuild that renders
    # it is a delivery step the join cannot embed (the site renders FROM
    # the join) — recorded as site_rebuilt in the cache copy afterwards.
    page_path = pages_root / f"{stem}.json"
    record = {
        "schema": SCHEMA,
        "old": pair["old"],
        "new": pair["new"],
        "command": command or f"build_release_report.py {old_rev} {new_rev}",
        "analyze": {"names": names, "default": is_default,
                    "rule": DEFAULT_RULE if is_default else "explicit"},
        "budgets": {"per_tarball": per_tarball_budget, "total": total_budget,
                    "force_full_record": force_full_record},
        "stages": [
            {"stage": "diff", "script": "build_release_manifest_diff.py",
             "cite": "release_manifest_diff():110", "output": _rel(diff_path)},
            {"stage": "fetch", "script": "fetch_release_tarballs.py",
             "cite": "run():314", "output": _rel(fetch_report_path)},
            {"stage": "codediff", "script": "build_release_code_diff.py",
             "cite": "code_diff():396", "output": _rel(codediff_path)},
            {"stage": "decks", "script": "build_release_pair_decks.py",
             "cite": "pair_decks():220", "output": _rel(decks_path)},
            {"stage": "impact", "script": "build_release_impact_stats.py",
             "cite": "impact_stats():257", "output": _rel(impact_path)},
            {"stage": "wall", "script": "build_release_wall_deck.py",
             "cite": "wall_deck():284", "output": _rel(wall_path)},
            {"stage": "pagedata", "script": "build_release_page_data.py",
             "cite": "page_data():163", "output": _rel(page_path)},
        ],
        "fetch_counts": fetch["counts"],
    }
    record_path = root / "runs" / f"{stem}.json"
    _write_json(record_path, record)

    # --- stage 6: the committed page-data join (/004b) -----------
    page = rpg.page_data(diff_path, codediff_path, decks_path, impact_path,
                         wall_path, record_path)
    _write_json(page_path, page)

    # --- stage 7: rebuild the static site (the report page) -------------
    if site:
        import build_catalog
        build_catalog.main()
        record["site_rebuilt"] = True
        _write_json(record_path, record)

    print(f"release report {stem}: {diff['counts']['changed']} changed / "
          f"{diff['counts']['identical']} identical; selection "
          f"{len(names)} case(s) ({'ITER default' if is_default else tag}); "
          f"join {_rel(page_path)}")
    return record


def main(argv: list[str]) -> int:
    p = argparse.ArgumentParser(
        prog="build_release_report.py",
        description="One command from two versions (or raw shas) to the "
                    "release report page (one-command driver)")
    p.add_argument("old", help="old version (pinned table) or raw sha")
    p.add_argument("new", help="new version (pinned table) or raw sha")
    p.add_argument("--analyze", nargs="+", metavar="NAME",
                   help="tarball names to fetch + analyze (default: the "
                        "pair's ITER families)")
    p.add_argument("--per-tarball-budget", type=int,
                   default=frt.PER_TARBALL_DEFAULT)
    p.add_argument("--total-budget", type=int, default=frt.TOTAL_DEFAULT)
    p.add_argument("--force-full-record", action="store_true")
    p.add_argument("--refresh-records", action="store_true")
    p.add_argument("--no-site", action="store_true",
                   help="stop after the page-data join (no site rebuild)")
    args = p.parse_args(argv)

    run(args.old, args.new, args.analyze,
        args.per_tarball_budget, args.total_budget,
        args.force_full_record, args.refresh_records,
        site=not args.no_site,
        command=" ".join(["build_release_report.py", *argv]))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
