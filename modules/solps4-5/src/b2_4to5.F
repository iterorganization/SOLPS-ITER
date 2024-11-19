      module b2_4to5
      use b2mod_types
      use b2mod_subsys
      use b2mod_dimensions
      implicit none

      real (kind=R8), allocatable ::
     *  fch_4(:,:,:),  fch_32_4(:,:,:), fch_52_4(:,:,:), fch_p_4(:,:,:),
     *  fhe_4(:,:,:),  fhi_4(:,:,:), fna_4(:,:,:,:),
     *  fne_4(:,:,:),  na_4(:,:,:),  po_4(:,:), fchdia_4(:,:,:),
     *  te_4(:,:),  ti_4(:,:),  ua_4(:,:,:),  uadia_4(:,:,:,:),
     *  mi_4(:), zi_4(:),
     *  crx_4(:,:,:), cry_4(:,:,:), bb_4(:,:,:),
     *  parvis_4(:), travis_4(:), difni_4(:), difpr_4(:), vconv_4(:),
     *  conpar_4(:,:,:), mompar_4(:,:,:), enepar_4(:,:), enipar_4(:,:),
     *  phiin_4(:), phiout_4(:),
     *  recyc_4(:,:), userfluxparm_4(:,:), gpfc_4(:,:),
     *  niiso_4(:),
     *  rf_neut_4(:), dtee_4(:), dtei_4(:), dtco_4(:,:), dtmo_4(:,:),
     *  sclstra_4(:,:), sclrtio_4(:,:),
     *  vout_cnv_4(:), pw0_cnv_4(:), pw1_cnv_4(:), pw2_cnv_4(:),
     *  ffb_const_4(:), ffb_rate_4(:), ffb_start_4(:), ffb_smax_4(:),
     *  ffb_over_4(:), cfb_core_4(:), cfb_over_4(:), cfb_smax_4(:),
     *  sps_absr_4(:), sps_trno_4(:), sps_trni_4(:), sps_mtri_4(:),
     *  sps_tmpr_4(:), sps_spph_4(:), sps_spch_4(:)

      real (kind=R8) ::
     *  kxe_4, kxi_4, kye_4, kyi_4, flim_4, flimi_4, flimv_4, feqp_4,
     *  fudgen_4, fudgeb_4,
     *  fudgeten_4, fudgeteb_4, fudgetin_4, fudgetib_4,
     *  starting_time_4, dflaglnlam_4, neutral_diflimit_4,
     *  gammai_4,
     *  dt_eirene_fudge_4, eirene_step_cpu_4,
     *  volrecstart_4, volrecinc_4, volrecwt_4,
     *  teiso_4, tiiso_4,
     *  cimpef_4,
     *  rxfi_4, dti_4, dtc_4, dtmin_4, dtmax_4, cpustop_4,
     *  res_limit_nstage_4, res_limit_job_4,
     *  maxconverge_decrease_timestep_4,
     *  maxconverge_increase_timestep_4, time_factor_required_4,
     *  fusion_power_4, Spmp_He_to_D_4, Spmp_nom_4,
     *  sepden_4, voldesired_4, volrecfac_4,
     *  time_4

      integer ::
     *  nx_4, ny_4, ns_4, nspecies_4, nncut_4, nniso_4, nlmpgs_4,
     *  dflagn_4, dflagte_4, dflagti_4, dflagkxe_4, dflagkxi_4,
     *  dflagvconv_4, ixref_4, iyref_4,
     *  nbc_4, ncbs_4,
     *  nstrae_4, nstrai_4, nfla_4, eirene_mod_4,
     *  ltime_4, lstime_4, lmovie_4, nltrsol_4, jxi_4, jxa_4,
     *  nstepprint_4, nstepout_4,
     *  impflag_4,
     *  nlrade_4, nlcurr_4,
     *  istepi_4, nstagei_4, stylei_4,
     *  lpfrb_i_4, lpfrb_o_4, lpfrt_i_4, lpfrt_o_4, lpfrs_pmp_4,
     *  npfrgrp_4, nntrgrp_4, j_he_at_4, j_h_at_4, n_spcsrf_4,
     *  main_plasma_bc_4, user_flux_feedback_stratum_4,
     *  l_neutrad_4, l_neutflux_4

      integer, allocatable ::
     *  nfluids_4(:),
     *  bcpos_4(:), bcstart_4(:), bcend_4(:),
     *  bccon_4(:,:), bcmom_4(:,:), bcene_4(:), bceni_4(:), lcbs_4(:),
     *  rcpos_4(:), rcstart_4(:), rcend_4(:), lstrascl_4(:,:),
     *  lmolscl_4(:), ksns_4(:), nspzi_4(:), nspze_4(:),
     *  lcns_4(:), lsns_4(:), ltns_4(:), msns_4(:,:), mlcmp_4(:,:),
     *  debug_flags_4(:),
     *  nxcut1_4(:), nxcut2_4(:), nycut1_4(:), nycut2_4(:),
     *  nxiso1_4(:), nxiso2_4(:), nyiso1_4(:), nyiso2_4(:),
     *  lhetrgts_4(:), l_h_mol_4(:),
     *  lpfrgrp_4(:), ipfrgrp_4(:), jpfrgrp_4(:),
     *  lntrgrp_4(:), intrgrp_4(:), jntrgrp_4(:),
     *  i_spcsrf_4(:), j_spcsrf_4(:), l_spcsrf_4(:), sps_sgrp_4(:),
     *  ffb_cntr_4(:), ffb_strata_4(:), cfb_cntr_4(:)

      integer, allocatable :: ifl(:), jfl(:), is1(:), isp(:)

      integer sput_dst, sput_dst2, sput_dst3

      integer jxa, jxi, jsep

      integer ank_mods, ionising_core

      character*80 label_4, sonnetfile_4

      character*8, allocatable ::
     *  gpfrgrp_4(:), gntrgrp_4(:), sps_id_4(:), sps_mtrl_4(:)

      character*1, allocatable :: bcchar_4(:), crcstra_4(:)

      logical lvis21_4, ni_driven_4, no_thermal_force_4,
     *  lbndusr_4, lfeedback_4,
     *  lreitr_4, lfirstflight_4,
     *  autotimestep_4, scale_He_4, print_isat_4,
     *  sepfeedback_4, volrecfeedback_4, sepgasfeedback_4

      logical, allocatable ::
     *  ffb_include_core_4(:), ffb_include_neutrals_4(:), ffb_init_4(:)

#ifndef NO_B2_CHEM_SPUT
      real (kind=R8), allocatable ::
     *  chemical_sputter_yield_4(:)
      real (kind=R8) :: fchar_chemical_4
      integer igass_chemical_4, itsput_chemical_4, issput_chemical_4
#endif

      save

      contains

      subroutine b2conv_plasma_1
      use braeir
      use ceirsrt
      implicit none
#     include <KOPPLDIM.F>
#     include <COMDIM.F>
#     include <COMNUM.F>
#     include <COMPLASMA.F>
#     include <COMBOUND.F>
#     include <COMNEUT.F>
#     include <COMDIAG.F>
#     include <COMTRA.F>
#     include <COMLAB.F>
#     include <IMPDIM.F>
#     include <COMGEO.F>
#     include <CCUT.F>
#     include <COMUSER.F>
#     include <CBRAEIR.F>

      integer is

      call subini('b2convp1')

      nx_4 = nx
      ny_4 = ny
      ns_4 = ns
      nbc_4 = nbc
      ncbs_4 = ncbs
      nncut_4 = nncut
      nniso_4 = nniso
      nstrae_4 = nstrai
      if (crcstra(nstrai+1).eq.'T') then
        nstrai_4 = nstrai+1
      else
        nstrai_4 = nstrai
      endif
      nspecies_4 = nspecies
      label_4 = label
      sonnetfile_4 = sonnetfile

      allocate(fhe_4(-1:nx_4,-1:ny_4,0:1))
      allocate(fhi_4(-1:nx_4,-1:ny_4,0:1))
      allocate(fch_4(-1:nx_4,-1:ny_4,0:1))
      allocate(fch_p_4(-1:nx_4,-1:ny_4,0:1))
      allocate(fchdia_4(-1:nx_4,-1:ny_4,0:1))
      allocate(fna_4(-1:nx_4,-1:ny_4,0:1,1:ns_4))
      allocate(na_4(-1:nx_4,-1:ny_4,1:ns_4))
      allocate(te_4(-1:nx_4,-1:ny_4))
      allocate(ti_4(-1:nx_4,-1:ny_4))
      allocate(po_4(-1:nx_4,-1:ny_4))
      allocate(ua_4(-1:nx_4,-1:ny_4,1:ns_4))
      allocate(uadia_4(-1:nx_4,-1:ny_4,0:1,1:ns_4))
      allocate(nfluids_4(1:nspecies_4))
      allocate(mi_4(1:ns_4))
      allocate(zi_4(1:ns_4))
      allocate(crx_4(-1:nx_4,-1:ny_4,0:3))
      allocate(cry_4(-1:nx_4,-1:ny_4,0:3))
      allocate(bb_4(-1:nx_4,-1:ny_4,0:3))
      allocate(nxcut1_4(1:nncut_4))
      allocate(nxcut2_4(1:nncut_4))
      allocate(nycut1_4(1:nncut_4))
      allocate(nycut2_4(1:nncut_4))
      if (nniso_4.gt.0) then
        allocate(nxiso1_4(1:nniso_4))
        allocate(nxiso2_4(1:nniso_4))
        allocate(nyiso1_4(1:nniso_4))
        allocate(nyiso2_4(1:nniso_4))
      endif
      allocate(lcbs_4(1:nbc_4))
      allocate(difni_4(1:ns_4))
      allocate(difpr_4(1:ns_4))
      allocate(vconv_4(1:ns_4))
      allocate(travis_4(1:ns_4))
      allocate(bccon_4(1:ns_4,1:nbc_4))
      allocate(conpar_4(1:ns_4,1:nbc_4,2))
      allocate(ksns_4(1:nstrai_4))
      allocate(nspzi_4(1:nstrai_4))
      allocate(nspze_4(1:nstrai_4))
      allocate(sclstra_4(0:ns_4,1:nstrai_4))
      allocate(sclrtio_4(0:ns_4,1:nstrai_4))
      allocate(vout_cnv_4(1:ns_4))
      allocate(pw0_cnv_4(1:ns_4))
      allocate(pw1_cnv_4(1:ns_4))
      allocate(pw2_cnv_4(1:ns_4))

      fhe_4(-1:nx_4,-1:ny_4,0) = FEEX(0:nx_4+1,0:ny_4+1)
      fhe_4(-1:nx_4,-1:ny_4,1) = FEEY(0:nx_4+1,0:ny_4+1)
      fhi_4(-1:nx_4,-1:ny_4,0) = FEIX(0:nx_4+1,0:ny_4+1)
      fhi_4(-1:nx_4,-1:ny_4,1) = FEIY(0:nx_4+1,0:ny_4+1)
      fch_4(-1:nx_4,-1:ny_4,0) = CC(0:nx_4+1,0:ny_4+1)
      fch_4(-1:nx_4,-1:ny_4,1) = DD(0:nx_4+1,0:ny_4+1)
      fch_p_4(-1:nx_4,-1:ny_4,0) = CP(0:nx_4+1,0:ny_4+1)
      fch_p_4(-1:nx_4,-1:ny_4,1) = 0.0_R8
      fchdia_4(-1:nx_4,-1:ny_4,0) = CD(0:nx_4+1,0:ny_4+1)
      fchdia_4(-1:nx_4,-1:ny_4,1) = 0.0_R8
      fna_4(-1:nx_4,-1:ny_4,0,1:ns_4) = FNIX(0:nx_4+1,0:ny_4+1,1:ns_4)
      fna_4(-1:nx_4,-1:ny_4,1,1:ns_4) = FNIY(0:nx_4+1,0:ny_4+1,1:ns_4)
      na_4(-1:nx_4,-1:ny_4,1:ns_4) = NI(0:nx_4+1,0:ny_4+1,1:ns_4)
      te_4(-1:nx_4,-1:ny_4) = TE(0:nx_4+1,0:ny_4+1)
      ti_4(-1:nx_4,-1:ny_4) = TI(0:nx_4+1,0:ny_4+1)
      po_4(-1:nx_4,-1:ny_4) = PHI(0:nx_4+1,0:ny_4+1)
cxpb Original code
      ua_4(-1:nx_4,-1:ny_4,1:ns_4) = UP(0:nx_4+1,0:ny_4+1,1:ns_4)
cxpb Use directly cell-centered data from SOLPS4.0
c      ua_4(-1:nx_4,-1:ny_4,1:ns_4) = UPC(0:nx_4+1,0:ny_4+1,1:ns_4)
      uadia_4(-1:nx_4,-1:ny_4,0,1:ns_4) = UD(0:nx_4+1,0:ny_4+1,1:ns_4)
      uadia_4(-1:nx_4,-1:ny_4,1,1:ns_4) = VD(0:nx_4+1,0:ny_4+1,1:ns_4)
cxpb Change of definition
c      do is = 1, ns_4
c        ua_4(-1:nx_4,-1:ny_4,is) = UU(0:nx_4+1,0:ny_4+1,is)/
c     .   PIT(0:nx_4+1,0:ny_4+1)
c      end do
cxpb
      nfluids_4(1:nspecies_4) = nfluids(1:nspecies_4)
      mi_4(1:ns_4) = MI(1:ns_4)
      zi_4(1:ns_4) = ZI(1:ns_4)
      crx_4(-1:nx_4,-1:ny_4,0) = BR(0:nx_4+1,0:ny_4+1,4)
      cry_4(-1:nx_4,-1:ny_4,0) = BZ(0:nx_4+1,0:ny_4+1,4)
      crx_4(-1:nx_4,-1:ny_4,1) = BR(0:nx_4+1,0:ny_4+1,1)
      cry_4(-1:nx_4,-1:ny_4,1) = BZ(0:nx_4+1,0:ny_4+1,1)
      crx_4(-1:nx_4,-1:ny_4,2) = BR(0:nx_4+1,0:ny_4+1,3)
      cry_4(-1:nx_4,-1:ny_4,2) = BZ(0:nx_4+1,0:ny_4+1,3)
      crx_4(-1:nx_4,-1:ny_4,3) = BR(0:nx_4+1,0:ny_4+1,2)
      cry_4(-1:nx_4,-1:ny_4,3) = BZ(0:nx_4+1,0:ny_4+1,2)
      bb_4(-1:nx_4,-1:ny_4,0) =
     .  BB(0:nx_4+1,0:ny_4+1) * PIT(0:nx_4+1,0:ny_4+1)
      bb_4(-1:nx_4,-1:ny_4,1) = 0.0_R8
      bb_4(-1:nx_4,-1:ny_4,2) =
     .  BB(0:nx_4+1,0:ny_4+1) * SQRT(1.0_R8-PIT(0:nx_4+1,0:ny_4+1)**2)
      bb_4(-1:nx_4,-1:ny_4,3) = BB(0:nx_4+1,0:ny_4+1)
      nxcut1_4(1:nncut_4) = nxcut1(1:nncut_4)
      nxcut2_4(1:nncut_4) = nxcut2(1:nncut_4)
      nycut1_4(1:nncut_4) = nycut1(1:nncut_4)
      nycut2_4(1:nncut_4) = nycut2(1:nncut_4)
      if (nniso.gt.0) then
        nxiso1_4(1:nniso_4) = nxiso1(1:nniso_4)
        nxiso2_4(1:nniso_4) = nxiso2(1:nniso_4)
        nyiso1_4(1:nniso_4) = nyiso1(1:nniso_4)
        nyiso2_4(1:nniso_4) = nyiso2(1:nniso_4)
      endif
      lcbs_4(1:ncbs_4) = lcbs(1:ncbs_4)
      difni_4(1:ns_4) = difni(1:ns_4)
      difpr_4(1:ns_4) = difpr(1:ns_4)
      vconv_4(1:ns_4) = vconv(1:ns_4)
      travis_4(1:ns_4)= travis(1:ns_4)
      kye_4 = kye
      kxe_4 = kxe
      kyi_4 = kyi
      kxi_4 = kxi
      dflagn_4 = dflagn
      dflagte_4 = dflagte
      dflagti_4 = dflagti
      fudgen_4 = fudgen
      fudgeb_4 = fudgeb
      fudgeten_4 = fudgeten
      fudgeteb_4 = fudgeteb
      fudgetin_4 = fudgetin
      fudgetib_4 = fudgetib
      flim_4 = flim
      flimi_4 = flimi
      flimv_4 = flimv
      bccon_4(1:ns_4,1:nbc_4) = bccon(1:ns_4,1:nbc_4)
      conpar_4(1:ns_4,1:nbc_4,1:2) = conpar(1:ns_4,1:nbc_4,1:2)
      ksns_4(1:nstrai_4) = ksns(1:nstrai_4)
      sclstra_4(0:ns_4,1:nstrai_4) = sclstra(0:ns_4,1:nstrai_4)
      sclrtio_4(0:ns_4,1:nstrai_4) = sclrtio(0:ns_4,1:nstrai_4)
      vout_cnv_4(1:ns_4) = vout_cnv(1:ns_4)
      pw0_cnv_4(1:ns_4) = pw0_cnv(1:ns_4)
      pw1_cnv_4(1:ns_4) = pw1_cnv(1:ns_4)
      pw2_cnv_4(1:ns_4) = pw2_cnv(1:ns_4)

      time_4 = time

      call subend()
      return
      end subroutine b2conv_plasma_1

      subroutine b2conv_input_1
      use braeir
     , , only: chemical_sputter_yield, fchar_chemical,
     ,         itsput_chemical, issput_chemical, igass_chemical
      use ccoupl
     , , only: nspze_eir => nspze, nspzi_eir => nspzi, ntgprt
      use comsou
     , , only: nlatm, nlmol, nlpls, nspez
      use cinit
     , , only: indsrc
      use ceirsrt
      use b2mod_dimensions
      implicit none
#     include <KOPPLDIM.F>
#     include <COMDIM.F>
#     include <COMFEEDBACK.F>
#     include <COMPLASMA.F>
#     include <COMBOUND.F>
#     include <COMINIT.F>
#     include <COMNEUT.F>
#     include <COMUSER.F>
#     include <COMDIAG.F>
#     include <COMTRA.F>
#     include <IMPDIM.F>
#     include <COMNUM.F>
#     include <COMLAB.F>
#     include <COMEQ.F>
#     include <CCUT.F>

      integer is, it, ib, k

      call subini('b2convi1')

      nfla_4 = nfla
      nlmpgs_4 = nlmpgs
      n_spcsrf_4 = n_spcsrf

      allocate(parvis_4(1:ns_4))
      allocate(bcpos_4(1:nbc_4))
      allocate(bcstart_4(1:nbc_4))
      allocate(bcend_4(1:nbc_4))
      allocate(bcchar_4(1:nbc_4))
      allocate(bcmom_4(1:ns_4,1:nbc_4))
      allocate(bcene_4(1:nbc_4))
      allocate(bceni_4(1:nbc_4))
      allocate(mompar_4(1:ns_4,1:nbc_4,2))
      allocate(enepar_4(1:nbc_4,2))
      allocate(enipar_4(1:nbc_4,2))
      allocate(phiin_4(1:nncut_4))
      allocate(phiout_4(1:nncut_4))
      allocate(crcstra_4(1:nstrai_4))
      allocate(rcpos_4(1:nstrai_4))
      allocate(rcstart_4(1:nstrai_4))
      allocate(rcend_4(1:nstrai_4))
      allocate(recyc_4(1:ns_4,1:nstrai_4))
      allocate(userfluxparm_4(1:nstrai_4,2))
#ifndef NO_B2_CHEM_SPUT
      allocate(chemical_sputter_yield_4(0:nlimps))
#endif
      allocate(lstrascl_4(1:nstrai_4,0:nspecies_4))
      allocate(lmolscl_4(1:nmol))
      allocate(lcns_4(1:nsts))
      allocate(lsns_4(1:nstrai_4))
      allocate(ltns_4(1:nsts))
      allocate(msns_4(2,1:nstrai_4))
      allocate(mlcmp_4(1:natm,1:nmol))
      allocate(gpfc_4(1:natm,1:nstrai_4))
      allocate(debug_flags_4(1:100))
      allocate(sps_id_4(1:n_spcsrf_4))
      allocate(i_spcsrf_4(1:n_spcsrf_4))
      allocate(j_spcsrf_4(1:n_spcsrf_4))
      allocate(l_spcsrf_4(1:nlim+nsts))
      allocate(sps_absr_4(1:n_spcsrf_4))
      allocate(sps_trno_4(1:n_spcsrf_4))
      allocate(sps_trni_4(1:n_spcsrf_4))
      allocate(sps_mtri_4(1:n_spcsrf_4))
      allocate(sps_tmpr_4(1:n_spcsrf_4))
      allocate(sps_spph_4(1:n_spcsrf_4))
      allocate(sps_spch_4(1:n_spcsrf_4))
      allocate(sps_sgrp_4(1:n_spcsrf_4))
      allocate(sps_mtrl_4(1:n_spcsrf_4))
      allocate(niiso_4(1:ns_4))
      allocate(rf_neut_4(1:4))
      allocate(dtee_4(1:nregionv))
      allocate(dtei_4(1:nregionv))
      allocate(dtmo_4(1:ns_4,1:nregionv))
      allocate(dtco_4(1:ns_4,1:nregionv))
      allocate(lhetrgts_4(1:nhetrgtx))
      allocate(l_h_mol_4(1:nmol))
      allocate(lpfrgrp_4(1:nlim))
      allocate(ipfrgrp_4(1:npfrgrpd))
      allocate(jpfrgrp_4(1:npfrgrpd))
      allocate(gpfrgrp_4(1:npfrgrpd))
      allocate(lntrgrp_4(1:nlim))
      allocate(intrgrp_4(1:nntrgrpd))
      allocate(jntrgrp_4(1:nntrgrpd))
      allocate(gntrgrp_4(1:nntrgrpd))
      allocate(ffb_cntr_4(1:nspecies_4))
      allocate(ffb_const_4(1:nspecies_4))
      allocate(ffb_rate_4(1:nspecies_4))
      allocate(ffb_start_4(1:nspecies_4))
      allocate(ffb_smax_4(1:nspecies_4))
      allocate(ffb_over_4(1:nspecies_4))
      allocate(ffb_strata_4(1:nspecies_4))
      allocate(ffb_include_core_4(1:nspecies_4))
      allocate(ffb_include_neutrals_4(1:nspecies_4))
      allocate(ffb_init_4(1:nspecies_4))
      allocate(cfb_cntr_4(1:nspecies_4))
      allocate(cfb_core_4(1:nspecies_4))
      allocate(cfb_over_4(1:nspecies_4))
      allocate(cfb_smax_4(1:nspecies_4))

