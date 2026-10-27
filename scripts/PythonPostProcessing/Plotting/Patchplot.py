import numpy as np
import matplotlib.pyplot as plt
from matplotlib.collections import PolyCollection
from ..Calc.isplasmagrid import isplasmagrid
from ..Calc.isunstructuredgrid import isunstructuredgrid
from ..Calc.istrianglegrid import istrianglegrid


def Patchplot(gmtry, field, scale=1.0, fmin=None, fmax=None, cmap='viridis', edgecolor='k'):
    """
    Patchplot of cell-centered quantity for SOLPS-ITER grids.

    Parameters
    ----------
    gmtry : object or dict
        Geometry object returned by read_b2fgmtry or read_b2fgmtry_us.
    field : array-like
        Cell-centered field to plot.
    scale : float, optional
        Scale factor for field values. Default is 1.
    fmin : float, optional
        Minimum contour value. Default is min(field/scale)
    fmax : float, optional
        Maximum contour value. Default is max(field/scale)

    Returns
    -------
    poly : matplotlib.collections.PolyCollection
        Collection of patches for plotting.
    """
    field = np.asarray(field).reshape(-1) / scale

    if fmin is None:
        fmin = field.min()
    if fmax is None:
        fmax = field.max()
    if fmin > fmax:
        raise ValueError("Patchplot: fmin > fmax")

    # Crop field
    field = np.clip(field, fmin, fmax)

    polygons = []
    colors = []

    # --- Structured plasma grid ---
    if isplasmagrid(gmtry):
        nx2, ny2 = gmtry.crx.shape[:2]
        X = gmtry.crx.reshape(-1, 4).T.copy()
        Y = gmtry.cry.reshape(-1, 4).T.copy()
        F = field.reshape(-1)

        # Make closed polygons
        X[2:4, :] = X[3:1:-1, :]
        Y[2:4, :] = Y[3:1:-1, :]

        # Remove guard cells if cflags exist
        if hasattr(gmtry, 'cflags') and gmtry.cflags.size > 0:
            mask = gmtry.cflags[:, :, 0].flatten() != 9
            X = X[:, mask]
            Y = Y[:, mask]
            F = F[mask]

        for i in range(X.shape[1]):
            poly = np.column_stack((X[:, i], Y[:, i]))
            polygons.append(poly)
            colors.append(F[i])

    # --- Unstructured grid ---
    elif isunstructuredgrid(gmtry):
        for iCv, cv in enumerate(gmtry.cvVol):
            nverts = gmtry.cvVxP[iCv, 1]
            start = gmtry.cvVxP[iCv, 0]
            vertices = [ (gmtry.vxX[gmtry.cvVx[start + j]], gmtry.vxY[gmtry.cvVx[start + j]]) 
                         for j in range(nverts) ]
            # Close polygon
            vertices.append(vertices[0])
            polygons.append(np.array(vertices))
            colors.append(field[iCv] if len(field) != gmtry.nVx else None)

    # --- Triangle grid ---
    elif istrianglegrid(gmtry):
        for tri in gmtry.cells:
            vertices = np.array([[gmtry.nodes[i,0], gmtry.nodes[i,1]] for i in tri])
            polygons.append(vertices)
            colors.append(field[0])  # assuming one value per triangle?

    else:
        raise ValueError("Patchplot: wrong gmtry structure")

    fig = plt.gcf()
    ax = plt.gca()
    poly_collection = PolyCollection(polygons, array=np.array(colors), cmap=cmap, edgecolors=edgecolor)
    poly_collection.set_clim(fmin, fmax)
    ax.add_collection(poly_collection)
    ax.autoscale_view()
    #plt.colorbar(poly_collection)
    return poly_collection
