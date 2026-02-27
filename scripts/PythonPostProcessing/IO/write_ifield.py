import numpy as np

def write_ifield(fid, fieldname, field):
    field = np.asarray(field, dtype=int)
    field_flat = field.flatten(order='F')

    # Header line
    fid.write('*cf:    int ')
    fid.write(f'{field_flat.size:16d}')
    fid.write(f'    {fieldname}\n')  # exactly 4 spaces before fieldname

    # Data in chunks of 12 per line
    per_line = 12
    for i in range(0, field_flat.size, per_line):
        chunk = field_flat[i:i+per_line]
        line = ''.join(f"{x:11d}" for x in chunk)
        fid.write(line + '\n')

def write_ifield_old(fid, fieldname, field):
    """
    Write an integer field to a B2.5 b2f* file in Fortran-compatible format,
    so that read_ifield can read it back correctly.

    Parameters
    ----------
    fid : file object
        Open file for writing.
    fieldname : str
        Name of the field to write.
    field : array-like
        Integer field data to write (numpy array or list).
    """
    field = np.asarray(field, dtype=int)

    # Flatten in column-major order (Fortran-style) to match read_ifield
    field_flat = field.flatten(order='F')

    # --- Write the header line ---
    fid.write(f"*cf:    int {field_flat.size:16d}    {fieldname}\n")

    # --- Write the data in groups of 12 per line ---
    per_line = 12
    for i in range(0, field_flat.size, per_line):
        chunk = field_flat[i:i+per_line]
        # 11-character width for each integer, right-aligned
        line = ''.join(f"{x:11d}" for x in chunk)
        fid.write(line + '\n')