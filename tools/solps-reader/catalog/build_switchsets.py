#!/usr/bin/env python3
"""SwitchJoin out/switchsets.json — the documentation<->run join artifact.

Every cataloged run's effective switch-set in ONE deterministic JSON, so
docs and runs join from either side without anyone re-parsing a deck:
per run  {switch: {value, source_file, vs_default, default}}  (the run
-> docs direction) plus an inverted index  switch -> [{run, value,
default}]  (the citation -> runs direction; keys are exactly askthedocs
source_switch section names, i.e. switches.json `switch` names — zero
fuzzy matching).

`default` (SwitchDefaults, additive — schema stays /1 per the
FORMATS.md additive-key pattern) is the inventory row's default string
VERBATIM, usable values and prose ("See description…") alike; a null
inventory default is stored as null; the two unknown_to_inventory names
carry NO default key.  Display-only, never re-compared: vs_default
classifications stay exactly the rules above, and the parity
between the two (same|differs <=> non-null default, no_default <=>
null, unknown <=> key absent) is pinned in tests/test_switchsets.py so
display and classification can never drift.  No defensive
transformation: today's inventory carries ZERO single-quoted defaults
(892 checked, 2026-09-29) — the note about unquoting belonged
to a different consumption layer and is corrected here.

All rules are the recon (FORMATS.md "SwitchJoin recon"),
cited per rule:

- Effective deck: whole-file vpath shadowing — runs/Makefile:131
  (`vpath %.dat .:$(baserundir)`) searches the run dir FIRST, the family
  baserun second; the winner is the only deck the solver sees
  (Makefile:192,194,196 `cp $^`).  Never key-merged.
- Scan region: b2mnds.F reads the label pair (b2rflb, :156), physics
  segments to the `*endphy` terminator (b2rfcp, :172; terminator
  b2rfcp.F:317), then the switch scan to EOF (:234-246).  Only
  post-`*endphy` lines are switches — the physics rows above (e.g. the
  `' -1'` cflim card) are NOT switches.
- Line syntax: comment iff line[0] in `* ! #` or all blank (is_comment.F
  :6-9); a switch is a line whose space/tab-stripped form starts with
  `'` (strip_spaces.F:11); list-directed two-token read (b2mnds.F:240):
  name = first quoted token, value = second token (quoted keeps content
  verbatim incl. blanks; unquoted runs to the first blank; the rest of
  the line is ignored — trailing `# ...` notes).  Names lowercased on
  storage (chcase, b2mod_ipmain.F:67-68); values stored verbatim
  (:96); re-setting replaces, so the LAST occurrence in file order wins
  (:83-87).
- vs_default ladder: strip both sides (inventory defaults carry their
  b2input.xml quoting — unquoted first); if BOTH sides parse as Fortran
  reals (`D`/`d` -> `E`; the solver's re-read is e32.0, ipgetr.F:22) ->
  numeric equality; else exact string equality.  Enum:
  same | differs | no_default_in_inventory (in the 892-name inventory
  but documented:false, default null — known read, no default recorded;
  distinct from unknown_to_inventory, census) |
  unknown_to_inventory (absent from the inventory — honest version
  drift, listed verbatim, never dropped).

Cross-repo input ../askthedocs/out/switches.json is READ-ONLY; if it is
not built this script dies naming it — never partial output.  Deck
bytes decode as latin-1 (1:1 byte map, never fails; one AUG deck
carries a U+2116 glyph on a junk post-endphy line — ignored by the
scan, and names/values are pure ASCII, proven by the b2mn.prt
parity).  Deterministic: sorted structures, sort_keys JSON, no
timestamps.  Run with the SOLPS-Reader venv interpreter (house rule).
"""
from __future__ import annotations

import json
import re
import sys
from collections import Counter
from pathlib import Path

from build_manifests import default_examples, find_run_dirs, md5_of
import runs_source

