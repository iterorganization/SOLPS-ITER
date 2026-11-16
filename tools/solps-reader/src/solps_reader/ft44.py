"""Reader for ``fort.44`` — EIRENE → B2.5 source-term exchange file (ASCII).

Format authority is the MATLAB reference reader
``scripts/MatlabPostProcessing/IO/read_ft44.m``; every rule below cites its
line numbers.  The producing side is EIRENE's writer
``modules/Eirene/src/interfaces/couple_SOLPS-ITER/eirmod_extrab25.F90``
(cited where it clarifies the MATLAB reader).
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import TextIO

import numpy as np

#: Versions the MATLAB reference reader accepts (read_ft44.m:39) plus
#: ``20240627`` — the version stamp of the real ITER_2275 ``fort.44``.  The
#: MATLAB check predates that stamp (the writer has emitted ``jvft44 >=
#: 20240311`` headers for years; eirmod_extrab25.F90:149 writes whatever
#: ``jvft44`` the build carries), so solps_reader accepts the union.
SUPPORTED_VERSIONS = frozenset({20081111, 20160829, 20170328, 20240627})

#: First ``fort.44`` version whose species-count line carries a fourth
#: integer ``nfla`` (eirmod_extrab25.F90:150-154); older writers emit only
#: ``natm nmol nion`` (read_ft44.m:47 reads three either way).
NFLA_MIN_VERSION = 20240311

#: First version whose field blocks carry ``*eirene data field`` titles;
#: older files hold the data blocks back-to-back with no labels
#: (read_ft44_rfield.m:11-13: "Version 20160829: field label and size are
#: specified in fort.44" — the label search and size check of :14-28 run
#: only for ``ver >= 20160829``).
TITLED_MIN_VERSION = 20160829


class Ft44FormatError(ValueError):
    """Raised when a fort.44 file does not match the reference format."""


@dataclass
class Ft44Header:
    """Provenance header of a fort.44 file (everything before field blocks)."""

    nx: int
    ny: int
    version: int
    git_hash: str | None
    natm: int
    nmol: int
    nion: int
    #: Fourth integer on the species-count line, present for
    #: version >= 20240311 (eirmod_extrab25.F90:151).  ``None`` on old files.
    nfla: int | None
    species_atoms: list[str]
    species_molecules: list[str]
    species_ions: list[str]

    @property
    def species(self) -> list[str]:
        """All species labels in file order: atoms, molecules, ions."""
        return [*self.species_atoms, *self.species_molecules, *self.species_ions]


def read_header(fh: TextIO) -> Ft44Header:
    """Parse the fort.44 header from an open text file.

    Consumes the two dimension lines and the ``natm + nmol + nion`` species
    label lines; on return ``fh`` is positioned at the first field-block
    title so callers can continue reading data (read_ft44.m:34-62).
    """
    # Line 1: "nx ny version [git-hash]" — read_ft44.m:34-37 reads the three
    # integers and read_ft44.m:43-44 skips the rest of the line, which the
    # writer fills with the EIRENE git hash padded to 40 chars
    # (eirmod_extrab25.F90:149).
    tokens = fh.readline().split()
    if len(tokens) < 3:
        raise Ft44FormatError(
            f"fort.44 line 1 must start with 'nx ny version', got {tokens!r}"
        )
    try:
        nx, ny, version = (int(t) for t in tokens[:3])
    except ValueError as exc:
        raise Ft44FormatError(
            f"fort.44 line 1 must start with three integers, got {tokens!r}"
        ) from exc
    if version not in SUPPORTED_VERSIONS:
        raise Ft44FormatError(
            f"unknown fort.44 format version {version} "
            f"(supported: {sorted(SUPPORTED_VERSIONS)})"
        )
    git_hash = tokens[3] if len(tokens) > 3 else None

    # Line 2: "natm nmol nion [nfla]" — read_ft44.m:47-50 reads the first
    # three; the writer appends nfla from version 20240311 on
    # (eirmod_extrab25.F90:150-154).
    tokens = fh.readline().split()
    if len(tokens) < 3:
        raise Ft44FormatError(
            f"fort.44 line 2 must start with 'natm nmol nion', got {tokens!r}"
        )
    try:
        natm, nmol, nion = (int(t) for t in tokens[:3])
        extra = [int(t) for t in tokens[3:]]
    except ValueError as exc:
        raise Ft44FormatError(
            f"fort.44 line 2 must contain integers, got {tokens!r}"
        ) from exc
    if version >= NFLA_MIN_VERSION and not extra:
        # Not fatal — read_ft44.m ignores the tail of the line (line 53) —
        # but record it, since nfla shapes the wall section in later blocks.
        nfla = None
    else:
        nfla = extra[0] if extra else None

    # Species labels: natm atom lines, then nmol molecule lines, then nion
    # ion lines (read_ft44.m:53-62; writer eirmod_extrab25.F90:155-163).
    species_atoms = _read_labels(fh, natm, "atom")
    species_molecules = _read_labels(fh, nmol, "molecule")
    species_ions = _read_labels(fh, nion, "ion")

    return Ft44Header(
        nx=nx,
        ny=ny,
        version=version,
        git_hash=git_hash,
        natm=natm,
        nmol=nmol,
        nion=nion,
        nfla=nfla,
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
            raise Ft44FormatError(f"EOF while reading {kind} species label")
        labels.append(line.strip())
    return labels


def read_ft44_header(path: str | Path) -> Ft44Header:
    """Open ``path`` and return its parsed fort.44 header."""
    with open(path, encoding="latin-1") as fh:
        return read_header(fh)


# --------------------------------------------------------------------------
# Field blocks
# --------------------------------------------------------------------------

#: Self-labeling block title, e.g. ``*eirene data field dab2 with size   3240``
#: (writer format ``'(3a,i6)'`` — eirmod_extrab25.F90:2151-2152).  The name
#: may itself contain spaces (``wldnek(  1)``), so it is taken verbatim
#: between ``field`` and ``with size``; the size is the trailing integer the
#: MATLAB consistency check compares against ``prod(dims)``
#: (read_ft44_rfield.m:25-28).
_FIELD_TITLE_RE = re.compile(
    r"^\*eirene\s+data\s+field\s+(.+?)\s+with\s+size\s+(\d+)\s*$"
)


@dataclass
class Ft44Field:
    """One ``*eirene data field`` block.

    ``data`` is Fortran/column-major reshaped (MATLAB ``reshape`` semantics,
    read_ft44_rfield.m:33-34): ``(nx, ny)`` when ``size == nx*ny``, generally
    ``(nx, ny, k)`` when ``size`` is a multiple of ``nx*ny``, otherwise the
    flat ``(size,)`` vector (wall tallies etc.).
    """

    #: Verbatim name from the title line (may contain spaces / ``(N)`` parts).
    name: str
    #: Unique access key: ``name``, or ``name_2``, ``name_3``, ... for exact
    #: repeats, in file order.
    key: str
    #: Declared element count from the title line.
    size: int
    data: np.ndarray
    #: Non-numeric sub-lines found inside the block, verbatim tokens joined
    #: The writer emits one per species row inside ``wlabsrp`` /
    #: ``wlpump`` / ``wlpump_res`` blocks — the ``line = fgetl(fid)`` calls of
    #: read_ft44.m:155-165 — while MATLAB's ``%e`` scanning silently steps
    #: over them.
    labels: list[str] = field(default_factory=list)


@dataclass
class Ft44:
    """A fully parsed fort.44 file: header plus every field block."""

    header: Ft44Header
    #: All field blocks in file order.
    fields: list[Ft44Field]
    #: Wall/stratum section grouped per the commented reference spec
    #: or ``None`` when the file carries no wall section
    #: (legacy < 20160829 files, wall-less synthetic fixtures).
    wall: Ft44Wall | None = None

    def keys(self) -> list[str]:
        """Unique field keys in file order."""
        return [f.key for f in self.fields]

    def field(self, key: str) -> Ft44Field:
        """Return the field stored under ``key``.

        Raises ``KeyError`` listing the available keys on a miss (reused by
        the CLI export).
        """
        for f in self.fields:
            if f.key == key:
                return f
        raise KeyError(f"no fort.44 field {key!r}; available: {self.keys()}")

    def __getitem__(self, key: str) -> np.ndarray:
        """``ft44['dab2']`` -> field data array."""
        return self.field(key).data


#: Field sequence the MATLAB reference reader consumes for version
#: < 20160829 files.  Old files carry no ``*eirene data field`` titles —
#: read_ft44_rfield.m:11-13 skips the label search entirely for
#: ``ver < 20160829`` and reads ``prod(dims)`` values blind — so the reader's
#: hardcoded call order (read_ft44.m:67-80, one call per block) is the ONLY
#: definition of the layout.  Each entry is ``(name, species-class)``; the
#: block size is ``nx*ny*n<species-class>`` from the header.
LEGACY_FIELD_SEQUENCE = (
    ("dab2", "natm"),      # read_ft44.m:67
    ("tab2", "natm"),      # read_ft44.m:68
    ("dmb2", "nmol"),      # read_ft44.m:69
    ("tmb2", "nmol"),      # read_ft44.m:70
    ("dib2", "nion"),      # read_ft44.m:71
    ("tib2", "nion"),      # read_ft44.m:72
    ("rfluxa", "natm"),    # read_ft44.m:73
    ("rfluxm", "nmol"),    # read_ft44.m:74
    ("pfluxa", "natm"),    # read_ft44.m:75
    ("pfluxm", "nmol"),    # read_ft44.m:76
    ("refluxa", "natm"),   # read_ft44.m:77
    ("refluxm", "nmol"),   # read_ft44.m:78
    ("pefluxa", "natm"),   # read_ft44.m:79
    ("pefluxm", "nmol"),   # read_ft44.m:80
)


def read_fields(fh: TextIO, header: Ft44Header) -> list[Ft44Field]:
    """Read every field block, version-dispatched.

    Version >= 20160829 (read_ft44_rfield.m:13): blocks are self-labeled —
    scan ``*eirene data field`` titles to EOF.  Version < 20160829
    (read_ft44_rfield.m:11-13): no titles exist; the blocks are consumed in
    the fixed hardcoded order of read_ft44.m:67-80, sized
    ``nx*ny*n<species-class>`` from the header counts.
    """
    return read_fields_and_wall_dims(fh, header)[0]


def read_fields_and_wall_dims(
    fh: TextIO, header: Ft44Header
) -> tuple[list[Ft44Field], tuple[int, int, int] | None]:
    """Like :func:`read_fields` but also returns the wall-dims line.

    Returns ``(fields, wall_dims)`` where ``wall_dims`` is ``(nlim, nsts,
    nstra)`` from the intermediate dims line between the grid and wall
    sections, or ``None`` for files without a wall section.
    """
    if header.version >= TITLED_MIN_VERSION:
        return _read_titled_fields(fh, header)
    return _read_legacy_fields(fh, header), None


#: The intermediate dims line is written ``'(3i6)'`` — three bare integers
#: (eirmod_extrab25.F90:218), read as ``fscanf(fid,'%d',3)`` by the commented
#: reference spec (read_ft44.m:90-93).  Between-block data lines never carry
#: exactly three bare integers (every float layout keeps its ``.``/``E``;
#: integer records use 12 or 18 per line), so this identifies it exactly.
_WALL_DIMS_TOKENS = 3


def _read_titled_fields(
    fh: TextIO, header: Ft44Header
) -> tuple[list[Ft44Field], tuple[int, int, int] | None]:
    """Read self-labeled blocks until EOF; also capture the wall-dims line.

    Mirrors the MATLAB reference reader: blocks are located by scanning for
    ``*eirene data field`` title lines (read_ft44_rfield.m:14-21), each
    block's element count is checked against the declared size
    (read_ft44_rfield.m:26-27), and values are read token-wise across line
    breaks exactly like ``fscanf(fid,'%e',n)`` (read_ft44_rfield.m:32).
    Non-numeric lines — the wall-dimension line ``nlim nsts nstra``
    (eirmod_extrab25.F90:218) and the per-species sub-labels inside
    ``wlabsrp`` blocks (eirmod_extrab25.F90:312, read_ft44.m:154-165) — are
    stepped over the way ``%e`` scanning does, but unlike MATLAB solps_reader
    records them: the dims line as ``wall_dims``, block-internal
    label lines as :attr:`Ft44Field.labels`.
    """
    fields: list[Ft44Field] = []
    wall_dims: tuple[int, int, int] | None = None
    seen: dict[str, int] = {}
    while True:
        line = fh.readline()
        if not line:
            break  # EOF — blocks run to end of file (read_ft44.m:67-201)
        m = _FIELD_TITLE_RE.match(line.strip())
        if m is not None:
            name = m.group(1)
            size = int(m.group(2))
            labels: list[str] = []
            values = _read_block_values(fh, size, name, labels)
            data = _reshape(values, header, name)
            seen[name] = seen.get(name, 0) + 1
            key = name if seen[name] == 1 else f"{name}_{seen[name]}"
            fields.append(
                Ft44Field(name=name, key=key, size=size, data=data, labels=labels)
            )
            continue
        dims = _match_wall_dims(line)
        if dims is not None:
            if wall_dims is not None:
                raise Ft44FormatError(
                    "fort.44 carries more than one wall-dims line "
                    f"(first {wall_dims}, then {dims})"
                )
            wall_dims = dims
    return fields, wall_dims


def _match_wall_dims(line: str) -> tuple[int, int, int] | None:
    """Return ``(nlim, nsts, nstra)`` if ``line`` is the wall-dims record."""
    tokens = line.split()
    if len(tokens) != _WALL_DIMS_TOKENS:
        return None
    try:
        dims = tuple(int(t) for t in tokens)
    except ValueError:
        return None
    if any(d < 0 for d in dims):
        return None
    return dims  # type: ignore[return-value]


def _read_legacy_fields(fh: TextIO, header: Ft44Header) -> list[Ft44Field]:
    """Read untitled back-to-back blocks for version < 20160829.

    Without labels there is nothing to scan for, so the layout comes from the
    reference reader's own call sequence: read_ft44.m:67-80 consumes exactly
    these 14 grid fields, each read blind as ``prod(dims)`` values
    (read_ft44_rfield.m:31-32, the label search of :13-29 being skipped).
    Anything after the 14th block is not read — read_ft44.m:203 simply
    fcloses there; the untitled trailing section of real old files is an
    OPEN QUESTION, never guessed at.
    """
    counts = {"natm": header.natm, "nmol": header.nmol, "nion": header.nion}
    fields: list[Ft44Field] = []
    for name, sclass in LEGACY_FIELD_SEQUENCE:
        size = header.nx * header.ny * counts[sclass]
        values = _read_block_values(fh, size, name)
        fields.append(
            Ft44Field(name=name, key=name, size=size,
                      data=_reshape(values, header, name))
        )
    return fields


def _read_block_values(
    fh: TextIO, count: int, name: str, labels: list[str] | None = None
) -> list[float]:
    """Collect ``count`` floats for one block, fscanf-``%e`` style.

    Non-numeric non-blank lines are stepped over like MATLAB ``%e`` scanning;
    when ``labels`` is given they are recorded there verbatim — the
    writer's species sub-labels inside ``wlabsrp``/``wlpump`` blocks
    (eirmod_extrab25.F90:312, the ``line = fgetl(fid)`` calls of
    read_ft44.m:155-165).
    """
    values: list[float] = []
    while len(values) < count:
        line = fh.readline()
        if not line:
            raise Ft44FormatError(
                f"fort.44 field {name!r}: EOF after {len(values)} of "
                f"{count} values"
            )
        if _FIELD_TITLE_RE.match(line.strip()) is not None:
            # Next block started before this one was complete — the size
            # check read_ft44_rfield.m:26-27 fails in MATLAB the same way.
            raise Ft44FormatError(
                f"fort.44 field {name!r}: found only {len(values)} of "
                f"{count} values before the next block title"
            )
        tokens = line.split()
        try:
            parsed = [float(t) for t in tokens]
        except ValueError:
            # Non-numeric line (species sub-labels etc.) — stepped over by
            # MATLAB's %e scan, recorded for the wall grouping when asked.
            # One '(6a13)' record holds up to six labels (eirmod_extrab25.F90
            # :312), so tokens are recorded individually; species labels
            # never contain spaces.
            if tokens and labels is not None:
                labels.extend(tokens)
            continue
        if not parsed:
            continue  # blank line
        # fscanf stops mid-line once n values are in; the remainder of the
        # line is then consumed by the next fgetl — readline already did that.
        values.extend(parsed[: count - len(values)])
    return values


def _reshape(values: list[float], header: Ft44Header, name: str) -> np.ndarray:
    """Column-major reshape, mirroring ``reshape(field,dims)`` in MATLAB."""
    arr = np.asarray(values, dtype=np.float64)
    ngrid = header.nx * header.ny
    if arr.size % ngrid == 0:
        k = arr.size // ngrid
        shape = (header.nx, header.ny) if k == 1 else (header.nx, header.ny, k)
        return arr.reshape(shape, order="F")
    return arr


def read_ft44(path: str | Path) -> Ft44:
    """Parse a complete fort.44 file (header + all field blocks + wall)."""
    with open(path, encoding="latin-1") as fh:
        header = read_header(fh)
        fields, wall_dims = read_fields_and_wall_dims(fh, header)
    wall = build_wall(header, fields, wall_dims) if wall_dims else None
    return Ft44(header=header, fields=fields, wall=wall)


# --------------------------------------------------------------------------
# Wall / stratum section
# --------------------------------------------------------------------------

#: Stratum-suffixed wall title, e.g. ``wldnek(0)``, ``wldnek(  1)`` — the
#: index is embedded with Fortran ``(i3)`` padding (eirmod_extrab25.F90:242
#: builds ``stnum`` with ``'(i3)'``).  Index 0 is the total over all strata
#: (written from the full tally before the strata loop, writer :219 vs
#: :241-258); 1..nstra are the per-stratum tallies.
_WALL_STRATUM_RE = re.compile(r"^(?P<base>[a-z_]+)\(\s*(?P<k>\d+)\s*\)$")


def _normalize_wall_name(name: str) -> str:
    """Collapse ``(N)`` padding: ``wldnek(  1)`` -> ``wldnek(1)``."""
    m = _WALL_STRATUM_RE.match(name)
    if m is None:
        return name
    return f"{m.group('base')}({int(m.group('k'))})"


#: Species-class count behind each strata-stacked wall tally.  ``None`` =
#: one value per wall element (no species axis).  Shapes follow the
#: commented reference spec (read_ft44.m:95-148) and the writer's `neutrs`
#: calls, which flatten with the wall index innermost and the species index
#: outermost (eirmod_extrab25.F90:882-895) — i.e. MATLAB
#: ``reshape(field, [nlim+nsts, nsp])`` column-major per stratum.
_WALL_STRATUM_SPECIES = {
    "wldnek": None,   # read_ft44.m:102,116
    "wldnep": None,   # read_ft44.m:103,117
    "wldna": "natm",  # read_ft44.m:104,118
    "ewlda": "natm",  # read_ft44.m:105,119
    "wldnm": "nmol",  # read_ft44.m:106,120
    "ewldm": "nmol",  # read_ft44.m:107,121
    "wldra": "natm",  # read_ft44.m:111 (file carries ALL strata: writer :236,:256)
    "wldrm": "nmol",  # read_ft44.m:112 (writer :238,:258)
    "wldpp": "nfla",  # read_ft44.m:132,140
    "wldpa": "natm",  # read_ft44.m:133,141
    "wldpm": "nmol",  # read_ft44.m:134,142
    "wldpeb": None,   # read_ft44.m:135,143
    "wldspt": None,   # read_ft44.m:136,144
    "wldspta": "natm",  # not in the MATLAB spec; writer :274,:293
    "wldsptm": "nmol",  # not in the MATLAB spec; writer :276,:295
}

#: Flat per-species-class row blocks: ``wlabsrp(A)``..``(P)`` and
#: ``wlpump(A)``..``(P)`` stack into ``(natm+nmol+nion+nfla, ncols)`` — the
#: ``wld.wlabsrp`` matrix of read_ft44.m:154-165, each class block reshaped
#: ``[nsp, nlim+nsts]`` column-major.  The writer flattens with the species
#: index innermost (eirmod_extrab25.F90:313, :334, ...), matching that
#: reshape.  ``wlpump`` (jvft44 >= 20170328, writer :331-352) and the
#: ``wlpump_res`` family (writer :417-426) post-date the MATLAB spec.
_SPECIES_ROW_CLASSES = (("A", "natm"), ("M", "nmol"), ("I", "nion"), ("P", "nfla"))

#: Resolution-field records, shaped per the writer's ``((x(j,i),j=1,nsp),i=1,ncl)``
#: flattening (species innermost -> column-major ``(nsp, ncl)``) — the
#: ``*_res`` group of read_ft44.m:177-185, guarded by ``allocated(wldna_res)``
#: on the writer side (eirmod_extrab25.F90:379-431).
_RES_LAYOUT = {
    "sarea_res": None,     # (ncl,)
    "wldna_res": "natm",   # (natm, ncl)
    "wldnm_res": "nmol",
    "ewlda_res": "natm",
    "ewldm_res": "nmol",
    "ewldea_res": "natm",
    "ewldem_res": "nmol",
    "ewldrp_res": None,
    "ewldmr_res": "nmol",
    "wldspt_res": None,    # writer :408 (jvft44 >= 20170228)
    "wldspta_res": "natm",  # writer :413
    "wldsptm_res": "nmol",  # writer :415
    "ewldt_res": None,     # writer :431 (jvft44 >= 20201006)
}

#: EIRENE strata-integral blocks: size ``(nstra+1) * nsp`` flattened with
#: the species index innermost (eirmod_extrab25.F90:433-458) -> column-major
#: ``(nsp, nstra+1)``.  The commented MATLAB spec reads these as
#: ``[nsp, nstrata]`` (read_ft44.m:187-198) — but ``nstrata`` is undefined
#: there; the writer's axis runs ``J = 0..NSTRAI``, i.e. nstra+1 columns
#: with column 0 the total, exactly like the wall strata.
_INTEGRAL_RE = re.compile(r"^[pe]den(?P<cls>[ami])_int(?:_b2)?$")


@dataclass
class Ft44Wall:
    """fort.44 wall/stratum section, grouped per the reference reader's spec.

    Every array is ``None`` when its blocks are absent from the file (the
    writer gates several groups on ``jvft44`` and on ``allocated(...)``).
    The stratum axis is ``0..nstra`` with ``0`` the total over strata —
    verified on the real file: particle tallies satisfy
    ``x[:, 0] == x[:, 1:].sum(axis=-1)`` to ASCII precision.
    """

    nlim: int
    nsts: int
    nstra: int

    #: Per-stratum wall tallies, shapes as documented per group above.
    wldnek: np.ndarray | None = None   # (nw, nstra+1)
    wldnep: np.ndarray | None = None   # (nw, nstra+1)
    wldna: np.ndarray | None = None    # (nw, natm, nstra+1)
    ewlda: np.ndarray | None = None    # (nw, natm, nstra+1)
    wldnm: np.ndarray | None = None    # (nw, nmol, nstra+1)
    ewldm: np.ndarray | None = None    # (nw, nmol, nstra+1)
    poly: np.ndarray | None = None     # (4, nlim) — wall_geometry
    wldra: np.ndarray | None = None    # (nw, natm, nstra+1)
    wldrm: np.ndarray | None = None    # (nw, nmol, nstra+1)
    wldpp: np.ndarray | None = None    # (nw, nfla, nstra+1)
    wldpa: np.ndarray | None = None    # (nw, natm, nstra+1)
    wldpm: np.ndarray | None = None    # (nw, nmol, nstra+1)
    wldpeb: np.ndarray | None = None   # (nw, nstra+1)
    wldspt: np.ndarray | None = None   # (nw, nstra+1)
    wldspta: np.ndarray | None = None  # (nw, natm, nstra+1)
    wldsptm: np.ndarray | None = None  # (nw, nmol, nstra+1)
    isrftype: np.ndarray | None = None  # (nw,) integers
    wlarea: np.ndarray | None = None   # (nw,)
    #: (natm+nmol+nion+nfla, nw) + one label per row (read_ft44.m:154-165).
    wlabsrp: np.ndarray | None = None
    wlabsrp_labels: list[str] = field(default_factory=list)
    wlpump: np.ndarray | None = None   # same layout as wlabsrp
    wlpump_labels: list[str] = field(default_factory=list)

    #: eirdiag: five integer records concatenated into one block of
    #: ``5*nsts+1`` values (writer :369-373; MATLAB reads them as five
    #: separate ifields, read_ft44.m:169-173).
    eirdiag_ind: np.ndarray | None = None      # (nsts+1,)
    eirdiag_typ: np.ndarray | None = None      # (nsts,)
    eirdiag_srf: np.ndarray | None = None      # (nsts,)
    eirdiag_start: np.ndarray | None = None    # (nsts,)
    eirdiag_end: np.ndarray | None = None      # (nsts,)

    #: Resolution (segment-resolved) records over ``ncl`` cells, ``ncl``
    #: being the last ``eirdiag_ind`` entry (read_ft44.m:175).
    sarea_res: np.ndarray | None = None        # (ncl,)
    wldna_res: np.ndarray | None = None        # (natm, ncl)
    wldnm_res: np.ndarray | None = None        # (nmol, ncl)
    ewlda_res: np.ndarray | None = None        # (natm, ncl)
    ewldm_res: np.ndarray | None = None        # (nmol, ncl)
    ewldea_res: np.ndarray | None = None       # (natm, ncl)
    ewldem_res: np.ndarray | None = None       # (nmol, ncl)
    ewldrp_res: np.ndarray | None = None       # (ncl,)
    ewldmr_res: np.ndarray | None = None       # (nmol, ncl)
    wldspt_res: np.ndarray | None = None       # (ncl,)
    wldspta_res: np.ndarray | None = None      # (natm, ncl)
    wldsptm_res: np.ndarray | None = None      # (nmol, ncl)
    #: (natm+nmol+nion+nfla, ncl) + labels (writer :417-426).
    wlpump_res: np.ndarray | None = None
    wlpump_res_labels: list[str] = field(default_factory=list)
    ewldt_res: np.ndarray | None = None        # (ncl,)

    #: Strata integrals ``pden*_int`` / ``eden*_int`` (``_b2`` variants),
    #: each ``(nsp, nstra+1)`` with column 0 the total (writer :433-458).
    integrals: dict[str, np.ndarray] = field(default_factory=dict)

    @property
    def nw(self) -> int:
        """Wall-element count ``nlim + nsts`` (read_ft44.m:95-100)."""
        return self.nlim + self.nsts

    @property
    def ncl(self) -> int | None:
        """Resolution-cell count = last ``eirdiag_ind`` entry (read_ft44.m:175)."""
        if self.eirdiag_ind is None:
            return None
        return int(self.eirdiag_ind[-1])

    @property
    def strata(self) -> np.ndarray:
        """Stratum axis ``[0, 1, ..., nstra]`` (0 = total over strata)."""
        return np.arange(self.nstra + 1)


def build_wall(
    header: Ft44Header, fields: list[Ft44Field], wall_dims: tuple[int, int, int]
) -> Ft44Wall:
    """Group the wall-section blocks of a fort.44 into an :class:`Ft44Wall`.

    Sizing follows the writer (``eirmod_extrab25.F90:218-458``) cross-checked
    against the commented reference spec (read_ft44.m:87-201); any block that
    disagrees with the declared ``nlim nsts nstra`` raises
    :class:`Ft44FormatError` rather than being reshaped speculatively.
    """
    nlim, nsts, nstra = wall_dims
    nw = nlim + nsts
    nfla = header.nfla if header.nfla is not None else 1  # read_ft44.m:8,18-20
    counts = {"natm": header.natm, "nmol": header.nmol, "nion": header.nion,
              "nfla": nfla}

    index: dict[str, Ft44Field] = {}
    for f in fields:
        key = _normalize_wall_name(f.name)
        if key in index:
            raise Ft44FormatError(
                f"fort.44 wall section: duplicate block {key!r} "
                f"({index[key].name!r} and {f.name!r})"
            )
        index[key] = f

    wall = Ft44Wall(nlim=nlim, nsts=nsts, nstra=nstra)
    found_any = False

    for base, sclass in _WALL_STRATUM_SPECIES.items():
        nsp = 1 if sclass is None else counts[sclass]
        stacked = _stack_strata(index, base, sclass, nsp, nw, nstra)
        setattr(wall, base, stacked)
        found_any |= stacked is not None

    wall.poly = _flat_block(index, "wall_geometry", (4, nlim))
    found_any |= wall.poly is not None
    wall.isrftype = _int_block(index, "isrftype", (nw,))
    found_any |= wall.isrftype is not None
    wall.wlarea = _flat_block(index, "wlarea", (nw,))
    found_any |= wall.wlarea is not None

    wall.wlabsrp, wall.wlabsrp_labels = _species_rows(
        index, header, "wlabsrp", nw, counts
    )
    found_any |= wall.wlabsrp is not None
    wall.wlpump, wall.wlpump_labels = _species_rows(
        index, header, "wlpump", nw, counts
    )
    found_any |= wall.wlpump is not None

    wall.eirdiag_ind, wall.eirdiag_typ, wall.eirdiag_srf, \
        wall.eirdiag_start, wall.eirdiag_end = _eirdiag(index, nsts)
    found_any |= wall.eirdiag_ind is not None

    ncl = wall.ncl
    for name, sclass in _RES_LAYOUT.items():
        nsp = None if sclass is None else counts[sclass]
        block = _res_block(index, name, sclass, nsp, ncl)
        setattr(wall, name, block)
        found_any |= block is not None
    wall.wlpump_res, wall.wlpump_res_labels = (
        _species_rows(index, header, "wlpump_res", ncl, counts)
        if ncl is not None
        else (None, [])
    )
    found_any |= wall.wlpump_res is not None

    for name, f in index.items():
        m = _INTEGRAL_RE.match(name)
        if m is None:
            continue
        nsp = counts[{"a": "natm", "m": "nmol", "i": "nion"}[m.group("cls")]]
        wall.integrals[name] = _shaped(f, (nsp, nstra + 1), name)
        found_any = True

    if not found_any:
        raise Ft44FormatError(
            "fort.44 carries a wall-dims line "
            f"({nlim} {nsts} {nstra}) but no wall-section blocks follow"
        )
    return wall


def _shaped(f: Ft44Field, shape: tuple[int, ...], what: str) -> np.ndarray:
    """Column-major reshape of one block, size-checked against ``shape``."""
    expected = int(np.prod(shape))
    if f.size != expected:
        raise Ft44FormatError(
            f"fort.44 wall section: block {what!r} has {f.size} elements, "
            f"expected {expected} for shape {shape}"
        )
    return f.data.reshape(shape, order="F")


def _stack_strata(
    index: dict[str, Ft44Field],
    base: str,
    sclass: str | None,
    nsp: int,
    nw: int,
    nstra: int,
) -> np.ndarray | None:
    """Stack the ``(k)``-suffixed blocks of one tally along the last axis."""
    blocks = {k: index[f"{base}({k})"] for k in range(nstra + 1)
              if f"{base}({k})" in index}
    if not blocks:
        return None
    # The writer emits the (0) total, then 1..nstra only when nstrai > 1
    # (eirmod_extrab25.F90:219, :241-242) — anything else is a broken set.
    allowed = {0} if nstra == 1 else set(range(nstra + 1))
    if set(blocks) != allowed:
        raise Ft44FormatError(
            f"fort.44 wall section: {base} blocks {sorted(blocks)} do not "
            f"match the expected strata {sorted(allowed)}"
        )
    shape = (nw,) if sclass is None else (nw, nsp)
    columns = [_shaped(blocks[k], shape, f"{base}({k})") for k in sorted(blocks)]
    return np.stack(columns, axis=-1)


def _flat_block(
    index: dict[str, Ft44Field], name: str, shape: tuple[int, ...]
) -> np.ndarray | None:
    f = index.get(name)
    return None if f is None else _shaped(f, shape, name)


def _int_block(
    index: dict[str, Ft44Field], name: str, shape: tuple[int, ...]
) -> np.ndarray | None:
    """Integer record (``read_ft44_ifield``, read_ft44.m:148): cast, checked."""
    f = index.get(name)
    if f is None:
        return None
    arr = _shaped(f, shape, name)
    if not np.all(arr == np.floor(arr)):
        raise Ft44FormatError(
            f"fort.44 wall section: block {name!r} must be integral"
        )
    return arr.astype(np.int64)


def _species_rows(
    index: dict[str, Ft44Field],
    header: Ft44Header,
    prefix: str,
    ncols: int,
    counts: dict[str, int],
) -> tuple[np.ndarray | None, list[str]]:
    """Stack the ``(A)/(M)/(I)/(P)`` class blocks into ``(rows, ncols)``."""
    rows: list[np.ndarray] = []
    labels: list[str] = []
    for letter, sclass in _SPECIES_ROW_CLASSES:
        f = index.get(f"{prefix}({letter})")
        if f is None:
            continue
        nsp = counts[sclass]
        rows.append(_shaped(f, (nsp, ncols), f"{prefix}({letter})"))
        if f.labels and len(f.labels) != nsp:
            raise Ft44FormatError(
                f"fort.44 block {prefix}({letter}) carries {len(f.labels)} "
                f"species labels for {nsp} species rows"
            )
        labels.extend(f.labels)
    if not rows:
        return None, []
    return np.vstack(rows), labels


def _res_block(
    index: dict[str, Ft44Field],
    name: str,
    sclass: str | None,
    nsp: int | None,
    ncl: int | None,
) -> np.ndarray | None:
    f = index.get(name)
    if f is None:
        return None
    if ncl is None:
        raise Ft44FormatError(
            f"fort.44 wall section: block {name!r} needs eirdiag for ncl"
        )
    return _shaped(f, (ncl,) if sclass is None else (nsp, ncl), name)


def _eirdiag(
    index: dict[str, Ft44Field], nsts: int
) -> tuple[np.ndarray | None, np.ndarray | None, np.ndarray | None,
           np.ndarray | None, np.ndarray | None]:
    f = index.get("eirdiag")
    if f is None:
        return None, None, None, None, None
    arr = _shaped(f, (5 * nsts + 1,), "eirdiag")
    if not np.all(arr == np.floor(arr)):
        raise Ft44FormatError("fort.44 wall section: block 'eirdiag' must be integral")
    arr = arr.astype(np.int64)
    ind = arr[: nsts + 1]
    return ind, arr[nsts + 1: 2 * nsts + 1], arr[2 * nsts + 1: 3 * nsts + 1], \
        arr[3 * nsts + 1: 4 * nsts + 1], arr[4 * nsts + 1:]


# --------------------------------------------------------------------------
# Synthetic writer — TEST FIXTURES ONLY
# --------------------------------------------------------------------------

#: Data lines carry five values, each a 15-char ``1pe15.8`` field preceded by
#: one blank — the ``'(1p,5(1x,1e15.8))'`` layout of ``neutrs``
#: (eirmod_extrab25.F90:889-893).  Verified as 80-char lines on the real
#: ITER_2275 file for both grid and wall blocks.
_VALUES_PER_LINE = 5


def quantize_ft44(values) -> np.ndarray:
    """Round ``values`` to the 8 significant digits a fort.44 can carry.

    The ``1pe15.8`` data layout holds one digit before and seven after the
    decimal point (see the real file: ``5.1866228E+018``), so arbitrary
    doubles cannot survive a write→read cycle bit-exactly.  Passing
    :func:`quantize_ft44` output to :func:`write_ft44` makes the round-trip
    exactly equal (the acceptance criterion).
    """
    arr = np.asarray(values, dtype=np.float64)
    return np.array([float(f"{v:.7E}") for v in arr.ravel()]).reshape(arr.shape)


def _validate_legacy_sequence(
    nx: int, ny: int, *, natm: int, nmol: int, nion: int, fields
) -> None:
    """Check ``fields`` matches the untitled read_ft44.m:67-80 layout.

    Version < 20160829 files carry no titles, so the reader can only recover
    the layout from the fixed call sequence — names, order and sizes must all
    agree with ``nx*ny*n<species-class>`` blocks of ``LEGACY_FIELD_SEQUENCE``.
    """
    counts = {"natm": natm, "nmol": nmol, "nion": nion}
    expected = [(name, nx * ny * counts[sclass]) for name, sclass in LEGACY_FIELD_SEQUENCE]
    given = [(name, int(np.asarray(data).size)) for name, data in fields]
    if given != expected:
        raise Ft44FormatError(
            f"version < {TITLED_MIN_VERSION} fort.44 files carry no field "
            f"titles, so fields must match the read_ft44.m:67-80 sequence "
            f"(name, size) exactly; expected {expected}, got {given}"
        )


def _format_value(value: float) -> str:
    """One 15-char Fortran ``1pe15.8`` field, e.g. `` 5.1866228E+018``.

    ``1p`` scaling puts one digit before the decimal (8 significant digits
    total) and the exponent is zero-padded to three digits, matching the
    producing compiler's output byte for byte.
    """
    mantissa, exponent = f"{abs(value):.7E}".split("E")
    return f"{'-' if value < 0 else ' '}{mantissa}E{exponent[0]}{int(exponent[1:]):03d}"


def _format_data_line(values) -> str:
    """One data line: ``1x`` separator before each ``e15.8`` value."""
    return "".join(" " + _format_value(v) for v in values)


def write_ft44(
    path: str | Path,
    *,
    nx: int,
    ny: int,
    version: int,
    species_atoms,
    species_molecules,
    species_ions,
    fields,
    git_hash: str | None = None,
    nfla: int | None = None,
    wall_dims: tuple[int, int, int] | None = None,
) -> None:
    """Write a **synthetic** fort.44 file — test fixtures only.

    solps_reader is a read-only tool for physics output (non-goals); this writer
    exists solely to generate small fixtures so tests do not depend on the
    1.5 MB real file. Never point it at SOLPS-ITER reference data.

    Layout mirrors the EIRENE writer ``eirmod_extrab25.F90`` exactly:

    - line 1 ``(i4,2x,i4,2x,i8,2x,a40)`` — nx, ny, version, git hash padded
      to 40 (:149); the hash is optional, read as a "possible git-hash"
      (read_ft44.m:43-44);
    - line 2 ``(i4,2x,i4,2x,i4)`` with a fourth integer ``nfla`` when
      ``version >= 20240311`` (:150-154);
    - species labels as list-directed ``character*8`` output — one leading
      blank, label padded to 8 (:156-163);
    - per field a title ``'*eirene data field ' + name + ' with size ' + i6``
      (:2147-2153) — **only** for version >= 20160829; older versions carry
      no titles at all (read_ft44_rfield.m:11-13), so for them ``fields``
      must follow the fixed read_ft44.m:67-80 sequence
      (``LEGACY_FIELD_SEQUENCE``) with matching sizes — anything else
      would be unreadable by the reference reader and is rejected;
    - the wall-dims line ``'(3i6)'`` (:218) before the first ``wldnek(0)``
      block when ``wall_dims`` is given — required whenever a
      ``wldnek(0)`` field is present, since the reader keys the whole wall
      section off that line;
    - values flattened column-major (the reader reshapes F-order,
      read_ft44_rfield.m:33-34), five ``1pe15.8`` values per line
      (eirmod_extrab25.F90:889-893).

    ``fields`` is a sequence of ``(name, array)`` pairs, or ``(name, array,
    labels)`` triples whose labels are emitted as one ``(6a13)``-style
    species-label line right after the title (the ``wlabsrp``/``wlpump``
    layout, eirmod_extrab25.F90:312).  ``natm/nmol/nion`` are derived from
    the species-label lists, as in the writer.
    """
    if version not in SUPPORTED_VERSIONS:
        raise Ft44FormatError(
            f"cannot write fort.44 version {version} "
            f"(supported: {sorted(SUPPORTED_VERSIONS)})"
        )

    lines: list[str] = []

    # Line 1 (i4,2x,i4,2x,i8,2x,a40) — eirmod_extrab25.F90:149.
    line1 = f"{nx:4d}  {ny:4d}  {version:8d}"
    if git_hash is not None:
        line1 += f"  {git_hash:<40}"
    lines.append(line1)

    # Line 2 — eirmod_extrab25.F90:150-154.
    counts = f"{len(species_atoms):4d}  {len(species_molecules):4d}  {len(species_ions):4d}"
    if version >= NFLA_MIN_VERSION:
        if nfla is None:
            nfla = 1  # the reference reader assumes 1 (read_ft44.m:8,18-20)
        lines.append(f"{counts}  {nfla:4d}")
    else:
        if nfla is not None:
            raise Ft44FormatError(
                f"version {version} species-count line has no nfla integer "
                f"(only written for version >= {NFLA_MIN_VERSION})"
            )
        lines.append(counts)

    # Species labels — write(44,*) of character*8 → one blank + 8-char pad.
    for label in (*species_atoms, *species_molecules, *species_ions):
        lines.append(f" {label:<8}")

    titled = version >= TITLED_MIN_VERSION
    if not titled:
        # Untitled blocks are parsed by position (read_ft44.m:67-80), so a
        # fixture deviating from that sequence would be unreadable — reject
        # it here rather than emit a broken file.
        if any(len(entry) > 2 for entry in fields):
            raise Ft44FormatError(
                "species-label triples are only writable for titled files "
                f"(version >= {TITLED_MIN_VERSION}); untitled blocks carry "
                "no sub-label records"
            )
        _validate_legacy_sequence(
            nx, ny,
            natm=len(species_atoms),
            nmol=len(species_molecules),
            nion=len(species_ions),
            fields=fields,
        )
    has_wall = any(
        _normalize_wall_name(entry[0]) == "wldnek(0)" for entry in fields
    )
    if has_wall != (wall_dims is not None):
        raise Ft44FormatError(
            "synthetic fort.44 wall section: wall_dims must be given exactly "
            "when a 'wldnek(0)' field is present (the '(3i6)' dims line of "
            "eirmod_extrab25.F90:218 keys the whole wall section)"
        )
    if wall_dims is not None and not titled:
        raise Ft44FormatError(
            "wall sections exist only in titled files (version >= "
            f"{TITLED_MIN_VERSION}); read_ft44.m:87-201 consumes labeled "
            "wall blocks"
        )
    for entry in fields:
        name, data = entry[0], entry[1]
        labels = list(entry[2]) if len(entry) > 2 else []
        arr = np.asarray(data, dtype=np.float64)
        if arr.size and not np.isfinite(arr).all():
            raise Ft44FormatError(
                f"fort.44 field {name!r}: non-finite values cannot be written"
            )
        if titled and wall_dims is not None and _normalize_wall_name(name) == "wldnek(0)":
            # The '(3i6)' wall-dims line precedes the first wall block
            # (eirmod_extrab25.F90:218-219).
            lines.append(f"{wall_dims[0]:6d}{wall_dims[1]:6d}{wall_dims[2]:6d}")
        if titled:
            lines.append(f"*eirene data field {name} with size {arr.size:6d}")
            for i in range(0, len(labels), 6):
                # '(6a13)' species-label records (eirmod_extrab25.F90:312).
                lines.append(
                    "".join(f"{lbl:<13}" for lbl in labels[i : i + 6])
                )
        flat = arr.ravel(order="F")
        for i in range(0, flat.size, _VALUES_PER_LINE):
            lines.append(_format_data_line(flat[i : i + _VALUES_PER_LINE]))

    Path(path).write_text("\n".join(lines) + "\n", encoding="ascii")
