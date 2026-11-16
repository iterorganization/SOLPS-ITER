"""Reader for ``b2fplasma`` / ``b2fplasmf`` — the B2.5 full plasma solution.

The file the solver writes at output time carrying the complete
plasma state — every profile, source, transport coefficient and
diagnostic array of the final iteration, ~190 arrays on a current
run.  Its ASCII twin ``b2fplasmf`` carries the identical record
stream in formatted form (produced by the ``b2uf`` converter;
``b2fu`` writes the binary back).  Both encodings are read here;
which one a path holds is detected from the bytes, never assumed
from the name.

Layout (the record map, read side of the converter pair):

- Binary ``b2fplasma`` is plain Fortran sequential UNFORMATTED
  records — 4-byte little-endian length markers around every
  record, no XDR.  File head: one VERSION record (cfverw,
  b2mod_version.F:52-67; payload ``'VERSION'`` + stamp*10 +
  blank + git description*32); pre-version files start directly
  at the first array record and default to stamp ``00.000.000``
  (cfverr's rewind branch, b2mod_version.F:41-45).
- Every array is TWO records: a 52-byte header (``'*cf:'`` A8,
  ``'real'|'int'`` A8, count int32, name A32 — cfrure.F:65-77)
  followed by a data record of count*8 / count*4 bytes.
- Record order is the converter's read order (b2uf.F:88-95):
  geometry, plasma, residuals, sources, transport, anomalous
  transport, neutral source scaling.  Membership inside a block
  is VERSION-gated with ``>=``/``>`` string comparisons on the
  zero-padded stamp (lexicographic == numeric at fixed width);
  optional records (cfrure_opt, cfrure.F:170-194) may be absent
  — present only when the next header names them.
- ``nx, ny, ns`` are NOT in the file: the converter itself takes
  them from the sibling ``b2fstate`` (b2uf.F:64-76, cross-checked
  against b2fgmtry and b2fparam).  This reader does the same by
  default (sibling b2fstate, explicit override); a wrong triple
  cannot slip through — every record's declared count is checked
  against the expected element total.
- The one dynamic dimension, ``nstra``, IS in the file (an int
  record gating the trailing ``sclstra``/``sclrtio`` pair, sized
  (ns+1, nstra); nstra=0 omits the pair entirely).  Its
  pre-01.001.024 default is DEF_NSTRA = 73 (b2mod_dimensions.F).
- Element order is Fortran column-major over the declared bounds
  — ``(-1:nx,-1:ny,…)`` guard-cell box, ix varying fastest,
  reshaped ``order='F'`` exactly like the b2fstate reader.  On
  the reference data the ``na`` record is byte-identical between
  b2fplasma and b2fstate of the same run, which pins the
  convention across both readers.

Deviations / limits, stated:

- ``qc``/``qcb`` presence is gated in the source on the
  *b2fgmtry* stamp (b2mod_geo.F:139-160); this reader gates on
  the b2fplasma file's own stamp — identical on every set one
  code run wrote together, and the only stamp available without
  demanding a b2fgmtry the converter merely cross-checks.
- The version ladder spans ``00.000.000`` .. ``03.000.010``
  exactly as the source conditionals; the reference data
  exercises only ``03.000.010``.  Older stamps parse by
  construction (every gate is ``>=``-style — an older file is
  the current sequence minus later records); the old branches
  are pinned by tests on synthetic files, not by field data.
- Big-endian and 8-byte record markers refuse with a named
  error: every producer in the ecosystem writes little-endian
  4-byte markers, and a silent misread of framing bytes is a
  wrong-answer class, not an inconvenience.
- The binary reader is LAZY: opening walks the 52-byte headers
  only (~11 KB of I/O on a 90 MB file) and builds an offset
  index; arrays load on first access.  The ASCII twin is parsed
  eagerly (the rare form, one pass).
"""

from __future__ import annotations

import re
import struct
from dataclasses import dataclass, field as dc_field
from pathlib import Path

import numpy as np

from solps_reader.gmtry import _HEADER_RE, _read_record
from solps_reader.state import read_b2fstate_header

#: array header payload: idcod*8 + idtyp*8 + count int32 + id1*32
#: (cfrure.F:67)
_HEADER_PAYLOAD = 52
#: pre-01.001.024 nstra default (b2mod_dimensions.F:32; DEF_NCUT=4,
#: DEF_NATM=6 -> (5*4/2+2)*6+1)
_DEF_NSTRA = 73
#: the one stamp whose sclstra pair sizes from the default instead of a
#: record: '01.001.023' alone (>= 01.001.023 reads the pair, but the
#: nstra record only exists from 01.001.024 on)
_NSTRA_DEFAULT_STAMP = "01.001.023"