HERE = Path(__file__).resolve().parent
ASKTHEDOCS = HERE.parents[1] / "askthedocs"
INVENTORY = ASKTHEDOCS / "out" / "switches.json"
#: pinned copy of the switch inventory, shipped in this tree so the
#: rebuild works standalone; the live sibling is preferred when present.
#: Same bytes either way (md5-proven), so the artifact never differs.
VENDORED_INVENTORY = HERE / "data" / "askthedocs-switch-inventory.json"


def resolve_inventory() -> Path:
    """Live askthedocs sibling first; vendored pinned copy as fallback."""
    if INVENTORY.is_file():
        return INVENTORY
    if VENDORED_INVENTORY.is_file():
        return VENDORED_INVENTORY
    raise SystemExit(
        f"inventory missing: {rel_path(INVENTORY)} not built and no "
        f"vendored copy at {rel_path(VENDORED_INVENTORY)}; run the "
        "askthedocs build first; refusing to emit partial output")
OUT = HERE / "out"

SCHEMA = "catalog-switchsets/1"
VS_DEFAULT_VALUES = (
    "same", "differs", "no_default_in_inventory", "unknown_to_inventory",
)
DECK_DIR = "baserun"

RULES = {
    "effective_deck": (
        "whole-file shadowing, never key-merged: vpath %.dat .:baserundir "
        "searches the run dir first, then the family baserun "
        "(SOLPS-ITER/runs/Makefile:131; recipe cp $^ :192,194,196)"
   ),
    "defaults": (
        "absent keys are never ipsetc-ed, the consumer default survives "
        "(b2mnds.F:234-246; ipgetc no-action b2mod_ipmain.F:140-141): "
        "absent == not set, never unknown"
   ),
    "syntax": (
        "post-*endphy scan only (b2mnds.F:156/:172, b2rfcp.F:317); comment "
        "iff line[0] in *!# or blank (is_comment.F:6-9); switch lines are "
        "quote-led after space/tab strip (strip_spaces.F:11); list-directed "
        "2-token read (b2mnds.F:240); names lowercased (chcase "
        "b2mod_ipmain.F:67-68); values verbatim (:96); last occurrence "
        "wins (:83-87)"
   ),
    "vs_default": (
        "strip both sides (inventory defaults unquoted from their "
        "b2input.xml form); both sides Fortran reals (D/d->E, e32.0 "
        "ipgetr.F:22) -> numeric equality; else exact string equality"
   ),
    "family_decks": (
        "the baserun/b2mn.dat of each family, parsed once with the "
        "same scan: the BASE the run pages' vs-base delta reads "
        "(site-side, never re-parsed from disk); a family without a "
        "baserun dir carries no entry: every member then runs its "
        "own deck whole"
   ),
}

# the default column's own provenance sentence, formatted with
# the join census measured at build time (usable = non-null, non-prose;
# prose = the measured 'See description*' forms; missing = an indexed
# name absent from the inventory — 0 by construction, never assumed).
DEFAULT_RULE = (
    "per-entry `default` = the pinned inventory row's default VERBATIM "
    "(usable values and 'See description' prose alike; null stays null; "
    "unknown_to_inventory names carry NO default key; display only, "
    "never re-compared, vs_default stays the vs_default rules; join over "
    "the indexed switches: {usable} usable / {prose_or_null} prose-or-null"
    " / {missing} missing"
)


def is_comment(line: str) -> bool:
    """is_comment.F:6-9 — first character of the RAW line, or all blank."""
    return not line.strip() or line[0] in "*!#"


def parse_deck(text: str) -> dict[str, str]:
    """Effective switch map {lowercased name: stripped value} per the
    b2mnds.F post-*endphy scan (rules cited in the module docstring).

    Raises ValueError on a deck with no `*endphy` terminator or a switch
    line lacking its value token — both mean the file is not a form the
    recon validated, and guessing is forbidden (source-of-truth ruling).
    """
    lines = text.splitlines()
    try:
        start = next(i for i, ln in enumerate(lines)
                     if ln.strip() == "*endphy") + 1
    except StopIteration:
        raise ValueError("no *endphy terminator line") from None
    switches: dict[str, str] = {}
    for ln in lines[start:]:
        if is_comment(ln):
            continue
        s = ln.strip(" \t")
        if not s.startswith("'"):
            continue  # not a switch line; the scan ignores it
        m = re.match(r"'([^']*)'", s)
        name = m.group(1)
        rest = s[m.end():].lstrip(" \t")
        if not rest:
            raise ValueError(f"switch line without value token: {ln!r}")
        if rest.startswith("'"):
            value = re.match(r"'([^']*)'", rest).group(1)
        else:
            value = rest.split()[0]
        switches[name.lower()] = value.strip()
    return switches


