#!/usr/bin/env python3
"""State-diff decks (catalog): family pairs + the recorded compare pairs.

Family decks — for every run family whose canonical pair resolves (rule,
pinned in build_manifests.family_diff_pairs — the same function the
manifest generator uses, so generator and inventory can never disagree
on the pair), generate the A/B comparison deck with SOLPS-Reader's own
CLI:

    cli.main(["state", "diff", <A b2fstate>, <B b2fstate>, "-o", outdir])

— the -pinned import path (no parser surgery, no reimplementation
of the deck; that would re-derive, against doctrine).  The deck lands in
figures/<family>__diff/: one overlay+difference PNG per catalog field
(te, ti, ne, na_k..., po — 4 + ns figures) plus diff_summary.txt.

Recorded decks (``--recorded``) — the comparisons the user recorded via
``catalog compare A B`` sit in the sources file; each side resolves
through the catalog groups.  A side no group provides, a missing
b2fstate, or a grid/species mismatch is a NAMED skip (never a failed
build); the deck lands under <seat>/figures/compare/<pair>__diff/.

Seating: the EXAMPLES' family decks are committed tree content
(figures/, the maintainer's byte-pinned set); everything a user build
generates — user-group family decks and every recorded pair — seats
under ``--seat-out PATH``/figures/ (the CLI passes the build's own
seat), never the checkout.

No --b2time-a/b flags: the 2588 pair's A side is ramping_drifts, whose
b2time.nc is the 2.44 GB over-guard file — with the flags omitted the
CLI renders the honest "n/a (--b2time-a not given)" lines and the pure-
python reader never touches it.  Uniform across families, so no guard
branch lives here.  No --geometry either — the measurements and
determinism proofs are on the index-grid form.

Determinism: byte-identical regenerations of ALL deck files (incl.
diff_summary.txt) were verified by cmp during ; the PNGs keep the
matplotlib tEXt chunk (acceptable — decks are staged, hash-pinned
artifacts and stage-1 rebuilds happen in this one venv, FORMATS.md).

Build order: run this BEFORE build_manifests.py — the comparisons block
in index.json inventories the deck; build_catalog.py stages
site/comparisons/<family>/ and site/compare/<pair>/ from that JSON.

Run with the SOLPS-Reader venv interpreter (house rule):
    ../.venv/bin/python build_diff_decks.py [family ...]
"""
from __future__ import annotations

import argparse
import json
import os
import shutil
import sys
from pathlib import Path

from solps_reader.cli import main as solps_reader_cli

import runs_source
from solps_reader import catalog_sources
from build_manifests import family_diff_pairs

HERE = Path(__file__).resolve().parent
FIGURES = HERE / "figures"


def recorded_pairs(sources_file: Path | None, groups: list[dict],
                   *, examples_only: bool = False) -> list[dict]:
    """The recorded-comparison list a build decks and inventories: the
    user's own pairs (the sources file) plus the REFERENCE SET's
    committed pairs (``data/recorded-comparisons.json`` — the shipped
    examples carry one so the compare verb demonstrates itself on
    every site, the certified build included).  ``--examples-only``
    (the gate's certified set) keeps the reference pairs alone; a
    build whose examples group does not stand (absent, no-runs, or
    ``--no-examples``) drops them — no reference set, no reference
    pairs, and never a named skip for content the user never chose.
    A malformed committed file fails the build loudly (it is our own
    content, the vendored-font rule)."""
    pairs = [] if examples_only else list(
        catalog_sources.load(sources_file)["comparisons"])
    stands = any(g["slug"] == runs_source.EXAMPLES_SLUG
                 and g["status"] == "ok" for g in groups)
    if stands:
        path = HERE / "data" / "recorded-comparisons.json"
        data = json.loads(path.read_text(encoding="utf-8"))
        pairs += [dict(c, reference=True)
                  for c in data.get("comparisons") or []]
    # a user pair identical to a reference pair (the same legs, either
    # order) decks and pages ONCE — first occurrence wins, and the
    # user's pairs sit first, so the kept entry is the user's own
    # record.  Without this the deck stage generates the deck twice and
    # the site stage dies on the second pass's directory (the manual
    # pass's finding: recording the reference pair yourself).
    seen: set[frozenset[str]] = set()
    merged = []
    for c in pairs:
        key = frozenset((c.get("a", ""), c.get("b", "")))
        if key in seen:
            continue
        seen.add(key)
        merged.append(c)
    return merged


def pair_slug(a: str, b: str) -> str:
    """The recorded pair's deck/page identity: both group-qualified
    names, order-stable, self-describing."""
    return "__".join(a.split("/") + ["vs"] + b.split("/"))


def _precheck(a: Path, b: Path) -> str | None:
    """The state-diff precondition, NAMED: same guard-box grid AND
    same species signature — exactly family_diff_pairs' rule."""
    from solps_reader.state import read_b2fstate
    try:
        sa, sb = read_b2fstate(a), read_b2fstate(b)
    except Exception as exc:
        return f"unreadable b2fstate: {type(exc).__name__}: {exc}"
    if tuple(sa.grid_shape) != tuple(sb.grid_shape):
        return (f"grid {tuple(sa.grid_shape)} != {tuple(sb.grid_shape)} "
                "(a diff deck needs the same grid)")
    sig = lambda st: tuple(  # noqa: E731  (local, one use, reads better)
        (sp.zamin, sp.zamax, sp.zn, sp.am) for sp in st.species)
    if sig(sa) != sig(sb):
        return ("species signatures differ "
                "(a diff deck needs the same species)")
    return None


