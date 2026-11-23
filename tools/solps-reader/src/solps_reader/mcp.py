"""The MCP face of SOLPS-Reader — run analysis over the wire.

Fourteen read-only tools answering questions about SOLPS-ITER run
directories (inventories, field summaries, convergence, plasma state,
the full plasma solution, wall loadings), the dated doc/LOG changelog,
and the shipped run-catalog artifacts (catalog summaries, manifests,
the ruled switch joins). Powered by the SOLPS-Reader library this
package installs — the MCP answers and the CLI share one
implementation.

Per-call semantics: every tool takes its run directory, file, or
catalog location as an EXPLICIT argument; a call without it answers
a loud named error with an example. The server never assumes a
location — pointed-at data, never installed data.

Run with ``solps-mcp`` (or ``python -m solps_reader.mcp``).
"""

from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path

import numpy as np
from mcp.server.mcpserver import MCPServer
from solps_reader import __version__
from solps_reader.cli import (
    _NUMERIC_KINDS,
    _classify_trace,
    _field_candidates,
    _stat_cells,
    _trace_drift,
    check_grid,
    format_plasma_summary,
    format_state_summary,
)
from solps_reader.ft44 import Ft44FormatError, read_ft44, read_ft44_header
from solps_reader.ft46 import Ft46FormatError, read_ft46
from solps_reader.gmtry import read_b2fgmtry
from solps_reader.nc import NcFormatError, load_nc
from solps_reader.plasma import B2fplasmaFormatError, read_b2fplasma
from solps_reader.state import read_b2fstate

#: example paths used ONLY inside the no-argument error messages —
#: the server assumes nothing about the caller's disk
EXAMPLE_RUN = "/solps/runs/ITER_2275_Donly_20MW"


def _need_arg(arg: str, what: str, example: str) -> str:
    """The loud no-argument answer: names the argument and an example."""
    return (f"no {what} given: pass `{arg}` explicitly "
            f"(example: {arg}='{example}'). This server never assumes "
            "a location: every call names its data.")

mcp = MCPServer("solps-mcp", version=__version__)

# What each well-known run file is (for scan_run_directory output).
FILE_GLOSSARY = {
    "fort.44": "EIRENE→B2.5 source-term exchange, ASCII, self-labeled fields",
    "fort.46": "EIRENE data on the triangular wall/target mesh, ASCII",
    "fort.30": "B2.5→EIRENE plasma background, ASCII",
    "fort.33": "Triangulated mesh for EIRENE: mesh nodes",
    "fort.34": "Triangulated mesh for EIRENE: triangles",
    "fort.35": "Triangulated mesh for EIRENE: surface assignment",
    "b2fstate": "B2.5 plasma state, cf-ASCII records (not XDR; verified from the bytes by this library)",
    "b2fgmtry": "Grid geometry, cf-ASCII records (not XDR; verified from the bytes by this library)",
    "b2fplasma": "The full plasma solution: all final profiles/sources/transport arrays; plain Fortran unformatted records, read natively by this library",
    "b2fplasmf": "The full plasma solution, formatted (ASCII) twin of b2fplasma; same records, read natively",
    "b2time.nc": "Solver convergence time traces, NetCDF-3",
    "b2batch.nc": "Batch-averaged quantities, NetCDF-3",
    "b2tallies.nc": "Region-integrated EIRENE tallies, NetCDF-3",
}

def _stats_cells(arr: np.ndarray) -> str:
    """min/max/mean table cells; non-finite values are counted in a
    trailing note, never printed as ``nan`` as if they were numbers."""
    finite = arr[np.isfinite(arr)]
    if finite.size == 0:
        return f"{'all non-finite':>34}"
    note = f"  [{arr.size - finite.size} non-finite]" if finite.size < arr.size else ""
    return (
        f"{_fmt(finite.min()):>12} {_fmt(finite.max()):>12} "
        f"{_fmt(finite.mean()):>12}{note}"
    )


def _fmt(x: float) -> str:
    return f"{x:.4e}"


@mcp.tool()
def scan_run_directory(path: str = "") -> str:
    """Inventory a SOLPS-ITER run directory: which output files exist, their
    sizes, what each file is, and the run identity (grid, species, code
    version) parsed from fort.44/fort.46 headers.

    Call this FIRST (before ls/find/head/cat) for any question shaped like
    'what's in this run directory', 'list the outputs', 'which fort.*/b2*
    files exist', or 'where does X live in this run'. One call returns the
    grouped, glossary-annotated listing; no shell spelunking required."""
    if not path:
        return _need_arg("path", "run directory", EXAMPLE_RUN)
    root = Path(path)
    if not root.is_dir():
        return f"ERROR: not a directory: {root}"
    lines = [f"Run directory: {root}", ""]

    # Identity from fort.44 if present (validated header: unknown
    # versions and malformed lines answer as unreadable, never as fact)
    ft44 = root / "fort.44"
    if ft44.is_file():
        try:
            h = read_ft44_header(ft44)
        except (Ft44FormatError, OSError) as exc:
            lines += [f"Identity (fort.44): unreadable ({exc})"]
        else:
            lines += [
                f"Identity (fort.44): grid {h.nx}x{h.ny} interior cells, "
                f"format version {h.version}, git {h.git_hash or 'n/a'}",
                f"  species: {', '.join(h.species)}",
            ]

    groups: dict[str, list] = {}
    for p in sorted(root.rglob("*")):
        if p.is_file():
            if p.name in FILE_GLOSSARY:
                key = p.name
            elif p.name.startswith("b2.") and ".parameters" in p.name:
                key = "b2.*.parameters"
            elif p.name.startswith(("fort.", "b2")):
                key = p.name.split(".")[0] + ".*"
            else:
                key = "other"
            groups.setdefault(key, []).append(p)

    lines.append("")
    for key in sorted(groups):
        lines.append(f"[{key}] " + FILE_GLOSSARY.get(key, ""))
        for p in groups[key][:20]:
            rel = p.relative_to(root)
            size = p.stat().st_size
            lines.append(f"  {rel}  ({size:,} bytes)")
        if len(groups[key]) > 20:
            lines.append(f"  ... and {len(groups[key]) - 20} more")
    return "\n".join(lines)


