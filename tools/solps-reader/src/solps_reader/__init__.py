"""solps-reader: pure-Python readers & CLI for SOLPS-ITER output files.

Families covered:
- ``fort.44`` / ``fort.46``: B2.5<->EIRENE source-term exchange (ASCII)
- ``b2*.nc``: NetCDF-3 outputs (b2time.nc, b2batch.nc, ...)
- ``b2fstate`` / ``b2fgmtry``: the plasma-state checkpoint and geometry
  (cf-ASCII, not XDR) — fully read, wall sections included
- ``b2fplasma`` / ``b2fplasmf``: the full plasma solution — every final
  profile/source/transport array; binary Fortran records read directly,
  or the formatted twin, auto-detected
"""

__version__ = "1.3.0"