_STAMP_RE = re.compile(r"\d{2}\.\d{3}\.\d{3}")


class B2fplasmaFormatError(ValueError):
    """Raised when a b2fplasma/b2fplasmf file does not match the format."""


# ---------------------------------------------------------------------------
# The record map
# ---------------------------------------------------------------------------

#: A shape is a tuple of extent symbols: ``"gx"``/``"gy"`` the guard-cell
#: box dims (nx+2, ny+2), ``"ns"`` the species count, ``"ns1"`` ns+1,
#: ``"nstra"`` the dynamic stratum count, or an int literal.  Symbolic
#: shapes make the expected COUNT (product) and the loaded array's logical
#: SHAPE one declaration, so a count check is also a shape check.
Shape = tuple


@dataclass(frozen=True)
class _Spec:
    block: str
    name: str
    shape: Shape
    optional: bool = False


def _sequence(version: str) -> list[_Spec]:
    """The version-gated record sequence, in converter read order.

    Every gate mirrors its source conditional; at fixed-width
    zero-padded stamps, lexicographic comparison equals numeric.
    Optional records (cfrure_opt) may be absent from the file.
    """
    ge, gt = (lambda a, b: a >= b), (lambda a, b: a > b)
    gxgy: Shape = ("gx", "gy")
    cell2: Shape = ("gx", "gy", 2)
    cell3: Shape = ("gx", "gy", 3)
    cell4: Shape = ("gx", "gy", 4)
    ns2: Shape = ("gx", "gy", "ns")
    k2ns: Shape = ("gx", "gy", 2, "ns")
    k4ns: Shape = ("gx", "gy", 4, "ns")
    out: list[_Spec] = []

    def R(block, name, shape, optional=False):
        out.append(_Spec(block, name, shape, optional))

    # -- geometry (read_b2mod_geo) ----------------------------------------
    for nm in ("bb", "crx", "cry", "ffbz", "fpsi"):
        R("geometry", nm, cell4)
    R("geometry", "gs", cell3)
    R("geometry", "hx", gxgy)
    R("geometry", "hy", gxgy)
    R("geometry", "qz", cell2)
    if gt(version, "01.001.021"):
        R("geometry", "qc", gxgy)
    if gt(version, "01.001.030"):
        R("geometry", "qcb", gxgy, optional=True)
    R("geometry", "vol", gxgy)
    if ge(version, "01.001.063"):
        R("geometry", "pbs", cell2)
    elif ge(version, "01.001.025"):
        R("geometry", "pbs", cell2, optional=True)
    if ge(version, "01.001.033"):
        R("geometry", "cell_width", gxgy, optional=True)
        R("geometry", "cell_height", gxgy, optional=True)

    # -- plasma (read_b2mod_plasma) ---------------------------------------
    for nm in ("fch", "fch0", "fchp", "fhe", "fhe0", "fhep"):
        R("plasma", nm, cell2)
    if gt(version, "01.001.003"):
        R("plasma", "fhet", cell2)
    for nm in ("fhi", "fhi0", "fhip"):
        R("plasma", nm, cell2)
    if gt(version, "01.001.003"):
        R("plasma", "fhit", cell2)
    for nm in ("fna", "fna0", "fnap"):
        R("plasma", nm, k2ns)
    R("plasma", "fne", cell2)
    R("plasma", "fni", cell2)
    for nm in ("na", "na0", "nap"):
        R("plasma", nm, ns2)
    for nm in ("ne", "ne0", "ne2", "nep"):
        R("plasma", nm, gxgy)
    R("plasma", "ni", cell2)
    R("plasma", "ni0", cell2)
    R("plasma", "pb", gxgy)
    for nm in ("po", "po0", "pop", "te", "te0", "tep", "ti", "ti0", "tip"):
        R("plasma", nm, gxgy)
    for nm in ("ua", "ua0", "uap"):
        R("plasma", nm, ns2)
    R("plasma", "uadia", k2ns)
    R("plasma", "fchdia", cell2)
    if ge(version, "01.001.008"):
        for nm in ("fmo", "fna_32", "fna_52"):
            R("plasma", nm, k2ns)
        for nm in ("fni_32", "fni_52", "fne_32", "fne_52"):
            R("plasma", nm, cell2)
    if ge(version, "01.001.010"):
        for nm in ("wadia", "vaecrb"):
            R("plasma", nm, k2ns)
    if ge(version, "01.001.012"):
        R("plasma", "facdrift", gxgy)
        R("plasma", "fac_ExB", gxgy)
    if ge(version, "01.001.014"):
        for nm in ("fchvispar", "fchvisper", "fchin"):
            R("plasma", nm, cell2)
        R("plasma", "fna_nodrift", k2ns)
    if ge(version, "01.001.015"):
        R("plasma", "fac_vis", gxgy)
    if ge(version, "03.000.003"):
        R("plasma", "fna_mdf", k2ns)
        for nm in ("fhe_mdf", "fhi_mdf"):
            R("plasma", nm, cell2)
        R("plasma", "fnaPSch", k2ns)
        for nm in ("fhePSch", "fhiPSch"):
            R("plasma", nm, cell2)
        for nm in ("fna_fcor", "fna_he"):
            R("plasma", nm, k2ns)
        for nm in ("fchvisq", "fchinert"):
            R("plasma", nm, cell2)
    if ge(version, "03.000.007"):
        R("plasma", "fht", cell2, optional=True)
        R("plasma", "fhj", cell2, optional=True)
        R("plasma", "fhm", k2ns, optional=True)
        R("plasma", "fhp", k2ns, optional=True)

    # -- residuals (read_b2mod_residuals) ---------------------------------
    for nm, shp in (("resco", ns2), ("reshe", gxgy), ("reshi", gxgy),
                    ("resmo", ns2), ("resmt", gxgy), ("respo", gxgy)):
        R("residuals", nm, shp)

    # -- sources (read_b2mod_sources) -------------------------------------
    for nm, shp in (("sch", cell4), ("she", cell4), ("shi", cell4),
                    ("smo", k4ns), ("smq", k4ns)):
        R("sources", nm, shp)
    R("sources", "sna", k2ns)
    if ge(version, "01.001.026"):
        R("sources", "sne", cell2, optional=True)
    if gt(version, "00.000.000"):
        R("sources", "rsana", ns2)
        R("sources", "rsahi", ns2)
        if gt(version, "01.001.003"):
            R("sources", "rsamo", ns2)
        R("sources", "rrana", ns2)
        R("sources", "rrahi", ns2)
        if gt(version, "01.001.003"):
            R("sources", "rramo", ns2)
        R("sources", "rqahe", ns2)
        if ge(version, "01.001.016"):
            R("sources", "rqrad", ns2)
        if ge(version, "01.001.019"):
            R("sources", "rqbrm", ns2)
        R("sources", "rcxna", ns2)
        R("sources", "rcxhi", ns2)
        if gt(version, "01.001.003"):
            R("sources", "rcxmo", ns2)
    if gt(version, "01.001.000"):
        # b2stbr_smo / b2stbc_smo / b2stbm_smo / ext_smo are the batch
        # TOTALS (one plane per species, 3-D) — not the 4-layer momentum
        # layout of smo/smq; every reference sample's counts say so.
        R("sources", "b2stbr_sna", ns2)
        R("sources", "b2stbr_smo", ns2)
        for nm in ("b2stbr_she", "b2stbr_shi", "b2stbr_sch"):
            R("sources", nm, gxgy)
    if ge(version, "01.001.026"):
        R("sources", "b2stbr_sne", gxgy, optional=True)
    if gt(version, "01.001.010"):
        R("sources", "b2stbc_sna", ns2)
        R("sources", "b2stbc_smo", ns2)
        for nm in ("b2stbc_she", "b2stbc_shi", "b2stbc_sch"):
            R("sources", nm, gxgy)
    if ge(version, "01.001.026"):
        R("sources", "b2stbc_sne", gxgy, optional=True)
    if ge(version, "01.001.027"):
        R("sources", "b2stbm_sna", ns2, optional=True)
        R("sources", "b2stbm_smo", ns2, optional=True)
        for nm in ("b2stbm_she", "b2stbm_shi", "b2stbm_sch", "b2stbm_sne"):
            R("sources", nm, gxgy, optional=True)
    if gt(version, "01.001.002"):
        for nm in ("b2sihs_divue", "b2sihs_divua", "b2sihs_exbe",
                   "b2sihs_exba", "b2sihs_visa", "b2sihs_joule",
                   "b2sihs_fraa", "b2sihs_str"):
            R("sources", nm, gxgy)
    if gt(version, "01.001.005"):
        for nm in ("b2npmo_smaf", "b2npmo_smag", "b2npmo_smav"):
            R("sources", nm, k4ns)
    if gt(version, "01.001.030"):
        for nm in ("smpr", "smpt", "smfr"):
            R("sources", nm, ns2, optional=True)
    if gt(version, "03.000.000"):
        R("sources", "smcf", ns2)
    if gt(version, "01.001.012"):
        R("sources", "ext_sna", ns2)
        R("sources", "ext_smo", ns2)
        for nm in ("ext_she", "ext_shi", "ext_sch"):
            R("sources", nm, gxgy)
    if ge(version, "01.001.026"):
        R("sources", "ext_sne", gxgy, optional=True)

    # -- transport (read_b2mod_transport) ---------------------------------
    R("transport", "calf", cell2)
    R("transport", "cdna", k2ns)
    R("transport", "cdpa", k2ns)
    R("transport", "ceqp", gxgy)
    for nm in ("chce", "chci", "chve"):
        R("transport", nm, cell2)
    R("transport", "chvemx", gxgy)
    R("transport", "chvi", cell2)
    R("transport", "chvimx", gxgy)
    R("transport", "csig", cell2)
    R("transport", "cvla", k2ns)
    R("transport", "cvsa", k2ns)
    R("transport", "cthe", ns2)
    R("transport", "cthi", ns2)
    if ge(version, "01.001.007"):
        R("transport", "csigin", ("gx", "gy", 2, "ns", "ns"))
        R("transport", "cvsa_cl", k2ns)
    if ge(version, "01.001.021"):
        R("transport", "fllime", gxgy)
        R("transport", "fllimi", gxgy)
    if ge(version, "01.001.017"):
        R("transport", "fllim0fna", k2ns)
        R("transport", "fllim0fhi", k2ns)
    if ge(version, "01.001.020"):
        R("transport", "fllimvisc", ns2)
    if ge(version, "03.000.006"):
        for nm in ("f_luc_ke", "f_luc_ki", "f_luc_et", "f_luc_sg",
                   "f_luc_al", "fllim_ke", "fllim_ki", "fllim_al",
                   "fllim_al_c"):
            R("transport", nm, gxgy)

    # -- anomalous transport (read_b2mod_anomalous_transport) -------------
    if gt(version, "01.001.001"):
        for nm, shp in (("sig0", gxgy), ("hce0", gxgy), ("alf0", gxgy),
                        ("hci0", gxgy), ("hcib", ns2), ("dpa0", ns2),
                        ("dna0", ns2), ("vsa0", ns2), ("vla0", k2ns),
                        ("csig_an", cell2)):
            R("anomalous transport", nm, shp)
    if ge(version, "01.001.029"):
        R("anomalous transport", "calf_an", cell2, optional=True)

    # -- neutral source scaling (read_b2mod_neutr_src_scaling) ------------
    if ge(version, "01.001.024"):
        # cfruin(nread, 1, idum, 'nstra'): count-1 integer record whose
        # value sizes the pair below; shaped as a 0-d array on load
        R("neutral source scaling", "nstra", ())
    if ge(version, "01.001.023"):
        # the pair is written only when nstra > 0 — checked during the
        # walk, once the nstra record's value (or the one-stamp default)
        # is known
        R("neutral source scaling", "sclstra", ("ns1", "nstra"))
        R("neutral source scaling", "sclrtio", ("ns1", "nstra"))
    return out


