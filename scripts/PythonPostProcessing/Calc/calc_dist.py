import numpy as np

def calc_dist(geo, clist, nc, iref):
    """
    Compute cumulative Euclidean distance between consecutive cell centers.

    Parameters
    ----------
    geo : object
        Geometry structure with arrays cvX and cvY
    clist : array-like
        List of cell indices (0-based)
    nc : int
        Number of cells
    iref : int
        Reference index (1-based to match MATLAB behavior)

    Returns
    -------
    ds : numpy.ndarray
        Relative cumulative distances (length nc)
    """

    ds = np.zeros(nc, dtype=float)

    # Cumulative distance
    for iCv in range(1, nc):
        dx = geo.cvX[clist[iCv]] - geo.cvX[clist[iCv - 1]]
        dy = geo.cvY[clist[iCv]] - geo.cvY[clist[iCv - 1]]
        ds[iCv] = ds[iCv - 1] + np.sqrt(dx**2 + dy**2)

    # Reference point handling (MATLAB-style indexing for iref)
    if iref == 1:
        dsref = ds[0]
    elif iref > nc:
        raise ValueError("iref out of bounds")
    else:
        # Convert MATLAB index to Python index
        idx = iref - 1
        dsref = (ds[idx] + ds[idx - 1]) / 2.0

    # Subtract reference
    ds = ds - dsref

    return ds
