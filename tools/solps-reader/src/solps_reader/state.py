"""Reader for ``b2fstate`` / ``b2fstati`` — B2.5 plasma state + fluxes.

Like b2fgmtry, the file is **cf-ASCII**, not XDR: line 1 is the shared
``VERSION`` provenance line, then a fixed sequence of self-describing cf
records.  The record map splits the file into a **header** written at
file creation by the driver (``cfverw`` + ``cfwuin`` dims + ``cfwuch``
label + ``b2wuzd`` the four species records — byte-identical at four
producer sites, e.g. b2mnds.F:266-269) and **state/flux records**
appended at end of run by b2wups.F:113-180.

The header reader parses the VERSION line, ``nx,ny,ns``, ``label`` and
the four numeric species records; :func:`read_fields` continues from
the stream position the header reader leaves off and parses the 48
state/flux records to EOF.  cf-record bytes and the VERSION line are
shared with b2fgmtry, so the low-level helpers in
:mod:`solps_reader.gmtry` are reused with this module's error class (same
pattern as ft46 reusing ft44's field-title scanner).

Deliberate deviations / limits:

- MATLAB consumes the header through its substring-search helpers and so
  never notices the ``label`` record (read_b2fstate.m:51 steps over it,
  read_rfield.m:12-18); solps_reader reads records **sequentially with exact
  names** — out of order, the substring search would misfire
  (``am`` ⊂ ``zamin``/``zamax`` — a hazard for substring search).
- The pre-01.001.024 species variant (``za``/``za2`` instead of
  ``zamin``/``zamax``, b2wuzd.F:25-33) is rejected with a clear error,
  exactly like the MATLAB reader (which also always reads ``zamin``
  first); no sample file exists in the reference data.
- ``nx, ny`` are the INTERIOR dims; every gridded state record stores the
  guard-cell box ``(nx+2)x(ny+2)`` (read_b2fstate.m:39-41,
  b2rups.F:31-59) — on the real file 92x38, the NetCDF convention, NOT
  fort.44's 90x36.  Documented, never forced equal.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import TextIO

import numpy as np

from solps_reader.gmtry import _read_record, _read_version_line

#: The six header records in writer order: (name, cf type).  Sources:
#: driver-level sequence b2mnds.F:266-269 (byte-identical at b2co.F:252-256,
#: b2aidr.F:786-790, b2rd.F:1411-1416); MATLAB reads the dims record at
#: read_b2fstate.m:34-37 and the species records at :51-54 (skipping only
#: ``label``, which its forward search steps over).
_HEADER_SEQUENCE: tuple[tuple[str, str], ...] = (
    ("nx,ny,ns", "int"),
    ("label", "char"),
    ("zamin", "real"),
    ("zamax", "real"),
    ("zn", "real"),
    ("am", "real"),
)

#: The 48 state/flux records in writer order (b2wups.F:113-180) with their
#: shape class.  MATLAB reads them in exactly this order via its forward
#: search (read_b2fstate.m:59-78 required, :83-116 version-gated optional):
#:
#: - ``"grid"``     — (nx+2, ny+2), count n2          (read_b2fstate.m:39-40)
#: - ``"grid_ns"``  — (nx+2, ny+2, ns), count n2*ns
#: - ``"fluxdim"``  — face-flux record: layer count k = count/n2, shaped
#:   (nx+2, ny+2, k); k = 2 on every file the tree can produce
#:   (read_b2fstate.m:39).  Sized from the count, not the >= 03.001.000
#:   gate (read_b2fstate.m:42-46) — no producer exists, a documented ambiguity.
#: - ``"fluxdimp"`` — the parallel-current record ``fch_p``: k = count/n2,
#:   collapsed to (nx+2, ny+2) when k == 1 (read_b2fstate.m:40 reads
#:   [nx+2,ny+2]; the 01.001.025-068 full-2-layer window b2wups.F:140-146
#:   would give (nx+2, ny+2, 2)).
#: - ``"fluxdims"`` — per-species face flux: k = count/(n2*ns), shaped
#:   (nx+2, ny+2, k, ns); k = 2 on every producible file
#:   (read_b2fstate.m:41; the 4-D variant :45 is count-sized like fluxdim).
#: - ``"scalar"``   — count 1, stored 0-d (MATLAB returns 1x1; ``time``).
_STATE_RECORDS: tuple[tuple[str, str], ...] = (
    # Required on every version the reference reader itself supports
    # (read_b2fstate.m reads these unconditionally).
    ("na", "grid_ns"),      # :59  (b2wups.F:113)
    ("ne", "grid"),         # :60  (>= 01.001.024, b2wups.F:114-115)
    ("ua", "grid_ns"),      # :61  (b2wups.F:116)
    ("uadia", "fluxdims"),  # :62  (>= 01.001.000, b2wups.F:117-118)
    ("te", "grid"),         # :63  (b2wups.F:119)
    ("ti", "grid"),         # :64  (b2wups.F:120)
    ("po", "grid"),         # :65  (b2wups.F:121)
    ("fna", "fluxdims"),    # :70  (b2wups.F:123)
    ("fhe", "fluxdim"),     # :71  (b2wups.F:124)
    ("fhi", "fluxdim"),     # :72  (b2wups.F:125)
    ("fch", "fluxdim"),     # :73  (b2wups.F:126)
    ("fch_32", "fluxdim"),  # :74  (>= 01.001.005, b2wups.F:127-128)
    ("fch_52", "fluxdim"),  # :75  (>= 01.001.005, b2wups.F:129-130)
    ("kinrgy", "grid_ns"),  # :76  (>= 01.001.009, b2wups.F:131-132)
    ("time", "scalar"),     # :77  (>= 01.001.018, b2wups.F:134-136)
    ("fch_p", "fluxdimp"),  # :78  (>= 01.001.069, b2wups.F:138-139)
    # The 32 "restart-effect" records — present only at >= 03.000.005
    # (read_b2fstate.m:80-117; writer b2wups.F:148-180).
    ("fna_mdf", "fluxdims"),      # :83
    ("fhe_mdf", "fluxdim"),       # :84
    ("fhi_mdf", "fluxdim"),       # :85
    ("fna_fcor", "fluxdims"),     # :86
    ("fna_nodrift", "fluxdims"),  # :87
    ("fna_he", "fluxdims"),       # :88
    ("fnaPSch", "fluxdims"),      # :89
    ("fhePSch", "fluxdim"),       # :90
    ("fhiPSch", "fluxdim"),       # :91
    ("fna_eir", "fluxdims"),      # :92
    ("fne_eir", "fluxdim"),       # :93
    ("fhe_eir", "fluxdim"),       # :94
    ("fhi_eir", "fluxdim"),       # :95
    ("fna_32", "fluxdims"),       # :96
    ("fna_52", "fluxdims"),       # :97
    ("fni_32", "fluxdim"),        # :98
    ("fni_52", "fluxdim"),        # :99
    ("fne_32", "fluxdim"),        # :100
    ("fne_52", "fluxdim"),        # :101
    ("fchdia", "fluxdim"),        # :102
    ("fchin", "fluxdim"),         # :103
    ("fchvispar", "fluxdim"),     # :104
    ("fchvisper", "fluxdim"),     # :105
    ("fchvisq", "fluxdim"),       # :106
    ("fchinert", "fluxdim"),      # :107
    ("vaecrb", "fluxdims"),       # :109
    ("vadia", "fluxdims"),        # :110
    ("wadia", "fluxdims"),        # :111
    ("veecrb", "fluxdim"),        # :112
    ("vedia", "fluxdim"),         # :113
    ("floe_noc", "fluxdim"),      # :115
    ("floi_noc", "fluxdim"),      # :116
)

#: Index one past the last record read unconditionally by the reference
#: reader — the required prefix of ``_STATE_RECORDS`` (read_b2fstate.m:59-78).
#: A file missing any of these fails in MATLAB exactly as it fails here.
_REQUIRED_COUNT = 16


class B2fstateFormatError(ValueError):
    """Raised when a b2fstate/b2fstati file does not match the reference format."""


@dataclass(frozen=True)
class B2Species:
    """One fluid species: the numeric records b2fstate stores instead of
    labels (read_b2fstate.m:51-54; writer b2wuzd.F:35-38).

    There are no species-name strings in the file — the run's
    ``SOLPS_FLUIDS`` names (``D0 D+1`` here) are not stored.  All four
    numbers are as-written reals (integral in practice).
    """

    #: 0-based species index (Fortran ``is``).
    index: int
    #: min ionization charge of the bundled stage (b2ruzd.F:39).
    zamin: float
    #: max ionization charge of the bundled stage (b2ruzd.F:40).
    zamax: float
    #: NUCLEAR charge of the bundled stage (b2mod_b2cmpa.F:21) — the
    #: element number, NOT the plasma charge (zamin/zamax carry that).
    zn: float
    #: mass number (b2ruzd.F:42).
    am: float

    @property
    def is_neutral(self) -> bool:
        """``zamin == 0`` marks the neutral stage (b2ruzd.F:46)."""
        return self.zamin == 0.0


@dataclass
class B2fstateHeader:
    """Parsed b2fstate header: VERSION line + the six header records."""

    #: 10-char version stamp, MATLAB ``line(8:17)`` (read_b2fstate.m:25-26).
    version: str
    #: character*32 git description after the version (cfverw,
    #: b2mod_version.F:52-67); ``None`` when all blanks.
    git_hash: str | None
    #: Interior grid dims + species count (record 1, read_b2fstate.m:34-37).
    nx: int
    ny: int
    ns: int
    #: Provenance char record — b2xxid instance + timestamp + user + run
    #: title (b2mnds.F:268, b2xxid :155).  Skipped by the MATLAB reader.
    label: str | None

    #: The four species records, as-written float64 vectors of length ns
    #: (read_b2fstate.m:51-54).
    zamin: np.ndarray
    zamax: np.ndarray
    zn: np.ndarray
    am: np.ndarray

    @property
    def species(self) -> list[B2Species]:
        """Per-species view of the four numeric records."""
        return [
            B2Species(i, zamin, zamax, zn, am)
            for i, (zamin, zamax, zn, am) in enumerate(
                zip(self.zamin, self.zamax, self.zn, self.am)
            )
        ]

    @property
    def grid_shape(self) -> tuple[int, int]:
        """Guard-cell box every gridded state record is stored over
        (read_b2fstate.m:39-41; Fortran ``(-1:nx,-1:ny…)`` b2rups.F:31-59).
        92x38 on ITER_2275 — the NetCDF convention, not fort.44's 90x36."""
        return (self.nx + 2, self.ny + 2)

    @property
    def n2(self) -> int:
        """Elements per guard-cell plane, (nx+2)*(ny+2) — 3496 on ITER_2275."""
        gx, gy = self.grid_shape
        return gx * gy

    @property
    def fluxdim(self) -> tuple[int, ...]:
        """Dims of 2-face flux records: (nx+2, ny+2, 2) — read_b2fstate.m:39.

        The >= 03.001.000 4-face variant (read_b2fstate.m:42-46) has no
        producer in the tree (writer caps at 03.000.010) and is not
        implemented — see the a documented ambiguity.
        """
        return (*self.grid_shape, 2)

    @property
    def fluxdimp(self) -> tuple[int, int]:
        """Dims of the parallel-current record ``fch_p`` (read_b2fstate.m:40)."""
        return self.grid_shape

    @property
    def fluxdims(self) -> tuple[int, ...]:
        """Dims of per-species flux records: (nx+2, ny+2, 2, ns)
        (read_b2fstate.m:41)."""
        return (*self.grid_shape, 2, self.ns)