def _resolve_side(groups: list[dict], name: str) -> tuple[Path | None,
                                                          str | None]:
    """One comparison side -> (b2fstate path, refusal reason)."""
    slug, _, rest = name.partition("/")
    for g in groups:
        if g["slug"] != slug:
            continue
        if g["status"] != "ok":
            return None, f"group {slug!r} was skipped ({g['status']})"
        st = g["path"].joinpath(*rest.split("/")) / "b2fstate"
        if not st.is_file():
            return None, f"no b2fstate at {name}"
        return st, None
    return None, f"no group provides a run named {name}"


def _deck(a: Path, b: Path, out: Path) -> int:
    if out.exists():
        shutil.rmtree(out)      # clean deck: no stale fields linger
    # portable paths: the summary header embeds both input paths
    # verbatim, so they must be relative to this tree (never
    # machine-absolute)
    return solps_reader_cli(["state", "diff",
                             os.path.relpath(a, HERE),
                             os.path.relpath(b, HERE), "-o", str(out)])


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(
        description="Generate state-diff decks: family pairs and/or "
                    "the recorded compare pairs.")
    ap.add_argument("families", nargs="*", metavar="family",
                    help="restrict the family pass to these families "
                         "(default: every family)")
    ap.add_argument("--recorded", action="store_true",
                    help="generate decks for the comparisons recorded "
                         "in the sources file (named skips for sides "
                         "no group provides)")
    ap.add_argument("--user-families", action="store_true",
                    help="also generate the canonical family-pair "
                         "decks for every USER group (seated, never "
                         "the tree's committed figures)")
    ap.add_argument("--seat-out", metavar="PATH", default=None,
                    help="the seat root: user-generated decks land "
                         "under PATH/figures/ (default: this tree's "
                         "out/figures for recorded pairs; committed "
                         "figures/ for the examples' families)")
    ap.add_argument("--sources", metavar="PATH", default=None,
                    help="the sources file (default: the per-user "
                         "share; the CLI hands its resolved path down "
                         "so subprocesses never guess a home)")
    ap.add_argument("--runs", metavar="PATH", action="append",
                    default=None,
                    help="a runs root, repeatable: the one-shot group "
                         "set for THIS run, in display order (mirrors "
                         "the other builders)")
    ap.add_argument("--no-examples", action="store_true",
                    help="omit the example-runs group")
    args = ap.parse_args(argv)
    sources_file = (Path(args.sources).expanduser()
                    if args.sources else None)
    os.chdir(HERE)  # relative diff paths resolve from here, any caller cwd
    groups = runs_source.resolve_groups(
        args.runs, include_examples=not args.no_examples,
        sources_file=sources_file)
    # recorded decks ALWAYS seat out-side (they are build artifacts of
    # whatever seat this is); the examples' family decks are committed
    # tree content; user-group family decks follow the seat
    out_figures = (Path(args.seat_out).expanduser() / "figures"
                   if args.seat_out else HERE / "out" / "figures")
    n = 0
    # the family pass: plain maintainer run (every group, committed
    # figures) or the user build's --user-families leg (user groups
    # only, seated); --recorded alone skips it
    family_pass = not args.recorded or args.user_families
    if family_pass:
        wanted = set(args.families) or None
        for g in groups:
            if g["status"] != "ok":
                continue    # the resolver already named the sick groups
            is_examples = g["slug"] == runs_source.EXAMPLES_SLUG
            if args.recorded and is_examples:
                continue    # committed figures serve the examples
            figures = FIGURES if (is_examples and not args.seat_out) \
                else out_figures
            root, group_slug = g["path"], g["slug"]
            for family, pair, n_members, _failures in \
                    family_diff_pairs(root):
                if wanted is not None and family not in wanted:
                    continue
                if pair is None:
                    print(f"skip {group_slug}/{family}: {n_members} "
                          "member(s), no pair passes the state-diff "
                          "precondition")
                    continue
                a = root / pair[0] / "b2fstate"
                b = root / pair[1] / "b2fstate"
                out = figures / f"{group_slug}__{family}__diff"
                print(f"{group_slug}/{family}: {pair[0]}  ->  {pair[1]}")
                rc = _deck(a, b, out)
                if rc != 0:
                    return rc
                n += 1
    if args.recorded:
        for c in recorded_pairs(sources_file, groups):
            a_name, b_name = c["a"], c["b"]
            label = f"{a_name} vs {b_name}"
            a_st, why_a = _resolve_side(groups, a_name)
            b_st, why_b = _resolve_side(groups, b_name)
            why = why_a or why_b
            if why is None:
                why = _precheck(a_st, b_st)
            if why is not None:
                # a reference pair a partial reference set cannot
                # support drops quietly — it is our content, never a
                # user choice the honesty doctrine protects
                if not c.get("reference"):
                    print(f"skip {label}: {why}")
                continue
            out = out_figures / "compare" / f"{pair_slug(a_name, b_name)}__diff"
            print(f"{label}: generating")
            rc = _deck(a_st, b_st, out)
            if rc != 0:
                return rc
            n += 1
    print(f"{n} diff decks -> "
          f"{out_figures if (args.recorded or args.seat_out) else FIGURES}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
