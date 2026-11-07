import numpy as np

class Structure:
    """Container for a single structure from structure.dat."""
    def __init__(self, nel, r, z):
        self.nel = nel
        self.r = r
        self.z = z


def read_structure(file):
    """
    Read structure.dat file containing coordinates of structures.

    Parameters
    ----------
    file : str
        Path to the structure.dat file.

    Returns
    -------
    structures : list of Structure
        List of structure objects with `nel`, `r`, and `z` attributes.
    """

    structures = []

    try:
        with open(file, 'r') as fid:

            # Number of structures
            nstr = int(fid.readline().strip())

            # Find header '$structures'
            line = fid.readline()
            while '$structures' not in line:
                line = fid.readline()
                if line == '':
                    raise RuntimeError("EOF reached without finding $structures.")

            # Read each structure
            for i in range(nstr):
                line = fid.readline().strip()
                parts = line.split()
                if len(parts) != 2 or parts[0] != 'Structure' or int(parts[1]) != i+1:
                    raise RuntimeError("read_structure: inconsistent input.")

                # Number of segments
                nel = int(fid.readline().strip())

                # Read coordinates
                coords = np.fromfile(fid, count=2*abs(nel), sep=' ', dtype=float)
                r = coords[0::2]
                z = coords[1::2]

                structures.append(Structure(nel, r, z))

    except OSError as e:
        raise RuntimeError(f"Failed to open {file}: {e}")

    return structures