def _resolve(shape: Shape, nx: int, ny: int, ns: int, nstra: int) -> tuple:
    dims = {"gx": nx + 2, "gy": ny + 2, "ns": ns, "ns1": ns + 1,
            "nstra": nstra}
    return tuple(dims[s] if isinstance(s, str) else s for s in shape)


# ---------------------------------------------------------------------------
# Dimension resolution (the converter's own policy)
# ---------------------------------------------------------------------------

def _resolve_dims(
    path: Path,
    b2fstate: str | Path | None,
    dims: str | None,
) -> tuple[int, int, int, str, tuple | None]:
    """nx, ny, ns from the explicit override, else the sibling b2fstate.

    The converter takes the same triple from b2fstate (b2uf.F:64-76); a
    run directory always carries one beside its b2fplasma.  Wrong dims
    never pass silently downstream — every record count is cross-checked
    against the resolved triple while the file is opened.  When the dims
    come from a b2fstate, its per-species charges ride along (the file
    itself stores no species data) — ``None`` under an explicit override.
    """
    if dims is not None:
        try:
            nx, ny, ns = (int(p) for p in dims.split(","))
        except ValueError:
            raise B2fplasmaFormatError(
                f"dims must be 'nx,ny,ns' (e.g. '90,36,3'), got {dims!r}"
            ) from None
        if min(nx, ny, ns) < 1:
            raise B2fplasmaFormatError(
                f"dims must be positive, got {nx},{ny},{ns}"
            )
        return nx, ny, ns, "explicit dims", None
    sibling = Path(b2fstate) if b2fstate else path.parent / "b2fstate"
    if not sibling.is_file():
        raise B2fplasmaFormatError(
            f"a b2fplasma file does not carry its own grid dims, and no "
            f"sibling b2fstate was found at {sibling}. Pass the b2fstate "
            f"path or dims 'nx,ny,ns' explicitly"
        )
    try:
        head = read_b2fstate_header(sibling)
    except (OSError, ValueError) as exc:
        raise B2fplasmaFormatError(
            f"cannot read grid dims from b2fstate {sibling}: {exc}"
        ) from None
    given = b2fstate is not None
    source = "sibling b2fstate" if not given else f"b2fstate {sibling.name}"
    return (head.nx, head.ny, head.ns, source,
            tuple(float(z) for z in head.zamin))


