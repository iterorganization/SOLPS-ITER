#!/usr/bin/env python3
"""Wall-loading figure (catalog v0.1,) — the v0 view, SI-honest axes.

v0 drew the stratum bars against an axis labelled "total power loading
(raw EIRENE tally)".  Both halves of that label were wrong (,
catalog/FORMATS.md): the bar values are a particle-flux sum (wldpp +
wldpa + wldpm, s-1) — wldpeb (W) cannot share the axis — and the
tallies are already SI per-element rates/powers (solps.tex :5064-5067).
This generator keeps v0's layout but plots the s-1 channels only,
labels the axis in s-1, and annotates each bar with the derived
per-area density (flux / wlarea, solps.tex :5082).

Deterministic: Agg backend, fixed size/dpi, PNG metadata stripped —
byte-identical across runs on the same matplotlib (verified by running
twice and cmp-ing during ; not yet wired into check_catalog.sh —
owns the figure pipeline from here).

the wall gate (2026-09-29): the RUN set is DERIVED, not tabulated — the
per-slug RUNS table is RETIRED.  Every run carrying a fort.44 wall
section is gate-attempted (build_manifests.wall_gate_outcome, the same
gate whose outcome the manifest records); a PASS paints, every other
outcome prints as an honest skip (never paint unverified
geometry — the gate is the only painter's license).  Build order:
figures -> manifests -> site.

Run with the SOLPS-Reader venv interpreter (house rule):
    ../.venv/bin/python build_wall_figure.py
"""
from __future__ import annotations

import math
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

from solps_reader.ft44 import read_ft44

import runs_source
from build_manifests import (
    DECK_DIR, find_run_dirs, wall_gate_outcome,
)
from f30_mesh import ITER_SURFACES, read_fort30, torus_factor

HERE = Path(__file__).resolve().parent
FIGURES = HERE / "figures"

TYPE_COLORS = {1: "#0969da", -3: "#d1850c"}   # physical / virtual (v0 palette)
GREY = "#9aa4b2"
SURF_COLORS = {           # density colormap anchors: min..max log density
    "cmap": "YlOrRd",
}


def rowvec(field, nw):
    if field is None:
        return np.zeros(nw)
    return field[..., 0].sum(axis=1) if field.ndim == 3 else field[:, 0]


