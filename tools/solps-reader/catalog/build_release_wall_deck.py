#!/usr/bin/env python3
"""Release-pair wall-load delta deck.

The state diff  never shows wall loads, and target loads are
what a divertor physicist upgrades for.  Per analyzed case of a release
pair this builder reads each extracted side's fort.44 wall section and
compares per loaded row — fluxes AND densities, area changes REPORTED
never normalized:

    build_release_wall_deck.py <decks.json> [--cache-root DIR] [-o out]

Authority (never re-implemented — cited at each use site):
- per-side wall summary: build_manifests.wall_summary (:251), imported
  and called VERBATIM — loaded rows are the nonzero p_tot rows (:274),
  values are the SI per-element tallies (WALL_SI :238, solps.tex
  :5064-5067), density = flux / wlarea (:281).  The reader underneath is
  solps_reader.ft44.read_ft44 (ft44.py:432).
- sides/runs/extraction: the deck record
  (catalog-deltarun-pairdecks/1), consumed exactly as the impact-stats layer does
  (build_release_impact_stats.impact_stats — same merge index, same
  compact_side honesty rule).

One-sided honesty (the measured golden-pair regime, the zenodo-absent question): every
old side of 79bb46bc..ab87f750 is zenodo-absent, so every REAL case is
one-sided — the record carries the new side's loads, the explicit
"no old side fetched — fetch to compare" note, the absent side's own
skip reason VERBATIM, and the exact driver command that would attempt
the fetch.  The both-sides comparison machinery (row_deltas) exists and
is golden-pinned on the two REAL extracted AUG sides (variant042 vs
variant017 — the relocation pattern: real bytes, real
machinery, a machinery pin never a release claim).

Area rule: wlarea is per-version input data — old/new areas are both
recorded, a change is flagged (area_rel), and the DENSITIES stay
per-side (flux/own-area).  Nothing is re-area-normalized.

Figures: one per analyzed case, in the EXISTING wall-figure
conventions (build_wall_figure.py: TYPE_COLORS panel idiom, log s-1
axis, fixed value column with flux · density, wldpeb footnote) — no new
chart design (owner ruling; dataviz not loaded).  Deterministic Agg,
metadata={"Software": None}.  Deck record joins the page-data for
card layer (build_release_page_data embeds it beside the deck
record like the impact layer).

Determinism: pure function of the deck record + extracted fort.44
bytes (sorted runs/rows, sort_keys, no timestamps).  No network (fixed
non-goal; source tripwire test pins it).

Run with the SOLPS-Reader venv interpreter (house rule).  Default output:
beside the deck record — <stem>.wall.json (cache).
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

from solps_reader.ft44 import read_ft44

from build_manifests import wall_summary
from build_release_impact_stats import compact_side
from build_wall_figure import TYPE_COLORS

SCHEMA = "catalog-deltarun-walldeck/1"
DECKS_SCHEMA = "catalog-deltarun-pairdecks/1"
WALLDECKS_DIR = Path("figures/deltarun")

HERE = Path(__file__).resolve().parent
USAGE = ("usage: build_release_wall_deck.py <decks.json> "
         "[--cache-root DIR] [-o out.json]")

#: The explicit one-sided note, verbatim (a fixed criterion).
ONE_SIDED_NOTE = "no old side fetched — fetch to compare"


def driver_command(old: str, new: str, name: str) -> str:
    """The exact command that would attempt the missing fetch — the
    axis page's own template form (build_catalog.py:1476), with raw
    12-char shas (the driver resolves both forms) and the case
    named explicitly so --analyze cannot default elsewhere."""
    return (f"../.venv/bin/python build_release_report.py "
            f"{old[:12]} {new[:12]} --analyze {name}")


def side_wall(cache_root: Path, blk: dict | None, run: str) -> tuple:
    """(wall_summary_or_None, outcome_str) for one run of one side:
    the deck record's side block says whether the extract exists; the
    extract's own fort.44 says whether wall data does."""
    if blk is None or blk.get("outcome") != "extracted" \
            or run not in blk.get("run_dirs", []):
        return None, "absent"
    f44 = cache_root / blk["extract_path"] / run / "fort.44"
    if not f44.is_file():
        return None, "no-fort44"
    try:
        ws = wall_summary(read_ft44(f44).wall)
    except Exception as exc:  # a read/parse failure is data, not a crash
        return None, f"error: {type(exc).__name__}: {exc}"
    if ws is None:
        return None, "no-wall-section"
    return ws, "ok"


