import numpy as np


def read_ifield(fid, fieldname, dims):
    """
    field = read_ifield(fid, fieldname, dims)

    Auxiliary routine to read integer fields from B2.5 b2f* files

    Parameters
    ----------
    fid : file object
        Open file handle, positioned anywhere in the file
    fieldname : str
        Identifier to search for
    dims : tuple or list of int
        Desired array dimensions

    Returns
    -------
    field : numpy.ndarray
        Integer array with shape `dims`
    """

    # Search the file until identifier 'fieldname' is found
    while True:
        line = fid.readline()
        if line == "":
            raise EOFError(f"EOF reached without finding {fieldname}.")
        header = line.split()
        if (len(header) >= 4 and header[0] == '*cf:'
                 and header[1] == 'int' and header[3] == fieldname):
            break

    # Consistency check: number of elements specified in the file
    # MATLAB: strread(line,'%*s %*s %d')
    tokens = line.split()
    try:
        numin = int(tokens[2])
    except (IndexError, ValueError):
        raise ValueError("Failed to parse number of elements from header line.")

    if numin != int(np.prod(dims)):
        raise ValueError("read_ifield: inconsistent number of input elements.")

    # Read the data
    count = int(np.prod(dims))
    data = np.fromfile(fid, dtype=int, count=count, sep=" ")

    if data.size != count:
        raise EOFError("Unexpected EOF while reading integer field data.")

    if len(dims) > 1:
        data = data.reshape(dims, order='F')

    return data
