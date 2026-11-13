import numpy as np
import re
from dataclasses import dataclass


@dataclass
class Geometry:

    nCv: int = 0
    nFc: int = 0
    nVx: int = 0
    nFt: int = 0
    nFs: int = 0


    vxX: np.ndarray = None
    vxY: np.ndarray = None
    vxFpsi: np.ndarray = None
    vxBb: np.ndarray = None      # shape (g.nVx, 2)
    vxFfbz: np.ndarray = None

    cvX: np.ndarray = None
    cvY: np.ndarray = None
    cvPsi: np.ndarray = None
    cvBp: np.ndarray = None
    cvBt: np.ndarray = None
    fsPsi: np.ndarray = None

    isClassicalGrid: int = 0
    nx: int = 0
    ny: int = 0
    nncut: int = 0

    cvVxP: np.ndarray = None     # (g.nCv, 2)
    cvFcP: np.ndarray = None     # (g.nCv, 2)
    cvLbl: np.ndarray = None
    cvReg: np.ndarray = None
    cvFt: np.ndarray = None
    cvVol: np.ndarray = None

    cvVx: np.ndarray = None
    cvFc: np.ndarray = None

    fcVx: np.ndarray = None      # (g.nFc, 2)
    fcLbl: np.ndarray = None
    fcReg: np.ndarray = None
    fcAligned: np.ndarray = None

    ftCvP: np.ndarray = None     # (g.nFt, 2)
    ftFcP: np.ndarray = None     # (g.nFt, 2)
    ftReg: np.ndarray = None
    ftCv: np.ndarray = None
    ftFc: np.ndarray = None

    fsFcP: np.ndarray = None     # (g.nFs, 2)
    fsFc: np.ndarray = None

    imapCv: np.ndarray = None
    imapFcx: np.ndarray = None
    imapFcy: np.ndarray = None
    imapVx: np.ndarray = None


def extract_version(first_line):
    match = re.search(r"VERSION([0-9]+\.[0-9]+\.[0-9]+)", first_line)
    if not match:
        raise RuntimeError("Could not extract grid version")
    return match.group(1)


def read_cfruin(f, n_expected):
    header = f.readline()
    values = []
    while len(values) < n_expected:
        line = f.readline()
        if line == "":
            raise EOFError(f"Unexpected EOF in {header.strip()}: expected {n_expected} integers, got {len(values)}")
        values.extend(map(int, line.split()))
    return np.array(values[:n_expected], dtype=int)


