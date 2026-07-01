
# all files are .f90 files, move them to .F90 extension
move_to_F90.sh
rm b2uxus_b.F90 solve_covariance_b.F90 calc_res_fp_b.F90 cfwure_b.F90 cfwuin_b.F90 invert_matrix_b.F90 b2mod_blns_b.F90
collect_nodiff_b.sh
rm damax_b.F90 smin_b.F90 smax_b.F90 get_jsep_b.F90 my_outi_us_b.F90

sed -i '/DIFFSIZES/d' ./*.F90
sed -i '/INTRINSIC DABS/d' b2us_geo_diff.F90 b2trcl_b.F90 b2srsm_b.F90
sed -i -e 's/DIMENSION(:) :: dabs0/DIMENSION(mpg%nFs) :: dabs0/g' b2us_geo_diff.F90
sed -i -e 's/DIMENSION(ISIZE1OFMETAVAR:abs)/DIMENSION(mpg%nFs)/g' b2us_geo_diff.F90
sed -i -e 's/INTEGER, DIMENSION(ISIZE1OFresult1)/INTEGER/g' b2us_geo_diff.F90
sed -i -e 's/DIMENSION(ISIZE1OFfspsi)/DIMENSION(mpg%nFs)/g' b2us_geo_diff.F90
sed -i -e '0,/\& nshift_opt, ncorr_opt/{s/\& nshift_opt, ncorr_opt/\& nshift_opt, ncorr_opt, par_opt_phys, par_opt_physb/g}' b2mn_b.F90
sed -i -e 's/REAL :: result1$/integer :: result1/g' b2mod_input_profile_diff.F90
sed -i -e 's/DIMENSION(SIZE(x1, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x2, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x3, 1), SIZE(x3, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x4, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x5, 1), SIZE(x5, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(:, :) :: dabs0/DIMENSION(mpg%nCv, 0:ns-1) :: dabs0/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(:, :) :: dabs1/DIMENSION(mpg%nCv, 0:ns-1) :: dabs1/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(:, :) :: dabs2/DIMENSION(mpg%nCv, 0:ns-1) :: dabs2/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(:, :) :: dabs3/DIMENSION(mpg%nCv, 0:ns-1) :: dabs3/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(:) :: dabs4/DIMENSION(mpg%nCv) :: dabs4/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(rza0, 1), SIZE(rza0, 2)) :: mask/DIMENSION(mpg%nCv, 0:ns-1) :: mask/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(rz20, 1), SIZE(rz20, 2)) :: mask0/DIMENSION(mpg%nCv, 0:ns-1) :: mask0/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(rpt0, 1), SIZE(rpt0, 2)) :: mask1/DIMENSION(mpg%nCv, 0:ns-1) :: mask1/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(rpi0, 1), SIZE(rpi0, 2)) :: mask2/DIMENSION(mpg%nCv, 0:ns-1) :: mask2/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE1OFne/mpg%nCv/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE1OFabs/mpg%nCv/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE2OFabs/0:state%pl%ns-1/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE1OFarg1/mpg%nCv/g' b2mod_driver_diff.F90 b2mod_recycle_diff.F90
sed -i -e 's/ISIZE1OFarg1/nCv/g' b2sikt_b.F90 b2tfhe__b.F90
sed -i -e 's/ISIZE1OFmask/mpg%nCv/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE2OFmask/state%pl%ns/g' b2mod_driver_diff.F90 
sed -i -e 's/ISIZE1OFmask/nCv/g' b2tqna_b.F90 b2trcl_b.F90
sed -i -e 's/ISIZE1OFcvsahz_eff/nFc/g'  b2mod_recycle_diff.F90
sed -i -e 's/ISIZE2OFcvsahz_eff/0:1/g' b2mod_recycle_diff.F90
sed -i -e 's/ISIZE1OFcvsahz/nFc/g' b2mod_recycle_diff.F90
sed -i -e 's/ISIZE2OFcvsahz/0:1/g' b2mod_recycle_diff.F90
sed -i -e 's/ISIZE1OFdv%fch_pi_c/nCv/g' b2news__b.F90
sed -i -e 's/ISIZE1OFcvsa/nFc/g' b2npmo_b.F90
sed -i -e 's/ISIZE1OFdv%ne2/nCv/g' b2npmo_b.F90
sed -i -e 's/ISIZE1OFdv%lnlam/nCv/g' b2npmo_b.F90
sed -i -e 's/ISIZE1OFlnlam/nCv/g' b2trcl_b.F90 b2trzh_b.F90 b2npmo_b.F90
sed -i -e 's/ISIZE1OFMETAVAR:abs/nCv/g' b2trcl_b.F90
sed -i -e 's/ISIZE1OFvxhz/nVx/g' b2nxfv_b.F90 
sed -i -e 's/ISIZE1OFcvhz/nCv/g' b2nxfv_b.F90
sed -i -e 's/ISIZE1OFgeo%cvvol/nCv/g' b2stbc_b.F90
sed -i -e 's/ISIZE1OFfcqalf/nFc/g' b2stbc_b.F90 b2stbc_phys_b.F90 b2tfch__b.F90 b2tfhe__b.F90 b2tfhi__b.F90 b2trno_b.F90
sed -i -e 's/ISIZE1OFfcbb/nFc/g' b2siav_zh_b.F90
sed -i -e 's/ISIZE1OFcdpa/nFc/g' b2tfcc_b.F90 b2tfnb_b.F90
sed -i -e 's/ISIZE1OFne/nCv/g' b2tfhe__b.F90 b2tfrn_b.F90 b2tqna_b.F90 b2npht_b.F90
sed -i -e 's/ISIZE1OFni/nCv/g' b2tfhi__b.F90 b2sikt_b.F90 b2npht_b.F90
sed -i -e 's/ISIZE1OFnn/nCv/g' b2npht_b.F90
sed -i -e 's/ISIZE1OFfchanml/nFc/g' b2tfhi__b.F90 
sed -i -e 's/ISIZE1OFfhe_exb/nFc/g' b2tfhi__b.F90 
sed -i -e 's/ISIZE2OFfhe_exb/0:1/g' b2tfhi__b.F90 
sed -i -e 's/ISIZE1OFdv%fna_52(:, :, isb)/nFc/g' b2tfnb_b.F90 
sed -i -e 's/ISIZE1OFcdna/nFc/g' b2tfnb_b.F90
sed -i -e 's/ISIZE1OFtemp/nCv/g' b2tfnb_b.F90 b2sikt_b.F90 b2tqna_b.F90 b2npmo_b.F90 b2trcl_b.F90 b2trzh_b.F90 b2npco_b.F90
sed -i -e 's/ISIZE1OFvadia/nFc/g' b2tfnb_b.F90
sed -i -e 's/ISIZE1OFpa/nCv/g' b2tfnb_b.F90
sed -i -e 's/ISIZE1OFvaecrb/nFc/g' b2tfrn_b.F90
sed -i -e 's/ISIZE1OFfchc/nFc/g' b2tinnt_b.F90
sed -i -e 's/DIMENSION(:) :: dabs/DIMENSION(nCv) :: dabs/g' b2tinnt_b.F90 b2tqna_b.F90 b2trcl_b.F90
sed -i -e 's/ISIZE1OFcvbzb/nCv/g' b2tral_b.F90
sed -i -e 's/ISIZE1OFco%cthi/nFc/g' b2tral_b.F90
sed -i -e 's/ISIZE2OFco%cthi/0:ns-1/g' b2tral_b.F90
sed -i -e 's/ISIZE1OFco%cthe/nFc/g' b2tral_b.F90
sed -i -e 's/ISIZE2OFco%cthe/0:ns-1/g' b2tral_b.F90
sed -i -e 's/\&              chve0, chci0, chvi0, csig0, calf0, co%csigin, co%vsaf_cl\&/\&              chve0, chci0, chvi0, csig0, calf0, co%csigin, co%cthe, co\&/g' b2tral_b.F90
sed -i -e 's/\&              , co%cvsa_cl, co%cvsahz_cl, co%fllimvisc, co%csig_cl, co%\&/\&              %cthi, co%vsaf_cl, co%cvsa_cl, co%cvsahz_cl, co%fllimvisc, co%csig_cl, co%\&/g' b2tral_b.F90
sed -i -e 's/ISIZE1OFcvbb/nCv/g' b2trno_b.F90 b2tqna_b.F90 b2trcl_b.F90 b2sikt_b.F90 b2tinnt_b.F90
sed -i -e 's/ISIZE1OFco%fllim0fhi/nfc/g' b2trno_b.F90
sed -i -e 's/ISIZE3OFco%fllim0fhi/0:ns-1/g' b2trno_b.F90
sed -i -e 's/\&              pl%tn, chcib, co%chcb)/\&              pl%tn, chcib, co%chcb, co%fllim0fhi)/g' b2trno_b.F90
sed -i -e 's/DIMENSION(SIZE(nal, 1))/DIMENSION(nCv)/g' b2tvspa_b.F90 b2tvsq_b.F90
sed -i -e 's/CHARACTER(len=\*) :: arg1/CHARACTER(len=20) :: arg1/g' b2usco_b.F90 b2usmo_b.F90
sed -i '/PUSHCHARACTERARRAY(name/d' b2usco_b.F90 
sed -i '/POPCHARACTERARRAY(name/d' b2usco_b.F90 
sed -i -e 's/ISIZE1OFmaskINb2usco/mpg%mxStencil/g' b2usco_b.F90
sed -i -e 's/ISIZE1OFmaskINb2usht/mpg%mxStencil/g' b2usht_b.F90
sed -i -e 's/ISIZE1OFmaskINb2usmo/mpg%mxStencil/g' b2usmo_b.F90
sed -i -e 's/ISIZE1OFmaskINb2uspo/mpg%mxStencil/g' b2uspo_b.F90
sed -i '/REAL(kind=r8) :: const_h/i\# ifndef CONSTANTS_PROVIDED' heatdiff1D_b.F90 ratstr_b.F90
sed -i '/PARAMETER (const_h/a\# endif' heatdiff1D_b.F90 ratstr_b.F90
sed -i -e 's/mb%cfoncv = 0.D0/mb%cfoncv = .true./g' b2us_map_diff.F90
sed -i -e 's/mb%cvonclosedsurface = 0.D0/mb%cvonclosedsurface = .true./g' b2us_map_diff.F90
sed -i -e 's/state_extb%is_neutral = 0.D0/state_extb%is_neutral = .true./g' b2us_plasma_diff.F90
sed -i '/INTRINSIC HUGE/d' b2mod_neutrals_namelist_diff.F90 b2mod_boundary_namelist_diff.F90
sed -i -e 's/REAL8ARRAY(small_r4_constant, r4\/8)/REAL4(small_r4_constant, r4\/8)/g' *.F90
sed -i -e 's/CALL POPREAL8ARRAY(switch/CALL POPREAL8(switch/g' *.F90
sed -i -e 's/REAL8ARRAY\(.*, r8\/8\)/REAL8\1/g' *.F90 ## match any [PUSH/POP]REAL8ARRAY, and substitute with REAL8, only when this addresses a scalar, for which only ", r8/8" is present
sed -i '/INTRINSIC MAX/d' b2stbc_phys_b.F90 b2usr_cost_function_b.F90 fix_user_b.F90 b2news__b.F90 b2news_m_b.F90 b2stel_b.F90 b2tqna_b.F90 b2mod_recycle_diff.F90
# WARNING! the following three may be dangerous in future!!
sed -i '/CALL INTCELL_FWD/i\  gfunrf = 1.0_R8 \!csc added this here for safety in gfortran' gradc_r_b.F90
sed -i '/CALL INTFACE_FWD/i\        wrk = 1.0_R8 \!csc added this here for safety in gfortran' b2tiner_b.F90
sed -i '/CALL INTCELL_FWD/i\    wrkf = 1.0_R8 \!csc added this here for safety in gfortran' b2sian_b.F90

# some incorrect tapenade arrays
sed -i -e "s/REAL8(potpar(0:0), r8\/8)/REAL8ARRAY(potpar, r8*nbcd*2\/8)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2sral_b.F90 b2stbc_b.F90
sed -i -e "s/REAL8(enepar(0:0), r8\/8)/REAL8ARRAY(enepar, r8*nbcd*2\/8)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2sral_b.F90 b2stbc_b.F90
sed -i -e "s/REAL8(enipar(0:0), r8\/8)/REAL8ARRAY(enipar, r8*nbcd*2\/8)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2sral_b.F90 b2stbc_b.F90
sed -i -e "s/REAL8(cfhci, r8\/8)/REAL8ARRAY(cfhci, r8*nsdecl*8\/8)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2tral_b.F90 b2trno_b.F90
sed -i -e "s/REAL8(cfvsa, r8\/8)/REAL8ARRAY(cfvsa, r8*nsdecl*8\/8)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2tral_b.F90 b2trno_b.F90
sed -i -e "s/REAL8(cfvla, r8\/8)/REAL8ARRAY(cfvla, r8*nsdecl*8\/8)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2tral_b.F90 b2trno_b.F90
sed -i -e "s/REAL8(cfdpa, r8\/8)/REAL8ARRAY(cfdpa, r8*nsdecl*8\/8)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2tral_b.F90 b2trno_b.F90
sed -i -e "s/REAL8(cfdna, r8\/8)/REAL8ARRAY(cfdna, r8*nsdecl*8\/8)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2tral_b.F90 b2trno_b.F90
sed -i -e "s/REAL8ARRAY(cfhci(0, is), r8)/REAL8(cfhci(0, is), r8)/g" b2tqna_b.F90
sed -i -e "s/REAL8ARRAY(cfvsa(0, is), r8)/REAL8(cfvsa(0, is), r8)/g" b2tqna_b.F90
sed -i -e "s/REAL8ARRAY(cfvla(0, is), r8)/REAL8(cfvla(0, is), r8)/g" b2tqna_b.F90
sed -i -e "s/REAL8ARRAY(cfdpa(0, is), r8)/REAL8(cfdpa(0, is), r8)/g" b2tqna_b.F90
sed -i -e "s/REAL8ARRAY(cfdna(0, is), r8)/REAL8(cfdna(0, is), r8)/g" b2tqna_b.F90
sed -i -e "s/REAL8(dabs1)/REAL8(dabs1, r8\/8)/g" b2tqna_b.F90
sed -i -e "s/REAL8ARRAY(cfhce, r8)/REAL8ARRAY(cfhce, r8*8\/8)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2tral_b.F90 b2trno_b.F90 b2tqna_b.F90
sed -i -e "s/REAL8ARRAY(cflim, r8)/REAL8ARRAY(cflim, r8*8\/8)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2tral_b.F90 b2trno_b.F90 b2tqna_b.F90
sed -i -e "s/REAL8ARRAY(cfalf, r8)/REAL8ARRAY(cfalf, r8*8\/8)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2tral_b.F90 b2trno_b.F90 b2tqna_b.F90
sed -i -e "s/REAL8ARRAY(cfsig, r8)/REAL8ARRAY(cfsig, r8*8\/8)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2tral_b.F90 b2trno_b.F90 b2tqna_b.F90
sed -i -e "s/ARRAY(omp(0:1), 2)/ARRAY(omp, nromp)/g" b2mod_driver_diff.F90 b2mndt_b.F90
sed -i -e "s/ARRAY(imp(0:1), 2)/ARRAY(imp, nromp)/g" b2mod_driver_diff.F90 b2mndt_b.F90
sed -i -e "s/ARRAY(msns(0:1), 2)/ARRAY(msns, 2*nstraid)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2sral_b.F90
sed -i -e "s/ARRAY(lsns(0:1), 2)/ARRAY(lsns, nstraid*def_nsrfs)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2sral_b.F90
sed -i -e "s/ARRAY(maxw_eff(0:1), 2)/ARRAY(maxw_eff, nstraid)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2sral_b.F90
sed -i -e "s/ARRAY(b2species_end(0:1), 2)/ARRAY(b2species_end, nstraid)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2sral_b.F90
sed -i -e "s/ARRAY(b2species_start(0:1), 2)/ARRAY(b2species_start, nstraid)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2sral_b.F90
sed -i -e "s/REAL8(userfluxparm(0:0), r8\/8)/REAL8ARRAY(userfluxparm, r8*nstraid*2\/8)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2sral_b.F90 b2stbc_b.F90
sed -i -e "s/ARRAY(targsp(0:1), 2)/ARRAY(targsp, nstraid*ntrack)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2sral_b.F90
sed -i -e "s/ARRAY(arcend(0:1), 2)/ARRAY(arcend, nstraid)/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2sral_b.F90
sed -i -e "s/ARRAY(ompind(0:1), 2)/ARRAY(ompind, nncf*2)/g" b2mod_driver_diff.F90
sed -i -e "s/REAL8(cfdata(0:0), r8\/8)/REAL8ARRAY(cfdata, r8*nncf*4*DEF_NLIM\/8)/g" b2mod_driver_diff.F90
sed -i -e "s/corr_lengthb(0:0)/corr_lengthb/g" b2usr_cost_function_b.F90 calc_log_prior_b.F90
sed -i -e "s/cfnormb(0:0)/cfnormb/g" b2usr_cost_function_b.F90
sed -i -e "s/voldb(0:0)/voldb/g" b2usr_cost_function_b.F90
sed -i -e "s/userfluxparmb(0:0)/userfluxparmb/g" b2mod_driver_diff.F90
sed -i -e "s/eneparb(0:0)/eneparb/g" b2mod_driver_diff.F90
sed -i -e "s/eniparb(0:0)/eniparb/g" b2mod_driver_diff.F90
sed -i -e "s/potparb(0:0)/potparb/g" b2mod_driver_diff.F90
sed -i -e "s/enkparb(0:0)/enkparb/g" b2mod_driver_diff.F90
sed -i -e "s/rcstart(0:1)/rcstart/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2sral_b.F90
sed -i -e "s/rcend(0:1)/rcend/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2sral_b.F90
sed -i -e "s/bccon14_is(0:1)/bccon14_is/g" b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2sral_b.F90
sed -i -e "/tmp(1:ic2-ic1+1) = b2rr(icf, ic1-1:ic2-1)/d" b2usr_cost_function_b.F90
sed -i -e "s/b2rr(icf, 1:n1) = tmp(1:ic2-ic1+1)/b2rr(icf, 1:n1) = b2rr(icf, ic1-1:ic2-1)/g" b2usr_cost_function_b.F90
sed -i -e "/ISIZE1OFDrfb2rrINb2usr_cost_function/d" b2usr_cost_function_b.F90

sed -i '/PUBLIC :: alloc_switches_b/d' b2mod_switches_diff.F90
sed -i '/& check_values_switches_b/d' b2mod_switches_diff.F90
sed -i -e 's/dealloc_b2mod_wall, dealloc_b2mod_wall_b/dealloc_b2mod_wall/g' b2mod_driver_diff.F90
sed -i -e 's/alloc_b2mod_balance_b, dealloc_b2mod_balance, dealloc_b2mod_balance_b,/dealloc_b2mod_balance,/g' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_eirene_sources, dealloc_b2mod_eirene_sources_b,/dealloc_b2mod_eirene_sources,/g' b2mod_driver_diff.F90
sed -i -e 's/run_av_get_plasma, run_av_get_plasma_b, run_av_save, run_av_save_b/run_av_get_plasma, run_av_save/g' b2mod_driver_diff.F90
sed -i -e 's/batch_av_all_init_b, batch_av_all_save, batch_av_all_fin, &/batch_av_all_save, batch_av_all_fin/g' b2mod_driver_diff.F90
sed -i '/& batch_av_all_fin_b/d' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_ysmp_sdrv, &/dealloc_b2mod_ysmp_sdrv/g' b2mod_driver_diff.F90
sed -i '/& dealloc_b2mod_ysmp_sdrv_b/d' b2mod_driver_diff.F90
sed -i -e 's/\& write_b2us_feedback_b, init_feedback, init_feedback_b, \&/\& init_feedback, \&/g' b2mod_driver_diff.F90
sed -i -e 's/\& dealloc_feedback, dealloc_feedback_b/\& dealloc_feedback/g' b2mod_driver_diff.F90

sed -i -e 's/alloc_geometry_b, dealloc_geometry_b, read_geometry_b, &/alloc_geometry_b, dealloc_geometry_b, read_geometry_b/g' b2us_geo_diff.F90
sed -i '/& check_geometry_b/d' b2us_geo_diff.F90
sed -i -e 's/read_b2fgmtry_b, read_b2fstate_b, write_b2fstate_b, &/read_b2fgmtry_b, read_b2fstate_b/g' b2us_io_diff.F90
sed -i '/& write_b2fplasma_b/d' b2us_io_diff.F90
sed -i 's/read_b2mod_par_opt, read_b2mod_par_opt_b/read_b2mod_par_opt/g' b2mod_driver_diff.F90
sed -i -e 's/USE B2MOD_RESIDUALS_DIFF/USE B2MOD_RESIDUALS/g' b2mod_diag_diff.F90
sed -i -e 's/INTEGER, SAVE :: ank_tracing=0/INTEGER :: ank_tracing=0/g' b2mod_diag_diff.F90
sed -i '/EXTERNAL RESTART_MA28_FOR_US/d' b2news__b.F90 b2npmo_b.F90 b2usht_b.F90 b2news_m_b.F90
 
sed -i '/EXTERNAL SUBINI/d' *.F90
sed -i '/EXTERNAL SUBEND/d' *.F90
sed -i '/EXTERNAL ISGHOSTCELL/d' b2mod_geo_diff.F90 b2mod_indirect_diff.F90
sed -i '/LOGICAL :: ISGHOSTCELL/d' b2mod_geo_diff.F90 b2mod_indirect_diff.F90
sed -i '/EXTERNAL ISREALCELL/d' b2mod_geo_diff.F90 b2mod_indirect_diff.F90
sed -i '/LOGICAL :: ISREALCELL/d' b2mod_geo_diff.F90 b2mod_indirect_diff.F90
sed -i '/EXTERNAL ISUNUSEDCELL/d' b2mod_geo_diff.F90
sed -i '/LOGICAL :: ISUNUSEDCELL/d' b2mod_geo_diff.F90
sed -i '/EXTERNAL ISINDOMAIN/d' b2mod_geo_diff.F90 b2mod_indirect_diff.F90
sed -i '/LOGICAL :: ISINDOMAIN/d' b2mod_geo_diff.F90 b2mod_indirect_diff.F90
sed -i '/EXTERNAL ISCLASSICALGRID/d' b2mod_geo_diff.F90
sed -i '/LOGICAL :: ISCLASSICALGRID/d' b2mod_geo_diff.F90
sed -i '/EXTERNAL DEALLOCATEB2GRIDMAP/d' b2mod_geo_diff.F90
sed -i '/EXTERNAL DEALLOC_B2MOD_MA28_FOR_US/d' b2mod_driver_diff.F90
sed -i -e 's/MSTEP_NODIFF/MSTEP/g' heatdiff1D_b.F90
sed -i -e 's/LINES2C_NODIFF/LINES2C/g' heatdiff1D_b.F90
sed -i -e 's/GET_JSEP_NODIFF/GET_JSEP/g' ./*.F90
sed -i -e 's/CFWURE_NODIFF/CFWURE/g' ./*.F90
sed -i -e 's/CFWUIN_NODIFF/CFWUIN/g' ./*.F90
sed -i -e '/REAL(kind=r8) :: tempb3/a\  EXTERNAL DIM_FWD' b2usht_b.F90
sed -i -e '/EXTERNAL DIM_FWD/a\  real(kind=r8) :: dim_fwd' b2usht_b.F90 b2mod_math_diff.F90
sed -i -e '/EXTERNAL EXPU_FWD/a\  real(kind=r8) :: expu_fwd' b2sqcx_b.F90 b2sqel_b.F90 b2mod_recycle_diff.F90
sed -i -e '/EXTERNAL INTP_2DTABLE_B, INTP_2DTABLE0_B, EXPU_FWD/a\  real(kind=r8) :: expu_fwd' b2mod_recycle_diff.F90
sed -i -e 's/#DIM_FWD#/DIM_FWD/g' dim_b.F90
sed -i -e 's/#DIM_BWD#/DIM_BWD/g' dim_b.F90
sed -i -e 's/#DIM_B#/DIM_B/g' dim_b.F90
sed -i -e 's/REAL(kind=r8) FUNCTION DIM_FWD(x, y) RESULT (dim)/FUNCTION DIM_FWD(x, y) RESULT (dim)/g' dim_b.F90
sed -i -e 's/SIZE(sy, 1)+1/n/g' myblas_b.F90
sed -i -e 's/SIZE(sx, 1)+1/n/g' sfill_b.F90
sed -i -e 's/SFILL_FWD(n, sa, sab, sx, incx)/SFILL_FWD(n, sa, sx, incx)/g' sfill_b.F90
sed -i -e '0,/REAL(kind=r8) :: sab/{/REAL(kind=r8) :: sab/d}' sfill_b.F90
sed -i '/EXTERNAL MINVAL_B/d' *.F90
sed -i '/EXTERNAL MAXVAL_B/d' *.F90
sed -i -e 's/USE B2MOD_PLASMA_DIFF/USE B2MOD_PLASMA/g' heatdiff2D_b.F90 init_wall_b.F90

sed -i -e '/my_out_folder/a\#ifdef DBG\n  CHARACTER(len=16), SAVE :: my_out_sf(0:1)\n#endif' b2mod_ad_diff.F90

# initialization missing for adjoint part, leading to floating point error with gfortran
sed -i -e '/CALL B2SAXPY_FWD(arg1, 1.0_R8, shedu, 1, she0, she0b, 1)/i\  shedu = 0.0_R8' b2sihs__b.F90
sed -i -e '/CALL B2SAXPY_FWD(arg1, 1.0_R8, shedu, 1, she0, she0b, 1)/i\  shidu = 0.0_R8' b2sihs__b.F90
sed -i -e '/CALL B2SAXPY_FWD(arg1, 1.0_R8, shedu, 1, she0, she0b, 1)/i\  shidun = 0.0_R8' b2sihs__b.F90
sed -i -e '/CALL B2SAXPY_FWD(arg1, 1.0_R8, shedu, 1, she0, she0b, 1)/i\  shedd = 0.0_R8' b2sihs__b.F90
sed -i -e '/CALL B2SAXPY_FWD(arg1, 1.0_R8, shedu, 1, she0, she0b, 1)/i\  shidd = 0.0_R8' b2sihs__b.F90
sed -i -e '/CALL B2SAXPY_FWD(arg1, 1.0_R8, shedu, 1, she0, she0b, 1)/i\  shivc = 0.0_R8' b2sihs__b.F90
sed -i -e '/CALL B2SAXPY_FWD(arg1, 1.0_R8, shedu, 1, she0, she0b, 1)/i\  shiva = 0.0_R8' b2sihs__b.F90
sed -i -e '/CALL B2SAXPY_FWD(arg1, 1.0_R8, shedu, 1, she0, she0b, 1)/i\  shivcn = 0.0_R8' b2sihs__b.F90
sed -i -e '/CALL B2SAXPY_FWD(arg1, 1.0_R8, shedu, 1, she0, she0b, 1)/i\  shivan = 0.0_R8' b2sihs__b.F90
sed -i -e '/CALL B2SAXPY_FWD(arg1, 1.0_R8, shedu, 1, she0, she0b, 1)/i\  shefr = 0.0_R8' b2sihs__b.F90
sed -i -e '/CALL B2SAXPY_FWD(arg1, 1.0_R8, shedu, 1, she0, she0b, 1)/i\  shifr = 0.0_R8' b2sihs__b.F90
sed -i -e '0,/!   ..velocity-dependent heat flux in the cell center/s/!   ..velocity-dependent heat flux in the cell center/!   ..velocity-dependent heat flux in the cell center\n  cfloi_vh = 0.0_R8/g' b2tfvh_b.F90

sed -i '/EXTERNAL OUTPUT_DS/d' b2mod_input_profile_diff.F90
sed -i '/TRIM_B/d' b2mod_main_diff.F90
sed -i '/EXTERNAL IPSETC/d' b2mnds_b.F90 
sed -i '/EXTERNAL IPPRHP/d' b2mnds_b.F90
sed -i '/EXTERNAL ANINT/d' b2xvcp_b.F90 
sed -i '/REAL(kind=r8) :: ANINT/d' b2xvcp_b.F90
sed -i '/EXTERNAL XERSET/d' b2mod_main_diff.F90
sed -i '/EXTERNAL IPGETC/d' b2mod_driver_diff.F90 b2trzh_b.F90
sed -i '/EXTERNAL B2TRCS/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL B2TRCF/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL B2TRACE/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL B2MWTI/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL B2FILE./d' b2mndt_b.F90
sed -i '/EXTERNAL GEOMETRYID/d' b2sihs__b.F90 b2us_feedback_diff.F90
sed -i '/EXTERNAL REPEAT/d' b2trzh_b.F90 b2mod_geometry_diff.F90 b2mod_running_average_diff.F90
sed -i '/INTEGER :: GEOMETRYID/d' b2sihs__b.F90 b2us_feedback_diff.F90
sed -i '/INTEGER :: geometry_sn/d' b2sihs__b.F90
sed -i '/INTEGER :: geometry_linear/d' b2sihs__b.F90
sed -i '/INTEGER :: geometry_lfs_snowflake_minus/d' b2sihs__b.F90
sed -i '/INTEGER :: geometry_ddn_top/d' b2sihs__b.F90
sed -i '/INTEGER :: geometry_ddn_bottom/d' b2sihs__b.F90
sed -i '/INTEGER :: geometry_limiter/d' b2sihs__b.F90
sed -i '/INTEGER :: geometry_lfs_snowflake_plus/d' b2sihs__b.F90
sed -i '/INTEGER :: geometry_cdn/d' b2sihs__b.F90
sed -i 's/FIX_USER_NODIFF/FIX_USER/g' fix_user_b.F90
sed -i 's/b2usr_loads/b2usr_loads_nodiff/g' b2mod_usrtrc.F
sed -i 's/b2xppz/b2xppz_nodiff/g' b2mod_usrtrc.F
sed -i 's/gradc_r/gradc_r_nodiff/g' b2mod_usrtrc.F
sed -i 's/b2xzef/b2xzef_nodiff/g' b2mod_wrsep.F
sed -i 's/fill/fill_nodiff/g' prvrt*.F
sed -i -e 's/B2WUZD_NODIFF/B2WUZD/g' b2mod_driver_diff.F90 b2mnds_b.F90 b2mod_running_average_diff.F90 b2mod_batch_average_diff.F90 b2wucp_b.F90
sed -i -e 's/b2xppz/b2xppz_nodiff/g' b2mod_blnm.F b2mod_ppout.F
sed -i 's/B2XPNE_ST_NODIFF/B2XPNE_ST/g' b2mod_running_average_diff.F90
sed -i '/EXTERNAL ALLOC_B2MOD_B2_TO_ASTRA/d' b2mod_main_diff.F90
sed -i '/EXTERNAL DEALLOC_B2MOD_MWTI/d' b2mod_driver_diff.F90
sed -i 's/sfill/sfill_nodiff/g' b2xpne_st.F
sed -i 's/call intcell/call intcell_nodiff/g' b2mod_mwti.F90

sed -i -e 's/DAMAX_NODIFF/damax/g' b2mndt_b.F90 b2mxac_b.F90 b2stcx_b.F90 b2stel_b.F90
sed -i -e 's/SMIN_NODIFF/smin/g' ./*.F90
sed -i -e 's/SMAX_NODIFF/smax/g' ./*.F90
sed -i -e 's/calc_dist(/calc_dist_nodiff(/g' b2wdat.F
sed -i -e 's/calc_dist_f/calc_dist_f_nodiff/g' b2wdat.F
sed -i '/EXTERNAL OR/d' b2stbr_b.F90
sed -i '/INTEGER :: OR/d' b2stbr_b.F90

sed -i -e 's/USE B2MOD_NEUTR_SRC_SCALING_DIFF/USE B2MOD_NEUTR_SRC_SCALING/g' b2mod_diag_diff.F90 b2mod_driver_diff.F90 b2mod_main_diff.F90 b2stbr_b.F90
sed -i -e 's/USE B2MOD_SOURCES_DIFF/USE B2MOD_SOURCES/g' b2mod_batch_average_diff.F90
sed -i -e 's/USE B2MOD_ANOMALOUS_TRANSPORT_DIFF/USE B2MOD_ANOMALOUS_TRANSPORT/g' b2txvspr_b.F90

sed -i -e 's/MY_OUT_US_NODIFF/MY_OUT_US/g' ./*.F90
sed -i -e 's/sort_faces/sort_faces_nodiff/g' b2wdat.F b2pwlprp.F

sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_diff.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_diff.F90
sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_b.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_b.F90

sed -i -e 's/DOUBLE PRECISION, DIM/REAL(kind=r8), DIM/g' b2mod_driver_diff.F90 b2mod_feedback_diff.F90 b2siav_b.F90 b2sikt_b.F90 b2srdt_b.F90 b2srsm_b.F90 b2stcx_b.F90 b2tdia_b.F90 b2tinnt_b.F90 b2tqna_b.F90 b2trcl_b.F90 b2tvsq_b.F90 b2us_geo_diff.F90
sed -i -e 's/DOUBLE PRECISION :: res/REAL(kind=r8) :: res/g' b2mod_driver_diff.F90 b2mod_feedback_diff.F90 b2srdt_b.F90 b2srsm_b.F90 b2stcx_b.F90 b2tdia_b.F90 b2us_geo_diff.F90
sed -i -e 's/DOUBLE PRECISION :: dab/REAL(kind=r8) :: dab/g' b2sikt_b.F90 b2tqna_b.F90
sed -i -e 's/DOUBLE PRECISION :: tempb/REAL(kind=r8) :: tempb/g' b2tqna_b.F90
sed -i -e 's/INTRINSIC DABS/INTRINSIC ABS/g' ./*.F90
sed -i -e 's/REAL(kind=r8) :: result11/integer :: result11/g' b2us_geo_diff.F90
sed -i -e 's/REAL(kind=r8) :: result10/integer :: result10/g' b2srdt_b.F90 b2usco_b.F90
sed -i -e 's/REAL(kind=r8) :: result1/integer :: result1/g' b2us_map_diff.F90 b2usmo_b.F90 b2uspo_b.F90
sed -i -e 's/mb%cvalongboundary = 0.D0/mb%cvalongboundary = .false./g' b2us_map_diff.F90

sed -i '/INTRINSIC ABS/d' b2mod_feedback_diff.F90 b2srdt_b.F90

sed -i -e "s/(:)//g" b2mod_driver_diff.F90 #extend to all?

sed -i -e 's/=>/=/g' b2mod_driver_diff.F90
sed -i -e 's/NULL()/0.0_R8/g' b2mod_driver_diff.F90

sed -i -e "/CALL B2UXUS_B/i\  aab = 0.0_R8" b2usco_b.F90 b2usmo_b.F90 b2usht_b.F90 b2uspo_b.F90
sed -i -e 's/B2UXUS_NODIFF/B2UXUS/g' b2usco_b.F90 b2usmo_b.F90 b2usht_b.F90 b2uspo_b.F90

# missing argument lnlam in calls to b2siav_zh_nodiff in b2npmo
sed -i -e 's/\&                     rt%rz2, dv%lnlam, co%hci_a, co_ns%hci_al_ast, co%\&/\&                     dv%ne2, rt%rz2, dv%lnlam, co%hci_a, co_ns%hci_al_ast, co%\&/g' b2npmo_b.F90

# missing argument in calls to b2saxpy in b2stbc
sed -i -e "s/CALL B2SAXPY_FWD(ncv, switch%sna0ep, incx=1, sy=srw%sna0(1, 0, is)/CALL B2SAXPY_FWD(ncv, switch%sna0ep, geo%cvvol, 1, srw%sna0(1, 0, is)/g" b2stbc_b.F90
sed -i -e "s/\&              incy=1)/\&              1)/g" b2stbc_b.F90
sed -i -e "s/CALL B2SAXPY_FWD(ncv, switch%she0ep, incx=1, sy=srw%she0(1, 0), incy=1/CALL B2SAXPY_FWD(ncv, switch%she0ep, geo%cvvol, 1, srw%she0(1, 0), 1/g" b2stbc_b.F90
sed -i -e "s/CALL B2SAXPY_FWD(ncv, switch%shi0ep, incx=1, sy=srw%shi0(1, 0), incy=1/CALL B2SAXPY_FWD(ncv, switch%shi0ep, geo%cvvol, 1, srw%shi0(1, 0), 1/g" b2stbc_b.F90

# missing argument in calls to calcflow in b2tfnb
sed -i -e "s/\&             fna_32(:, :, isb))/\&             fna_32(:, :, isb), dv%fna_52(:, :, isb))/g" b2tfnb_b.F90
sed -i -e "s/\&              vsaf_cl, co%cvsa_cl, co%cvsahz_cl, co%fllimvisc, co%/\&              cthe, co%cthi, co%vsaf_cl, co%cvsa_cl, co%cvsahz_cl, co%/g" b2tral_b.F90
sed -i -e "s/\&              csig_cl, co%calf_cl)/\&              fllimvisc, co%csig_cl, co%calf_cl)/g" b2tral_b.F90

# removing non-existing call to READ_NEUTRALS_NAMELIST_US_DV0
sed -i -e 's/MODULE PROCEDURE READ_NEUTRALS_NAMELIST_US_B, \&/MODULE PROCEDURE READ_NEUTRALS_NAMELIST_US_B/g' b2mod_neutrals_namelist_diff.F90
sed -i -e '/\&     READ_NEUTRALS_NAMELIST_US_B0/d' b2mod_neutrals_namelist_diff.F90
l1=`grep -n READ_NEUTRALS_NAMELIST_US_B0 b2mod_neutrals_namelist_diff.F90 | head -n 1| awk -F ':' '/1/ {print $1}'`
l2=`grep -n READ_NEUTRALS_NAMELIST_US_B0 b2mod_neutrals_namelist_diff.F90 | tail -n 1| awk -F ':' '/1/ {print $1}'`
sed -i -e "$l1,$l2 d" b2mod_neutrals_namelist_diff.F90

# adjusting get_mult_dt
sed -i -e 's/LOG(10)/LOG(10.0)/g' get_mult_dt_b.F90
sed -i -e "/IF (style .NE. 0) THEN/a\    call xerrab('get_mult_dt_b to be checked and manually adjusted for adjoint AD!')" get_mult_dt_b.F90
sed -i -e 's/CALL MAXVAL_B/\!CALL MAXVAL_B/g' get_mult_dt_b.F90
sed -i -e 's/CALL MINVAL_B/\!CALL MINVAL_B/g' get_mult_dt_b.F90
sed -i -e 's/\&                 dt_var4_minb(icv))/\!\&                 dt_var4_minb(icv))/g' get_mult_dt_b.F90

sed -i -e "/TYPE(B2PLASMASNAPSHOT_DIFF) :: psnc/i\      TYPE(B2PLASMASNAPSHOT_DIFF) :: psnl" b2us_plasma_diff.F90
sed -i -e 's/CHARACTER(len=13), DIMENSION(:), DIMENSION(:), ALLOCATABLE :: text/CHARACTER(len=13), DIMENSION(:), ALLOCATABLE :: text(:)/g' b2us_plasma_diff.F90
sed -i -e 's/DO ii2=1,SIZE(state_extb%text(ii1), 1)/DO ii2=1,SIZE(state_extb%text)/g' b2us_plasma_diff.F90
sed -i -e 's/state_extb%text(ii1)(ii2) = ''/state_extb%text(ii1) = ''/g' b2us_plasma_diff.F90
sed -i -e 's/DO ii1=1,SIZE(dvb%resmo0, 2)/DO ii1=0,SIZE(dvb%resmo0, 2)-1/g' b2us_plasma_diff.F90
sed -i -e 's/DO ii1=1,SIZE(snapb%resmo0, 2)/DO ii1=0,SIZE(snapb%resmo0, 2)-1/g' b2us_plasma_diff.F90
sed -i -e 's/DO ii1=1,SIZE(dvb%resco0, 2)/DO ii1=0,SIZE(dvb%resmo0, 2)-1/g' b2us_plasma_diff.F90
sed -i -e 's/DO ii1=1,SIZE(snapb%resco0, 2)/DO ii1=0,SIZE(snapb%resmo0, 2)-1/g' b2us_plasma_diff.F90
sed -i -e 's/DO ii1=1,SIZE(dvb%kinrgy, 2)/DO ii1=0,SIZE(dvb%kinrgy, 2)-1/g' b2us_plasma_diff.F90
sed -i -e 's/DO ii1=1,SIZE(snapb%kinrgy, 2)/DO ii1=0,SIZE(snapb%kinrgy, 2)-1/g' b2us_plasma_diff.F90
sed -i -e 's/DO ii1=1,SIZE(plb%ua, 2)/DO ii1=0,SIZE(plb%ua, 2)-1/g' b2us_plasma_diff.F90
sed -i -e 's/DO ii1=1,SIZE(snapb%ua, 2)/DO ii1=0,SIZE(snapb%ua, 2)-1/g' b2us_plasma_diff.F90
sed -i -e 's/DO ii1=1,SIZE(plb%na, 2)/DO ii1=0,SIZE(plb%na, 2)-1/g' b2us_plasma_diff.F90
sed -i -e 's/DO ii1=1,SIZE(snapb%na, 2)/DO ii1=0,SIZE(snapb%na, 2)-1/g' b2us_plasma_diff.F90
sed -i -e 's/DO ii1=1,SIZE(dvb%ni, 2)/DO ii1=0,SIZE(dvb%ni, 2)-1/g' b2us_plasma_diff.F90
sed -i -e 's/DO ii1=1,SIZE(snapb%ni, 2)/DO ii1=0,SIZE(snapb%ni, 2)-1/g' b2us_plasma_diff.F90

sed -i -e 's/DO ii1=1,SIZE(dvb%dmodt, 2)/DO ii1=0,SIZE(dvb%dmodt, 2)-1/g' b2us_plasma_diff.F90
sed -i -e 's/DO ii1=1,SIZE(snapb%dmodt, 2)/DO ii1=0,SIZE(snapb%dmodt, 2)-1/g' b2us_plasma_diff.F90
sed -i -e 's/DO ii1=1,SIZE(dvb%dnadt, 2)/DO ii1=0,SIZE(dvb%dnadt, 2)-1/g' b2us_plasma_diff.F90
sed -i -e 's/DO ii1=1,SIZE(snapb%dnadt, 2)/DO ii1=0,SIZE(snapb%dnadt, 2)-1/g' b2us_plasma_diff.F90

sed -i -e 's/ii1=0,8/ii1=1,nstraid/g' b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2stbr_b.F90
sed -i -e 's/ii1=8,0,-1/ii1=nstraid,1,-1/g' b2mod_driver_diff.F90 b2mndt_b.F90 b2news__b.F90 b2news_m_b.F90 b2stbr_b.F90
sed -i -e 's/ii0=0,8/ii0=1,nstraid/g' b2sral_b.F90
sed -i -e 's/ii0=8,0,-1/ii0=nstraid,1,-1/g' b2sral_b.F90

sed -i -e "s/REAL(kind=r4) :: cpustartb/REAL(kind=r4) :: cpustartb, cpustartb0/g" b2mod_driver_diff.F90
sed -i -e "s/  REAL(kind=r8) :: res_quitb/  REAL(kind=r8) :: res_quitb, res_quitb0/g" b2mod_driver_diff.F90
sed -i -e "s/  REAL(kind=r8) :: na_minb, na_newb, dtimb/  REAL(kind=r8) :: na_minb, na_newb, dtimb, dtimb0/g" b2mod_driver_diff.F90
sed -i -e "s/dtcob(0:nsdmax-1, 0:cvregmax)/dtcob(0:nsdmax-1, 0:cvregmax),dtcob0(0:nsdmax-1, 0:cvregmax)/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/dtmob(0:nsdmax-1, 0:cvregmax)/dtmob(0:nsdmax-1, 0:cvregmax),dtmob0(0:nsdmax-1, 0:cvregmax)/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/dteeb(0:cvregmax)/dteeb(0:cvregmax),dteeb0(0:cvregmax)/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/dteib(0:cvregmax)/dteib(0:cvregmax),dteib0(0:cvregmax)/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/dtenb(0:cvregmax)/dtenb(0:cvregmax),dtenb0(0:cvregmax)/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/time_factor_requiredb/time_factor_requiredb,time_factor_requiredb0/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/core_dt_suppressionb/core_dt_suppressionb,core_dt_suppressionb0/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/core_dt_factorb/core_dt_factorb,core_dt_factorb0/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/numerics_time_modb/numerics_time_modb,numerics_time_modb0/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/numerics_time_switchb/numerics_time_switchb,numerics_time_switchb0/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/corr_core_dnb(0:nsdmax-1)/corr_core_dnb(0:nsdmax-1),corr_core_dnb0(0:nsdmax-1)/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/SAVE :: corr_core_dtb/SAVE :: corr_core_dtb, corr_core_dtb0/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/transport_time_modb/transport_time_modb,transport_time_modb0/g" b2mod_transport_namelist_diff.F90
sed -i -e "s/transport_time_switchb/transport_time_switchb,transport_time_switchb0/g" b2mod_transport_namelist_diff.F90
sed -i -e "s/transport_ip_time_modb/transport_ip_time_modb,transport_ip_time_modb0/g" b2mod_input_profile_diff.F90
sed -i -e "s/transport_ip_time_switchb/transport_ip_time_switchb,transport_ip_time_switchb0/g" b2mod_input_profile_diff.F90
sed -i -e "s/cfdf0b(0:7, 0:nsdecl-1)/cfdf0b(0:7, 0:nsdecl-1),cfdf0b0(0:7, 0:nsdecl-1)/g" b2mod_b2cmpt_diff.F90
sed -i -e "s/rcionb(0:nsdmax-1, nstraid)/rcionb(0:nsdmax-1, nstraid),rcionb0(0:nsdmax-1, nstraid)/g" b2mod_neutrals_namelist_diff.F90
sed -i -e "s/e_fcb/e_fcb,e_fcb0/g" b2mod_neutrals_namelist_diff.F90
sed -i -e "s/recycmb(0:nsdmax-1, nstraid)/recycmb(0:nsdmax-1, nstraid),recycmb0(0:nsdmax-1, nstraid)/g" b2mod_neutrals_namelist_diff.F90
sed -i -e "s/b2recycb(0:nsdmax-1, nstraid)/b2recycb(0:nsdmax-1, nstraid),b2recycb0(0:nsdmax-1, nstraid)/g" b2mod_neutrals_namelist_diff.F90
sed -i -e "s/mrecycb(0:nsdmax-1, nstraid)/mrecycb(0:nsdmax-1, nstraid),mrecycb0(0:nsdmax-1, nstraid)/g" b2mod_neutrals_namelist_diff.F90
sed -i -e "s/erecycb(0:nsdmax-1, nstraid)/erecycb(0:nsdmax-1, nstraid),erecycb0(0:nsdmax-1, nstraid)/g" b2mod_neutrals_namelist_diff.F90

sed -i -e "s/momparb(0:nsdmax-1, nbcd, 2)/momparb(0:nsdmax-1, nbcd, 2),momparb0(0:nsdmax-1, nbcd, 2)/g" b2mod_boundary_namelist_diff.F90
sed -i -e "s/gammaeb/gammaeb,gammaeb0/g" b2mod_boundary_namelist_diff.F90
sed -i -e "s/conparb(0:nsdmax-1, nbcd, 3)/conparb(0:nsdmax-1, nbcd, 3),conparb0(0:nsdmax-1, nbcd, 3)/g" b2mod_boundary_namelist_diff.F90
sed -i -e "s/eneparb(nbcd, 2)/eneparb(nbcd, 2),eneparb0(nbcd, 2)/g" b2mod_boundary_namelist_diff.F90
sed -i -e "s/eniparb(nbcd, 2)/eniparb(nbcd, 2),eniparb0(nbcd, 2)/g" b2mod_boundary_namelist_diff.F90
sed -i -e "s/potparb(nbcd, 2)/potparb(nbcd, 2),potparb0(nbcd, 2)/g" b2mod_boundary_namelist_diff.F90
sed -i -e "s/enkparb(nbcd, 2)/enkparb(nbcd, 2),enkparb0(nbcd, 2)/g" b2mod_boundary_namelist_diff.F90
sed -i -e "s/enzparb(nbcd, 2)/enzparb(nbcd, 2),enzparb0(nbcd, 2)/g" b2mod_boundary_namelist_diff.F90
sed -i -e "s/parm_hceb,/parm_hceb,parm_hceb0,/g" b2mod_transport_namelist_diff.F90
sed -i -e "s/parm_sigb,/parm_sigb,parm_sigb0,/g" b2mod_transport_namelist_diff.F90
sed -i -e "s/parm_alfb/parm_alfb,parm_alfb0/g" b2mod_transport_namelist_diff.F90
sed -i -e "s/parm_dnab(0:nsdmax-1)/parm_dnab(0:nsdmax-1),parm_dnab0(0:nsdmax-1)/g" b2mod_transport_namelist_diff.F90
sed -i -e "s/parm_hcib(0:nsdmax-1)/parm_hcib(0:nsdmax-1),parm_hcib0(0:nsdmax-1)/g" b2mod_transport_namelist_diff.F90
sed -i -e "s/parm_dpab(0:nsdmax-1)/parm_dpab(0:nsdmax-1),parm_dpab0(0:nsdmax-1)/g" b2mod_transport_namelist_diff.F90
sed -i -e "s/parm_vsab(0:nsdmax-1)/parm_vsab(0:nsdmax-1),parm_vsab0(0:nsdmax-1)/g" b2mod_transport_namelist_diff.F90
sed -i -e "s/parm_vlab(0:nsdmax-1)/parm_vlab(0:nsdmax-1),parm_vlab0(0:nsdmax-1)/g" b2mod_transport_namelist_diff.F90
sed -i -e "s/uoldb=0.D0/uoldb=0.D0,uoldb0=0.D0/g" b2mod_recycle_diff.F90
sed -i -e "s/toldb=0.D0/toldb=0.D0,toldb0=0.D0/g" b2mod_recycle_diff.F90
sed -i -e "s/moldb=0.D0/moldb=0.D0,moldb0=0.D0/g" b2mod_recycle_diff.F90
sed -i -e "s/b2news_cutlob=0.D0/b2news_cutlob=0.D0,b2news_cutlob0=0.D0/g" b2mod_ad_diff.F90
sed -i -e "s/b2tlh0_cutlob=0.D0/b2tlh0_cutlob=0.D0,b2tlh0_cutlob0=0.D0/g" b2mod_ad_diff.F90
sed -i -e "s/b2srst_kt_epsb=0.D0/b2srst_kt_epsb=0.D0,b2srst_kt_epsb0=0.D0/g" b2mod_ad_diff.F90
sed -i -e "s/b2trcl_cutlob=0.D0/b2trcl_cutlob=0.D0,b2trcl_cutlob0=0.D0/g" b2mod_ad_diff.F90
sed -i -e "s/b2tlc0_cutlob=0.D0/b2tlc0_cutlob=0.D0,b2tlc0_cutlob0=0.D0/g" b2mod_ad_diff.F90
sed -i -e "s/b2tlv0_cutlob=0.D0/b2tlv0_cutlob=0.D0,b2tlv0_cutlob0=0.D0/g" b2mod_ad_diff.F90
sed -i -e "s/b2sian_epsb=0.D0/b2sian_epsb=0.D0,b2sian_epsb0=0.D0,b2tqna_keps_epsb0=0.D0/g" b2mod_ad_diff.F90
sed -i -e "s/b2srst_zt_epsb=0.D0/b2srst_zt_epsb=0.D0,b2srst_zt_epsb0=0.D0/g" b2mod_ad_diff.F90
sed -i "/stateb2/d" b2mod_driver_diff.F90 ## CAREFUL! might be needed in future
sed -i "/stateb3/d" b2mod_driver_diff.F90 ## CAREFUL! might be needed in future
sed -i "/stateb4/d" b2mod_driver_diff.F90 ## CAREFUL! might be needed in future
sed -i "/stateb5/d" b2mod_driver_diff.F90 ## CAREFUL! might be needed in future

## some changes for modification to the fixed point loop
sed -i -e '/DO WHILE (ADFIXEDPOINT_TOOLARGE/a\      stateb1 = stateb' b2mod_driver_diff.F90
sed -i -e "s/DO WHILE (ADFIXEDPOINT_TOOLARGE(cumul, 1.0e-6))/DO WHILE ((cumul .GT. res_quit) .and. (ITERCOUNT.lt.ntim) .and. (.not.quit))/g" b2mod_driver_diff.F90
sed -i -e "/REAL(kind=r8) :: cumul/i\    INTEGER :: ITERCOUNT" b2mod_driver_diff.F90
sed -i -e 's/cumul = -1.0/cumul = 1.0/g' b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_STARTREPEAT/i\    ITERCOUNT = 0" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      call calc_res_fp_diff(nCv, ns, stateb, stateb1, cumul)" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      call cpu_time(cpuval)" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      elapsedval=epoch_seconds()" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      inquire(file='_quit',exist=quitexist_)" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      inquire(file='.quit',exist=quitexist)" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      quit = ((quitexist_ .OR. quitexist) .OR. (cpuval - cpuinit .GT. \&" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\\&       b2mndr_cpu .AND. b2mndr_cpu .GT. 0.0_R8)) .OR. (elapsedval - \&" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\\&       elapsedinit .GT. b2mndr_elapsed .AND. b2mndr_elapsed .GT. 0.0_R8)" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      ITERCOUNT = ITERCOUNT + 1" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      write(*,*) 'GRADIENT ITERATION ',ITERCOUNT" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      write(*,*) 'MAX ADJ RESIDUAL ',cumul" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      gradient_res = cumul" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      gradient_iterations = ITERCOUNT" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      if (b2mndr_cpu.gt.0.0_R8) then\n        write(\*,'(1x,3(a,es11.3))') 'adj-step-cpu =',cpuval-cpustart,' elapsed ',\&" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\\&       elapsedval-elapsedstart,' estimated remaining CPU time (s) =',\&\n\&       min((ntim-itim)\*real(cpuval-cpustart,R8),max(0.0_R8,b2mndr_cpu-\&" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\\&       real(cpuval-cpuinit,R8)))" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      else if (b2mndr_elapsed.gt.0.0_R8) then\n        write(\*,'(1x,3(a,es11.3))') 'adj-step-cpu =',cpuval-cpustart,' elapsed ',\&" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\\&       elapsedval-elapsedstart,' estimated remaining elapsed time (s) =',\&\n\&       min((ntim-itim)\*(elapsedval-elapsedstart),max(0.0_R8,b2mndr_elapsed-\&" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\\&       (elapsedval-elapsedinit)))\n      else" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\        write(\*,'(1x,3(a,es11.3))') 'adj-step-cpu =',cpuval-cpustart,' elapsed ',\&\n\&       elapsedval-elapsedstart,' estimated remaining elapsed time (s) =',\&" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\\&       (ntim-itim)\*(elapsedval-elapsedstart)\n      end if" b2mod_driver_diff.F90
sed -i -e '0,/elapsedinit = EPOCH_SECONDS()/s//elapsedinit = EPOCH_SECONDS()\n    call cpu_time(cpuinit)/'  b2mod_driver_diff.F90
sed -i -e "/diffparam_save = momparb/a\    b2recycb0 = b2recycb" b2mod_driver_diff.F90
sed -i -e "/momparb = diffparam_save/a\    b2recycb = b2recycb0" b2mod_driver_diff.F90
sed -i -e "s/diffparam_save12 = rtlcxb/rtlcxb0 = rtlcxb/g" b2mod_driver_diff.F90
sed -i -e "s/diffparam_save11 = rtlqab/rtlqab0 = rtlqab/g" b2mod_driver_diff.F90
sed -i -e "s/diffparam_save10 = rtlrab/rtlrab0 = rtlrab/g" b2mod_driver_diff.F90
sed -i -e "s/diffparam_save9 = rtlsab/rtlsab0 = rtlsab/g" b2mod_driver_diff.F90
sed -i -e "/      momparb = 0.D0/a\      b2recycb = 0.D0" b2mod_driver_diff.F90
sed -i -e "s/rtlcxb = diffparam_save12/rtlcxb = rtlcxb0/g" b2mod_driver_diff.F90
sed -i -e "s/rtlqab = diffparam_save11/rtlqab = rtlqab0/g" b2mod_driver_diff.F90
sed -i -e "s/rtlrab = diffparam_save10/rtlrab = rtlrab0/g" b2mod_driver_diff.F90
sed -i -e "s/rtlsab = diffparam_save9/rtlsab = rtlsab0/g" b2mod_driver_diff.F90
# attempt to automatically remove some parts in b2mod_driver
## CAREFUL! below might be needed in future
# define block 1
l1=`grep -n 'stateb0%pl%na = stateb%pl%na' b2mod_driver_diff.F90 | head -n 1 | awk -F ':' '{print $1}'`
l2=`grep -n 'diffparam_save13%b2npht_rxg = switchb%b2optim_reset_drift' b2mod_driver_diff.F90 | tail -n 1 | awk -F ':' '{print $1}'`
# define block 2
l3=`grep -n 'stateb1%pl%na = stateb%pl%na' b2mod_driver_diff.F90 | head -n 1 | awk -F ':' '{print $1}'`
l4=`grep -n 'stateb1%update%zt = stateb%update%zt' b2mod_driver_diff.F90 | tail -n 1 | awk -F ':' '{print $1}'`
# define block 3
l5=`grep -n 'cumul = cumul + (stateb%pl%na-stateb1%pl%na)\*\*2' b2mod_driver_diff.F90 | head -n 1 | awk -F ':' '{print $1}'`
l6=`grep -n 'cumul = cumul + (stateb%update%zt-stateb1%update%zt)\*\*2' b2mod_driver_diff.F90 | tail -n 1 | awk -F ':' '{print $1}'`
# define block 4
l7=`grep -n 'stateb%pl%na = diffparam_save15%ns' b2mod_driver_diff.F90 | head -n 1 | awk -F ':' '{print $1}'`
l8=`grep -n 'switchb%b2optim_reset_drift = diffparam_save13%b2npht_rxg' b2mod_driver_diff.F90 | tail -n 1 | awk -F ':' '{print $1}'`
if [ -z "$l1" ] || [ -z "$l2" ]; then
    echo "ERROR: could not find markers for block1 in b2mod_driver_diff, it needs to be manually modified"
fi
if [ -z "$l3" ] || [ -z "$l4" ]; then
    echo "ERROR: could not find markers for block2 in b2mod_driver_diff, it needs to be manually modified"
fi
if [ -z "$l5" ] || [ -z "$l6" ]; then
    echo "ERROR: could not find markers for block3 in b2mod_driver_diff, it needs to be manually modified"
fi
if [ -z "$l7" ] || [ -z "$l8" ]; then
    echo "ERROR: could not find markers for block4 in b2mod_driver_diff, it needs to be manually modified"

fi
sed -i -e "${l7},${l8} d" b2mod_driver_diff.F90
sed -i -e "${l5},${l6} d" b2mod_driver_diff.F90
sed -i -e "${l3},${l4} d" b2mod_driver_diff.F90
sed -i -e "${l1},${l2} d" b2mod_driver_diff.F90
sed -i -e '/diffparam_save9/d' b2mod_driver_diff.F90
sed -i -e '/diffparam_save10/d' b2mod_driver_diff.F90
sed -i -e '/diffparam_save11/d' b2mod_driver_diff.F90
sed -i -e '/diffparam_save12/d' b2mod_driver_diff.F90
sed -i -e '/diffparam_save13/d' b2mod_driver_diff.F90
sed -i -e '/diffparam_save14/d' b2mod_driver_diff.F90
sed -i -e '/diffparam_save15/d' b2mod_driver_diff.F90

## insert an extra call to b2usr_cost_function within the fixed point loop, only for output purposes.
## This could have been done using $AD DO-NOT-DIFF pragmas but they fail for adjoint AD
sed -i -e "0,/!    ..increment/s/!    ..increment/!    ..incre1ment/g" b2mod_driver_diff.F90
sed -i -e "0,/!    ..increment/s/!    ..increment/!    ..incre2ment/g" b2mod_driver_diff.F90
sed -i -e "0,/!    ..increment/s/!    ..increment/!    ..incre1ment/g" b2mod_driver_diff.F90
sed -i -e '/!    ..incre1ment/i\!     manually inserted call to cost function, for output purposes only' b2mod_driver_diff.F90
sed -i -e '/!    ..incre1ment/i\      call b2usr_cost_function_nodiff(ncv, nfc, nvx, ns, geo, mpg, state, &' b2mod_driver_diff.F90
sed -i -e '/!    ..incre1ment/i\&                             state_ext, j)' b2mod_driver_diff.F90
sed -i -e '/!    ..incre1ment/i\      do icf=1,ncf' b2mod_driver_diff.F90
sed -i -e "/!    ..incre1ment/i\        write(ss, '(I1)') icf" b2mod_driver_diff.F90
sed -i -e "/!    ..incre1ment/i\        if (icf.gt.9) write (ss,'(I2)') icf" b2mod_driver_diff.F90
sed -i -e "/!    ..incre1ment/i\        write(*, *) 'Cost function value '//ss//': ', j(icf)" b2mod_driver_diff.F90
sed -i -e '/!    ..incre1ment/i\      end do' b2mod_driver_diff.F90
sed -i -e 's/incre1ment/increment/g' b2mod_driver_diff.F90
sed -i -e 's/incre2ment/increment/g' b2mod_driver_diff.F90

sed -i -e "/primal_iterations = itim/i\      primal_res = res_max" b2mod_driver_diff.F90

sed -i -e "/INTEGER, ALLOCATABLE, SAVE :: rtyr(:)/i\  REAL(kind=r8), ALLOCATABLE, SAVE :: rtlrab0(:, :, :), rtlsab0(:, :, :),&" b2mod_b2cmrc_diff.F90
sed -i -e "/INTEGER, ALLOCATABLE, SAVE :: rtyr(:)/i\& rtlqab0(:, :, :), rtlcxb0(:, :, :)" b2mod_b2cmrc_diff.F90
sed -i -e "/rtlsab = 0.D0/a\    rtlsab0 = 0.D0" b2mod_b2cmrc_diff.F90
sed -i -e "/rtlsab = 0.D0/a\    ALLOCATE(rtlsab0(0:rtnt, 0:rtnn, 0:rtns-1))" b2mod_b2cmrc_diff.F90
sed -i -e "/rtlrab = 0.D0/a\    rtlrab0 = 0.D0" b2mod_b2cmrc_diff.F90
sed -i -e "/rtlrab = 0.D0/a\    ALLOCATE(rtlrab0(0:rtnt, 0:rtnn, 0:rtns-1))" b2mod_b2cmrc_diff.F90
sed -i -e "/rtlqab = 0.D0/a\    rtlqab0 = 0.D0" b2mod_b2cmrc_diff.F90
sed -i -e "/rtlqab = 0.D0/a\    ALLOCATE(rtlqab0(0:rtnt, 0:rtnn, 0:rtns-1))" b2mod_b2cmrc_diff.F90
sed -i -e "/rtlcxb = 0.D0/a\    rtlcxb0 = 0.D0" b2mod_b2cmrc_diff.F90
sed -i -e "/rtlcxb = 0.D0/a\    ALLOCATE(rtlcxb0(0:rtnt, 0:rtnn, 0:rtns-1))" b2mod_b2cmrc_diff.F90
sed -i -e "/DEALLOCATE(rtlsab)/a\      DEALLOCATE(rtlsab0)" b2mod_b2cmrc_diff.F90
sed -i -e "/DEALLOCATE(rtlrab)/a\      DEALLOCATE(rtlrab0)" b2mod_b2cmrc_diff.F90
sed -i -e "/DEALLOCATE(rtlqab)/a\      DEALLOCATE(rtlqab0)" b2mod_b2cmrc_diff.F90
sed -i -e "/DEALLOCATE(rtlcxb)/a\      DEALLOCATE(rtlcxb0)" b2mod_b2cmrc_diff.F90

# add calls to write out adjoint state
sed -i -e "0,/CALL CFOPEN(nout(5), 'b2ftrack', 'new', 'un\*formatted')/{s/CALL CFOPEN(nout(5), 'b2ftrack', 'new', 'un\*formatted')/CALL CFOPEN(nout(5), 'b2ftrack', 'new', 'un\*formatted')\n    call cfopen(nout(9), 'b2fdiffe', 'new', 'un\*formatted')/g}" b2mod_main_diff.F90
sed -i -e "0,/!   ..save final state/{s/!   ..save final state/!   ..save final state\n    CALL write_b2fstate_diff(nout(9), ncv, nfc, ns, stateb)/g}" b2mod_driver_diff.F90

sed -i "/POINTER8/d" b2mndt_b.F90 b2news__b.F90 b2sral_b.F90 b2news_m_b.F90 b2stbr_b.F90 b2mod_driver_diff.F90 b2npht_b.F90 ## CAREFUL! might be needed in future
sed -i -e '/stateb1 = state0b/d' b2mod_driver_diff.F90 
sed -i -e '/TYPE(MAPPING_DIFF) :: mpgb1/d' b2mod_driver_diff.F90
sed -i -e '/TYPE(MAPPING_DIFF) :: mpgb2/d' b2mod_driver_diff.F90
sed -i -e '/TYPE(MAPPING_DIFF) :: mpgb3/d' b2mod_driver_diff.F90

# adding restartma28 section in reverse sweeps (CAREFUL HERE TOO!)
# first b2npco_nodiff
sed -i -e '0,/    CALL B2NPCO_NODIFF/s//    new_matrix = .false.\n&/' b2news__b.F90
sed -i -e '0,/    CALL B2NPCO_NODIFF/s//    DO ireg=0,mpg%nnreg(0)\n&/' b2news__b.F90
sed -i -e '0,/    CALL B2NPCO_NODIFF/s//      new_matrix = (new_matrix .OR. solveco(is, ireg)) .NEQV. \&\n&/' b2news__b.F90
sed -i -e '0,/    CALL B2NPCO_NODIFF/s//\&       last_solve_9(ireg)\n&/' b2news__b.F90
sed -i -e '0,/    CALL B2NPCO_NODIFF/s//    END DO\n&/' b2news__b.F90
sed -i -e '0,/    CALL B2NPCO_NODIFF/s//    IF (new_matrix .OR. .true.) CALL RESTART_MA28_FOR_US()\n&/' b2news__b.F90
# b2nppo_nodiff
sed -i -e '0,/        CALL B2NPPO_NODIFF/s//        new_matrix = .false.\n&/' b2news__b.F90
sed -i -e '0,/        CALL B2NPPO_NODIFF/s//        DO ireg=0,mpg%nnreg(0)\n&/' b2news__b.F90
sed -i -e '0,/        CALL B2NPPO_NODIFF/s//          new_matrix = (new_matrix .OR. solvepo(ireg)) .NEQV. \&\n&/' b2news__b.F90
sed -i -e '0,/        CALL B2NPPO_NODIFF/s//\&           last_solve_9(ireg)\n&/' b2news__b.F90
sed -i -e '0,/        CALL B2NPPO_NODIFF/s//        END DO\n&/' b2news__b.F90
sed -i -e '0,/        CALL B2NPPO_NODIFF/s//        IF (new_matrix .OR. .true.) CALL RESTART_MA28_FOR_US()\n&/' b2news__b.F90
# second b2npco_nodiff
sed -i -e '0,/      CALL B2NPCO_NODIFF(ncv, nfc, nvx, mpg%nnreg(0), b2news_solving(2)\&/s//      new_matrix = .false.\n&/' b2news__b.F90
sed -i -e '0,/      CALL B2NPCO_NODIFF(ncv, nfc, nvx, mpg%nnreg(0), b2news_solving(2)\&/s//      DO ireg=0,mpg%nnreg(0)\n&/' b2news__b.F90
sed -i -e '0,/      CALL B2NPCO_NODIFF(ncv, nfc, nvx, mpg%nnreg(0), b2news_solving(2)\&/s//        new_matrix = (new_matrix .OR. solveco(is, ireg)) .NEQV. \&\n&/' b2news__b.F90
sed -i -e '0,/      CALL B2NPCO_NODIFF(ncv, nfc, nvx, mpg%nnreg(0), b2news_solving(2)\&/s//\&         last_solve_9(ireg)\n&/' b2news__b.F90
sed -i -e '0,/      CALL B2NPCO_NODIFF(ncv, nfc, nvx, mpg%nnreg(0), b2news_solving(2)\&/s//      END DO\n&/' b2news__b.F90
sed -i -e '0,/      CALL B2NPCO_NODIFF(ncv, nfc, nvx, mpg%nnreg(0), b2news_solving(2)\&/s//      IF (new_matrix) CALL RESTART_MA28_FOR_US()\n&/' b2news__b.F90
sed -i -e '0,/      CALL B2NPCO_NODIFF(ncv, nfc, nvx, mpg%nnreg(0), b2news_solving(2)\&/s//      last_solve_9(0:mpg%nnreg(0)) = solveco(is, 0:mpg%nnreg(0))\n&/' b2news__b.F90
# first b2npco_b(=second b2ncpo_nodiff (need to change on letter to lower case to not match second b2npco_b)
sed -i -e '0,/      CALL B2NPCO_B/s//      new_matrix = .false.\n&/' b2news__b.F90
sed -i -e '0,/      CALL B2NPCO_B/s//      DO ireg=0,mpg%nnreg(0)\n&/' b2news__b.F90
sed -i -e '0,/      CALL B2NPCO_B/s//        new_matrix = (new_matrix .OR. solveco(is, ireg)) .NEQV. \&\n&/' b2news__b.F90
sed -i -e '0,/      CALL B2NPCO_B/s//\&         last_solve_9(ireg)\n&/' b2news__b.F90
sed -i -e '0,/      CALL B2NPCO_B/s//      END DO\n&/' b2news__b.F90
sed -i -e '0,/      CALL B2NPCO_B/s//      IF (new_matrix) CALL RESTART_MA28_FOR_US()\n&/' b2news__b.F90
sed -i -e '0,/      CALL B2NPCO_B/s//      last_solve_9(0:mpg%nnreg(0)) = solveco(is, 0:mpg%nnreg(0))\n&/' b2news__b.F90
sed -i -e '0,/      CALL B2NPCO_B/s/      CALL B2NPCO_B/      CALL B2NPCO_b/' b2news__b.F90 #change first B2NPCO_B into smaller letter to avoid matching for the second one
# b2nppo_b(=b2nppo_nodiff
sed -i -e '0,/        CALL B2NPPO_B/s//        new_matrix = .false.\n&/' b2news__b.F90
sed -i -e '0,/        CALL B2NPPO_B/s//        DO ireg=0,mpg%nnreg(0)\n&/' b2news__b.F90
sed -i -e '0,/        CALL B2NPPO_B/s//          new_matrix = (new_matrix .OR. solvepo(ireg)) .NEQV. \&\n&/' b2news__b.F90
sed -i -e '0,/        CALL B2NPPO_B/s//\&           last_solve_9(ireg)\n&/' b2news__b.F90
sed -i -e '0,/        CALL B2NPPO_B/s//        END DO\n&/' b2news__b.F90
sed -i -e '0,/        CALL B2NPPO_B/s//        IF (new_matrix .OR. .true.) CALL RESTART_MA28_FOR_US()\n&/' b2news__b.F90
sed -i -e '0,/        CALL B2NPPO_B/s//        last_solve_9(0:mpg%nnreg(0)) = solvepo(0:mpg%nnreg(0))\n&/' b2news__b.F90
# second b2npco_b(=first b2ncpo_nodiff
sed -i -e '0,/    CALL B2NPCO_B/s//    new_matrix = .false.\n&/' b2news__b.F90
sed -i -e '0,/    CALL B2NPCO_B/s//    DO ireg=0,mpg%nnreg(0)\n&/' b2news__b.F90
sed -i -e '0,/    CALL B2NPCO_B/s//      new_matrix = (new_matrix .OR. solveco(is, ireg)) .NEQV. \&\n&/' b2news__b.F90
sed -i -e '0,/    CALL B2NPCO_B/s//\&       last_solve_9(ireg)\n&/' b2news__b.F90
sed -i -e '0,/    CALL B2NPCO_B/s//    END DO\n&/' b2news__b.F90
sed -i -e '0,/    CALL B2NPCO_B/s//    IF (new_matrix .OR. .true.) CALL RESTART_MA28_FOR_US()\n&/' b2news__b.F90
sed -i -e '0,/    CALL B2NPCO_B/s//    last_solve_9(0:mpg%nnreg(0)) = solveco(is, 0:mpg%nnreg(0))\n&/' b2news__b.F90
sed -i -e 's/B2NPCO_b/B2NPCO_B/g' b2news__b.F90 #revert B2NPCO_b into B2NPCO_B
# first b2usmo_nodiff
sed -i -e '0,/      CALL B2USMO_NODIFF/s//      new_matrix = .false.\n&/' b2npmo_b.F90
sed -i -e '0,/      CALL B2USMO_NODIFF/s//      DO ireg=0,mpg%nnreg(0)\n&/' b2npmo_b.F90
sed -i -e '0,/      CALL B2USMO_NODIFF/s//        new_matrix = (new_matrix .OR. solvemo(is, ireg)) .NEQV. \&\n&/' b2npmo_b.F90
sed -i -e '0,/      CALL B2USMO_NODIFF/s//\&         last_solve_9(ireg)\n&/' b2npmo_b.F90
sed -i -e '0,/      CALL B2USMO_NODIFF/s//      END DO\n&/' b2npmo_b.F90
sed -i -e '0,/      CALL B2USMO_NODIFF/s//      IF (new_matrix .OR. .true.) CALL RESTART_MA28_FOR_US()\n&/' b2npmo_b.F90
sed -i -e '0,/      CALL B2USMO_NODIFF/s//      last_solve_9(0:mpg%nnreg(0)) = solvemo(is, 0:mpg%nnreg(0))\n&/' b2npmo_b.F90
sed -i -e '0,/      CALL B2USMO_NODIFF/s/      CALL B2USMO_NODIFF/      CALL B2USMO_nodiff/' b2npmo_b.F90 #avoid matching for second b2usmo_nodiff
# second b2usmo_nodiff
sed -i -e '0,/    CALL B2USMO_NODIFF/s//    new_matrix = .false.\n&/' b2npmo_b.F90
sed -i -e '0,/    CALL B2USMO_NODIFF/s//    DO ireg=0,mpg%nnreg(0)\n&/' b2npmo_b.F90
sed -i -e '0,/    CALL B2USMO_NODIFF/s//      new_matrix = (new_matrix .OR. solvemt(ireg)) .NEQV. last_solve_9(\&\n&/' b2npmo_b.F90
sed -i -e '0,/    CALL B2USMO_NODIFF/s//\&       ireg)\n&/' b2npmo_b.F90
sed -i -e '0,/    CALL B2USMO_NODIFF/s//    END DO\n&/' b2npmo_b.F90
sed -i -e '0,/    CALL B2USMO_NODIFF/s//    last_solve_9(0:mpg%nnreg(0)) = solvemt(0:mpg%nnreg(0))\n&/' b2npmo_b.F90
sed -i -e 's/CALL B2USMO_nodiff/CALL B2USMO_NODIFF/g' b2npmo_b.F90
# first b2usmo_b
sed -i -e '0,/    CALL B2USMO_B/s//    new_matrix = .false.\n&/' b2npmo_b.F90
sed -i -e '0,/    CALL B2USMO_B/s//    DO ireg=0,mpg%nnreg(0)\n&/' b2npmo_b.F90
sed -i -e '0,/    CALL B2USMO_B/s//      new_matrix = (new_matrix .OR. solvemt(ireg)) .NEQV. last_solve_9(\&\n&/' b2npmo_b.F90
sed -i -e '0,/    CALL B2USMO_B/s//\&       ireg)\n&/' b2npmo_b.F90
sed -i -e '0,/    CALL B2USMO_B/s//    END DO\n&/' b2npmo_b.F90
sed -i -e '0,/    CALL B2USMO_B/s//    last_solve_9(0:mpg%nnreg(0)) = solvemt(0:mpg%nnreg(0))\n&/' b2npmo_b.F90
sed -i -e '0,/    CALL B2USMO_B/s/    CALL B2USMO_B/    CALL B2USMO_b/' b2npmo_b.F90
#second b2usmo_b
sed -i -e '0,/      CALL B2USMO_B/s//      new_matrix = .false.\n&/' b2npmo_b.F90
sed -i -e '0,/      CALL B2USMO_B/s//      DO ireg=0,mpg%nnreg(0)\n&/' b2npmo_b.F90
sed -i -e '0,/      CALL B2USMO_B/s//        new_matrix = (new_matrix .OR. solvemo(is, ireg)) .NEQV. \&\n&/' b2npmo_b.F90
sed -i -e '0,/      CALL B2USMO_B/s//\&         last_solve_9(ireg)\n&/' b2npmo_b.F90
sed -i -e '0,/      CALL B2USMO_B/s//      END DO\n&/' b2npmo_b.F90
sed -i -e '0,/      CALL B2USMO_B/s//      IF (new_matrix .OR. .true.) CALL RESTART_MA28_FOR_US()\n&/' b2npmo_b.F90
sed -i -e '0,/      CALL B2USMO_B/s//      last_solve_9(0:mpg%nnreg(0)) = solvemo(is, 0:mpg%nnreg(0))\n&/' b2npmo_b.F90
sed -i -e 's/CALL B2USMO_b/CALL B2USMO_B/g' b2npmo_b.F90
# total heat
sed -i -e '0,/! ..total heat correction equation/s/! ..total heat correction equation/99HERE99\n&/' b2usht_b.F90
sed -i -e '/99HERE99/i\    new_matrix = .false.' b2usht_b.F90
sed -i -e '/99HERE99/i\    DO ireg=0,mpg%nnreg(0)' b2usht_b.F90
sed -i -e '/99HERE99/i\      new_matrix = (new_matrix .OR. solveet(ireg)) .NEQV. last_solve_9(\&' b2usht_b.F90
sed -i -e '/99HERE99/i\\&       ireg)' b2usht_b.F90
sed -i -e '/99HERE99/i\    END DO' b2usht_b.F90
sed -i -e '/99HERE99/i\    IF (new_matrix .OR. .true.) CALL RESTART_MA28_FOR_US()' b2usht_b.F90
sed -i -e '/99HERE99/d' b2usht_b.F90
# electron heat
sed -i -e '0,/  IF (ANY(solveee(0:mpg%nnreg(0)))) THEN/s/  IF (ANY(solveee(0:mpg%nnreg(0)))) THEN/  IF (ANY(solveee(0:mpg%nnreg(0)))) THEN\n99HERE99/' b2usht_b.F90
sed -i -e '/99HERE99/i\    new_matrix = .false.' b2usht_b.F90
sed -i -e '/99HERE99/i\    DO ireg=0,mpg%nnreg(0)' b2usht_b.F90
sed -i -e '/99HERE99/i\      new_matrix = (new_matrix .OR. solveee(ireg)) .NEQV. solveet(ireg)' b2usht_b.F90
sed -i -e '/99HERE99/i\    END DO' b2usht_b.F90
sed -i -e '/99HERE99/i\    IF (new_matrix .OR. .true.) CALL RESTART_MA28_FOR_US()' b2usht_b.F90
sed -i -e '/99HERE99/d' b2usht_b.F90
# atom heat
sed -i -e '0,/  IF (ANY(solveei(0:mpg%nnreg(0)))) THEN/s/  IF (ANY(solveei(0:mpg%nnreg(0)))) THEN/  IF (ANY(solveei(0:mpg%nnreg(0)))) THEN\n99HERE99/' b2usht_b.F90
sed -i -e '/99HERE99/i\    new_matrix = .false.' b2usht_b.F90
sed -i -e '/99HERE99/i\    DO ireg=0,mpg%nnreg(0)' b2usht_b.F90
sed -i -e '/99HERE99/i\      new_matrix = (new_matrix .OR. solveei(ireg)) .NEQV. solveee(ireg)' b2usht_b.F90
sed -i -e '/99HERE99/i\    END DO' b2usht_b.F90
sed -i -e '/99HERE99/i\    IF (new_matrix .OR. .true.) CALL RESTART_MA28_FOR_US()' b2usht_b.F90
sed -i -e '/99HERE99/d' b2usht_b.F90
# neutral heat
sed -i -e '0,/  IF (ANY(solveen(0:mpg%nnreg(0)))) THEN/s/  IF (ANY(solveen(0:mpg%nnreg(0)))) THEN/  IF (ANY(solveen(0:mpg%nnreg(0)))) THEN\n99HERE99/' b2usht_b.F90
sed -i -e '/99HERE99/i\      new_matrix = .false.' b2usht_b.F90
sed -i -e '/99HERE99/i\      DO ireg=0,mpg%nnreg(0)' b2usht_b.F90
sed -i -e '/99HERE99/i\        new_matrix = (new_matrix .OR. solveen(ireg)) .NEQV. solveei(ireg\&' b2usht_b.F90
sed -i -e '/99HERE99/i\\&         )' b2usht_b.F90
sed -i -e '/99HERE99/i\      END DO' b2usht_b.F90
sed -i -e '/99HERE99/i\      IF (new_matrix .OR. .true.) CALL RESTART_MA28_FOR_US()' b2usht_b.F90
sed -i -e '/99HERE99/d' b2usht_b.F90
# k
sed -i -e '0,/  IF (switch%solve_keps .GT. 0 .AND. ANY(solvekt(0:mpg%nnreg(0)))) THEN/s/  IF (switch%solve_keps .GT. 0 .AND. ANY(solvekt(0:mpg%nnreg(0)))) THEN/  IF (switch%solve_keps .GT. 0 .AND. ANY(solvekt(0:mpg%nnreg(0)))) THEN\n    CALL RESTART_MA28_FOR_US()/' b2usht_b.F90
# enstrophy
sed -i -e '0,/  IF (switch%solve_keps .GT. 1 .AND. ANY(solvezt(0:mpg%nnreg(0)))) THEN/s/  IF (switch%solve_keps .GT. 1 .AND. ANY(solvezt(0:mpg%nnreg(0)))) THEN/  IF (switch%solve_keps .GT. 1 .AND. ANY(solvezt(0:mpg%nnreg(0)))) THEN\n    CALL RESTART_MA28_FOR_US()/' b2usht_b.F90


# add initialization of mask arrays in b2tqna which otherwise would cause bad derivatives precision when using keps_shear
sed -i -e "/CALL PUSHBOOLEANARRAY(mask, ncv)/i\        mask = .FALSE." b2tqna_b.F90
sed -i -e "/CALL PUSHBOOLEANARRAY(mask0, ncv)/i\        mask0 = .FALSE." b2tqna_b.F90
sed -i -e "/CALL PUSHBOOLEANARRAY(mask1, ncv)/i\        mask1 = .FALSE." b2tqna_b.F90
sed -i -e "/CALL PUSHBOOLEANARRAY(mask2, ncv)/i\        mask2 = .FALSE." b2tqna_b.F90

# add variables for output of 2D maps of transport coeff
sed -i -e "/REAL(r8), DIMENSION(:), ALLOCATABLE :: cssb/a\      REAL(r8), DIMENSION(:, :), ALLOCATABLE :: dna0save" b2us_plasma_diff.F90
sed -i -e "/REAL(r8), DIMENSION(:), ALLOCATABLE :: cssb/a\      REAL(r8), DIMENSION(:), ALLOCATABLE :: hci0save" b2us_plasma_diff.F90
sed -i -e "/REAL(r8), DIMENSION(:), ALLOCATABLE :: cssb/a\      REAL(r8), DIMENSION(:), ALLOCATABLE :: hce0save" b2us_plasma_diff.F90
sed -i -e "/REAL(r8), DIMENSION(:), ALLOCATABLE :: cssb/a\! the sensitivity of transport coefficients for each cell" b2us_plasma_diff.F90
sed -i -e "/REAL(r8), DIMENSION(:), ALLOCATABLE :: cssb/a\! csc the following three have been manually added to enable saving" b2us_plasma_diff.F90
sed -i -e "/coeffb%cssb = 0.D0/a\!" b2us_plasma_diff.F90
sed -i -e "/coeffb%cssb = 0.D0/a\      coeffb%dna0save = 0.D0" b2us_plasma_diff.F90
sed -i -e "/coeffb%cssb = 0.D0/a\      ALLOCATE(coeffb%dna0save(ncv, 0:ns-1), source=0._R8)" b2us_plasma_diff.F90
sed -i -e "/coeffb%cssb = 0.D0/a\      coeffb%hce0save = 0.D0" b2us_plasma_diff.F90
sed -i -e "/coeffb%cssb = 0.D0/a\      ALLOCATE(coeffb%hci0save(ncv), source=0._R8)" b2us_plasma_diff.F90
sed -i -e "/coeffb%cssb = 0.D0/a\      coeffb%hce0save = 0.D0" b2us_plasma_diff.F90
sed -i -e "/coeffb%cssb = 0.D0/a\      ALLOCATE(coeffb%hce0save(ncv), source=0._R8)" b2us_plasma_diff.F90
sed -i -e "/coeffb%cssb = 0.D0/a\! the sensitivity of transport coefficients for each cell" b2us_plasma_diff.F90
sed -i -e "/coeffb%cssb = 0.D0/a\! csc the following three have been manually added to enable saving" b2us_plasma_diff.F90
sed -i -e "/IF (ALLOCATED(coeffb%cssb)) THEN/i\! csc the following three have been manually added to enable saving" b2us_plasma_diff.F90
sed -i -e "/IF (ALLOCATED(coeffb%cssb)) THEN/i\! the sensitivity of transport coefficients for each cell" b2us_plasma_diff.F90
sed -i -e "/IF (ALLOCATED(coeffb%cssb)) THEN/i\    IF (ALLOCATED(coeffb%dna0save)) THEN" b2us_plasma_diff.F90
sed -i -e "/IF (ALLOCATED(coeffb%cssb)) THEN/i\      DEALLOCATE(coeffb%dna0save)" b2us_plasma_diff.F90
sed -i -e "/IF (ALLOCATED(coeffb%cssb)) THEN/i\    END IF" b2us_plasma_diff.F90
sed -i -e "/IF (ALLOCATED(coeffb%cssb)) THEN/i\    IF (ALLOCATED(coeffb%hce0save)) THEN" b2us_plasma_diff.F90
sed -i -e "/IF (ALLOCATED(coeffb%cssb)) THEN/i\      DEALLOCATE(coeffb%hce0save)" b2us_plasma_diff.F90
sed -i -e "/IF (ALLOCATED(coeffb%cssb)) THEN/i\    END IF" b2us_plasma_diff.F90
sed -i -e "/IF (ALLOCATED(coeffb%cssb)) THEN/i\    IF (ALLOCATED(coeffb%hci0save)) THEN" b2us_plasma_diff.F90
sed -i -e "/IF (ALLOCATED(coeffb%cssb)) THEN/i\      DEALLOCATE(coeffb%hci0save)" b2us_plasma_diff.F90
sed -i -e "/IF (ALLOCATED(coeffb%cssb)) THEN/i\    END IF" b2us_plasma_diff.F90
sed -i -e "s/dzt0b, dna_exb, dna_exbb, hce_exb, hce_exbb, hci_exb, hci_exbb)/dzt0b, dna_exb, dna_exbb, hce_exb, hce_exbb, hci_exb, hci_exbb, dna0bsave, hce0bsave, hci0bsave)/g" b2tqna_b.F90
sed -i -e '0,/USE B2MOD_AD_DIFF, ONLY : my_out_folder, ncall_transp_keps/{s/USE B2MOD_AD_DIFF, ONLY : my_out_folder, ncall_transp_keps/USE B2MOD_AD_DIFF, ONLY : my_out_folder, ncall_transp_keps, last_call_transp/}' b2tqna_b.F90
sed -i -e "/\& , hci_exbb(ncv)/a\  REAL(kind=r8) :: dna0bsave(ncv, 0:ns-1), hci0bsave(ncv), hce0bsave(ncv)" b2tqna_b.F90
sed -i -e "/\& , hci_exbb(ncv)/a\! the sensitivity of the transport coefficient for each cell" b2tqna_b.F90
sed -i -e "/\& , hci_exbb(ncv)/a\! csc these additional variables are added manually and are used to save" b2tqna_b.F90
sed -i -e '0,/\& ncall_transp_keps/{s/ / /}' b2tqna_b.F90
sed -i -e '/hcn0b = 0.D0/{p;s/.*/1/;H;g;/^\(\n1\)\{2\}$/s//    last_call_transp = .false./p;d}' b2tqna_b.F90 # might be risky to search for this key but worst case it won't spit out anything
sed -i -e '/hcn0b = 0.D0/{p;s/.*/1/;H;g;/^\(\n1\)\{2\}$/s//    hci0bsave = pl%na(:, 1)*(hcibb(:,1) + hci0b)/p;d}' b2tqna_b.F90
sed -i -e '/hcn0b = 0.D0/{p;s/.*/1/;H;g;/^\(\n1\)\{2\}$/s//    hce0bsave = dv%ne*hce0b/p;d}' b2tqna_b.F90
sed -i -e '/hcn0b = 0.D0/{p;s/.*/1/;H;g;/^\(\n1\)\{2\}$/s//    dna0bsave = dna0b/p;d}' b2tqna_b.F90
sed -i -e '/hcn0b = 0.D0/{p;s/.*/1/;H;g;/^\(\n1\)\{2\}$/s//  if (last_call_transp) then/p;d}' b2tqna_b.F90
sed -i -e '/hcn0b = 0.D0/{p;s/.*/1/;H;g;/^\(\n1\)\{2\}$/s//! for each point of the domain, before they are reset to zero/p;d}' b2tqna_b.F90
sed -i -e '/hcn0b = 0.D0/{p;s/.*/1/;H;g;/^\(\n1\)\{2\}$/s//! csc added manually to save sensitivities of transport coefficients/p;d}' b2tqna_b.F90
sed -i -e '/hcn0b = 0.D0/{p;s/.*/1/;H;g;/^\(\n1\)\{2\}$/s//  END IF/p;d}' b2tqna_b.F90
sed -i -e "/ CALL B2TQNA_B/i\! csc the last three arguments of the b2tqna_b call have been added " b2trno_b.F90
sed -i -e "/ CALL B2TQNA_B/i\! manually to save the sensitivity of transport coefficients in each" b2trno_b.F90
sed -i -e "/ CALL B2TQNA_B/i\! cell of the domain" b2trno_b.F90
sed -i -e 's/\&         %hci_exb)/\&         %hci_exb, cob%dna0save, cob%hce0save, cob%hci0save)/g' b2trno_b.F90

