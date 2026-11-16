import numpy as np

def find_cv_faces_fcreg(fcreg, gmtry):
    """
    Find control volumes (cvs) and faces belonging to a given face region.

    Parameters
    ----------
    fcreg : int
        Face region identifier
    gmtry : object
        Geometry structure with arrays:
        fcReg, fcCv, nCi

    Returns
    -------
    cvs : numpy.ndarray
        Control volume indices
    faces : numpy.ndarray
        Face indices
    """

    # Equivalent of MATLAB: find(gmtry.fcReg == fcreg)
    faces = np.where(gmtry.fcReg == fcreg)[0]

    cvs = []

    for iFc in faces:
        ic1 = min(gmtry.fcCv[iFc, 0], gmtry.fcCv[iFc, 1])
        ic2 = max(gmtry.fcCv[iFc, 0], gmtry.fcCv[iFc, 1])

        if ic1 <= gmtry.nCi:
            icc = ic1
        elif ic2 <= gmtry.nCi:
            icc = ic2
        else:
            raise ValueError("Problem with boundary faces")

        cvs.append(icc)

    cvs = np.array(cvs, dtype=int)

    return cvs, faces