def read_b2fstate_header(path: str | Path) -> B2fstateHeader:
    """Parse the header of a b2fstate/b2fstati file."""
    with open(path, encoding="latin-1") as fh:
        return read_header(fh)


def read_header(fh: TextIO) -> B2fstateHeader:
    """Parse the six header records from an open file.

    Leaves ``fh`` positioned at the first state record (``na``) so 
    can continue from the same stream — same contract as the fort.44/46
    header readers.
    """
    version, git_hash = _read_version_line(
        fh, family="b2fstate", error=B2fstateFormatError
    )

    # The header is exactly six records in writer order (b2mnds.F:266-269);
    # each is checked against the expectation AS it is read — no forward
    # searching, and a bad name/type/length is
    # reported at its own position rather than as a late truncation.
    values: list[object] = []
    for pos, (name, rtype) in enumerate(_HEADER_SEQUENCE, 1):
        while True:
            line = fh.readline()
            if not line:
                raise B2fstateFormatError(
                    f"b2fstate header truncated: got {len(values)} of "
                    f"{len(_HEADER_SEQUENCE)} records, next expected "
                    f"{name!r}"
                )
            if line.strip():
                break
        rname, rrtype, count, value = _read_record(
            fh, line, error=B2fstateFormatError
        )
        if rname != name:
            hint = (
                " (pre-01.001.024 species variant 'za'/'za2', b2wuzd.F:25-33 "
                "— unsupported, exactly as in the MATLAB reader)"
                if rname == "za"
                else ""
            )
            raise B2fstateFormatError(
                f"b2fstate header record {pos} must be {name!r}, got "
                f"{rname!r}{hint}"
            )
        if rrtype != rtype:
            raise B2fstateFormatError(
                f"b2fstate record {name!r} must be cf type {rtype!r}, "
                f"got {rrtype!r}"
            )
        values.append((count, value))

    dims_count, dims = values[0]
    if dims_count != 3 or dims.size != 3:
        raise B2fstateFormatError(
            f"b2fstate 'nx,ny,ns' must carry 3 integers, got count "
            f"{dims_count}"
        )
    nx, ny, ns = (int(v) for v in dims)
    if min(nx, ny, ns) < 1:
        # The writer asserts 1 <= ns (b2wuzd.F:22-23 xertst); nx/ny are
        # array bounds and cannot be zero in a real run.
        raise B2fstateFormatError(
            f"b2fstate 'nx,ny,ns' must be positive, got {nx}, {ny}, {ns}"
        )

    # Each species record must carry exactly ns values — the
    # ``numin ~= prod(dims)`` consistency check (read_rfield.m:20-25).
    species: list[np.ndarray] = []
    for (name, _), (count, value) in zip(_HEADER_SEQUENCE[2:], values[2:]):
        if count != ns or value.size != ns:
            raise B2fstateFormatError(
                f"b2fstate species record {name!r} must carry ns = {ns} "
                f"values, got {count}"
            )
        species.append(np.asarray(value, dtype=np.float64))

    label_value = values[1][1]
    return B2fstateHeader(
        version=version,
        git_hash=git_hash,
        nx=nx,
        ny=ny,
        ns=ns,
        label=label_value if isinstance(label_value, str) else None,
        zamin=species[0],
        zamax=species[1],
        zn=species[2],
        am=species[3],
    )