def read_traduitoutb2us(filename):

    with open(filename, "r") as f:

        # --- Version ---
        first_line = f.readline().strip()
        grid_version = extract_version(first_line)

        if grid_version != "03.002.000":
            raise RuntimeError("Unsupported grid version")
        g = Geometry()
        # --- Sizes ---
        idum = read_cfruin(f, 6)
        g.nCv, g.nFc, g.nVx = idum[0], idum[1], idum[2]
        g.nFs, g.nFt = idum[4], idum[5]

        idum = read_cfruin(f, 5)
        nnCmxVx, nnCmxFc, nnFmxCv, nnVmxCv, nnVmxFc = idum

        idum = read_cfruin(f, 1)
        g.isClassicalGrid = idum[0]

        if g.isClassicalGrid == 1:
            idum = read_cfruin(f, 3)
            g.nx, g.ny, g.nncut = idum

        

        # --- Allocate arrays ---
        g.vxX = np.zeros(g.nVx)
        g.vxY = np.zeros(g.nVx)
        g.vxFpsi = np.zeros(g.nVx)
        g.vxBb = np.zeros((g.nVx, 2))
        g.vxFfbz = np.zeros(g.nVx)

        g.cvX = np.zeros(g.nCv)
        g.cvY = np.zeros(g.nCv)

        g.cvPsi = np.zeros(g.nCv)
        g.cvBp = np.zeros(g.nCv)
        g.cvBt = np.zeros(g.nCv)
        g.cvVol = np.zeros(g.nCv)

        g.cvVxP = np.zeros((g.nCv, 2), dtype=int)
        g.cvLbl = np.zeros(g.nCv, dtype=int)
        g.cvReg = np.zeros(g.nCv, dtype=int)
        g.cvFt = np.zeros(g.nCv, dtype=int)

        g.fcVx = np.zeros((g.nFc, 2), dtype=int)
        g.fcLbl = np.zeros(g.nFc, dtype=int)
        g.fcReg = np.zeros(g.nFc, dtype=int)
        g.fcAligned = np.zeros(g.nFc, dtype=int)

        if g.nFt > 0:
            g.ftCvP = np.zeros((g.nFt, 2), dtype=int)
            g.ftFcP = np.zeros((g.nFt, 2), dtype=int)
            g.ftReg = np.zeros(g.nFt, dtype=int)

        if g.nFs > 0:
            g.fsFcP = np.zeros((g.nFs, 2), dtype=int)
            g.fsPsi = np.zeros(g.nFs)

        # --- Vertex section ---
        line = f.readline().split()
        if line[0] == "*cf:" and line[1] == "Vx":
            for i in range(g.nVx):
                parts = f.readline().split()
                g.vxX[i] = float(parts[1])
                g.vxY[i] = float(parts[2])
                g.vxFpsi[i] = float(parts[3])
                g.vxBb[i, 0] = float(parts[4])
                g.vxBb[i, 1] = float(parts[5])
                g.vxFfbz[i] = float(parts[6])

        # --- Cell section ---
        line = f.readline().split()
        if line[0] == "*cf:" and line[1] == "cv":
            for i in range(g.nCv):
                parts = f.readline().split()
                g.cvVxP[i, 0] = int(parts[1])
                g.cvVxP[i, 1] = int(parts[2])
                g.cvX[i] = float(parts[3])
                g.cvY[i] = float(parts[4])
                g.cvPsi[i] = float(parts[5])
                g.cvBp[i] = float(parts[6])
                g.cvBt[i] = float(parts[7])
                g.cvLbl[i] = int(parts[8])
                g.cvReg[i] = int(parts[9])
                g.cvFt[i] = int(parts[10])

            g.cvFcP = g.cvVxP.copy()

        # --- Variable-length integer blocks ---
        g.cvVx = read_cfruin(f, nnCmxVx)
        g.cvFc = read_cfruin(f, nnCmxFc)

        # --- Face section ---
        line = f.readline().split()
        if line[0] == "*cf:" and line[1] == "fc":
            for i in range(g.nFc):
                parts = f.readline().split()
                g.fcVx[i, 0] = int(parts[1])
                g.fcVx[i, 1] = int(parts[2])
                g.fcLbl[i] = int(parts[3])
                g.fcReg[i] = int(parts[4])
                g.fcAligned[i] = int(parts[5])

        # --- Flux tubes ---
        if g.nFt > 0:
            line = f.readline().split()
            if line[0] == "*cf:" and line[1] == "ft":
                for i in range(g.nFt):
                    parts = f.readline().split()
                    g.ftCvP[i, 0] = int(parts[1])
                    g.ftCvP[i, 1] = int(parts[2])
                    g.ftFcP[i, 0] = int(parts[3])
                    g.ftFcP[i, 1] = int(parts[4])
                    g.ftReg[i] = int(parts[5])

            ftCv_len = np.sum(g.ftCvP[-1]) - 1
            g.ftCv = read_cfruin(f, ftCv_len)

            ftFc_len = np.sum(g.ftFcP[-1]) - 1
            g.ftFc = read_cfruin(f, ftFc_len)

        shift_full(g.cvVx)
        shift_full(g.cvFc)
        shift_full(g.ftCv)
        shift_full(g.ftFc)
        shift_full(g.fsFc)
        shift_full(g.fcVx)

        shift_full(g.imapCv)
        shift_full(g.imapFcx)
        shift_full(g.imapFcy)
        shift_full(g.imapVx)

        shift_pointer_first_column(g.cvVxP)
        shift_pointer_first_column(g.cvFcP)
        shift_pointer_first_column(g.ftCvP)
        shift_pointer_first_column(g.ftFcP)
        shift_pointer_first_column(g.fsFcP)




        return g


# -------------------------------------------------
# Convert Fortran 1-based pointer starts to Python
# (only first column is shifted)
# -------------------------------------------------

def shift_pointer_first_column(arr):
    if arr is not None:
        arr[:, 0] -= 1



# -------------------------------------------------
# Convert pure index arrays (fully 1-based)
# -------------------------------------------------

def shift_full(arr):
    if arr is not None:
        arr -= 1





