import numpy as np

def boundary_flux_density(gmtry, fcList, flux):
    """
    Compute the flux density normal to the boundary.

    Project the flux vector onto the surface normal pointing
    away from the plasma.

    Positive boundary_flux indicates flux leaving the plasma domain.

    Parameters
    ----------
    gmtry : object
        Geometry object containing:
            fcCv : (n_faces, 2) array of cell indices
            nCi  : number of interior cells
            fcS  : (n_faces,) array of face surface areas

    fcList : array_like
        List of boundary face indices (MATLAB 1-based indexing).

    flux : ndarray
        Flux vector array with shape (n_faces, 2, n_species).

    Returns
    -------
    bFlux : ndarray
        Normal flux density with shape (n_boundary_faces, n_species).
    """
    
    # Determine face orientation
    fcOr = np.zeros(len(fcList))

    for iFc, fc in enumerate(fcList):

        if gmtry.fcCv[fc, 0] > gmtry.nCi:
            fcOr[iFc] = -1

        elif gmtry.fcCv[fc, 1] > gmtry.nCi:
            fcOr[iFc] = 1

        else:
            raise ValueError(f"Face {fc + 1} is not a boundary face!")

    # Calculate normal flux density
    bFlux = np.zeros((len(fcList), flux.shape[2]))

    for is_ in range(flux.shape[2]):
        bFlux[:, is_] = (
            np.sum(flux[fcList, 0:2, is_], axis=1)
            * fcOr
            / gmtry.fcS[fcList]
        )

    return bFlux