@dataclass
class B2fstate:
    """A fully parsed b2fstate/b2fstati file: header plus every state record.

    ``fields`` maps record name -> value in file order — the six header
    species records are exposed through :attr:`header`, the 48 state/flux
    records through ``fields``.  Every state record is a float64 ndarray
    already reshaped to its MATLAB shape (``fields["te"][ix+2, iy+2]`` is
    Fortran cell (ix, iy), ix in -1..nx, iy in -1..ny — the +2 guard
    offset, read_b2fstate.m:39-41 with read_rfield.m:29-31's column-major
    reshape); ``time`` is a 0-d array.  Future/unknown record names are
    kept with their flat file shape rather than guessed at.
    """

    header: B2fstateHeader
    #: State/flux records in file order (record map).
    fields: dict[str, "np.ndarray | str"]

    # -- convenience delegates to the header (container protocol of
    #    Ft44/Ft46/B2fgmtry: everything reachable off one object).
    @property
    def version(self) -> str:
        return self.header.version

    @property
    def git_hash(self) -> str | None:
        return self.header.git_hash

    @property
    def nx(self) -> int:
        return self.header.nx

    @property
    def ny(self) -> int:
        return self.header.ny

    @property
    def ns(self) -> int:
        return self.header.ns

    @property
    def label(self) -> str | None:
        return self.header.label

    @property
    def species(self) -> list[B2Species]:
        return self.header.species

    @property
    def grid_shape(self) -> tuple[int, int]:
        return self.header.grid_shape

    @property
    def n2(self) -> int:
        return self.header.n2

    @property
    def time(self) -> float | None:
        """The scalar ``time`` record in seconds, or ``None`` if absent."""
        value = self.fields.get("time")
        if isinstance(value, np.ndarray):
            return float(value)
        return None

    def keys(self) -> list[str]:
        """State record names in file order."""
        return list(self.fields)

    def __contains__(self, name: str) -> bool:
        return name in self.fields

    def __getitem__(self, name: str) -> "np.ndarray | str":
        """``state['te']`` -> record array; KeyError lists available names."""
        try:
            return self.fields[name]
        except KeyError:
            raise KeyError(
                f"no b2fstate record {name!r}; available: {self.keys()}"
            ) from None


