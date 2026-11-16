def find_separatrix_flux_surface(gmtry):
    fssep = 0

    # Loop over flux surfaces (MATLAB: 1-based → Python: 0-based)
    for ifs in range(gmtry.nFs):
        # MATLAB indices
        i1 = gmtry.fsFcP[ifs, 0]
        nn = gmtry.fsFcP[ifs, 1]
        i2 = i1 + nn  # Python slice is exclusive at end

        # Extract faces (convert from MATLAB 1-based to Python 0-based if needed)
        fcs = gmtry.fsFc[i1:i2]

        # Loop over faces
        for ifc in range(nn):
            fc = fcs[ifc]

            # If MATLAB data is 1-based, subtract 1 here:
            # fc_idx = fc - 1
            fc_idx = fc

            cvs = gmtry.fcCv[fc_idx, :]
            regs = gmtry.cvReg[cvs]
            regs = sorted(regs)

            if regs[0] == 1 and regs[1] != 1:
                return ifs  # return Python index

    return fssep