*  ..take in b2.parameters data
*   ..initialisation
      starting_time_4 = starting_time
*   ..transport
      parvis_4(1:ns_4) = parvis(1:ns_4)
      dflagkxi_4 = dflagkxi
      dflagkxe_4 = dflagkxe
      dflagvconv_4 = dflagvconv
      feqp_4 = feqp
      lvis21_4 = lvis21
      dflaglnlam_4 = dflaglnlam
      ixref_4 = ixref-1
      iyref_4 = iyref-1
      ni_driven_4 = ni_driven
      no_thermal_force_4 = no_thermal_force
      neutral_diflimit_4 = neutral_diflimit
*   ..boundary
      bcpos_4(1:nbc_4) = bcpos(1:nbc_4)
      bcstart_4(1:nbc_4) = bcstart(1:nbc_4)
      bcend_4(1:nbc_4) = bcend(1:nbc_4)
      bcchar_4(1:nbc_4) = bcchar(1:nbc_4)
      bcmom_4(1:ns_4,1:nbc_4) = bcmom(1:ns_4,1:nbc_4)
      bcene_4(1:nbc_4) = bcene(1:nbc_4)
      bceni_4(1:nbc_4) = bceni(1:nbc_4)
      mompar_4(1:ns_4,1:nbc_4,1:2) = mompar(1:ns_4,1:nbc_4,1:2)
      enepar_4(1:nbc_4,1:2) = enepar(1:nbc_4,1:2)
      enipar_4(1:nbc_4,1:2) = enipar(1:nbc_4,1:2)
      phiin_4(1:nncut_4/2) = phiin(1:nncut_4/2)
      phiout_4(1:nncut_4/2) = phiout(1:nncut_4/2)
      gammai_4 = gammai
      lbndusr_4 = lbndusr
#ifndef SOLPS4_3
      lfeedback_4 = lfeedback.or.sepfeedback.or.volrecfeedback.or.
     .              sepgasfeedback
#else
      lfeedback_4 = lfeedback.or.sepfeedback.or.volrecfeedback
#endif
*   ..neutrals
      lreitr_4 = lreitr
      crcstra_4(1:nstrai_4) = crcstra(1:nstrai_4)
      rcpos_4(1:nstrai_4) = rcpos(1:nstrai_4)
      rcstart_4(1:nstrai_4) = rcstart(1:nstrai_4)
      rcend_4(1:nstrai_4) = rcend(1:nstrai_4)
      recyc_4(1:ns_4,1:nstrai_4) = recyc(1:ns_4,1:nstrai_4)
      do is = 1, nstrai_4
        nspzi_4(is) = nspzi(is)
        nspze_4(is) = nspze(is)
        do it = 1, ntgprt(is)
          nspzi_4(is) = max(nspzi_4(is),nspzi_eir(is,it))
          nspze_4(is) = min(nspze_4(is),nspze_eir(is,it))
        end do
        if (indsrc(is).ne.6) then
          if (nlatm(is)) then
            k = 0
            do it = 1, nspez(is)-1
              k = k + nfluids(it)
            end do
            nspzi_4(is) = k+1
            nspze_4(is) = k+nfluids(nspez(is))
          else if (nlmol(is)) then
            k = 0
            do it = 1, lmolscl(nspez(is))-1
              k = k + nfluids(it)
            end do
            nspzi_4(is) = k+1
            nspze_4(is) = k+nfluids(lmolscl(nspez(is)))
          else if (nlpls(is).and.nspez(is).eq.-1) then
            nspzi_4(is) = 1
            nspze_4(is) = 0
            do it = 1, nspecies
              nspze_4(is) = nspze_4(is)+nfluids(it)
            end do
          else if (nlpls(is).and.nspez(is).gt.0) then
            nspzi_4(is) = nspez(is)
            nspze_4(is) = nspez(is)
          endif
        endif
        ksns_4(is) = ntgprt(is)
      end do
      dt_eirene_fudge_4 = dt_eirene_fudge
      eirene_step_cpu_4 = eirene_step_cpu
      eirene_mod_4 = eirene_mod
      userfluxparm_4(1:nstrai_4,1:2) = userfluxparm(1:nstrai_4,1:2)
      lfirstflight_4 = lfirstflight .and. lfluid.gt.0
      lstrascl_4(1:nstrai_4,1:nspecies_4) =
     .  lstrascl(1:nstrai_4,1:nspecies_4)
      l_neutrad_4 = l_neutrad
      l_neutflux_4 = l_neutflux
      lmolscl_4 = lmolscl
      lcns_4 = lcns
      lsns_4(1:nstrai_4) = lsns(1:nstrai_4)
      ltns_4 = ltns
      msns_4(1:2,1:nstrai_4) = msns(1:2,1:nstrai_4)
      mlcmp_4 = mlcmp
      gpfc_4(1:natm,1:nstrai_4) = gpfc(1:natm,1:nstrai_4)
      volrecstart_4 = volrecstart
      volrecinc_4 = volrecinc
      volrecwt_4 = volrecwt
#ifndef NO_B2_CHEM_SPUT
      chemical_sputter_yield_4 = chemical_sputter_yield
      fchar_chemical_4 = fchar_chemical
      igass_chemical_4 = igass_chemical
      itsput_chemical_4 = itsput_chemical
      issput_chemical_4 = issput_chemical
#endif
      sps_id_4(1:n_spcsrf_4) = sps_id(1:n_spcsrf_4)
      i_spcsrf_4(1:n_spcsrf_4) = i_spcsrf(1:n_spcsrf_4)
      j_spcsrf_4(1:n_spcsrf_4) = j_spcsrf(1:n_spcsrf_4)
      l_spcsrf_4(1:nlim+nsts) = l_spcsrf(1:nlim+nsts)
      sps_absr_4(1:n_spcsrf_4) = sps_absr(1:n_spcsrf_4)
      sps_trni_4(1:n_spcsrf_4) = sps_trni(1:n_spcsrf_4)
      sps_trno_4(1:n_spcsrf_4) = sps_trno(1:n_spcsrf_4)
      sps_mtri_4(1:n_spcsrf_4) = sps_mtri(1:n_spcsrf_4)
      sps_tmpr_4(1:n_spcsrf_4) = sps_tmpr(1:n_spcsrf_4)
      sps_spph_4(1:n_spcsrf_4) = sps_spph(1:n_spcsrf_4)
      sps_spch_4(1:n_spcsrf_4) = sps_spch(1:n_spcsrf_4)
      sps_sgrp_4(1:n_spcsrf_4) = sps_sgrp(1:n_spcsrf_4)
      sps_mtrl_4(1:n_spcsrf_4) = sps_mtrl(1:n_spcsrf_4)
*   ..diagnostics
      ltime_4 = ltime
      lstime_4 = lstime
      lmovie_4 = lmovie
      nltrsol_4 = nltrsol
      jxi_4 = jxi-1
      jxa_4 = jxa-1
      debug_flags_4 = debug_flags
      nstepprint_4 = nstepprint
      nstepout_4 = nstepout
*   ..cut
      niiso_4(1:ns_4) = niiso(1:ns_4)
      teiso_4 = teiso
      tiiso_4 = tiiso
*   ..impurities
      impflag_4 = impflag
      cimpef_4 = cimpef
*   ..drifts
      nlrade_4 = nlrade
      nlcurr_4 = nlcurr
*   ..numerics
      istepi_4 = sum(istepi(1:ncyc))
      nstagei_4 = nstagei(1)
      rxfi_4 = rxfi(1)
      dti_4 = dti(1)
      stylei_4 = stylei_4
      autotimestep_4 = autotimestep
      dtc_4 = dtc
      dtmin_4 = dtmin
      dtmax_4 = dtmax
      cpustop_4 = cpustop
      rf_neut_4 = rf_neut
      res_limit_nstage_4 = res_limit_nstage
      res_limit_job_4 = res_limit_job
      maxconverge_decrease_timestep_4 = maxconverge_decrease_timestep
      maxconverge_increase_timestep_4 = maxconverge_increase_timestep
      dtee_4 = dtee
      dtei_4 = dtei
      dtco_4 = dtco
      dtmo_4 = dtmo
      time_factor_required_4 = time_factor_required
*   ..user
      npfrgrp_4 = npfrgrp
      lpfrgrp_4 = lpfrgrp
      ipfrgrp_4 = ipfrgrp
      jpfrgrp_4 = jpfrgrp
      gpfrgrp_4 = gpfrgrp
      nntrgrp_4 = nntrgrp
      lntrgrp_4 = lntrgrp
      intrgrp_4 = intrgrp
      jntrgrp_4 = jntrgrp
      gntrgrp_4 = gntrgrp
      lhetrgts_4 = lhetrgts
      if (lpfrb_i.gt.0) then
        lpfrb_i_4 = lpfrb_i-1
      else
        lpfrb_i_4 = lpfrb_i
      end if
      if (lpfrb_o.gt.0) then
        lpfrb_o_4 = lpfrb_o-1
      else
        lpfrb_o_4 = lpfrb_o
      end if
      if (lpfrt_i.gt.0) then
        lpfrt_i_4 = lpfrt_i-1
      else
        lpfrt_i_4 = lpfrt_i
      end if
      if (lpfrt_o.gt.0) then
        lpfrt_o_4 = lpfrt_o-1
      else
        lpfrt_o_4 = lpfrt_o
      end if
      lpfrs_pmp_4 =  lpfrs_pmp
      j_he_at_4 = j_he_at
      j_h_at_4 = j_h_at
      l_h_mol_4 = l_h_mol
      fusion_power_4 = fusion_power
      Spmp_He_to_D_4 = Spmp_He_to_D
      Spmp_nom_4 = Spmp_nom
      scale_He_4 = scale_He
      print_isat_4 = print_isat
*   ..feedback
      sepfeedback_4 = sepfeedback
#ifndef SOLPS4_3
      sepgasfeedback_4 = sepgasfeedback
#else
      sepgasfeedback_4 = .false.
#endif
      sepden_4 = sepden
      main_plasma_bc_4 = main_plasma_bc
      voldesired_4 = voldesired
      volrecfac_4 = volrecfac
      volrecfeedback_4 = volrecfeedback
      user_flux_feedback_stratum_4 = user_flux_feedback_stratum
      ffb_cntr_4(1:nspecies_4) = ffb_cntr(1:nspecies_4)
      ffb_const_4(1:nspecies_4) = ffb_const(1:nspecies_4)
      ffb_rate_4(1:nspecies_4) = ffb_rate(1:nspecies_4)
      ffb_start_4(1:nspecies_4) = ffb_start(1:nspecies_4)
      ffb_smax_4(1:nspecies_4) = ffb_smax(1:nspecies_4)
      ffb_strata_4(1:nspecies_4) = ffb_strata(1:nspecies_4)
      ffb_over_4(1:nspecies_4) = ffb_over(1:nspecies_4)
      ffb_include_core_4(1:nspecies_4) = ffb_include_core(1:nspecies_4)
      ffb_init_4(1:nspecies_4) = ffb_init(1:nspecies_4)
      ffb_include_neutrals_4(1:nspecies_4) =
     . ffb_include_neutrals(1:nspecies_4)
      cfb_cntr_4(1:nspecies_4) = cfb_cntr(1:nspecies_4)
      cfb_core_4(1:nspecies_4) = cfb_core(1:nspecies_4)
      cfb_over_4(1:nspecies_4) = cfb_over(1:nspecies_4)
      cfb_smax_4(1:nspecies_4) = cfb_smax(1:nspecies_4)
      ank_mods = 1
      ionising_core = 0
      do is = 1, nspecies_4
        lfeedback_4 = lfeedback_4 .or. ffb_cntr_4(is).ne.0 .or.
     .                                 cfb_cntr_4(is).ne.0
        if (ionising_core.lt.0) cycle
        if (cfb_cntr_4(is).ne.0 .and. ffb_cntr_4(is).ne.0) then
          ank_mods = 0
          do ib = 1, nbc
            if (bcchar_4(ib).eq.'S') then
              if (nncut_4.eq.2) then
                if (bcstart_4(ib).gt.nxcut1_4(1) .and.
     &              bcstart_4(ib).le.nxcut1_4(2)) then
                  ionising_core = -ib
                end if
              else if (nncut_4.eq.4) then
                if (bcstart_4(ib).gt.nxcut1_4(1) .and.
     &              bcstart_4(ib).le.nxcut1_4(2)) then
                  ionising_core = -ib
                else if (bcstart_4(ib).gt.nxcut1_4(3) .and.
     &                   bcstart_4(ib).le.nxcut1_4(4)) then
                  ionising_core = -ib
                end if
              end if
            end if
          end do
        end if
      end do

      call subend()
      return
      end subroutine b2conv_input_1

      subroutine b2conv_plasma_2(nx,ny,ns,lblgm)
      use b2mod_types
      use b2mod_geo
      use b2mod_time
      use b2mod_work
      use b2mod_rates
      use b2mod_plasma
      use b2mod_sources
      use b2mod_indirect
      use b2mod_elements
      use b2mod_constants
      use b2mod_residuals
      use b2mod_transport
      use b2mod_neutr_src_scaling
      use b2mod_boundary_namelist
      use b2mod_neutrals_namelist
      use b2mod_anomalous_transport
      use b2mod_b2cmpa
      use b2mod_b2cmpb
      use b2mod_b2cmpt
      use b2mod_external
      use b2mod_dimensions
      implicit none

      integer nx, ny, ns
      character*120 lblgm
      integer i,j,k,m,n,is,ic,ix,iy
      integer ixl,ixr,ireg
      integer, allocatable :: zone(:)

      external xertst
      external b2xpne, b2xpni, b2xppb, b2xpfe, b2xpfi, b2agmt
      external init_region
      real (kind=R8) :: rratio
      external rratio

      call subini('b2convp2')

      nx = nx_4
      ny = ny_4
      ns = ns_4 + nspecies_4
      nspecies = nspecies_4

      call xertst(1.le.nx.and.nx.le.DEF_NXD,
     . 'Check size of NX !')
      call xertst(1.le.ny.and.ny.le.DEF_NYD,
     . 'Check size of NY !')
      call xertst(1.le.ns.and.ns.le.nfl+natm,
     . 'Check size of NS !')
      allocate(ifl(0:ns-1))
      allocate(jfl(0:ns-1))
      allocate(is1(1:ns_4))
      allocate(isp(1:nspecies_4))

      k=0
      m=0
      n=0
      do i=1,nspecies_4
        ifl(k)=0
        n=n+1
        jfl(k)=n
        isp(i)=k
        do j=1,nfluids_4(i)
          k=k+1
          m=m+1
          ifl(k)=m
          jfl(k)=n
          is1(m)=k
        end do
        k=k+1
      end do
      write(*,'(a,50i5)') 'ifl = ',ifl
      write(*,'(a,50i5)') 'jfl = ',jfl
      write(*,'(a,50i5)') 'is1 = ',is1
      write(*,'(a,50i5)') 'isp = ',isp
      lblgm = label_4

      call alloc_b2mod_geo(nx,ny)
      call alloc_b2mod_work(nx,ny,ns)
      call alloc_b2mod_rates(nx,ny,ns)
      call alloc_b2mod_plasma(nx,ny,ns)
      call alloc_b2mod_sources(nx,ny,ns)
      call alloc_b2mod_residuals(nx,ny,ns)
      call alloc_b2mod_transport(nx,ny,ns)
      call alloc_b2mod_indirect(nx,ny,nncutmax)
      call alloc_b2mod_anomalous_transport(nx,ny,ns)
      call alloc_b2mod_neutr_src_scaling(ns,nstraid)
      call alloc_b2mod_external(nx,ny,ns)
      call alloc_b2mod_external_dummy(nx,ny)

c Fill out b2mod_indirect arrays
      call xertst (mod(nncut,2).eq.0, 'nncut = odd, case not expected')
      nncut = nncut_4/2
      call xertst(0.le.nncut.and.nncut.le.nncutmax,
     . 'Check size of NNCUT !')
      leftcut(1:nncut) = nxcut1_4(1:nncut)+1-1
      rightcut(1:nncut) = nxcut2_4(1:nncut)-1
      bottomcut(1:nncut) = nycut1_4(1:nncut)-1
      topcut(1:nncut) = nycut2_4(1:nncut)+1-1
!xpb careful about the change of meaning of nniso between 4.x and 5.x
!xpb In 4.x: a DN geometry needs an isolating cut, which will be the first of the list
!xpb In 5.x: no isolating cut is needed for DN geometries
      if (nncut.ge.2) then
        nniso = nniso_4-(nncut-1)
      else
        nniso = nniso_4
      end if
      call xertst(0.le.nniso.and.nniso.le.nnisod,
     . 'Check size of NNISO !')
      if (nniso.gt.0) then
        if (nncut.ge.2) then
          nxiso1(1:nniso) = nxiso1_4(nncut:nniso_4)-1
          nxiso2(1:nniso) = nxiso2_4(nncut:nniso_4)-1
          nyiso1(1:nniso) = nyiso1_4(nncut:nniso_4)-1
          nyiso2(1:nniso) = nyiso2_4(nncut:nniso_4)-1
        else
          nxiso1(1:nniso) = nxiso1_4(1:nniso)
          nxiso2(1:nniso) = nxiso2_4(1:nniso)
          nyiso1(1:nniso) = nyiso1_4(1:nniso)
          nyiso2(1:nniso) = nyiso2_4(1:nniso)
        end if
      end if
      if(nncut.eq.0) write(*,*) 'No cuts found'
      if(nncut.ge.1) write(*,'(a,4i5)')
     1     'Calculated leftcut1, rightcut1, topcut1, bottomcut1 = ',
     1     leftcut(1), rightcut(1), topcut(1), bottomcut(1)
      if(nncut.ge.2) write(*,'(a,4i5)')
     1     'Calculated leftcut2, rightcut2, topcut2, bottomcut2 = ',
     1     leftcut(2), rightcut(2), topcut(2), bottomcut(2)

      do ix = -1, nx
        do iy = -1, ny
          leftix(ix,iy)=ix-1
          leftiy(ix,iy)=iy
          rightix(ix,iy)=ix+1
          rightiy(ix,iy)=iy
          bottomix(ix,iy)=ix
          bottomiy(ix,iy)=iy-1
          topix(ix,iy)=ix
          topiy(ix,iy)=iy+1
        enddo
      enddo

      do ix = -1, nx
        do iy = -1, ny
          do ic = 1, nncut
            if (ix.eq.leftcut(ic)-1 .and.
     &          iy.ge.bottomcut(ic) .and. iy.lt.topcut(ic)) then
              rightix(ix,iy)=rightcut(ic)
              leftix(rightcut(ic),iy)=leftcut(ic)-1
            endif
            if (ix.eq.leftcut(ic) .and.
     &          iy.ge.bottomcut(ic) .and. iy.lt.topcut(ic)) then
              leftix(ix,iy)=rightcut(ic)-1
              rightix(rightcut(ic)-1,iy)=leftcut(ic)
            endif
          enddo
          do ic = 1, nncut-1
!xpb We treat here only the isolating cuts corresponding to DN geometry
            if (ix.eq.nxiso2_4(ic)) leftix(ix,iy)=-2
            if (ix.eq.nxiso1_4(ic)-1) rightix(ix,iy)=nx+1
          enddo
          do ic = nncut, nniso
!xpb We treat here only the isolating cuts corresponding to regions removed from the computational space
            if (ix.eq.nxiso1(ic) .and.
     &          iy.ge.nyiso1(ic) .and. iy.le.nyiso2(ic)) then
              leftix(ix,iy)=-2
            endif
            if (ix.eq.nxiso2(ic) .and.
     &          iy.ge.nyiso1(ic) .and. iy.le.nyiso2(ic)) then
              rightix(ix,iy)=nx+1
            endif
            if (iy.eq.nyiso1(ic) .and.
     &          ix.ge.nxiso1(ic) .and. ix.le.nxiso2(ic)) then
              bottomiy(ix,iy)=-2
            endif
            if (iy.eq.nyiso2(ic) .and.
     &          ix.ge.nxiso1(ic) .and. ix.le.nxiso2(ic)) then
              topiy(ix,iy)=ny+1
            endif
          enddo
        enddo
      enddo

      write(*,*) 'X regions (from rightix<>ix+1)'
      allocate(zone(-1:nx))
      do iy=ny,-1,-1
        ireg=1
        do ix=-1,nx
          zone(ix)=ireg
          if(rightix(ix,iy).ne.ix+1) ireg=ireg+1
        enddo
        write(*,'(3276(10i1,1x))') zone(-1:nx)
      enddo
      write(*,*) 'X regions (from connections)'
      do iy=ny,-1,-1
        ireg=0
        zone=0
        do ix=-1,nx
          if(zone(ix).eq.0) then
            ireg=ireg+1
            zone(ix)=ireg
            ixr=rightix(ix,iy)
            do while(ixr.ne.ix.and.ixr.ge.-1.and.ixr.le.nx)
              zone(ixr)=ireg
              ixr=rightix(ixr,iy)
            enddo
            ixl=leftix(ix,iy)
            do while(ixl.ne.ix.and.ixl.ge.-1.and.ixl.le.nx)
              zone(ixl)=ireg
              ixl=leftix(ixl,iy)
            enddo
          endif
        enddo
        write(*,'(3276(10i1,1x))') zone(-1:nx)
      enddo
      deallocate(zone)

      do ix = -1, nx
       do iy = -1, ny
        if (leftix(ix,iy).ne.-2) then
          fhe(ix,iy,0) = fhe_4(leftix(ix,iy),leftiy(ix,iy),0)
          fhi(ix,iy,0) = fhi_4(leftix(ix,iy),leftiy(ix,iy),0)
          fch(ix,iy,0) = fch_4(leftix(ix,iy),leftiy(ix,iy),0)
          fch_p(ix,iy,0) = fch_p_4(leftix(ix,iy),leftiy(ix,iy),0)
          fchdia(ix,iy,0) = fchdia_4(leftix(ix,iy),leftiy(ix,iy),0)
          do i=0,ns-1
            if(ifl(i).ne.0) then
              fna(ix,iy,0,i) =
     .         fna_4(leftix(ix,iy),leftiy(ix,iy),0,ifl(i))
            else
              fna(ix,iy,0,i) = 0.0_R8
            endif
          enddo
        else
          fhe(ix,iy,0) = 0.0_R8
          fhi(ix,iy,0) = 0.0_R8
          fch(ix,iy,0) = 0.0_R8
          fch_p(ix,iy,0) = 0.0_R8
          fchdia(ix,iy,0) = 0.0_R8
          fna(ix,iy,0,0:ns-1) = 0.0_R8
        endif
    7   if (bottomiy(ix,iy).ne.-2) then
          fhe(ix,iy,1) = fhe_4(bottomix(ix,iy),bottomiy(ix,iy),1)
          fhi(ix,iy,1) = fhi_4(bottomix(ix,iy),bottomiy(ix,iy),1)
          fch(ix,iy,1) = fch_4(bottomix(ix,iy),bottomiy(ix,iy),1)
          fch_p(ix,iy,1) = fch_p_4(bottomix(ix,iy),bottomiy(ix,iy),1)
          fchdia(ix,iy,1) =
     .                    fchdia_4(bottomix(ix,iy),bottomiy(ix,iy),1)
          do i=0,ns-1
            if(ifl(i).ne.0) then
              fna(ix,iy,1,i) =
     .         fna_4(bottomix(ix,iy),bottomiy(ix,iy),1,ifl(i))
            else
              fna(ix,iy,1,i) = 0.0_R8
            endif
          enddo
        else
          fhe(ix,iy,1) = 0.0_R8
          fhi(ix,iy,1) = 0.0_R8
          fch(ix,iy,1) = 0.0_R8
          fch_p(ix,iy,1) = 0.0_R8
          fchdia(ix,iy,1) = 0.0_R8
          fna(ix,iy,1,0:ns-1) = 0.0_R8
        endif
       enddo
      enddo

      te(-1:nx,-1:ny) = te_4(-1:nx,-1:ny)
      ti(-1:nx,-1:ny) = ti_4(-1:nx,-1:ny)
      po(-1:nx,-1:ny) = po_4(-1:nx,-1:ny)
      bb(-1:nx,-1:ny,0:3) = bb_4(-1:nx,-1:ny,0:3)
      crx(-1:nx,-1:ny,0:3) = crx_4(-1:nx,-1:ny,0:3)
      cry(-1:nx,-1:ny,0:3) = cry_4(-1:nx,-1:ny,0:3)
      do i=0,ns-1
        if(ifl(i).ne.0) then
          na(-1:nx,-1:ny,i) = na_4(-1:nx,-1:ny,ifl(i))
          ua(-1:nx,-1:ny,i) = ua_4(-1:nx,-1:ny,ifl(i))
          uadia(-1:nx,-1:ny,0:1,i) = uadia_4(-1:nx,-1:ny,0:1,ifl(i))
          am(i) = nint(mi_4(ifl(i))/mp)
          zamin(i) = zi_4(ifl(i))
          zamax(i) = zi_4(ifl(i))
          is_neutral(i) = .false.
        else
          na(-1:nx,-1:ny,i) = 1.0e8_R8
          ua(-1:nx,-1:ny,i) = 0.0_R8
          uadia(-1:nx,-1:ny,0:1,i) = 0.0_R8
          am(i) = nint(mi_4(ifl(i+1))/mp)
          zamin(i) = 0.0_R8
          zamax(i) = 0.0_R8
          is_neutral(i) = .true.
        end if
        zn(i) = nfluids_4(jfl(i))
        rza(-1:nx,-1:ny,i) = (zamin(i)+zamax(i))/2.0_R8
        rz2(-1:nx,-1:ny,i) = ((zamin(i)+zamax(i))/2.0_R8)**2
      end do
      call alloc_b2mod_elements(ns, zn, am)