@mcp.tool()
def fort44_summary(path: str = "") -> str:
    """Summarize a fort.44 file: header, species, grid geometry, and the full
    field inventory with per-field statistics (count, min, max, mean). The
    file is self-labeled: for 'what's in this fort.44' or 'which fields
    does it carry', ask this rather than head/grep/awk-ing the raw text.
    Powered by the SOLPS-Reader fort.44 parser: names are verbatim from
    the file, zero-size blocks (absent species classes) answer as empty,
    and every format problem answers a named error."""
    if not path:
        return _need_arg("path", "fort.44 path", EXAMPLE_RUN + "/run_restart/fort.44")
    p = Path(path)
    if not p.is_file():
        return f"ERROR: no such file: {p}"
    try:
        ft = read_ft44(p)
    except Ft44FormatError as exc:
        return f"ERROR: not a readable fort.44: {exc}"

    h = ft.header
    out = [
        f"fort.44: grid {h.nx}x{h.ny} interior ({h.nx * h.ny} cells), "
        f"version {h.version}, git {h.git_hash or 'n/a'}",
        f"counts: natm={h.natm} nmol={h.nmol} nion={h.nion}"
        + (f" nfla={h.nfla}" if h.nfla is not None else "")
        + f"  species: {', '.join(h.species)}",
        f"{len(ft.fields)} field blocks in file order; grid fields have size "
        f"{h.nx * h.ny}, others are wall/stratum tallies",
        "",
        f"{'field':<12} {'size':>7} {'min':>12} {'max':>12} {'mean':>12}",
    ]
    for fld in ft.fields:
        arr = np.asarray(fld.data, dtype=float)
        if arr.size == 0:
            out.append(f"{fld.key:<12} {fld.size:>7}  (empty block)")
            continue
        out.append(f"{fld.key:<12} {fld.size:>7} " + _stats_cells(arr))
    out += [
        "",
        "Use fort44_field for a single field's details (repeats: NAME_2, NAME_3, ...).",
        "Names are verbatim: wall strata carry Fortran-padded indices like "
        "'wldnek(  1)'; fort44_field also accepts the unpadded form.",
    ]
    return "\n".join(out)


@mcp.tool()
def fort44_field(
    field: str,
    path: str = "",
) -> str:
    """Detailed look at ONE field of a fort.44 file: shape, full statistics,
    first values. Repeated fields are addressed as NAME_2, NAME_3, ... in
    file order (see fort44_summary). Species sub-labels recorded inside a
    block (wlabsrp/wlpump) are shown. The lookup is whitespace-insensitive,
    so the unpadded form of a Fortran-padded wall name ('wldnek(1)' for
    'wldnek(  1)') answers too."""
    if not path:
        return _need_arg("path", "fort.44 path", EXAMPLE_RUN + "/run_restart/fort.44")
    p = Path(path)
    if not p.is_file():
        return f"ERROR: no such file: {p}"
    try:
        ft = read_ft44(p)
    except Ft44FormatError as exc:
        return f"ERROR: not a readable fort.44: {exc}"

    keys = ft.keys()
    resolved_from = ""
    if field not in keys:
        # Whitespace-insensitive exact match: a caller typing the unpadded
        # form of a Fortran-padded wall name gets the field, not an error —
        # but only when exactly one key matches (repeats stay explicit).
        exact = [k for k in keys if k.replace(" ", "") == field.replace(" ", "")]
        if len(exact) == 1:
            resolved_from = field
            field = exact[0]
        elif len(exact) > 1:
            return (f"ERROR: field '{field}' is ambiguous across padded "
                    f"forms: {', '.join(exact)}; use the verbatim key")
        else:
            cands = _field_candidates(ft, field)
            hint = f" Did you mean: {', '.join(cands)}?" if cands else \
                " See fort44_summary for the field list."
            return f"ERROR: field '{field}' not found.{hint}"

    fld = ft.field(field)
    arr = np.asarray(fld.data, dtype=float)
    if arr.size == 0:
        return f"field {field}: empty (zero-size) block; species class absent"
    flat = arr.ravel()
    finite = flat[np.isfinite(flat)]
    lines = []
    if resolved_from:
        lines.append(f"note: queried '{resolved_from}'; matched verbatim "
                     f"key '{field}' (whitespace-insensitive)")
    lines.append(f"field {field}: shape {arr.shape} (declared size {fld.size})")
    if fld.labels:
        lines.append(f"sub-labels: {', '.join(fld.labels)}")
    if finite.size == 0:
        lines.append(f"all {flat.size} values non-finite")
        return "\n".join(lines)
    note = f"  [{flat.size - finite.size} non-finite]" if finite.size < flat.size else ""
    lines += [
        f"min={_fmt(finite.min())}  max={_fmt(finite.max())}  "
        f"mean={_fmt(finite.mean())}{note}",
        f"first values: {['%.4e' % v for v in flat[:5]]}",
        f"nonzero: {int(np.count_nonzero(finite))}/{flat.size}",
    ]
    return "\n".join(lines)