# ---------------------------------------------------------------------------
# Encoding detection + the binary record primitives
# ---------------------------------------------------------------------------

def _read_fortran_record(fh) -> bytes | None:
    """One sequential-unformatted record: markers verified around the
    payload; ``None`` at clean EOF.

    gfortran/Intel layout — int32 little-endian count, payload, count
    again.  A mismatched or negative marker is framing corruption or a
    foreign endianness, never a skippable detail.
    """
    pre = fh.read(4)
    if len(pre) == 0:
        return None
    if len(pre) < 4:
        raise B2fplasmaFormatError(
            f"b2fplasma truncated: {len(pre)}-byte length marker"
        )
    (n,) = struct.unpack("<i", pre)
    if n < 0:
        raise B2fplasmaFormatError(
            f"negative record length {n} — not little-endian 4-byte "
            f"Fortran records (big-endian and 8-byte-marker files are "
            f"outside what any SOLPS-ITER producer writes)"
        )
    payload = fh.read(n)
    suf = fh.read(4)
    if len(payload) != n or len(suf) < 4:
        raise B2fplasmaFormatError(
            f"b2fplasma truncated inside a {n}-byte record"
        )
    (n2,) = struct.unpack("<i", suf)
    if n2 != n:
        raise B2fplasmaFormatError(
            f"record length markers disagree ({n} before, {n2} after) at "
            f"byte {fh.tell() - n - 8} — corrupted or non-Fortran framing"
        )
    return payload


