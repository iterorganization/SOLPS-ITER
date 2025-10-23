#! /usr/bin/env tcsh
move_to_F90.sh
rm b2uxus_d.F90 solve_covariance_d.F90 calc_res_fp_d.F90 eirflux_map_d.F90 b2mod_astra_to_b2_d.F90
collect_nodiff_d.sh
rm damax_d.F90 smin_d.F90 smax_d.F90 get_jsep_d.F90 my_outi_us_d.F90 my_out_us_d.F90 b2wuzd_d.F90 set_parameters.F set_tgt_perturbation.F set_tgt_gradient.F
mv b2mn_d.F90 b2mn_d.F90

cp $TAPENADEDIR/ADFirstAidKit/adDebug.* .
cp $TAPENADEDIR/ADFirstAidKit/adStack.c .
cp $TAPENADEDIR/ADFirstAidKit/adStack.h .
cp $TAPENADEDIR/ADFirstAidKit/adComplex.h .

sed -i "/INCLUDE 'DIFFSIZES.inc'/d" ./*.F90
sed -i "/USE DIFFSIZES/d" ./*.F90
#sed -i -e "/IMPLICIT NONE/i\  USE B2MOD_DIFFSIZES" ./*.F90
#sed -i -e 's/#DIM_D#/DIM_D/g' dim_d.F90 #why?
sed -i -e 's/SMIN_NODIFF/smin/g' ./*.F90
sed -i -e 's/SMAX_NODIFF/smax/g' ./*.F90

sed -i '/EXTERNAL ALLOC_B2MOD_B2_TO_ASTRA/d' b2mod_driver_diff.F90 b2mod_main_diff.F90
sed -i '/EXTERNAL CDFMOVIE/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL DEALLOC_B2MOD_MWTI/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL TALLIES/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL REPEAT/d' b2mod_elements_diff.F90 b2trzh_d.F90
sed -i '/EXTERNAL SUBINI/d' *.F90
sed -i '/EXTERNAL SUBEND/d' *.F90
sed -i '/EXTERNAL RESTART_MA28_FOR_US/d' b2news__d.F90 b2npmo_d.F90 b2usht_d.F90 b2news_m_d.F90
sed -i '/EXTERNAL DEALLOC_B2MOD_MA28_FOR_US/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL ISGHOSTCELL/d' b2mod_geo_diff.F90 b2mod_indirect_diff.F90
sed -i '/LOGICAL :: ISGHOSTCELL/d' b2mod_geo_diff.F90 b2mod_indirect_diff.F90
sed -i '/EXTERNAL ISREALCELL/d' b2mod_geo_diff.F90 b2mod_indirect_diff.F90
sed -i '/LOGICAL :: ISREALCELL/d' b2mod_geo_diff.F90 b2mod_indirect_diff.F90
sed -i '/EXTERNAL ISINDOMAIN/d' b2mod_geo_diff.F90 b2mod_indirect_diff.F90
sed -i '/LOGICAL :: ISINDOMAIN/d' b2mod_geo_diff.F90 b2mod_indirect_diff.F90
sed -i '/EXTERNAL ISCLASSICALGRID/d' b2mod_geo_diff.F90
sed -i '/LOGICAL :: ISCLASSICALGRID/d' b2mod_geo_diff.F90
sed -i '/EXTERNAL ISUNUSEDCELL/d' b2mod_geo_diff.F90
sed -i '/LOGICAL :: ISUNUSEDCELL/d' b2mod_geo_diff.F90
sed -i '/EXTERNAL DEALLOCATEB2GRIDMAP/d' b2mod_geo_diff.F90
sed -i -e 's/MSTEP_NODIFF/MSTEP/g' heatdiff1D_d.F90
sed -i -e 's/LINES2C_NODIFF/LINES2C/g' heatdiff1D_d.F90
sed -i '/EXTERNAL OR/d' b2stbr_d.F90
sed -i '/INTEGER :: OR/d' b2stbr_d.F90
sed -i -e 's/B2UXUS_NODIFF/B2UXUS/g' b2usco_d.F90 b2usmo_d.F90 b2usht_d.F90 b2uspo_d.F90
sed -i -e 's/GET_JSEP_NODIFF/GET_JSEP/g' ./*.F90
sed -i -e 's/CFWURE_NODIFF/CFWURE/g' ./*.F90
sed -i '/EXTERNAL IPSETC/d' b2mnds_d.F90 
sed -i '/EXTERNAL IPPRHP/d' b2mnds_d.F90 
sed -i '/EXTERNAL ANINT/d' b2xvcp_d.F90 
sed -i '/REAL(kind=r8) :: ANINT/d' b2xvcp_d.F90
sed -i '/EXTERNAL XERSET/d' b2mod_main_diff.F90
sed -i '/EXTERNAL IPGETC/d' b2mod_driver_diff.F90 b2trzh_d.F90
sed -i '/EXTERNAL B2TRCS/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL B2TRCF/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL B2TRACE/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL B2TRCI/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL B2MWTI/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL OUTPUT_DS/d' b2mod_input_profile_diff.F90
sed -i '/EXTERNAL B2FILE./d' b2mndt_d.F90
sed -i '/TRIM_D/d' b2mod_main_diff.F90
sed -i 's/FIX_USER_NODIFF/FIX_USER/g' fix_user_d.F90
sed -i 's/B2XPNE_ST_NODIFF/B2XPNE_ST/g' b2mod_running_average_diff.F90 b2rups_d.F90
sed -i 's/call species/call species_nodiff/g' tallies.F
sed -i 's/b2usr_loads/b2usr_loads_nodiff/g' b2mod_usrtrc.F
sed -i 's/b2xppz_st/b2xppz_st_nodiff/g' b2mod_usrtrc.F
sed -i 's/B2NEUT_IND_NODIFF/B2NEUT_IND/g' b2usr_loads_d.F90
sed -i 's/b2xppz/b2xppz_nodiff/g' b2mod_blnm.F
sed -i 's/b2xzef/b2xzef_nodiff/g' b2mod_wrsep.F
sed -i 's/fill/fill_nodiff/g' prvrt*.F b2xpne_st.F
sed -i 's/B2XVFX_NODIFF/B2XVFX/g' b2xtvx_d.F90
sed -i 's/B2XVFF_NODIFF/B2XVFF/g' b2npp7_d.F90 b2tr21_d.F90 b2usp7_d.F90
sed -i '/PRGINI_D/d' b2mod_main_diff.F90
sed -i 's/b2xvfy/b2xvfy_nodiff/g' b2xvff.F
sed -i -e 's/B2WUZD_NODIFF/B2WUZD/g' b2mod_driver_diff.F90 b2mnds_d.F90 b2mod_running_average_diff.F90 b2mod_batch_average_diff.F90 b2wucp_d.F90
sed -i 's/call intcell/call intcell_nodiff/g' b2mod_mwti.F90
sed -i 's/b2scopy/b2scopy_nodiff/g' b2mwmv.F
sed -i 's/b2saxpy/b2saxpy_nodiff/g' b2mwmv.F
sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_diff.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_diff.F90
sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_d.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_d.F90
sed -i '/MINVAL_D/d' ./*.F90
sed -i '/MAXVAL_D/d' ./*.F90
sed -i '/EXTERNAL XERRAB_D/d' ./*.F90
sed -i '/ANY_D/d' ./*.F90
sed -i '/COUNT_D/d' ./*.F90
sed -i '/ALLOCATED_D/d' ./*.F90
sed -i '/GET_B25_HASH_D/d' b2mod_main_diff.F90
sed -i '/MINLOC_D/d' b2mod_neutrals_namelist_diff.F90
sed -i -e 's/MY_OUT_US_NODIFF/MY_OUT_US/g' ./*.F90
sed -i 's/call sort_faces/call sort_faces_ndiff/g' b2wdat.F
sed -i -e 's/DAMAX_NODIFF/samax/g' b2mndt_d.F90 b2mxac_d.F90 b2stcx_d.F90 b2stel_d.F90

sed -i '/alloc_switches_d/d' b2mod_switches_diff.F90
sed -i '/check_values_switches_d/d' b2mod_switches_diff.F90
sed -i '/read_first_switches_d/d' b2mod_switches_diff.F90

sed -i -e 's/alloc_geometry_d, dealloc_geometry_d, read_geometry_d, &/alloc_geometry_d, dealloc_geometry_d, read_geometry_d/g' b2us_geo_diff.F90
sed -i '/check_geometry_d/d' b2us_geo_diff.F90
#sed -i -e 's/ISIZE1OFfceb/mpg%nFc/g' b2us_geo_diff.F90
sed -i -e 's/ISIZE1OFfspsi/mpg%nFs/g' b2us_geo_diff.F90
#sed -i -e 's/INTEGER, DIMENSION(ISIZE1OFresult1) :: result1/INTEGER :: result1/g' b2us_geo_diff.F90
#sed -i -e 's/result1 = MAXVAL(arg1(:))/result1 = MAXVAL(gm%vxfpsi(verts(1:mpg%cvvxp(icv, 2))))/g' b2us_geo_diff.F90
#sed -i -e 's/result2 = MINVAL(arg2(:))/result2 = MINVAL(gm%vxfpsi(verts(1:mpg%cvvxp(icv, 2))))/g' b2us_geo_diff.F90
#sed -i -e '/REAL(kind=r8), DIMENSION(mpg%cvvxp(icv, 2)) :: arg/d' b2us_geo_diff.F90
#sed -i -e '/arg.(:) = gm%vxfpsi(verts(1:mpg%cvvxp(icv, 2)))/d' b2us_geo_diff.F90
#sed -i -e 's/cvfpsi(icv) = SUM(arg10)\/mpg%cvvxp(icv, 2)/cvfpsi(icv) = SUM(gm%vxfpsi(verts))\/mpg%cvvxp(icv, 2)/g' b2us_geo_diff.F90
#sed -i -e '/arg10 = gm%vxfpsi(verts)/d' b2us_geo_diff.F90
sed -i -e 's/DIMENSION(:) :: dabs0/DIMENSION(mpg%nFs) :: dabs0/g' b2us_geo_diff.F90
#sed -i '/INTRINSIC DABS/d' b2us_geo_diff.F90 b2trcl_d.F90

#sed -i -e '/EXTERNAL DIM_D/a\    REAL(kind=r8) :: DIM_D' b2mod_math_diff.F90 b2usht_d.F90

sed -i -e 's/ISIZE1OFtemp/nCv/g' b2news__d.F90 b2tfcc_d.F90 b2tfnb_d.F90 b2tqna_d.F90 b2xpic_d.F90 b2us_feedback_diff.F90 b2npmo_d.F90 b2sikt_d.F90 b2tral_d.F90 b2trcl_d.F90 b2mndt_d.F90 b2news_m_d.F90 b2trzh_d.F90

sed -i -e 's/read_b2fgmtry_d, read_b2fstate_d, write_b2fstate_d, &/read_b2fgmtry_d, read_b2fstate_d/g' b2us_io_diff.F90
sed -i '/& write_b2fplasma_d/d' b2us_io_diff.F90

sed -i -e 's/alloc_b2mod_balance_d, dealloc_b2mod_balance/dealloc_b2mod_balance/g' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_balance_d, dealloc_b2mod_eirene_sources/dealloc_b2mod_eirene_sources/g' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_eirene_sources_d, balance_average/balance_average/g' b2mod_driver_diff.F90
sed -i -e 's/run_av_get_plasma, run_av_get_plasma_d, run_av_save, run_av_save_d/run_av_get_plasma, run_av_save/g' b2mod_driver_diff.F90
sed -i -e 's/batch_av_all_init_d, batch_av_all_save, batch_av_all_fin, &/batch_av_all_save, batch_av_all_fin/g' b2mod_driver_diff.F90
sed -i '/& batch_av_all_fin_d/d' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_wall, dealloc_b2mod_wall_d/dealloc_b2mod_wall/g' b2mod_driver_diff.F90
sed -i -e 's/ONLY : dealloc_b2mod_ysmp_sdrv, &/ONLY : dealloc_b2mod_ysmp_sdrv/g' b2mod_driver_diff.F90
sed -i '/& dealloc_b2mod_ysmp_sdrv_d/d' b2mod_driver_diff.F90
sed -i -e 's/\& write_b2us_feedback_d, init_feedback, init_feedback_d, \&/\& init_feedback, \&/g' b2mod_driver_diff.F90
sed -i -e 's/\& dealloc_feedback, dealloc_feedback_d/\& dealloc_feedback/g' b2mod_driver_diff.F90
sed -i -e 's/\& read_b2mod_par_opt, read_b2mod_par_opt_d, par_opt_phys, par_opt_physd/\& read_b2mod_par_opt, par_opt_phys, par_opt_physd, nsigma_opt/g' b2mod_driver_diff.F90
sed -i -e 's/dealloc_sputter_data_d, dealloc_b2mod_sputter, dealloc_b2mod_sputter_d/dealloc_b2mod_sputter/g' b2mod_driver_diff.F90
sed -i '/& dealloc_b2mod_neoclassical_d/d' b2mod_driver_diff.F90
sed -i '/& dealloc_b2mod_transport_disruption_d/d' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_neoclassical, &/dealloc_b2mod_neoclassical/g' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_transport_disruption, &/dealloc_b2mod_transport_disruption/g' b2mod_driver_diff.F90
sed -i -e 's/\& alloc_b2mod_balance_d, write_balance, write_balance_d, \&/\& alloc_b2mod_balance_d, write_balance, \&/g' b2mod_driver_diff.F90
sed -i -e 's/\& dealloc_b2mod_eirene_sources, dealloc_b2mod_eirene_sources_d, \&/\& dealloc_b2mod_eirene_sources, \&/g' b2mod_driver_diff.F90
sed -i -e 's/\& balance_average, update_average_balance, update_average_balance_d/\& balance_average, update_average_balance/g' b2mod_driver_diff.F90
sed -i -e 's/\& alloc_b2mod_b2plot_d, dealloc_b2mod_b2plot, dealloc_b2mod_b2plot_d/\& dealloc_b2mod_b2plot/g' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_facdrift_exb, \&/dealloc_b2mod_facdrift_exb/g' b2mod_driver_diff.F90
sed -i -e '/\& dealloc_b2mod_facdrift_exb_d/d' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_mrel, dealloc_b2mod_mrel_d/dealloc_b2mod_mrel/g' b2mod_driver_diff.F90
sed -i -e '/\& dealloc_b2mod_zhfrtf_df_d/d' b2mod_driver_diff.F90
sed -i -e 's/\& dealloc_b2mod_zhfrtf_d, dealloc_b2mod_zhfrtf_df, \&/\& dealloc_b2mod_zhfrtf_d, dealloc_b2mod_zhfrtf_df/g' b2mod_driver_diff.F90

sed -i -e 's/DIMENSION(:, :) :: dabs0/DIMENSION(SIZE(rza0, 1), SIZE(rza0, 2)) :: dabs0/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(:, :) :: dabs1/DIMENSION(SIZE(rz20, 1), SIZE(rz20, 2)) :: dabs1/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(:, :) :: dabs2/DIMENSION(SIZE(rpt0, 1), SIZE(rpt0, 2)) :: dabs2/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(:, :) :: dabs3/DIMENSION(SIZE(rpi0, 1), SIZE(rpi0, 2)) :: dabs3/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(:) :: dabs4/DIMENSION(mpg%nCv) :: dabs4/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE1OFarg1/mpg%nCv/g' b2mod_driver_diff.F90

sed -i -e "s/USE B2MOD_ASTRA_TO_B2_DIFF/USE B2MOD_ASTRA_TO_B2/g" b2mod_main_diff.F90 b2stbc_phys_d.F90

sed -i -e 's/=> NULL()/= 0.0_R8/g' b2mndt_d.F90 b2sral_d.F90
sed -i -e 's/ISIZE1OFgeo%cvvol/nCv/g' b2stbc_d.F90 b2news_m_d.F90 b2mndt_d.F90 b2news__d.F90
sed -i -e 's/ISIZE1OFst%dv%fac_vis/nFc/g' b2news__d.F90

sed -i -e 's/ISIZE1OFarg1/nCv/g' b2npmo_d.F90 b2stbr_phys_d.F90 b2tqna_d.F90 eirene_f30f31_d.F90 b2mod_recycle_diff.F90 b2sikt_d.F90 b2trcl_d.F90 b2tfhe__d.F90 b2trzh_d.F90
sed -i -e 's/ISIZE1OFlnlam/nCv/g' b2npmo_d.F90 b2trcl_d.F90 b2trzh_d.F90
sed -i -e 's/ISIZE1OFcvsa/nFc/g' b2npmo_d.F90
sed -i -e 's/ISIZE1OFresult1/nCv/g' b2npmo_d.F90 b2tqna_d.F90 b2sikt_d.F90 b2trcl_d.F90 b2trzh_d.F90
sed -i -e 's/ISIZE1OFcvhz/nCv/g' b2nxfv_d.F90 b2npmo_d.F90

sed -i -e 's/ISIZE1OFfcqalf/nFc/g' b2sian_d.F90 b2stbc_d.F90 b2stbc_phys_d.F90 b2tfhe__d.F90 b2tfhi__d.F90 b2trno_d.F90 b2tfch__d.F90 b2tfnb_d.F90 b2tinnt_d.F90 b2tvskt_d.F90 b2tfrn_d.F90

sed -i -e 's/ISIZE1OFfcbb/nFc/g' b2siav_d.F90 b2tvskt_d.F90 b2tvspa_d.F90 b2tvsq_d.F90  b2siav_zh_d.F90
sed -i -e 's/ISIZE1OFvxbb/nVx/g' b2siav_d.F90 b2siav_zh_d.F90
sed -i -e 's/ISIZE1OFcvbb/nCv/g' b2siav_d.F90 b2siav_zh_d.F90 b2sikt_d.F90 b2tqna_d.F90 b2tvspa_d.F90 b2tvsq_d.F90
sed -i -e 's/ISIZE1OFcvvol/nCv/g' b2sikt_d.F90

sed -i -e 's/TYPE(B2PLASMA_DIFF), INTENT(IN) :: pld/TYPE(B2PLASMA_diff), INTENT(INout) :: pld/g' b2stbc_phys_d.F90 b2stel_d.F90
sed -i -e 's/TYPE(B2RATES_DIFF), INTENT(IN) :: rtd/TYPE(B2RATES_diff), INTENT(INout) :: rtd/g' b2stbc_phys_d.F90 b2stel_d.F90
sed -i -e 's/TYPE(B2RATESWORK), INTENT(IN) :: rtwd/TYPE(B2RATESWORK), INTENT(INout) :: rtwd/g' b2stel_d.F90
sed -i -e 's/TYPE(GEOMETRY_DIFF), INTENT(IN) :: geod/TYPE(GEOMETRY_diff), INTENT(INout) :: geod/g' b2mod_recycle_diff.F90 b2mndt_d.F90 b2news__d.F90 b2news_m_d.F90 b2npht_d.F90 b2npmo_d.F90 b2siav_d.F90  b2siav_zh_d.F90 b2sral_d.F90 b2stbc_d.F90 b2stbc_phys_d.F90 b2stbr_d.F90 b2stel_d.F90 b2tfch__d.F90 b2tinnt_d.F90 b2tlhe_d.F90 b2tlhi_d.F90 b2tqca_d.F90  b2tqce_d.F90 b2tqin_d.F90 b2tral_d.F90 b2trno_d.F90 b2trql_d.F90 b2tvspa_d.F90 b2tvsq_d.F90 b2stbr_phys_d.F90 b2tqna_d.F90 b2trcl_d.F90

sed -i -e 's/TYPE(SWITCHES_DIFF), INTENT(IN) :: switchd/TYPE(SWITCHES_diff), INTENT(INout) :: switchd/g' b2npco_d.F90 b2npht_d.F90 b2npmo_d.F90 b2sifr__d.F90 b2sihs__d.F90 b2sqel_d.F90 b2stbc_d.F90 b2stbc_phys_d.F90 b2stbr_phys_d.F90 b2stcx_d.F90 b2tcpa_d.F90 b2tfch__d.F90 b2tfhe__d.F90  b2tfhi__d.F90 b2tfnb_d.F90 b2tlc0_d.F90 b2tlh0_d.F90 b2tlhe_d.F90 b2tlhi_d.F90 b2tlmv_d.F90 b2tqna_d.F90 b2tlnl_d.F90 b2tlv0_d.F90 b2tqca_d.F90  b2tqce_d.F90 b2trcl_d.F90 b2treq_d.F90 b2trql_d.F90 b2sikt_d.F90

sed -i -e 's/ISIZE1OFni/nCv/g' b2tfhi__d.F90

sed -i -e 's/ISIZE1OFpa/nCv/g' b2tfnb_d.F90
sed -i -e 's/ISIZE1OFfchz/nFc/g' b2tfnb_d.F90
sed -i -e 's/DIMENSION(ISIZE1OFdv%fna_52(:, :, isb), 0:1)/DIMENSION(nFc, 0:1)/g' b2tfnb_d.F90

sed -i -e 's/DIMENSION(:) :: dabs/DIMENSION(nCv) :: dabs/g' b2tinnt_d.F90 b2tqna_d.F90 b2trcl_d.F90
sed -i -e 's/ISIZE1OFfchc/nFc/g' b2tinnt_d.F90

sed -i -e 's/ISIZE1OFcvbzb/nCv/g' b2tral_d.F90
sed -i -e 's/ISIZE1OFco%cthi/nFc/g' b2tral_d.F90
sed -i -e 's/ISIZE2OFco%cthi/0:ns-1/g' b2tral_d.F90
sed -i -e 's/ISIZE1OFco%cthe/nFc/g' b2tral_d.F90
sed -i -e 's/ISIZE2OFco%cthe/0:ns-1/g' b2tral_d.F90

sed -i -e 's/ISIZE1OFco%fllim0fhi/nfc/g' b2trno_d.F90
sed -i -e 's/ISIZE3OFco%fllim0fhi/0:ns-1/g' b2trno_d.F90

sed -i -e 's/CHARACTER(len=\*) :: arg1/CHARACTER(len=20) :: arg1/g' b2usco_d.F90
sed -i -e 's/CHARACTER(len=\*) :: arg10/CHARACTER(len=20) :: arg10/g' b2usmo_d.F90

sed -i -e 's/nmean, corr_model, corr_length, corr_lengthd, corr_cutoff/nmean, corr_model, corr_length, corr_lengthd, corr_cutoff, nsigmx, nncf/g' calc_loglikelihood_d.F90



