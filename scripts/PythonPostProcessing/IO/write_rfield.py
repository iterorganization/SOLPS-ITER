import numpy as np

def write_rfield(fid, fieldname, field):
    field = np.asarray(field, dtype=float)
    field_flat = field.flatten(order='F')

    # Header line (MATLAB-style, fixed-width)
    fid.write('*cf:    real')
    fid.write(f'{field_flat.size:16d}')
    fid.write(f'    {fieldname}\n')  # 4 spaces before fieldname

    # Data in chunks of 6 per line
    per_line = 6
    for i in range(0, field_flat.size, per_line):
        chunk = field_flat[i:i+per_line]
        line = ''.join(f"{x:21.13E}" for x in chunk)
        line = line.replace('E+', 'E+0').replace('E-', 'E-0')
        fid.write(line + '\n')


def write_rfield_old(fid, fieldname, field):
    """
    Write a real (float) field to a B2.5 b2f* file in Fortran-compatible format,
    so that read_rfield can read it back correctly.

    Parameters
    ----------
    fid : file object
        Open file for writing.
    fieldname : str
        Name of the field to write.
    field : array-like
        Real (float) field data to write (numpy array or list).
    """
    field = np.asarray(field, dtype=float)

    # Flatten in column-major order (Fortran style)
    field_flat = field.flatten(order='F')

    # --- Write the header line ---
    fid.write(f"*cf:    real {field_flat.size:16d}    {fieldname}\n")

    # --- Write the data in chunks of 6 per line ---
    per_line = 6
    for i in range(0, field_flat.size, per_line):
        chunk = field_flat[i:i+per_line]
        # 21-character scientific format
        line = ''.join(f"{x:21.13E}" for x in chunk)
        # Ensure Fortran-style 3-digit exponent
        line = line.replace('E+', 'E+0').replace('E-', 'E-0')
        fid.write(line + '\n')