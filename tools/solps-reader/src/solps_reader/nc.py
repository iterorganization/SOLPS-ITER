"""Uniform read API over the NetCDF-3 ``b2*.nc`` family.

``load_nc(path)`` wraps the vendored pupynere reader
(``solps_reader._vendor.pupynere`` — the documented format authority for
``*.nc``) in the container style of ``Ft44``/``Ft46``:
ordered dimensions, a variable table with metadata, eager in-memory data
arrays.  All line references below are ``src/solps_reader/_vendor/pupynere.py``.

Semantics pinned to the vendored reader:

- Dimension order is file order (``_read_dim_array``, :527-537); the
  unlimited / record dimension surfaces as length ``None`` (:535).
- ``num_records`` is the header numrecs (:524-525) — 1000 on b2time.nc.
- The reader loads every variable eagerly at open (:601-654); solps_reader
  **copies** the arrays, so they are detached from the file/mmap and
  writeable.  Dtypes keep the file's big-endian byte order (``>f8`` etc.)
  exactly as stored — the on-disk representation, not byteswapped.
- String attributes are Fortran blank-padded in the file (e.g.
  ``timesa:units = "s "``); solps_reader ``rstrip()``s them — the same
  convention as the fort.44/46 species labels.  Numeric attributes keep
  the reader's unwrapping of 1-element vectors to scalars (:691).
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

import numpy as np

from ._vendor import NetCDFFile


class NcFormatError(ValueError):
    """Raised when a file is not readable as NetCDF-3 classic."""


@dataclass(frozen=True)
class NcDim:
    """One file dimension; ``length`` ``None`` marks the unlimited one."""

    name: str
    length: int | None


@dataclass
class NcVariable:
    """One NetCDF variable with its metadata and eagerly-read data."""

    name: str
    #: Dimension names in declaration order (pupynere.py:656-669).
    dims: tuple[str, ...]
    dtype: np.dtype
    #: Data shape with the record length filled in (pupynere.py:812-819).
    shape: tuple[int, ...]
    data: np.ndarray
    attributes: dict[str, Any]
    #: Name of the file's unlimited dimension (``None`` if the file has
    #: none) — carried per-variable so ``is_record`` needs no file handle.
    record_dim: str | None

    @property
    def is_record(self) -> bool:
        """True when the first dimension is the unlimited dimension.

        Record variables are stored interleaved per record
        (pupynere.py:580-596); their ``shape[0]`` equals the file's
        numrecs.
        """
        return self.record_dim is not None and self.dims[:1] == (self.record_dim,)

    @property
    def units(self) -> str | None:
        """``units`` attribute (rstripped), or ``None`` if absent."""
        value = self.attributes.get("units")
        return value if isinstance(value, str) else None

    @property
    def long_name(self) -> str | None:
        """``long_name`` attribute (rstripped), or ``None`` if absent."""
        value = self.attributes.get("long_name")
        return value if isinstance(value, str) else None


@dataclass
class NcFile:
    """A parsed ``b2*.nc`` file: dimensions, variables, global attributes."""

    path: Path
    #: File dimensions in file order (pupynere.py:527-537).
    dimensions: list[NcDim]
    #: Variables in file order (pupynere.py:555-654).
    variables: dict[str, NcVariable]
    #: Header numrecs — number of records along the unlimited dimension
    #: (pupynere.py:524-525).
    num_records: int
    attributes: dict[str, Any]

    @property
    def record_dimension(self) -> str | None:
        """Name of the unlimited dimension, or ``None`` if there is none."""
        return next((d.name for d in self.dimensions if d.length is None), None)

    def keys(self) -> list[str]:
        """Variable names in file order."""
        return list(self.variables)

    def variable(self, name: str) -> NcVariable:
        """Return the variable ``name``.

        Raises ``KeyError`` listing the available names on a miss
        (mirrors ``Ft44.field``; reused by the CLI).
        """
        try:
            return self.variables[name]
        except KeyError:
            raise KeyError(
                f"no NetCDF variable {name!r} in {self.path}; "
                f"available: {self.keys()}"
            ) from None

    def __getitem__(self, name: str) -> np.ndarray:
        """``nc['timesa']`` -> the variable's data array."""
        return self.variable(name).data

    def time_traces(self) -> list[str]:
        """Names of 1-D variables spanning the record dimension, file order.

        These are the solver-convergence traces plots (e.g.
        ``timesa``, ``tmne``, ``tmte`` on b2time.nc).  Multi-dimensional
        record variables (``tab3dl(time,natm,nybl)``) and fixed 1-D
        coordinates (``dsi(nyi)``) are excluded by definition: one
        dimension, and it is the unlimited one.
        """
        record = self.record_dimension
        if record is None:
            return []
        return [n for n, v in self.variables.items() if v.dims == (record,)]


def _clean_attributes(raw: dict[str, Any]) -> dict[str, Any]:
    """Normalize attribute values for the solps_reader API.

    Strings (NC_CHAR attributes) carry Fortran blank padding in the file
    (e.g. ``"s "``, ``"  "``) — rstripped here, like the species labels in
    fort.44/46.  numpy scalars from the vendored reader become plain
    Python scalars; anything else (numeric attribute vectors) is kept.
    """
    cleaned: dict[str, Any] = {}
    for key, value in raw.items():
        if isinstance(value, str):
            cleaned[key] = value.rstrip()
        elif isinstance(value, np.generic):
            cleaned[key] = value.item()
        else:
            cleaned[key] = value
    return cleaned


def load_nc(path: str | Path) -> NcFile:
    """Read a NetCDF-3 classic file into an :class:`NcFile`.

    The vendored reader parses and loads everything at open; data arrays
    are copied out (writeable, detached from the file) before the
    underlying file is closed.  A file that is not NetCDF-3 classic (bad
    magic — pupynere.py:510-516 — or a broken header) raises
    :class:`NcFormatError`.
    """
    path = Path(path)
    try:
        f = NetCDFFile(str(path))
    except (TypeError, ValueError, OSError) as exc:
        raise NcFormatError(
            f"{path}: not a readable NetCDF-3 classic file ({exc})"
        ) from exc
    try:
        dimensions = [NcDim(name, length) for name, length in f.dimensions.items()]
        record_dim = next(
            (d.name for d in dimensions if d.length is None), None
        )
        variables = {
            name: NcVariable(
                name=name,
                dims=tuple(var.dimensions),
                dtype=np.dtype(var.dtype),
                shape=tuple(var.shape),
                # copy: detaches from mmap/file so arrays stay valid and
                # writeable after close (mmap data is ACCESS_READ-only)
                data=np.array(var.data, copy=True),
                attributes=_clean_attributes(var._attributes),
                record_dim=record_dim,
            )
            for name, var in f.variables.items()
        }
        return NcFile(
            path=path,
            dimensions=dimensions,
            variables=variables,
            num_records=f._recs,
            attributes=_clean_attributes(f._attributes),
        )
    finally:
        f.close()
