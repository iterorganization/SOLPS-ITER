#!/usr/bin/env python3
"""Release-pair impact stats — per-case numbers.

The deck record (, catalog-deltarun-pairdecks/1) shows WHERE the
new code moved the reference physics (variance-highlighted figures);
this builder quantifies HOW MUCH — per analyzed case, per field — the
numbers scorecard renders before any figure:

    build_release_impact_stats.py <decks.json> [--cache-root DIR] [-o out]

Authority (never re-implemented — cited at each use site):
- state values: solps_reader.state.read_b2fstate (state.py:417), sliced to
  the deck's own comparison catalog by solps_reader.cli._catalog_slices
  (cli.py:646): interior cells [2:nx+2, 2:ny+2] (the guard ring is
  solver bookkeeping), te/ti converted J -> eV, na_k per species;
  fields in the CLI's catalog order te ti ne na_0.. po (cli.py:913-917).
- relative deltas: the CLI summary's own rule, solps_reader.cli._stat_row
  (cli.py:834-852): rel = |B-A|/|A| over cells with |A| >= 1% max|A|
  (A = old side, B = new side; the mask keeps near-zero filler from
  dominating).  mean_abs_rel averages the same masked cells; argmax is
  the 0-based interior (ix, iy) of the max-rel cell — the deck figure's
  index-mode axes (cli.py:785-795) — null when nothing moved.  A
  mask-empty field (constant-zero A) has no rel values at all: null,
  the CLI's own "-" convention.
- comparability: the deck machinery's own identity checks, reused
  VERBATIM (solps_reader.cli._diff_precheck, cli.py:667 — guard-box check
  :679, species-signature check :689-91; the refusal rides a
  SystemExit(2) whose stderr text is captured verbatim, the try_deck pattern).  A mismatch is an honest per-run skip — never a
  silent gap, never a regriddled number (cross-grid regridding is a
  fixed non-goal).
- convergence verdict per side: REUSED from the deck record's compact
  verdicts (build_release_pair_decks.compact_convergence :84 ->
  build_manifests.convergence_block :180 — verdict over ACTIVE
  monitors, 3 GiB guard, size guard).  Joined here, never recomputed.

One-sided honesty (the measured golden-pair regime, the zenodo-absent question): every
old side of 79bb46bc..ab87f750 is zenodo-absent, so real cases are
ONE-SIDED — their stats are new-side-only (per-field min/max/mean over
the same interior slices) and SAY so, with the deck record's own skip
reason verbatim.  No max_abs_rel is invented for a side never fetched.
Facts note: the 2026-09-29 facts block calls cache md5s 0b810bd5 +
710d9f41 "AUG_28903 old+new" — the deck record and fetch reports (the
authorities) show both are NEW sides of the two AUG_28903 tarballs;
this builder follows the artifacts, and FORMATS.md records the
correction.  The both-sides-present golden is therefore pinned on REAL
AUG_28903 bytes through the REAL machinery (variant042 vs variant101,
same grid + species — the catalog's own AUG family pair).

Determinism: a pure function of the deck record + the extracted
b2fstate bytes (sorted runs, catalog field order, sort_keys, no
timestamps, plain json float repr — the house convention).  No network
(the fetch stage owns the network; a source tripwire test pins it).

Usage (venv interpreter, house rule):
    ../.venv/bin/python build_release_impact_stats.py \
        out/deltarun/decks/79bb46bc_ab87f750.json
Default output: beside the deck record — <stem>.impact.json (cache).
"""
from __future__ import annotations

import argparse
import contextlib
import io
import json
import sys
from pathlib import Path

import numpy as np

from solps_reader.cli import _DIFF_CATALOG, _catalog_slices, _diff_precheck
from solps_reader.state import B2fstateFormatError, read_b2fstate

SCHEMA = "catalog-deltarun-impact/1"
DECKS_SCHEMA = "catalog-deltarun-pairdecks/1"

HERE = Path(__file__).resolve().parent
USAGE = ("usage: build_release_impact_stats.py <decks.json> "
         "[--cache-root DIR] [-o out.json]")

#: The rel-delta mask floor, restated from _stat_row (cli.py:841) so the
#: artifact's provenance carries the number itself.
REL_MASK_FLOOR = 0.01


def catalog_fields(st) -> list[tuple[str, str]]:
    """(key, unit) pairs in the CLI's own deck order: te ti ne na_0.. po
    (the per-species na slotted after ne — cli.py:913-917)."""
    catalog = list(_DIFF_CATALOG)
    for k in range(st.ns):
        catalog.insert(3 + k, (f"na_{k}", ""))
    return catalog


def precondition_reason(st_a, st_b) -> str | None:
    """The deck machinery's identity checks, VERBATIM: run
    solps_reader.cli._diff_precheck (cli.py:667) on a throwaway parser and
    capture the SystemExit(2) stderr text (the try_deck
    pattern).  None = comparable."""
    err = io.StringIO()
    try:
        with contextlib.redirect_stderr(err):
            _diff_precheck(argparse.ArgumentParser(prog="impact"), st_a,
                           st_b, None)
    except SystemExit:
        return err.getvalue().strip()
    return None