@mcp.tool()
def fort46_summary(
    path: str = "",
) -> str:
    """Summarize a fort.46 file (EIRENE data on the triangular wall/target
    mesh): header, species, and every field block with statistics: the
    first stop for wall/target loading questions. Powered by the SOLPS-Reader
    reader, which scans to EOF: 20 blocks where the MATLAB reference stops
    at 15 (volumes/pux/puy/pvx/pvy trail unread there)."""
    if not path:
        return _need_arg("path", "fort.46 path", EXAMPLE_RUN + "/run_restart/fort.46")
    p = Path(path)
    if not p.is_file():
        return f"ERROR: no such file: {p}"
    try:
        ft = read_ft46(p)
    except Ft46FormatError as exc:
        return f"ERROR: not a readable fort.46: {exc}"
    h = ft.header
    out = [
        f"fort.46: triangular mesh ntri={h.ntri}, version {h.version}, "
        f"git {h.git_hash or 'n/a'}",
        f"counts: natm={h.natm} nmol={h.nmol} nion={h.nion}  "
        f"species: {', '.join(h.species)}",
        f"{len(ft.fields)} field blocks (all blocks in file order, to EOF)",
        "",
        f"{'field':<12} {'size':>7} {'min':>12} {'max':>12} {'mean':>12}",
    ]
    for fld in ft.fields:
        arr = np.asarray(fld.data, dtype=float)
        if arr.size == 0:
            out.append(f"{fld.key:<12} {fld.size:>7}  (empty block)")
            continue
        out.append(f"{fld.key:<12} {fld.size:>7} " + _stats_cells(arr))
    out += ["", "Units are raw EIRENE (MATLAB's SI conversion factors NOT applied).",
            "Use fort46_field for a single field's details (repeats: NAME_2, ...)."]
    return "\n".join(out)


@mcp.tool()
def fort46_field(
    field: str,
    path: str = "",
) -> str:
    """Detailed look at ONE field of a fort.46 file: statistics, shape, first
    values. Repeated fields are addressed as NAME_2, NAME_3, ... (see
    fort46_summary). Species-class fields are shaped (ntri, n-species)."""
    if not path:
        return _need_arg("path", "fort.46 path", EXAMPLE_RUN + "/run_restart/fort.46")
    p = Path(path)
    if not p.is_file():
        return f"ERROR: no such file: {p}"
    try:
        ft = read_ft46(p)
    except Ft46FormatError as exc:
        return f"ERROR: not a readable fort.46: {exc}"
    keys = ft.keys()
    if field not in keys:
        cands = [k for k in keys if field.lower() in k.lower()]
        hint = f" Did you mean: {', '.join(cands)}?" if cands else \
            " See fort46_summary for the field list."
        return f"ERROR: field '{field}' not found.{hint}"
    arr = np.asarray(ft[field].data, dtype=float)
    if arr.size == 0:
        return f"field {field}: empty (zero-size) block"
    flat = arr.ravel()
    finite = flat[np.isfinite(flat)]
    if finite.size == 0:
        return f"field {field}: shape {arr.shape}: all {flat.size} values non-finite"
    note = f"  [{flat.size - finite.size} non-finite]" if finite.size < flat.size else ""
    return "\n".join([
        f"field {field}: shape {arr.shape} (size {flat.size})",
        f"min={_fmt(finite.min())}  max={_fmt(finite.max())}  "
        f"mean={_fmt(finite.mean())}{note}",
        f"first values: {['%.4e' % v for v in flat[:5]]}",
        f"nonzero: {int(np.count_nonzero(finite))}/{flat.size}",
    ])


@mcp.tool()
def run_convergence(
    path: str = "",
    tail_fraction: float = 0.1,
) -> str:
    """Read a run's solver convergence monitors (b2time.nc time traces) and
    classify each 1-D trace: plateaued / near-plateau / still evolving /
    constant. Answers 'is this run converged?' without plotting or ncdump;
    prefer this over parsing b2time.nc by hand. The read-only ancestor of a
    run-health watcher. Powered by SOLPS-Reader."""
    if not path:
        return _need_arg("path", "b2time.nc path", EXAMPLE_RUN + "/run_restart/b2time.nc")
    p = Path(path)
    if not p.is_file():
        return f"ERROR: no such file: {p}"
    try:
        ncf = load_nc(p)
    except NcFormatError as exc:
        return f"ERROR: not a readable NetCDF file: {exc}"
    n = ncf.num_records
    if n == 0:
        return (f"{p.name}: 0 records recorded; no monitor data to "
                "classify (the solver wrote no steps; crashed at startup?)")
    # Same candidates the CLI convergence face draws: numeric 1-D record
    # variables with data (text kinds and zero-size records are not traces).
    traces = [
        t for t in ncf.time_traces()
        if ncf.variable(t).data.dtype.kind in _NUMERIC_KINDS
        and ncf.variable(t).data.size > 0
    ]
    if not traces:
        return (f"ERROR: no numeric 1-D record variables found in {p.name} "
                "(no convergence traces).")
    out = [
        f"{p.name}: {ncf.record_dimension} dimension, {n} records, "
        f"{len(traces)} one-D monitor traces",
        "",
        f"{'trace':<10} {'units':<20} {'first':>12} {'last':>12} "
        f"{'tail change':>12}  verdict",
    ]
    verdicts = []
    for name in traces:
        arr = np.asarray(ncf[name], dtype=float).ravel()
        var = ncf.variable(name)
        units = (var.units or "")[:20]
        # Shared classifier (the CLI diff face uses the same function and
        # thresholds — the two faces cannot disagree on the same file);
        # the display wording below is this tool's richer rendering.
        base = _classify_trace(arr, tail_fraction)
        if base == "constant":
            verdict = "constant zero (not computed in this run)" \
                if abs(float(arr[0])) == 0.0 else "constant"
            rel = 0.0
        elif base == "non-finite":
            verdict = "non-finite values (no verdict)"
            rel = 0.0
        else:
            rel = _trace_drift(arr, tail_fraction)
            verdict = {
                "near-plateau": "near-plateau (slow drift)",
                "evolving": "still evolving",
            }.get(base, base)
        if name == "timesa" and len(arr) > 1 and bool(np.all(np.diff(arr) > 0)):
            verdict += "; strictly increasing time base (expected)"
        verdicts.append(verdict)
        rel_cell = "-" if base == "non-finite" else _fmt(rel)
        out.append(
            f"{name:<10} {units:<20} {_fmt(arr[0]):>12} {_fmt(arr[-1]):>12} "
            f"{rel_cell:>12}  {verdict}"
        )
    active = [v for v in verdicts if "constant" not in v and "time base" not in v]
    plateaued = sum(1 for v in active if v.startswith(("plateaued", "near-plateau")))
    out += [
        "",
        f"Summary: {plateaued}/{len(active)} active monitors plateaued "
        f"(tail fraction {tail_fraction:g}, thresholds 1e-3 / 1e-2 relative).",
        "Verdict heuristic, not physics: check the plot before trusting a run.",
    ]
    return "\n".join(out)