def make_figure(run_dir: Path, title_machine: str, fort30: Path | None = None):
    """Return (fig, eb_total) for one run's fort.44 wall section.

    With fort30 (the baserun mesh exchange file), the loaded stratum
    segments are painted at their real coordinates (v1 view):
    the EIRENE standard mesh reconstructed per f30_mesh.py, area-gate
    verified against wlarea on this run family.
    """
    w = read_ft44(run_dir / "fort.44").wall
    nw = w.nlim + w.nsts
    ion, atom, mol = rowvec(w.wldpp, nw), rowvec(w.wldpa, nw), rowvec(w.wldpm, nw)
    eb = rowvec(w.wldpeb, nw)
    part = ion + atom + mol                      # the s-1 channels (axis-legal)
    eb_total = float(eb.sum())

    # per loaded stratum surface: density for the paint scale
    # (row = 0-based fort.44 index; block-3a card i -> row nlim+i-1)
    dens = {}
    for card_i, (_name, _idimp, _inump, _a, _b) in enumerate(ITER_SURFACES, 1):
        row = w.nlim + card_i - 1
        area = float(w.wlarea[row]) if w.wlarea is not None else 0.0
        dens[card_i] = part[row] / area if area > 0 else 0.0

    fig, (ax_geo, ax_bar) = plt.subplots(
        1, 2, figsize=(13.0, 5.4), dpi=140,
        gridspec_kw={"width_ratios": [1.15, 1.0]})

    # --- left: wall polygons + painted stratum surfaces (R-Z, metres) ------
    if w.poly is not None:
        r1, z1, r2, z2 = w.poly
        for i in range(len(r1)):
            ax_geo.plot([r1[i], r2[i]], [z1[i], z2[i]], color=GREY, lw=0.8)
    ax_geo.set_xlabel("R [m]")
    ax_geo.set_ylabel("Z [m]")
    ax_geo.set_aspect("equal")
    if (fort30 is not None and w.nsts == len(ITER_SURFACES)
            and any(d > 0 for d in dens.values())):
        # zero flux on every surface (a gate-PASS but empty run) has
        # no map to paint — the bar chart below still tells that story
        xpol, ypol, _npoint, _nx, _ny = read_fort30(fort30)
        dvals = [d for d in dens.values() if d > 0]
        dmin, dmax = min(dvals), max(dvals)
        cmap = plt.get_cmap(SURF_COLORS["cmap"])
        lo = math.log10(dmin)
        span = math.log10(dmax) - lo or 1.0
        sm = plt.cm.ScalarMappable(
            cmap=cmap, norm=plt.Normalize(vmin=lo, vmax=lo + span))
        for card_i, (name, idimp, inump, a, b) in enumerate(ITER_SURFACES, 1):
            d = dens[card_i]
            frac = (math.log10(d) - lo) / span if d > 0 else None
            color = cmap(frac) if frac is not None else "#c9d1d9"
            lw = 3.2 if d > 0 else 1.4
            if idimp == 1:                        # radial surface: one row
                r = inump - 1
                cols = list(range(a - 1, b))       # nodes a..b, segments a..b-1
                ax_geo.plot(xpol[r, cols], ypol[r, cols],
                            color=color, lw=lw,
                            solid_capstyle="round", zorder=3 if d > 0 else 2)
            else:                                  # poloidal: one column
                c = inump - 1
                rws = list(range(a - 1, b))
                ax_geo.plot(xpol[rws, c], ypol[rws, c],
                            color=color, lw=lw,
                            solid_capstyle="round", zorder=3 if d > 0 else 2)
        cbar = fig.colorbar(sm, ax=ax_geo, shrink=0.75, pad=0.04)
        cbar.set_label("particle flux density [m⁻² s⁻¹] (log)", fontsize=8)
        ticks = [lo, lo + span / 2, lo + span]
        cbar.set_ticks(ticks)
        cbar.set_ticklabels([f"{10**t:.2e}" for t in ticks])
        ax_geo.set_title(
            f"{title_machine} wall + loaded stratum segments at real R/Z\n"
            "(fort.30/LINDA mesh; area gate PASS, f30_mesh.py)",
            fontsize=9)
        ax_geo.text(0.02, 0.98,
                    "grey: fort.44 wall polygons (zero loading);\n"
                    "colored: block-3a stratum surfaces at real R/Z,\n"
                    "density from wldpp+wldpa+wldpm / wlarea",
                    transform=ax_geo.transAxes, va="top", ha="left",
                    fontsize=8, color="#57606a")
    else:
        ax_geo.set_title(f"{title_machine} fort.44 wall polygons "
                         "(zero loading in this run)", fontsize=10)
        ax_geo.text(0.02, 0.98,
                    "loading sits on the divertor-target stratum segments:\n"
                    "no in-file geometry for them (writer: polygons only)",
                    transform=ax_geo.transAxes, va="top", ha="left",
                    fontsize=8, color="#57606a")

    # --- right: stratum-segment particle loading, SI axis ------------------
    rows = list(range(w.nlim, nw))               # the NSTS block (solps.tex :5017)
    labels, values, colors = [], [], []
    for i in rows:
        t = int(w.isrftype[i]) if w.isrftype is not None else 0
        area = float(w.wlarea[i]) if w.wlarea is not None else 0.0
        labels.append(f"row {i} · type {t:+d} · {area:.1f} m²")
        values.append(float(part[i]))
        colors.append(TYPE_COLORS.get(t, GREY))
    y = np.arange(len(rows))
    pos = [yi for yi, v in zip(y, values) if v > 0]
    val = [v for v in values if v > 0]
    col = [c for c, v in zip(colors, values) if v > 0]
    if not val:
        raise ValueError(
            "no positive particle flux on any surface: nothing to plot "
            "(zero-flux run; record the absence instead of a figure)")
    ax_bar.barh(pos, val, color=col, height=0.62)
    # value column: text at a fixed axes-fraction x just right of the
    # spine (table-style, aligned to each bar's row), NOT at the bar
    # end — anchoring at the bar end made the fit data-dependent (the
    # 2171 bars, 7e24 s-1, pushed their annotation flush to the
    # figure edge; stretching the log axis to fit it inside instead
    # wasted three decades of empty axis).
    annots = []
    for yi, v, i in zip(pos, val, [r for r, v in zip(rows, values) if v > 0]):
        area = float(w.wlarea[i]) if w.wlarea is not None else 0.0
        dens = v / area if area > 0 else float("nan")
        annots.append(ax_bar.text(
            1.02, yi, f"{v:.2e} s⁻¹ · {dens:.2e} m⁻² s⁻¹",
            transform=ax_bar.get_yaxis_transform(),
            va="center", ha="left", fontsize=8))
    ax_bar.set_yticks(y, labels, fontsize=8)
    ax_bar.invert_yaxis()
    ax_bar.set_xscale("log")
    ax_bar.set_xlim(1e20, 4 * max(val))
    ax_bar.set_xlabel("particle flux to segment: wldpp + wldpa + wldpm "
                      "[s⁻¹]  (impinging ions + net-emitted neutrals)",
                      fontsize=9)
    ax_bar.set_title("Stratum-segment particle loading (SI)", fontsize=10)
    ax_bar.text(0.0, -0.20,
                "tallies are per-element SI rates (solps.tex :5064-5067, "
                "catalog/FORMATS.md);\n"
                "wldpeb (emitted power, W) is a different quantity, "
                "excluded from the bars\n"
                f"; run total {eb_total:.2e} W; areas from wlarea "
                f"(solps.tex :5082);\n"
                "density = flux / area",
                transform=ax_bar.transAxes, va="top", ha="left",
                fontsize=7.5, color="#57606a")

    fig.suptitle("EIRENE wall loading, fort.44 section: "
                 "read by SOLPS-Reader, skipped by the reference MATLAB reader, "
                 "absent from IMAS", fontsize=11)
    fig.tight_layout(rect=(0, 0.02, 1, 0.94))

    # The value column must fit between the spine and the figure edge.
    # tight_layout ignores ax.text artists, so reserve the room by hand:
    # after layout, measure the column's pixel extents and shrink the
    # axes box from the right by exactly the shortfall (+14 px margin).
    # One pass is exact — the texts sit at fixed axes-fraction x, so
    # they move with the spine and their pixel width does not change.
    fig.canvas.draw()
    rend = fig.canvas.get_renderer()
    figw = fig.get_size_inches()[0] * fig.dpi
    rightmost = max(t.get_window_extent(rend).x1 for t in annots)
    shortfall = rightmost + 14.0 - figw
    if shortfall > 0:
        bx = ax_bar.get_position()
        ax_bar.set_position([
            bx.x0, bx.y0,
            max(bx.width - shortfall / figw, 0.4 * bx.width), bx.height])
    return fig