### modify all the switchbXX geobXX etc to just have one, TOO DIFFICULT TO IMPLEMENT, NEED BY HAND

sed -i -e "/TYPE(B2STATE_DIFF) :: state0b/d" b2mod_driver_diff.F90
sed -i -e "/cumul = 1.0/a\    stateb0 = stateb" b2mod_driver_diff.F90
sed -i -e "/cumul = 1.0/a\    switchb0 = switchb" b2mod_driver_diff.F90
sed -i -e "/REAL(kind=r8) :: cumul/a\    TYPE(SWITCHES) :: switchb0" b2mod_driver_diff.F90
sed -i -e "/REAL(kind=r8) :: cumul/a\    TYPE(B2STATE_DIFF) :: stateb0" b2mod_driver_diff.F90
sed -i -e "/REAL(kind=r8) :: cumul/a\    TYPE(B2STATE_DIFF) :: stateb1" b2mod_driver_diff.F90

sed -i -e "s/(:, :, :)//" b2mod_driver_diff.F90
sed -i -e "s/(ii3, ii2, ii1),//" b2mod_driver_diff.F90
sed -i -e "s/rtltb0(:)/rtltb0/" b2mod_driver_diff.F90
sed -i -e "s/rtlnb0(:)/rtlnb0/" b2mod_driver_diff.F90
sed -i -e "s/rtltb(:)/rtltb/" b2mod_driver_diff.F90
sed -i -e "s/rtlnb(:)/rtlnb/" b2mod_driver_diff.F90
sed -i -e "s/rtltb0(ii1), 1/rtltb0, 1/" b2mod_driver_diff.F90
sed -i -e "s/rtltb(ii1), 1/rtltb, 1/" b2mod_driver_diff.F90
sed -i -e "s/rtlnb0(ii1), 1/rtlnb0, 1/" b2mod_driver_diff.F90
sed -i -e "s/rtlnb(ii1), 1/rtlnb, 1/" b2mod_driver_diff.F90