_REAL = re.compile(r"^[+-]?(\d+\.?\d*|\.\d+)([eEdD][+-]?\d+)?$")


def as_real(token: str) -> float | None:
    """Fortran real or None. `D`/`d` exponents normalised to `E`
    (the solver's own re-read is e32.0, ipgetr.F:22)."""
    if _REAL.match(token):
        return float(token.replace("D", "E").replace("d", "e"))
    return None


def default_of(inv_row: dict) -> str | None:
    """Inventory default, unquoted and stripped. switches.json stores the
    b2input.xml text verbatim, so numeric defaults read as \"'1.0'\"."""
    d = inv_row["default"]
    if d is None:
        return None
    if len(d) >= 2 and d[0] == "'" and d[-1] == "'":
        d = d[1:-1]
    return d.strip()


def classify(value: str, inv_row: dict | None) -> str:
    """The vs_default ladder : unknown_to_inventory for switches
    absent from the inventory; no_default_in_inventory for documented:
    false rows (known read, no default recorded); then the numeric /
    string rungs."""
    if inv_row is None:
        return "unknown_to_inventory"
    d = default_of(inv_row)
    if d is None:
        return "no_default_in_inventory"
    a, b = as_real(value), as_real(d)
    if a is not None and b is not None:
        return "same" if a == b else "differs"
    return "same" if value == d else "differs"


class MissingDeckError(RuntimeError):
    """A run (and its family baserun) carries no b2mn.dat at all.

    The deck is an input, not an output: a run can exist without one.
    The build treats it as a named per-run absence (D-162's b2time
    precedent), never a fatal error — one deck-less run must not cost
    the other several hundred their switch sets.
    """


def effective_b2mn(run_dir: Path) -> tuple[Path, str]:
    """Resolve the ONE b2mn.dat make would hand the solver (vpath rule,
    runs/Makefile:131): run dir shadows the deck WHOLE-FILE."""
    run_file = run_dir / "b2mn.dat"
    if run_file.is_file():
        return run_file, "run"
    deck_file = run_dir.parent / DECK_DIR / "b2mn.dat"
    if deck_file.is_file():
        return deck_file, "deck"
    raise MissingDeckError(
        f"no effective b2mn.dat for {run_dir} (neither the run dir nor "
        f"the family {DECK_DIR} carries one)"
   )


def rel_path(path: Path) -> str:
    """Repo-relative display path (stable, no machine absolute paths);
    falls back to the path as given when it sits outside the tree (e.g.
    the missing-inventory error must still NAME its path, not crash)."""
    try:
        return "../" + path.relative_to(HERE.parents[1]).as_posix()
    except ValueError:
        return str(path)


