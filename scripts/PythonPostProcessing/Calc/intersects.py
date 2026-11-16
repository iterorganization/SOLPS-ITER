from .orient import orient
from .onSegment import onSegment

def intersects(p1, q1, p2, q2):
    """
    Check if line segment p1q1 intersects with segment p2q2.

    Returns
    -------
    1 : If segments intersect
    0 : Otherwise
    """

    o1 = orient(p1, q1, p2)
    o2 = orient(p1, q1, q2)
    o3 = orient(p2, q2, p1)
    o4 = orient(p2, q2, q1)

    # General case
    if o1 != o2 and o3 != o4:
        return 1

    # Special cases
    if o1 == 0 and onSegment(p1, p2, q1):
        return 1

    if o2 == 0 and onSegment(p1, q2, q1):
        return 1

    if o3 == 0 and onSegment(p2, p1, q2):
        return 1

    if o4 == 0 and onSegment(p2, q1, q2):
        return 1

    return 0