c Compute geometrical quantities
      call b2agmt(nx, ny, 1,
     & crx, cry, vol, hx, hy, qz, qc, qcb, gs,
     & cell_width, cell_height, leftix, leftiy, bottomiy)
      fpsi = 0.0_R8
      ffbz = 0.0_R8
      periodic_bc = 0
      call init_region(nx,ny,nncut,nncutmax,
     1 leftcut,rightcut,topcut,bottomcut,
     1 leftix,rightix,rightiy,topix,topiy,bottomiy,
     2 region,nnreg,resignore,
     3 crx,cry,periodic_bc)
      call get_jsep(nx, ny, jxi, jxa, jsep)

c Fill out b2mod_plasma data
      call b2xpne(nx, ny, ns, rza, na, ne_ext, ne)
      call b2xpne(nx, ny, ns, rz2, na, ne_ext, ne2)
      call b2xpni(nx, ny, ns, na, ni)
      call b2xppb(nx, ny, rza(-1,-1,1), na(-1,-1,1), te, ti, pb)
      fhe0 = fhe
      fhep = fhe
      fhet = fhe
      fhi0 = fhi
      fhip = fhi
      fhit = fhi
      fch0 = fch
      fchp = fch
      fna0 = fna
      fnap = fna
      fna_mdf = fna
      fhe_mdf = fhe
      fhi_mdf = fhi
      fna_fcor = fna
      fna_nodrift = fna
      fna_he = fna
      fnaPSch = 0.0_R8
      fhePSch = 0.0_R8
      fhiPSch = 0.0_R8
      fna_eir = fna
      fhe_eir = fhe
      fhi_eir = fhi
      fna_32(:,:,0,:) = fna(:,:,0,:)
      fna_32(:,:,1,:) = 0.0_R8
      fna_52(:,:,0,:) = 0.0_R8
      fna_52(:,:,1,:) = fna(:,:,1,:)
      fch_32(:,:,0) = fch(:,:,0)
      fch_32(:,:,1) = 0.0_R8
      fch_52(:,:,0) = 0.0_R8
      fch_52(:,:,1) = fch(:,:,1)
      call b2xpfi(nx, ny, ns, fna, fni)
      call b2xpfi(nx, ny, ns, fna_32, fni_32)
      call b2xpfi(nx, ny, ns, fna_52, fni_52)
      call b2xpfe(nx, ny, ns, ns_ext, qe, rza, za_ext,
     $     fna, fa_ext, fch, fne)
      call b2xpfe(nx, ny, ns, ns_ext, qe, rza, za_ext,
     $     fna_32, fa_ext, fch_32, fne_32)
      call b2xpfe(nx, ny, ns, ns_ext, qe, rza, za_ext,
     $     fna_52, fa_ext, fch_52, fne_52)
      call b2xpfe(nx, ny, ns, ns_ext, qe, rza, za_ext,
     $     fna_eir, fa_ext, fch, fne_eir)
      vaecrb = 0.0_R8
      veecrb = 0.0_R8
      facdrift = 0.0_R8
      fac_ExB = 0.0_R8
      fac_vis = 0.0_R8
      fchvispar = 0.0_R8
      fchvisper = 0.0_R8
      fchvisq = 0.0_R8
      fchin = 0.0_R8
      floe_noc = 0.0_R8
      floi_noc = 0.0_R8
      na0 = na
      nap = na
      ne0 = ne
      nep = ne
      ni0 = ni
      po0 = po
      pop = po
      te0 = te
      tep = te
      ti0 = ti
      tip = ti

c Fill out /b2cmpb/ arrays
      cbsna=0.0_R8
      cbsmo=0.0_R8
      cbshi=0.0_R8
      cbshe=0.0_R8
      cbrec=0.0_R8
      cbmsa=0.0_R8
      cbsch=0.0_R8
      cbmsb=0.0_R8
      cbirso=0
      cbnrso=max(1,nncut*3)
      cbirno=cbirso+cbnrso
      cbnrno=max(1,nncut)
      cbirwe=cbirno+cbnrno
      cbnrwe=1
      cbirea=cbirwe+cbnrwe
      cbnrea=1
      call xertst(cbnrso+cbnrno+cbnrwe+cbnrea.le.cbnrmx,
     . 'faulty number of boundaries in b2cmpb !')
      cbrbrk(cbirso)=rratio(leftcut(1),nx)
      if(nncut.eq.1) then
        cbrbrk(1)=rratio(rightcut(1),nx)
      else
        cbrbrk(1)=rratio(leftcut(2),nx)
        cbrbrk(2)=rratio(nxiso1_4(1)+nxiso2_4(1)-2,2*nx)
        cbrbrk(3)=rratio(rightcut(2),nx)
        cbrbrk(4)=rratio(rightcut(1),nx)
      endif
      cbrbrk(cbirso+cbnrso-1)=2.0_R8
      if(nncut.eq.2) then
        cbrbrk(cbirno)=rratio(nxiso1_4(1)+nxiso2_4(1)-2,2*nx)
      endif
      cbrbrk(cbirno+cbnrno-1)=2.0_R8
      cbrbrk(cbirwe)=2.0_R8
      cbrbrk(cbirea)=2.0_R8
      do ic = 1, nncut
        do is = 0, ns-1
          if (is_neutral(is)) then
            cbsna(2,is,cbirso+(ic-1)*3  )=-1.0e-2_R8
            cbsna(2,is,cbirso+(ic-1)*3+2)=-1.0e-2_R8
            cbsna(2,is,cbirno+(ic-1)    )=-1.0e-2_R8
            cbsmo(3,is,cbirso+(ic-1)*3  )=-1.0e10_R8
            cbsmo(3,is,cbirso+(ic-1)*3+2)=-1.0e10_R8
            cbsmo(3,is,cbirno+(ic-1)    )=-1.0e10_R8
            cbshi(2,is,cbirso+(ic-1)*3  )=-1.0e-1_R8
            cbshi(2,is,cbirso+(ic-1)*3+2)=-1.0e-1_R8
            cbshi(2,is,cbirno+(ic-1)    )=-1.0e-1_R8
          else
            cbsna(2,is,cbirso+(ic-1)*3  )=-1.0e-3_R8
            cbsna(2,is,cbirso+(ic-1)*3+2)=-1.0e-3_R8
            cbsna(2,is,cbirno+(ic-1)    )=-1.0e-3_R8
            cbshi(2,is,cbirso+(ic-1)*3  )=-1.0e-2_R8
            cbshi(2,is,cbirso+(ic-1)*3+2)=-1.0e-2_R8
            cbshi(2,is,cbirno+(ic-1)    )=-1.0e-2_R8
            if (nint(zn(is)).eq.1 .or. nint(zn(is)).eq.2  .or.
     &          nint(zn(is)).eq.7 .or. nint(zn(is)).eq.10 .or.
     &          nint(zn(is)).eq.18) then
             cbrec(0,is,cbirso+(ic-1)*3  )=1.0_R8
             cbrec(0,is,cbirso+(ic-1)*3+2)=1.0_R8
             cbrec(0,is,cbirno+(ic-1)    )=1.0_R8
             cbrec(1,is,cbirso+(ic-1)*3  )=0.3_R8
             cbrec(1,is,cbirso+(ic-1)*3+2)=0.3_R8
             cbrec(1,is,cbirno+(ic-1)    )=0.3_R8
            end if
            if (zamax(is).eq.zn(is)) then
              if(bccon_4(ifl(is),lcbs_4(ic)).eq.1) then
                cbsna(0,is,cbirso+(ic-1)*3+1)=
     .           1.0e10_R8*conpar_4(ifl(is),lcbs_4(ic),1)
              end if
            end if
          end if
          cbsna(1,is,cbirso+(ic-1)*3+1)=-1.0e10_R8
          cbsmo(6,is,cbirso+(ic-1)*3  )=-1.0_R8
          cbsmo(3,is,cbirso+(ic-1)*3+1)=-1.0e10_R8
          cbsmo(6,is,cbirso+(ic-1)*3+2)=-1.0_R8
          cbsmo(6,is,cbirno+(ic-1)    )=-1.0_R8
          cbshi(0,is,cbirso+(ic-1)*3  )= 1.0e-18_R8
          cbshi(0,is,cbirso+(ic-1)*3+1)= 1.0e4_R8
          cbshi(0,is,cbirso+(ic-1)*3+2)= 1.0e-18_R8
          cbshi(0,is,cbirno+(ic-1)    )= 1.0e-18_R8
          cbshi(1,is,cbirso+(ic-1)*3  )=-100.0_R8
          cbshi(1,is,cbirso+(ic-1)*3+2)=-100.0_R8
          cbshi(1,is,cbirno+(ic-1)    )=-100.0_R8
          cbshi(7,is,cbirso+(ic-1)*3  )=-2.5_R8
          cbshi(7,is,cbirso+(ic-1)*3+1)=-2.5_R8
          cbshi(7,is,cbirso+(ic-1)*3+2)=-2.5_R8
          cbshi(7,is,cbirno+(ic-1)    )=-2.5_R8
          cbshe(0,cbirso+(ic-1)*3  )= 1.0e-18_R8
          cbshe(0,cbirso+(ic-1)*3+1)= 1.0e+4_R8
          cbshe(0,cbirso+(ic-1)*3+2)= 1.0e-18_R8
          cbshe(0,cbirno+(ic-1)    )= 1.0e-18_R8
          cbshe(1,cbirso+(ic-1)*3  )=-100.0_R8
          cbshe(1,cbirso+(ic-1)*3+2)=-100.0_R8
          cbshe(1,cbirno+(ic-1)    )=-100.0_R8
          cbshe(2,cbirso+(ic-1)*3  )=-1.0e-4_R8
          cbshe(2,cbirso+(ic-1)*3+2)=-1.0e-4_R8
          cbshe(2,cbirno+(ic-1)    )=-1.0e-4_R8
          cbshe(7,cbirso+(ic-1)*3  )=-2.5_R8
          cbshe(7,cbirso+(ic-1)*3+1)=-2.5_R8
          cbshe(7,cbirso+(ic-1)*3+2)=-2.5_R8
          cbshe(7,cbirno+(ic-1)    )=-2.5_R8
        enddo
      enddo
      do is = 0, ns-1
        if (is_neutral(is)) then
          continue
        else
          cbsmo(2,is,cbirwe)= 1.0e10_R8
          cbsmo(2,is,cbirea)= 1.0e10_R8
          cbshi(3,is,cbirwe)=-0.1_R8
          cbshi(3,is,cbirea)=-0.1_R8
          if (nint(zn(is)).eq.1 .or. nint(zn(is)).eq.2  .or.
     &        nint(zn(is)).eq.7 .or. nint(zn(is)).eq.10 .or.
     &        nint(zn(is)).eq.18) then
            cbrec(0,is,cbirwe)= 1.0_R8
            cbrec(0,is,cbirea)= 1.0_R8
            cbrec(1,is,cbirwe)= 0.3_R8
            cbrec(1,is,cbirea)= 0.3_R8
          end if
        end if
        cbsna(7,is,cbirwe)=-1.0_R8
        cbsna(7,is,cbirea)=-1.0_R8
        cbsmo(4,is,cbirwe)=-1.0e10_R8
        cbsmo(4,is,cbirea)=-1.0e10_R8
        cbshi(0,is,cbirwe)= 1.0e-18_R8
        cbshi(0,is,cbirea)= 1.0e-18_R8
        cbshi(1,is,cbirwe)=-100.0_R8
        cbshi(1,is,cbirea)=-100.0_R8
        cbshi(7,is,cbirwe)=-1.5_R8
        cbshi(7,is,cbirea)=-1.5_R8
        cbshe(0,cbirwe)= 1.0e-18_R8
        cbshe(0,cbirea)= 1.0e-18_R8
        cbshe(1,cbirwe)=-100.0_R8
        cbshe(1,cbirea)=-100.0_R8
        cbshe(3,cbirwe)=-0.1_R8
        cbshe(3,cbirea)=-0.1_R8
        cbshe(7,cbirwe)=-1.5_R8
        cbshe(7,cbirea)=-1.5_R8
        cbsch(6,cbirwe)= 1.0_R8
        cbsch(6,cbirea)= 1.0_R8
        cbsch(7,cbirwe)= 0.5_R8
        cbsch(7,cbirea)= 0.5_R8
      end do

c Fill out /b2cmpt/ arrays
      cfdf0=0.0_R8
      cfdna=0.0_R8
      cfdpa=0.0_R8
      cfvla=0.0_R8
      cfvsa=0.0_R8
      cfhci=0.0_R8
      cfhce=0.0_R8
      cfsig=0.0_R8
      cfalf=0.0_R8
      cflim=0.0_R8
      do is = 0, ns-1
        if (is_neutral(is)) then
          cfdf0(2,is)= 1.0_R8
          if (nint(zn(is)).eq.1) then
            cfdf0(3,is)= 5.0e-20_R8
            cfdf0(4,is)= 1.5e-18_R8
          else if (nint(zn(is)).eq.2) then
            cfdf0(3,is)= 2.0e-20_R8
            cfdf0(4,is)= 5.0e-20_R8
          else if (nint(zn(is)).eq.4) then
            cfdf0(3,is)= 1.0e-20_R8
            cfdf0(4,is)= 3.0e-20_R8
          else if (nint(zn(is)).eq.6) then
            cfdf0(3,is)= 5.0e-20_R8
            cfdf0(4,is)= 1.5e-18_R8
          else if (nint(zn(is)).eq.7) then
            cfdf0(3,is)= 1.5e-20_R8
            cfdf0(4,is)= 5.5e-20_R8
          else if (nint(zn(is)).eq.10) then
            cfdf0(3,is)= 1.0e-20_R8
            cfdf0(4,is)= 7.0e-21_R8
          else if (nint(zn(is)).eq.18) then
            cfdf0(3,is)= 2.0e-20_R8
            cfdf0(4,is)= 5.0e-20_R8
          end if
          if (.not.ni_driven_4) then
            cfdpa(2,is)= 1.0_R8
          else
            cfdna(2,is)= 1.0_R8
          endif
          cfvsa(2,is)= 1.0_R8
       else
          if (dflagn_4.eq.0) then
            cfdna(0,is)= difni_4(ifl(is))
          else if (dflagn_4.eq.1) then
            cfdna(1,is)= fudgen_4/1.0e20_R8*difni_4(ifl(is))
          else if (dflagn_4.eq.2) then
            cfdna(3,is)= fudgeb_4*difni_4(ifl(is))
          else if (dflagn_4.eq.4) then
            cfdna(0,is)= difni_4(ifl(is))
            cfdna(7,is)= 1.0_R8
          else
            cfdna(0,is)= difni_4(ifl(is))
            write(*,*) 'DFLAGN = ', dflagn_4,
     .       ' model not foreseen in SOLPS5.0!'
            write(*,*) 'Using default DIFNI value. '
          endif
          cfdpa(0,is)= difpr_4(ifl(is))
          if (dflagvconv_4.eq.0) then
            cfvla(0,is)= vconv_4(ifl(is))
          else if (dflagvconv_4.eq.4) then
            cfvla(0,is)= vconv_4(ifl(is))
            cfdna(7,is)= 1.0_R8
          else
            cfvla(0,is)= vconv_4(ifl(is))
            if (dflagvconv_4.ne.-10) then
              write(*,*) 'DFLAGVCONV = ', dflagvconv_4,
     .         ' model not foreseen in SOLPS5.0!'
              write(*,*) 'Using default VCONV value. '
            endif
          endif
          cfvsa(0,is)= travis_4(ifl(is))
        endif
        if (dflagti_4.eq.0) then
          cfhci(0,is)= kyi_4*kxi_4
        else if (dflagti_4.eq.1) then
          cfhci(1,is)= fudgetin_4/1.0e20_R8*kyi_4*kxi_4
        else if (dflagti_4.eq.2) then
          cfhci(3,is)= fudgetib_4*kyi_4*kxi_4
        else if (dflagti_4.eq.4) then
          cfhci(0,is)= kyi_4*kxi_4
          cfhci(7,is)= 1.0_R8
        else
          cfhci(0,is)= kyi_4*kxi_4
          write(*,*) 'DFLAGTI = ', dflagti_4,
     .     ' model not foreseen in SOLPS5.0!'
          write(*,*) 'Using default KYI value. '
        endif
      end do
      if (dflagte_4.eq.0) then
        cfhce(0)= kye_4*kxe_4
      else if (dflagte_4.eq.1) then
        cfhce(1)= fudgeten_4/1.0e20_R8*kye_4*kxe_4
      else if (dflagte_4.eq.2) then
        cfhce(3)= fudgeteb_4*kye_4*kxe_4
      else if (dflagte_4.eq.4) then
        cfhce(0)= kye_4*kxe_4
        cfhce(7)= 1.0_R8
      else
        cfhce(0)= kye_4*kxe_4
        write(*,*) 'DFLAGTE = ', dflagte_4,
     .   ' model not foreseen in SOLPS5.0!'
        write(*,*) 'Using default KYE value. '
      endif
      cfsig(0)= 1.0e-7_R8
      cfalf(0)= 0.0_R8
      cflim(0)= flim_4
      cflim(1)= flimi_4
      cflim(2)= flimv_4
      cflim(3)= 0.5_R8
      cflim(4)= 0.5_R8

c Fill out b2mod_residuals data
      resco = 0.0_R8
      reshe = 0.0_R8
      reshi = 0.0_R8
      resmo = 0.0_R8
      resmt = 0.0_R8
      respo = 0.0_R8

c Fill out b2mod_sources data
      sch = 0.0_R8
      she = 0.0_R8
      shi = 0.0_R8
      smo = 0.0_R8
      smq = 0.0_R8
      sna = 0.0_R8
      rsana = 0.0_R8
      rsahi = 0.0_R8
      rsamo = 0.0_R8
      rrana = 0.0_R8
      rrahi = 0.0_R8
      rramo = 0.0_R8
      rqahe = 0.0_R8
      rqrad = 0.0_R8
      rcxna = 0.0_R8
      rcxhi = 0.0_R8
      rcxmo = 0.0_R8
      b2stbr_sna = 0.0_R8
      b2stbr_smo = 0.0_R8
      b2stbr_she = 0.0_R8
      b2stbr_shi = 0.0_R8
      b2stbr_sch = 0.0_R8
      b2stbc_sna = 0.0_R8
      b2stbc_smo = 0.0_R8
      b2stbc_she = 0.0_R8
      b2stbc_shi = 0.0_R8
      b2stbc_sch = 0.0_R8
      b2sihs_divue = 0.0_R8
      b2sihs_divua = 0.0_R8
      b2sihs_exbe = 0.0_R8
      b2sihs_exba = 0.0_R8
      b2sihs_visa = 0.0_R8
      b2sihs_joule = 0.0_R8
      b2sihs_fraa = 0.0_R8
      b2sihs_str = 0.0_R8
      b2npmo_smaf = 0.0_R8
      b2npmo_smag = 0.0_R8
      b2npmo_smav = 0.0_R8
      ext_sna = 0.0_R8
      ext_smo = 0.0_R8
      ext_she = 0.0_R8
      ext_shi = 0.0_R8
      ext_sch = 0.0_R8

c Fill out b2mod_transport arrays
      calf = 0.0_R8
      cdna = 0.0_R8
      cdpa = 0.0_R8
      ceqp = 0.0_R8
      chce = 0.0_R8
      chci = 0.0_R8
      chve = 0.0_R8
      chvemx = 0.0_R8
      chvi = 0.0_R8
      chvimx = 0.0_R8
      csig = 0.0_R8
      cvla = 0.0_R8
      cvsa = 0.0_R8
      cthe = 0.0_R8
      cthi = 0.0_R8
      csigin = 0.0_R8
      cvsa_cl = cvsa