@mcp.tool()
def state_summary(
    path: str = "",
    check_grid_path: str = "",
) -> str:
    """Summarize a B2.5 plasma state file (b2fstate): version/provenance,
    species, snapshot time, all 48 state/flux records with statistics, plus
    internal consistency checks (quasineutrality ne = Σ z·na, drift status)
    and a grid cross-check against b2fgmtry. First stop for 'what are the
    densities/temperatures/flows in this run'. Powered by SOLPS-Reader."""
    if not path:
        return _need_arg("path", "b2fstate path", EXAMPLE_RUN + "/run_restart/b2fstate")
    p = Path(path)
    if not p.is_file():
        return f"ERROR: no such file: {p}"
    try:
        st = read_b2fstate(p)
    except (OSError, ValueError) as exc:
        return f"ERROR: not a readable b2fstate: {exc}"
    out = [format_state_summary(st, str(p)), ""]

    # -- internal consistency: quasineutrality with charge = zamin per species
    if "ne" in st and "na" in st and st.species:
        na = st.fields["na"]  # (gx, gy, ns)
        ne = st.fields["ne"]
        z = np.array([sp.zamin for sp in st.species])
        residual = float(np.abs(ne - (na * z[None, None, :]).sum(axis=2)).max())
        rel = residual / max(float(np.abs(ne).max()), 1.0)
        out.append(f"quasineutrality ne = Σ z·na: max residual {residual:.3e} "
                   f"(rel {rel:.1e}): {'PASS' if rel < 1e-10 else 'CHECK'}")

    # -- drift status: the dia-drift velocity record is identically zero when
    #    drifts are off (observed on ITER_2275; a data fact, not a parse one)
    if "uadia" in st:
        dia = np.asarray(st.fields["uadia"], dtype=float)
        state = "identically zero (drifts disabled in this run)" \
            if not dia.any() else f"nonzero (range {_fmt(dia.min())}..{_fmt(dia.max())})"
        out.append(f"drifts (uadia): {state}")

    # -- physics ranges, interior cells only (guard ring excluded), te/ti J→eV
    nx, ny = st.nx, st.ny
    ev = 1.0 / 1.602176634e-19
    ranges = []
    for label, key, scale in (("na (per-species max)", "na", 1.0),
                              ("ne m^-3", "ne", 1.0),
                              ("te eV", "te", ev), ("ti eV", "ti", ev),
                              ("po V", "po", 1.0), ("ua m/s", "ua", 1.0)):
        if key not in st.fields:
            continue
        arr = np.asarray(st.fields[key], dtype=float)
        if arr.ndim >= 2:
            arr = arr[2:nx + 2, 2:ny + 2]
        ranges.append(f"{label}: {_fmt(arr.min() * scale)}..{_fmt(arr.max() * scale)}")
    out += ["interior-cell ranges: " + "; ".join(ranges)]

    # -- optional grid cross-check (three sub-checks)
    cgp = Path(check_grid_path)
    if str(cgp) and cgp.is_file():
        try:
            gm = read_b2fgmtry(cgp)
        except (OSError, ValueError) as exc:
            out.append(f"grid cross-check: SKIPPED (unreadable b2fgmtry: {exc})")
        else:
            lines, ok = check_grid(st, gm, str(cgp))
            out += ["grid cross-check vs b2fgmtry:"] + lines
    else:
        out.append("grid cross-check: SKIPPED (no b2fgmtry at "
                   f"{cgp}; pass check_grid_path to enable)")
    return "\n".join(out)