def _peek_is_binary(path: Path) -> bool:
    """Binary iff the first record's markers bookend a plausible payload.

    ASCII text accidentally unpacking to a plausible little-endian
    length is not enough — the trailing marker must equal it (a ~2^-32
    coincidence on text), so the two encodings cannot be confused.
    """
    with open(path, "rb") as fh:
        head = fh.read(4)
        if len(head) < 4:
            return False
        (n,) = struct.unpack("<i", head)
        if not 0 < n <= path.stat().st_size - 8:
            return False
        fh.seek(4 + n)
        tail = fh.read(4)
        if len(tail) < 4:
            return False
        (n2,) = struct.unpack("<i", tail)
        return n2 == n


def _parse_version_record(payload: bytes) -> tuple[str, str | None]:
    """cfverw's record: label, 10-char stamp, blank, 32-char git id."""
    version = payload[7:17].decode("ascii", "replace")
    if not _STAMP_RE.fullmatch(version):
        raise B2fplasmaFormatError(
            f"version stamp must be NN.NNN.NNN, got {version!r}"
        )
    git_hash = payload[18:].decode("ascii", "replace").strip() or None
    return version, git_hash


# ---------------------------------------------------------------------------
# The reader object
# ---------------------------------------------------------------------------

@dataclass
class _Rec:
    """One present record: where its data lives and what shape it takes."""
    spec: _Spec
    shape: tuple
    count: int
    offset: int = -1          # binary only: data payload start
    value: object = None      # ascii only: the parsed array


