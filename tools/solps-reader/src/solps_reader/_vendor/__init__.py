"""Vendored third-party code.

Currently hosts ``pupynere`` (pure-Python NetCDF-3 reader/writer), vendored
from the SOLPS-ITER distribution under the EUPL v. 1.1 and ported to
Python 3.14 + numpy 2.5.  All changes relative to the vendored source are
documented in ``PATCHES.md`` at the repository root.
"""

from solps_reader._vendor.pupynere import NetCDFFile, NetCDFVariable, netcdf_file, netcdf_variable

__all__ = ["NetCDFFile", "NetCDFVariable", "netcdf_file", "netcdf_variable"]
