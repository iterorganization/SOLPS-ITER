"""Reader for ``b2fgmtry`` — B2.5 grid geometry + magnetic field.

The file is **cf-ASCII**, not XDR: line 1 is a ``VERSION`` provenance line,
everything after is a fixed sequence of self-describing cf records written
by the B2.5 grid generator (b2agdr.F:721-744 via b2wugm.F:422-490) — header
line ``(2a8,i12,4x,a32)`` then the values.  The MATLAB reference reader is
``read_b2fgmtry.m`` with the shared ``read_ifield.m`` / ``read_rfield.m``
helpers; the Fortran reader ``b2rugm.F`` (doc block :39-181) supplies the
per-field semantics MATLAB never asks for.  The record-by-record map with
all citations lives in the format dictionary — the tables below cite the
same lines.

Two deliberate deviations from MATLAB, both by design:

- MATLAB *searches forward* for each field name as a substring
  (read_ifield.m:12-18) and so silently skips 6 on-disk records (``label``,
  ``redef_gmtry``, ``wbbl``, ``cflags``, ``cell_width``, ``cell_height``).
  solps_reader reads **every** record sequentially and matches header names
  exactly — the substring search has real near-collisions on this very file
  (``bb`` in ``wbbl``, ``gs`` in ``cflags``).
- ``nx, ny`` on line 3 are the INTERIOR grid dims; every gridded record
  stores the guard-cell box ``(nx+2)x(ny+2)`` (MATLAB dims ``[nx+2,ny+2,…]``,
  read_b2fgmtry.m:33,46-56; Fortran declarations ``(-1:nx,-1:ny…)``,
  b2rugm.F:21-28).  On the real file that is 92x38 — the NetCDF convention,
  *not* fort.44's 90x36.  Documented, never forced equal.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import TextIO

import numpy as np

#: cf record header layout ``(2a8,i12,4x,a32)`` (cfwuin.F:28, cfwure.F:30,
#: cfwuch.F:29; read identically at cfrure.F:28).  ``*cf:`` blank-padded to
#: 8, type padded to 8, element count right-justified in 12, four blanks,
#: field name padded to 32.
_HEADER_RE = re.compile(
    r"^(?P<magic>.{8})(?P<type>.{8})(?P<count>.{12})    (?P<name>.{0,32})$"
)

#: Types a cf record may declare (cfwuin/cfwure/cfwuch are the only
#: producers; cfrure.F:28-35 validates magic, name and count the same way).
_RECORD_TYPES = frozenset({"int", "real", "char"})

#: Gridded records and their trailing dimension k: values reshape to
#: ``(nx+2, ny+2, k)`` column-major (MATLAB ``reshape(field,dims)`` is
#: column-major, read_rfield.m:33-34).  k=1 collapses to ``(nx+2, ny+2)``
#: because MATLAB passes 2-element dims there (read_b2fgmtry.m:51-53,
#: :74-81).  Lines: 4-corner/4-component fields read_b2fgmtry.m:46-50;
#: qz :54; gs :56; region :83; resignore :85; pbs :88; cflags
#: (GRID_N_CELLFLAGS=5, carre_constants.F90:23) b2rugm.F:638-641;
#: cell_width/cell_height b2rugm.F:705-707; wbbl b2wugm.F:483.
_GRID_K: dict[str, int] = {
    "crx": 4,
    "cry": 4,
    "fpsi": 4,
    "ffbz": 4,
    "bb": 4,
    "wbbl": 4,
    "qz": 2,
    "gs": 3,
    "region": 3,
    "resignore": 2,
    "pbs": 2,
    "cflags": 5,
    "vol": 1,
    "hx": 1,
    "hy": 1,
    "cell_width": 1,
    "cell_height": 1,
    "leftix": 1,
    "rightix": 1,
    "topix": 1,
    "bottomix": 1,
    "leftiy": 1,
    "rightiy": 1,
    "topiy": 1,
    "bottomiy": 1,
}

#: Flat vector records with a MATLAB-mandated element count — the
#: ``numin ~= prod(dims)`` consistency check (read_ifield.m:20-25) as a
#: (fixed count, citation) table.  ``nlx*``/``nly*``/``nlloc`` scale with
#: ``nlreg`` and ``*cut`` scale with ``nncut``; they are validated after
#: the header scalars are known.  ``parg`` count 100 read_b2fgmtry.m:90;
#: ``nnreg`` count 3 :84.
_FLAT_COUNTS: dict[str, tuple[int, str]] = {
    "nnreg": (3, "read_b2fgmtry.m:84"),
    "parg": (100, "read_b2fgmtry.m:90"),
}


class B2fgmtryFormatError(ValueError):
    """Raised when a b2fgmtry file does not match the reference format."""


@dataclass
class B2fgmtry:
    """A fully parsed b2fgmtry file: VERSION line plus every cf record.

    ``fields`` maps record name -> value in file order: np.ndarray for
    int/real records (gridded names already reshaped per the record
    map, count-1 scalars as 0-d arrays), ``str`` for char records.
    MATLAB-index convention: ``fields["crx"][ix+2, iy+2, k]`` is Fortran
    corner k of cell (ix, iy), ix in -1..nx, iy in -1..ny
    (read_b2fgmtry.m:33 with the +2 guard offset).
    """

    #: 10-char version stamp, MATLAB ``line(8:17)`` (read_b2fgmtry.m:20-21).
    version: str
    #: character*32 git description after the version (cfverw,
    #: b2mod_version.F:52-67), blank-padded; ``None`` when all blanks.
    git_hash: str | None
    #: Interior grid dimensions (record 1, read_b2fgmtry.m:28-30).
    nx: int
    ny: int
    #: Every cf record, in file order — including the six MATLAB skips.
    fields: dict[str, np.ndarray | str] = field(default_factory=dict)

    #: Creation-provenance char record (b2agdr.F:332-338,732); skipped by
    #: MATLAB.  ``None`` on files that predate it.
    label: str | None = None
    isymm: int | None = None
    nlreg: int | None = None
    nncut: int | None = None
    periodic_bc: int | None = None
    #: !=0 => read wbbl as authoritative instead of re-interpolating
    #: (b2rugm.F:341-343,435); version-gated >= 03.000.007 (b2wugm.F:480-482).
    redef_gmtry: int | None = None

    @property
    def grid_shape(self) -> tuple[int, int]:
        """Guard-cell box every gridded record is stored over."""
        return (self.nx + 2, self.ny + 2)

    @property
    def n2(self) -> int:
        """Elements per guard-cell plane, (nx+2)*(ny+2) — 3496 on ITER_2275."""
        gx, gy = self.grid_shape
        return gx * gy

    def keys(self) -> list[str]:
        """Record names in file order."""
        return list(self.fields)

    def __contains__(self, name: str) -> bool:
        return name in self.fields

    def __getitem__(self, name: str) -> np.ndarray | str:
        """``gmtry['crx']`` -> record value; KeyError lists available names."""
        try:
            return self.fields[name]
        except KeyError:
            raise KeyError(
                f"no b2fgmtry record {name!r}; available: {self.keys()}"
            ) from None


def read_b2fgmtry(path: str | Path) -> B2fgmtry:
    """Parse a complete b2fgmtry file (VERSION line + all cf records)."""
    with open(path, encoding="latin-1") as fh:
        return _read_stream(fh)


def _read_stream(fh: TextIO) -> B2fgmtry:
    version, git_hash = _read_version_line(fh)

    # All records are read sequentially to EOF — the writer's fixed call
    # order (b2wugm.F:422-490) minus version-gated optionals; unknown names
    # are kept as flat vectors rather than guessed at.
    raw: list[tuple[str, str, int, object]] = []
    while True:
        line = fh.readline()
        if not line:
            break
        if not line.strip():
            continue
        raw.append(_read_record(fh, line))

    # Record 1 must be the dims pair — both the writer (b2agdr.F:728-731)
    # and MATLAB's first read (read_b2fgmtry.m:28) put it first, and every
    # grid shape below is derived from it.
    if not raw or raw[0][0] != "nx,ny":
        names = [r[0] for r in raw]
        raise B2fgmtryFormatError(
            f"first cf record must be 'nx,ny' (b2agdr.F:728-731), "
            f"got {names[:3]!r}"
        )
    dims = raw[0][3]
    if not (isinstance(dims, np.ndarray) and dims.size == 2):
        raise B2fgmtryFormatError(
            f"record 'nx,ny' must carry 2 integers, got {dims!r}"
        )
    nx, ny = (int(v) for v in dims)

    gmtry = _shape_records(raw, nx, ny)
    return B2fgmtry(
        version=version,
        git_hash=git_hash,
        nx=nx,
        ny=ny,
        fields=gmtry,
        label=gmtry.get("label") if isinstance(gmtry.get("label"), str)
        else None,
        isymm=_scalar(gmtry, "isymm"),
        nlreg=_scalar(gmtry, "nlreg"),
        nncut=_scalar(gmtry, "nncut"),
        periodic_bc=_scalar(gmtry, "periodic_bc"),
        redef_gmtry=_scalar(gmtry, "redef_gmtry"),
    )


def _read_version_line(
    fh: TextIO,
    *,
    family: str = "b2fgmtry",
    error: type[ValueError] = B2fgmtryFormatError,
) -> tuple[str, str | None]:
    """Line 1: ``VERSION`` + 10-char version + 1 blank + character*32 hash.

    Written ``'(a,a,1x,a)'`` by cfverw (b2mod_version.F:52-67); MATLAB takes
    the version from chars 8:17 without validating the label
    (read_b2fgmtry.m:20-21, read_b2fstate.m:25-26), the Fortran reader
    requires ``label == VERSION`` (cfverr, b2mod_version.F:31-44).  solps_reader
    follows the Fortran check — the label-less fallback (version
    ``00.000.000``, every gate closed) has no sample file, so it is an
    error rather than a guess. Shared by the b2fstate reader;
    ``family``/``error`` parameterize the message and exception type.
    """
    line = fh.readline()
    if len(line.rstrip("\n")) < 17 or not line.startswith("VERSION"):
        raise error(
            f"{family} line 1 must be 'VERSION' + version stamp, got {line!r}"
        )
    version = line[7:17]
    if not re.fullmatch(r"\d{2}\.\d{3}\.\d{3}", version):
        # The stamps are zero-padded NN.NNN.NNN — lexicographic version
        # gates only stay sound in that form (see the format dictionary, "Version
        # gates"); anything else is not a stamp any reader knows.
        raise error(
            f"{family} version stamp must be NN.NNN.NNN, got {version!r}"
        )
    git_hash = line[17:].strip() or None
    return version, git_hash


def _read_record(
    fh: TextIO,
    header_line: str,
    *,
    error: type[ValueError] = B2fgmtryFormatError,
) -> tuple[str, str, int, object]:
    """Read one cf record; returns ``(name, type, count, value)``.

    Header names are matched exactly (cfrure.F:31-33) — never by substring
    search, which collides on this very file (``bb`` inside ``wbbl``,
    ``gs`` inside ``cflags``; documented ambiguity). Values are
    read token-wise across line breaks exactly like MATLAB's ``fscanf``
    (read_rfield.m:28, read_ifield.m:28); the per-line counts (6 reals /
    12 ints) are layout only. Shared by the b2fstate reader;
    ``error`` parameterizes the exception type raised.
    """
    m = _HEADER_RE.match(header_line.rstrip("\n"))
    if m is None or m.group("magic").rstrip() != "*cf:":
        raise error(
            f"expected a '*cf:' record header, got {header_line!r}"
        )
    rtype = m.group("type").rstrip()
    if rtype not in _RECORD_TYPES:
        raise error(
            f"cf record type must be one of {sorted(_RECORD_TYPES)}, "
            f"got {rtype!r}"
        )
    name = m.group("name").rstrip()
    if not name:
        raise error(f"cf record header has no name: {header_line!r}")
    try:
        count = int(m.group("count"))
    except ValueError as exc:
        raise error(
            f"cf record {name!r}: header count is not an integer "
            f"({m.group('count')!r})"
        ) from exc

    if count == 0:
        # cfwure.F:31-33 guards the data write with `if (0.lt.n)` — count-0
        # records are a bare header, no data lines follow (real file: the
        # five nl-r records when nlreg=0).
        return name, rtype, 0, np.empty(0, dtype=np.int32 if rtype == "int"
                                        else np.float64)
    if rtype == "char":
        # cfwuch.F:30-32: one line, layout `1x` + the string; count is the
        # character length, not a number of lines.
        line = fh.readline()
        if not line:
            raise error(f"cf record {name!r}: EOF before char data")
        return name, rtype, count, line.rstrip("\n")[1:].rstrip()
    if rtype == "int":
        values = _read_values(fh, count, name, int, np.int32, error=error)
    else:
        values = _read_values(fh, count, name, float, np.float64, error=error)
    return name, rtype, count, values


def _read_values(
    fh: TextIO,
    count: int,
    name: str,
    convert,
    dtype,
    *,
    error: type[ValueError] = B2fgmtryFormatError,
) -> np.ndarray:
    """Collect ``count`` numeric values for one record, fscanf-style."""
    values: list = []
    while len(values) < count:
        line = fh.readline()
        if not line:
            raise error(
                f"cf record {name!r}: EOF after {len(values)} of {count} values"
            )
        tokens = line.split()
        if not tokens:
            continue
        if tokens[0].startswith("*cf:"):
            # A record header where data belonged — the record was truncated
            # (cfrure.F:28-35 would read past it in Fortran and fail the
            # count check).
            raise error(
                f"cf record {name!r}: found only {len(values)} of {count} "
                f"values before the next record header"
            )
        try:
            parsed = [convert(t) for t in tokens]
        except ValueError as exc:
            raise error(
                f"cf record {name!r}: non-numeric data {tokens!r}"
            ) from exc
        # fscanf stops mid-line once n values are in; readline consumed the
        # rest of the line, which is where the next record header would be.
        values.extend(parsed[: count - len(values)])
    return np.asarray(values, dtype=dtype)


def _shape_records(
    raw: list[tuple[str, str, int, object]], nx: int, ny: int
) -> dict[str, np.ndarray | str]:
    """Apply the record map: reshape gridded records, validate counts.

    Count validation mirrors the ``numin ~= prod(dims)`` check of
    read_ifield.m:20-25 / read_rfield.m:20-25 — a declared count that
    disagrees with the reader's dims is the same inconsistency MATLAB
    raises on.  Unknown record names keep their flat file shape; nothing
    speculative is shaped for them.
    """
    gx, gy = nx + 2, ny + 2
    n2 = gx * gy
    out: dict[str, np.ndarray | str] = {}
    nlreg = nncut = None
    for name, rtype, count, value in raw:
        if name in out:
            raise B2fgmtryFormatError(
                f"duplicate cf record name {name!r} — every name occurs in "
                f"exactly one header in a well-formed file"
            )
        if name in ("nlreg", "nncut") and isinstance(value, np.ndarray):
            # Needed to size the nlx*/nly*/nlloc and *cut records below.
            nlreg, nncut = (
                (int(value.reshape(-1)[0]), nncut)
                if name == "nlreg"
                else (nlreg, int(value.reshape(-1)[0]))
            )
        if isinstance(value, str) or not isinstance(value, np.ndarray):
            out[name] = value
            continue
        arr: np.ndarray = value

        expected: int | None = None
        cite = ""
        k = _GRID_K.get(name)
        if name == "qc":
            # qc's layer count is version-gated in the readers (>= 01.001.022
            # b2rugm.F:267; the 3-D >= 03.001.000 branch of
            # read_b2fgmtry.m:34-36 has no producer in the tree) — solps_reader
            # sizes it from the record count instead of guessing at gates
            # (a documented ambiguity, "3-D qc variant").
            if count % n2:
                raise B2fgmtryFormatError(
                    f"cf record {name!r}: declared count {count} is not a "
                    f"multiple of the guard-cell plane n2 = {n2}"
                )
            k = count // n2
        elif k is not None:
            expected = n2 * k
            cite = "read_b2fgmtry.m dims (see _GRID_K)"
        elif name in _FLAT_COUNTS:
            expected, cite = _FLAT_COUNTS[name]
        elif name in ("nlxlo", "nlxhi", "nlylo", "nlyhi", "nlloc"):
            expected, cite = nlreg, "read_b2fgmtry.m:62-66 (nlreg-scaled)"
        elif name in ("leftcut", "rightcut", "topcut", "bottomcut"):
            expected, cite = nncut, "read_b2fgmtry.m:69-72 (nncut-scaled)"

        if expected is not None and count != expected:
            raise B2fgmtryFormatError(
                f"cf record {name!r}: declared count {count} != expected "
                f"{expected} ({cite})"
            )

        if k is not None:
            shape = (gx, gy) if k == 1 else (gx, gy, k)
            out[name] = arr.reshape(shape, order="F")
        elif count == 1:
            out[name] = arr.reshape(())
        else:
            out[name] = arr
    return out


def _scalar(gmtry: dict[str, np.ndarray | str], name: str) -> int | None:
    """Pull a count-1 int record out as a Python int (``None`` if absent)."""
    value = gmtry.get(name)
    if isinstance(value, np.ndarray):
        return int(value)
    return None
