import matplotlib.pyplot as plt
import numpy as np

def plotstructure(structure, *args, **kwargs):
    """
    Plot structure (vessel, templates, etc.) given r/z coordinates.

    Parameters
    ----------
    structure : list of dicts
        Each dict should have keys 'r' and 'z' with arrays of coordinates.
    *args, **kwargs : passed to matplotlib plot function
        e.g., color='k', linewidth=2

    Returns
    -------
    handles : list
        List of Line2D objects for each structure part.
    """
    # Check hold status (Matplotlib always adds to current axes)
    ax = plt.gca()

    handles = []
    for part in structure:
        h, = ax.plot(part.r, part.z, *args, **kwargs)
        handles.append(h)

    return handles