@mcp.tool()
def plasma_summary(path: str = "", b2fstate: str = "") -> str:
    """Summarize a full plasma solution file (b2fplasma binary, or its ASCII
    twin b2fplasmf; encoding detected from the bytes): version, grid +
    species, the seven block inventories (geometry/plasma/residuals/sources/
    transport/anomalous/neutral scaling), core-field statistics, and a
    quasineutrality check when species charges are known. The ~190-array
    final state a run writes at output time. Powered by SOLPS-Reader."""
    if not path:
        return _need_arg("path", "b2fplasma path",
                         EXAMPLE_RUN + "/run_restart/b2fplasma")
    p = Path(path)
    if not p.is_file():
        return f"ERROR: no such file: {p}"
    try:
        pl = read_b2fplasma(p, b2fstate=b2fstate or None)
    except (OSError, ValueError) as exc:
        return f"ERROR: not a readable b2fplasma/b2fplasmf: {exc}"
    try:
        out = [format_plasma_summary(pl, str(p)), ""]
        # interior-cell physics ranges, the state_summary vocabulary
        nx, ny = pl.nx, pl.ny
        ev = 1.0 / 1.602176634e-19
        ranges = []
        for label, key, scale in (("ne m^-3", "ne", 1.0),
                                  ("te eV", "te", ev), ("ti eV", "ti", ev),
                                  ("po V", "po", 1.0)):
            if key not in pl:
                continue
            arr = pl[key]
            arr = arr[2:nx + 2, 2:ny + 2]
            ranges.append(f"{label}: {_fmt(arr.min() * scale)}.."
                          f"{_fmt(arr.max() * scale)}")
        if ranges:
            out += ["interior-cell ranges: " + "; ".join(ranges)]
        out.append("drill into any record with plasma_field(path, field)")
        return "\n".join(out)
    finally:
        pl.close()


@mcp.tool()
def plasma_field(path: str = "", field: str = "") -> str:
    """One record of a b2fplasma/b2fplasmf file: shape, min/max/mean, first
    values (column-major); e.g. te, na, ua, csigin, or any name the
    plasma_summary inventory lists. The full record set is exportable from
    the CLI (solps-reader plasma export). Powered by SOLPS-Reader."""
    if not path:
        return _need_arg("path", "b2fplasma path",
                         EXAMPLE_RUN + "/run_restart/b2fplasma")
    if not field:
        return _need_arg("field", "record name", "te")
    p = Path(path)
    if not p.is_file():
        return f"ERROR: no such file: {p}"
    try:
        pl = read_b2fplasma(p)
    except (OSError, ValueError) as exc:
        return f"ERROR: not a readable b2fplasma/b2fplasmf: {exc}"
    try:
        try:
            arr = pl[field]
        except KeyError:
            return (f"ERROR: no record {field!r} in {p.name}; available: "
                    f"{pl.keys()}")
        shape = "x".join(str(d) for d in arr.shape) or "scalar"
        flat = arr.ravel(order="F")
        head = ", ".join(f"{v:.6e}" for v in flat[:12])
        return "\n".join([
            f"{field}: shape ({shape})",
            f"  min / max / mean: {_stats_cells(arr) if arr.size else '-'}",
            f"  first values (column-major): {head}"
            + (" ..." if flat.size > 12 else ""),
        ])
    finally:
        pl.close()


# doc/LOG date headers are bare tokens on their own line: "2007.01.07",
# "2002.04.10+11", placeholder "2007.01.dd". Wrapped prose may START with a
# date, so anchor to the full line.
_LOG_DATE = re.compile(r"^(\d{4}\.\d{2}\.[\da-z+]+)\s*$")


def _log_entries(log_path: Path) -> tuple[list[str], list[str]]:
    """Read doc/LOG once; return (lines, governing_date_per_line). The file is
    hand-maintained newest-first; each entry belongs to the nearest date
    header above it."""
    log = log_path
    if not log.is_file():
        return [], []
    lines = log.read_text(errors="replace").splitlines()
    dates: list[str] = []
    current = "?"
    for line in lines:
        m = _LOG_DATE.match(line)
        if m:
            current = m.group(1)
        dates.append(current)
    return lines, dates


def _log_hits(lines: list[str], dates: list[str], needle: str) -> list[tuple]:
    """(line_number, entry_date, line) for every substring match."""
    low = needle.lower()
    return [
        (i, d, line.rstrip())
        for i, (line, d) in enumerate(zip(lines, dates), 1)
        if low in line.lower()
    ]


@mcp.tool()
def search_changelog(query: str, log_path: str = "") -> str:
    """Search SOLPS-ITER's hand-maintained changelog (doc/LOG, text; entries
    dated YYYY.MM.dd, file ordered newest-first, coverage back to 2002.04)
    plus release-note document titles in doc/. Every LOG hit is annotated
    with its entry date, and the oldest matches are always included, so
    'when was X introduced' is answered directly. Multi-word queries with no
    hits fall back to the most selective single token."""
    if not log_path:
        return _need_arg("log_path", "doc/LOG path", "/path/to/SOLPS-ITER/doc/LOG")
    lines, dates = _log_entries(Path(log_path))
    hits = _log_hits(lines, dates, query)
    note = ""
    if not hits and lines:
        # Phrase missed — retry per token, most selective (fewest hits) wins.
        per_token = {
            tok: _log_hits(lines, dates, tok)
            for tok in query.split()
        }
        cand = [(len(h), -len(t), t) for t, h in per_token.items() if h]
        if not cand and query.rstrip("s") != query:
            per_token = {query.rstrip("s"): _log_hits(lines, dates, query.rstrip("s"))}
            cand = [(len(h), -len(t), t) for t, h in per_token.items() if h]
        if cand:
            _, _, tok = min(cand)
            hits = per_token[tok]
            note = f"; no match for full phrase, fell back to '{tok}'"
    doc_hits = [
        f"doc: {p.name}"
        for p in log_path.parent.glob("*")
        if query.lower() in p.name.lower()
    ]
    if not hits and not doc_hits:
        return f"No matches for '{query}' in doc/LOG or doc/ titles."
    span = ""
    if hits:
        span = (f", {len(hits)} LOG lines, newest {hits[0][1]} "
                f"/ oldest {hits[-1][1]}")
    out = [f"Changelog matches for '{query}'{note}{span} "
           "(file order is newest-first):", ""]
    out += [f"LOG:{i} [{d}]: {line}" for i, d, line in hits[:30]]
    if len(hits) > 30:
        out += ["", "earliest matches (oldest entries):"]
        out += [f"LOG:{i} [{d}]: {line}" for i, d, line in hits[-10:]]
        if len(hits) > 40:
            out.append(f"... {len(hits) - 40} lines between the blocks above")
    out += doc_hits[:15]
    return "\n".join(out)