def read_b2fstate(path: str | Path) -> B2fstate:
    """Parse a complete b2fstate/b2fstati file (header + state records)."""
    with open(path, encoding="latin-1") as fh:
        header = read_header(fh)
        fields = read_fields(fh, header)
    return B2fstate(header=header, fields=fields)


def read_fields(fh: TextIO, header: B2fstateHeader) -> dict[str, "np.ndarray | str"]:
    """Parse the state/flux records to EOF from a header-positioned stream.

    Mirrors the reference reader's consumption model with exact-name,
    in-order matching instead of MATLAB's substring forward search (the
     hazard note: ``na`` ⊂ ``fna``, ``ua`` ⊂ ``uadia`` — the search
    is only safe because it walks in file order):

    - Records are consumed sequentially in the writer's order
      (b2wups.F:113-180).  Skipping *ahead* is tolerated — every version
      gate in the sequence is ``>=``-style, so an older file simply lacks
      later records (read_b2fstate.m:80 gates the whole optional block).
    - A name already passed, or a duplicate, is an error (out of order).
    - An unknown name is kept flat — MATLAB's forward search steps over
      unknown headers the same way (read_rfield.m:12-18).
    - At EOF the required prefix (``na`` .. ``fch_p``, read_b2fstate.m:59-78
      unconditional reads) must be complete — a file missing any of those
      fails in the reference reader too.
    """
    gx, gy = header.grid_shape
    canonical_names = [name for name, _ in _STATE_RECORDS]
    shape_class = dict(_STATE_RECORDS)
    fields: dict[str, "np.ndarray | str"] = {}
    pointer = 0
    while True:
        line = fh.readline()
        if not line:
            break
        if not line.strip():
            continue
        name, _rtype, count, value = _read_record(fh, line, error=B2fstateFormatError)
        if name in fields:
            raise B2fstateFormatError(
                f"duplicate b2fstate record {name!r} — every name occurs in "
                f"exactly one header in a well-formed file"
            )
        if name in canonical_names[:pointer]:
            raise B2fstateFormatError(
                f"b2fstate record {name!r} out of order — {name!r} belongs "
                f"before already-read record "
                f"{canonical_names[pointer - 1]!r} (b2wups.F:113-180 order)"
            )
        if name in canonical_names[pointer:]:
            pointer = canonical_names.index(name, pointer) + 1
        # else: unknown record name — kept flat below, pointer unchanged.

        klass = shape_class.get(name)
        if klass is None:
            fields[name] = value
        else:
            if not isinstance(value, np.ndarray):
                raise B2fstateFormatError(
                    f"b2fstate record {name!r} must be cf type 'real', got "
                    f"a char record"
                )
            fields[name] = _shape_state_record(name, klass, count, value, header)

    missing = [
        name
        for name in canonical_names[:_REQUIRED_COUNT]
        if name not in fields
    ]
    if missing:
        raise B2fstateFormatError(
            f"b2fstate file ended before the required record {missing[0]!r} "
            f"— read_b2fstate.m:59-78 reads na..fch_p unconditionally"
        )
    return fields