def rel_stats(a: np.ndarray, b: np.ndarray) -> dict:
    """Two-sided per-field delta stats — the CLI summary's own rule
    (solps_reader.cli._stat_row, cli.py:834-852): rel = |B-A|/|A| over cells
    with |A| >= 1% max|A|.  argmax = 0-based interior (ix, iy) of the
    max-rel cell (the deck figure's index-mode axes, cli.py:785-795);
    null when nothing moved (uniformly zero delta) or no cell qualifies
    for the mask (constant-zero A — the CLI's own "-" case)."""
    adiff = np.abs(b - a)
    amax = float(np.abs(a).max())
    # constant-zero A (amax == 0) qualifies nothing: the 1%-of-zero
    # floor would let 0 >= 0 through and divide by zero — the CLI's own
    # "-" case is "nothing qualifies (constant-zero A)", so enforce it.
    mask = (np.abs(a) >= REL_MASK_FLOOR * amax) if amax > 0.0 else \
        np.zeros(a.shape, dtype=bool)
    out: dict = {"n_cells": int(a.size), "n_masked": int(mask.sum()),
                 "max_abs": float(adiff.max())}
    if not mask.any():
        out.update(max_abs_rel=None, mean_abs_rel=None, argmax=None,
                   rel_note="no cell with |A| >= 1% max|A| (constant-zero "
                            "old side — the CLI's own '-' case)")
        return out
    rel = adiff[mask] / np.abs(a)[mask]
    out["max_abs_rel"] = float(rel.max())
    out["mean_abs_rel"] = float(rel.mean())
    out["argmax"] = None
    if out["max_abs_rel"] > 0.0:
        full = np.full(a.shape, -np.inf)
        full[mask] = rel
        ix, iy = np.unravel_index(int(np.argmax(full)), a.shape)
        out["argmax"] = {"ix": int(ix), "iy": int(iy)}
    return out


def side_stats(a: np.ndarray) -> dict:
    """One-sided per-field summary over the same interior slices."""
    return {"n_cells": int(a.size), "min": float(a.min()),
            "max": float(a.max()), "mean": float(a.mean())}


def field_records(st, other=None) -> list[dict]:
    """Per-field records in catalog order.  other=None -> one-sided
    summaries of st; other set -> two-sided rel stats (A=st, B=other)."""
    slices = _catalog_slices(st)
    slices_b = _catalog_slices(other) if other is not None else None
    recs = []
    for key, unit in catalog_fields(st):
        data = slices[key]
        if not np.isfinite(data).all() or (
                slices_b is not None
                and not np.isfinite(slices_b[key]).all()):
            raise ValueError(f"non-finite values in field {key!r}")
        rec = {"field": key, "unit": unit, "shape": [st.nx, st.ny]}
        if slices_b is None:
            rec["side_stats"] = side_stats(data)
        else:
            rec["delta_stats"] = rel_stats(data, slices_b[key])
        recs.append(rec)
    return recs


def side_conv(side_blk: dict | None, run: str):
    """One side's compact convergence verdict for one run, VERBATIM from
    the deck record (never recomputed); None when the side carries no
    verdict record (skipped / not-fetched / run absent)."""
    return (side_blk or {}).get("convergence", {}).get(run)


def absent_reason(side_blk: dict | None) -> str:
    """Why a side carries no extract for a run — the deck record's own
    words, verbatim."""
    if side_blk is None:
        return "no side block in the deck record"
    if side_blk.get("outcome") == "extracted":
        return "run dir not present in this side's extract"
    return side_blk.get("skip_reason") or side_blk.get("note") or \
        side_blk.get("outcome", "unknown outcome")


def run_record(run: str, old_blk: dict | None, new_blk: dict | None,
               cache_root: Path) -> dict:
    """One run dir of one case -> the impact record.  Two-sided when
    both extracts carry the run (precondition enforced via the deck
    machinery's own checks); one-sided otherwise, SAYING so."""
    sides = {}
    for which, blk in (("old", old_blk), ("new", new_blk)):
        rd = None
        if blk is not None and blk.get("outcome") == "extracted" \
                and run in blk.get("run_dirs", []):
            rd = cache_root / blk["extract_path"] / run / "b2fstate"
        sides[which] = rd
    rec: dict = {"run": run,
                 "convergence": {"old": side_conv(old_blk, run),
                                 "new": side_conv(new_blk, run)}}
    try:
        states = {w: read_b2fstate(rd) for w, rd in sides.items()
                  if rd is not None}
    except (OSError, B2fstateFormatError) as exc:
        rec.update(comparison="error", error=f"{type(exc).__name__}: {exc}")
        return rec
    if len(states) == 2:
        st_a, st_b = states["old"], states["new"]
        rec["comparison"] = "two-sided"
        rec["grid"] = {"nx": st_a.nx, "ny": st_a.ny, "ns": st_a.ns}
        rec["a"] = f"{old_blk['extract_path']}/{run}/b2fstate"
        rec["b"] = f"{new_blk['extract_path']}/{run}/b2fstate"
        reason = precondition_reason(st_a, st_b)
        if reason is not None:
            rec.update(comparison="precondition-skip", skipped=reason)
            return rec
        try:
            rec["fields"] = field_records(st_a, st_b)
        except ValueError as exc:
            rec.update(comparison="error", error=str(exc))
        return rec
    if len(states) == 1:
        which, st = next(iter(states.items()))
        other = "new" if which == "old" else "old"
        rec["comparison"] = "one-sided"
        rec["one_sided"] = {
            "side": which,
            "absent_side_outcome": (old_blk if which == "new" else new_blk
                                    or {}).get("outcome", "no-side-block"),
            "absent_side_reason": absent_reason(
                old_blk if which == "new" else new_blk),
            "note": f"stats are {which}-side-only",
        }
        rec["state"] = f"{(old_blk if which == 'old' else new_blk)['extract_path']}/{run}/b2fstate"
        rec["grid"] = {"nx": st.nx, "ny": st.ny, "ns": st.ns}
        try:
            rec["fields"] = field_records(st)
        except ValueError as exc:
            rec.update(comparison="error", error=str(exc))
        return rec
    rec.update(comparison="error",
               error="b2fstate absent on both extracted sides")
    return rec


