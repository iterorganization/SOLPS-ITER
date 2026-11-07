def isplasmagrid(gmtry):
    """
    Check if the gmtry structure corresponds to a plasma grid.

    Parameters
    ----------
    gmtry : object or dict
        Geometry object.

    Returns
    -------
    bool
        True if gmtry has 'crx' and 'cry' attributes, False otherwise.
    """
    return hasattr(gmtry, 'crx') and hasattr(gmtry, 'cry')