@dataclass
class B2fplasma:
    """A b2fplasma/b2fplasmf file opened for reading.

    ``plasma['te']`` -> float64 ndarray shaped (nx+2, ny+2), Fortran
    cell (ix, iy) with the -1 guard offset — same convention as the
    b2fstate reader.  Binary files load lazily on first access (opening
    walked only the 52-byte headers); the ASCII twin is parsed eagerly.
    Use as a context manager, or call :meth:`close`.
    """

    path: Path
    version: str
    git_hash: str | None
    encoding: str                     # 'binary' | 'ascii'
    nx: int
    ny: int
    ns: int
    nstra: int | None
    dims_source: str
    #: per-species charges when dims came from a b2fstate (the plasma file
    #: stores none); ``None`` under an explicit override
    species_zamin: tuple | None = None
    #: how many records the version gate expects here (absent ones are
    #: optional slots that the file omitted)
    expected: int = 0
    records: list = dc_field(default_factory=list)

    _fh: object = None                # binary: kept open for lazy loads
    _cache: dict = dc_field(default_factory=dict)

    @property
    def grid_shape(self) -> tuple[int, int]:
        """Guard-cell box every gridded record stores over: (nx+2, ny+2)."""
        return (self.nx + 2, self.ny + 2)

    def keys(self) -> list[str]:
        """Record names in file order."""
        return [r.spec.name for r in self.records]

    def blocks(self) -> list:
        """(block, member names) in converter order — the inventory view."""
        out: list = []
        for r in self.records:
            if out and out[-1][0] == r.spec.block:
                out[-1][1].append(r.spec.name)
            else:
                out.append((r.spec.block, [r.spec.name]))
        return out

    def __contains__(self, name: str) -> bool:
        return any(r.spec.name == name for r in self.records)

    def shape_of(self, name: str) -> tuple:
        """The logical array shape a record loads as."""
        for r in self.records:
            if r.spec.name == name:
                return r.shape
        raise KeyError(
            f"no b2fplasma record {name!r}; available: {self.keys()}"
        )

    def __getitem__(self, name: str) -> np.ndarray:
        """``plasma['te']`` -> the record array; KeyError lists names."""
        if name in self._cache:
            return self._cache[name]
        for r in self.records:
            if r.spec.name == name:
                arr = self._load(r)
                self._cache[name] = arr
                return arr
        raise KeyError(
            f"no b2fplasma record {name!r}; available: {self.keys()}"
        )

    def _load(self, r: _Rec) -> np.ndarray:
        if self.encoding == "ascii":
            return r.value  # parsed eagerly, already shaped
        if self._fh is None:
            raise B2fplasmaFormatError("b2fplasma file is closed")
        is_int = r.spec.name == "nstra"
        dtype, width = ("<i4", 4) if is_int else ("<f8", 8)
        self._fh.seek(r.offset)
        payload = self._fh.read(r.count * width)
        if len(payload) != r.count * width:
            raise B2fplasmaFormatError(
                f"b2fplasma record {r.spec.name!r}: truncated data record"
            )
        flat = np.frombuffer(payload, dtype=dtype)
        if r.shape == ():
            return flat.reshape(())
        return flat.reshape(r.shape, order="F").copy()

    def load_all(self) -> dict:
        """Every present record, loaded (the export path)."""
        return {name: self[name] for name in self.keys()}

    def close(self) -> None:
        if self._fh is not None:
            self._fh.close()
            self._fh = None

    def __enter__(self) -> "B2fplasma":
        return self

    def __exit__(self, *exc) -> None:
        self.close()


def read_b2fplasma(
    path: str | Path,
    *,
    b2fstate: str | Path | None = None,
    dims: str | None = None,
) -> B2fplasma:
    """Open a b2fplasma (binary) or b2fplasmf (ASCII) file for reading.

    Encoding is detected from the bytes.  Grid dims come from the
    sibling ``b2fstate`` (the converter's own source for them) unless
    ``b2fstate``/``dims`` say otherwise.  Every record's name, type and
    count are verified against the version-gated sequence while
    opening — a file that does not match answers a named error, never
    a silent misread.
    """
    p = Path(path)
    try:
        binary = _peek_is_binary(p)
        if not binary:
            # a big-endian producer would fail the little-endian marker
            # test and land here as if it were text — name it for what
            # it is instead of a confusing not-a-record error
            with open(p, "rb") as fh:
                head = fh.read(4)
            if len(head) == 4:
                (n,) = struct.unpack(">i", head)
                if 0 < n <= p.stat().st_size - 8:
                    raise B2fplasmaFormatError(
                        f"{p}: big-endian Fortran record markers (first "
                        f"record length {n}) — only little-endian 4-byte "
                        f"markers, the only kind any SOLPS-ITER producer "
                        f"writes, are supported"
                    )
    except OSError as exc:
        raise B2fplasmaFormatError(f"cannot read {p}: {exc}") from None

    nx, ny, ns, dims_source, zamin = _resolve_dims(p, b2fstate, dims)

    pl = _read_binary(p, nx, ny, ns, dims_source) if binary \
        else _read_ascii(p, nx, ny, ns, dims_source)
    pl.species_zamin = zamin
    if not pl.records:
        raise B2fplasmaFormatError(f"{p}: no records found")
    return pl