sed -i -e "s/b2mn_init_diff/b2mn_init_b/g" b2optim_tao.F90
sed -i -e "s/b2mn_fin_diff/b2mn_fin_b/g" b2optim_tao.F90
sed -i -e "s/b2mn_step_diff/b2mn_step_b/g" b2optim_tao.F90
sed -i -e "s/geodiff/geob/g" b2optim_tao.F90
sed -i -e "s/mpgdiff/mpgb/g" b2optim_tao.F90
sed -i -e "s/statediff/stateb/g" b2optim_tao.F90
sed -i -e "s/state_extdiff/state_extb/g" b2optim_tao.F90
sed -i -e "s/state_avgdiff/state_avgb/g" b2optim_tao.F90
sed -i -e "s/switchdiff/switchb/g" b2optim_tao.F90
sed -i -e "s/par_opt_physdiff/par_opt_physb/g" b2optim_tao.F90
sed -i -e "s/stateb, state_ext, state_extb, j, jdiff)/stateb, state_ext, state_extb, j)/g" b2optim_tao.F90

cp $TAPENADEDIR/ADFirstAidKit/adStack.c .
cp $TAPENADEDIR/ADFirstAidKit/adStack.h .
cp $TAPENADEDIR/ADFirstAidKit/adComplex.h .