def _shape_state_record(
    name: str,
    klass: str,
    count: int,
    value: np.ndarray,
    header: B2fstateHeader,
) -> np.ndarray:
    """Apply the shape rules to one parsed state record.

    Fixed-count classes enforce ``count == prod(dims)`` exactly like the
    reference reader (read_rfield.m:20-25).  The face-flux classes size
    their layer count from the declared count instead of a version gate —
    the >= 03.001.000 4-face variant has no producer in the tree
    (a documented ambiguity), so the count is the only honest authority.
    """
    gx, gy = header.grid_shape
    n2 = header.n2
    ns = header.ns
    if klass == "scalar":
        if count != 1:
            raise B2fstateFormatError(
                f"b2fstate record {name!r}: declared count {count} != expected "
                f"1 (read_rfield.m:20-25)"
            )
        return value.reshape(())
    if klass == "grid":
        expected, shape = n2, (gx, gy)
    elif klass == "grid_ns":
        expected, shape = n2 * ns, (gx, gy, ns)
    elif klass == "fluxdim":
        if count % n2 or count < n2:
            raise B2fstateFormatError(
                f"b2fstate record {name!r}: declared count {count} is not a "
                f"positive multiple of the guard-cell plane n2 = {n2}"
            )
        return value.reshape((gx, gy, count // n2), order="F")
    elif klass == "fluxdimp":
        if count % n2 or count < n2:
            raise B2fstateFormatError(
                f"b2fstate record {name!r}: declared count {count} is not a "
                f"positive multiple of the guard-cell plane n2 = {n2}"
            )
        k = count // n2
        return value.reshape((gx, gy) if k == 1 else (gx, gy, k), order="F")
    else:  # fluxdims
        per_species = n2 * ns
        if count % per_species or count < per_species:
            raise B2fstateFormatError(
                f"b2fstate record {name!r}: declared count {count} is not a "
                f"positive multiple of the per-species plane n2*ns = "
                f"{per_species}"
            )
        return value.reshape((gx, gy, count // per_species, ns), order="F")

    if count != expected:
        raise B2fstateFormatError(
            f"b2fstate record {name!r}: declared count {count} != expected "
            f"{expected} (read_rfield.m:20-25)"
        )
    return value.reshape(shape, order="F")
