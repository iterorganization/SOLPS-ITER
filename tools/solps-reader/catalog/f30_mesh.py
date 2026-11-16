"""fort.30 -> EIRENE standard mesh (XPOL/YPOL) + block-3a surface areas.

A faithful port of the two reference routines that turn B2's fort.30 mesh
exchange file into the exact mesh the coupled EIRENE used:

- EIRENE_GEOMD_LINDA (couple_specific.F:251-986, couple_SOLPS-ITER) —
  selected by MSHFRM=0 (default; EIRENE manual chap2b14.tex:778), which
  SOLPS-ITER runs use because block 14's IMF=0 (eirene_infcop.F:1383-1387;
  ITER_2171 baserun input.dat block 14 line 1345: "17 0 1 0 ...").
- SAREA loops in grid.f case (2:3): radial surfaces grid.f:1361-1369,
  poloidal surfaces grid.f:1393-1401 — per segment 2*pi*R_mid*L with
  R_mid=(X(a)+X(b))/2+RMTOR (RMTOR=0: block-2 input ZIA=0, ZAA=360,
  ROA=0 -> grid.f:962 RMTOR=ROA*ALPHA/TANAL=0), windows HALF-OPEN over
  node indices (DO IP=IRPTA..IRPTE-1).
- Torus factor TANAL/ALPHA is the polygon-torus correction tan(a)/a:
  TANAL=TAN(ALPHA), ALPHA=0.5*ZDF/NTTRAM with ZDF=(ZAA-ZIA)*DEGRAD=2*pi
  and NTTRAM=NTTRA-1 (grid.f:946-950; set_derived_input_parameters.f:43;
  ITER runs: block-2 NTTRA=60 -> a=pi/59, tan(a)/a=1.0009462). This
  factor was the last missing piece: without it every surface area is
  uniformly ~9.46e-4 low.

Unit chain: B2 writes fort.30 in metres (crx/cry, R~6.2); LINDA multiplies
XPOL/YPOL x100 to cm (couple_specific.F:973-979) and the coupling converts
wlarea = 1e-4 * SAREA back to m^2 (eirmod_wneutrals.F:886) — the two
factors cancel, so computing directly in metres is exact.

Mesh layout produced (ITER 90x36 single-null family, nncut=2 cuts):
- radial rows 1..NR1ST(37) == B2 node radial lines 0..36 — no guard rings
  (grid.f check: NR1ST = dimyh+1, couple_specific.F:933-941);
- poloidal columns 1..NP2ND(93) = 91 B2 node lines + 2 SPLIT faces at the
  cuts (couple_specific.F:410-431, 495-513, 792-854); NP2ND = NX+NPLP
  (couple_specific.F:942-953);
- per cell record (2 lines, corner write order w1,w2,w3,w4 ==
  crx(ix,iy,1),crx(ix,iy,3),crx(ix,iy,2),crx(ix,iy,0),
  eirene_f30f31.F:705-708): main column rows 1..36 <- w4, row 37 <- w3;
  split column (cut records only) rows 1..36 <- w1, row 37 <- w2.
"""

import math
import re

import numpy as np