def build(inventory_path: Path | None = None,
          groups: list[dict] | None = None) -> dict:
    """Assemble the catalog-switchsets/1 artifact dict over the
    display-ordered catalog groups (sick groups skipped — the
    resolver already named them)."""
    if groups is None:
        groups = runs_source.resolve_groups()
    if inventory_path is None:
        inventory_path = resolve_inventory()
    if not inventory_path.is_file():
        raise SystemExit(
            f"inventory missing: {rel_path(inventory_path)} not built; "
            "run the askthedocs build first; refusing to emit partial output"
       )
    inv = json.loads(inventory_path.read_bytes().decode("latin-1"))
    by_name = {s["switch"]: s for s in inv["switches"]}

    walk = [(g["path"], g["slug"], run_dir)
            for g in groups if g["status"] == "ok"
            for run_dir in find_run_dirs(g["path"])]
    runs_block: dict[str, dict] = {}
    effective: dict[str, dict] = {}
    absent: dict[str, str] = {}
    for root, group_slug, run_dir in walk:
        name = f"{group_slug}/{run_dir.relative_to(root)}"
        try:
            deck_file, source = effective_b2mn(run_dir)
        except MissingDeckError as exc:
            # fires on BOTH the computed and the reused path: the run
            # catalogs without a switch set, its page states the reason
            print(f"warning: {name}: {exc}; "
                  "switch set skipped, run cataloged without it")
            absent[name] = str(exc)
            continue
        switches = parse_deck(deck_file.read_bytes().decode("latin-1"))
        runs_block[name] = {
            "switch_count": len(switches),
            "switches": {
                key: {
                    "value": value, "source_file": source,
                    "vs_default": classify(value, by_name.get(key)),
                    # additive: the inventory default VERBATIM (null
                    # stays null); unknown names carry no default key.
                    **({"default": by_name[key]["default"]}
                       if key in by_name else {}),
                }
                for key, value in switches.items()
            },
            "unknown_to_inventory": sorted(
                k for k in switches if k not in by_name),
            "documented_false": {
                "count": sum(1 for k in switches
                             if k in by_name and not by_name[k]["documented"]),
                "switches": sorted(
                    k for k in switches
                    if k in by_name and not by_name[k]["documented"]),
            },
        }
        effective[name] = {
            # group-qualified runs-relative identity (stable under any
            # rung the root resolved through — never a machine path)
            "path": f"{group_slug}/"
                    f"{deck_file.relative_to(root).as_posix()}",
            "bytes": deck_file.stat().st_size,
            "md5": md5_of(deck_file), "source_file": source,
        }

    # family base decks (the landing redesign, checkpoint B): the
    # baserun deck parsed ONCE per family — the reference the run
    # pages' vs-base delta reads.  Whole-file shadowing makes this
    # the honest base: a run with its own b2mn.dat REPLACES the deck
    # (the delta is value-vs-value against THIS block, computed by
    # the site from the artifact, never re-parsed from disk).  Keyed
    # by the run_family identity the index uses (group/family);
    # families without a baserun dir carry no entry — the honest
    # absence the family page states.
    family_decks: dict[str, dict] = {}
    for root, group_slug, run_dir in walk:
        rel = run_dir.relative_to(root)
        fam_key = (f"{group_slug}/{rel.parts[1]}" if len(rel.parts) > 2
                   else f"{group_slug}/{rel.parts[0]}")
        if fam_key in family_decks:
            continue
        deck_file = run_dir.parent / DECK_DIR / "b2mn.dat"
        if not deck_file.is_file():
            continue
        family_decks[fam_key] = {
            "switches": parse_deck(
                deck_file.read_bytes().decode("latin-1")),
            "bytes": deck_file.stat().st_size,
            "md5": md5_of(deck_file),
        }

    # Inverted index (citation -> runs): keys are exactly askthedocs
    # source_switch section names — switches present in the inventory.
    # unknown_to_inventory names stay per-run only (no askthedocs citation
    # can ever name them; the honest-absence ledger keeps them verbatim).
    inverted: dict[str, list[dict]] = {}
    for name in sorted(runs_block):
        for key, entry in runs_block[name]["switches"].items():
            if entry["vs_default"] == "unknown_to_inventory":
                continue
            inverted.setdefault(key, []).append(
                {"run": name, "value": entry["value"],
                 "default": entry["default"]})

    # join census over the indexed switches (the same ^See
    # description prose form styles by — measured, not assumed).
    usable = sum(1 for k in inverted
                 if by_name[k]["default"] is not None
                 and not by_name[k]["default"].startswith("See description"))
    prose_or_null = len(inverted) - usable
    missing = sum(1 for k in inverted if k not in by_name)
    rules = {**RULES,
             "default_display": DEFAULT_RULE.format(
                 usable=usable, prose_or_null=prose_or_null, missing=missing)}

    counts = Counter(e["vs_default"]
                     for rb in runs_block.values()
                     for e in rb["switches"].values())
    # documented-but-unset — inventory names no cataloged run
    # sets.  Additive keys, display only: the switch page's collapsed
    # block renders them; they are never index keys, never classified
    # (their vs_default story is "no entry at all").  Inventory order,
    # the census's own.
    not_set = [s["switch"] for s in inv["switches"]
               if s["switch"] not in inverted]
    return {
        "schema": SCHEMA,
        "vs_default_values": list(VS_DEFAULT_VALUES),
        "provenance": {
            "inventory": {
                # the origin that fed THIS build, tree-relative when the
                # sibling stands, the vendored name otherwise — never a
                # machine absolute path
                "path": rel_path(inventory_path),
                "schema": inv["schema"],
                "bytes": inventory_path.stat().st_size,
                "md5": md5_of(inventory_path),
                "counts": inv["counts"],
                "sources": inv["sources"],
            },
            "rules": rules,
            "effective_b2mn": effective,
        },
        "runs": runs_block,
        "absent": absent,
        "family_decks": family_decks,
        "inverted_index": inverted,
        "documented_not_set": not_set,
        "counts": {**{v: counts.get(v, 0) for v in VS_DEFAULT_VALUES},
                   "runs": len(runs_block),
                   "absent_runs": len(absent),
                   "distinct_switches_set": len(inverted),
                   "documented_switches": inv["counts"]["switches"],
                   "documented_not_set": len(not_set)},
    }