c Fill out b2mod_anomalous_transport arrays
      sig0 = 0.0_R8
      hce0 = 0.0_R8
      alf0 = 0.0_R8
      hci0 = 0.0_R8
      hcib = 0.0_R8
      dpa0 = 0.0_R8
      dna0 = 0.0_R8
      vsa0 = 0.0_R8
      vla0 = 0.0_R8
      csig_an = 0.0_R8

c Fill out b2mod_neutr_src_scaling
      sclstra = sclstra_4
      sclrtio = sclrtio_4

c Fill out b2mod_time
      tim = time_4

      call subend()
      return
      end subroutine b2conv_plasma_2
c
      subroutine b2conv_input_2(nx,ny,ns)
      use b2mod_types
      use b2mod_ma28
      use b2mod_indirect
      use b2mod_user_namelist
      use b2mod_eirene_globals
      use b2mod_neutrals_namelist
      use b2mod_boundary_namelist
      use b2mod_numerics_namelist
      use b2mod_b2cmpa
      use b2mod_b2cmpb
      use b2mod_b2cmpt
      use comsou
     , , only: nlpls, nspez
      implicit none

      integer nx,ny,ns
      integer is, js, ib, ireg, ireg_4

      external xertst

      call subini('b2convi2')

c Fill out some b2mod_boundary_namelist data
      call alloc_b2mod_boundary(nx, ny, ns, nbc_4, nniso)
      nbc = nbc_4
      ncbs = ncbs_4
      bcchar(1:nbc) = bcchar_4(1:nbc)
      bcpos(1:nbc) = bcpos_4(1:nbc)-1
      bcstart(1:nbc) = bcstart_4(1:nbc)-1
      bcend(1:nbc) = bcend_4(1:nbc)-1
      bcene(1:nbc) = bcene_4(1:nbc)
      do ib = 1, nbc
        if (bceni_4(ib).eq.10) then
          bceni(ib) = 19
        else if (bceni_4(ib).eq.13) then
          bceni(ib) = 11
        else
          bceni(ib) = bceni_4(ib)
        end if
      end do
      enepar(1:nbc,1:2) = enepar_4(1:nbc,1:2)
      enipar(1:nbc,1:2) = enipar_4(1:nbc,1:2)
      do is = 0, ns-1
        if (ifl(is).ne.0) then
          do ib = 1, nbc
            if (bccon_4(ifl(is),ib).eq.10) then
              bccon(is,ib) = 15
            else if (bccon_4(ifl(is),ib).eq.11) then
              bccon(is,ib) = 10
            else
              bccon(is,ib) = bccon_4(ifl(is),ib)
            end if
          end do
          bcmom(is,1:nbc) = bcmom_4(ifl(is),1:nbc)
          conpar(is,1:nbc,1:2) = conpar_4(ifl(is),1:nbc,1:2)
          mompar(is,1:nbc,1:2) = mompar_4(ifl(is),1:nbc,1:2)
          niiso(is) = niiso_4(ifl(is))
        endif
      end do
      gammai = gammai_4
      lbndusr = lbndusr_4
      lfeedback = lfeedback_4
      teiso = teiso_4
      tiiso = tiiso_4
      lcbs(1:ncbs) = lcbs_4(1:ncbs)

c Fill out b2mod_neutrals_namelist data
      sput_dst =-1
      sput_dst2=-1
      sput_dst3=-1
      do is = 0, ns-1
        if (is_neutral(is) .and. .not.
     &   (nint(zn(is)).eq.1 .or. nint(zn(is)).eq.2  .or.
     &    nint(zn(is)).eq.7 .or. nint(zn(is)).eq.10 .or.
     &    nint(zn(is)).eq.18)) then
          if (sput_dst.ne.-1.and.sput_dst2.ne.-1.and.sput_dst3.ne.-1)
     >     write(*,*) 'No more than 3 sputtering species are expected !'
          if (sput_dst.ne.-1.and.sput_dst2.ne.-1.and.sput_dst3.eq.-1)
     >     sput_dst3=is
          if (sput_dst.ne.-1.and.sput_dst2.eq.-1) sput_dst2=is
          if (sput_dst.eq.-1) sput_dst=is
        end if
      end do
      write(*,*) 'sput_dst: ',sput_dst
      call alloc_b2mod_neutrals
     . (nx, ny, ns, natm, nmol, nion, nstrai_4, nsts, sput_dst)
      nstrai = nstrai_4
      nflai = nfla_4
      crcstra(1:nstrai) = crcstra_4(1:nstrai)
      do is = 1, nstrai
        if (rcpos_4(is).eq.0 .and. rcstart_4(is).eq.0 .and.
     &      rcend_4(is).eq.0) then
          rcpos(is) = rcpos_4(is)
          rcstart(is) = rcstart_4(is)
          rcend(is) = rcend_4(is)
        else
          rcpos(is) = rcpos_4(is)-1
          rcstart(is) = rcstart_4(is)-1
          rcend(is) = rcend_4(is)-1
        end if
      end do
      do is = 0, ns-1
        if (ifl(is).ne.0) then
          recyc(is,1:nstrai) = recyc_4(ifl(is),1:nstrai)
        end if
      end do
      eirene_step_dt = dt_eirene_fudge_4
      eirene_step_cpu = eirene_step_cpu_4
      eirene_mod = eirene_mod_4
      userfluxparm(1:nstrai,1:2) = userfluxparm_4(1:nstrai,1:2)
#ifndef NO_B2_CHEM_SPUT
      chemical_sputter_yield = chemical_sputter_yield_4
      fchar_chemical = fchar_chemical_4
      igass_chemical = igass_chemical_4
      itsput_chemical = itsput_chemical_4
      issput_chemical = issput_chemical_4
#endif
      do ib = 1, nstrai
        do is = 1, nspecies_4
          if (lstrascl_4(ib,is).ge.0) then
            lstrascl(ib,is) = lstrascl_4(ib,is)
          else
            lstrascl(ib,is) = 0
          end if
        end do
      end do
      l_neutrad = l_neutrad_4
      l_neutflux = l_neutflux_4
      lmolscl = lmolscl_4
      ksns(1:nstrai) = ksns_4(1:nstrai)
      lcns = lcns_4
      lsns(1:nstrai) = lsns_4(1:nstrai)
      ltns = ltns_4
      msns(1:2,1:nstrai) = msns_4(1:2,1:nstrai)
      mlcmp = mlcmp_4
      gpfc(1:natm,1:nstrai) = gpfc_4(1:natm,1:nstrai)
      do is = 1, nstrai
        if (crcstra(is).eq.'V') volrecstart(is) = volrecstart_4
        if (nspzi_4(is).ne.0) species_start(is) = is1(nspzi_4(is))
        if (species_start(is).gt.0 .and. species_start(is).lt.ns) then
          if (.not.(nlpls(is).and.nspez(is).gt.0) .and.
     &        .not.is_neutral(species_start(is))) then
            if (lnext(species_start(is)-1,species_start(is)))
     >       species_start(is) = species_start(is)-1
          endif
        endif
        if (nspze_4(is).ne.0) then
          species_end(is) = is1(nspze_4(is))
        else
          species_end(is) = ns-1
        endif
      end do
      volrecinc = volrecinc_4
      volrecwt = volrecwt_4
      debug_flags = debug_flags_4
      do is = 1, 4
        if (rf_neut_4(is).ne.-1.0_R8) rf_neut = rf_neut_4
      end do

c Fill out some b2mod_ma28 data
      nltrsol_5p = nltrsol_4

c Fill out b2mod_numerics_namelist data
      call alloc_b2mod_numerics(nx,ny,ns)
      do ireg = 1, nnreg(0)
        ireg_4 = mod(ireg,4)
        if (ireg_4.eq.0) ireg_4 = 4
        dtee(ireg) = dtee_4(ireg_4)
        dtei(ireg) = dtei_4(ireg_4)
        do is = 0, ns-1
          if (ifl(is).ne.0) then
            dtco(is,ireg) = dtco_4(ifl(is),ireg_4)
            dtmo(is,ireg) = dtmo_4(ifl(is),ireg_4)
          end if
        end do
      end do
      time_factor_required = time_factor_required_4

c Fill out b2mod_user_namelist data
      npfrgrp = npfrgrp_4
      lpfrgrp = lpfrgrp_4
      ipfrgrp = ipfrgrp_4
      jpfrgrp = jpfrgrp_4
      gpfrgrp = gpfrgrp_4
      nntrgrp = nntrgrp_4
      lntrgrp = lntrgrp_4
      intrgrp = intrgrp_4
      jntrgrp = jntrgrp_4
      gntrgrp = gntrgrp_4
      lhetrgts = lhetrgts_4
      lpfrb_i = lpfrb_i_4
      lpfrb_o = lpfrb_o_4
      lpfrt_i = lpfrt_i_4
      lpfrt_o = lpfrt_o_4
      lpfrs_pmp =  lpfrs_pmp_4
      j_he_at = j_he_at_4
      j_h_at(1) = j_h_at_4
      l_h_mol(1:nmol,1) = l_h_mol_4(1:nmol)
      fusion_power = fusion_power_4
      Spmp_He_to_D = Spmp_He_to_D_4
      Spmp_nom = Spmp_nom_4
      scale_He = scale_He_4
      print_isat = print_isat_4

      call subend()
      return
      end subroutine b2conv_input_2
c
      subroutine write_b2ag(nx,ny)
      implicit none
      integer nx, ny
      character tab
      character*8 device
#ifndef NO_GETENV
      integer lenval, ierror
#ifndef USE_PXFGETENV
      intrinsic get_environment_variable
#endif
#endif
      logical streql
      external streql

      tab=char(9)
      write(*,*) 'Writing b2ag.dat'
      open(99,file='b2ag.dat',status='unknown')
      write(99,'(a)') '*dimens     (nx, ny, nx1, ny1; free format)'
      write(99,'(4(2x,i3))') nx, ny, nx, ny
      write(99,'(a)') '*param      (param(0:99); free format)'
      write(99,'(a)') '  -2.0, 99*0.0'
      write(99,'(3a)')
     . '''b2agfs_geometry'''//tab//'''',trim(sonnetfile_4),''''
#ifdef JET
      device='jet'
#else
      device='iter'
#endif
#ifndef NO_GETENV
#ifdef USE_PXFGETENV
      CALL PXFGETENV ('DEVICE', 0, device, lenval, ierror)
#else
      call get_environment_variable
     . ('DEVICE', status=ierror, length=lenval)
      if (ierror.eq.0) call get_environment_variable
     . ('DEVICE', value=device)
#endif
#endif
      if (streql(device,'iter'))
     > write(99,'(a)') '''b2agfs_pit_rescale''       ''-1.0'''
      close(99)
      return
      end subroutine write_b2ag
c
      subroutine write_b2ai(ns)
      use b2mod_types
      use b2mod_b2cmpa
      implicit none
      integer ns
      integer is
      real (kind=R8), allocatable :: na0(:)
      character*5 specs(0:ns-1)
      character*22 hlp_frm

      allocate(na0(0:ns-1))
      write(*,*) 'Writing b2ai.dat'
      open(99,file='b2ai.dat',status='unknown')
      write(99,'(a)') '*dimens         (ns; free format)'
      write(99,'(2x,i3)') ns
      write(99,'(a)')
     . '*label          (lblps, character*60; free format)'
      write(99,'(2x,a)') ''''//trim(label_4)//''''
      write(99,'(a)') '*specs    zamin    zamax       zn      am'
      do is = 0, ns-1
        if (is.lt.10) then
          write(specs(is),'(a,i1,a)') '  ''',is,''''
        else if (is.lt.100) then
          write(specs(is),'(a,i2,a)')  ' ''',is,''''
        else
          write(specs(is),'(a,i3,a)')   '''',is,''''
        end if
        write(99,'(1x,a5,4(4x,f4.1,1x))')
     .   specs(is),zamin(is),zamax(is),zn(is),am(is)
        if (nint(zn(is)).eq.1.and.zamin(is).gt.0.0_R8) then
          na0(is) = 1.0e19_R8
        else if (zamin(is).gt.0.0_R8) then
          na0(is) = 1.0e16_R8
        else
          na0(is) = 1.0e8_R8
        end if
      end do
      write(99,'(a)') '*naini          (na0(0:ns-1); free format)'
      write(hlp_frm,'(a,i3,a)') '(1p,',ns,'(2x,e8.1))'
      write(99,hlp_frm) (na0(is),is=0,ns-1)
      write(99,'(a)') '*ttini          (tt0; free format)'
      write(99,'(3x,a)') '1.0e2'
      close(99)
      deallocate(na0)
      return
      end subroutine write_b2ai
c
      subroutine write_b2ah(ns)
      use b2mod_types
      use b2mod_b2cmpa
      use b2mod_b2cmpb
      use b2mod_b2cmpt
      implicit none
      integer ns
      character*5 specs(-1:ns-1)
      character*27 lbreg(0:cbnrmx-1)
      character*80 column_header
      character*22 hlp_frm
      integer i, is, ireg, nreg, len

      len = 0
      do i = 0, 7
        column_header(len+1:len+6) = '     ('
        len=len+6
        write(column_header(len+1:len+1),'(i1)') i
        len=len+1
        column_header(len+1:len+3) = ')  '
        len=len+3
      end do
      write(*,*) 'Writing b2ah.dat'
      open(99,file='b2ah.dat',status='unknown')
      write(99,'(a)') '*dimens         (ns; free format)'
      write(99,'(2x,i3)') ns
      write(99,'(a)')
     . '*label          (lblps, character*60; free format)'
      write(99,'(2x,a)') ''''//trim(label_4)//''''
      write(99,'(a)') '*b2cmpa         basic parameters'
      write(99,'(a)') '*specs      zamin    zamax    zn      am'
      write(specs(-1),'(a)') ' ''-1'''
      do is = 0, ns-1
        if (is.lt.10) then
          write(specs(is),'(a,i1,a)') '  ''',is,''''
        else if (is.lt.100) then
          write(specs(is),'(a,i2,a)')  ' ''',is,''''
        else
          write(specs(is),'(a,i3,a)')   '''',is,''''
        end if
        write(99,'(1x,a5,4(4x,f4.1,1x))')
     .   specs(is),zamin(is),zamax(is),zn(is),am(is)
      end do
      write(99,'(a)') '*b2cmpb         boundary conditions'
      write(99,'(a)') '*cbregs'
      write(hlp_frm,'(a,i1,a)') '(a,5x,i1,',cbnrso,'(3x,f7.4))'
      write(99,hlp_frm) '''south''', cbnrso,
     . (cbrbrk(i),i=cbirso,cbirso+cbnrso-1)
      write(hlp_frm,'(a,i1,a)') '(a,5x,i1,',cbnrno,'(3x,f7.4))'
      write(99,hlp_frm) '''north''', cbnrno,
     . (cbrbrk(i),i=cbirno,cbirno+cbnrno-1)
      write(hlp_frm,'(a,i1,a)') '(a,5x,i1,',cbnrwe,'(3x,f7.4))'
      write(99,hlp_frm) '''west'' ', cbnrwe,
     . (cbrbrk(i),i=cbirwe,cbirwe+cbnrwe-1)
      write(hlp_frm,'(a,i1,a)') '(a,5x,i1,',cbnrea,'(3x,f7.4))'
      write(99,hlp_frm) '''east'' ', cbnrea,
     . (cbrbrk(i),i=cbirea,cbirea+cbnrea-1)
      nreg = cbnrso + cbnrno + cbnrwe + cbnrea
      lbreg(cbirso  :cbirso+cbnrso-1:3)='''south, private flux'''
      lbreg(cbirso+1:cbirso+cbnrso-1:3)='''south, core plasma'' '
      lbreg(cbirso+2:cbirso+cbnrso-1:3)='''south, private flux'''
      lbreg(cbirno:cbirno+cbnrno-1)='''north, SOL/DIV outer wall'''
      lbreg(cbirwe:cbirwe+cbnrwe-1)='''west, target plate'' '
      lbreg(cbirea:cbirea+cbnrea-1)='''east, target plate'' '
      do ireg = 0, nreg-1
        write(99,'(a)') '*region'
        write(99,'(i2,2x,a)') ireg,lbreg(ireg)
        write(99,'(a)') '*cbsna'//column_header
        do is = 0, ns-1
          write(99,'(1x,a5,1p,8(1x,e9.2))') specs(is),
     .     (cbsna(i,is,ireg),i=0,7)
        end do
        write(99,'(a)') '*cbsmo'//column_header
        do is = 0, ns-1
          write(99,'(1x,a5,1p,8(1x,e9.2))') specs(is),
     .     (cbsmo(i,is,ireg),i=0,7)
        end do
        write(99,'(a)') '*cbshi'//column_header
        do is = 0, ns-1
          write(99,'(1x,a5,1p,8(1x,e9.2))') specs(is),
     .     (cbshi(i,is,ireg),i=0,7)
        end do
        write(99,'(a)') '*cbshe'//column_header
        write(99,'(1x,a5,1p,8(1x,e9.2))') specs(-1),
     .     (cbshe(i,ireg),i=0,7)
        write(99,'(a)') '*cbsch'//column_header
        write(99,'(1x,a5,1p,8(1x,e9.2))') specs(-1),
     .     (cbsch(i,ireg),i=0,7)
        write(99,'(a)') '*cbrec'//column_header
        do is = 0, ns-1
          write(99,'(1x,a5,1p,8(1x,e9.2))') specs(is),
     .     (cbrec(i,is,ireg),i=0,7)
        end do
        write(99,'(a)') '*cbmsa'//column_header
        write(99,'(1x,a5,1p,8(1x,e9.2))') specs(-1),
     .     (cbmsa(i,ireg),i=0,7)
        write(99,'(a)') '*cbmsb'//column_header
        do is = 0, ns-1
          write(99,'(1x,a5,1p,8(1x,e9.2))') specs(is),
     .     (cbmsb(i,is,ireg),i=0,7)
        end do
      end do
      write(99,'(a)') '*b2cmpt  transport coefficients'
      write(99,'(a)') '*cfdf0'//column_header
      do is = 0, ns-1
        write(99,'(1x,a5,1p,8(1x,e9.2))') specs(is),
     .   (cfdf0(i,is),i=0,7)
      end do
      write(99,'(a)') '*cfdna'//column_header
      do is = 0, ns-1
        write(99,'(1x,a5,1p,8(1x,e9.2))') specs(is),
     .   (cfdna(i,is),i=0,7)
      end do
      write(99,'(a)') '*cfdpa'//column_header
      do is = 0, ns-1
        write(99,'(1x,a5,1p,8(1x,e9.2))') specs(is),
     .   (cfdpa(i,is),i=0,7)
      end do
      write(99,'(a)') '*cfvla'//column_header
      do is = 0, ns-1
        write(99,'(1x,a5,1p,8(1x,e9.2))') specs(is),
     .   (cfvla(i,is),i=0,7)
      end do
      write(99,'(a)') '*cfvsa'//column_header
      do is = 0, ns-1
        write(99,'(1x,a5,1p,8(1x,e9.2))') specs(is),
     .   (cfvsa(i,is),i=0,7)
      end do
      write(99,'(a)') '*cfhci'//column_header
      do is = 0, ns-1
        write(99,'(1x,a5,1p,8(1x,e9.2))') specs(is),
     .   (cfhci(i,is),i=0,7)
      end do
      write(99,'(a)') '*cfhce'//column_header
      write(99,'(1x,a5,1p,8(1x,e9.2))') specs(-1),
     .  (cfhce(i),i=0,7)
      write(99,'(a)') '*cfsig'//column_header
      write(99,'(1x,a5,1p,8(1x,e9.2))') specs(-1),
     .  (cfsig(i),i=0,7)
      write(99,'(a)') '*cfalf'//column_header
      write(99,'(1x,a5,1p,8(1x,e9.2))') specs(-1),
     .  (cfalf(i),i=0,7)
      write(99,'(a)') '*cflim'//
     .  '    cflme     cflmi     cflmv     cflal     cflab     ...'
      write(99,'(1x,a5,1p,8(1x,e9.2))') specs(-1),
     .  (cflim(i),i=0,7)
      write(99,'(a)') '*endphy'
      close(99)
      return
      end subroutine write_b2ah
c
      subroutine write_b2ar(ns)
      use b2mod_types
      use b2mod_b2cmpa
      implicit none
      integer ns

      real (kind=R8) :: tlo, thi
      parameter (tlo = 1.0e-1_R8, thi = 1.0e4_R8)
      real (kind=R8) :: nlo, nhi
      parameter (nlo = 1.0e16_R8, nhi = 1.0e21_R8)
      character*8 flag
      real (kind=R8) :: tailep
      parameter (tailep = 0.08_R8)
      character tab
      logical found
      integer fix_cx
      data fix_cx /2/
      integer i, is

      tab=char(9)
      flag='''strahl'''
      write(*,*) 'Writing b2ar.dat'
      open(99,file='b2ar.dat',status='unknown')
      write(99,'(a)') '*tlohi          (tlo, thi; real, free format)'
      write(99,'(1p,2e8.1)') tlo, thi
      write(99,'(a)') '*nlohi          (nlo, nhi; real, free format)'
      write(99,'(1p,2e8.1)') nlo, nhi
      write(99,'(a)') '*numnuc         (nnuc; integer, free format)'
      write(99,'(i2)') nspecies_4
      write(99,'(a)')
     . '*nucspec       (nz, izlo, izhi; integers, one triplet per line)'
      is = 0
      do i = 1, nspecies_4
        is = is+nfluids_4(i)
        write(99,'(i2,2x,i2,2x,i2)') nint(zn(is)),0,nfluids_4(i)
        is = is+1
      end do
      write(99,'(a)')
     . '*flag           (either ''adpak'' or ''strahl'', free format)'
      write(99,'(1x,a)') flag
      write(99,'(a)') '*tailep         (real, free format)'
      write(99,'(1f7.3)') tailep
      found = .false.
      do is = 0, ns-1
        found = found.or.nint(zn(is)).gt.1
      enddo
      if (found) then
        write(99,'(a,i1,a)') '''b2ardr_fix_cx'''//tab//'''',fix_cx,''''
      endif
      close(99)
      return
      end subroutine write_b2ar
