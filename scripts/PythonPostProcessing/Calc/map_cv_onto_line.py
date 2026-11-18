import numpy as np
from .intersects import intersects

def map_cv_onto_line(gmtry, cv_list, segm, ifssep):
    """
    Map control volumes onto a line segment.

    Parameters
    ----------
    gmtry : object
        Geometry structure
    cv_list : array-like
        List of control volume indices (0-based)
    segm : 2x2 array-like
        [[x1, x2],
         [y1, y2]]
    ifssep : int
        Flux surface index (0-based)

    Returns
    -------
    xm, ym : numpy.ndarray
        Midpoints of intersections for each cv
    xs, ys : float
        Intersection point on separatrix (NaN if not found)
    """

    cv_list = np.asarray(cv_list)
    xm = np.zeros(len(cv_list), dtype=float)
    ym = np.zeros(len(cv_list), dtype=float)

    xs = np.nan
    ys = np.nan

    # Separatrix faces
    start = gmtry.fsFcP[ifssep, 0]
    count = gmtry.fsFcP[ifssep, 1]
    sep_faces = gmtry.fsFc[start:start + count]

    # Line equation y = m x + b
    x1, x2 = segm[0][0], segm[0][1]
    y1, y2 = segm[1][0], segm[1][1]

    if x2 != x1:
        m = (y2 - y1) / (x2 - x1)
        b = -m * x1 + y1
    else:
        m = np.inf
        b = None

    p1 = [x1, y1]
    p2 = [x2, y2]

    for ii, cv in enumerate(cv_list):

        start = gmtry.cvFcP[cv, 0]
        count = gmtry.cvFcP[cv, 1]

        xp = []
        yp = []

        for idx in range(start, start + count):
            fc = gmtry.cvFc[idx]

            vx1 = gmtry.fcVx[fc, 0]
            vx2 = gmtry.fcVx[fc, 1]

            q1 = [gmtry.vxX[vx1], gmtry.vxY[vx1]]
            q2 = [gmtry.vxX[vx2], gmtry.vxY[vx2]]

            if intersects(p1, p2, q1, q2):

                # Face line equation
                if q2[0] != q1[0]:
                    mm = (q2[1] - q1[1]) / (q2[0] - q1[0])
                    bb = -mm * q1[0] + q1[1]
                else:
                    mm = np.inf
                    bb = None

                # Intersection
                if np.isinf(mm):  # vertical face
                    xi = q1[0]
                    yi = m * xi + b if not np.isinf(m) else np.nan

                elif np.isinf(m):  # vertical segment
                    xi = p1[0]
                    yi = mm * xi + bb

                else:
                    xi = (b - bb) / (mm - m)
                    yi = mm * xi + bb

                xp.append(xi)
                yp.append(yi)

                if fc in sep_faces:
                    xs = xi
                    ys = yi

        if len(xp) > 2:
            raise ValueError("Found Cv with more than 2 faces intersecting line!")

        if len(xp) > 0:
            xm[ii] = np.sum(xp) / len(xp)
            ym[ii] = np.sum(yp) / len(yp)

    return xm, ym, xs, ys
