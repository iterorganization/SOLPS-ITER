import numpy as np
from .read_ifield import read_ifield
from .read_rfield import read_rfield

class State:
    """Container for B2.5 unstructured grid state data."""
    pass

def read_b2fstate_us(file):
    state = State()

    # Open file
    try:
        fid = open(file, "r")
    except OSError as e:
        raise RuntimeError(f"Failed to open {file}: {e}")

    # Get version
    line = fid.readline()
    version = line[7:17]
    print(f"read_b2fstate_us -- file version {version}")

    dim = read_ifield(fid, "nCv,nFc,ns", (3,))
    nCv, nFc, ns = dim

    statedim = (nCv, 1)
    statedims = (nCv, ns)
    fluxdim = (nFc, 2)
    fluxdimp = (nFc, 2)
    fluxdims = (nFc, 2, ns)

    # --- Read charges etc. ---
    state.zamin = read_rfield(fid, "zamin", (ns,))
    state.zamax = read_rfield(fid, "zamax", (ns,))
    state.zn    = read_rfield(fid, "zn", (ns,))
    state.am    = read_rfield(fid, "am", (ns,))

    # --- Read state variables ---
    state.na     = read_rfield(fid, 'na', statedims)
    state.ne     = read_rfield(fid, 'ne', statedim)
    state.ua     = read_rfield(fid, 'ua', statedims)
    state.uadia  = read_rfield(fid, 'uadia', fluxdims)
    state.te     = read_rfield(fid, 'te', statedim)
    state.ti     = read_rfield(fid, 'ti', statedim)
    state.tn     = read_rfield(fid, 'tn', statedim)
    state.po     = read_rfield(fid, 'po', statedim)
    state.kt     = read_rfield(fid, 'kt', statedim)
    state.zt     = read_rfield(fid, 'zt', statedim)

    # --- Read fluxes ---
    state.fna    = read_rfield(fid, 'fna', fluxdims)
    # state.fne    = read_rfield(fid, 'fne', fluxdim)
    state.fhe    = read_rfield(fid, 'fhe', fluxdim)
    state.fhi    = read_rfield(fid, 'fhi', fluxdim)
    state.fhn    = read_rfield(fid, 'fhn', fluxdim)
    # state.fch    = read_rfield(fid, 'fch', fluxdim)
    # # state.fch_32 = read_rfield(fid, 'fch_32', fluxdim)
    # # state.fch_52 = read_rfield(fid, 'fch_52', fluxdim)
    # # state.kinrgy = read_rfield(fid, 'kinrgy', statedims)
    state.fhm    = read_rfield(fid, 'fhm', fluxdims)
    state.fkt    = read_rfield(fid, 'fkt', fluxdim)
    state.fzt    = read_rfield(fid, 'fzt', fluxdim)
    state.time    = read_rfield(fid, 'time', (1,))
    state.fch_p  = read_rfield(fid, 'fch_p', fluxdimp)

    # --- Additional fluxes ---
    state.fna_mdf    = read_rfield(fid, 'fna_mdf', fluxdims)
    state.fhe_mdf    = read_rfield(fid, 'fhe_mdf', fluxdim)
    state.fhi_mdf    = read_rfield(fid, 'fhi_mdf', fluxdim)
    state.fna_fcor   = read_rfield(fid, 'fna_fcor', fluxdims)
    state.fna_nodrift= read_rfield(fid, 'fna_nodrift', fluxdims)
    state.fna_he     = read_rfield(fid, 'fna_he', fluxdims)
    state.fnaPSch    = read_rfield(fid, 'fnaPSch', fluxdims)
    state.fhePSch    = read_rfield(fid, 'fhePSch', fluxdim)
    state.fhiPSch    = read_rfield(fid, 'fhiPSch', fluxdim)
    state.fna_eir    = read_rfield(fid, 'fna_eir', fluxdims)
    state.fne_eir    = read_rfield(fid, 'fne_eir', fluxdim)
    state.fhe_eir    = read_rfield(fid, 'fhe_eir', fluxdim)
    state.fhi_eir    = read_rfield(fid, 'fhi_eir', fluxdim)
    state.fna_32     = read_rfield(fid, 'fna_32', fluxdims)
    state.fna_52     = read_rfield(fid, 'fna_52', fluxdims)
    state.fni_32     = read_rfield(fid, 'fni_32', fluxdim)
    state.fni_52     = read_rfield(fid, 'fni_52', fluxdim)
    state.fne_32     = read_rfield(fid, 'fne_32', fluxdim)
    state.fne_52     = read_rfield(fid, 'fne_52', fluxdim)
    state.fchdia     = read_rfield(fid, 'fchdia', fluxdim)
    state.fchin      = read_rfield(fid, 'fchin', fluxdim)
    state.fchvispar  = read_rfield(fid, 'fchvispar', fluxdim)
    state.fchvisper  = read_rfield(fid, 'fchvisper', fluxdim)
    state.fchvisq    = read_rfield(fid, 'fchvisq', fluxdim)
    state.fchviskt   = read_rfield(fid, 'fchviskt', fluxdim)
    state.fchinert   = read_rfield(fid, 'fchinert', fluxdim)
    # state.fchanml    = read_rfield(fid, 'fchanml', fluxdim)
    # state.fht        = read_rfield(fid, 'fht', fluxdim)
    # state.fhj        = read_rfield(fid, 'fhj', fluxdim)
    # state.fhm        = read_rfield(fid, 'fhm', fluxdims)
    # state.fhp        = read_rfield(fid, 'fhp', fluxdims)

    state.vaecrb    = read_rfield(fid, 'vaecrb', fluxdims)
    state.vadia     = read_rfield(fid, 'vadia', fluxdims)
    state.wadia     = read_rfield(fid, 'wadia', fluxdims)
    state.veecrb    = read_rfield(fid, 'veecrb', fluxdim)
    state.vedia     = read_rfield(fid, 'vedia', fluxdim)
    
    state.floe_noc     = read_rfield(fid, 'floe_noc', fluxdim)
    state.floi_noc     = read_rfield(fid, 'floi_noc', fluxdim)

    fid.close()
    return state