# ---------------------------------------------------------------------------
# binary
# ---------------------------------------------------------------------------

#: the only integer-valued record in the family (cfruin 'nstra')
_INT_RECORDS = frozenset({"nstra"})


def _count(spec: _Spec, nx: int, ny: int, ns: int, nstra: int) -> int:
    n = 1
    for d in _resolve(spec.shape, nx, ny, ns, nstra):
        n *= int(d)
    return n


def _mismatch_hint(found: str) -> str:
    if found == "nx,ny,ns":
        return (" (the first record names the grid dims — this looks like "
                "a b2fstate, not a b2fplasma/b2fplasmf)")
    return ""


def _read_binary(p: Path, nx: int, ny: int, ns: int, dims_source: str) -> B2fplasma:
    fh = open(p, "rb")
    try:
        # VERSION first (cfverr): present -> stamp; absent -> the default
        # stamp and the geometry block starts at byte 0 (rewind branch)
        version, git_hash = "00.000.000", None
        pos0 = fh.tell()
        payload = _read_fortran_record(fh)
        if payload is not None and len(payload) >= 17 \
                and payload[:7] == b"VERSION":
            version, git_hash = _parse_version_record(payload)
        else:
            fh.seek(pos0)

        pl = B2fplasma(
            path=p, version=version, git_hash=git_hash, encoding="binary",
            nx=nx, ny=ny, ns=ns, nstra=None, dims_source=dims_source, _fh=fh,
        )
        seq = _sequence(version)
        nstra = _DEF_NSTRA if version == _NSTRA_DEFAULT_STAMP else None
        present: list = []
        expected = 0

        for spec in seq:
            if spec.name in ("sclstra", "sclrtio") and (nstra or 0) == 0:
                continue  # the pair is written only when nstra > 0
            expected += 1
            count = _count(spec, nx, ny, ns,
                           nstra if nstra is not None else _DEF_NSTRA)
            pos = fh.tell()
            head = _read_header_record(fh)
            if head is None:
                if spec.optional:
                    continue
                raise B2fplasmaFormatError(
                    f"{p}: file ended before required record "
                    f"{spec.name!r} ({len(present)} of {len(seq)} "
                    f"expected records present)"
                )
            magic, rtype, n0, hname = head
            if hname != spec.name:
                if spec.optional:
                    fh.seek(pos)  # cfrure_opt's backspace: unconsumed
                    continue
                raise B2fplasmaFormatError(
                    f"{p}: expected record {spec.name!r}, found "
                    f"{hname!r} at byte {pos} — out of sequence, or a "
                    f"variant layout this version gate does not know"
                    f"{_mismatch_hint(hname)}"
                )
            _check_header(p, spec, magic, rtype, n0, count, dims_source)
            rec = _Rec(spec=spec, shape=_resolve(spec.shape, nx, ny, ns,
                                                 nstra or _DEF_NSTRA),
                       count=n0)
            if n0 == 0:
                present.append(rec)
                continue
            if spec.name == "nstra":
                rec.offset = fh.tell() + 4  # past the leading marker
                data = _read_fortran_record(fh)
                (nstra,) = struct.unpack("<i", data[:4])
                pl.nstra = nstra
                present.append(rec)
                continue
            rec.offset = fh.tell() + 4  # past the leading marker
            fh.seek(rec.offset)
            fh.seek(n0 * 8 + 4, 1)  # payload + trailing marker
            present.append(rec)

        if fh.read(1):
            raise B2fplasmaFormatError(
                f"{p}: trailing data after the last expected record "
                f"'{seq[-1].name}' — unknown variant; refusing to guess"
            )
        pl.records = present
        pl.expected = expected
        return pl
    except Exception:
        fh.close()
        raise


def _read_header_record(fh) -> tuple | None:
    """Parse one 52-byte array header record; ``None`` at clean EOF."""
    payload = _read_fortran_record(fh)
    if payload is None:
        return None
    if len(payload) != _HEADER_PAYLOAD:
        raise B2fplasmaFormatError(
            f"array header record must be {_HEADER_PAYLOAD} bytes "
            f"('*cf:' + type + count + name), got {len(payload)} bytes"
        )
    magic = payload[:8].decode("ascii", "replace").rstrip()
    rtype = payload[8:16].decode("ascii", "replace").rstrip()
    (n0,) = struct.unpack("<i", payload[16:20])
    hname = payload[20:52].decode("ascii", "replace").rstrip()
    return magic, rtype, n0, hname