def row_deltas(a: dict, b: dict) -> list[dict]:
    """Two-sided per-loaded-row comparison — A=old, B=new, the union of
    the sides' loaded rows in row order.  Fluxes AND densities are
    compared per side's OWN area (never normalized); an area change is
    itself reported (area_rel), rows loaded on one side only carry the
    other side's value as null with present-sides recorded."""
    ra = {r["row"]: r for r in a["loaded_rows_si"]}
    rb = {r["row"]: r for r in b["loaded_rows_si"]}
    out = []
    for row in sorted(ra.keys() | rb.keys()):
        x, y = ra.get(row), rb.get(row)
        rec: dict = {"row": row}
        for tag, r in (("old", x), ("new", y)):
            if r is None:
                rec[tag] = None
                continue
            rec[tag] = {"area_m2": r["area_m2"],
                        "isrftype": r["isrftype"],
                        "particle_flux_s1": r["particle_flux_s1"],
                        "particle_flux_density_m2_s1":
                            r["particle_flux_density_m2_s1"]}
        rec["present"] = [t for t in ("old", "new") if rec[t] is not None]
        if x and y:
            fa, fb = x["particle_flux_s1"], y["particle_flux_s1"]
            da_, db_ = (x["particle_flux_density_m2_s1"],
                        y["particle_flux_density_m2_s1"])
            aa, ab = x["area_m2"], y["area_m2"]
            rec["flux_rel"] = abs(fb - fa) / abs(fa) if fa else None
            rec["density_rel"] = (abs(db_ - da_) / abs(da_)
                                  if da_ else None)
            rec["area_rel"] = (abs(ab - aa) / aa
                               if aa and ab and aa != ab else 0.0)
            rec["area_changed"] = bool(rec["area_rel"])
        out.append(rec)
    return out


def compact_wall(ws: dict) -> dict:
    """The per-side block figures and pages render from — wall_summary's
    own values, subset-kept verbatim."""
    return {k: ws[k] for k in ("nlim", "nsts", "loaded_rows",
                               "integrated_si", "loaded_rows_si")}


def run_record(run: str, oblk: dict | None, nblk: dict | None,
               cache_root: Path, old: str, new: str, name: str) -> dict:
    """One run dir of one case -> the wall record (shape):
    two-sided row deltas when both sides carry wall data, one-sided
    loads + note + driver command otherwise, honest absence when a side
    carries no fort.44 wall section at all."""
    wa, sa = side_wall(cache_root, oblk, run)
    wb, sb = side_wall(cache_root, nblk, run)
    rec: dict = {"run": run,
                 "sides": {"old": sa, "new": sb}}
    if wa is not None and wb is not None:
        rec["comparison"] = "two-sided"
        rec["rows"] = row_deltas(wa, wb)
        rec["wall"] = {"old": compact_wall(wa), "new": compact_wall(wb)}
        return rec
    if wa is not None or wb is not None:
        which = "old" if wa is not None else "new"
        ws = wa if wa is not None else wb
        other = "old" if which == "new" else "new"
        oblk_other = oblk if which == "new" else nblk
        rec["comparison"] = "one-sided"
        rec["one_sided"] = {
            "side": which,
            "note": ONE_SIDED_NOTE,
            "absent_side_outcome": (oblk_other or {}).get(
                "outcome", "no-side-block"),
            "absent_side_reason": (
                (oblk_other or {}).get("skip_reason")
                or (oblk_other or {}).get("note")
                or rec["sides"][other]),
            "driver_command": driver_command(old, new, name),
        }
        rec["wall"] = {which: compact_wall(ws)}
        return rec
    rec["comparison"] = "no-wall-data"
    rec["note"] = ("no fort.44 wall-load section on any extracted side "
                   "of this run")
    return rec


