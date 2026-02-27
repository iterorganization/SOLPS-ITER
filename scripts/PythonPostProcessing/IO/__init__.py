"""
PythonPostProcessing.IO module

Provides utilities to read B2.5 b2f* files, replacing the MATLAB IO routines.
"""

from .read_ifield import read_ifield
from .read_rfield import read_rfield
from .write_ifield import write_ifield
from .write_rfield import write_rfield
from .write_sfield import write_sfield
from .read_b2fgmtry_us import read_b2fgmtry_us
from .write_b2fgmtry_us import write_b2fgmtry_us
from .read_structure import read_structure
from .read_traduit_b2us import read_traduitoutb2us
from .read_b2fplasmf_us import read_b2fplasmf_us
from .read_b2fstate import read_b2fstate

__all__ = [
    "read_ifield",
    "read_rfield",
    "write_ifield",
    "write_rfield",
    "write_sfield",
    "read_b2fgmtry_us",
    "write_b2fgmtry_us",
    "read_structure",
    "read_traduitoutb2us",
    "read_b2fplasmf_us",
    "read_b2fstate"
]