c
      subroutine write_b2mn(nx, ny, ns)
      use b2mod_types
      use b2mod_ma28
      use b2mod_b2cmpa
      use b2mod_b2cmpb
      use b2mod_b2cmpt
      implicit none
      integer nx, ny, ns
      character tab
      character*10 hlp_frm
      integer i, is, is0
      integer len_of_digits
      external len_of_digits

      tab=char(9)
      write(*,*) 'Writing b2mn.dat.4 and b2mn.dat.5'
      open(99,file='b2mn.dat.4',status='unknown')
      write(99,'(a)') '*label          (lblmn: character*60)'
      write(99,'(2x,a)') ''''//trim(label_4)//''''
      write(99,'(a)') '*b2cmpa         basic parameters'
      write(99,'(a)') '*b2cmpb         boundary conditions'
      write(99,'(a)') '*b2cmpt         transport coefficients'
      write(99,'(a)') '*endphy'

      open(98,file='b2mn.dat.5',status='unknown')
      write(98,'(a)') '*label          (lblmn: character*60)'
      write(98,'(2x,a)') ''''//trim(label_4)//''''
      write(98,'(a)') '*b2cmpa         basic parameters'
      write(98,'(a)') '*b2cmpb         boundary conditions'
      write(98,'(a)') '*b2cmpt         transport coefficients'
      write(98,'(a)') '*endphy'

      write(hlp_frm, '(a,i1,a)')
     . '(a,i',len_of_digits(istepi_4),',a)'
      write(99,hlp_frm)
     . '''b2mndr_ntim'''//tab//tab//tab//'''',istepi_4,''''
      write(98,hlp_frm)
     . '''b2mndr_ntim'''//tab//tab//tab//'''',istepi_4,''''
      if (.not.autotimestep_4) then
        write(99,'(a,1pe9.2,a)')
     .   '''b2mndr_dtim'''//tab//tab//tab//'''',dti_4,''''
        write(98,'(a,1pe9.2,a)')
     .   '''b2mndr_dtim'''//tab//tab//tab//'''',dti_4,''''
      else
        write(99,'(a,1pe9.2,a)')
     .   '''b2mndr_dtim'''//tab//tab//tab//'''',dtc_4,''''
        write(99,'(a,1pe9.2,a)')
     .   '''b2mndr_dt_min'''//tab//tab//tab//'''',dtmin_4,''''
        write(99,'(a,1pe9.2,a)')
     .   '''b2mndr_dt_max'''//tab//tab//tab//'''',dtmax_4,''''
        write(99,'(a,1pe9.2,a)')
     .   '''b2mndr_delta_min'''//tab//tab//'''',
     .   maxconverge_increase_timestep_4,''''
        write(99,'(a,1pe9.2,a)')
     .   '''b2mndr_delta_max'''//tab//tab//'''',
     .   maxconverge_decrease_timestep_4,''''
        write(99,'(a)')
     .   '''b2mndr_dt_change_dec'''//tab//tab//'''0.5'''
        write(99,'(a)')
     .   '''b2mndr_dt_change_inc'''//tab//tab//'''1.1'''
        write(98,'(a,1pe9.2,a)')
     .   '''b2mndr_dtim'''//tab//tab//tab//'''',dtc_4,''''
        write(98,'(a,1pe9.2,a)')
     .   '''b2mndr_dt_min'''//tab//tab//tab//'''',dtmin_4,''''
        write(98,'(a,1pe9.2,a)')
     .   '''b2mndr_dt_max'''//tab//tab//tab//'''',dtmax_4,''''
        write(98,'(a,1pe9.2,a)')
     .   '''b2mndr_delta_min'''//tab//tab//'''',
     .   maxconverge_increase_timestep_4,''''
        write(98,'(a,1pe9.2,a)')
     .   '''b2mndr_delta_max'''//tab//tab//'''',
     .   maxconverge_decrease_timestep_4,''''
        write(98,'(a)')
     .   '''b2mndr_dt_change_dec'''//tab//tab//'''0.5'''
        write(98,'(a)')
     .   '''b2mndr_dt_change_inc'''//tab//tab//'''1.1'''
      end if
      if (res_limit_nstage_4.gt.0.0_R8) then
        write(99,'(a,1pe9.2,a)')
     .   '''b2news_potok'''//tab//tab//tab//'''',res_limit_nstage_4,''''
        write(98,'(a,1pe9.2,a)')
     .   '''b2news_potok'''//tab//tab//tab//'''',res_limit_nstage_4,''''
      end if
      if (res_limit_job_4.gt.0.0_R8) then
        write(99,'(a,1pe9.2,a)')
     .   '''b2mndr_min_areshe'''//tab//tab//'''',res_limit_job_4,''''
        write(98,'(a,1pe9.2,a)')
     .   '''b2mndr_min_areshe'''//tab//tab//'''',res_limit_job_4,''''
        write(99,'(a,1pe9.2,a)')
     .   '''b2mndr_min_areshi'''//tab//tab//'''',res_limit_job_4,''''
        write(98,'(a,1pe9.2,a)')
     .   '''b2mndr_min_areshi'''//tab//tab//'''',res_limit_job_4,''''
        write(99,'(a,1pe9.2,a)')
     .   '''b2mndr_min_aresco'''//tab//tab//'''',res_limit_job_4,''''
        write(98,'(a,1pe9.2,a)')
     .   '''b2mndr_min_aresco'''//tab//tab//'''',res_limit_job_4,''''
      end if
      if (cpustop_4.ne.0.0_R8) then
        write(99,'(a,1pe9.2,a)')
     .   '''b2mndr_cpu'''//tab//tab//tab//'''',cpustop_4,''''
        write(98,'(a,1pe9.2,a)')
     .   '''b2mndr_cpu'''//tab//tab//tab//'''',cpustop_4,''''
      end if
      write(99,'(a)')
     . '''b2mndt_nstg0'''//tab//tab//tab//'''1'''
      write(98,'(a)')
     . '''b2mndt_nstg0'''//tab//tab//tab//'''1'''
      write(99,'(a)')
     . '''b2mndt_nstg1'''//tab//tab//tab//'''1'''
      write(98,'(a)')
     . '''b2mndt_nstg1'''//tab//tab//tab//'''1'''
      write(hlp_frm, '(a,i1,a)')
     . '(a,i',len_of_digits(nstagei_4),',a)'
      write(99,hlp_frm)
     . '''b2mndt_nstg2'''//tab//tab//tab//'''',nstagei_4,''''
      write(98,hlp_frm)
     . '''b2mndt_nstg2'''//tab//tab//tab//'''',nstagei_4,''''
      write(99,'(a,1pe9.2,a)')
     . '''b2mndt_rxf'''//tab//tab//tab//'''',rxfi_4,''''
      write(98,'(a,1pe9.2,a)')
     . '''b2mndt_rxf'''//tab//tab//tab//'''',rxfi_4,''''
      if (stylei_4.gt.1) then
        write(99,'(a)')
     .   '''b2mndt_moitlv'''//tab//tab//tab//'''1'''
        write(98,'(a)')
     .   '''b2mndt_moitlv'''//tab//tab//tab//'''1'''
      end if
      if (starting_time_4.ne.0.0_R8 .and. ltime_4.eq.0) then
        write(99,'(a,1pe9.2,a)')
     .   '''b2mndr_stim'''//tab//tab//tab//'''',starting_time_4,''''
        write(98,'(a,1pe9.2,a)')
     .   '''b2mndr_stim'''//tab//tab//tab//'''',starting_time_4,''''
      else
        write(99,'(a)')
     .   '''b2mndr_stim'''//tab//tab//tab//'''-1.0'''
        write(98,'(a)')
     .   '''b2mndr_stim'''//tab//tab//tab//'''-1.0'''
      end if
      if (nstepprint_4.ge.1 .and. lstime_4.ge.1) then
        write(hlp_frm, '(a,i1,a)')
     .   '(a,i',len_of_digits(nstepprint_4),',a)'
        write(99,hlp_frm)
     .   '''b2mndr_b2time'''//tab//tab//tab//'''',nstepprint_4,''''
        write(98,hlp_frm)
     .   '''b2mndr_b2time'''//tab//tab//tab//'''',nstepprint_4,''''
      else
        write(hlp_frm, '(a,i1,a)')
     .   '(a,i',len_of_digits(lstime_4),',a)'
        write(99,hlp_frm)
     .   '''b2mndr_b2time'''//tab//tab//tab//'''',lstime_4,''''
        write(98,hlp_frm)
     .   '''b2mndr_b2time'''//tab//tab//tab//'''',lstime_4,''''
      endif
      if (lmovie_4.gt.0) then
        write(hlp_frm, '(a,i1,a)')
     .   '(a,i',len_of_digits(lmovie_4),',a)'
        write(99,hlp_frm)
     .   '''b2mndr_mvinc'''//tab//tab//tab//'''',lmovie_4,''''
        write(98,hlp_frm)
     .   '''b2mndr_mvinc'''//tab//tab//tab//'''',lmovie_4,''''
      end if
      write(99,'(a)')
     . '''b2news_area_fix'''//tab//tab//'''3'''
      write(98,'(a)')
     . '''b2news_area_fix'''//tab//tab//'''3'''
      write(99,'(a)')
     . '''b2tral_mode'''//tab//tab//tab//'''2'''
      write(99,'(a)')
     . '''b2tqce_model'''//tab//tab//tab//'''2'''
      write(98,'(a)')
     . '''b2tqca_model'''//tab//tab//tab//'''1'''
      write(99,'(a)')
     . '''b2tqca_model'''//tab//tab//tab//'''2'''
      write(99,'(a)')
     . '''b2trno_pol_anom_scale'''//tab//tab//'''0.0'''
      write(99,'(a)')
     . '''b2tqna_transport_namelist'''//tab//'''1'''
      write(98,'(a)')
     . '''b2tqna_transport_namelist'''//tab//'''1'''
      write(99,'(a)')
     . '''b2stbc_boundary_namelist'''//tab//'''1'''
      write(98,'(a)')
     . '''b2stbc_boundary_namelist'''//tab//'''1'''
      write(99,'(a)')
     . '''b2stbr_neutrals_namelist'''//tab//'''1'''
      write(98,'(a)')
     . '''b2stbr_neutrals_namelist'''//tab//'''1'''
      if (lreitr_4) then
        write(99,'(a)')
     .   '''b2mndr_eirene'''//tab//tab//tab//'''1'''
        write(99,'(a)')
     .   '''b2mndr_rescale_neutrals'''//tab//'''1.0'''
        write(99,'(a)')
     .   '''b2mndr_rescale_neutrals_sources'''//tab//'''1.0e-10'''
        write(99,'(a)')
     .   '''eirene_dpc_fix'''//tab//tab//'''1'''
        write(99,'(a)')
     .   '''eirene_repeat_first_call'''//tab//'''1'''
        write(99,'(a)')
     .   '''eirene_extrap'''//tab//tab//tab//'''0'''
        write(99,'(a)')
     .   '''eirene_fixmap'''//tab//tab//tab//'''1'''
        write(99,'(a)')
     .   '''eirene_fixuub'''//tab//tab//tab//'''2'''
        write(99,'(a,i1,a)')
     .   '''eirene_ank_mods'''//tab//tab//'''',ank_mods,''''
        write(hlp_frm, '(a,i1,a)')
     .   '(a,i',len_of_digits(ionising_core),',a)'
        write(99,hlp_frm)
     .   '''eirene_ionising_core'''//tab//tab//'''',ionising_core,''''
        write(98,'(a)')
     .   '''b2mndr_eirene'''//tab//tab//tab//'''1'''
        write(98,'(a)')
     .   '''b2mndr_rescale_neutrals'''//tab//'''1.0'''
        write(98,'(a)')
     .   '''b2mndr_rescale_neutrals_sources'''//tab//'''1.0e-10'''
        write(98,'(a)')
     .   '''eirene_dpc_fix'''//tab//tab//'''1'''
        write(98,'(a)')
     .   '''eirene_repeat_first_call'''//tab//'''1'''
        write(98,'(a)')
     .   '''eirene_extrap'''//tab//tab//tab//'''0'''
        write(98,'(a)')
     .   '''eirene_fixmap'''//tab//tab//tab//'''1'''
        write(98,'(a,i1,a)')
     .   '''eirene_ank_mods'''//tab//tab//'''',ank_mods,''''
        write(98,hlp_frm)
     .   '''eirene_ionising_core'''//tab//tab//'''',ionising_core,''''
        if (nstepout_4.ge.1) then
          write(hlp_frm, '(a,i1,a)')
     .   '(a,i',len_of_digits(nstepout_4),',a)'
          write(99,hlp_frm)
     .     '''ank_tracing'''//tab//tab//tab//'''',nstepout_4,''''
          write(98,hlp_frm)
     .     '''ank_tracing'''//tab//tab//tab//'''',nstepout_4,''''
        else
          write(99,'(a)')
     .     '''ank_tracing'''//tab//tab//tab//'''1'''
          write(98,'(a)')
     .     '''ank_tracing'''//tab//tab//tab//'''1'''
        end if
      end if
      if (dflagkxe_4.ne.0 .or. dflagkxi_4.ne.0) then
        write(99,'(a)') '''b2trcl_lluciani'''//tab//tab//'''2'''
        write(98,'(a)') '''b2trcl_lluciani'''//tab//tab//'''1'''
      end if
      if (lvis21_4) then
        write(99,'(a)') '''b2trcl_lvis21'''//tab//tab//tab//'''1'''
        write(98,'(a)') '''b2trcl_lvis21'''//tab//tab//tab//'''1'''
      end if
      if (dflaglnlam_4.eq.0.0_R8) then
        write(99,'(a)')
     . '''b2trcl_lambda'''//tab//tab//tab//'''12.0'''
        write(98,'(a)')
     . '''b2trcl_lambda'''//tab//tab//tab//'''12.0'''
      else if (dflaglnlam_4.gt.0.0_R8) then
        write(99,'(a,1pe9.2,a)')
     . '''b2trcl_lambda'''//tab//tab//tab//'''',dflaglnlam_4,''''
        write(98,'(a,1pe9.2,a)')
     . '''b2trcl_lambda'''//tab//tab//tab//'''',dflaglnlam_4,''''
      endif
      write(99,'(a)')
     . '''b2trcl_cthe'''//tab//tab//tab//'''0.71'''
      write(99,'(a)')
     . '''b2trcl_cthi'''//tab//tab//tab//'''2.20'''
      if (feqp_4.ne.1.0_R8) then
        write(99,'(a,1pe9.2,a)')
     .   '''b2treq_phm0'''//tab//tab//tab//'''',feqp_4,''''
        write(98,'(a,1pe9.2,a)')
     .   '''b2treq_phm0'''//tab//tab//tab//'''',feqp_4,''''
      end if
      write(99,'(a)')
     . '''b2tqna_new_df0'''//tab//tab//'''1'''
      write(98,'(a)')
     . '''b2tqna_new_df0'''//tab//tab//'''1'''
      write(99,'(a,1pe9.2,a)')
     . '''b2tqna_max_df0'''//tab//tab//'''',neutral_diflimit_4,''''
      write(98,'(a,1pe9.2,a)')
     . '''b2tqna_max_df0'''//tab//tab//'''',neutral_diflimit_4,''''
      write(hlp_frm, '(a,i1,a)')
     . '(a,i',len_of_digits(jxa_4),',a)'
      if (jxa_4.ne.jxa) then
        write(99,hlp_frm)
     .   '''b2mwti_jxa'''//tab//tab//tab//'''',jxa_4,''''
        write(98,hlp_frm)
     .   '''b2mwti_jxa'''//tab//tab//tab//'''',jxa_4,''''
      end if
      write(hlp_frm, '(a,i1,a)')
     . '(a,i',len_of_digits(jxi_4),',a)'
      if (jxi_4.ne.jxi) then
        write(99,hlp_frm)
     .   '''b2mwti_jxi'''//tab//tab//tab//'''',jxi_4,''''
        write(98,hlp_frm)
     .   '''b2mwti_jxi'''//tab//tab//tab//'''',jxi_4,''''
      end if
      write(hlp_frm, '(a,i1,a)')
     . '(a,i',len_of_digits(ixref_4),',a)'
      if (ixref_4.ne.jxa .and. ixref_4.lt.nx .and. ixref_4.gt.-1) then
        write(99,hlp_frm)
     .   '''b2tqna_ixref'''//tab//tab//tab//'''',ixref_4,''''
        write(98,hlp_frm)
     .   '''b2tqna_ixref'''//tab//tab//tab//'''',ixref_4,''''
      end if
      if (no_thermal_force_4) then
        write(99,'(a)')
     .   '''b2sifr_phm1'''//tab//tab//tab//'''0.0'''
        write(98,'(a)')
     .   '''b2sifr_phm1'''//tab//tab//tab//'''0.0'''
      end if
      if (sput_dst.ne.-1) then
        write(hlp_frm, '(a,i1,a)')
     .   '(a,i',len_of_digits(sput_dst),',a)'
        write(99,hlp_frm)
     .   '''b2stbr_sput_dst'''//tab//tab//'''',sput_dst,''''
        write(98,hlp_frm)
     .   '''b2stbr_sput_dst'''//tab//tab//'''',sput_dst,''''
      endif
      if (sput_dst2.ne.-1) then
        write(hlp_frm, '(a,i1,a)')
     .   '(a,i',len_of_digits(sput_dst2),',a)'
        write(99,hlp_frm)
     .   '''b2stbr_sput_dst2'''//tab//tab//'''',sput_dst2,''''
        write(98,hlp_frm)
     .   '''b2stbr_sput_dst2'''//tab//tab//'''',sput_dst2,''''
      endif
      if (sput_dst3.ne.-1) then
        write(hlp_frm, '(a,i1,a)')
     .   '(a,i',len_of_digits(sput_dst3),',a)'
        write(99,hlp_frm)
     .   '''b2stbr_sput_dst3'''//tab//tab//'''',sput_dst3,''''
        write(98,hlp_frm)
     .   '''b2stbr_sput_dst3'''//tab//tab//'''',sput_dst3,''''
      endif
      if (lfirstflight_4) then
        write(99,'(a)')
     .   '''b2stbr_first_flight'''//tab//tab//'''1'''
        write(98,'(a)')
     .   '''b2stbr_first_flight'''//tab//tab//'''1'''
      end if
      write(99,'(a)')
     . '''b2news_BoRiS'''//tab//tab//tab//'''1.0'''
      write(99,'(a)')
     . '''b2tfnb_no_hybr'''//tab//tab//'''1'''
      write(99,'(a)')
     . '''b2tfhe_no_hybr'''//tab//tab//'''1'''
      write(99,'(a)')
     . '''b2tfhi_no_hybr'''//tab//tab//'''1'''
      if (nlcurr_4.eq.0) then
        write(99,'(a)')
     .   '''b2news_poteq'''//tab//tab//tab//'''2'''
        write(99,'(a)')
     .   '''b2tfhe_no_current'''//tab//tab//'''1'''
      endif
      write(99,'(a,i1,a)')
     . '''b2ux5p_nltrsol'''//tab//tab//'''',nltrsol_5p,''''
      write(98,'(a,i1,a)')
     . '''b2ux5p_nltrsol'''//tab//tab//'''',nltrsol_5p,''''
      write(99,'(a)')
     . '''b2ux5p_style'''//tab//tab//tab//'''2'''
      write(98,'(a)')
     . '''b2ux5p_style'''//tab//tab//tab//'''2'''
      if (impflag_4.eq.1) then
        write(99,'(a,1pe9.2,a)')
     .   '''b2sqel_artificial_radiation'''//tab//'''',cimpef_4,''''
        write(98,'(a,1pe9.2,a)')
     .   '''b2sqel_artificial_radiation'''//tab//'''',cimpef_4,''''
      end if
      write(hlp_frm, '(a,i1,a)')
     .   '(a,i',len_of_digits(nlrade_4),',a)'
      write(99,hlp_frm)
     . '''b2sihs_style'''//tab//tab//tab//'''',nlrade_4,''''
      write(98,hlp_frm)
     . '''b2sihs_style'''//tab//tab//tab//'''',nlrade_4,''''
      if (lfeedback_4) then
        write(99,'(a)')
     .   '''b2stbc_feedback'''//tab//tab//'''1'''
        write(98,'(a)')
     .   '''b2stbc_feedback'''//tab//tab//'''1'''
      end if
      if (sepfeedback_4) then
        write(99,'(a,i2,a)')
     .   '''b2stbc_isfeedback'''//tab//tab//'''1'''
        write(99,'(a,1pe9.2,a)')
     .   '''b2stbc_feedback_nesepm'''//tab//'''',sepden_4,''''
        write(99,'(a,i2,a)')
     .   '''eirene_nesepm_istra'''//tab//'''',
     .   user_flux_feedback_stratum_4,''''
        write(98,'(a,i2,a)')
     .   '''b2stbc_isfeedback'''//tab//tab//'''1'''
        write(98,'(a,1pe9.2,a)')
     .   '''b2stbc_feedback_nesepm'''//tab//'''',sepden_4,''''
        write(98,'(a,i2,a)')
     .   '''eirene_nesepm_istra'''//tab//'''',
     .   user_flux_feedback_stratum_4,''''
      end if
      if (sepgasfeedback_4) then
        write(99,'(a,i2,a)')
     .   '''b2stbc_isfeedback'''//tab//tab//'''1'''
        write(99,'(a,1pe9.2,a)')
     .   '''b2stbc_feedback_nesepm_sol'''//tab//'''',sepden_4,''''
        write(99,'(a,i2,a)')
     .   '''eirene_nesepm_istra'''//tab//'''',
     .   user_flux_feedback_stratum_4,''''
        write(98,'(a,i2,a)')
     .   '''b2stbc_isfeedback'''//tab//tab//'''1'''
        write(98,'(a,1pe9.2,a)')
     .   '''b2stbc_feedback_nesepm_sol'''//tab//'''',sepden_4,''''
        write(98,'(a,i2,a)')
     .   '''eirene_nesepm_istra'''//tab//'''',
     .   user_flux_feedback_stratum_4,''''
      end if
      if (volrecfeedback_4) then
        write(99,'(a)')
     .   '''b2stbc_isfeedback'''//tab//tab//'''0'''
        write(99,'(a,1pe9.2,a)')
     .   '''b2stbc_volrec_sol'''//tab//tab//'''',voldesired_4,''''
        write(99,'(a,1pe9.2,a)')
     .   '''b2stbc_volrec_alpha'''//tab//'''',volrecfac_4,''''
        write(99,'(a,i2,a)')
     .   '''eirene_nesepm_istra'''//tab//'''',
     .   user_flux_feedback_stratum_4,''''
        write(98,'(a)')
     .   '''b2stbc_isfeedback'''//tab//tab//'''0'''
        write(98,'(a,1pe9.2,a)')
     .   '''b2stbc_volrec_sol'''//tab//tab//'''',voldesired_4,''''
        write(98,'(a,1pe9.2,a)')
     .   '''b2stbc_volrec_alpha'''//tab//'''',volrecfac_4,''''
        write(98,'(a,i2,a)')
     .   '''eirene_nesepm_istra'''//tab//'''',
     .   user_flux_feedback_stratum_4,''''
      end if
      do is = 1, nspecies_4
        if (ffb_cntr_4(is).ne.0) then
          is0 = isp(is)
          if (is0.ge.0) then
            write(hlp_frm, '(a,i1,a)')
     .       '(a,i',len_of_digits(is0),',a)'
            write(99,hlp_frm)
     .       '''b2stbc_isfeedback'''//tab//tab//'''',is0,''''
            write(98,hlp_frm)
     .       '''b2stbc_isfeedback'''//tab//tab//'''',is0,''''
          end if
          if (ffb_strata_4(is).le.0) then
            do i = 1, nstrai_4
              if(crcstra_4(i).eq.'C' .and. gpfc_4(is,i).gt.0.0_R8) then !{
                ffb_strata_4(is) = i
              end if !}
            end do
          end if
          if (ffb_strata_4(is).gt.0) then
            write(hlp_frm, '(a,i1,a)')
     .       '(a,i',len_of_digits(ffb_strata_4(is)),',a)'
            write(99,hlp_frm)
     .       '''eirene_nesepm_istra'''//tab//'''',
     .       ffb_strata_4(is),''''
            write(98,hlp_frm)
     .       '''eirene_nesepm_istra'''//tab//'''',
     .       ffb_strata_4(is),''''
          end if
        end if
      end do
      if (dflagvconv_4.eq.-10) then
        write(98,'(a)')
     .   '''b2tqna_user_transport'''//tab//'''6'''
        write(99,'(a)')
     .   '''b2tqna_user_transport'''//tab//'''6'''
      end if

      close(98)
      close(99)
      return
      end subroutine write_b2mn
c
      subroutine write_boundary_namelist(ns)
      use b2mod_types
      use b2mod_indirect
      use b2mod_feedback
      use b2mod_boundary_namelist
      use b2mod_b2cmpa
      implicit none
      integer ns
      integer ib, is, is0, iss
      character*32 hlp_frm, hlp_frp, hlp_frb
      character*80 boundary_filename_4, boundary_filename_5
      intrinsic mod

      do ib = 1, nbc
        if (bcchar(ib).eq.'W') then
          bcpot(ib) = 3
          potpar(ib,2) = phiin_4(region(bcpos(ib),bcstart(ib),0)/4+1)
          do is = 0, ns-1
            if (is_neutral(is)) then
              bccon(is,ib) = 5
              bcmom(is,ib) = 1
              conpar(is,ib,1) = 0.0_R8
              conpar(is,ib,2) = 0.0_R8
              mompar(is,ib,1) = 0.0_R8
              mompar(is,ib,2) = 0.0_R8
            end if
            if (bccon(is,ib).eq.3) then
              conpar(is,ib,1) = 0.0_R8
              conpar(is,ib,2) = 0.0_R8
            end if
          end do
        else if (bcchar(ib).eq.'E') then
          bcpot(ib) = 3
          potpar(ib,2) = phiout_4(region(bcpos(ib),bcstart(ib),0)/4)
          do is = 0, ns-1
            if (is_neutral(is)) then
              bccon(is,ib) = 5
              bcmom(is,ib) = 1
              conpar(is,ib,1) = 0.0_R8
              conpar(is,ib,2) = 0.0_R8
              mompar(is,ib,1) = 0.0_R8
              mompar(is,ib,2) = 0.0_R8
            end if
            if (bccon(is,ib).eq.3) then
              conpar(is,ib,1) = 0.0_R8
              conpar(is,ib,2) = 0.0_R8
            end if
          end do
        else if (bcchar(ib).eq.'S') then
          if (mod(region(bcstart(ib),bcpos(ib),0),4).eq.1) then
            bcpot(ib) = 12
            do is = 0, ns-1
              if (is_neutral(is)) then
                bccon(is,ib) = 8
                bcmom(is,ib) = 1
                conpar(is,ib,1) = 0.0_R8
                conpar(is,ib,2) = 0.0_R8
                mompar(is,ib,1) = 0.0_R8
                mompar(is,ib,2) = 0.0_R8
              end if
            end do
            if (sepfeedback_4.and.ib.eq.main_plasma_bc_4) then
              bccon(1,ib) = 12
              conpar(1,ib,1) = sepden_4
            end if
cxpb Careful here for the case where both core and fuel feedback schemes
cxpb are turned on simultaneously for the same isonuclear sequence
            do is = 1, nspecies_4
              if (cfb_cntr_4(is).ne.0) then
                do is0 = isp(is)+1, isp(is)+nfluids_4(is)-1
                  if (is0.ge.0) then
                    if (ffb_cntr_4(is).ne.0) then
                      bccon(is0,ib) = 8
                    else
                      bccon(is0,ib) = 11
                    end if
                    conpar(is0,ib,1) = 0.0_R8
                    conpar(is0,ib,2) = 0.0_R8
                  end if
                end do
                is0 = isp(is)+nfluids_4(is)
                if (ffb_cntr_4(is).ne.0) then
                  bccon(is0,ib) = 13
                  if (cfb_over_4(is).ne.0.0_R8) then
                    conpar(is0,ib,2) = cfb_over_4(is)
                  else
                    conpar(is0,ib,2) = 0.01_R8
                  end if
                else
                  bccon(is0,ib) = 11
                  conpar(is0,ib,2) = 0.0_R8
                end if
                na_feedback_ib(is-1) = ib
                conpar(is0,ib,1) = cfb_core_4(is)
                do iss = isp(is)+1, isp(is)+nfluids_4(is)
                  conpar(is0,ib,1) = conpar(is0,ib,1) +
     .                               conpar_4(ifl(iss),ib,1)
                end do
              end if
            end do
          else
            bcpot(ib) = 13
            do is = 0, ns-1
              if (is_neutral(is)) then
                bccon(is,ib) = 10
                bcmom(is,ib) = 1
                if (nint(zn(is)).eq.1 .or. nint(zn(is)).eq.2  .or.
     &              nint(zn(is)).eq.7 .or. nint(zn(is)).eq.10 .or.
     &              nint(zn(is)).eq.18) then
                  conpar(is,ib,1) = -1.0e-2_R8
                else
                  conpar(is,ib,1) = -1.0_R8
                end if
              end if
            end do
          end if
        else if (bcchar(ib).eq.'N') then
          bcpot(ib) = 13
          do is = 0, ns-1
            if (is_neutral(is)) then
              bccon(is,ib) = 10
              bcmom(is,ib) = 1
              if (nint(zn(is)).eq.1 .or. nint(zn(is)).eq.2  .or.
     &            nint(zn(is)).eq.7 .or. nint(zn(is)).eq.10 .or.
     &            nint(zn(is)).eq.18) then
                conpar(is,ib,1) = -1.0e-2_R8
              else
                conpar(is,ib,1) = -1.0_R8
              end if
            end if
          end do
          do is = 1, nspecies_4
            if (ffb_cntr_4(is).ne.0) then
              is0 = isp(is)
              if (is0.ge.0) then
                if (cfb_cntr_4(is).ne.0) then
                  bccon(is0,ib) = 8
                else
                  bccon(is0,ib) = 11
                  na_feedback_ib(is-1) = ib
                end if
                conpar(is0,ib,1) = ffb_const_4(is)
              end if
            end if
          end do
          if (volrecfeedback_4) then
            bccon(0,ib) = 12
            conpar(0,ib,1) = voldesired_4
          end if
        end if
      end do

      boundary_filename_4 = trim(boundary_filename)//'.4'
      boundary_filename_5 = trim(boundary_filename)//'.5'
      write(*,*) 'Writing ',trim(boundary_filename_4),' and ',
     . trim(boundary_filename_5)
      open(35,file=boundary_filename_4)
      open(36,file=boundary_filename_5)
      write(35,'(a)') '&BOUNDARY'
      write(36,'(a)') '&BOUNDARY'
      write(35,'(a,i2,a)') 'NBC=', nbc,','
      write(36,'(a,i2,a)') 'NBC=', nbc,','
      write(hlp_frm,'(a,i2,a)') '(a,',nbc,'(1x,a1,a1,a2))'
      write(35,hlp_frm) 'BCCHAR= ',('''',bcchar(ib),''',',ib=1,nbc)
      write(36,hlp_frm) 'BCCHAR= ',('''',bcchar(ib),''',',ib=1,nbc)
      write(hlp_frm,'(a,i2,a)') '(a,',nbc,'(1x,i3,'',''))'
      write(35, hlp_frm) 'BCPOS=  ',(bcpos(ib)  ,ib=1,nbc)
      write(36, hlp_frm) 'BCPOS=  ',(bcpos(ib)  ,ib=1,nbc)
      write(35, hlp_frm) 'BCSTART=',(bcstart(ib),ib=1,nbc)
      write(36, hlp_frm) 'BCSTART=',(bcstart(ib),ib=1,nbc)
      write(35, hlp_frm) 'BCEND=  ',(bcend(ib)  ,ib=1,nbc)
      write(36, hlp_frm) 'BCEND=  ',(bcend(ib)  ,ib=1,nbc)
      write(35, hlp_frm) 'BCENE=  ',(bcene(ib)  ,ib=1,nbc)
      write(36, hlp_frm) 'BCENE=  ',(bcene(ib)  ,ib=1,nbc)
      write(35, hlp_frm) 'BCENI=  ',(bceni(ib)  ,ib=1,nbc)
      write(36, hlp_frm) 'BCENI=  ',(bceni(ib)  ,ib=1,nbc)
      write(35, hlp_frm) 'BCPOT=  ',(bcpot(ib)  ,ib=1,nbc)
      write(36, hlp_frm) 'BCPOT=  ',(bcpot(ib)  ,ib=1,nbc)
      write(hlp_frm,'(a,i2,a)') '(a,1p,',nbc,'(1x,e9.2,'',''))'
      write(35, hlp_frm) 'ENEPAR(1,1)=',(enepar(ib,1),ib=1,nbc)
      do ib = 1, nbc
        if (bcene(ib).eq.3) enepar(ib,1)=enepar(ib,1)-1.0_R8
      enddo
      write(36, hlp_frm) 'ENEPAR(1,1)=',(enepar(ib,1),ib=1,nbc)
      if (maxval(abs(enepar(1:nbc,2))).gt.0.0_R8)
     > write(35, hlp_frm) 'ENEPAR(1,2)=',(enepar(ib,2),ib=1,nbc)
      if (maxval(abs(enepar(1:nbc,2))).gt.0.0_R8)
     > write(36, hlp_frm) 'ENEPAR(1,2)=',(enepar(ib,2),ib=1,nbc)
      write(35, hlp_frm) 'ENIPAR(1,1)=',(enipar(ib,1),ib=1,nbc)
      if (maxval(abs(enipar(1:nbc,2))).gt.0.0_R8)
     > write(35, hlp_frm) 'ENIPAR(1,2)=',(enipar(ib,2),ib=1,nbc)
      do ib = 1, nbc
        if (bceni(ib).eq.3) then
          enipar(ib,1)=enipar(ib,1)-2.0_R8+enipar(ib,2)
          enipar(ib,2)=0.0_R8
        endif
      enddo
      write(36, hlp_frm) 'ENIPAR(1,1)=',(enipar(ib,1),ib=1,nbc)
      if (maxval(abs(enipar(1:nbc,2))).gt.0.0_R8)
     > write(36, hlp_frm) 'ENIPAR(1,2)=',(enipar(ib,2),ib=1,nbc)
      write(35, hlp_frm) 'POTPAR(1,1)=',(potpar(ib,1),ib=1,nbc)
      write(36, hlp_frm) 'POTPAR(1,1)=',(potpar(ib,1),ib=1,nbc)
      if (maxval(abs(potpar(1:nbc,2))).gt.0.0_R8)
     > write(35, hlp_frm) 'POTPAR(1,2)=',(potpar(ib,2),ib=1,nbc)
      if (maxval(abs(potpar(1:nbc,2))).gt.0.0_R8)
     > write(36, hlp_frm) 'POTPAR(1,2)=',(potpar(ib,2),ib=1,nbc)
      write(hlp_frb,'(a,i2,a)') '(a,i2,a,',ns,'(1x,i3,'',''))'
      write(hlp_frp,'(a,i2,a)') '(a,i2,a,1p,',ns,'(1x,e9.2,'',''))'
      do ib = 1, nbc
        write(35, hlp_frb)
     .   'BCCON(0,',ib,')=',(bccon(is,ib),is=0,ns-1)
        write(36, hlp_frb)
     .   'BCCON(0,',ib,')=',(bccon(is,ib),is=0,ns-1)
      end do
      do ib = 1, nbc
        write(35, hlp_frp)
     .   'CONPAR(0,',ib,',1)=',(conpar(is,ib,1),is=0,ns-1)
        write(36, hlp_frp)
     .   'CONPAR(0,',ib,',1)=',(conpar(is,ib,1),is=0,ns-1)
        if (maxval(abs(conpar(0:ns-1,ib,2))).gt.0.0_R8)
     >   write(35, hlp_frp)
     >    'CONPAR(0,',ib,',2)=',(conpar(is,ib,2),is=0,ns-1)
        if (maxval(abs(conpar(0:ns-1,ib,2))).gt.0.0_R8)
     >   write(36, hlp_frp)
     >    'CONPAR(0,',ib,',2)=',(conpar(is,ib,2),is=0,ns-1)
        if (maxval(abs(conpar(0:ns-1,ib,3))).gt.0.0_R8)
     >   write(35, hlp_frp)
     >    'CONPAR(0,',ib,',3)=',(conpar(is,ib,3),is=0,ns-1)
        if (maxval(abs(conpar(0:ns-1,ib,3))).gt.0.0_R8)
     >   write(36, hlp_frp)
     >    'CONPAR(0,',ib,',3)=',(conpar(is,ib,3),is=0,ns-1)
      end do
      do ib = 1, nbc
        write(35, hlp_frb)
     .   'BCMOM(0,',ib,')=',(bcmom(is,ib),is=0,ns-1)
        write(36, hlp_frb)
     .   'BCMOM(0,',ib,')=',(bcmom(is,ib),is=0,ns-1)
      end do
      do ib = 1, nbc
        write(35, hlp_frp)
     .   'MOMPAR(0,',ib,',1)=',(mompar(is,ib,1),is=0,ns-1)
        write(36, hlp_frp)
     .   'MOMPAR(0,',ib,',1)=',(mompar(is,ib,1),is=0,ns-1)
        if (maxval(abs(mompar(0:ns-1,ib,2))).gt.0.0_R8)
     >   write(35, hlp_frp)
     >    'MOMPAR(0,',ib,',2)=',(mompar(is,ib,2),is=0,ns-1)
        if (maxval(abs(mompar(0:ns-1,ib,2))).gt.0.0_R8)
     >   write(36, hlp_frp)
     >    'MOMPAR(0,',ib,',2)=',(mompar(is,ib,2),is=0,ns-1)
      end do
      write(35,'(a,f10.7,a,1pe9.2,a)')
     . 'GAMMAI=',gammai,', GAMMAE=',gammae,','
      write(36,'(a,f10.7,a,1pe9.2,a)')
     . 'GAMMAI=',gammai,', GAMMAE=',gammae,','
      write(35,'(a,l1,a,l1,a)')
     . 'LBNDUSR=',lbndusr,', LFEEDBACK=',lfeedback,','
      write(36,'(a,l1,a,l1,a)')
     . 'LBNDUSR=',lbndusr,', LFEEDBACK=',lfeedback,','
      write(35,'(a,i2,a)') 'NNISO=',NNISO,','
      write(36,'(a,i2,a)') 'NNISO=',NNISO,','
      if (nniso.gt.0) then
        write(hlp_frm,'(a,i2,a)') '(a,',nniso,'(1x,i2,'',''))'
        write(35, hlp_frm) 'NXISO1=',nxiso1(1:nniso)
        write(36, hlp_frm) 'NXISO1=',nxiso1(1:nniso)
        write(35, hlp_frm) 'NXISO2=',nxiso2(1:nniso)
        write(36, hlp_frm) 'NXISO2=',nxiso2(1:nniso)
        write(35, hlp_frm) 'NYISO1=',nyiso1(1:nniso)
        write(36, hlp_frm) 'NYISO1=',nyiso1(1:nniso)
        write(35, hlp_frm) 'NYISO2=',nyiso2(1:nniso)
        write(36, hlp_frm) 'NYISO2=',nyiso2(1:nniso)
        write(hlp_frm,'(a,i2,a)') '(a,1p,',ns,'(1x,e9.2,'',''))'
        write(35, hlp_frm) 'NIISO=',niiso(0:ns-1)
        write(36, hlp_frm) 'NIISO=',niiso(0:ns-1)
        write(35, '(a,1p,e9.2,a,e9.2,a)')
     .   'TEISO=',teiso,', TIISO=',tiiso,','
        write(36, '(a,1p,e9.2,a,e9.2,a)')
     .   'TEISO=',teiso,', TIISO=',tiiso,','
      endif
      if (ncbs_4.gt.0 .and. maxval(lcbs).gt.0) then
        write(hlp_frm,'(a,i2,a)') '(a,',ncbs_4,'(1x,i2,'',''))'
        write(35, hlp_frm) 'LCBS=',lcbs(1:ncbs_4)
        write(36, hlp_frm) 'LCBS=',lcbs(1:ncbs_4)
      endif

      write(35,'(a)') '/'
      write(36,'(a)') '/'
      close(35)
      close(36)
      return
      end subroutine write_boundary_namelist
c
      subroutine write_transport_namelist(ns)
      use b2mod_types
      use b2mod_transport_namelist
      use b2mod_b2cmpa
      implicit none
      integer ns
      integer is
      character*32 hlp_frm
      character*80 transport_filename_4, transport_filename_5

      call alloc_transport_namelist(ns)
      do is = 0, ns-1
        if(.not.is_neutral(is)) then
          parm_dna(is)=difni_4(ifl(is))
          parm_dpa(is)=difpr_4(ifl(is))
          parm_vla(is)=vconv_4(ifl(is))
          parm_vsa(is)=travis_4(ifl(is))
        endif
        parm_hci(is)=kyi_4*kxi_4
      end do
      parm_hce=kye_4*kxe_4
      cflme=flim_4
      cflmi=flimi_4
      cflmv=flimv_4
      if (dflagn_4.eq.0) then
        flag_dna=1
      else if (dflagn_4.eq.1) then
        flag_dna=2
        parm_dna=parm_dna*fudgen_4/1.0e20_R8
      else if (dflagn_4.eq.2) then
        flag_dna=3
        parm_dna=parm_dna*fudgeb_4
      else if (dflagn_4.eq.4) then
        flag_dna=4
      else
        flag_dna=0
      end if
      flag_dpa=0
      if (dflagvconv_4.eq.4) then
        flag_vla=4
      else
        flag_vla=0
      endif
      flag_vsa=0
      if (dflagti_4.eq.0) then
        flag_hci=1
      else if (dflagti_4.eq.1) then
        flag_hci=2
        parm_hci=parm_hci*fudgetin_4/1.0e20_R8
      else if (dflagti_4.eq.2) then
        flag_hci=3
        parm_hci=parm_hci*fudgetib_4
      else if (dflagti_4.eq.4) then
        flag_hci=4
      else
        flag_hci=0
      end if
      if (dflagte_4.eq.0) then
        flag_hce=1
      else if (dflagte_4.eq.1) then
        flag_hce=2
        parm_hce=parm_hce*fudgeten_4/1.0e20_R8
      else if (dflagte_4.eq.2) then
        flag_hce=3
        parm_hce=parm_hce*fudgeteb_4
      else if (dflagte_4.eq.4) then
        flag_hce=4
      else
        flag_hce=0
      end if
      do is = 0, ns-1
        if(.not.is_neutral(is)) then
          vout_cnv(is)=vout_cnv_4(ifl(is))
          pw0_cnv(is)=pw0_cnv_4(ifl(is))
          pw1_cnv(is)=pw1_cnv_4(ifl(is))
          pw2_cnv(is)=pw2_cnv_4(ifl(is))
        endif
      end do

      transport_filename_4 = trim(transport_filename)//'.4'
      transport_filename_5 = trim(transport_filename)//'.5'
      write(*,*) 'Writing ',trim(transport_filename_4),' and ',
     . trim(transport_filename_5)
      open(94,file=transport_filename_4)
      open(95,file=transport_filename_5)
      write(94,'(a)') '&TRANSPORT'
      write(95,'(a)') '&TRANSPORT'
      write(hlp_frm,'(a,i2,a)') '(a,i1,a,1p,',ns,'(e9.2,'',''))'
      write(94,hlp_frm)
     . 'flag_dna=',flag_dna,', parm_dna=',(parm_dna(is),is=0,ns-1)
      write(95,hlp_frm)
     . 'flag_dna=',flag_dna,', parm_dna=',(parm_dna(is),is=0,ns-1)
      write(94,hlp_frm)
     . 'flag_dpa=',flag_dpa,', parm_dpa=',(parm_dpa(is),is=0,ns-1)
      write(95,hlp_frm)
     . 'flag_dpa=',flag_dpa,', parm_dpa=',(parm_dpa(is),is=0,ns-1)
      write(94,hlp_frm)
     . 'flag_vla=',flag_vla,', parm_vla=',(parm_vla(is),is=0,ns-1)
      write(95,hlp_frm)
     . 'flag_vla=',flag_vla,', parm_vla=',(parm_vla(is),is=0,ns-1)
      write(94,hlp_frm)
     . 'flag_vsa=',flag_vsa,', parm_vsa=',(parm_vsa(is),is=0,ns-1)
      write(95,hlp_frm)
     . 'flag_vsa=',flag_vsa,', parm_vsa=',(parm_vsa(is),is=0,ns-1)
      write(94,hlp_frm)
     . 'flag_hci=',flag_hci,', parm_hci=',(parm_hci(is),is=0,ns-1)
      write(95,hlp_frm)
     . 'flag_hci=',flag_hci,', parm_hci=',(parm_hci(is),is=0,ns-1)
      write(94,'(a,i1,a,1pe9.2,a)')
     . 'flag_hce=',flag_hce,', parm_hce=',parm_hce,','
      write(95,'(a,i1,a,1pe9.2,a)')
     . 'flag_hce=',flag_hce,', parm_hce=',parm_hce,','
      write(94,'(a,1pe9.2,a)')
     . 'cflme=',cflme,','
      write(95,'(a,1pe9.2,a)')
     . 'cflme=',cflme,','
      write(94,'(a,1pe9.2,a)')
     . 'cflmi=',cflmi,','
      write(95,'(a,1pe9.2,a)')
     . 'cflmi=',cflmi,','
      write(94,'(a,1pe9.2,a)')
     . 'cflmv=',cflmv,','
      write(95,'(a,1pe9.2,a)')
     . 'cflmv=',cflmv*0.75_R8,','
      write(hlp_frm,'(a,i2,a)') '(a,1p,',ns,'(e9.2,'',''))'
      if (abs(maxval(vout_cnv(0:ns-1))).ne.0.0_R8 .and.
     &    dflagvconv_4.eq.-10) then
        write(94,hlp_frm)
     .   'vout_cnv=',(vout_cnv(is),is=0,ns-1)
        write(94,hlp_frm)
     .   'pw0_cnv=',(pw0_cnv(is),is=0,ns-1)
        write(94,hlp_frm)
     .   'pw1_cnv=',(pw1_cnv(is),is=0,ns-1)
        write(94,hlp_frm)
     .   'pw2_cnv=',(pw2_cnv(is),is=0,ns-1)
        write(95,hlp_frm)
     .   'vout_cnv=',(vout_cnv(is),is=0,ns-1)
        write(95,hlp_frm)
     .   'pw0_cnv=',(pw0_cnv(is),is=0,ns-1)
        write(95,hlp_frm)
     .   'pw1_cnv=',(pw1_cnv(is),is=0,ns-1)
        write(95,hlp_frm)
     .   'pw2_cnv=',(pw2_cnv(is),is=0,ns-1)
      end if
      write(94,'(a)') '/'
      write(95,'(a)') '/'
      close(94)
      close(95)
      deallocate(parvis_4,travis_4,difni_4,difpr_4,vconv_4)
      deallocate(vout_cnv_4,pw0_cnv_4,pw1_cnv_4,pw2_cnv_4)
      return
      end subroutine write_transport_namelist
c
      subroutine write_neutrals_namelist(ns)
      use b2mod_types
      use b2mod_indirect
      use b2mod_neutrals_namelist
      implicit none
      integer ns

      character*32 hlp_frm
      integer is, ib, ii(1), nsns
      intrinsic mod

      write(*,*) 'Writing ',trim(neutrals_filename)
      open(34,file=neutrals_filename)
      write(34,'(a)') '&NEUTRALS'
      write(34,'(a,i2,a)') 'NSTRAI=', nstrae_4,','
      write(34,'(a,1pe9.2,a)') 'EIRENE_STEP_CPU=',eirene_step_cpu,','
      write(34,'(a,1pe9.2,a)') 'EIRENE_STEP_DT= ',eirene_step_dt,','
      write(34,'(a,i2,a)') 'EIRENE_MOD=', eirene_mod,','
      if (lreitr_4) then
        nstrat = nstrai+1
        crcstra(nstrat) = 'T'
        rcpos(nstrat) = 0
        rcstart(nstrat) = 0
        rcend(nstrat) = 0
        species_start(nstrat) = 0
        species_end(nstrat) = ns-1
      else
        nstrat = nstrai
      endif
      write(hlp_frm,'(a,i2,a)') '(a,',nstrat,'(1x,a1,a1,a2))'
      write(34,hlp_frm) 'CRCSTRA=',('''',crcstra(ib),''',',
     .                                            ib=1,nstrat)
      write(hlp_frm,'(a,i2,a)') '(a,',nstrat,'(1x,i3,'',''))'
      write(34, hlp_frm) 'RCPOS=  ',(rcpos(ib)  ,ib=1,nstrat)
      write(34, hlp_frm) 'RCSTART=',(rcstart(ib),ib=1,nstrat)
      write(34, hlp_frm) 'RCEND=  ',(rcend(ib)  ,ib=1,nstrat)
      write(hlp_frm,'(a,i2,a)') '(a,i2,a,1p,',ns,'(1x,e9.2,'',''))'
      do ib = 1, nstrai
        write(34, hlp_frm)
     .   'RECYC(0,',ib,')=',(recyc(is,ib),is=0,ns-1)
      end do
      if (maxval(species_start).gt.0 .or.
     &    minval(species_end).lt.ns-1) then
        write(hlp_frm,'(a,i2,a)') "(a,",nstrat,"(1x,i2,','))"
        write(34,hlp_frm) 'SPECIES_START=',species_start(1:nstrat)
        write(34,hlp_frm) 'SPECIES_END=  ',species_end(1:nstrat)
      endif
      write(hlp_frm,'(a,i2,a)') '(a,1p,',nstrai,'(1x,e9.2,'',''))'
      do ib = 1, nstrai
       if (crcstra(ib).eq.'V' .and. volrecstart(ib).ne.1.0e21_R8)
     >  write(34, '(a,i2,a,1pe9.2,a)')
     .  'VOLRECSTART(',ib,')=',volrecstart(ib),','
      end do
      if (volrecinc.ne.0.0_R8) write(34, '(a,1pe9.2,a)')
     . 'VOLRECINC=',volrecinc,','
      write(34, '(a,1pe9.2,a)')
     . 'VOLRECWT= ',volrecwt,','
      do is = 1, 4
        if (rf_neut(is).ne.1.0_R8) write(34,'(a,i1,a,1pe9.2,a)')
     .   'RF_NEUT(',is,')=',rf_neut(is)
      end do
      do ib = 1, nstrai
        if (userfluxparm(ib,1).ne.0.0_R8)
     >   write(34, '(a,i2,a,1pe9.2,a)')
     .   'USERFLUXPARM(',ib,',1)=',userfluxparm(ib,1),','
        if (userfluxparm(ib,2).ne.0.0_R8)
     >   write(34, '(a,i2,a,1pe9.2,a)')
     .   'USERFLUXPARM(',ib,',2)=',userfluxparm(ib,2),','
      end do
      do ib = 1, nstrai
        do is = 1, nspecies_4
          if (gpfc(is,ib).ne.0.0_R8) write(34,'(a,i1,a,i2,a,f5.2,a)')
     .     'GPFC(',is,',',ib,')=',gpfc(is,ib),','
        end do
      end do
#ifndef NO_B2_CHEM_SPUT
      do ib = 0, nlimps
        if (chemical_sputter_yield(ib).ne.0.0_R8)
     >   write(34,'(a,i3,a,1pe9.2,a)')
     .   'CHEMICAL_SPUTTER_YIELD(',ib,')=',
     .   chemical_sputter_yield(ib),','
      end do
      if (fchar_chemical.ne.0.0_R8) write(34, '(a,1pe9.2,a)')
     .   'FCHAR_CHEMICAL= ',fchar_chemical,','
      if (igass_chemical.ne.0) write(34, '(a,i2,a)')
     .   'IGASS_CHEMICAL= ',igass_chemical,','
      if (itsput_chemical.ne.0) write(34, '(a,i2,a)')
     .   'ITSPUT_CHEMICAL=',itsput_chemical,','
      if (issput_chemical.ne.0) write(34, '(a,i2,a)')
     .   'ISSPUT_CHEMICAL=',issput_chemical,','
#endif
      write(hlp_frm,'(a,i2,a)') '(a,i1,a,',nstrat,'(1x,i2,'',''))'
      if (maxval(lstrascl).gt.0) then
        do is = 1, nspecies_4
          write(34, hlp_frm)
     .     'LSTRASCL(1,',is,')=',(lstrascl(ib,is),ib=1,nstrat)
        end do
      end if
      if (l_neutrad.ge.0)
     > write(34,'(a,i2,a)') 'L_NEUTRAD=',l_neutrad,','
      if (l_neutflux.ne.-1)
     > write(34,'(a,i2,a)') 'L_NEUTFLUX=',l_neutflux,','
      write(hlp_frm,'(a,i2,a)') '(a,',nmol,'(1x,i2,'',''))'
      if (maxval(lmolscl).gt.0)
     > write(34,hlp_frm) 'LMOLSCL=',(lmolscl(is),is=1,nmol)
      write(hlp_frm,'(a,i2,a)') '(a,',ns,'(1x,i2,'',''))'
      write(34,hlp_frm) 'B2ESPCR=',(b2espcr(is),is=0,ns-1)
      write(hlp_frm,'(a,i2,a)') '(a,',nspecies_4,'(1x,i2,'',''))'
      write(34,hlp_frm) 'EB2SPCR=',(eb2spcr(is),is=1,nspecies_4)
      write(hlp_frm,'(a,i2,a)') '(a,i2,a,',nspecies_4,'(1x,i2,'',''))'
      if (maxval(mlcmp).gt.0) then
        do ib = 1, nmol
          write(34,hlp_frm)
     .     'MLCMP(1,',ib,')=',(mlcmp(is,ib),is=1,nspecies_4)
        end do
      end if
      ii=minloc(lcns)
      if(lcns(ii(1)).gt.0) then !{
        ncns=nstsid
      else !}{
        ncns=ii(1)-1
      end if !}
      ii=minloc(ltns)
      if(ltns(ii(1)).gt.0) then !{
        ntns=nstsid
      else !}{
        ntns=ii(1)-1
      end if !}
      if (ncns.gt.0 .and. maxval(lcns).gt.0) then
        write(hlp_frm,'(a,i2,a)') '(a,',ncns,'(1x,i3,'',''))'
        write(34,hlp_frm) 'LCNS=',(lcns(ib),ib=1,ncns)
      end if
      if (ntns.gt.0 .and. maxval(ltns).gt.0) then
        write(hlp_frm,'(a,i2,a)') '(a,',ntns,'(1x,i3,'',''))'
        write(34,hlp_frm) 'LTNS=',(ltns(ib),ib=1,ntns)
      end if
      nsns = 0
      do ib = 1, nstrai
        if (crcstra(ib).eq.'N'.or. crcstra(ib).eq.'W'.or.
     &      crcstra(ib).eq.'E') then
          nsns = nsns + 1
        else if (crcstra(ib).eq.'S'.and.
     &      mod(region(rcstart(ib),rcpos(ib),0),4).ne.1) then
          nsns = nsns + 1
        end if
      end do
      write(hlp_frm,'(a,i2,a)') '(a,',nsns,'(1x,i3,'',''))'
      if (nsns.gt.0 .and.
     &   (maxval(lsns).gt.0 .or. minval(lsns).lt.0)) then
        do ib = 1, nsns
          if (lsns(ib).gt.nlim) lsns(ib)=nlim-lsns(ib)
        end do
        write(34,hlp_frm) 'LSNS=',(lsns(ib),ib=1,nsns)
      end if
      if (nsns.gt.0 .and. maxval(ksns).gt.0)
     > write(34,hlp_frm) 'KSNS=',(ksns(ib),ib=1,nsns)
      write(34,'(a,1pe9.2,a)') 'NEUT_SCL_LIM=',neut_scl_lim,','
      if(n_spcsrf_4.gt.0) then !DPC
        write(34,'(a,i2,a)') 'N_SPCSRF=',n_spcsrf_4,','
        ii=minloc(abs(l_spcsrf_4))
        if (ii(1).eq.1) then
          is = 0
        else if (l_spcsrf_4(ii(1)).eq.0) then
          is = ii(1)-1
        else
          is = size(l_spcsrf_4)
        end if
        if (is.gt.0) then
          write(hlp_frm,'(a,i3,a)') '(a,',is,'(i3,'',''))'
          write(34,hlp_frm) 'L_SPCSRF=',(l_spcsrf_4(ib),ib=1,is)
        end if
        write(hlp_frm,'(a,i2,a)') '(a,',n_spcsrf_4,'(a1,a8,a2))'
        write(34,hlp_frm) 'SPS_ID=  ',('''',sps_id_4(ib),''',',
     .                                               ib=1,n_spcsrf_4)
        write(hlp_frm,'(a,i2,a)') '(a,',n_spcsrf_4,'(i10,'',''))'
        write(34, hlp_frm) 'I_SPCSRF=',(i_spcsrf_4(ib),ib=1,n_spcsrf_4)
        write(34, hlp_frm) 'J_SPCSRF=',(j_spcsrf_4(ib),ib=1,n_spcsrf_4)
        write(hlp_frm,'(a,i2,a)') '(a,1p,',n_spcsrf_4,'(e10.3,'',''))'
        write(34, hlp_frm) 'SPS_ABSR=',(sps_absr_4(ib),ib=1,n_spcsrf_4)
        write(34, hlp_frm) 'SPS_TRNO=',(sps_trno_4(ib),ib=1,n_spcsrf_4)
        write(34, hlp_frm) 'SPS_TRNI=',(sps_trni_4(ib),ib=1,n_spcsrf_4)
        write(34, hlp_frm) 'SPS_MTRI=',(sps_mtri_4(ib),ib=1,n_spcsrf_4)
        write(34, hlp_frm) 'SPS_TMPR=',(sps_tmpr_4(ib),ib=1,n_spcsrf_4)
        write(34, hlp_frm) 'SPS_SPPH=',(sps_spph_4(ib),ib=1,n_spcsrf_4)
        write(34, hlp_frm) 'SPS_SPCH=',(sps_spch_4(ib),ib=1,n_spcsrf_4)
        write(hlp_frm,'(a,i2,a)') '(a,',n_spcsrf_4,'(i10,'',''))'
        write(34, hlp_frm) 'SPS_SGRP=',(sps_sgrp_4(ib),ib=1,n_spcsrf_4)
        write(hlp_frm,'(a,i2,a)')
     .   '(a,',n_spcsrf_4,'('''''''',a8,'''''''','',''))'
        write(34, hlp_frm) 'SPS_MTRL=',(sps_mtrl_4(ib),ib=1,n_spcsrf_4)
      endif
      do ib = 1, 100
        if (debug_flags(ib).ne.0) write(34,'(a,i3,a,i2,a)')
     .   'DEBUG_FLAGS(',ib,')=',debug_flags(ib),','
      end do
      write(34,'(a)') '/'
      close(34)
      deallocate(sps_id_4)
      deallocate(i_spcsrf_4)
      deallocate(j_spcsrf_4)
      deallocate(l_spcsrf_4)
      deallocate(sps_absr_4)
      deallocate(sps_trno_4)
      deallocate(sps_trni_4)
      deallocate(sps_mtri_4)
      deallocate(sps_tmpr_4)
      deallocate(sps_spph_4)
      deallocate(sps_spch_4)
      deallocate(sps_sgrp_4)
      deallocate(sps_mtrl_4)
      return
      end subroutine write_neutrals_namelist
c
      subroutine write_numerics_namelist(ns)
      use b2mod_types
      use b2mod_indirect
      use b2mod_numerics_namelist
      implicit none
      integer ns
      integer is, ireg
      logical needed
      character*32 hlp_frm

      write(*,*) 'Writing b2.numerics.parameters'
      open(33,file='b2.numerics.parameters')
      write(33,'(a)') '&NUMERICS'
      write(hlp_frm,'(a,i1,a)') '(a,1p,',nnreg(0),'(e9.2,'',''))'
      needed = .false.
      do ireg = 1, nnreg(0)
        needed = needed .or. dtee(ireg).ne.1.0_R8
      end do
      if (needed)
     > write(33, hlp_frm) 'DTEE(1)=',(dtee(ireg),ireg=1,nnreg(0))
      needed = .false.
      do ireg = 1, nnreg(0)
        needed = needed .or. dtei(ireg).ne.1.0_R8
      end do
      if (needed)
     > write(33, hlp_frm) 'DTEI(1)=',(dtei(ireg),ireg=1,nnreg(0))
      write(hlp_frm,'(a,i2,a)') '(a,i1,a,1p,',ns,'(e9.2,'',''))'
      do ireg = 1, nnreg(0)
        needed = .false.
        do is = 0, ns-1
          needed = needed .or. dtco(is,ireg).ne.1.0_R8
        end do
        if (needed)
     >   write(33, hlp_frm)
     .   'DTCO(0,',ireg,')=',(dtco(is,ireg),is=0,ns-1)
        needed = .false.
        do is = 0, ns-1
          needed = needed .or. dtmo(is,ireg).ne.1.0_R8
        end do
        if (needed)
     >   write(33, hlp_frm)
     .   'DTMO(0,',ireg,')=',(dtmo(is,ireg),is=0,ns-1)
      end do
      if (time_factor_required.ne.0.1_R8) write(33,'(a,1pe9.2,a)')
     . 'TIME_FACTOR_REQUIRED=',time_factor_required,','
      write(33,'(a)') '/'
      close(33)
      return
      end subroutine write_numerics_namelist
c
      subroutine write_feedback_control_namelist(nx,ny)
      use b2mod_types
      use b2mod_b2cmpa
      use b2mod_feedback
      use b2mod_indirect
      use b2mod_neutrals_namelist
      implicit none
      integer nx, ny
      integer is
      character*32 hlp_frm
      logical todo

      todo = .false.
      do is = 1, nspecies_4
        todo = todo .or. ffb_cntr_4(is).ne.0 .or. cfb_cntr_4(is).ne.0
        if (ffb_cntr_4(is).eq.1) then
          if (ffb_include_core_4(is)) then
            if (ffb_include_neutrals_4(is)) then
              na_feedback_choice(is-1) = 4
            else
              na_feedback_choice(is-1) = 5
            endif
            na_feedback_ix1(is-1) = 0
            na_feedback_ix2(is-1) = nx-1
            na_feedback_iy1(is-1) = 0
            na_feedback_iy2(is-1) = ny-1
          else
            if (ffb_include_neutrals_4(is)) then
              na_feedback_choice(is-1) = 11
            else
              na_feedback_choice(is-1) = 5
              na_feedback_ix1(is-1) = 0
              na_feedback_ix2(is-1) = nx-1
              na_feedback_iy1(is-1) = jsep+1
              na_feedback_iy2(is-1) = ny-1
            endif
          end if
          if (ffb_rate_4(is).ge.0.0_R8) then
            na_feedback_option(is-1) = 4
          else
            na_feedback_option(is-1) = 5
          endif
          na_feedback_actuator(is-1) = 1
          na_feedback_target(is-1) = ffb_const_4(is)
          na_feedback_const(is-1) = ffb_const_4(is)
          na_feedback_alpha(is-1) = ffb_over_4(is)
          if (ffb_init_4(is)) then
            na_feedback_beta(is-1) = ffb_rate_4(is)
          else
            na_feedback_beta(is-1) = 0.0_R8
          endif
          na_feedback_actuator_min(is-1) = 0.0_R8
          na_feedback_actuator_max(is-1) = ffb_smax_4(is)
          na_feedback_overshoot(is-1) = 0.0_R8
          na_feedback_time(is-1) = ffb_start_4(is)
        else if (ffb_cntr_4(is).eq.2) then
          na_feedback_choice(is-1) = 7
          na_feedback_option(is-1) = 4
          na_feedback_actuator(is-1) = 1
          na_feedback_ix1(is-1) = leftcut(1)+1
          na_feedback_ix2(is-1) = rightcut(1)
          na_feedback_iy1(is-1) = jsep+1
          na_feedback_iy2(is-1) = jsep+1
          na_feedback_target(is-1) = ffb_const_4(is)
          na_feedback_const(is-1) = ffb_const_4(is)
          na_feedback_alpha(is-1) = ffb_over_4(is)
          na_feedback_beta(is-1) = 0.0_R8
          na_feedback_actuator_min(is-1) = 0.0_R8
          na_feedback_actuator_max(is-1) = ffb_smax_4(is)
          na_feedback_overshoot(is-1) = 0.0_R8
          na_feedback_time(is-1) = ffb_start_4(is)
        end if
        if (cfb_cntr_4(is).eq.1) then
          na_feedback_choice(is-1) = 6
          na_feedback_option(is-1) = 6
          if (ffb_cntr_4(is).ne.0) then
            na_feedback_actuator(is-1) = 1
          else
            na_feedback_actuator(is-1) = 3
          end if
          na_feedback_ix1(is-1) = leftcut(1)+1
          na_feedback_ix2(is-1) = rightcut(1)
          na_feedback_iy1(is-1) = 0
          na_feedback_iy2(is-1) = 0
          na_feedback_target(is-1) = cfb_core_4(is)
          na_feedback_const(is-1) = cfb_core_4(is)
          if (cfb_over_4(is).gt.0.0_R8) then
            na_feedback_alpha(is-1) = cfb_over_4(is)
          else
            na_feedback_alpha(is-1) = 0.01_R8
          end if
          na_feedback_beta(is-1) = 0.0_R8
          na_feedback_actuator_min(is-1) = 0.0_R8
          na_feedback_actuator_max(is-1) = cfb_smax_4(is)
          na_feedback_overshoot(is-1) = 0.0_R8
        end if
      end do
      if (.not.todo) return
      write(*,*) 'Writing b2.feedback_control.parameters'
      open(36,file='b2.feedback_control.parameters')
      write(hlp_frm,'(a,i2,a)') '(1x,a,',nspecies,'(1x,i4,'',''))'
      write(36,'(a)') '&FEEDBACK_CONTROL'
      if (maxval(na_feedback_choice(0:nspecies-1)).gt.0)
     > write(36,hlp_frm)
     .     'NA_FEEDBACK_CHOICE=  ',na_feedback_choice(0:nspecies-1)
      if (maxval(na_feedback_option(0:nspecies-1)).gt.0)
     > write(36,hlp_frm)
     .     'NA_FEEDBACK_OPTION=  ',na_feedback_option(0:nspecies-1)
      if (maxval(na_feedback_actuator(0:nspecies-1)).gt.0)
     > write(36,hlp_frm)
     .     'NA_FEEDBACK_ACTUATOR=',na_feedback_actuator(0:nspecies-1)
      write(hlp_frm,'(a,i2,a)') '(1x,a,',nspecies,'(1x,i4,'',''))'
      if (maxval(na_feedback_ib(0:nspecies-1)).gt.0)
     > write(36,hlp_frm)
     .     'NA_FEEDBACK_IB=      ',na_feedback_ib(0:nspecies-1)
      if (maxval(na_feedback_ix1(0:nspecies-1)).gt.-2)
     > write(36,hlp_frm)
     .     'NA_FEEDBACK_IX1=     ',na_feedback_ix1(0:nspecies-1)
      if (maxval(na_feedback_ix2(0:nspecies-1)).gt.-2)
     > write(36,hlp_frm)
     .     'NA_FEEDBACK_IX2=     ',na_feedback_ix2(0:nspecies-1)
      if (maxval(na_feedback_iy1(0:nspecies-1)).gt.-2)
     > write(36,hlp_frm)
     .     'NA_FEEDBACK_IY1=     ',na_feedback_iy1(0:nspecies-1)
      if (maxval(na_feedback_iy2(0:nspecies-1)).gt.-2)
     > write(36,hlp_frm)
     .     'NA_FEEDBACK_IY2=     ',na_feedback_iy2(0:nspecies-1)
      write(hlp_frm,'(a,i2,a)')
     .   '(1x,a,1p,',nspecies,'(1x,g10.3,'',''))'
      if (maxval(na_feedback_target(0:nspecies-1)).gt.0.0_R8 .or.
     .    minval(na_feedback_target(0:nspecies-1)).lt.0.0_R8)
     > write(36,hlp_frm)
     .     'NA_FEEDBACK_TARGET=  ',na_feedback_target(0:nspecies-1)
      if (maxval(na_feedback_alpha(0:nspecies-1)).ne.0.001_R8 .or.
     &    minval(na_feedback_alpha(0:nspecies-1)).ne.0.001_R8)
     > write(36,hlp_frm)
     .     'NA_FEEDBACK_ALPHA=   ',na_feedback_alpha(0:nspecies-1)
      if (maxval(na_feedback_beta(0:nspecies-1)).ne.1.0_R8 .or.
     &    minval(na_feedback_beta(0:nspecies-1)).ne.1.0_R8)
     > write(36,hlp_frm)
     .     'NA_FEEDBACK_BETA=    ',na_feedback_beta(0:nspecies-1)
      if (maxval(na_feedback_const(0:nspecies-1)).ne.0.0_R8 .or.
     &    minval(na_feedback_const(0:nspecies-1)).ne.0.0_R8 .or.
     &    maxval(na_feedback_choice(0:nspecies-1)).gt.0)
     > write(36,hlp_frm)
     .     'NA_FEEDBACK_CONST=   ',na_feedback_const(0:nspecies-1)
      if (maxval(na_feedback_actuator_min(0:nspecies-1)).gt.0.0_R8)
     > write(36,hlp_frm)
     .     'NA_FEEDBACK_ACTUATOR_MIN=',
     .      na_feedback_actuator_min(0:nspecies-1)
      if (maxval(na_feedback_actuator_max(0:nspecies-1)).gt.0.0_R8)
     > write(36,hlp_frm)
     .     'NA_FEEDBACK_ACTUATOR_MAX=',
     .      na_feedback_actuator_max(0:nspecies-1)
      if (maxval(na_feedback_overshoot(0:nspecies-1)).gt.0.0_R8)
     > write(36,hlp_frm) 'NA_FEEDBACK_OVERSHOOT=',
     .     na_feedback_overshoot(0:nspecies-1)
      if (maxval(na_feedback_time(0:nspecies-1)).gt.0.0_R8)
     > write(36,hlp_frm) 'NA_FEEDBACK_TIME=',
     .     na_feedback_time(0:nspecies-1)
      write(36,'(a)') '/'
      close(36)
      return
      end subroutine write_feedback_control_namelist
c
      subroutine write_user_namelist
      use b2mod_types
      use b2mod_user_namelist
      implicit none
      integer i, is, ii(1)
      character*32 hlp_frm

      write(*,*) 'Writing b2.user.parameters'
      open(38,file='b2.user.parameters')
      write(38,'(a)') '&USER'
      write(38,'(a,1pe9.2,a)') 'FUSION_POWER=',fusion_power,','
      if (j_h_at(1).ne.0) write(38,'(a,i2,a)') 'J_H_AT=',j_h_at(1),','
      if (j_he_at.ne.0) write(38,'(a,i2,a)') 'J_HE_AT=',j_he_at,','
      write(hlp_frm, '(a,i2,a)') '(a,',nmol,'(i2,'',''))'
      write(38, hlp_frm) 'L_H_MOL=',(l_h_mol(is,1),is=1,nmol)
      write(38,'(a,1pe9.2,a)') 'Spmp_He_to_D=',Spmp_He_to_D,','
      write(38,'(a,1pe9.2,a)') 'Spmp_nom=',Spmp_nom,','
      write(38,'(a,l1,a)') 'SCALE_HE= ',scale_He,','
      write(38,'(a,l1,a)') 'PRINT_ISAT=',print_isat,','
      write(38,'(a,i2,a)') 'LPFRS_PMP=',lpfrs_pmp,','
      if (lpfrb_i.ne.0) write(38,'(a,i3,a)') 'LPFRB_I=',lpfrb_i,','
      if (lpfrb_o.ne.0) write(38,'(a,i3,a)') 'LPFRB_O=',lpfrb_o,','
      if (lpfrt_i.ne.0) write(38,'(a,i3,a)') 'LPFRT_I=',lpfrt_i,','
      if (lpfrt_o.ne.0) write(38,'(a,i3,a)') 'LPFRT_O=',lpfrt_o,','
      if (npfrgrp.ne.0) then
        write(38,'(a,i2,a)') 'NPFRGRP=',npfrgrp,','
        write(hlp_frm, '(a,i2,a)') '(a,',npfrgrp,'(i3,'',''))'
        write(38, hlp_frm) 'IPFRGRP=',(ipfrgrp(is),is=1,npfrgrp)
        write(38, hlp_frm) 'JPFRGRP=',(jpfrgrp(is),is=1,npfrgrp)
        write(hlp_frm,'(a,i2,a)') '(a,',npfrgrp,'(a1,a8,a2))'
        write(38,hlp_frm) 'GPFRGRP=',('''',gpfrgrp(is),''',',
     .                                             is=1,npfrgrp)
        write(hlp_frm, '(a,i3,a)') '(a,',jpfrgrp(npfrgrp),'(i3,'',''))'
        write(38, hlp_frm) 'LPFRGRP=',
     .   (lpfrgrp(is),is=1,jpfrgrp(npfrgrp))
      end if
      if (nntrgrp.ne.0) then
        write(38,'(a,i2,a)') 'NNTRGRP=',nntrgrp,','
        write(hlp_frm, '(a,i2,a)') '(a,',nntrgrp,'(i3,'',''))'
        write(38, hlp_frm) 'INTRGRP=',(intrgrp(is),is=1,nntrgrp)
        write(38, hlp_frm) 'JNTRGRP=',(jntrgrp(is),is=1,nntrgrp)
        write(hlp_frm,'(a,i2,a)') '(a,',nntrgrp,'(a1,a8,a2))'
        write(38,hlp_frm) 'GNTRGRP=',('''',gntrgrp(is),''',',
     .                                             is=1,nntrgrp)
        write(hlp_frm, '(a,i3,a)') '(a,',jntrgrp(nntrgrp),'(i3,'',''))'
        write(38, hlp_frm) 'LNTRGRP=',
     .   (lntrgrp(is),is=1,jntrgrp(nntrgrp))
      end if
      ii=minloc(lhetrgts)
      if (lhetrgts(ii(1)).ne.0) then
        i = size(lhetrgts)
      else if (ii(1).ne.1) then
        i = ii(1)-1
      else
        i = 0
      end if
      if (i.gt.0) then
        write(hlp_frm, '(a,i3,a)') '(a,',i,'(i3,'',''))'
        write(38, hlp_frm) 'LHETRGTS=',(lhetrgts(is),is=1,i)
      end if
      write(38,'(a)') '/'
      close(38)
      return
      end subroutine write_user_namelist
c
      subroutine write_SOLPS_FLUIDS_NREG(nreg,ns)
      integer nreg, ns
      integer is
      character*11 hlp_frm
      character*10, allocatable :: species_name(:)
      external species

*   ..we now write the SOLPS_FLUIDS and NREG files
      write(*,*) 'Writing ../SOLPS_FLUIDS'
      allocate(species_name(0:ns-1))
      do is = 0, ns-1
        call species(is,species_name(is),.false.)
      enddo
      write(hlp_frm,'(a1,i3,a7)') '(',ns,'(a,1x))'
      open(unit=99,file='../SOLPS_FLUIDS')
      write(99,hlp_frm) (trim(species_name(is)),is=0,ns-1)
      close(99)
      deallocate(species_name)
      write(*,*) 'Writing ../NREG'
      open(unit=99,file='../NREG')
      write(99,'(i2)') nreg
      close(99)
      return
      end subroutine write_SOLPS_FLUIDS_NREG
c
      subroutine dealloc_b2_4to5_plasma
      deallocate(fhe_4)
      deallocate(fhi_4)
      deallocate(fna_4)
      deallocate(na_4)
      deallocate(te_4)
      deallocate(ti_4)
      deallocate(ua_4)
      deallocate(nfluids_4)
      deallocate(mi_4,zi_4)
      deallocate(crx_4,cry_4,bb_4)
      return
      end subroutine dealloc_b2_4to5_plasma
c
      subroutine dealloc_b2_4to5_input
      deallocate(ifl,jfl,is1)
      deallocate(nxcut1_4,nxcut2_4,nycut1_4,nycut2_4)
      if (nniso_4.gt.0) deallocate(nxiso1_4,nxiso2_4,nyiso1_4,nyiso2_4)
      deallocate(bcpos_4,bcstart_4,bcend_4,bcchar_4)
      deallocate(bccon_4,bcmom_4,bcene_4,bceni_4)
      deallocate(conpar_4,mompar_4,enepar_4,enipar_4)
      deallocate(phiin_4,phiout_4)
      deallocate(lcbs_4)
      deallocate(crcstra_4,rcpos_4,rcend_4,rcstart_4)
      deallocate(recyc_4)
      deallocate(userfluxparm_4,rf_neut_4)
      deallocate(lstrascl_4,lmolscl_4)
      deallocate(ksns_4,lcns_4,lsns_4,ltns_4,mlcmp_4,msns_4,gpfc_4)
      deallocate(nspzi_4,nspze_4)
      deallocate(debug_flags_4)
      deallocate(niiso_4)
      deallocate(dtee_4,dtei_4,dtmo_4,dtco_4)
      deallocate(lhetrgts_4,l_h_mol_4)
      deallocate(lpfrgrp_4,ipfrgrp_4,jpfrgrp_4,gpfrgrp_4)
      deallocate(lntrgrp_4,intrgrp_4,jntrgrp_4,gntrgrp_4)
#ifndef NO_B2_CHEM_SPUT
      deallocate(chemical_sputter_yield_4)
#endif
      return
      end subroutine dealloc_b2_4to5_input
c
      subroutine map4_5x(nx,ny,ns,crx,cry,vol,bb,field)
      use b2mod_types
      use b2mod_indirect
      implicit none
*   ..input parameters (unchanged on exit)
      integer nx,ny,ns
      real (kind=R8) ::
     * crx(-1:nx,-1:ny,0:3), cry(-1:nx,-1:ny,0:3),
     * vol(-1:nx,-1:ny), bb(-1:nx,-1:ny,0:3)
*   ..output parameters (to be modified here)
      real (kind=R8) ::
     1 field(-1:nx,-1:ny,0:ns-1)
*   ..local variables
      integer ix,iy,is
      real (kind=R8) ::
     * work(-1:nx,-1:ny,0:ns-1)
      real (kind=R8) ::
     * hxg, hxr, xa, ya, xb, yb
      integer, save :: interptype
*   ..procedures
      intrinsic sqrt
      external xerrab
*   ..initialisation
      data interptype /1/

      call subini ('map4_5x')
      if (interptype.eq.1) then
cxpb Interpolation from cell faces to cell centers
cxpb For guard cell quantities, extrapolate using
cxpb the local gradient into the guard cell.
cxpb We use these results for the core and the leftmost guard cells.
        do is=0,ns-1
          do iy=-1,ny
            do ix=-1,nx
              if(leftix(ix,iy).eq.-2) then
                xa = 0.5_R8*(crx(rightix(ix,iy),rightiy(ix,iy),0)+
     1                       crx(rightix(ix,iy),rightiy(ix,iy),2))
                ya = 0.5_R8*(cry(rightix(ix,iy),rightiy(ix,iy),0)+
     1                       cry(rightix(ix,iy),rightiy(ix,iy),2))
                xb = 0.5_R8*(crx(rightix(ix,iy),rightiy(ix,iy),1)+
     1                       crx(rightix(ix,iy),rightiy(ix,iy),3))
                yb = 0.5_R8*(cry(rightix(ix,iy),rightiy(ix,iy),1)+
     1                       cry(rightix(ix,iy),rightiy(ix,iy),3))
                hxr = sqrt((xb-xa)**2+(yb-ya)**2)
                xa = 0.5_R8*(crx(ix,iy,0)+crx(ix,iy,2))
                ya = 0.5_R8*(cry(ix,iy,0)+cry(ix,iy,2))
                xb = 0.5_R8*(crx(ix,iy,1)+crx(ix,iy,3))
                yb = 0.5_R8*(cry(ix,iy,1)+cry(ix,iy,3))
                hxg = sqrt((xb-xa)**2+(yb-ya)**2)
                work(ix,iy,is)=field(rightix(ix,iy),rightiy(ix,iy),is)+
     1           (field(ix,iy,is)-
     .            field(rightix(ix,iy),rightiy(ix,iy),is))
     2          *(hxr+hxg/2.0_R8)/hxr
              elseif(rightix(ix,iy).eq.nx+1) then
                xa = 0.5_R8*(crx(leftix(leftix(ix,iy),leftiy(ix,iy)),
     .                           leftiy(leftix(ix,iy),leftiy(ix,iy)),0)+
     1                       crx(leftix(leftix(ix,iy),leftiy(ix,iy)),
     .                           leftiy(leftix(ix,iy),leftiy(ix,iy)),2))
                ya = 0.5_R8*(cry(leftix(leftix(ix,iy),leftiy(ix,iy)),
     .                           leftiy(leftix(ix,iy),leftiy(ix,iy)),0)+
     1                       cry(leftix(leftix(ix,iy),leftiy(ix,iy)),
     .                           leftiy(leftix(ix,iy),leftiy(ix,iy)),2))
                xb = 0.5_R8*(crx(leftix(leftix(ix,iy),leftiy(ix,iy)),
     .                           leftiy(leftix(ix,iy),leftiy(ix,iy)),1)+
     1                       crx(leftix(leftix(ix,iy),leftiy(ix,iy)),
     .                           leftiy(leftix(ix,iy),leftiy(ix,iy)),3))
                yb = 0.5_R8*(cry(leftix(leftix(ix,iy),leftiy(ix,iy)),
     .                           leftiy(leftix(ix,iy),leftiy(ix,iy)),1)+
     1                       cry(leftix(leftix(ix,iy),leftiy(ix,iy)),
     .                           leftiy(leftix(ix,iy),leftiy(ix,iy)),3))
                hxr = sqrt((xb-xa)**2+(yb-ya)**2)
                xa = 0.5_R8*(crx(leftix(ix,iy),leftiy(ix,iy),0)+
     1                       crx(leftix(ix,iy),leftiy(ix,iy),2))
                ya = 0.5_R8*(cry(leftix(ix,iy),leftiy(ix,iy),0)+
     1                       cry(leftix(ix,iy),leftiy(ix,iy),2))
                xb = 0.5_R8*(crx(leftix(ix,iy),leftiy(ix,iy),1)+
     1                       crx(leftix(ix,iy),leftiy(ix,iy),3))
                yb = 0.5_R8*(cry(leftix(ix,iy),leftiy(ix,iy),1)+
     1                       cry(leftix(ix,iy),leftiy(ix,iy),3))
                hxg = sqrt((xb-xa)**2+(yb-ya)**2)
                work(ix,iy,is)=
     .            field(leftix(leftix(ix,iy),leftiy(ix,iy)),
     .                  leftiy(leftix(ix,iy),leftiy(ix,iy)),is)+
     1           (field(leftix(ix,iy),leftiy(ix,iy),is)-
     .            field(leftix(leftix(ix,iy),leftiy(ix,iy)),
     .                  leftiy(leftix(ix,iy),leftiy(ix,iy)),is))
     2          *(hxr+hxg/2.0_R8)/hxr
              else
                work(ix,iy,is)=0.5_R8*
     1           (field(leftix(ix,iy),leftiy(ix,iy),is)+field(ix,iy,is))
              endif
            enddo
          enddo
        enddo
      endif
cxpb  We recompute the guard cell values to maintain the fluxes
      do iy = -1, ny
        do ix = -1, nx
          do is = 0, ns-1
            if (leftix(ix,iy).eq.-2) then
              work(ix,iy,is)=(field(ix,iy,is)*
     .         (vol(ix,iy)+vol(rightix(ix,iy),rightiy(ix,iy)))-
     .         work(rightix(ix,iy),rightiy(ix,iy),is)*vol(ix,iy))/
     .          vol(rightix(ix,iy),rightiy(ix,iy))
            else if (rightix(ix,iy).eq.nx+1) then
              work(ix,iy,is)=(field(leftix(ix,iy),leftiy(ix,iy),is)*
     .         (vol(ix,iy)+vol(leftix(ix,iy),leftiy(ix,iy)))-
     .         work(leftix(ix,iy),leftiy(ix,iy),is)*vol(ix,iy))/
     .          vol(leftix(ix,iy),leftiy(ix,iy))
            end if
          end do
        end do
      end do
      if (interptype.ge.2) then
cxpb  Interpolation scheme intended to keep parallel fluxes constant
cxpb  We reverse-engineer the velocities.
        do iy = -1, ny
          ix = -1
          do while (rightix(ix,iy).le.nx)
            do is = 0, ns-1
              if (ifl(is).ne.0) then
                work(rightix(ix,iy),iy,is) =
     .           (field(ix,iy,is)*(vol(ix,iy)+vol(rightix(ix,iy),iy))-
     .            work(ix,iy,is)*vol(rightix(ix,iy),iy))/vol(ix,iy)
              endif
            enddo
            ix=rightix(ix,iy)
          enddo
        enddo
      endif
      do is=0,ns-1
        do iy=-1,ny
          do ix=-1,nx
            field(ix,iy,is)=work(ix,iy,is)
          enddo
        enddo
      enddo
      call subend ()
      return
      end subroutine map4_5x
c
      subroutine map4_5y(nx,ny,ns,crx,cry,vol,bb,field)
      use b2mod_types
      use b2mod_indirect
      implicit none
*   ..input parameters (unchanged on exit)
      integer nx,ny,ns
      real (kind=R8) ::
     * crx(-1:nx,-1:ny,0:3), cry(-1:nx,-1:ny,0:3),
     * vol(-1:nx,-1:ny), bb(-1:nx,-1:ny,0:3)
*   ..output parameters (to be modified here)
      real (kind=R8) ::
     1 field(-1:nx,-1:ny,0:ns-1)
*   ..local variables
      integer ix,iy,is
      real (kind=R8) ::
     * work(-1:nx,-1:ny,0:ns-1)
      real (kind=R8) ::
     * hxg, hxn, xa, ya, xb, yb
      integer, save :: interptype
*   ..procedures
      intrinsic sqrt
      external xerrab
*   ..initialisation
      data interptype /1/

      call subini ('map4_5y')
      if (interptype.eq.1) then
cxpb Interpolation from cell faces to cell centers
cxpb For guard cell quantities, extrapolate using
cxpb the local gradient into the guard cell.
cxpb We use these results for the core and the leftmost guard cells.
        do is=0,ns-1
          do iy=-1,ny
            do ix=-1,nx
              if(bottomiy(ix,iy).eq.-2) then
                xa = 0.5_R8*(crx(topix(ix,iy),topiy(ix,iy),0)+
     1                       crx(topix(ix,iy),topiy(ix,iy),1))
                ya = 0.5_R8*(cry(topix(ix,iy),topiy(ix,iy),0)+
     1                       cry(topix(ix,iy),topiy(ix,iy),1))
                xb = 0.5_R8*(crx(topix(ix,iy),topiy(ix,iy),2)+
     1                       crx(topix(ix,iy),topiy(ix,iy),3))
                yb = 0.5_R8*(cry(topix(ix,iy),topiy(ix,iy),2)+
     1                       cry(topix(ix,iy),topiy(ix,iy),3))
                hxn = sqrt((xb-xa)**2+(yb-ya)**2)
                xa = 0.5_R8*(crx(ix,iy,0)+crx(ix,iy,1))
                ya = 0.5_R8*(cry(ix,iy,0)+cry(ix,iy,1))
                xb = 0.5_R8*(crx(ix,iy,2)+crx(ix,iy,3))
                yb = 0.5_R8*(cry(ix,iy,2)+cry(ix,iy,3))
                hxg = sqrt((xb-xa)**2+(yb-ya)**2)
                work(ix,iy,is)=field(topix(ix,iy),topiy(ix,iy),is)+
     1           (field(ix,iy,is)-
     .            field(topix(ix,iy),topiy(ix,iy),is))
     2          *(hxn+hxg/2.0_R8)/hxn
              elseif(topiy(ix,iy).eq.ny+1) then
                xa = 0.5_R8*
     .             (crx(bottomix(bottomix(ix,iy),bottomiy(ix,iy)),
     .                  bottomiy(bottomix(ix,iy),bottomiy(ix,iy)),0)+
     1              crx(bottomix(bottomix(ix,iy),bottomiy(ix,iy)),
     .                  bottomiy(bottomix(ix,iy),bottomiy(ix,iy)),1))
                ya = 0.5_R8*
     .             (cry(bottomix(bottomix(ix,iy),bottomiy(ix,iy)),
     .                  bottomiy(bottomix(ix,iy),bottomiy(ix,iy)),0)+
     1              cry(bottomix(bottomix(ix,iy),bottomiy(ix,iy)),
     .                  bottomiy(bottomix(ix,iy),bottomiy(ix,iy)),1))
                xb = 0.5_R8*
     .             (crx(bottomix(bottomix(ix,iy),bottomiy(ix,iy)),
     .                  bottomiy(bottomix(ix,iy),bottomiy(ix,iy)),2)+
     1              crx(bottomix(bottomix(ix,iy),bottomiy(ix,iy)),
     .                  bottomiy(bottomix(ix,iy),bottomiy(ix,iy)),3))
                yb = 0.5_R8*
     .             (cry(bottomix(bottomix(ix,iy),bottomiy(ix,iy)),
     .                  bottomiy(bottomix(ix,iy),bottomiy(ix,iy)),2)+
     1              cry(bottomix(bottomix(ix,iy),bottomiy(ix,iy)),
     .                  bottomiy(bottomix(ix,iy),bottomiy(ix,iy)),3))
                hxn = sqrt((xb-xa)**2+(yb-ya)**2)
                xa = 0.5_R8*(crx(bottomix(ix,iy),bottomiy(ix,iy),0)+
     1                       crx(bottomix(ix,iy),bottomiy(ix,iy),1))
                ya = 0.5_R8*(cry(bottomix(ix,iy),bottomiy(ix,iy),0)+
     1                       cry(bottomix(ix,iy),bottomiy(ix,iy),1))
                xb = 0.5_R8*(crx(bottomix(ix,iy),bottomiy(ix,iy),2)+
     1                       crx(bottomix(ix,iy),bottomiy(ix,iy),3))
                yb = 0.5_R8*(cry(bottomix(ix,iy),bottomiy(ix,iy),2)+
     1                       cry(bottomix(ix,iy),bottomiy(ix,iy),3))
                hxg = sqrt((xb-xa)**2+(yb-ya)**2)
                work(ix,iy,is)=
     .            field(bottomix(bottomix(ix,iy),bottomiy(ix,iy)),
     .                  bottomiy(bottomix(ix,iy),bottomiy(ix,iy)),is)+
     1           (field(bottomix(ix,iy),bottomiy(ix,iy),is)-
     .            field(bottomix(bottomix(ix,iy),bottomiy(ix,iy)),
     .                  bottomiy(bottomix(ix,iy),bottomiy(ix,iy)),is))
     2          *(hxn+hxg/2.0_R8)/hxn
              else
                work(ix,iy,is)=0.5_R8*
     1           (field(bottomix(ix,iy),bottomiy(ix,iy),is)+
     2            field(ix,iy,is))
              endif
            enddo
          enddo
        enddo
      endif
      do is=0,ns-1
        do iy=-1,ny
          do ix=-1,nx
            field(ix,iy,is)=work(ix,iy,is)
          enddo
        enddo
      enddo
      call subend ()
      return
      end subroutine map4_5y
c
      end module b2_4to5