# ----------------------------------------------------------------------
# Catalog tools (2026-09-23) — the publication-tier JSON layer shared with
# the static site (catalog/build_catalog.py). One engine, two faces: these
# tools serve the same manifests the browser catalog renders, so an AI
# answer and a web page can never disagree.
# ----------------------------------------------------------------------


def _load_catalog_index(catalog_dir: Path) -> list[dict]:
    index_path = catalog_dir / "out" / "index.json"
    if not index_path.is_file():
        raise FileNotFoundError(
            f"no catalog index at {index_path}; run catalog/build_manifests.py first"
        )
    return json.loads(index_path.read_text())["runs"]


@mcp.tool()
def catalog_summary(catalog_dir: str = "") -> str:
    """Summarize the run catalog: which runs exist, machine, convergence
    verdict, grid, species, the code git hash each run stamps, and whether
    wall-load data is present.

    Call this FIRST for "what runs do we have", "which runs converged",
    "list the runs"; it carries precomputed verdicts and provenance, so it
    is cheaper than scanning run directories. Generated by
    catalog/build_manifests.py from the run files; regenerate if stale.
    """
    if not catalog_dir:
        return _need_arg("catalog_dir", "catalog root", "/path/to/catalog")
    try:
        runs = _load_catalog_index(Path(catalog_dir))
    except (OSError, json.JSONDecodeError, KeyError) as exc:
        return f"catalog unavailable: {exc}"

    try:
        out = [
            f"catalog: {len(runs)} runs ({catalog_dir})",
            "",
            f"{'verdict':>12}  {'machine':<7} {'grid':>7}  run",
            "-" * 88,
        ]
        for r in runs:
            grid = r.get("grid") or {}
            g = f"{grid.get('nx', '?')}x{grid.get('ny', '?')}" if grid else "?"
            out.append(
                f"{(r.get('verdict') or '-'):>12}  {r['machine']:<7} {g:>7}  {r['name']}"
            )
        out += [
            "",
            "per-run detail (provenance, per-monitor verdicts, wall loads, "
            "file MD5s): run_manifest('<name or unique substring>')",
        ]
    except (KeyError, TypeError) as exc:
        return (f"catalog unavailable: index entry is malformed ({exc!r}); "
                "rebuild the catalog (its manifests builder)")
    return "\n".join(out)


@mcp.tool()
def run_manifest(run: str, catalog_dir: str = "") -> str:
    """Return the full manifest of one cataloged run: identity, code
    provenance (fort.44/46 versions AND the git hashes the files stamp),
    grid, species, convergence verdict with the active-monitor table,
    wall-load summary, and the key-file inventory with MD5s.

    Call for "what code version produced run X", "is run X converged and
    on which monitors", "which files and hashes back run X", "where do
    run X's wall loads sit". `run` is the catalog name, or any unique
    substring of it (e.g. 'run_with_drifts', 'variant042', '2275').
    """
    if not catalog_dir:
        return _need_arg("catalog_dir", "catalog root", "/path/to/catalog")
    try:
        runs = _load_catalog_index(Path(catalog_dir))
    except (OSError, json.JSONDecodeError, KeyError) as exc:
        return f"catalog unavailable: {exc}"

    try:
        matches = [r for r in runs if run == r["name"]] or [
            r for r in runs if run in r["name"]
        ]
        if not matches:
            return (
                f"no catalog run matches {run!r}. Known runs:\n  "
                + "\n  ".join(r["name"] for r in runs)
            )
        if len(matches) > 1:
            return (
                f"{run!r} is ambiguous; matches:\n  "
                + "\n  ".join(r["name"] for r in matches)
            )
        manifest_path = Path(catalog_dir) / "out" / matches[0]["manifest"]
        return manifest_path.read_text()
    except (KeyError, TypeError) as exc:
        return (f"catalog unavailable: index entry is malformed ({exc!r}); "
                "rebuild the catalog (its manifests builder)")
    except OSError as exc:
        return (f"catalog unavailable: the manifest file the index names is "
                f"unreadable ({exc}); rebuild the catalog (its manifests builder)")


# ----------------------------------------------------------------------
# SwitchJoin tools (2026-09-28) — the ruled documentation<->run join.
# Doctrine: the catalog artifact out/switchsets.json (schema
# catalog-switchsets/1, built by catalog/build_switchsets.py per catalog
# catalog/build_switchsets.py) is the SINGLE source of truth — these tools never re-parse
# b2mn.dat decks and never re-read the askthedocs inventory; they only join
# what the artifact already carries. Read-only like everything else here.
# ----------------------------------------------------------------------

SWITCHSETS_SCHEMA = "catalog-switchsets/1"


def _load_switchsets(catalog_dir: Path) -> dict:
    """Load the SwitchJoin artifact or raise an honest, named error.
    Absence names the catalog build step — a silent empty would fake
    'no switches set', which is never true."""
    path = catalog_dir / "out" / "switchsets.json"
    if not path.is_file():
        raise FileNotFoundError(
            f"no switchsets artifact at {path}; built by the catalog "
            "SwitchJoin step (the catalog's switchsets builder, catalog/build_switchsets.py); "
            "run it in the catalog repo and retry"
        )
    data = json.loads(path.read_text())
    schema = data.get("schema")
    if schema != SWITCHSETS_SCHEMA:
        raise ValueError(
            f"unsupported switchsets schema {schema!r} at {path} "
            f"(expected {SWITCHSETS_SCHEMA!r}) — rebuild the artifact "
            "(the catalog's switchsets builder)"
        )
    return data


