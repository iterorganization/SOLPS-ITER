#!/usr/bin/env python3
"""Run-manifest generator over the Zenodo example runs (catalog v0, step #2).

Walks the runs root — resolved through runs_source's ladder (--runs > the
per-user share > the floor-resolved checkout) — finds directories that carry solver outputs
(fort.44 / b2fstate / b2time.nc), and emits one JSON manifest per run dir
plus a top-level index.json — the shared JSON layer for the static catalog
 and the MCP tools .

Manifest = pillar-1 provenance, lite:
  identity + code versions (the git hashes the fort files stamp and no
  official tool consumes) + grid/species + convergence verdict (reuses
  SOLPS-Reader's _classify_trace — parity with the run-convergence MCP tool) +
  key-file inventory with MD5s + wall-load summary.

Deterministic: sorted walks, sort_keys JSON, no timestamps, no mtimes.
MD5 only for files <= 200 MB (size recorded for all); b2time.nc convergence
skipped above 3 GiB (pure-python reader cost, the fixed size threshold).

each run family also ships its sibling INPUT DECK (<family>/
baserun) as one deck manifest out/manifests/<family>__baserun.json, and
every run manifest links to it via `input_deck` (nullable). The linkage
is STRUCTURAL (sibling-directory convention, runs/Makefile:131 vpath) —
not content-verified provenance; runs may override deck inputs locally
(FORMATS.md "Input-deck linkage" honesty rule).

per-run `artifacts` block is RETIRED (, 2026-09-29):
its only payload was the convergence trace figures, whose evidence role
moved into the convergence block's `sparklines` (one inline SVG per
active monitor on the run pages — no staged PNGs, no figure generator;
make_convergence_figure.py and figures/*__convergence.png are deleted).
Run manifests carry no `artifacts` key at all now; the family diff
decks below remain the family-scope artifact inventory.

index.json gains a `comparisons` array — the same artifacts
doctrine at FAMILY scope.  Per family, the canonical diff pair
(family_diff_pairs below, single-sourced for build_diff_decks.py) and the
state-diff deck it owns under figures/<family>__diff/ are inventoried
(path + size + MD5 per file); families without a deck record an honest
skip.  Run build_diff_decks.py BEFORE this script too.

ConvSpark the convergence block gains an additive `sparklines`
key — the physical time span (timesa first/last) plus one downsampled
series per ACTIVE monitor (keys exactly `active_verdicts`; fixed ruling:
b2time.nc is read only for those named monitors' values and the span,
never to re-derive verdicts or the active set).  A run directory found
without b2time.nc catalogs with the convergence section stating that
absence — the file is optional SOLPS-ITER output, and the build warns
once naming the run (the field ruling that reversed the workshop-era
hard refusal).

ConvSpark repealed the v0 500 MB guard for exactly one file,
ITER_2588_drifts/ramping_drifts/b2time.nc, via a one-entry
CONV_GUARD_ALLOWLIST (measured full-read cost: 88 s cold / 2.9 s warm,
~4.7 GiB peak RSS).  AutoIngest (2026-09-29) RETIRED that
allowlist and replaced the whole mechanism with the fixed 3 GiB
threshold (CONV_MAX_BYTES below): the 2.28 GiB ramping_drifts file —
and any new run's big-but-sane monitor file — reads automatically, no
per-file edit ever again; only a >3 GiB file skips (reader floor
~6.4 GiB RAM, FORMATS.md section).

AutoIngest the wall gate (2026-09-29): every run manifest gains a
`wall_geometry` block — the gate-driven outcome of matching the run's
own wlareas against the six block-3a surfaces recomputed from the
family baserun fort.30 (wall_gate_outcome / wall_geometry_block below;
build_wall_figure.py imports the same gate, so the figure RUN set is
DERIVED, not tabulated).  Verdicts: pass | fail | unsupported |
unreadable | no-wall-data; the figure artifact entry (path + size +
MD5, pattern) appears ONLY on pass — a pass without its figure
is a hard error, and only a pass may paint .

Run with the SOLPS-Reader venv interpreter (house rule).
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
from itertools import combinations
from pathlib import Path

import numpy as np

from solps_reader import catalog_sources
from solps_reader.ft44 import read_ft44
from solps_reader.ft46 import read_header as ft46_read_header
from solps_reader.nc import load_nc
from solps_reader.cli import _classify_trace
from solps_reader.state import read_b2fstate

from f30_mesh import (
    ITER_MESH_DIMS, ITER_SURFACES, block3a_wlareas, read_fort30,
    surface_area, torus_factor,
)
import runs_source

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"
FIGURES_DIR = HERE / "figures"

#: A user-shaped build (share seat, not the maintainer's --in-tree
#: bump): runs seated in the example slot are the USER'S data and
#: paint their wall figures into --out like every user group, instead
#: of demanding figures committed inside the package. The gate's
#: --examples-only rebuild and the --in-tree bump never set it, so
#: the certified missing-figure contract stands where it belongs.
PAINT_EXAMPLE_FIGURES = False


class BuildRefusal(RuntimeError):
    """A build refused with a named remedy — run() prints it as one
    clean error line (exit 2); unexpected exceptions keep their
    tracebacks."""


def default_examples() -> Path:
    """The runs root through the discovery ladder (runs_source)."""
    return runs_source.resolve_examples()[0]


def __getattr__(name: str):
    """PEP 562: ``EXAMPLES`` resolves lazily through the runs ladder.

    Importing this module on a machine without run data must not walk
    the ladder — the from-importers (the deck, wall-figure, and
    release-tier scripts) resolve on first attribute access instead,
    on maintainer machines that have the data.
    """
    if name == "EXAMPLES":
        return default_examples()
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")

MARKERS = ("fort.44", "b2fstate", "b2time.nc")
KEY_FILES = (
    "fort.44", "fort.46", "b2fstate", "b2time.nc", "b2fplasma",
    "b2fmovie", "b2mn.dat", "b2fgmtry",
)
MD5_MAX_BYTES = 200 * 1024 * 1024
CONV_MAX_BYTES = 3 * 1024**3
#: (2026-09-29): the b2time.nc convergence-read size guard —
#: 3 GiB BINARY (3 * 1024**3 = 3,221,225,472 B; the same MiB/GiB
#: convention as MD5_MAX_BYTES above), decided on stat().st_size ALONE
#: so the skip is deterministic on any machine (never free RAM / load
#: — a machine-dependent skip would break the byte-identical proof).
#: Sized from the measured reader cost: load_nc peaks at ~2x file size
#: RSS (the 2.28 GiB ramping_drifts b2time.nc measured 4.7 GiB peak),
#: so a just-under-threshold file needs ~6.4 GiB free at build time —
#: the documented hardware floor.  Retires the v0 500 MB guard AND the
#: one-file allowlist in the same act; a >3 GiB file skips
#: with the reason string in convergence_block below.
CLASSES = ("plateaued", "near-plateau", "evolving", "constant")
DECK_DIR = "baserun"
DECK_NOTE = (
    "sibling input deck of the family's run dirs (runs/Makefile:131 vpath "
    "search path); run markers absent below: that absence is what makes "
    "this a deck, not a run"
)


def md5_of(path: Path) -> str | None:
    if path.stat().st_size > MD5_MAX_BYTES:
        return None
    h = hashlib.md5()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def file_entry(path: Path) -> dict:
    return {"bytes": path.stat().st_size, "md5": md5_of(path)}


def _note_unreadable(where: object, exc: OSError, what: str) -> None:
    """The one recovery line every filesystem denial prints: name the
    path, name the reason, say what happens instead.  Shared by the
    walk, the fingerprint, and the per-run guard so the wording never
    drifts (the recovery doctrine: an unreadable folder costs its own
    contents, never the build)."""
    print(f"note: cannot read {where} "
          f"({exc.strerror or type(exc).__name__}); {what}",
          file=sys.stderr)


def find_run_dirs(root: Path) -> list[Path]:
    found = []

    def _unreadable(err: OSError) -> None:
        _note_unreadable(getattr(err, "filename", None) or root, err,
                         "skipping its contents")

    # os.walk with onerror (never a bare rglob): shared archives carry
    # folders the user cannot read, and on some Python versions a bare
    # rglob turns that denial into a traceback.  The onerror line
    # names the folder; its contents cost only themselves.  Symlinked
    # directories are not entered (the documented walk rule: real
    # copies are the instrument).
    for dirpath, _dirnames, _files in os.walk(root, onerror=_unreadable):
        d = Path(dirpath)
        if any((d / m).exists() for m in MARKERS):
            found.append(d)
    return sorted(found)


def fort46_provenance(path: Path) -> dict | None:
    try:
        with open(path, encoding="ascii") as fh:
            h = ft46_read_header(fh)
    except Exception:
        return None
    return {
        "version": h.version, "git_hash": h.git_hash, "ntri": h.ntri,
        "species": h.species,
    }


#: sparkline budget: stride = max(1, n // 40) over the classifier's
#: record window — the FULL 1-D trace `_classify_trace` ravels (SOLPS-Reader
#: src/SOLPS-Reader/cli.py:579-593; the same arrays convergence_block passes it
#: below), with the final record ALWAYS included.  pinned edges:
#: 700 records -> stride 17 (43 kept), 11 records -> stride 1 (all points).
SPARK_STRIDE_TARGET = 40


def spark_series(values: np.ndarray) -> list[float]:
    """Downsample one full record trace to the sparkline series.

    Pure index selection, never arithmetic: each kept value is the
    verbatim tally at that record (json repr round-trip downstream), so
    the series re-derives from the file bytes alone.
    """
    n = int(np.asarray(values).size)
    stride = max(1, n // SPARK_STRIDE_TARGET)
    keep = list(range(0, n, stride))
    if keep[-1] != n - 1:
        keep.append(n - 1)
    return [float(values[i]) for i in keep]


def convergence_block(path: Path) -> dict:
    """One b2time.nc -> the convergence + sparklines block.

    A file over CONV_MAX_BYTES (decision on st_size alone, BEFORE any
    read) keeps its honest skip; everything at or under gets the full
    single-source read — no allowlist exists since retired it.
    """
    if path.stat().st_size > CONV_MAX_BYTES:
        return {"skipped": f"b2time.nc > {CONV_MAX_BYTES // (1 << 30)} GB "
                           "(reader floor ~6.4 GiB RAM)"}
    try:
        ncf = load_nc(path)
        names = [n for n in ncf.time_traces() if ncf.variable(n).data.size > 0]
        classes = {n: _classify_trace(np.asarray(ncf.variable(n).data)) for n in names}
    except Exception as exc:  # unreadable NC -> honest null, not a crash
        return {"error": f"{type(exc).__name__}: {exc}"}
    counts = {c: sum(1 for v in classes.values() if v == c) for c in CLASSES}
    # Verdict over ACTIVE monitors only — parity with the run-convergence
    # MCP tool: time bases (strictly increasing, e.g. timesa) evolve by
    # design and constant-zero traces were never computed; neither counts.
    time_bases = [n for n in names
                  if bool(np.all(np.diff(np.asarray(ncf.variable(n).data, dtype=float)) > 0))]
    active = [n for n in names
              if n not in time_bases and classes[n] != "constant"]
    if not active:
        verdict = "static"
    elif any(classes[n] == "evolving" for n in active):
        verdict = "evolving"
    elif any(classes[n] == "near-plateau" for n in active):
        verdict = "near-plateau"
    else:
        verdict = "plateaued"
    # physical span + per-active-monitor series, same record
    # window the classifier read (the full arrays above).  A readable
    # b2time.nc without `timesa` is a schema surprise — the KeyError is
    # deliberately loud here (no honest-null path for a missing span).
    timesa = np.asarray(ncf.variable("timesa").data, dtype=float)
    monitors = {
        n: {"units": ncf.variable(n).units or "",
            "values": spark_series(np.asarray(ncf.variable(n).data))}
        for n in active
    }
    return {"verdict": verdict, "counts": counts, "nrecords": ncf.num_records,
            "ntraces": len(names), "n_active": len(active),
            "time_bases": time_bases,
            "active_verdicts": {n: classes[n] for n in active},
            "sparklines": {
                "time_span_s": {"start": float(timesa[0]),
                                "end": float(timesa[-1])},
                "monitors": monitors,
            }}


#: SI labels for the integrated wall tallies — catalog/FORMATS.md unit
#: table (solps.tex "Output files" :5064-5067; audit 2026-09-24).
#: The per-element wld* tallies ARE SI rates/powers — there are no
#: conversion factors to apply.  The channels differ in direction, which
#: the labels must keep visible: ion impinges, atom/mol/eb are net-emitted.
WALL_SI = {
    "ion": ("particles s-1", "impinging plasma-ion flux (wldpp)"),
    "atom": ("particles s-1", "net-emitted atom flux (wldpa)"),
    "mol": ("particles s-1", "net-emitted molecule flux (wldpm)"),
    "eb": ("W", "power of emitted particles (wldpeb)"),
}
WALL_UNITS_NOTE = (
    "per-element SI rates/powers (solps.tex :5064-5067, catalog/FORMATS.md): "
    "wldpp/wldpa/wldpm particles s-1 (ion impinging; atom/mol net-emitted), "
    "wldpeb W"
)


def wall_summary(w) -> dict | None:
    if w is None:
        return None
    nw = w.nlim + w.nsts

    def rowvec(field):
        # Stratum-0 (total-over-strata) per-element vector; species summed.
        if field is None:
            return np.zeros(nw)
        return field[..., 0].sum(axis=1) if field.ndim == 3 else field[:, 0]

    def total(field):
        return float(rowvec(field).sum())

    ion, atom, mol = rowvec(w.wldpp), rowvec(w.wldpa), rowvec(w.wldpm)
    eb = rowvec(w.wldpeb)
    p_tot = ion + atom + mol + eb       # nonzero-detector (mixes units by design)
    part = ion + atom + mol             # the s-1 channels alone (SI-coherent)
    raw = {
        "ion": total(w.wldpp), "atom": total(w.wldpa),
        "mol": total(w.wldpm), "eb": total(w.wldpeb),
    }
    loaded = []
    for i in np.nonzero(p_tot)[0]:
        area = float(w.wlarea[i]) if w.wlarea is not None else 0.0
        loaded.append({
            "row": int(i),
            "isrftype": int(w.isrftype[i]) if w.isrftype is not None else None,
            "area_m2": area or None,
            "particle_flux_s1": float(part[i]),
            "particle_flux_density_m2_s1":
                float(part[i] / area) if area > 0 else None,
            "emitted_power_w": float(eb[i]),
        })
    return {
        "nlim": w.nlim, "nsts": w.nsts, "nstra": w.nstra,
        "loaded_rows": [e["row"] for e in loaded],
        "polygon_segments_nonzero": int((p_tot[: w.nlim] > 0).sum()),
        "integrated_raw": raw,
        "integrated_si": {
            k: {"value": raw[k], "unit": unit, "what": what}
            for k, (unit, what) in WALL_SI.items()
        },
        "loaded_rows_si": loaded,
        "units": WALL_UNITS_NOTE,
    }


#: the wall gate (2026-09-29): the wall-geometry gate.  Every run carrying a
#: fort.44 wall section is gate-attempted automatically: the six
#: block-3a surfaces are recomputed from the family baserun fort.30
#: (f30_mesh.py; tests/test_f30_gate.py is the pinned authority) and
#: compared to the run's OWN wlareas over the card window
#: (f30_mesh.block3a_wlareas — the alignment helper; a naive zip against
#: loaded_rows_si misaligns by one card and false-FAILs at ~19x).
#: Only a PASS may paint (never paint unverified geometry);
#: every other outcome is recorded, never a crash and never a guess.
#: Non-ITER meshes are RECORDED OUTCOMES, not exceptions.
WALL_GATE_TOL = 5e-6   # == tests/test_f30_gate.py TOL (pinned authority)


def wall_gate_outcome(run_dir: Path, wall, root: Path) -> dict:
    """Gate one run's wall geometry -> outcome dict (no figure inventory).

    Verdicts: ``pass`` (all six areas agree within WALL_GATE_TOL — the
    only painter's license), ``fail`` (readable, supported shape, areas
    disagree), ``unsupported`` (mesh readable but not the ITER 90x36
    family ITER_SURFACES was verified on, or the wall topology is not
    the six-card block), ``unreadable`` (read_fort30 raised — caught
    per-family and recorded), ``no-wall-data`` (nothing to gate).

    The mesh records ROOT-relative (``family/baserun/fort.30``) — the
    name-independent form the analysis cache stores; the manifest
    assembly group-qualifies it for display.
    """
    if wall is None:
        return {"verdict": "no-wall-data",
                "note": "no fort.44 wall-load section among this run's outputs"}
    rel = run_dir.relative_to(root)
    mesh_rel = f"{rel.parts[0]}/{DECK_DIR}/fort.30"
    try:
        xpol, ypol, npoint, dimxh, dimyh = read_fort30(root / mesh_rel)
    except Exception as exc:  # unreadable mesh is data, not a crash
        # relativize the path read_fort30 embeds so the recorded error
        # stays machine-independent (byte-identical rebuild proof)
        msg = str(exc).replace(f"{root}/", "")
        return {"verdict": "unreadable", "mesh": mesh_rel,
                "error": f"{type(exc).__name__}: {msg}"}
    block: dict = {
        "mesh": mesh_rel,
        "dims": [dimxh, dimyh],
        "patch": [list(p) for p in npoint],
    }
    if (dimxh, dimyh) != ITER_MESH_DIMS:
        return {**block, "verdict": "unsupported",
                "reason": f"mesh dims {(dimxh, dimyh)} != {ITER_MESH_DIMS} "
                          "(dimxh, dimyh): ITER_SURFACES windows are "
                          "verified for the ITER 90x36 family only"}
    try:
        wlareas = block3a_wlareas(wall)
    except ValueError as exc:
        return {**block, "verdict": "unsupported", "reason": str(exc)}
    factor = torus_factor()
    surfaces = []
    for (name, idimp, inump, a, b), gold in zip(ITER_SURFACES, wlareas):
        got = surface_area(xpol, ypol, idimp, inump, a, b, factor)
        # a zero wlarea block divides nothing: an exact zero matches,
        # anything else is an unbounded miss (recorded, never a crash)
        rel = (abs(got - gold) / gold if gold
               else (0.0 if got == gold else float("inf")))
        surfaces.append({"surface": name, "computed_m2": got,
                         "wlarea_m2": gold, "rel": rel})
    worst = max(s["rel"] for s in surfaces)
    block.update({
        "surfaces": surfaces,
        "worst_rel": worst,
        "tol": WALL_GATE_TOL,
        "verdict": "pass" if worst <= WALL_GATE_TOL else "fail",
    })
    return block


def _figure_entry(run_dir: Path, root: Path, group_slug: str,
                  gate: dict) -> dict:
    """The pass-only figure artifact entry (pattern: hash-pinned like
    a key file, so the site renders figure-or-note from JSON).

    Seating follows the deck rule: the examples' figures are committed
    tree content (a PASS without one is an ingest bug — loud, the
    maintainer's build-order contract), every USER-group figure is
    painted into THIS seat on demand (out/figures — the manual
    build_wall_figure.py step is a certified-tree contract, never a
    user's).  The entry carries its seat so the site stages from the
    right root."""
    slug = "__".join((group_slug,
                      *run_dir.relative_to(root).parts))
    committed = (group_slug == runs_source.EXAMPLES_SLUG
                 and not PAINT_EXAMPLE_FIGURES)
    figures_root = FIGURES_DIR if committed else OUT / "figures"
    fig = figures_root / f"{slug}.png"
    if not fig.is_file():
        if committed:
            # Build-order invariant (figures -> manifests -> site): a
            # PASS without its committed figure is an ingest bug
            # wearing an honest-absence mask — loud, same ruling as
            # the missing-b2time.nc error. The certified rebuild's
            # contract only: a user-shaped build paints below.
            raise BuildRefusal(
                f"{run_dir.relative_to(root)}: gate PASS but {fig} "
                "missing; run build_wall_figure.py before "
                "build_manifests.py")
        _paint_wall_figure(run_dir, root, gate, fig)
    return {"path": f"figures/{slug}.png",
            "figures_seat": "tree" if committed else "out",
            **file_entry(fig)}


def _paint_wall_figure(run_dir: Path, root: Path, gate: dict,
                       out_png: Path) -> None:
    """Paint one user seat's wall figure — the committed figures'
    own machinery (build_wall_figure.make_figure) aimed at the seat
    instead of the tree; same Agg/determinism settings as the
    maintainer's run, same gate-recorded mesh."""
    import build_wall_figure
    fig = build_wall_figure.make_figure(
        run_dir, run_dir.relative_to(root).parts[0],
        root / gate["mesh"])
    out_png.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(out_png, metadata={"Software": None})
    build_wall_figure.plt.close(fig)
    print(f"painted wall figure -> {out_png}")


def analyze_run(run_dir: Path, root: Path) -> dict:
    """The NAME-INDEPENDENT heavy analysis of one run directory — the
    unit the stat-fingerprint cache stores.  Everything here reads the
    run's own bytes (plus the sibling deck's fort.30 through the wall
    gate); nothing knows the group's name, so reordering or relabeling
    groups reuses every entry untouched.  A missing b2time.nc stays
    honest INSIDE the analysis (the file is optional SOLPS-ITER
    output): the convergence block records the absence and the build
    prints one warning line naming the run — cached entries warn
    identically on every rebuild."""
    a: dict = {
        "files": {n: file_entry(run_dir / n) for n in KEY_FILES
                  if (run_dir / n).exists()},
    }
    f44 = run_dir / "fort.44"
    ft = None
    if f44.exists():
        try:
            ft = read_ft44(f44)
            h = ft.header
            a["fort44"] = {
                "version": h.version, "git_hash": h.git_hash,
                "grid": {"nx": h.nx, "ny": h.ny},
                "species": h.species,
            }
            a["wall"] = wall_summary(ft.wall)
        except Exception as exc:
            a["fort44"] = {"error": f"{type(exc).__name__}: {exc}"}
    f46 = run_dir / "fort.46"
    if f46.exists():
        a["fort46"] = fort46_provenance(f46)
    bt = run_dir / "b2time.nc"
    if bt.is_file():
        a["convergence"] = convergence_block(bt)
    else:
        # b2time.nc is the convergence + sparklines source, and
        # optional SOLPS-ITER output: shared archives carry runs
        # without it.  The run catalogs in full otherwise; the
        # convergence section states the absence (the honest-absence
        # doctrine, same shape as the oversized-file skip).
        a["convergence"] = {
            "absent": "b2time.nc not present in this run directory"}
    a["gate"] = wall_gate_outcome(
        run_dir, None if ft is None else ft.wall, root)
    return a


def recorded_comparisons_block(groups: list[dict],
                               sources_file: Path | None = None,
                               examples_only: bool = False
                               ) -> list[dict]:
    """The recorded A/B comparisons — the user's own pairs plus the
    reference set's committed pair (build_diff_decks.recorded_pairs
    merges them, the user's first) — inventoried exactly like the
    family decks: deck-or-named-skip, never a silent absence.  A side
    no group provides, a sick group, a missing b2fstate, a grid/species
    mismatch, or a deck the pair-deck stage never wrote each carries
    its recorded reason into index.json."""
    from build_diff_decks import (_precheck, _resolve_side, pair_slug,
                                  recorded_pairs)
    entries = []
    for c in recorded_pairs(sources_file, groups,
                            examples_only=examples_only):
        a_name, b_name = c["a"], c["b"]
        entry: dict = {"a": a_name, "b": b_name, "deck": None}
        a_st, why_a = _resolve_side(groups, a_name)
        b_st, why_b = _resolve_side(groups, b_name)
        why = why_a or why_b
        if why is None:
            why = _precheck(a_st, b_st)
        if why is not None:
            # a reference pair a partial reference set cannot support
            # drops quietly (our content, never a user choice the
            # honesty doctrine protects); a user's pair names its skip
            if c.get("reference"):
                continue
            entry["skipped"] = why
            entries.append(entry)
            continue
        deck_dir = (OUT / "figures" / "compare"
                    / f"{pair_slug(a_name, b_name)}__diff")
        summary = deck_dir / "diff_summary.txt"
        if not summary.is_file():
            entry["skipped"] = (
                "deck not generated: the build's pair-deck stage "
                "must run before build_manifests.py")
            entries.append(entry)
            continue
        files = {p.name: file_entry(p) for p in sorted(deck_dir.iterdir())
                 if p.is_file()}
        lines = summary.read_text(encoding="utf-8").splitlines()
        fields = next((ln.split()[1:] for ln in lines
                       if ln.startswith("fields")), None)
        entry.update({
            "deck": f"figures/compare/{pair_slug(a_name, b_name)}__diff",
            "figures_seat": "out",
            "files": files,
            "n_figures": sum(1 for n in files if n.endswith(".png")),
            "summary_lines": len(lines),
            "fields": fields,
            "note": DIFF_DECK_NOTE,
        })
        entries.append(entry)
    return entries


def build_manifest(run_dir: Path, root: Path, group_slug: str,
                   analysis: dict) -> dict:
    """Assemble one run's manifest from its cached-or-fresh analysis:
    naming, family linkage, group-qualified display forms, and the
    pass-only figure lookup — all cheap, all re-derived every build
    (a reorder or relabel costs nothing and stays correct)."""
    rel = run_dir.relative_to(root)
    deck_slug = f"manifests/{group_slug}__{rel.parts[0]}__{DECK_DIR}.json"
    m: dict = {
        "name": f"{group_slug}/{rel}",
        "machine": rel.parts[0].split("_")[0],   # ITER / AUG / MAST
        "run_family": f"{group_slug}/{rel.parts[0]}",
        # Structural linkage only (FORMATS.md honesty rule): the FAMILY's
        # top-level baserun exists — the one directory the deck pass
        # below inventories and the family page shows (the same rule as
        # the gate's mesh path).  A run nested deeper may sit next to
        # its OWN baserun; that folder is not the family base deck, and
        # linking it here pointed at a record nobody writes.
        "input_deck": deck_slug if (root / rel.parts[0] / DECK_DIR).is_dir() else None,
        "files": analysis["files"],
    }
    for key in ("fort44", "wall", "fort46", "convergence"):
        if key in analysis:
            m[key] = analysis[key]
    gate = dict(analysis["gate"])
    if gate["verdict"] == "pass":
        # BEFORE the mesh display rewrite: the painter needs the
        # root-relative form the gate recorded
        gate["figure"] = _figure_entry(run_dir, root, group_slug, gate)
    if "mesh" in gate:
        gate["mesh"] = f"{group_slug}/{gate['mesh']}"   # display form
    m["wall_geometry"] = gate
    return m


def deck_manifest(group_slug: str, family: str, deck_dir: Path) -> dict:
    """Inventory one family's sibling input deck (<family>/baserun).

    A deck is defined by marker ABSENCE: no fort.44 / b2fstate / b2time.nc
    (the same MARKERS find_run_dirs uses), hence no convergence / fort44 /
    fort46 blocks here. Full recursive file inventory, sizes for all, MD5
    under the same 200 MB rule; .DS_Store (Finder metadata, not deck
    content) is skipped so the manifest stays stable under browsing.
    """
    files: dict[str, dict] = {}

    def _unreadable(err: OSError) -> None:
        # re-raise: a deck that cannot be read is SKIPPED by the
        # caller's guard (one named line), never inventoried as an
        # empty deck — an unread baserun is an honest absence, not a
        # zero-file deck
        raise err

    for dirpath, _dirnames, fnames in os.walk(deck_dir,
                                              onerror=_unreadable):
        for fn in sorted(fnames):
            if fn == ".DS_Store":
                continue
            p = Path(dirpath) / fn
            if not p.is_file():
                continue
            files[p.relative_to(deck_dir).as_posix()] = file_entry(p)
    return {
        "name": f"{group_slug}/{family}/{DECK_DIR}",
        "kind": "input_deck",
        "machine": family.split("_")[0],
        "run_family": f"{group_slug}/{family}",
        "files": files,
        "file_count": len(files),
        "total_bytes": sum(e["bytes"] for e in files.values()),
        "geometry": files.get("b2fgmtry"),
        "run_markers": {m: (deck_dir / m).exists() for m in MARKERS},
        "note": DECK_NOTE,
    }


def verify_deck_links(manifests_dir: Path, index: list[dict]) -> None:
    """The manifest stage's closing check: every non-null input_deck a
    build just wrote must name a file the SAME build wrote.  The link
    (at run-record time) and the deck record (at deck-pass time) agree
    by construction; this makes any future disagreement a NAMED refusal
    at the cheapest stage — never a page-stage FileNotFoundError after
    the whole build's work (the iter/DMS field crash shape)."""
    for r in index:
        m = json.loads(
            (manifests_dir / Path(r["manifest"]).name)
            .read_text(encoding="utf-8"))
        deck = m.get("input_deck")
        if deck and not (manifests_dir / Path(deck).name).is_file():
            raise BuildRefusal(
                f"{r['name']}: the shared-deck link names a file this "
                f"build did not write ({deck}); a builder bug — please "
                "report it, with the runs tree if possible")


def family_diff_pairs(
    root: Path,
) -> list[tuple[str, list[str] | None, int, list[tuple[str, str]]]]:
    """canonical diff-pair rule, single-sourced here (the deck
    generator build_diff_decks.py imports it — one rule, two consumers).

    Within each family, members are sorted lexicographically and the deck
    pair is the FIRST TWO whose b2fstate pass SOLPS-Reader ``state diff``'s
    precondition: equal guard-box ``grid_shape`` AND equal species
    signature ``[(zamin, zamax, zn, am)]`` — exactly the two checks
    ``_diff_precheck`` runs (cli.py:679, :689-691); version/git
    differences are provenance NOTEs there, not gates.  Families whose
    no member pair passes are an honest skip (single-member families in
    this catalog).

    A member whose b2fstate cannot be READ (corrupt, foreign format) is
    a NAMED failure, never a silent absence: it rides the fourth slot as
    (member, reason) and surfaces in the manifest's skip note — a family
    must not under-count its members because one of them is broken.

    Returns [(family, pair_or_None, n_members_with_b2fstate,
    [(member, reason)])] over every family that has at least one
    b2fstate-bearing or failed member, sorted by family.
    """
    families: dict[str, list[tuple[str, tuple]]] = {}
    failures: dict[str, list[tuple[str, str]]] = {}
    for run_dir in find_run_dirs(root):
        name = str(run_dir.relative_to(root))
        st_file = run_dir / "b2fstate"
        if not st_file.is_file():
            continue
        try:
            st = read_b2fstate(st_file)
            sig = (tuple(st.grid_shape),
                   tuple((sp.zamin, sp.zamax, sp.zn, sp.am) for sp in st.species))
        except Exception as exc:
            failures.setdefault(name.split("/")[0], []).append(
                (name, f"{type(exc).__name__}: {exc}"))
            continue
        families.setdefault(name.split("/")[0], []).append((name, sig))
    out = []
    for family in sorted(set(families) | set(failures)):
        members = sorted(families.get(family, []))
        pair = next(
            ([na, nb] for (na, sa), (nb, sb) in combinations(members, 2)
             if sa == sb),
            None,
       )
        out.append((family, pair, len(members), failures.get(family, [])))
    return out


#: What a diff-deck entry claims about itself (the site renders this note;
#: the honest wording matters — the deck is a STAGED ARTIFACT generated by
#: build_diff_decks.py through the SOLPS-Reader CLI, never recomputed).
DIFF_DECK_NOTE = (
    "SOLPS-Reader state diff deck (A -> B): one overlay+difference PNG per "
    "catalog field plus diff_summary.txt, generated by build_diff_decks.py "
    "through the SOLPS-Reader CLI; staged artifact, "
    "hash-pinned here like a key file, never recomputed by the site"
)


def comparisons_block(root: Path, group_slug: str) -> list[dict]:
    """the family-level artifacts inventory for index.json.

    One entry per run family: the canonical pair (family_diff_pairs) and,
    when the deck exists under figures/<family>__diff/, its full file
    inventory (same 200 MB MD5 rule as run files), figure count, summary
    line count and the field order the CLI's summary itself lists (the
    catalog order te, ti, ne, na_k..., po — NOT filename order; na_10
    sorts between na_1 and na_2 lexicographically).  Families without a
    deck record an honest skip — no pair, or the generator has not run.
    """
    entries = []
    # seating: the examples' decks are committed tree content; every
    # user-group deck is a build artifact of THIS seat (out/figures)
    figures_root = (FIGURES_DIR
                    if group_slug == runs_source.EXAMPLES_SLUG
                    else OUT / "figures")
    seat = ("tree" if group_slug == runs_source.EXAMPLES_SLUG else "out")
    for family, pair, n_members, failures in family_diff_pairs(root):
        entry: dict = {"run_family": f"{group_slug}/{family}",
                       "pair": pair, "deck": None, "figures_seat": seat}
        if failures:
            entry["unreadable_members"] = [
                {"run": m, "reason": r} for m, r in failures]
        if pair is None:
            fail_note = ("; unreadable: " + ", ".join(
                f"{m} ({r})" for m, r in failures)) if failures else ""
            entry["skipped"] = (
                f"{n_members} member(s) with b2fstate, no pair passes the "
                "same-grid + same-species diff precondition"
                + fail_note
           )
            entries.append(entry)
            continue
        deck_dir = figures_root / f"{group_slug}__{family}__diff"
        summary = deck_dir / "diff_summary.txt"
        if not summary.is_file():
            entry["skipped"] = (
                "deck not generated: run build_diff_decks.py before "
                "build_manifests.py"
           )
            entries.append(entry)
            continue
        files = {p.name: file_entry(p) for p in sorted(deck_dir.iterdir())
                 if p.is_file()}
        lines = summary.read_text(encoding="utf-8").splitlines()
        fields = next((ln.split()[1:] for ln in lines
                       if ln.startswith("fields")), None)
        entry.update({
            "deck": f"figures/{group_slug}__{family}__diff",
            "files": files,
            "n_figures": sum(1 for n in files if n.endswith(".png")),
            "summary_lines": len(lines),
            "fields": fields,
            "note": DIFF_DECK_NOTE,
        })
        entries.append(entry)
    return entries


# ------------------------------------------------- the analysis cache

#: Bump when analysis SEMANTICS change (a field recomputed differently,
#: a parser fix, a new key): every cache entry invalidates, honestly.
#: Nothing in any manifest or site records this number — it lives on
#: the machine-local cache side only.
ANALYSIS_VERSION = 1


def _stat_walk(root: Path) -> list[tuple[str, int, int]]:
    """The cheap identity of one directory's bytes: sorted
    (relpath, size, mtime_ns) over its files.  No parsing, no md5 —
    that is the whole point of the key.  A directory that cannot be
    read, or a file that cannot be stat'ed (vanished mid-build),
    contributes one named note and nothing else — the same recovery
    doctrine the run walk guarantees."""
    out: list[tuple[str, int, int]] = []

    def _unreadable(err: OSError) -> None:
        _note_unreadable(getattr(err, "filename", None) or root, err,
                         "fingerprinting the rest")

    for dirpath, _dirnames, files in os.walk(root, onerror=_unreadable):
        for fn in files:
            p = Path(dirpath) / fn
            try:
                st = p.stat()
            except OSError:
                # a symlink whose target never existed is the NORMAL
                # well-formed run shape (b2.log.gz -> run.log.gz while
                # the run carries run.log): the analysis reads it as
                # an absent file, so the fingerprint records the link
                # itself, silently — one note per run for the healthy
                # shape is noise (field finding 2026-11-19)
                try:
                    st = p.lstat()
                except OSError as exc:
                    _note_unreadable(p, exc, "fingerprinting the rest")
                    continue
            out.append((p.relative_to(root).as_posix(),
                        st.st_size, st.st_mtime_ns))
    return sorted(out)


def analysis_fingerprint(run_dir: Path, root: Path) -> str:
    """Content fingerprint of one run's ANALYSIS INPUTS: the run
    directory plus the sibling baserun deck (the wall gate reads its
    fort.30, so a touched deck invalidates the gate honestly).  The
    name-independent guarantee: the group's name is not an input —
    the same run under two groups (or a relabeled group) shares one
    entry."""
    h = hashlib.sha256()
    h.update(f"analysis-v{ANALYSIS_VERSION}".encode("ascii"))
    for rel, size, mtime in _stat_walk(run_dir):
        h.update(f"run|{rel}|{size}|{mtime}".encode("utf-8"))
    deck = run_dir.parent / DECK_DIR
    if deck.is_dir():
        for rel, size, mtime in _stat_walk(deck):
            h.update(f"deck|{rel}|{size}|{mtime}".encode("utf-8"))
    return h.hexdigest()


def cache_dir_default() -> Path:
    """The cache seats beside the sources file in the per-user share
    (the placement doctrine); a cache entry never lands in a manifest,
    a site, or the checkout."""
    return catalog_sources.sources_path().parent / "cache"


def _cache_read(cache_dir: Path, fp: str) -> dict | None:
    path = cache_dir / f"{fp}.json"
    try:
        entry = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return None                 # absent or corrupt = recompute
    analysis = entry.get("analysis")
    return analysis if isinstance(analysis, dict) else None


def _cache_write(cache_dir: Path, fp: str, analysis: dict) -> bool:
    """Best effort: an unwritable share degrades to compute-only
    (the cache is an optimization, never a gate), with one note."""
    try:
        cache_dir.mkdir(parents=True, exist_ok=True)
        tmp = cache_dir / f"{fp}.tmp"
        tmp.write_text(
            json.dumps({"fingerprint": fp, "analysis": analysis},
                       indent=2, sort_keys=True) + "\n",
            encoding="utf-8")
        tmp.replace(cache_dir / f"{fp}.json")
        return True
    except OSError:
        return False


def main(argv: list[str] | None = None) -> int:
    global EXAMPLES, OUT, PAINT_EXAMPLE_FIGURES
    ap = argparse.ArgumentParser(
        description="Rebuild the run manifests + index from the "
                    "catalog groups (the remembered sources + the "
                    "example runs, or a one-shot --runs set).")
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
    ap.add_argument("--paint-example-figures", action="store_true",
                    help="a user-shaped build: example-slot runs are "
                         "the user's own data, so their wall figures "
                         "paint into --out like every user group's, "
                         "never demanding figures committed inside "
                         "the package (the CLI passes this for every "
                         "non---in-tree build)")
    ap.add_argument("--out", metavar="PATH", default=None,
                    help="the out tree to write (default: this catalog "
                         "tree's out/; the CLI seats user builds in the "
                         "per-user share instead)")
    ap.add_argument("--force", action="store_true",
                    help="bypass the analysis cache: recompute every "
                         "run (the escape for a changed-content-"
                         "unchanged-stat edge; the outputs stay "
                         "byte-identical either way)")
    ap.add_argument("--prune-cache", action="store_true",
                    help="after a successful build, drop cache entries "
                         "this build did not reference (orphans are "
                         "KEPT by default so re-adding a folder stays "
                         "cheap)")
    ap.add_argument("--cache", metavar="PATH", default=None,
                    help="the analysis cache directory (default: the "
                         "per-user share beside the sources file)")
    ap.add_argument("--sources", metavar="PATH", default=None,
                    help="the sources file for the recorded "
                         "comparisons (default: the per-user share; "
                         "the CLI hands its resolved path down so "
                         "subprocesses never guess a home)")
    args = ap.parse_args(argv)
    if args.out:
        OUT = Path(args.out).expanduser()
    PAINT_EXAMPLE_FIGURES = bool(args.paint_example_figures)
    cache_dir = (Path(args.cache).expanduser() if args.cache
                 else cache_dir_default())
    sources_file = (Path(args.sources).expanduser()
                    if args.sources else None)
    try:
        groups = runs_source.resolve_groups(
            ([] if args.examples_only else args.runs),
            include_examples=(not args.no_examples),
            sources_file=sources_file)
    except runs_source.RunsError as exc:
        print(str(exc), file=sys.stderr)
        return 2
    for i, g in enumerate(groups, 1):
        print(f"group {i}: {g['label']} [{g['status']}] "
              f"{g['path'] or ''}".rstrip())
    ok_groups = [g for g in groups if g["status"] == "ok"]
    manifests_dir = OUT / "manifests"
    manifests_dir.mkdir(parents=True, exist_ok=True)

    index = []
    wg_counts: dict[str, int] = {}
    n_runs = 0
    n_computed = n_reused = 0
    cache_note_shown = False
    used_fps: set[str] = set()
    written: set[str] = set()
    # per-case progress (field feedback: hundreds of cases make the
    # manifests stage long and silent): ONE printed line per case, at
    # the moment work on it starts, naming it group-qualified with a
    # running counter — a stuck build shows exactly where it stopped
    group_runs = [(g, find_run_dirs(g["path"])) for g in ok_groups]
    for g, runs in group_runs:
        if g["slug"] == runs_source.EXAMPLES_SLUG:
            EXAMPLES = g["path"]
    n_total = sum(len(runs) for _g, runs in group_runs)
    n_seen = 0
    for g, runs in group_runs:
        for run_dir in runs:
            n_seen += 1
            name = f"{g['slug']}/{run_dir.relative_to(g['path'])}"
            print(f"case {n_seen}/{n_total}: {name}")
            try:
                fp = analysis_fingerprint(run_dir, g["path"])
                used_fps.add(fp)
                analysis = (None if args.force
                            else _cache_read(cache_dir, fp))
                if analysis is None:
                    analysis = analyze_run(run_dir, g["path"])
                    n_computed += 1
                    if not _cache_write(cache_dir, fp, analysis) \
                            and not cache_note_shown:
                        print(f"note: cache unwritable ({cache_dir}); "
                              "computing without it", file=sys.stderr)
                        cache_note_shown = True
                else:
                    n_reused += 1
                if (analysis.get("convergence") or {}).get("absent"):
                    # fires on BOTH the computed and the reused path:
                    # a cached absence warns like a fresh one, every
                    # rebuild, until the run gains its b2time.nc
                    print(f"warning: {name}: no b2time.nc; "
                          "cataloged without convergence")
                m = build_manifest(run_dir, g["path"], g["slug"],
                                   analysis)
                v = m["wall_geometry"]["verdict"]
                wg_counts[v] = wg_counts.get(v, 0) + 1
                slug = "__".join(m["name"].split("/"))
                written.add(f"{slug}.json")
                (manifests_dir / f"{slug}.json").write_text(
                    json.dumps(m, indent=2, sort_keys=True) + "\n"
               , encoding="utf-8")
                index.append({
                    "name": m["name"], "machine": m["machine"],
                    "run_family": m.get("run_family", m["machine"]),
                    "group": g["slug"], "group_label": g["label"],
                    "verdict": (m.get("convergence") or {}).get("verdict"),
                    "grid": (m.get("fort44") or {}).get("grid"),
                    "species": (m.get("fort44") or {}).get("species"),
                    "code_git": (m.get("fort44") or {}).get("git_hash"),
                    "has_wall_loads": bool((m.get("wall") or {})
                                           .get("loaded_rows")),
                    "manifest": f"manifests/{slug}.json",
                })
                n_runs += 1
            except (PermissionError, FileNotFoundError) as exc:
                # the recovery doctrine: a run that cannot be read (or
                # vanished mid-build) costs ITSELF, never the build —
                # named here, skipped, and the stale-manifest prune
                # below drops any ghost an earlier build left behind
                _note_unreadable(run_dir, exc,
                                 f"skipping {name}; the other runs "
                                 "continue")
                continue

    # one deck manifest per run family that carries a baserun —
    # family identity is group-qualified (two groups may each carry
    # an ITER_2275 family; they are different families).
    decks = []
    deck_skipped: set[str] = set()
    for g in ok_groups:
        fams = sorted({r["name"].split("/")[1] for r in index
                       if r["group"] == g["slug"]})
        for family in fams:
            deck_dir = g["path"] / family / DECK_DIR
            if not deck_dir.is_dir():
                continue
            carried = [mk for mk in MARKERS if (deck_dir / mk).exists()]
            if carried:
                # marker ABSENCE is the deck definition (deck_manifest's
                # own note) — enforced here, not just asserted.  A baserun
                # that itself carries run output was already cataloged as
                # a RUN by the walk above; writing its deck record too
                # would claim the same file name and clobber the run's
                # record.  The family keeps its runs; the deck pass
                # stays silent about it beyond this one named line.
                print(f"note: {g['slug']}/{family}/{DECK_DIR} carries "
                      f"run output ({', '.join(carried)}); it is "
                      "cataloged as a run, so the family carries no "
                      "deck record", file=sys.stderr)
                deck_skipped.add(f"{g['slug']}/{family}")
                continue
            try:
                dm = deck_manifest(g["slug"], family, deck_dir)
                mslug = f"{g['slug']}__{family}__{DECK_DIR}"
                written.add(f"{mslug}.json")
                (manifests_dir / f"{mslug}.json").write_text(
                    json.dumps(dm, indent=2, sort_keys=True) + "\n"
               , encoding="utf-8")
                decks.append({
                    "run_family": f"{g['slug']}/{family}",
                    "manifest": f"manifests/{mslug}.json",
                    "file_count": dm["file_count"],
                    "total_bytes": dm["total_bytes"],
                    "geometry_file": dm["geometry"] is not None,
                })
            except (PermissionError, FileNotFoundError) as exc:
                # the deck twin of the run guard: an unreadable
                # baserun costs its own deck manifest, never the
                # build (the family's runs stand without it)
                _note_unreadable(deck_dir, exc,
                                 f"skipping {g['slug']}/{family}'s "
                                 "deck manifest; the runs continue")
                deck_skipped.add(f"{g['slug']}/{family}")
                continue
    if deck_skipped:
        # linkage honesty: the run manifests were written BEFORE the
        # deck pass and reference the deck manifest by directory
        # existence alone — a skipped deck leaves a dangling reference
        # the site would chase.  Null it, so the family and run pages
        # render their honest no-shared-base-deck absence instead.
        for r in index:
            if r["run_family"] not in deck_skipped:
                continue
            mp = manifests_dir / Path(r["manifest"]).name
            m = json.loads(mp.read_text(encoding="utf-8"))
            m["input_deck"] = None
            mp.write_text(json.dumps(m, indent=2, sort_keys=True)
                          + "\n", encoding="utf-8")
    # the closing check: after every write and every null, no run
    # record may point at a deck record this build did not write
    verify_deck_links(manifests_dir, index)

    comparisons: list[dict] = []
    for g in ok_groups:
        comparisons += comparisons_block(g["path"], g["slug"])
    # --examples-only is the gate's certified set: the maintainer's
    # personal groups and their recorded comparisons stay out of it —
    # the REFERENCE SET's own committed pair stays (it is example
    # content, not the maintainer's choice)
    recorded = recorded_comparisons_block(
        groups,
        Path(args.sources).expanduser() if args.sources else None,
        examples_only=args.examples_only)
    # clean rebuild (the site's own rmtree doctrine): manifests this
    # build did not write are stale — renamed or dropped groups must
    # not linger as ghosts a reader could mistake for cataloged runs
    n_stale = 0
    for p in sorted(manifests_dir.glob("*.json")):
        if p.name not in written:
            p.unlink()
            n_stale += 1
    if n_stale:
        print(f"  {n_stale} stale manifest(s) removed")
    # display order throughout: groups in list order, families and
    # runs sorted within each group — never a global re-sort
    (OUT / "index.json").write_text(
        json.dumps({
            # STABLE forms only (the byte-determinism doctrine: no
            # machine paths in artifacts): the examples group records
            # its fixed identity, user groups their own local paths
            "groups": [{
                "slug": g["slug"], "label": g["label"],
                "path": (None if g["slug"] == runs_source.EXAMPLES_SLUG
                         else str(g["path"])),
                "status": g["status"],
                "via": ("the shipped example set"
                        if g["slug"] == runs_source.EXAMPLES_SLUG
                        else "a user runs folder")}
                for g in groups],
            "runs": index,
            "decks": decks,
            "comparisons": comparisons,
            "recorded_comparisons": recorded},
                   indent=2, sort_keys=True) + "\n"
   , encoding="utf-8")
    print(f"{n_runs} run manifests + {len(decks)} deck manifests -> {OUT}")
    n_rec = sum(1 for c in recorded if c.get("deck"))
    print(f"  recorded comparisons: {n_rec} deck(s), "
          f"{len(recorded) - n_rec} named skip(s)")
    print(f"  analysis cache: {n_reused} reused, {n_computed} computed "
          f"({cache_dir})")
    if args.prune_cache and cache_dir.is_dir():
        kept = dropped = 0
        for p in sorted(cache_dir.glob("*.json")):
            if p.stem in used_fps:
                kept += 1
            else:
                p.unlink()
                dropped += 1
        print(f"  cache pruned: {dropped} dropped, {kept} kept")
    n_diff = sum(1 for c in comparisons if c.get("deck"))
    print(f"  {n_diff} family diff decks ")
    print("  wall gate (the wall gate): "
          + ", ".join(f"{n} {v}" for v, n in sorted(wg_counts.items())))
    for r in index:
        print(f"  {r['verdict'] or '-':>11}  {r['name']}")
    for d in decks:
        print(f"  {'deck':>11}  {d['run_family']}/{DECK_DIR} "
              f"({d['file_count']} files)")


def run(argv: list[str] | None = None) -> int:
    """main() with the named refusals converted to clean one-line
    errors (exit 2, no traceback — the CLI banner stays the only
    wrapper the user sees)."""
    try:
        return main(argv)
    except BuildRefusal as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(run())
