def write_sfield(fid, fieldname, field):
    """
    Write a string field to a B2.5 b2f* file.

    Parameters
    ----------
    fid : file object
        Open file handle for writing.
    fieldname : str
        Name of the field.
    field : str
        String content of the field.

    Notes
    -----
    - Always uses string length 120, as expected by B2.5.
    """
    # Print the label line
    fid.write('*cf:    char')
    fid.write(f'{120:16d}')
    fid.write(f'    {fieldname}\n')

    # Print the string
    fid.write(f' {field}\n')