def compact_side(blk: dict | None) -> dict:
    """The deck record's side block minus the per-run maps (folded into
    run records) — outcome + reasons stay verbatim."""
    if blk is None:
        return {"outcome": "no-side-block"}
    return {k: v for k, v in blk.items()
            if k not in ("run_dirs", "convergence")}


def impact_stats(decks_path: Path, cache_root: Path = HERE) -> dict:
    """The JSON for one release pair (see module docstring)."""
    decks = json.loads(decks_path.read_text(encoding="utf-8"))
    if decks.get("schema") != DECKS_SCHEMA:
        raise SystemExit(f"{decks_path}: schema {decks.get('schema')!r} is "
                         f"not {DECKS_SCHEMA!r}")
    cases = []
    n_runs = {"two-sided": 0, "one-sided": 0,
              "precondition-skip": 0, "error": 0}
    for c in decks["cases"]:
        ob, nb = c.get("old"), c.get("new")
        if not (ob and ob.get("outcome") == "extracted"
                or nb and nb.get("outcome") == "extracted"):
            continue  # nothing extracted -> manifest-only tier
        runs = sorted(set((ob or {}).get("run_dirs", []))
                      | set((nb or {}).get("run_dirs", [])))
        rrecs = [run_record(r, ob, nb, cache_root) for r in runs]
        for r in rrecs:
            n_runs[r["comparison"]] += 1
        cases.append({"name": c["name"], "status": c["status"],
                      "sides": {"old": compact_side(ob),
                                "new": compact_side(nb)},
                      "runs": rrecs})
    return {
        "schema": SCHEMA,
        "deck_record": str(decks_path),
        "old": decks["old"], "new": decks["new"],
        "counts": {
            "deck_cases": len(decks["cases"]),
            "cases_analyzed": len(cases),
            # nothing-dropped proof: analyzed + not-analyzed == deck cases
            "cases_not_analyzed": len(decks["cases"]) - len(cases),
            "runs_analyzed": sum(n_runs.values()),
            "runs_two_sided": n_runs["two-sided"],
            "runs_one_sided": n_runs["one-sided"],
            "runs_precondition_skipped": n_runs["precondition-skip"],
            "runs_error": n_runs["error"],
        },
        "provenance": {
            "reader": "solps_reader.state.read_b2fstate (state.py:417)",
            "slices": "solps_reader.cli._catalog_slices (cli.py:646) — interior "
                      "cells [2:nx+2, 2:ny+2], te/ti J->eV, na_k per species",
            "field_order": "catalog order te ti ne na_0.. po (cli.py:913-917)",
            "rel_rule": "solps_reader.cli._stat_row (cli.py:834-852): |B-A|/|A| "
                        "over cells with |A| >= 1% max|A|; A=old, B=new",
            "argmax_rule": "0-based interior (ix, iy) — the deck figure's "
                           "index-mode axes (cli.py:785-795); null when "
                           "nothing moved",
            "convergence": "reused verbatim from the deck record's compact "
                           "verdicts (build_release_pair_decks.py:84 -> "
                           "build_manifests.py:180 — never recomputed)",
        },
        "cases": cases,
    }


def main(argv: list[str]) -> int:
    args = list(argv)
    out_path = None
    cache_root = HERE

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
        if "--cache-root" in args:
            cache_root = Path(take("--cache-root"))
    except ValueError:
        pass
    if len(args) != 1:
        print(USAGE, file=sys.stderr)
        return 2
    decks_path = Path(args[0])
    if out_path is None:  # beside the deck record (criterion)
        out_path = decks_path.with_name(decks_path.stem + ".impact.json")

    result = impact_stats(decks_path, cache_root)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n",
                        encoding="utf-8")
    c = result["counts"]
    print(f"{c['cases_analyzed']} case(s) analyzed "
          f"({c['cases_not_analyzed']} manifest-only), "
          f"{c['runs_analyzed']} run(s): {c['runs_two_sided']} two-sided / "
          f"{c['runs_one_sided']} one-sided -> {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