def read_fort30(path):
    """Parse fort.30 exactly as GEOMD_LINDA reads it (couple_specific.F:299-855).

    Returns (xpol, ypol, npoint, dimxh, dimyh):
    xpol/ypol[ir, ip] with ir=0..NR1ST-1 (row ir+1 in Fortran),
    ip=0..NP2ND-1 (column ip+1); values in metres.
    npoint: list of (start, end) 1-based column ranges per poloidal patch.
    """
    with open(path) as fh:
        lines = fh.read().splitlines()

    pos = 1  # line 0 is the 'Geometry from B2' title (skipped, :302)
    # skip blank lines until the first non-blank one (:303-310)
    while not lines[pos].strip():
        pos += 1
    # 'dimxh dimyh nncut', list-directed (:312)
    dimxh, dimyh, nncut = (int(t) for t in lines[pos].split()[:3])
    pos += 1
    # nncut cards of 4 ints, list-directed across records (:315-316)
    vals = []
    while len(vals) < 4 * nncut:
        vals.extend(int(t) for t in lines[pos].split())
        pos += 1
    cuts = [(vals[4 * i], vals[4 * i + 1], vals[4 * i + 2], vals[4 * i + 3])
            for i in range(nncut)]
    nxcut1 = [c[0] for c in cuts]
    nxcut2 = [c[1] for c in cuts]
    # nncut<=2 -> nniso=0, no iso cards (:323-325); then one record consumed
    pos += 1  # the blank line before the data (:326)
    # data records: 2 lines per B2 cell, 4 floats each (:368-388 detection
    # only distinguishes E15.7/E16.8; plain split parses both)
    recs = []
    while pos < len(lines):
        xs = lines[pos].split()
        if len(xs) != 4:
            break
        xrow = [float(t) for t in xs]
        yrow = [float(t) for t in lines[pos + 1].split()]
        recs.append((xrow, yrow))
        pos += 2
    if len(recs) != dimxh * dimyh:
        raise ValueError(
            f"{path}: expected {dimxh*dimyh} cell records, got {len(recs)}")

    nplp = max((nncut // 2) * 3, 1)  # couple_specific.F:328
    nwiso = 0  # nniso=0 (:323-334)
    snowflake = nncut >= 2 and nxcut2[0] <= nxcut1[1]  # :436 / :771

    # Column placement per record IX (1-based record = B2 cell ix=IX-1).
    # (main_col, split_col); Fortran 1-based columns as placed by LINDA.
    def cols_for(ix):
        if nncut >= 1:
            if ix <= nxcut1[0] - 1:
                return (ix, None)                       # :394-409
            if ix == nxcut1[0]:
                return (ix, nxcut2[nncut - 1])          # :410-431
        if nncut >= 2:
            if snowflake:
                raise NotImplementedError("snowflake topology not ported")
            # DDN/SN case (:477-513)
            if nxcut2[nncut - 1] <= ix <= nxcut1[1] - 1:
                return (ix + 1, None)                   # :477-493
            if ix == nxcut1[1]:
                return (ix + 1, ix + 2)                 # :495-513
        if nncut >= 1:
            # last poloidal patch, DDN/SN (:791-809)
            if nxcut2[0] <= ix <= dimxh - 1:
                return (ix + nplp - 1 - nwiso, None)    # :792-808
        elif nncut == 0:
            if ix <= dimxh - 1:
                return (ix + nplp - 1 - nwiso, None)    # :811-829
        if ix == dimxh:
            return (dimxh + nplp - 1 - nwiso,           # :831-854
                    dimxh + nplp - nwiso)
        raise ValueError(f"record {ix} not placed by any LINDA branch")

    ncols = dimxh + nplp  # == NP2ND (:942-953)
    xpol = np.full((dimyh + 1, ncols), np.nan)
    ypol = np.full((dimyh + 1, ncols), np.nan)
    for ix in range(1, dimxh + 1):
        main, split = cols_for(ix)
        for iy in range(1, dimyh + 1):
            xrow, yrow = recs[(ix - 1) * dimyh + (iy - 1)]
            # w-order as written: [c1, c3, c2, c0] (eirene_f30f31.F:705-708)
            for col, w_lo, w_hi in ((main, 3, 2), (split, 0, 1)):
                if col is None:
                    continue
                r = iy - 1  # Fortran row iy -> python row iy-1
                if iy < dimyh:                # :397-400 plain / :413-418 cut
                    xpol[r, col - 1] = xrow[w_lo]
                    ypol[r, col - 1] = yrow[w_lo]
                else:                          # :402-406 / :420-428
                    xpol[r, col - 1] = xrow[w_lo]
                    ypol[r, col - 1] = yrow[w_lo]
                    xpol[dimyh, col - 1] = xrow[w_hi]
                    ypol[dimyh, col - 1] = yrow[w_hi]

    # Patch table (DDN case, couple_specific.F:880-918; NNCUT<=1 :860-861)
    if nncut <= 1:
        npoint = [(1, dimxh + 1)]
    elif snowflake:
        raise NotImplementedError("snowflake topology not ported")
    else:
        npoint = [
            (1, nxcut1[0] + 1),
            (nxcut2[nncut - 1] + 1, nxcut2[nncut - 2] + 1),
            (nxcut2[nncut - 2] + 2, dimxh + nplp),
        ][:nplp]
    if npoint[-1][1] != ncols:
        raise ValueError(f"patch table ends at {npoint[-1][1]}, NP2ND={ncols}")
    return xpol, ypol, npoint, dimxh, dimyh


def torus_factor(nttra=60):
    """TANAL/ALPHA = tan(a)/a, a = pi/NTTRAM, NTTRAM = NTTRA-1
    (grid.f:946-950 with ZDF=2*pi; set_derived_input_parameters.f:43).
    ITER block-2 NTTRA=60 -> 1.0009462."""
    alpha = 0.5 * (2.0 * math.pi) / (nttra - 1)
    return math.tan(alpha) / alpha


def surface_area(xpol, ypol, idimp, inump, a, b, factor=None):
    """SAREA of one block-3a surface (grid.f:1361-1369 radial, :1393-1401
    poloidal), computed in metres (RMTOR=0), polygon-torus factor applied.

    idimp=1: radial surface no. INUMP spanning poloidal columns a..b
             (1-based, half-open: segments a..b-1).
    idimp=2: poloidal surface no. INUMP spanning radial rows a..b.
    """
    if factor is None:
        factor = torus_factor()
    total = 0.0
    if idimp == 1:
        ir = inump - 1
        for ip in range(a - 1, b - 1):
            dx = xpol[ir, ip + 1] - xpol[ir, ip]
            dy = ypol[ir, ip + 1] - ypol[ir, ip]
            total += math.hypot(dx, dy) * 0.5 * (xpol[ir, ip + 1] + xpol[ir, ip])
    else:
        ip = inump - 1
        for ir in range(a - 1, b - 1):
            dx = xpol[ir + 1, ip] - xpol[ir, ip]
            dy = ypol[ir + 1, ip] - ypol[ir, ip]
            total += math.hypot(dx, dy) * 0.5 * (xpol[ir + 1, ip] + xpol[ir, ip])
    return total * 2.0 * math.pi * factor


# ITER block-3a family windows (input.dat cards; windows verified to align
# with the LINDA patch boundaries — FORMATS.md "Stratum-segment geometry").
# (name, idimp, inump, a, b) in 1-based mesh indices; order == card order.
ITER_SURFACES = [
    ("Core side 1", 1, 1, 22, 72),
    ("Target 1",    2, 1, 1, 37),
    ("Target 2",    2, 93, 1, 37),
    ("PFR side 1",  1, 1, 1, 21),
    ("PFR side 2",  1, 1, 73, 93),
    ("Outer side 1", 1, 37, 1, 93),
]

#: The mesh family ITER_SURFACES was verified on: fort.30 header dims
#: (dimxh, dimyh) of the ITER 90x36 single-null layout (layout pinned in
#: the module docstring above; test_f30_gate asserts both real meshes
#: carry exactly these dims).  A readable mesh with other dims is
#: machine-specific geometry this port does not support — an outcome to
#: record, never windows to guess on (the wall gate).
ITER_MESH_DIMS = (90, 36)


def block3a_wlareas(wall):
    """wlarea of the six block-3a surface cards, in ITER_SURFACES card
    order (card i -> fort.44 wall row nlim+i-1, 0-based).

    THE ALIGNMENT RULE (the wall gate, the spec-probe trap): the gate compares
    computed surfaces against the run's OWN wlareas over this six-card
    window — NOT against the manifest's loaded_rows_si, which carries
    only the LOADED rows (5 for ITER; the unloaded core-wall card 1 sits
    at row nlim).  Zipping computed surfaces onto loaded_rows_si
    misaligns by one card and false-FAILs the gate at ~19x.

    Raises ValueError when the wall topology is not the six-card ITER
    block (nsts mismatch) or wlarea is absent — callers record that as
    an outcome, never a crash.
    """
    if wall.wlarea is None:
        raise ValueError("fort.44 wall section carries no wlarea vector")
    if wall.nsts != len(ITER_SURFACES):
        raise ValueError(
            f"wall nsts {wall.nsts} != {len(ITER_SURFACES)} block-3a cards")
    return [float(wall.wlarea[wall.nlim + i]) for i in range(len(ITER_SURFACES))]


def run_gate(fort30_path, golden_areas):
    """Area gate: recompute wlarea of the six 3a surfaces from fort.30 and
    compare to the fort.44 goldens (m^2). Returns list of result dicts."""
    xpol, ypol, npoint, dimxh, dimyh = read_fort30(fort30_path)
    factor = torus_factor()
    out = []
    for (name, idimp, inump, a, b), gold in zip(ITER_SURFACES, golden_areas):
        got = surface_area(xpol, ypol, idimp, inump, a, b, factor)
        rel = (abs(got - gold) / gold if gold
               else (0.0 if got == gold else float("inf")))
        out.append({
            "surface": name, "got_m2": got, "golden_m2": gold,
            "rel": rel,
        })
    return out