@mcp.tool()
def run_switches(run: str, catalog_dir: str = "") -> str:
    """A run's effective switch table (the b2mn.dat the solver actually
    read), joined to the documentation inventory: per switch, its value,
    whether it came from the run dir or the family deck (source_file),
    how it compares to the documented default (vs_default: same /
    differs / no_default_in_inventory / unknown_to_inventory), and
    whether it is documented at all. Sorted by switch name; switches
    absent from the inventory are listed with their flag, never dropped.

    Call for "what switches does run X set", "run X's effective b2mn.dat",
    "is switch S at its default in run X". Served from the catalog
    SwitchJoin artifact (catalog-switchsets/1); the header carries the
    effective-deck and inventory MD5 pins, so an answer is self-citing.
    A switch line whose quoted name starts with '#' is commented out:
    excluded from the table and every count, named with its value in
    one line (kept in the deck file, not used by the run).
    `run` is the catalog name or any unique substring of it
    ('run_with_drifts', '2275'), per the run_manifest rule. Chain to the
    docs with the askthedocs MCP face's search_docs('<switch>',
    cluster='source_switch'); the citation section IS the switch name."""
    if not catalog_dir:
        return _need_arg("catalog_dir", "catalog root", "/path/to/catalog")
    try:
        data = _load_switchsets(Path(catalog_dir))
    except (OSError, json.JSONDecodeError, ValueError) as exc:
        return f"ERROR: {exc}"

    names = sorted(data["runs"])
    matches = [n for n in names if run == n] or [n for n in names if run in n]
    if not matches:
        # a cataloged run without a deck answers by name, never as a
        # non-match (it HAS a page; the switch set is the absent part)
        absent = data.get("absent") or {}
        hits = ([n for n in sorted(absent) if run == n]
                or [n for n in sorted(absent) if run in n])
        if hits:
            if len(hits) > 1:
                return (f"{run!r} is ambiguous across deck-less runs; "
                        "matches:\n  " + "\n  ".join(hits))
            return (f"{hits[0]} is cataloged but carries no switch set: "
                    f"{absent[hits[0]]}. The run catalogs in full without "
                    "one; its page states the absence.")
        return (f"no cataloged run matches {run!r}. Runs in the switchsets "
                "artifact:\n  " + "\n  ".join(names))
    if len(matches) > 1:
        return (f"{run!r} is ambiguous across switchsets runs; matches:\n  "
                + "\n  ".join(matches))

    name = matches[0]
    entry = data["runs"][name]
    eff = data["provenance"]["effective_b2mn"][name]
    inv = data["provenance"]["inventory"]
    # documented per switch, derived from the artifact alone: switches
    # absent from the inventory, then those present but documented:false
    # (the artifact's documented_false ledger), are the only undocumented
    # ones — everything else the inventory documents.
    undocumented = set(entry["documented_false"]["switches"])

    counts = Counter(e["vs_default"] for e in entry["switches"].values())
    commented = entry.get("commented_out") or {}
    out = [
        f"run {name}: {entry['switch_count']} switches set in the effective deck",
        f"artifact: {SWITCHSETS_SCHEMA} ({catalog_dir}/out/switchsets.json)",
        f"effective b2mn.dat: {eff['path']} [{eff['source_file']}] "
        f"{eff['bytes']} B, md5 {eff['md5']}",
        f"askthedocs switch inventory pin: {inv['path']} md5 {inv['md5']} "
        f"({inv['counts']['switches']} switches, "
        f"{inv['counts']['documented']} documented)",
        "vs_default counts: "
        + " / ".join(f"{counts.get(v, 0)} {v}" for v in data["vs_default_values"]),
    ]
    if commented.get("count"):
        co_names = ", ".join(
            f"{n} = {v}" for n, v in sorted(
                commented.get("switches", {}).items()))
        out.append(f"commented out in this deck: {commented['count']} "
                   "(kept in the deck file, not used by the run): "
                   f"{co_names}")
    out += [
        "",
        f"{'switch':<34} {'value':<12} {'from':<5} {'vs_default':<23} documented",
    ]
    for key in sorted(entry["switches"]):
        e = entry["switches"][key]
        if e["vs_default"] == "unknown_to_inventory":
            documented = "absent"
        elif key in undocumented:
            documented = "no"
        else:
            documented = "yes"
        out.append(
            f"{key:<34} {e['value']:<12} {e['source_file']:<5} "
            f"{e['vs_default']:<23} {documented}"
        )
    out += [
        "",
        "documented: yes/no = askthedocs inventory entry (no = known read, "
        "undocumented); absent = not in the inventory at all.",
        "unknown_to_inventory switches are never dropped: the deck sets "
        "them, no citation can name them.",
        "Per-switch docs: the askthedocs MCP face (search_docs "
        "'<switch>' cluster source_switch).",
    ]
    return "\n".join(out)