def _check_header(p, spec, magic, rtype, n0, count, dims_source) -> None:
    if magic != "*cf:":
        raise B2fplasmaFormatError(
            f"{p}: record {spec.name!r} header magic must be '*cf:', "
            f"got {magic!r}"
        )
    want_type = "int" if spec.name in _INT_RECORDS else "real"
    if rtype != want_type:
        raise B2fplasmaFormatError(
            f"{p}: record {spec.name!r} must be cf type {want_type!r}, "
            f"got {rtype!r}"
        )
    if n0 != count:
        raise B2fplasmaFormatError(
            f"{p}: record {spec.name!r} declares {n0} values, expected "
            f"{count} — the grid dims ({dims_source}) do not fit this "
            f"file, or it is a layout variant. If the file was written "
            f"on another grid, pass the b2fstate path or dims explicitly"
        )


# ---------------------------------------------------------------------------
# ascii
# ---------------------------------------------------------------------------

class _Pushback:
    """One-line pushback over a text stream (the cfrure_opt backspace)."""

    def __init__(self, fh):
        self.fh = fh
        self.held: str | None = None

    def readline(self) -> str:
        if self.held is not None:
            line, self.held = self.held, None
            return line
        return self.fh.readline()

    def push(self, line: str) -> None:
        self.held = line


def _read_ascii(p: Path, nx: int, ny: int, ns: int, dims_source: str) -> B2fplasma:
    with open(p, encoding="latin-1") as raw:
        fh = _Pushback(raw)
        # VERSION line first; absent -> the default stamp, line unconsumed
        version, git_hash = "00.000.000", None
        first = fh.readline()
        if first.startswith("VERSION") and len(first.rstrip("\n")) >= 17:
            version = first[7:17]
            if not _STAMP_RE.fullmatch(version):
                raise B2fplasmaFormatError(
                    f"version stamp must be NN.NNN.NNN, got {version!r}"
                )
            git_hash = first[17:].strip() or None
        else:
            fh.push(first)

        pl = B2fplasma(
            path=p, version=version, git_hash=git_hash, encoding="ascii",
            nx=nx, ny=ny, ns=ns, nstra=None, dims_source=dims_source,
        )
        seq = _sequence(version)
        nstra = _DEF_NSTRA if version == _NSTRA_DEFAULT_STAMP else None
        present: list = []
        expected = 0

        for spec in seq:
            if spec.name in ("sclstra", "sclrtio") and (nstra or 0) == 0:
                continue
            expected += 1
            count = _count(spec, nx, ny, ns,
                           nstra if nstra is not None else _DEF_NSTRA)
            line = fh.readline()
            if not line or not line.strip():
                if spec.optional:
                    continue
                raise B2fplasmaFormatError(
                    f"{p}: file ended before required record "
                    f"{spec.name!r} ({len(present)} of {len(seq)} "
                    f"expected records present)"
                )
            m = _HEADER_RE.match(line.rstrip("\n"))
            hname = m.group("name").rstrip() if m else ""
            if hname != spec.name:
                if spec.optional:
                    fh.push(line)
                    continue
                raise B2fplasmaFormatError(
                    f"{p}: expected record {spec.name!r}, found "
                    f"{hname or line.strip()!r} — out of sequence, or a "
                    f"variant layout this version gate does not know"
                    f"{_mismatch_hint(hname)}"
                )
            _name, rtype, n0, value = _read_record(
                fh.fh, line, error=B2fplasmaFormatError)
            _check_header(p, spec, "*cf:", rtype, n0, count, dims_source)
            arr = np.asarray(value)
            if spec.name == "nstra":
                nstra = int(arr.reshape(-1)[0])
                pl.nstra = nstra
                present.append(_Rec(spec=spec, shape=(), count=n0,
                                    value=arr.reshape(())))
                continue
            arr = arr.astype(np.float64)
            shape = _resolve(spec.shape, nx, ny, ns, nstra)
            present.append(_Rec(
                spec=spec, shape=shape, count=n0,
                value=(arr.reshape(()) if shape == ()
                       else arr.reshape(shape, order="F")),
            ))

        tail = fh.readline()
        while tail and not tail.strip():
            tail = fh.readline()
        if tail:
            raise B2fplasmaFormatError(
                f"{p}: trailing data after the last expected record "
                f"'{seq[-1].name}' — unknown variant; refusing to guess"
            )
        pl.records = present
        pl.expected = expected
        return pl
