def onSegment(p, q, r):
    """
    Check if point q lies on the line segment pr.

    Returns
    -------
    1 : If q lies on segment pr
    0 : Otherwise
    """

    if (q[0] <= max(p[0], r[0]) and
        q[0] >= min(p[0], r[0]) and
        q[1] <= max(p[1], r[1]) and
        q[1] >= min(p[1], r[1])):
        return 1

    return 0