def case_figure(case: dict, stem: str, base: Path) -> dict | None:
    """One figure per analyzed case in the EXISTING wall-figure
    conventions: one panel per run-side carrying wall data (the
    build_wall_figure barh idiom — type colors, log s-1 axis, fixed
    value column with flux · density, wldpeb footnote).  One-sided
    cases carry the note in the suptitle.  Null when no panel exists
    (the honest all-absent regime still gets a record, never a blank
    figure)."""
    panels = []   # (label, compact_wall, one_sided-note-or-None)
    for r in case["runs"]:
        one = r.get("one_sided")
        for which in ("old", "new"):
            ws = (r.get("wall") or {}).get(which)
            if ws is None:
                continue
            note = None
            if one is not None:
                note = (f"{one['note']} — "
                        f"old side: {one['absent_side_outcome']}; driver: "
                        f"{one['driver_command']}")
            panels.append((f"{r['run']} · {which}", ws, note))
    if not panels:
        return None
    n = len(panels)
    fig, axes = plt.subplots(
        n, 1, figsize=(9.6, 2.5 + 2.3 * n), dpi=140,
        squeeze=False, gridspec_kw={"hspace": 0.55})
    for ax, (label, ws, note) in zip(axes.ravel(), panels):
        rows = ws["loaded_rows_si"]
        y = np.arange(len(rows))
        values = [x["particle_flux_s1"] for x in rows]
        colors = [TYPE_COLORS.get(x["isrftype"] or 0, "#9aa4b2")
                  for x in rows]
        ax.barh(y, values, color=colors, height=0.62)
        annots = []
        for yi, x in zip(y, rows):
            dens = x["particle_flux_density_m2_s1"]
            annots.append(ax.text(
                1.02, yi,
                f"{x['particle_flux_s1']:.2e} s⁻¹ · "
                + (f"{dens:.2e} m⁻² s⁻¹" if dens is not None else "—"),
                transform=ax.get_yaxis_transform(),
                va="center", ha="left", fontsize=8))
        ax.set_yticks(y, [
            f"row {x['row']} · type {x['isrftype']:+d} · "
            f"{x['area_m2'] or float('nan'):.1f} m²" for x in rows],
            fontsize=8)
        ax.invert_yaxis()
        ax.set_xscale("log")
        ax.set_xlim(1e18, 4 * max(values))
        ax.set_xlabel("particle flux to segment — wldpp + wldpa + wldpm "
                      "[s⁻¹]", fontsize=8)
        ax.set_title(f"{label} — target loads (SI)", fontsize=9)
        if note:
            ax.text(0.0, -0.34, note,
                    transform=ax.transAxes, va="top", ha="left",
                    fontsize=7, color="#57606a")
    # measured layout, never tight_layout (it refuses these axes and
    # CLIPS the wide row labels — caught by the protocol-C pass): draw
    # once, then (a) shift every axes left edge so the widest y-tick
    # label clears the figure edge, (b) shrink each axes from the right
    # so the fixed value column fits — the build_wall_figure discipline.
    fig.canvas.draw()
    rend = fig.canvas.get_renderer()
    figw = fig.get_size_inches()[0] * fig.dpi
    axlist = list(axes.ravel())
    tick_x0 = min(t.get_window_extent(rend).x0
                  for ax in axlist for t in ax.get_yticklabels())
    left_short = 12.0 - tick_x0          # want labels 12 px from the edge
    if left_short > 0:
        for ax in axlist:
            bx = ax.get_position()
            ax.set_position([bx.x0 + left_short / figw, bx.y0,
                             max(bx.width - left_short / figw,
                                 0.4 * bx.width), bx.height])
    fig.canvas.draw()
    rend = fig.canvas.get_renderer()
    for ax in axlist:
        annots = [t for t in ax.texts if t.get_position()[0] == 1.02]
        rightmost = max(t.get_window_extent(rend).x1 for t in annots)
        shortfall = rightmost + 14.0 - figw
        if shortfall > 0:
            bx = ax.get_position()
            ax.set_position([
                bx.x0, bx.y0,
                max(bx.width - shortfall / figw, 0.4 * bx.width),
                bx.height])
    eb = None
    for _l, ws, _n in panels:
        v = (ws.get("integrated_si") or {}).get("eb")
        if v:
            eb = v["value"]
    fig.suptitle(f"{case['name']} — fort.44 wall loads per release "
                 f"(old → new)", fontsize=10)
    if eb is not None:
        fig.text(0.01, 0.01, f"wldpeb (emitted power, W) excluded from "
                 f"the bars — new-side total {eb:.2e} W",
                 fontsize=7, color="#57606a")
    out = base / WALLDECKS_DIR / stem / \
        f"{case['name'][:-len('.tar.gz')]}__wall.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(out, metadata={"Software": None})
    plt.close(fig)
    import hashlib
    return {"path": str(out.relative_to(base)), "bytes": out.stat().st_size,
            "md5": hashlib.md5(out.read_bytes()).hexdigest()}


