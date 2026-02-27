import numpy as np

def read_rfield(fid, fieldname, dims):
    """
    Read a real (float) field from b2f* files.
    """
    # --- Search for the header ---
    while True:
        line = fid.readline()
        if line == "":
            raise EOFError(f"EOF reached without finding {fieldname}.")
        if fieldname in line:
            break

    # Parse number of elements from header
    tokens = line.split()
    try:
        numin = int(tokens[2])
    except (IndexError, ValueError):
        raise ValueError(f"Failed to parse number of elements from {fieldname} header.")

    count = int(np.prod(dims))
    if numin != count:
        raise ValueError(f"read_rfield: inconsistent number of elements for {fieldname}.")

    # --- Read the data safely ---
    # Read 'count' floats from the file (split lines if necessary)
    numbers = []
    while len(numbers) < count:
        line = fid.readline()
        if line == "":
            raise EOFError(f"Unexpected EOF while reading {fieldname}")
        numbers.extend([float(x) for x in line.split()])

    if len(numbers) != count:
        raise ValueError(f"read_rfield: read {len(numbers)} elements but expected {count} for {fieldname}")

    data = np.array(numbers, dtype=float)

    # --- Reshape with Fortran order ---
    if len(dims) > 1:
        data = data.reshape(dims, order='F')

    return data
