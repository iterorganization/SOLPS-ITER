"""Reader for ``fort.46`` — EIRENE triangle-mesh tallies for B2.5 (ASCII).

Format authority is the MATLAB reference reader
``scripts/MatlabPostProcessing/IO/read_ft46.m``; every rule below cites its
line numbers.  The producing side is EIRENE's writer
``modules/Eirene/src/interfaces/couple_SOLPS-ITER/eirmod_extrab25.F90``
(fort.46 section, :563-573), cited where it clarifies the MATLAB reader.

The header and field blocks follow the same
self-labeled ``*eirene data field`` layout as fort.44, read through the very
same ``read_ft44_rfield`` helper in MATLAB (read_ft46.m:54-72).

solps_reader stores **raw EIRENE units** — MATLAB multiplies SI factors in after
reading (×1e6 → m⁻³, ×1e6·eV → J m⁻³, ×1e1 → kg s⁻¹ m⁻²; read_ft46.m:50,
:54-72), solps_reader does not; convert downstream if SI is wanted.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import TextIO

import numpy as np

from .ft44 import TITLED_MIN_VERSION, _FIELD_TITLE_RE

#: Versions the MATLAB reference reader accepts (read_ft46.m:25-27).  Unlike
#: fort.44 — where the real file outdates the MATLAB check — the real
#: ITER_2275 ``fort.46`` stamps ``20170930``, inside this set, so solps_reader
#: accepts exactly the same three.  (The reader's own header comment still
#: says "only version 20160513 recognized", read_ft46.m:6 — stale; the code
#: check at :25 is authoritative.)
SUPPORTED_VERSIONS = frozenset({20160513, 20160829, 20170930})


class Ft46FormatError(ValueError):
    """Raised when a fort.46 file does not match the reference format."""


@dataclass
class Ft46Header:
    """Provenance header of a fort.46 file (everything before field blocks)."""

    #: Number of triangles of the EIRENE production mesh (read_ft46.m:22).
    ntri: int
    version: int
    #: EIRENE git hash from the tail of line 1 — read_ft46.m:29-30 skips it
    #: unread ("a possible git-hash"); the writer always writes it
    #: (eirmod_extrab25.F90:564).  ``None`` on files predating it.
    git_hash: str | None
    natm: int
    nmol: int
    nion: int
    species_atoms: list[str]
    species_molecules: list[str]
    species_ions: list[str]

    @property
    def species(self) -> list[str]:
        """All species labels in file order: atoms, molecules, ions."""
        return [*self.species_atoms, *self.species_molecules, *self.species_ions]


def read_header(fh: TextIO) -> Ft46Header:
    """Parse the fort.46 header from an open text file.

    Consumes the dimension line, the species-count line and the
    ``natm + nmol + nion`` species-label lines; on return ``fh`` is
    positioned at the first field-block title so callers can continue
    reading data (read_ft46.m:22-48 -> :54).
    """
    # Line 1: "ntri version [git-hash]" — read_ft46.m:22-23 reads the two
    # integers, :25-27 checks the version, :29-30 fgetls past the rest of the
    # line, which the writer fills with the EIRENE git hash padded to 40
    # chars (eirmod_extrab25.F90:564, format (i6,2x,i8,2x,a40)).
    tokens = fh.readline().split()
    if len(tokens) < 2:
        raise Ft46FormatError(
            f"fort.46 line 1 must start with 'ntri version', got {tokens!r}"
        )
    try:
        ntri, version = (int(t) for t in tokens[:2])
    except ValueError as exc:
        raise Ft46FormatError(
            f"fort.46 line 1 must start with two integers, got {tokens!r}"
        ) from exc
    if version not in SUPPORTED_VERSIONS:
        raise Ft46FormatError(
            f"unknown fort.46 format version {version} "
            f"(supported: {sorted(SUPPORTED_VERSIONS)})"
        )
    git_hash = tokens[2] if len(tokens) > 2 else None

    # Line 2: "natm nmol nion" — read_ft46.m:33-36 reads the three integers
    # and :39 fgetls the rest of the line unread.  The writer emits exactly
    # three, no nfla append (eirmod_extrab25.F90:565, (i4,2x,i4,2x,i4));
    # unlike fort.44 no version ever adds a fourth integer, so any extra
    # token has no defined meaning and is discarded, as MATLAB discards it.
    tokens = fh.readline().split()
    if len(tokens) < 3:
        raise Ft46FormatError(
            f"fort.46 line 2 must start with 'natm nmol nion', got {tokens!r}"
        )
    try:
        natm, nmol, nion = (int(t) for t in tokens[:3])
    except ValueError as exc:
        raise Ft46FormatError(
            f"fort.46 line 2 must start with three integers, got {tokens!r}"
        ) from exc

    # Species labels: natm atom lines, then nmol molecule lines, then nion
    # ion lines.  MATLAB skips these unread (read_ft46.m:38-48, "for now,
    # ignore reading species labels"); the writer emits them exactly like
    # fort.44's — list-directed character*8 output, one leading blank and
    # 8-char padding (eirmod_extrab25.F90:566-573).
    species_atoms = _read_labels(fh, natm, "atom")
    species_molecules = _read_labels(fh, nmol, "molecule")
    species_ions = _read_labels(fh, nion, "ion")

    return Ft46Header(
        ntri=ntri,
        version=version,
        git_hash=git_hash,
        natm=natm,
        nmol=nmol,
        nion=nion,
        species_atoms=species_atoms,
        species_molecules=species_molecules,
        species_ions=species_ions,
    )


def _read_labels(fh: TextIO, count: int, kind: str) -> list[str]:
    """Read ``count`` species-label lines, stripped of padding."""
    labels = []
    for _ in range(count):
        line = fh.readline()
        if not line:
            raise Ft46FormatError(f"EOF while reading {kind} species label")
        labels.append(line.strip())
    return labels


def read_ft46_header(path: str | Path) -> Ft46Header:
    """Open ``path`` and return its parsed fort.46 header."""
    with open(path, encoding="latin-1") as fh:
        return read_header(fh)


# --------------------------------------------------------------------------
# Field blocks
# --------------------------------------------------------------------------

#: The 15 species-class fields MATLAB reads, each with the species class its
#: block is sized against — the ``[ntri, n<species-class>]`` dims pairs of
#: read_ft46.m:54-72.  The trailing per-triangle blocks (``volumes``, ``pux``,
#: ``puy``, ``pvx``, ``pvy`` — writer eirmod_extrab25.F90:686-695) carry no
#: species dimension and are not listed; they stay flat.
SPECIES_FIELD_CLASSES = {
    "pdena": "natm",   # read_ft46.m:54
    "pdenm": "nmol",   # read_ft46.m:55
    "pdeni": "nion",   # read_ft46.m:56
    "edena": "natm",   # read_ft46.m:58
    "edenm": "nmol",   # read_ft46.m:59
    "edeni": "nion",   # read_ft46.m:60
    "vxdena": "natm",  # read_ft46.m:62
    "vxdenm": "nmol",  # read_ft46.m:63
    "vxdeni": "nion",  # read_ft46.m:64
    "vydena": "natm",  # read_ft46.m:66
    "vydenm": "nmol",  # read_ft46.m:67
    "vydeni": "nion",  # read_ft46.m:68
    "vzdena": "natm",  # read_ft46.m:70
    "vzdenm": "nmol",  # read_ft46.m:71
    "vzdeni": "nion",  # read_ft46.m:72
}

#: Block order for version < 20160829 files, which carry no
#: ``*eirene data field`` titles: read_ft44_rfield.m:11-13 skips the label
#: search for those versions, so — exactly as for fort.44 — the
#: reference reader's hardcoded call order (read_ft46.m:54-72) is the only
#: definition of the layout.  Sizes come from the header species counts.
LEGACY_FIELD_SEQUENCE = tuple(SPECIES_FIELD_CLASSES.items())


@dataclass
class Ft46Field:
    """One ``*eirene data field`` block.

    ``data`` is shaped per the reference reader: species-class blocks become
    ``(ntri, n<species-class>)`` (the ``dims`` MATLAB passes and reshapes to,
    read_ft46.m:54-72 + read_ft44_rfield.m:33-34); everything else — the
    trailing per-triangle blocks and ``(not computed)`` variants (one
    species-1 row, writer eirmod_extrab25.F90:580-581) — stays the flat
    ``(size,)`` vector.  F-order reshape matches the writer's species-major
    write loops (e.g. ``((PDENA(i,j),j=1,ntrii),i=1,natmi)``,
    eirmod_extrab25.F90:578): ``data[:, s]`` is species ``s+1``'s
    per-triangle values.
    """

    #: Verbatim name from the title line (may contain spaces, e.g.
    #: ``pdena (not computed)``).
    name: str
    #: Unique access key: ``name``, or ``name_2``, ``name_3``, ... for exact
    #: repeats, in file order (same convention as fort.44 ).
    key: str
    #: Declared element count from the title line.
    size: int
    data: np.ndarray


@dataclass
class Ft46:
    """A fully parsed fort.46 file: header plus every field block."""

    header: Ft46Header
    #: All field blocks in file order — to EOF, including the blocks
    #: read_ft46.m stops before (volumes/pux/puy/pvx/pvy).
    fields: list[Ft46Field]

    def keys(self) -> list[str]:
        """Unique field keys in file order."""
        return [f.key for f in self.fields]

    def field(self, key: str) -> Ft46Field:
        """Return the field stored under ``key``.

        Raises ``KeyError`` listing the available keys on a miss.
        """
        for f in self.fields:
            if f.key == key:
                return f
        raise KeyError(f"no fort.46 field {key!r}; available: {self.keys()}")

    def __getitem__(self, key: str) -> np.ndarray:
        """``ft46['pdena']`` -> field data array."""
        return self.field(key).data


def read_fields(fh: TextIO, header: Ft46Header) -> list[Ft46Field]:
    """Read every field block, version-dispatched.

    Version >= 20160829 (read_ft44_rfield.m:13): blocks are self-labeled —
    scan ``*eirene data field`` titles to EOF.  Version 20160513 (the only
    accepted version below that gate): no titles; blocks are consumed blind
    in the fixed order of read_ft46.m:54-72, sized ``ntri*n<species-class>``
    from the header counts.
    """
    if header.version >= TITLED_MIN_VERSION:
        return _read_titled_fields(fh, header)
    return _read_legacy_fields(fh, header)


def _read_titled_fields(fh: TextIO, header: Ft46Header) -> list[Ft46Field]:
    """Read self-labeled blocks until EOF.

    Mirrors the MATLAB reference reader: blocks are located by scanning for
    ``*eirene data field`` title lines (read_ft44_rfield.m:14-21) and values
    are read token-wise across line breaks exactly like ``fscanf(fid,'%e',n)``
    (read_ft44_rfield.m:32) in the ``'(1p,6e15.7)'`` layout — 6 per line,
    7 decimals (eirmod_extrab25.F90:578 et al.).  Unlike MATLAB — which
    fcloses after 15 blocks (read_ft46.m:77) — the scan continues to EOF so
    the trailing per-triangle blocks are exposed too.
    """
    fields: list[Ft46Field] = []
    seen: dict[str, int] = {}
    while True:
        line = fh.readline()
        if not line:
            break  # EOF — blocks run to end of file
        m = _FIELD_TITLE_RE.match(line.strip())
        if m is None:
            continue
        name = m.group(1)
        size = int(m.group(2))
        values = _read_block_values(fh, size, name)
        data = _reshape(values, header, name)
        seen[name] = seen.get(name, 0) + 1
        key = name if seen[name] == 1 else f"{name}_{seen[name]}"
        fields.append(Ft46Field(name=name, key=key, size=size, data=data))
    return fields


def _read_legacy_fields(fh: TextIO, header: Ft46Header) -> list[Ft46Field]:
    """Read untitled back-to-back blocks for version 20160513.

    Without labels there is nothing to scan for, so the layout comes from the
    reference reader's own call sequence: read_ft46.m:54-72 consumes exactly
    these 15 species-class blocks, each read blind as ``prod(dims)`` values
    (read_ft44_rfield.m:31-32, the label search of :13-29 being skipped) and
    reshaped to ``dims`` unconditionally (:33-34).  MATLAB stops there
    (read_ft46.m:77 fcloses); whether 20160513-era writers also emitted the
    trailing per-triangle blocks is an OPEN QUESTION —
    nothing after the 15th block is read, mirroring the reader.
    """
    counts = {"natm": header.natm, "nmol": header.nmol, "nion": header.nion}
    fields: list[Ft46Field] = []
    for name, sclass in LEGACY_FIELD_SEQUENCE:
        size = header.ntri * counts[sclass]
        values = _read_block_values(fh, size, name)
        fields.append(
            Ft46Field(name=name, key=name, size=size,
                      data=_reshape(values, header, name))
        )
    return fields


def _read_block_values(fh: TextIO, count: int, name: str) -> list[float]:
    """Collect ``count`` floats for one block, fscanf-``%e`` style."""
    values: list[float] = []
    while len(values) < count:
        line = fh.readline()
        if not line:
            raise Ft46FormatError(
                f"fort.46 field {name!r}: EOF after {len(values)} of "
                f"{count} values"
            )
        if _FIELD_TITLE_RE.match(line.strip()) is not None:
            # Next block started before this one was complete — the size
            # check read_ft44_rfield.m:26-27 fails in MATLAB the same way.
            raise Ft46FormatError(
                f"fort.46 field {name!r}: found only {len(values)} of "
                f"{count} values before the next block title"
            )
        tokens = line.split()
        try:
            parsed = [float(t) for t in tokens]
        except ValueError:
            continue  # non-numeric line — skipped
        if not parsed:
            continue  # blank line
        # fscanf stops mid-line once n values are in; the remainder of the
        # line is then consumed by the next fgetl — readline already did that.
        values.extend(parsed[: count - len(values)])
    return values


def _reshape(values: list[float], header: Ft46Header, name: str) -> np.ndarray:
    """Shape one block's values per the reference reader's dims.

    Species-class blocks: MATLAB checks ``numin == prod(dims)`` and reshapes
    to ``[ntri, n<species-class>]`` (read_ft44_rfield.m:26-27,33-34 with the
    dims of read_ft46.m:54-72) — a declared size that disagrees is the same
    inconsistency MATLAB raises on.  All other names (trailing per-triangle
    blocks, ``(not computed)`` variants, unknowns) carry no MATLAB dims and
    stay flat; no second dimension is invented for them.
    """
    arr = np.asarray(values, dtype=np.float64)
    sclass = SPECIES_FIELD_CLASSES.get(name)
    if sclass is None:
        return arr
    nclass = getattr(header, sclass)
    if arr.size != header.ntri * nclass:
        raise Ft46FormatError(
            f"fort.46 field {name!r}: declared size {arr.size} != "
            f"ntri*{sclass} = {header.ntri * nclass} "
            f"(read_ft44_rfield.m:26-27 consistency check)"
        )
    return arr.reshape((header.ntri, nclass), order="F")


def read_ft46(path: str | Path) -> Ft46:
    """Parse a complete fort.46 file (header + all field blocks)."""
    with open(path, encoding="latin-1") as fh:
        header = read_header(fh)
        fields = read_fields(fh, header)
    return Ft46(header=header, fields=fields)
