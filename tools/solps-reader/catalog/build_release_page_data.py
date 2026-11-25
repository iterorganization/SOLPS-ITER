#!/usr/bin/env python3
"""Release-pair page-data join.

Merges the four release-pair layers into ONE committed page-data
artifact the site renders from exclusively (the SwitchJoin pattern:
pages never read the cache, and never re-derive):

  out/deltarun/diffs/<stem>.json     catalog-deltarun-diff/1
          — the md5 table (every tarball, both md5s, status) + the
            per-tarball publish narrative (subjects);
  out/deltarun/codediffs/<stem>.json  catalog-deltarun-codediff/1
          — per-case code stamps/resolutions, stamp_pairs (diffstat +
            compare URL + version jump), the pair's publish compare URL
            and the doc/LOG changelog range;
  out/deltarun/decks/<stem>.json      catalog-deltarun-pairdecks/1
          — per-case deck records (files inventory path+bytes+md5, the
            doctrine) or the honest skip, + per-side convergence
            verdicts;
  out/deltarun/decks/<stem>.impact.json
          catalog-deltarun-impact/1 — per analyzed case the per-field
          impact numbers (two-sided delta stats / one-sided side stats
          + the says-so note), per-side convergence verdicts.

Those live under out/deltarun/ — a GITIGNORED CACHE (by design), so
the join artifact is written OUTSIDE it, committed, and becomes the
page's single source (the figures-PNG convention: cache -> committed
input -> site).  Every embedded block is carried VERBATIM from its
layer; this script joins, it never edits, summarizes or re-derives.
Join integrity is enforced hard (SystemExit, never a silent mismatch):
same pair commits in all layers, and the non-identical case sets of the
codediff/decks layers must equal the diff's own non-identical set (the
learning: case names carry the .tar.gz suffix); the impact
layer's analyzed set must be a SUBSET of it (manifest-only
cases stay out of the impact record by construction).

additions (the triage layers the report page renders):
  publish_subject — the publish commit's own subject VERBATIM (the
      Layer-0 one-sentence answer), selected from the narrative:
      the subject of the NEW commit among the tarballs' subjects, null
      (rendered as an honest note) when no changed tarball's narrative
      carries it;
  per-case analysis — tier analyzed|manifest-only; analyzed cases carry
      the impact runs VERBATIM plus the Layer-1 figure SELECTION (a
      recorded selection among recorded values, never a new number):
      summary_figure = the decked run's most-moved field (max
      max_abs_rel over its two-sided fields, ties -> first in the
      impact record's own field order), the deck's first field when no
      two-sided stats exist, field null when no deck exists.

addition (additive key, schema stays catalog-deltarun-page/2 —
the pattern): an optional DRIVER record
(catalog-deltarun-driver/1, written by build_release_report.py) embeds
VERBATIM as `selection` — the resolved versions, the --analyze
selection, the budgets and every stage's output, i.e. the audit-layer
answer to "what was asked for here".  Joins built before the driver
(the piecewise ..004b chain) carry no selection key; the page
renders that absence honestly.  The driver record cannot embed the
site rebuild that renders it (the site renders FROM the join) — the
join's copy lists the six producing stages, verbatim.

Output: JSON schema catalog-deltarun-page/2 (stdout or -o PATH;
default out/deltarun_pages/<diff-stem>.json).  Deterministic: diff
tarball order preserved (the own order), sort_keys, no
timestamps, no machine-dependent paths (catalog-relative sources).

Run with the SOLPS-Reader venv interpreter (house rule):
    ../.venv/bin/python build_release_page_data.py <diff.json> \
        <codediff.json> <decks.json> [-i impact.json] [-d driver.json] \
        [-o out.json]
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"

DIFF_SCHEMA = "catalog-deltarun-diff/1"
CODEDIFF_SCHEMA = "catalog-deltarun-codediff/1"
DECKS_SCHEMA = "catalog-deltarun-pairdecks/1"
IMPACT_SCHEMA = "catalog-deltarun-impact/1"
WALLDECK_SCHEMA = "catalog-deltarun-walldeck/1"
DRIVER_SCHEMA = "catalog-deltarun-driver/1"
SCHEMA = "catalog-deltarun-page/2"

USAGE = ("usage: build_release_page_data.py <diff.json> <codediff.json> "
         "<decks.json> [-i impact.json] [-w wall.json] "
         "[-d driver.json] [-o out.json]")

#: The deck-report keys embedded verbatim per case.  added/removed cases
#: carry only {"deck": None} (build_release_pair_decks.case_decks is not
#: run for them) — .get keeps the absent keys honestly None.
DECK_KEYS = ("old", "new", "deck", "skipped_pairs", "unmatched")
#: The codediff keys embedded verbatim per case.
CODE_KEYS = ("old", "new", "stamp_pairs")
#: The impact run-record keys embedded verbatim per analyzed case
#: (build_release_impact_stats.run_record — one_sided only on one-sided
#: runs; .get keeps the schema honest for both regimes).
RUN_KEYS = ("run", "comparison", "grid", "state", "convergence",
            "one_sided", "fields")
#: The wall run-record keys embedded verbatim (rows = per-loaded-
#: row deltas on two-sided runs; wall = per-side compact summaries).
WALL_RUN_KEYS = ("run", "comparison", "sides", "one_sided", "rows", "wall")


def _rel(p: Path) -> str:
    """Catalog-dir-relative path string, machine-independent."""
    try:
        return p.resolve().relative_to(HERE).as_posix()
    except ValueError:
        return p.as_posix()


def _publish_subject(diff: dict) -> str | None:
    """The publish commit's own subject, selected from the narrative: the NEW commit's subject among the tarballs' subjects
    (diff order — deterministic).  null when no changed tarball's
    narrative carries it (the page then states the absence)."""
    new = diff["new"]["commit"]
    for t in diff["tarballs"]:
        for s in t.get("subjects") or []:
            if s.get("commit") == new and s.get("subject"):
                return s["subject"]
    return None


def _summary_figure(impact_runs: list[dict], deck: dict | None) -> dict:
    """The Layer-1 figure SELECTION for one analyzed case — a recorded
    choice among recorded values, never a new number:

      most_moved     the decked run's field with the highest
                     delta_stats.max_abs_rel (ties -> first in the
                     impact record's own field order);
      deck_first     no two-sided stats on the decked run — the deck's
                     own first field (a figure exists, the ranking does
                     not);
      none           no deck exists (field null; the page renders the
                     deck record's honest skip lines instead).
    """
    none = {"field": None, "selected_by": "none", "max_abs_rel": None}
    if not deck:
        return none
    deck_run = deck.get("run")
    for r in impact_runs:
        if r.get("run") != deck_run or r.get("comparison") != "two-sided":
            continue
        best_field, best_rel = None, None
        for f in r.get("fields") or []:
            rel = ((f.get("delta_stats") or {}).get("max_abs_rel"))
            if rel is None:
                continue
            if best_rel is None or rel > best_rel:   # strict: ties -> first
                best_field, best_rel = f["field"], rel
        if best_field is not None:
            return {"field": best_field, "selected_by": "most_moved",
                    "max_abs_rel": best_rel}
    fields = deck.get("fields") or []
    if fields:
        return {"field": fields[0], "selected_by": "deck_first_field",
                "max_abs_rel": None}
    return none


def _analysis(impact_case: dict | None, deck: dict | None) -> dict:
    """The per-case tier block: manifest-only cases carry the
    tier alone; analyzed cases carry the impact runs VERBATIM (run
    records re-keyed through RUN_KEYS — .get keeps honest nulls) plus
    the figure selection."""
    if impact_case is None:
        return {"tier": "manifest-only"}
    runs = [{k: r.get(k) for k in RUN_KEYS} for r in impact_case["runs"]]
    return {
        "tier": "analyzed",
        "runs": runs,
        "summary_figure": _summary_figure(impact_case["runs"], deck),
    }


def page_data(diff_path: Path, codediff_path: Path, decks_path: Path,
              impact_path: Path | None = None,
              wall_path: Path | None = None,
              driver_path: Path | None = None) -> dict:
    """The catalog-deltarun-page/2 join of one release pair."""
    diff = json.loads(diff_path.read_text(encoding="utf-8"))
    codediff = json.loads(codediff_path.read_text(encoding="utf-8"))
    decks = json.loads(decks_path.read_text(encoding="utf-8"))
    if impact_path is None:   # beside the deck record (convention)
        impact_path = decks_path.with_name(
            decks_path.stem + ".impact.json")
    impact = json.loads(impact_path.read_text(encoding="utf-8"))
    # the wall deck record rides beside the deck record the same
    # way — but OPTIONALLY: joins built before (and pairs whose
    # wall stage was never run) carry no wall layer; the page renders
    # that absence honestly.  Only a present file is joined.
    if wall_path is None and decks_path.with_name(
            decks_path.stem + ".wall.json").is_file():
        wall_path = decks_path.with_name(decks_path.stem + ".wall.json")
    wall = None
    if wall_path is not None:
        wall = json.loads(wall_path.read_text(encoding="utf-8"))
        if wall.get("schema") != WALLDECK_SCHEMA:
            raise SystemExit(f"{wall_path}: schema {wall.get('schema')!r} "
                             f"is not {WALLDECK_SCHEMA!r}")
    for obj, path, schema in ((diff, diff_path, DIFF_SCHEMA),
                              (codediff, codediff_path, CODEDIFF_SCHEMA),
                              (decks, decks_path, DECKS_SCHEMA),
                              (impact, impact_path, IMPACT_SCHEMA)):
        if obj.get("schema") != schema:
            raise SystemExit(f"{path}: schema {obj.get('schema')!r} is not "
                             f"{schema!r}")
    driver = None
    if driver_path is not None:   # the selection record, verbatim
        driver = json.loads(driver_path.read_text(encoding="utf-8"))
        if driver.get("schema") != DRIVER_SCHEMA:
            raise SystemExit(f"{driver_path}: schema "
                             f"{driver.get('schema')!r} is not "
                             f"{DRIVER_SCHEMA!r}")
        got = (driver.get("old", {}).get("commit"),
               driver.get("new", {}).get("commit"))
        if got != (diff["old"]["commit"], diff["new"]["commit"]):
            raise SystemExit(
                f"{driver_path}: driver pair "
                f"{got[0][:12] if got[0] else '?'}.."
                f"{got[1][:12] if got[1] else '?'} does not match the "
                f"diff's pair {diff['old']['commit'][:12]}.."
                f"{diff['new']['commit'][:12]} — refusing to join a driver "
                "record across release pairs")

    old, new = diff["old"]["commit"], diff["new"]["commit"]
    for label, obj, path in (("codediff", codediff, codediff_path),
                             ("decks", decks, decks_path),
                             ("impact", impact, impact_path),
                             ("wall", wall, wall_path)):
        if obj is None:
            continue
        if (obj["old"], obj["new"]) != (old, new):
            raise SystemExit(
                f"{path}: pair {obj['old'][:12]}..{obj['new'][:12]} does not "
                f"match the diff's pair {old[:12]}..{new[:12]} — refusing to "
                f"join {label} data across release pairs")

    non_identical = {t["name"]: t["status"] for t in diff["tarballs"]
                     if t["status"] != "identical"}
    for label, obj, path in (("codediff", codediff, codediff_path),
                             ("decks", decks, decks_path)):
        got = {c["name"]: c["status"] for c in obj["cases"]}
        if got != non_identical:
            raise SystemExit(
                f"{path}: case set/status does not match the diff's "
                f"non-identical tarballs ({len(got)} vs "
                f"{len(non_identical)}) — refusing to join mismatched "
                f"{label} data")
    # the impact layer's analyzed set is a SUBSET by construction
    # (manifest-only cases stay out) — anything else is a
    # cross-pair or stale artifact, refused like the others.
    got = {c["name"]: c["status"] for c in impact["cases"]}
    unknown = got.keys() - non_identical.keys()
    if unknown or any(non_identical[n] != s for n, s in got.items()):
        raise SystemExit(
            f"{impact_path}: analyzed case set/status is not a subset of "
            f"the diff's non-identical tarballs (offenders: "
            f"{sorted(unknown) or sorted(got)}) — refusing to join "
            "mismatched impact data")
    # the wall layer's analyzed set is a subset the same way.
    if wall is not None:
        got = {c["name"]: c["status"] for c in wall["cases"]}
        unknown = got.keys() - non_identical.keys()
        if unknown or any(non_identical[n] != s for n, s in got.items()):
            raise SystemExit(
                f"{wall_path}: analyzed case set/status is not a subset "
                f"of the diff's non-identical tarballs (offenders: "
                f"{sorted(unknown) or sorted(got)}) — refusing to join "
                "mismatched wall data")

    code_by_name = {c["name"]: c for c in codediff["cases"]}
    deck_by_name = {c["name"]: c for c in decks["cases"]}
    impact_by_name = {c["name"]: c for c in impact["cases"]}
    wall_by_name = {c["name"]: c for c in (wall or {"cases": []})["cases"]}
    cases = []
    for t in diff["tarballs"]:
        if t["status"] == "identical":
            continue                    # same bytes — no delta to report
        name = t["name"]
        deck = deck_by_name[name].get("deck")
        wc = wall_by_name.get(name)
        cases.append({
            "name": name,
            "status": t["status"],
            "code": {k: code_by_name[name].get(k) for k in CODE_KEYS},
            "decks": {k: deck_by_name[name].get(k) for k in DECK_KEYS},
            "analysis": _analysis(impact_by_name.get(name), deck),
            # (additive key, schema stays page/2 — the # pattern): the wall deck record's own case block, runs
            # re-keyed through WALL_RUN_KEYS + the figure inventory.
            **({"wall": {
                "runs": [{k: r.get(k) for k in WALL_RUN_KEYS}
                         for r in wc["runs"]],
                "figure": wc.get("figure")}} if wc else {}),
        })

    return {
        "schema": SCHEMA,
        "old": old,
        "new": new,
        "sources": {
            "diff": _rel(diff_path),
            "codediff": _rel(codediff_path),
            "decks": _rel(decks_path),
            "impact": _rel(impact_path),
            **({"wall": _rel(wall_path)} if wall_path else {}),
            **({"driver": _rel(driver_path)} if driver_path else {}),
        },
        "publish_subject": _publish_subject(diff),
        "publish_compare_url": codediff["publish_compare_url"],
        "changelog": codediff["changelog"],
        "counts": diff["counts"],
        "old_n_md5_files": diff["old"]["n_md5_files"],
        "new_n_md5_files": diff["new"]["n_md5_files"],
        # The md5 table + publish narrative, verbatim, in the
        # diff's own order (sorted by path) — identical rows included:
        # an unchanged tarball is information, not a gap.
        "tarballs": diff["tarballs"],
        # the driver record (selection + budgets + chain),
        # verbatim — absent for pre-driver joins, never synthesized.
        **({"selection": driver} if driver is not None else {}),
        "cases": cases,
    }


def main(argv: list[str]) -> int:
    args = list(argv)
    out_path = impact_arg = wall_arg = driver_arg = None

    def take(flag: str) -> str:
        i = args.index(flag)
        if i + 1 >= len(args):
            print(USAGE, file=sys.stderr)
            sys.exit(2)
        val = args[i + 1]
        del args[i:i + 2]
        return val

    try:
        if "-o" in args:
            out_path = Path(take("-o"))
        if "-i" in args:
            impact_arg = Path(take("-i"))
        if "-w" in args or "--wall" in args:
            wall_arg = Path(take("-w" if "-w" in args else "--wall"))
        if "-d" in args or "--driver" in args:
            driver_arg = Path(take("-d" if "-d" in args else "--driver"))
    except ValueError:
        pass
    if len(args) != 3:
        print(USAGE, file=sys.stderr)
        return 2
    diff_path, codediff_path, decks_path = (Path(a) for a in args)
    if out_path is None:
        out_path = OUT / "deltarun_pages" / f"{diff_path.stem}.json"

    result = page_data(diff_path, codediff_path, decks_path, impact_arg,
                       wall_arg, driver_arg)
    text = json.dumps(result, indent=2, sort_keys=True) + "\n"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(text, encoding="utf-8")
    c = result["counts"]
    tiers = {"analyzed": 0, "manifest-only": 0}
    for x in result["cases"]:
        tiers[x["analysis"]["tier"]] += 1
    print(f"release page data: {out_path} — {c['changed']} changed / "
          f"{c['identical']} identical, {tiers['analyzed']} analyzed + "
          f"{tiers['manifest-only']} manifest-only case(s), "
          f"{sum(1 for x in result['cases'] if x['decks']['deck'])} deck(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
