c VERSION: 01.07.2000 23:24
c
c*** Control parameters for transfer from B2 to Eirene
c*** This allows to input some of more often varied Eirene parameters
c*** to be specified in the B2 input file in a convenient way.
c*** 
c*** DELTAT and EIRENE_STEP_CPU are left in the dummy variable list in
c*** the eirsrt routine just to minimise the number of possible errors.
c***>>  Control parameters:
c*** DEF_NSPCSRFG:  max. number of groups of surfaces for which the data
c***                can be transferred (e. g., pump duct, e.t.c)
c*** n_spcsrf:  actual number of such groups as input from B2
c*** l_spcsrf:  list of surface segments (non-default standard surfaces
c***            or additional surfaces in Eirene notation) included
c***            in the groups. Negative numbers correspond to NDSS.
c*** i_spcsrf:  starting position of each group in the list
c*** j_spcsrf:  ending position of each group in the list
c***>>  Eirene parameters for the groups:
c*** l_neutrad: jneutrad (global): neutral radiation, >0 - new
c*** sps_absr:  particle absorption on the surface
c*** sps_trno:  surface transparency in positive direction
c*** sps_trni:  surface transparency in negative direction
c*** sps_mtri:  surface material in Eirene notation (e.g., 1206 for C)
c*** sps_tmpr:  surface temperature
c*** sps_spph:  fudge-factor for physical sputtering
c*** sps_spch:  fudge-factor for chemical sputtering
c*** sps_sgrp:  surface group for chemical sputtering
c*** sps_mtrl:  surface material in human notation (e.g., C)
c*** sps_id:    identifier of the group of surfaces (assigned in DG)
     -  sps_absr(DEF_NSPCSRFG), sps_trno(DEF_NSPCSRFG), 
     ,  sps_trni(DEF_NSPCSRFG), sps_mtri(DEF_NSPCSRFG),
     ,  sps_tmpr(DEF_NSPCSRFG), sps_spph(DEF_NSPCSRFG),
     ,  sps_spch(DEF_NSPCSRFG)
      integer nn_spcsrf
      parameter(nn_spcsrf=DEF_NLIM+DEF_NSTS)
      integer l_neutrad, n_spcsrf,
     ,  l_spcsrf(nn_spcsrf), i_spcsrf(DEF_NSPCSRFG),
     ,  j_spcsrf(DEF_NSPCSRFG), sps_sgrp(DEF_NSPCSRFG)
      character*8 sps_mtrl(DEF_NSPCSRFG), sps_id(DEF_NSPCSRFG)
      common/spcsrfcom/sps_absr,sps_trno,sps_trni,sps_mtri,sps_tmpr,
     r  sps_spph,sps_spch,
     i  l_neutrad,n_spcsrf,l_spcsrf,i_spcsrf,j_spcsrf,sps_sgrp
      common/spcsrfcch/sps_mtrl,sps_id
