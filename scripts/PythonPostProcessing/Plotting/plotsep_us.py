import numpy as np
import matplotlib.pyplot as plt
from ..Calc.find_flux_surfaces import find_flux_surfaces

def plotsep_us(gmtry, icsep, omp, *args, **kwargs):
    """
    Identify and plot separatrix flux tube.

    Parameters
    ----------
    gmtry : object or dict
        Geometry structure containing required arrays
    icsep : int
        Separatrix index (Python indexing assumed)
    omp : array-like
        OMP array
    *args, **kwargs :
        Passed directly to matplotlib.pyplot.plot
    """

    # Identify separatrix flux tube
    sep1 = find_flux_surfaces(gmtry, omp[icsep])
    sep2 = find_flux_surfaces(gmtry, omp[icsep - 1])
    sep = np.intersect1d(sep1, sep2)

    # MATLAB indexing is 1-based; adjust if data still uses that convention
    start = gmtry.fsFcP[sep, 0]
    count = gmtry.fsFcP[sep, 1]

    for jj in range(count[0]):
        ifc = gmtry.fsFc[start + jj]
        vx1 = gmtry.fcVx[ifc, 0]
        vx2 = gmtry.fcVx[ifc, 1]

        x = [gmtry.vxX[vx1], gmtry.vxX[vx2]]
        y = [gmtry.vxY[vx1], gmtry.vxY[vx2]]

        plt.plot(x, y, *args, **kwargs)

    return sep
