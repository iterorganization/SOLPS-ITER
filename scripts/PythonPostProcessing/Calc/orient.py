def orient(p, q, r):
    """
    Determine orientation of ordered triplet (p, q, r).

    Returns
    -------
    0 : Collinear
    1 : Clockwise
    2 : Counterclockwise
    """

    val = (q[1] - p[1]) * (r[0] - q[0]) - (q[0] - p[0]) * (r[1] - q[1])

    if val > 0:
        return 1
    elif val < 0:
        return 2
    else:
        return 0