@mcp.tool()
def switch_runs(switch: str, catalog_dir: str = "") -> str:
    """The citation->runs direction of the ruled documentation<->run join:
    which cataloged runs set a switch, and to what. Per run: name,
    family, value, and vs_default (same / differs / no_default_in_inventory
    / unknown_to_inventory), plus the docs pointer so a citation chains
    straight into the askthedocs MCP face (search_docs/get_chunk).

    `switch` is the EXACT switch name (the askthedocs source_switch citation
    section IS the name, zero fuzzy matching) or a comma-list for AND
    semantics ('b2news_facdrift_start,b2tfnb_drift_style' = runs setting
    BOTH). A switch no cataloged run sets is reported as such, with the
    inventory size for orientation, never approximated; a name that only
    ever appears commented out (quoted name starting with '#') is
    reported as commented out, with the runs that comment it out.

    Call for "which runs set switch S", "runs using facdrift/drifts",
    "turn this citation into run evidence"."""
    if not catalog_dir:
        return _need_arg("catalog_dir", "catalog root", "/path/to/catalog")
    try:
        data = _load_switchsets(Path(catalog_dir))
    except (OSError, json.JSONDecodeError, ValueError) as exc:
        return f"ERROR: {exc}"

    names = [s.strip() for s in switch.split(",") if s.strip()]
    if not names:
        return ("ERROR: no switch name given; pass the exact switch name "
                "(the askthedocs source_switch citation section IS the name) "
                "or a comma-list for AND semantics")

    idx = data["inverted_index"]
    table = data["runs"]
    inv = data["provenance"]["inventory"]
    n_runs = len(table)
    # Rows come from the per-run deck records (the artifact's runs
    # tables) — the same section run_switches reads, so the two join
    # directions can never disagree. The artifact's own inverted_index
    # is only a cross-check: the shipped artifact drops its
    # unknown_to_inventory switches from the index (4 entries), and a
    # disagreement is surfaced below, never silently resolved.
    setting = {n: sorted(rn for rn, e in table.items() if n in e["switches"])
               for n in names}
    distinct = {sw for e in table.values() for sw in e["switches"]}
    orientation = (
        f"artifact: {SWITCHSETS_SCHEMA} ({catalog_dir}/out/switchsets.json), "
        f"{len(distinct)} distinct switch names set across {n_runs} "
        f"cataloged runs (artifact counts block: "
        f"{data['counts']['distinct_switches_set']}); askthedocs switch "
        f"inventory pins {inv['counts']['switches']} switches "
        f"({inv['counts']['documented']} documented) md5 {inv['md5']}"
    )

    unknown = [n for n in names if not setting[n]]
    if unknown:
        # a name no run sets but some runs COMMENT OUT (the quoted name
        # starts with '#'): named, never silently absent — the same
        # visibility rule the run pages carry
        commented_hits = {
            n: sorted(rn for rn, e in table.items()
                      if n in (e.get("commented_out") or {}).get(
                          "switches", {}))
            for n in unknown}
        lines = []
        if len(unknown) == len(names):
            lines.append("no cataloged run sets this switch: "
                         + ", ".join(unknown))
        else:
            # AND with a switch nobody sets: the intersection is empty,
            # but each requested switch's status is still spelled out —
            # no silent gaps.
            lines.append(f"no cataloged run sets ALL of {', '.join(names)} "
                         "(AND semantics):")
            for n in names:
                lines.append(f"  {n}: set by {len(setting[n])} of {n_runs} "
                             "runs")
        lines.append("exact-name lookup only (the askthedocs source_switch "
                     "citation section IS the switch name); no fuzzy "
                     "matching")
        if any(n != n.lower() for n in unknown):
            lines.append("note: switch names are lowercase in decks (the "
                         "solver lowercases them); retry the lowercase form")
        for n in unknown:
            hits = commented_hits.get(n) or []
            if hits:
                lines.append(
                    f"note: {n}: commented out in {len(hits)} "
                    "run(s) (kept in the deck file, not used by the "
                    "run): " + ", ".join(hits))
        lines.append(orientation)
        return "\n".join(lines)

    common = set.intersection(*(set(v) for v in setting.values()))
    title = names[0] if len(names) == 1 else " + ".join(names) + " (AND)"
    out = [
        f"switch {title}: {len(common)} of {n_runs} cataloged runs set "
        + ("it" if len(names) == 1 else "all of them"),
        orientation,
        "",
        f"{'run':<42} {'family':<22} {'switch':<24} {'value':<8} vs_default",
    ]
    for run in sorted(common):
        family = run.split("/", 1)[0]
        for n in names:
            e = table[run]["switches"][n]
            out.append(f"{run:<42} {family:<22} {n:<24} "
                       f"{e['value']:<8} {e['vs_default']}")
    for n in names:
        if n not in idx:
            out += ["",
                    f"note: {n} is set per the artifact's runs tables but "
                    "absent from its inverted_index: catalog artifact "
                    "inconsistency (the catalog's switchsets builder)"]
        elif {e["run"] for e in idx[n]} != set(setting[n]):
            out += ["",
                    f"note: {n}: inverted_index and runs tables disagree on "
                    "which runs set it: catalog artifact inconsistency "
                    "(the catalog's switchsets builder)"]
    out += [
        "",
        "docs pointer: the askthedocs MCP face; "
        "search_docs('<switch>', cluster='source_switch') "
        "); the citation section IS the switch name; get_chunk(<chunk_id>) "
        "fetches the passage.",
    ]
    return "\n".join(out)


def startup_gate() -> None:
    """The floor gate at server startup: no SOLPS-ITER checkout with
    initialized submodules, no server. The refusal (discovery stop or
    missing submodule list, each piece with its remedy) goes to
    stderr and the process exits before serving anything."""
    from solps_reader import floor
    try:
        report = floor.check_floor()
    except floor.FloorError as exc:
        raise SystemExit(str(exc)) from None
    if not report.ok:
        raise SystemExit(floor.format_refusal(report))


def main() -> None:
    """Console entry point (``solps-mcp``): the floor gate runs before
    the server starts serving."""
    startup_gate()
    mcp.run()


if __name__ == "__main__":
    main()
