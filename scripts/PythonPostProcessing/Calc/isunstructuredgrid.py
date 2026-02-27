def isunstructuredgrid(gmtry):
    """
    Check if the gmtry structure corresponds to an unstructured grid.

    Parameters
    ----------
    gmtry : object or dict
        Geometry object.

    Returns
    -------
    bool
        True if gmtry has 'cvX' and 'cvY' attributes, False otherwise.
    """
    return hasattr(gmtry, 'cvX') and hasattr(gmtry, 'cvY')