def figure_plan(groups: list[dict] | None = None
                ) -> list[tuple[Path, Path, str, dict]]:
    """the wall gate DERIVED figure set (the RUNS table is retired): every run
    carrying a fort.44 wall section, each with its gate outcome — the
    same single-sourced gate (build_manifests.wall_gate_outcome) whose
    verdict the manifest records.  main() paints exactly the verdict
    'pass' entries; everything else is an honest skip, never a guess.

    Walks the display-ordered catalog groups; each plan entry carries
    its (run_dir, group_root, group_slug, outcome) so the painter and
    the manifest agree on the group-prefixed figure name.
    """
    if groups is None:
        groups = runs_source.resolve_groups()
    plan = []
    for g in groups:
        if g["status"] != "ok":
            continue    # the resolver already named the sick groups
        root, group_slug = g["path"], g["slug"]
        for run_dir in find_run_dirs(root):
            f44 = run_dir / "fort.44"
            if not f44.is_file():
                continue
            try:
                wall = read_ft44(f44).wall
            except Exception:
                continue    # build_manifests records the fort44 read error
            if wall is None:
                continue    # no wall section -> the no-wall-data outcome
            plan.append((run_dir, root, group_slug,
                         wall_gate_outcome(run_dir, wall, root)))
    return plan


def main() -> None:
    for run_dir, root, group_slug, outcome in figure_plan():
        rel = run_dir.relative_to(root)
        slug = "__".join((group_slug, *rel.parts))
        if outcome["verdict"] != "pass":
            why = (outcome.get("reason") or outcome.get("error")
                   or outcome.get("note") or "no reason recorded")
            print(f"skip {slug}: wall gate {outcome['verdict']} ({why})")
            continue
        # the gate records the mesh root-relative (family/baserun/
        # fort.30); the reader wants the file itself, under this
        # group's root
        fig = make_figure(run_dir, rel.parts[0], root / outcome["mesh"])
        out = FIGURES / f"{slug}.png"
        fig.savefig(out, metadata={"Software": None})
        plt.close(fig)
        print(f"{out}")


if __name__ == "__main__":
    main()
