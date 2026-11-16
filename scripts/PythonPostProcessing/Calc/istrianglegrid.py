def istrianglegrid(triangles):
    """
    Check if the structure corresponds to a triangle grid (from Eirene).

    Parameters
    ----------
    triangles : object or dict
        Geometry object.

    Returns
    -------
    bool
        True if triangles has 'nodes' and 'cells' attributes, False otherwise.
    """
    return hasattr(triangles, 'nodes') and hasattr(triangles, 'cells')