def main(argv: list[str] | None = None) -> int:
    global OUT
    import argparse
    ap = argparse.ArgumentParser(
        description="Rebuild the catalog switch-sets join from a runs tree.")
    ap.add_argument("--runs", metavar="PATH", action="append",
                    default=None,
                    help="a runs root, repeatable: the one-shot group "
                         "set for THIS build, in display order (default: "
                         "the remembered sources file + the example runs, "
                         "which always follow last)")
    ap.add_argument("--no-examples", action="store_true",
                    help="omit the example-runs group")
    ap.add_argument("--examples-only", action="store_true",
                    help="catalog ONLY the example runs: the "
                         "maintainer's certified set, whatever this "
                         "machine's remembered sources hold (the gate "
                         "builds with this)")
    ap.add_argument("--out", metavar="PATH", default=None,
                    help="the out tree to write (default: this catalog "
                         "tree's out/; the CLI seats user builds in the "
                         "per-user share instead)")
    ap.add_argument("--sources", metavar="PATH", default=None,
                    help="the sources file (default: the per-user "
                         "share; the CLI hands its resolved path down "
                         "so subprocesses never guess a home)")
    args = ap.parse_args(argv)
    if args.out:
        OUT = Path(args.out).expanduser()
    try:
        groups = runs_source.resolve_groups(
            ([] if args.examples_only else args.runs),
            include_examples=(not args.no_examples),
            sources_file=(Path(args.sources).expanduser()
                          if args.sources else None))
    except runs_source.RunsError as exc:
        print(str(exc), file=sys.stderr)
        return 2
    art = build(groups=groups)
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "switchsets.json").write_text(
        json.dumps(art, indent=2, sort_keys=True) + "\n"
   , encoding="utf-8")
    c = art["counts"]
    skipped = (f", {c['absent_runs']} without a deck (skipped)"
               if c.get("absent_runs") else "")
    print(f"switchsets -> {OUT / 'switchsets.json'}: {c['runs']} runs"
          f"{skipped}, "
          f"{sum(rb['switch_count'] for rb in art['runs'].values())} "
          f"switch entries ({c['same']} same / {c['differs']} differs / "
          f"{c['no_default_in_inventory']} no-default / "
          f"{c['unknown_to_inventory']} unknown_to_inventory), "
          f"{c['distinct_switches_set']} distinct indexed switches")


if __name__ == "__main__":
    sys.exit(main())
