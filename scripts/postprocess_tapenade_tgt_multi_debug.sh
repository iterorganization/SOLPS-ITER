#! /usr/bin/env tcsh
move_to_F90.sh
rm b2uxus_dv.F90 solve_covariance_dv.F90 calc_res_fp_dv.F90 eirflux_map_dv.F90 b2mod_astra_to_b2_dv.F90
collect_nodiff_d_multi.sh
rm damax_dv.F90 smin_dv.F90 smax_dv.F90 get_jsep_dv.F90 my_outi_us_dv.F90 b2wuzd_dv.F90 set_parameters.F
mv b2mn_dv.F90 b2mn_d.F90


sed -i "/INCLUDE 'DIFFSIZES.inc'/d" ./*.F90
sed -i "/USE DIFFSIZES/d" ./*.F90
sed -i -e "/IMPLICIT NONE/i\  USE B2MOD_DIFFSIZES" ./*.F90
sed -i -e 's/#NBDirsMax#/nbdirsmax/g' ./*.F90 #why?
sed -i -e 's/#DIM_DV#/DIM_DV/g' dim_dv.F90 #why?
sed -i -e 's/SMIN_NODIFF/smin/g' ./*.F90
sed -i -e 's/SMAX_NODIFF/smax/g' ./*.F90

sed -i '/EXTERNAL ALLOC_B2MOD_B2_TO_ASTRA/d' b2mod_driver_diffv.F90 b2mod_main_diffv.F90
sed -i '/EXTERNAL CDFMOVIE/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL DEALLOC_B2MOD_MWTI/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL TALLIES/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL REPEAT/d' b2mod_elements_diffv.F90
sed -i '/EXTERNAL SUBINI/d' *.F90
sed -i '/EXTERNAL SUBEND/d' *.F90
sed -i '/EXTERNAL RESTART_MA28_FOR_US/d' b2news__dv.F90 b2npmo_dv.F90 b2usht_dv.F90 b2news_m_dv.F90
sed -i '/EXTERNAL DEALLOC_B2MOD_MA28_FOR_US/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL ISGHOSTCELL/d' b2mod_geo_diffv.F90 b2mod_indirect_diffv.F90
sed -i '/LOGICAL :: ISGHOSTCELL/d' b2mod_geo_diffv.F90 b2mod_indirect_diffv.F90
sed -i '/EXTERNAL ISREALCELL/d' b2mod_geo_diffv.F90 b2mod_indirect_diffv.F90
sed -i '/LOGICAL :: ISREALCELL/d' b2mod_geo_diffv.F90 b2mod_indirect_diffv.F90
sed -i '/EXTERNAL ISINDOMAIN/d' b2mod_geo_diffv.F90 b2mod_indirect_diffv.F90
sed -i '/LOGICAL :: ISINDOMAIN/d' b2mod_geo_diffv.F90 b2mod_indirect_diffv.F90
sed -i '/EXTERNAL ISCLASSICALGRID/d' b2mod_geo_diffv.F90
sed -i '/LOGICAL :: ISCLASSICALGRID/d' b2mod_geo_diffv.F90
sed -i '/EXTERNAL ISUNUSEDCELL/d' b2mod_geo_diffv.F90
sed -i '/LOGICAL :: ISUNUSEDCELL/d' b2mod_geo_diffv.F90
sed -i '/EXTERNAL DEALLOCATEB2GRIDMAP/d' b2mod_geo_diffv.F90
sed -i -e 's/MSTEP_NODIFF/MSTEP/g' heatdiff1D_dv.F90
sed -i -e 's/LINES2C_NODIFF/LINES2C/g' heatdiff1D_dv.F90
sed -i '/EXTERNAL OR/d' b2stbr_dv.F90
sed -i '/INTEGER :: OR/d' b2stbr_dv.F90
sed -i -e 's/B2UXUS_NODIFF/B2UXUS/g' b2usco_dv.F90 b2usmo_dv.F90 b2usht_dv.F90 b2uspo_dv.F90
sed -i -e 's/GET_JSEP_NODIFF/GET_JSEP/g' ./*.F90
sed -i -e 's/CFWURE_NODIFF/CFWURE/g' ./*.F90
sed -i '/EXTERNAL IPSETC/d' b2mnds_dv.F90 
sed -i '/EXTERNAL IPPRHP/d' b2mnds_dv.F90 
sed -i '/EXTERNAL ANINT/d' b2xvcp_dv.F90 
sed -i '/REAL(kind=r8) :: ANINT/d' b2xvcp_dv.F90
sed -i '/EXTERNAL XERSET/d' b2mod_main_diffv.F90
sed -i '/EXTERNAL IPGETC/d' b2mod_driver_diffv.F90 b2trzh_dv.F90
sed -i '/EXTERNAL B2TRCS/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL B2TRCF/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL B2TRACE/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL B2TRCI/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL B2MWTI/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL OUTPUT_DS/d' b2mod_input_profile_diffv.F90
sed -i '/EXTERNAL B2FILE./d' b2mndt_dv.F90
sed -i '/TRIM_DV/d' b2mod_main_diffv.F90
sed -i 's/FIX_USER_NODIFF/FIX_USER/g' fix_user_dv.F90
sed -i 's/B2XPNE_ST_NODIFF/B2XPNE_ST/g' b2mod_running_average_diffv.F90 b2rups_dv.F90
sed -i 's/call species/call species_nodiff/g' tallies.F
sed -i 's/b2usr_loads/b2usr_loads_nodiff/g' b2mod_usrtrc.F
sed -i 's/b2xppz_st/b2xppz_st_nodiff/g' b2mod_usrtrc.F
sed -i 's/B2NEUT_IND_NODIFF/B2NEUT_IND/g' b2usr_loads_dv.F90
sed -i 's/b2xppz/b2xppz_nodiff/g' b2mod_blnm.F
sed -i 's/b2xzef/b2xzef_nodiff/g' b2mod_wrsep.F
sed -i 's/fill/fill_nodiff/g' prvrt*.F b2xpne_st.F
sed -i 's/B2XVFX_NODIFF/B2XVFX/g' b2xtvx_dv.F90
sed -i 's/B2XVFF_NODIFF/B2XVFF/g' b2npp7_dv.F90 b2tr21_dv.F90 b2usp7_dv.F90
sed -i '/PRGINI_DV/d' b2mod_main_diffv.F90
sed -i 's/b2xvfy/b2xvfy_nodiff/g' b2xvff.F
sed -i -e 's/B2WUZD_NODIFF/B2WUZD/g' b2mod_driver_diffv.F90 b2mnds_dv.F90 b2mod_running_average_diffv.F90 b2mod_batch_average_diffv.F90 b2wucp_dv.F90
sed -i 's/call intcell/call intcell_nodiff/g' b2mod_mwti.F90
sed -i 's/b2scopy/b2scopy_nodiff/g' b2mwmv.F
sed -i 's/b2saxpy/b2saxpy_nodiff/g' b2mwmv.F
sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_diffv.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_diffv.F90
sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_dv.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_dv.F90

sed -i '/MINVAL_DV/d' ./*.F90
sed -i '/MAXVAL_DV/d' ./*.F90
sed -i '/EXTERNAL XERRAB_DV/d' ./*.F90
sed -i '/ANY_DV/d' ./*.F90
sed -i '/COUNT_DV/d' ./*.F90
sed -i '/ALLOCATED_DV/d' ./*.F90
sed -i '/GET_B25_HASH_DV/d' b2mod_main_diffv.F90
sed -i '/MINLOC_DV/d' b2mod_neutrals_namelist_diffv.F90

sed -i '/PUBLIC :: alloc_switches_dv/d' b2mod_switches_diffv.F90
sed -i '/& check_values_switches_dv/d' b2mod_switches_diffv.F90
sed -i '/& read_first_switches_dv/d' b2mod_switches_diffv.F90

sed -i -e 's/alloc_geometry_dv, dealloc_geometry_dv, read_geometry_dv, &/alloc_geometry_dv, dealloc_geometry_dv, read_geometry_dv/g' b2us_geo_diffv.F90
sed -i '/& check_geometry_dv/d' b2us_geo_diffv.F90
sed -i -e 's/ISIZE1OFfceb/mpg%nFc/g' b2us_geo_diffv.F90
sed -i -e 's/ISIZE1OFfspsi/mpg%nFs/g' b2us_geo_diffv.F90
sed -i -e 's/INTEGER, DIMENSION(ISIZE1OFresult1) :: result1/INTEGER :: result1/g' b2us_geo_diffv.F90
sed -i -e 's/result1 = MAXVAL(arg1(:))/result1 = MAXVAL(gm%vxfpsi(verts(1:mpg%cvvxp(icv, 2))))/g' b2us_geo_diffv.F90
sed -i -e 's/result2 = MINVAL(arg2(:))/result2 = MINVAL(gm%vxfpsi(verts(1:mpg%cvvxp(icv, 2))))/g' b2us_geo_diffv.F90
sed -i -e '/REAL(kind=r8), DIMENSION(mpg%cvvxp(icv, 2)) :: arg/d' b2us_geo_diffv.F90
sed -i -e '/arg.(:) = gm%vxfpsi(verts(1:mpg%cvvxp(icv, 2)))/d' b2us_geo_diffv.F90
sed -i -e 's/cvfpsi(icv) = SUM(arg10)\/mpg%cvvxp(icv, 2)/cvfpsi(icv) = SUM(gm%vxfpsi(verts))\/mpg%cvvxp(icv, 2)/g' b2us_geo_diffv.F90
sed -i -e '/arg10 = gm%vxfpsi(verts)/d' b2us_geo_diffv.F90
sed -i -e 's/DIMENSION(:) :: dabs0/DIMENSION(mpg%nFs) :: dabs0/g' b2us_geo_diffv.F90
sed -i '/INTRINSIC DABS/d' b2us_geo_diffv.F90 b2trcl_dv.F90
sed -i -e 's/REAL(r8), DIMENSION(:, nfc, 0:1), ALLOCATABLE :: fne_he/REAL(r8), DIMENSION(:, :, :), ALLOCATABLE :: fne_he/g' b2us_plasma_diffv.F90

sed -i -e 's/ISIZE1OFtemp/nCv/g' b2news__dv.F90 b2tfcc_dv.F90 b2tfnb_dv.F90 b2tqna_dv.F90 b2xpic_dv.F90 b2us_feedback_diffv.F90 b2npmo_dv.F90 b2sikt_dv.F90 b2tral_dv.F90 b2trcl_dv.F90 b2mndt_dv.F90 b2news_m_dv.F90 b2trzh_dv.F90

sed -i -e 's/read_b2fgmtry_dv, read_b2fstate_dv, write_b2fstate_dv, &/read_b2fgmtry_dv, read_b2fstate_dv/g' b2us_io_diffv.F90
sed -i '/& write_b2fplasma_dv/d' b2us_io_diffv.F90

sed -i -e 's/alloc_b2mod_balance_dv, dealloc_b2mod_balance/dealloc_b2mod_balance/g' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_b2mod_balance_dv, dealloc_b2mod_eirene_sources/dealloc_b2mod_eirene_sources/g' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_b2mod_eirene_sources_dv, balance_average/balance_average/g' b2mod_driver_diffv.F90
sed -i -e 's/run_av_get_plasma, run_av_get_plasma_dv, run_av_save, run_av_save_dv/run_av_get_plasma, run_av_save/g' b2mod_driver_diffv.F90
sed -i -e 's/batch_av_all_init_dv, batch_av_all_save, batch_av_all_fin, &/batch_av_all_save, batch_av_all_fin/g' b2mod_driver_diffv.F90
sed -i '/& batch_av_all_fin_dv/d' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_b2mod_wall, dealloc_b2mod_wall_dv/dealloc_b2mod_wall/g' b2mod_driver_diffv.F90
sed -i -e 's/ONLY : dealloc_b2mod_ysmp_sdrv, &/ONLY : dealloc_b2mod_ysmp_sdrv/g' b2mod_driver_diffv.F90
sed -i '/& dealloc_b2mod_ysmp_sdrv_dv/d' b2mod_driver_diffv.F90
sed -i -e 's/\& write_b2us_feedback_dv, init_feedback, init_feedback_dv, \&/\& init_feedback, \&/g' b2mod_driver_diffv.F90
sed -i -e 's/\& dealloc_feedback, dealloc_feedback_dv/\& dealloc_feedback/g' b2mod_driver_diffv.F90
sed -i -e 's/\& read_b2mod_par_opt, read_b2mod_par_opt_dv, par_opt_phys, par_opt_physd/\& read_b2mod_par_opt, par_opt_phys, par_opt_physd, nsigma_opt/g' b2mod_driver_diffv.F90
sed -i '/& dealloc_b2mod_sputter_dv/d' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_sputter_data_dv, dealloc_b2mod_sputter, &/dealloc_b2mod_sputter/g' b2mod_driver_diffv.F90
sed -i '/& dealloc_b2mod_neoclassical_dv/d' b2mod_driver_diffv.F90
sed -i '/& dealloc_b2mod_transport_disruption_dv/d' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_b2mod_neoclassical, &/dealloc_b2mod_neoclassical/g' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_b2mod_transport_disruption, &/dealloc_b2mod_transport_disruption/g' b2mod_driver_diffv.F90
sed -i -e 's/\& alloc_b2mod_balance_dv, write_balance, write_balance_dv, \&/\& alloc_b2mod_balance_dv, write_balance, \&/g' b2mod_driver_diffv.F90
sed -i -e 's/\& dealloc_b2mod_eirene_sources, dealloc_b2mod_eirene_sources_dv, \&/\& dealloc_b2mod_eirene_sources, \&/g' b2mod_driver_diffv.F90
sed -i -e 's/\& balance_average, update_average_balance, update_average_balance_dv/\& balance_average, update_average_balance/g' b2mod_driver_diffv.F90
sed -i -e 's/\& alloc_b2mod_b2plot_dv, dealloc_b2mod_b2plot, dealloc_b2mod_b2plot_dv/\& dealloc_b2mod_b2plot/g' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_b2mod_facdrift_exb, \&/dealloc_b2mod_facdrift_exb/g' b2mod_driver_diffv.F90
sed -i -e '/\& dealloc_b2mod_facdrift_exb_dv/d' b2mod_driver_diffv.F90

sed -i -e 's/DIMENSION(:, :) :: dabs0/DIMENSION(SIZE(rza0, 1), SIZE(rza0, 2)) :: dabs0/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(:, :) :: dabs1/DIMENSION(SIZE(rz20, 1), SIZE(rz20, 2)) :: dabs1/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(:, :) :: dabs2/DIMENSION(SIZE(rpt0, 1), SIZE(rpt0, 2)) :: dabs2/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(:, :) :: dabs3/DIMENSION(SIZE(rpi0, 1), SIZE(rpi0, 2)) :: dabs3/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(:) :: dabs4/DIMENSION(mpg%nCv) :: dabs4/g' b2mod_driver_diffv.F90
sed -i -e 's/ISIZE1OFarg1/mpg%nCv/g' b2mod_driver_diffv.F90

sed -i -e "s/USE B2MOD_ASTRA_TO_B2_DIFFV/USE B2MOD_ASTRA_TO_B2/g" b2mod_main_diffv.F90 b2stbc_phys_dv.F90

sed -i -e 's/=> NULL()/= 0.0_R8/g' b2mndt_dv.F90 b2sral_dv.F90
sed -i -e "s/DIMENSION(:, ISIZE1OFgeo%cvvol)/DIMENSION(nbdirsmax, nCv)/g" b2mndt_dv.F90 b2news__dv.F90 b2news_m_dv.F90
sed -i -e "s/REAL(r8), DIMENSION(:,/REAL(r8), DIMENSION(nbdirsmax,/g" b2news__dv.F90 b2news_m_dv.F90 b2sral_dv.F90

sed -i -e "s/REAL(kind=r8), DIMENSION(:,/REAL(kind=r8), DIMENSION(nbdirsmax,/g" b2news_m_dv.F90



sed -i -e 's/ISIZE1OFarg1/nCv/g' b2npmo_dv.F90 b2stbr_phys_dv.F90 b2tqna_dv.F90 eirene_f30f31_dv.F90 b2mod_recycle_diffv.F90 b2sikt_dv.F90 b2trcl_dv.F90 b2tfhe__dv.F90 b2trzh_dv.F90

sed -i -e 's/ISIZE1OFlnlam/nCv/g' b2npmo_dv.F90 b2trcl_dv.F90 b2trzh_dv.F90
sed -i -e 's/ISIZE1OFcvsa/nFc/g' b2npmo_dv.F90
sed -i -e 's/ISIZE1OFresult1/nCv/g' b2npmo_dv.F90 b2tqna_dv.F90 b2sikt_dv.F90 b2trcl_dv.F90 b2trzh_dv.F90
sed -i -e 's/ISIZE1OFcvhz/nCv/g' b2nxfv_dv.F90 b2npmo_dv.F90

sed -i -e 's/ISIZE1OFfcqalf/nFc/g' b2sian_dv.F90 b2stbc_dv.F90 b2stbc_phys_dv.F90 b2tfhe__dv.F90 b2tfhi__dv.F90 b2trno_dv.F90 b2tfch__dv.F90 b2tfnb_dv.F90 b2tinnt_dv.F90 b2tvskt_dv.F90 b2tfrn_dv.F90

sed -i -e 's/ISIZE1OFfcbb/nFc/g' b2siav_dv.F90 b2tvskt_dv.F90 b2tvspa_dv.F90 b2tvsq_dv.F90  b2siav_zh_dv.F90
sed -i -e 's/ISIZE1OFvxbb/nVx/g' b2siav_dv.F90 b2siav_zh_dv.F90
sed -i -e 's/ISIZE1OFcvbb/nCv/g' b2siav_dv.F90 b2siav_zh_dv.F90 b2sikt_dv.F90 b2tqna_dv.F90 b2tvspa_dv.F90 b2tvsq_dv.F90
sed -i -e 's/ISIZE1OFcvvol/nCv/g' b2sikt_dv.F90

sed -i -e 's/ISIZE1OFgeo%cvvol/nCv/g' b2stbc_dv.F90 b2news_m_dv.F90

sed -i -e "s/REAL(kind=r8), DIMENSION(:,/REAL(kind=r8), DIMENSION(nbdirsmax,/g" b2stbc_dv.F90

sed -i -e 's/TYPE(B2PLASMA_DIFFV), INTENT(IN) :: pld/TYPE(B2PLASMA_DIFFV), INTENT(INout) :: pld/g' b2stbc_phys_dv.F90 b2stel_dv.F90
sed -i -e 's/TYPE(B2RATES_DIFFV), INTENT(IN) :: rtd/TYPE(B2RATES_DIFFV), INTENT(INout) :: rtd/g' b2stbc_phys_dv.F90 b2stel_dv.F90
sed -i -e 's/TYPE(B2RATESWORK_DIFFV), INTENT(IN) :: rtwd/TYPE(B2RATESWORK_DIFFV), INTENT(INout) :: rtwd/g' b2stel_dv.F90
sed -i -e 's/TYPE(GEOMETRY_DIFFV), INTENT(IN) :: geod/TYPE(GEOMETRY_DIFFV), INTENT(INout) :: geod/g' b2mod_recycle_diffv.F90 b2mndt_dv.F90 b2news__dv.F90 b2news_m_dv.F90 b2npht_dv.F90 b2npmo_dv.F90 b2siav_dv.F90  b2siav_zh_dv.F90 b2sral_dv.F90 b2stbc_dv.F90 b2stbc_phys_dv.F90 b2stbr_dv.F90 b2stel_dv.F90 b2tfch__dv.F90 b2tinnt_dv.F90 b2tlhe_dv.F90 b2tlhi_dv.F90 b2tqca_dv.F90  b2tqce_dv.F90 b2tqin_dv.F90 b2tral_dv.F90 b2trno_dv.F90 b2trql_dv.F90 b2tvspa_dv.F90 b2tvsq_dv.F90

sed -i -e 's/TYPE(SWITCHES_DIFFV), INTENT(IN) :: switchd/TYPE(SWITCHES_DIFFV), INTENT(INout) :: switchd/g' b2npco_dv.F90 b2npht_dv.F90 b2npmo_dv.F90 b2sifr__dv.F90 b2sihs__dv.F90 b2sqel_dv.F90 b2stbc_dv.F90 b2stbc_phys_dv.F90 b2stbr_phys_dv.F90 b2stcx_dv.F90 b2tcpa_dv.F90 b2tfch__dv.F90 b2tfhe__dv.F90  b2tfhi__dv.F90 b2tfnb_dv.F90 b2tlc0_dv.F90 b2tlh0_dv.F90 b2tlhe_dv.F90 b2tlhi_dv.F90 b2tlmv_dv.F90 b2tqna_dv.F90 b2tlnl_dv.F90 b2tlv0_dv.F90 b2tqca_dv.F90  b2tqce_dv.F90 b2trcl_dv.F90 b2treq_dv.F90 b2trql_dv.F90

sed -i -e 's/ISIZE1OFni/nCv/g' b2tfhi__dv.F90

sed -i -e 's/ISIZE1OFpa/nCv/g' b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFfchz/nFc/g' b2tfnb_dv.F90
sed -i -e 's/DIMENSION(:, ISIZE1OFdv%fna_52(:, :, isb), 0:1)/DIMENSION(nbdirsmax, nFc, 0:1)/g' b2tfnb_dv.F90

sed -i -e 's/DIMENSION(:) :: dabs/DIMENSION(nCv) :: dabs/g' b2tinnt_dv.F90
sed -i -e 's/ISIZE1OFfchc/nFc/g' b2tinnt_dv.F90


sed -i -e 's/DIMENSION(:) :: dabs/DIMENSION(nCv) :: dabs/g' b2tqna_dv.F90 b2trcl_dv.F90
sed -i -e 's/DIMENSION(:, :) :: dabs/DIMENSION(nbdirsmax, nCv) :: dabs/g' b2tqna_dv.F90 b2trcl_dv.F90

sed -i -e 's/ISIZE1OFcvbzb/nCv/g' b2tral_dv.F90
sed -i -e 's/ISIZE1OFco%cthi/nFc/g' b2tral_dv.F90
sed -i -e 's/ISIZE2OFco%cthi/0:ns-1/g' b2tral_dv.F90
sed -i -e 's/ISIZE1OFco%cthe/nFc/g' b2tral_dv.F90
sed -i -e 's/ISIZE2OFco%cthe/0:ns-1/g' b2tral_dv.F90
sed -i -e 's/DIMENSION(:/DIMENSION(nbdirsmax/g' b2tral_dv.F90 b2trno_dv.F90

sed -i -e 's/ISIZE1OFco%fllim0fhi/nfc/g' b2trno_dv.F90
sed -i -e 's/ISIZE3OFco%fllim0fhi/0:ns-1/g' b2trno_dv.F90

sed -i -e 's/CHARACTER(len=\*) :: arg1/CHARACTER(len=20) :: arg1/g' b2usco_dv.F90
sed -i -e 's/CHARACTER(len=\*) :: arg10/CHARACTER(len=20) :: arg10/g' b2usmo_dv.F90





