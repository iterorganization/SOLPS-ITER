import numpy as np
from .read_ifield import read_ifield
from .read_rfield import read_rfield


class Gmtry:
    """Container for B2.5 unstructured grid geometry data."""
    pass


def read_b2fgmtry_us(file):
    """
    Read b2fgmtry file for unstructured grid (US) from B2.5.

    Parameters
    ----------
    file : str
        Path to the b2fgmtry US file.

    Returns
    -------
    gmtry : Gmtry
        Object containing unstructured grid geometry information.
    """

    gmtry = Gmtry()

    # Open file
    try:
        fid = open(file, "r")
    except OSError as e:
        raise RuntimeError(f"Failed to open {file}: {e}")

    # Get version
    line = fid.readline()
    version = line[7:17]
    print(f"read_b2fgmtry_us -- file version {version}")

    # Read dimensions
    dim = read_ifield(fid, "nCi,nCg,nCv,nFc,nVx,nFs,nFt", (7,))
    nCi, nCg, nCv, nFc, nVx, nFs, nFt = dim

    dim = read_ifield(fid, "nCmxVx,nCmxFc,nVmxCv,nVmxFc,nCmx", (5,))
    nCmxVx, nCmxFc, nVmxCv, nVmxFc, nCmxNv = dim

    gmtry.nCi = nCi
    gmtry.nCg = nCg
    gmtry.nCv = nCv
    gmtry.nFc = nFc
    gmtry.nVx = nVx
    gmtry.nFs = nFs
    gmtry.nFt = nFt

    gmtry.nCmxVx = nCmxVx
    gmtry.nCmxFc = nCmxFc
    gmtry.nVmxCv = nVmxCv
    gmtry.nVmxFc = nVmxFc
    gmtry.nCmxNv = nCmxNv

    # Structured grid info
    gmtry.isClassicalGrid = read_ifield(fid, "isClassicalGrid", (1,))[0]
    nx, ny, nncut = read_ifield(fid, "nx,ny,nncut", (3,))
    gmtry.nx = nx
    gmtry.ny = ny
    gmtry.nncut = nncut

    # Symmetry
    gmtry.isymm = read_ifield(fid, "isymm", (1,))[0]

    # Mapping
    gmtry.cvFcP = read_ifield(fid, "cvFcP", (nCv, 2))
    gmtry.cvFc  = read_ifield(fid, "cvFc", (nCmxFc,))
    gmtry.fcCv  = read_ifield(fid, "fcCv", (nFc, 2))
    gmtry.fcVx  = read_ifield(fid, "fcVx", (nFc, 2))
    gmtry.cvVxP = read_ifield(fid, "cvVxP", (nCv, 2))
    gmtry.cvVx  = read_ifield(fid, "cvVx", (nCmxVx,))
    gmtry.vxFcP = read_ifield(fid, "vxFcP", (nVx, 2))
    gmtry.vxFc  = read_ifield(fid, "vxFc", (nVmxFc,))
    gmtry.vxCvP = read_ifield(fid, "vxCvP", (nVx, 2))
    gmtry.vxCv  = read_ifield(fid, "vxCv", (nVmxCv,))
    gmtry.ftCvP = read_ifield(fid, "ftCvP", (nFt, 2))
    gmtry.ftCv  = read_ifield(fid, "ftCv", (nCv,))
    gmtry.ftFcP = read_ifield(fid, "ftFcP", (nFt, 2))
    gmtry.ftFc  = read_ifield(fid, "ftFc", (nFc,))
    gmtry.cvFt  = read_ifield(fid, "cvFt", (nCv,))
    gmtry.fsFcP = read_ifield(fid, "fsFcP", (nFs, 2))
    gmtry.fsFc  = read_ifield(fid, "fsFc", (nFc,))
    gmtry.fcReg = read_ifield(fid, "fcReg", (nFc,))
    gmtry.cvReg = read_ifield(fid, "cvReg", (nCv,))
    gmtry.ftReg = read_ifield(fid, "ftReg", (nFt,))
    gmtry.intcellP = read_rfield(fid, "intcellP", (nCmxFc,))
    gmtry.intcellR = read_rfield(fid, "intcellR", (nCmxFc,))

    # Classical grid mappings
    if gmtry.isClassicalGrid == 1:
        gmtry.imapCv  = read_ifield(fid, "imapCv", (nx+2, ny+2))
        gmtry.imapFcx = read_ifield(fid, "imapFcx", (nx+2, ny+2))
        gmtry.imapFcy = read_ifield(fid, "imapFcy", (nx+2, ny+2))
        gmtry.imapVx  = read_ifield(fid, "imapVx", (nx+2, ny+2))
        gmtry.icornVx = read_ifield(fid, "icornVx", (nx,))
    else:
        gmtry.imapCv  = np.array([])
        gmtry.imapFcx = np.array([])
        gmtry.imapFcy = np.array([])
        gmtry.imapVx  = np.array([])
        gmtry.icornVx = np.array([])

    # Labels
    gmtry.fcLbl = read_ifield(fid, "fcLbl", (nFc,))
    gmtry.cvLbl = read_ifield(fid, "cvLbl", (nCv,))
    gmtry.ftLbl = read_ifield(fid, "ftLbl", (nFt,))

    # Cell volumes
    gmtry.cvBb   = read_rfield(fid, "cvBb",  (nCv, 4))
    gmtry.cvEb   = read_rfield(fid, "cvEb",  (nCv, 3))
    gmtry.cvX    = read_rfield(fid, "cvX",   (nCv,))
    gmtry.cvY    = read_rfield(fid, "cvY",   (nCv,))
    gmtry.cvSz   = read_rfield(fid, "cvSz",  (nCv,))
    gmtry.cvHz   = read_rfield(fid, "cvHz",  (nCv,))
    gmtry.cvHx   = read_rfield(fid, "cvHx",  (nCv,))
    gmtry.cvQgam = read_rfield(fid, "cvQgam",(nCv, 2))
    gmtry.cvVol  = read_rfield(fid, "cvVol", (nCv,))

    # Face quantities
    gmtry.fcBb   = read_rfield(fid, "fcBb",  (nFc, 4))
    gmtry.fcS    = read_rfield(fid, "fcS",   (nFc,))
    gmtry.fcHc   = read_rfield(fid, "fcHc",  (nFc, 2))
    gmtry.fcHt   = read_rfield(fid, "fcHt",  (nFc,))
    gmtry.fcQgam = read_rfield(fid, "fcQgam",(nFc, 2))
    gmtry.fcQalf = read_rfield(fid, "fcQalf",(nFc, 2))
    gmtry.fcQbet = read_rfield(fid, "fcQbet",(nFc, 2))
    gmtry.fcPbs  = read_rfield(fid, "fcPbs", (nFc,))

    # Vertex quantities
    gmtry.vxBb   = read_rfield(fid, "vxBb",  (nVx, 4))
    gmtry.vxX    = read_rfield(fid, "vxX",   (nVx,))
    gmtry.vxY    = read_rfield(fid, "vxY",   (nVx,))
    gmtry.vxFfbz = read_rfield(fid, "vxFfbz",(nVx,))
    gmtry.vxFpsi = read_rfield(fid, "vxFpsi",(nVx,))

    # Flux surface quantities
    gmtry.cvConn = read_rfield(fid, "cvConn", (nCv,))
    gmtry.fsPsi  = read_rfield(fid, "fsPsi",  (nFs,))

    # Convert MATLAB 1-based indices to Python 0-based
    # Pointer arrays (cvVxP) → need correction
    # Connectivity arrays (cvVx) → already 0-based
    # Adjust true index arrays
    index_arrays = [
        'cvFc', 'fcCv', 'fcVx', 'cvVx',
        'vxFc', 'vxCv', 'ftCv', 'ftFc',
        'cvFt', 'fsFc'
    ]
    if gmtry.isClassicalGrid == 1:
        index_arrays.extend(['imapCv','imapFcx','imapFcy','imapVx'])


    for arr in index_arrays:
        if hasattr(gmtry, arr):
            setattr(gmtry, arr, np.asarray(getattr(gmtry, arr), dtype=int) - 1)

    # Adjust pointer arrays (only first column!)
    pointer_arrays = [
        'cvFcP', 'cvVxP', 'vxFcP', 'vxCvP',
        'ftCvP', 'ftFcP', 'fsFcP'
    ]

    for arr in pointer_arrays:
        if hasattr(gmtry, arr):
            value = np.asarray(getattr(gmtry, arr), dtype=int)
            value[:, 0] -= 1   # only start pointer
            setattr(gmtry, arr, value)

    fid.close()
    return gmtry
