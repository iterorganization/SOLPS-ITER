import numpy as np

def find_flux_surfaces(gmtry, icv):
    """
    Find flux surface indices connected to a given control volume.

    Parameters
    ----------
    gmtry : object
        Geometry structure containing:
        cvFc, cvFcP, fsFc, fsFcP, nFs
    icv : int
        Control volume index (0-based)

    Returns
    -------
    ifs : numpy.ndarray
        Unique flux surface indices (0-based)
    """

    # Faces connected to control volume icv
    start = gmtry.cvFcP[icv, 0]
    count = gmtry.cvFcP[icv, 1]
    faces = gmtry.cvFc[start:start + count]

    ifs = []

    for face in faces:
        # Find index in fsFc list
        iss = np.where(gmtry.fsFc == face)[0]

        if iss.size > 0:
            iss = iss[0]  # take first match

            # Loop over flux surfaces
            for js in range(gmtry.nFs):
                is1 = gmtry.fsFcP[js, 0]
                is2 = is1 + gmtry.fsFcP[js, 1] - 1

                if is1 <= iss <= is2:
                    ifs.append(js)
                    break

    return np.unique(np.array(ifs, dtype=int))
