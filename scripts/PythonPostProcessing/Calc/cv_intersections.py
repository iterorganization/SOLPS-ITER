import numpy as np
from .intersects import intersects

def cv_intersections(segm, gmtry, meth=None):
    """
    Find control volumes (cv) and faces (fc) intersected by a segment.

    Parameters
    ----------
    segm : 2x2 array-like
        Segment endpoints: [[x1, x2],
                            [y1, y2]]
    gmtry : object
        Geometry structure containing required arrays
    meth : str, optional
        Sorting method: 'X' or 'Y'

    Returns
    -------
    listcv : numpy array
    listfc : numpy array
    nn     : int (number of intersections)
    """

    if meth is None:
        meth = ""

    nn = 0
    listcv = []
    listfc = []

    p1 = [segm[0][0], segm[1][0]]
    q1 = [segm[0][1], segm[1][1]]

    for ifc in range(gmtry.nFc):  # Python 0-based

        vx1 = gmtry.fcVx[ifc, 0]
        vx2 = gmtry.fcVx[ifc, 1]

        p2 = [gmtry.vxX[vx1], gmtry.vxY[vx1]]
        q2 = [gmtry.vxX[vx2], gmtry.vxY[vx2]]

        if intersects(p1, q1, p2, q2):

            for ii in range(2):
                cv = gmtry.fcCv[ifc, ii]

                if cv not in listcv:
                    listcv.append(cv)
                    listfc.append(ifc)
                    nn += 1

    listcv = np.array(listcv, dtype=int)
    listfc = np.array(listfc, dtype=int)

    # Sorting
    if meth == 'X':
        order = np.argsort(gmtry.cvX[listcv])
        listcv = listcv[order]
        listfc = listfc[order]

    elif meth == 'Y':
        order = np.argsort(gmtry.cvY[listcv])
        listcv = listcv[order]
        listfc = listfc[order]

    return listcv, listfc, nn