def wall_deck(decks_path: Path, cache_root: Path = HERE) -> dict:
    """The JSON for one release pair (see module docstring)."""
    decks = json.loads(decks_path.read_text(encoding="utf-8"))
    if decks.get("schema") != DECKS_SCHEMA:
        raise SystemExit(f"{decks_path}: schema {decks.get('schema')!r} is "
                         f"not {DECKS_SCHEMA!r}")
    stem = decks_path.stem
    cases = []
    kinds = {}
    for c in decks["cases"]:
        ob, nb = c.get("old"), c.get("new")
        if not (ob and ob.get("outcome") == "extracted"
                or nb and nb.get("outcome") == "extracted"):
            continue  # manifest-only tier (rule)
        runs = sorted(set((ob or {}).get("run_dirs", []))
                      | set((nb or {}).get("run_dirs", [])))
        rrecs = [run_record(r, ob, nb, cache_root,
                            decks["old"], decks["new"], c["name"])
                 for r in runs]
        for r in rrecs:
            kinds[r["comparison"]] = kinds.get(r["comparison"], 0) + 1
        case = {"name": c["name"], "status": c["status"],
                "sides": {"old": compact_side(ob),
                          "new": compact_side(nb)},
                "runs": rrecs}
        case["figure"] = case_figure(case, stem, HERE)
        cases.append(case)
    return {
        "schema": SCHEMA,
        "deck_record": str(decks_path),
        "old": decks["old"], "new": decks["new"],
        "counts": {
            "deck_cases": len(decks["cases"]),
            "cases_analyzed": len(cases),
            "cases_not_analyzed": len(decks["cases"]) - len(cases),
            "runs_analyzed": sum(kinds.values()),
            **{f"runs_{k.replace('-', '_')}": v for k, v in
               sorted(kinds.items())},
        },
        "provenance": {
            "summary_rule": "build_manifests.wall_summary (:251) imported "
                            "and called VERBATIM — never re-implemented; "
                            "loaded rows = nonzero p_tot (:274), density = "
                            "flux / wlarea (:281)",
            "reader": "solps_reader.ft44.read_ft44 (ft44.py:432)",
            "units": "WALL_SI (build_manifests.py:238) — per-element SI "
                     "rates/powers, solps.tex :5064-5067",
            "sides": "deck record consumed exactly as the impact-stats layer "
                     "(build_release_impact_stats.impact_stats)",
            "figure": "existing wall-figure conventions "
                      "(build_wall_figure.py TYPE_COLORS barh idiom) — no "
                      "new chart design",
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
    if out_path is None:  # beside the deck record (convention)
        out_path = decks_path.with_name(decks_path.stem + ".wall.json")

    result = wall_deck(decks_path, cache_root)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n",
                        encoding="utf-8")
    c = result["counts"]
    print(f"{c['cases_analyzed']} case(s) analyzed "
          f"({c['cases_not_analyzed']} manifest-only), "
          f"{c['runs_analyzed']} run(s): "
          + " / ".join(f"{v} {k}" for k, v in sorted(
              (k[5:].replace('_', '-'), v) for k, v in c.items()
              if k.startswith("runs_") and k != "runs_analyzed"))
          + f" -> {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
