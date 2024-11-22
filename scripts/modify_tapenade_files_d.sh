
# all files are .f90 files, move them to .F90 extension
move_to_F90.sh
rm b2uxus_d.F90 my_outi_us_d.F90 samax_d.F90 smin_d.F90 smax_d.F90 get_jsep_d.F90 solve_covariance_d.F90
collect_nodiff_d.sh

sed -i '/DIFFSIZES/d' ./*.F90 
sed -i -e 's/ISIZE1OFfceb/mpg%nFc/g' b2us_geo_diff.F90
sed -i -e 's/REAL :: result1$/integer :: result1/g' b2mod_input_profile_diff.F90
sed -i -e 's/DIMENSION(SIZE(x1, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x2, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x3, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x4, 1), SIZE(x4, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x5, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x6, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x7, 1), SIZE(x7, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE1OFabs/mpg%nCv/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE2OFabs/0:state%pl%ns-1/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE1OFarg1/mpg%nCv/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE1OFarg1/nCv/g' b2npmo_d.F90 b2stbr_phys_d.F90 b2mod_recycle_diff.F90 b2tqna_d.F90 b2sikt_d.F90 b2trcl_d.F90 calc_res_fp_d.F90
sed -i -e 's/ISIZE1OFdv%fch_pi_c/nCv/g' b2news__d.F90
sed -i -e 's/ISIZE1OFfch_p/nFc/g' b2news__d.F90
sed -i -e 's/ISIZE1OFtemp/nCv/g' b2news__d.F90 b2tfcc_d.F90 b2tfnb_d.F90 b2tqna_d.F90 b2xpic_d.F90 b2tral_d.F90 b2npmo_d.F90 b2us_feedback_diff.F90 b2sikt_d.F90 b2trcl_d.F90 b2mndt_d.F90
sed -i -e 's/ISIZE1OFfcbb/nFc/g' b2tfch__d.F90 b2tfnb_d.F90 b2tinnt_d.F90 b2siav_d.F90 b2tvskt_d.F90 b2tvspa_d.F90 b2tvsq_d.F90
sed -i -e 's/ISIZE1OFvxbb/nVx/g' b2siav_d.F90
sed -i -e 's/ISIZE1OFvadia/nFc/g' b2tfnb_d.F90
sed -i -e 's/ISIZE1OFlnlam/nCv/g' b2npmo_d.F90 b2trcl_d.F90
sed -i -e 's/ISIZE1OFcvsa/nFc/g' b2npmo_d.F90
sed -i -e 's/ISIZE1OFresult1/nCv/g' b2npmo_d.F90 b2tqna_d.F90 b2sikt_d.F90 b2trcl_d.F90
sed -i -e 's/ISIZE1OFcvhz/nCv/g' b2nxfv_d.F90
sed -i -e 's/ISIZE1OFvxhz/nVx/g' b2nxfv_d.F90 
sed -i -e 's/ISIZE1OFfcqalf/nFc/g' b2sian_d.F90 b2stbc_d.F90 b2stbc_phys_d.F90 b2tfhe__d.F90 b2tfhi__d.F90 b2trno_d.F90 b2tfch__d.F90 b2tfnb_d.F90 b2tinnt_d.F90 b2tvskt_d.F90 b2tfrn_d.F90
sed -i -e 's/ISIZE1OFco%fllim0fhi/nfc/g' b2trno_d.F90
sed -i -e 's/ISIZE3OFco%fllim0fhi/0:ns-1/g' b2trno_d.F90
sed -i -e 's/ISIZE1OFgeo%vxonedbsq/nVx/g' b2sihs__d.F90
sed -i -e 's/ISIZE1OFgeo%cvonedbsq/nCv/g' b2sihs__d.F90
sed -i -e 's/ISIZE1OFcvvol/nCv/g' b2stbc_d.F90 b2sikt_d.F90
sed -i -e 's/ISIZE1OFgeo%cvvol/nCv/g' b2stbc_d.F90
sed -i -e 's/ISIZE1OFcvbb/nCv/g' b2stbm_d.F90 b2tfnb_d.F90 b2tvspa_d.F90 b2trno_d.F90 b2tfed_d.F90 b2tqna_d.F90 b2siav_d.F90 b2sikt_d.F90 b2trcl_d.F90 b2tvsq_d.F90
sed -i -e 's/ISIZE1OFcvsahz_eff/nFc/g' b2stbr_phys_d.F90 b2mod_recycle_diff.F90
sed -i -e 's/ISIZE2OFcvsahz_eff/0:1/g' b2stbr_phys_d.F90 b2mod_recycle_diff.F90
sed -i -e 's/ISIZE1OFcvsahz/nFc/g' b2stbr_phys_d.F90 b2mod_recycle_diff.F90
sed -i -e 's/ISIZE2OFcvsahz/0:1/g' b2stbr_phys_d.F90 b2mod_recycle_diff.F90
sed -i -e 's/ISIZE1OFcdpa/nFC/g' b2tfcc_d.F90 b2tfnb_d.F90
sed -i -e 's/ISIZE1OFne/nCv/g' b2tfhe__d.F90 b2tfrn_d.F90
sed -i -e 's/ISIZE1OFni/nCv/g' b2tfhi__d.F90 
sed -i -e 's/ISIZE1OFcdna/nFc/g' b2tfnb_d.F90
sed -i -e 's/ISIZE1OFpa/nCv/g' b2tfnb_d.F90
sed -i -e 's/ISIZE1OFfnapsch/nFc/g' b2tfnb_d.F90
sed -i -e 's/ISIZE1OFdv%fna_52(:, :, isb)/nFc/g' b2tfnb_d.F90 
sed -i -e 's/ISIZE1OFfchz/nFc/g' b2tfnb_d.F90 
sed -i -e 's/ISIZE1OFfchc/nFc/g' b2tinnt_d.F90
sed -i -e 's/ISIZE1OFcvbzb/nCv/g' b2tral_d.F90
sed -i -e 's/ISIZE1OFco%cthi/nFc/g' b2tral_d.F90
sed -i -e 's/ISIZE2OFco%cthi/0:ns-1/g' b2tral_d.F90
sed -i -e 's/ISIZE1OFco%cthe/nFc/g' b2tral_d.F90
sed -i -e 's/ISIZE2OFco%cthe/0:ns-1/g' b2tral_d.F90
sed -i -e 's/CHARACTER(len=\*) :: arg1/CHARACTER(len=20) :: arg1/g' b2usco_d.F90
sed -i -e 's/CHARACTER(len=\*) :: arg10/CHARACTER(len=20) :: arg10/g' b2usmo_d.F90
sed -i -e 's/ISIZE1OFarg1/20/g' calc_err_d.F90
sed -i -e 's/ISIZE1OFarg2/20/g' calc_err_d.F90
sed -i -e 's/CALL DIM_D(1.0_R8, 0.0/CALL DIM_D(1.0_R8, 0.0_R8/g' b2usht_d.F90
sed -i -e 's/#DIM_D#/DIM_D/g' dim_d.F90
sed -i -e 's/result10 = ISGHOSTCELL(cflag(:, :, cellflag_type))/result10 = count(ISGHOSTCELL(cflag(:, :, cellflag_type)))/g' b2mod_geo2_diff.F90
sed -i -e 's/IF (COUNT(result10) .EQ. 0) THEN/IF (result10 .EQ. 0) THEN/g' b2mod_geo2_diff.F90
sed -i -e 's/result10 = ISUNUSEDCELL(cflag(0:nx-1, 0:ny-1, cellflag_type))/result10 = count(ISUNUSEDCELL(cflag(0:nx-1, 0:ny-1, cellflag_type)))/g' b2mod_geo2_diff.F90
sed -i -e 's/fullgrid = COUNT(result10) .EQ. 0/fullgrid = result10 .EQ. 0/g' b2mod_geo2_diff.F90
sed -i -e 's/LOGICAL :: result10/INTEGER :: result10/g' b2mod_geo2_diff.F90

sed -i -e 's/alloc_geometry_d, dealloc_geometry_d, read_geometry_d, &/alloc_geometry_d, dealloc_geometry_d, read_geometry_d/g' b2us_geo_diff.F90
sed -i '/& check_geometry_d/d' b2us_geo_diff.F90
sed -i -e 's/read_b2fgmtry_d, read_b2fstate_d, write_b2fstate_d, &/read_b2fgmtry_d, read_b2fstate_d/g' b2us_io_diff.F90
sed -i '/& write_b2fplasma_d/d' b2us_io_diff.F90
sed -i '/PUBLIC :: to_struct_cell_d, to_struct_face_d/d' b2us_debug_diff.F90
sed -i '/PUBLIC :: alloc_switches_d/d' b2mod_switches_diff.F90
sed -i '/& check_values_switches_d/d' b2mod_switches_diff.F90
sed -i -e 's/PUBLIC :: to_struct_plasma_d,/PUBLIC :: /g' b2us_prep_diff.F90
sed -i -e 's/alloc_b2mod_balance_d, dealloc_b2mod_balance, dealloc_b2mod_balance_d,/dealloc_b2mod_balance,/g' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_eirene_sources, dealloc_b2mod_eirene_sources_d,/dealloc_b2mod_eirene_sources,/g' b2mod_driver_diff.F90
sed -i -e 's/run_av_get_plasma, run_av_get_plasma_d, run_av_save, run_av_save_d/run_av_get_plasma, run_av_save/g' b2mod_driver_diff.F90
sed -i -e 's/batch_av_all_init_d, batch_av_all_save, batch_av_all_fin, &/batch_av_all_save, batch_av_all_fin/g' b2mod_driver_diff.F90
sed -i '/& batch_av_all_fin_d/d' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_wall, dealloc_b2mod_wall_d/dealloc_b2mod_wall/g' b2mod_driver_diff.F90
sed -i -e 's/ONLY : dealloc_b2mod_ysmp_sdrv, &/ONLY : dealloc_b2mod_ysmp_sdrv/g' b2mod_driver_diff.F90
sed -i -e 's/\& read_b2mod_par_opt, read_b2mod_par_opt_d, par_opt_phys, x0/\& read_b2mod_par_opt, par_opt_phys, x0/g' b2mod_driver_diff.F90
sed -i '/& dealloc_b2mod_ysmp_sdrv_d/d' b2mod_driver_diff.F90
sed -i -e 's/\& write_b2us_feedback_d, init_feedback, init_feedback_d, \&/\& init_feedback, \&/g' b2mod_driver_diff.F90
sed -i -e 's/\& dealloc_feedback, dealloc_feedback_d/\& dealloc_feedback/g' b2mod_driver_diff.F90
sed -i -e 's/=> NULL()/= 0.0_R8/g' b2mndt_d.F90 b2sral_d.F9

sed -i '/TRIM_D/d' b2mod_main_diff.F90
sed -i '/EXTERNAL IPSETC/d' b2mnds_d.F90 
sed -i '/EXTERNAL IPPRHP/d' b2mnds_d.F90 
sed -i '/EXTERNAL OUTPUT_DS/d' b2mod_input_profile_diff.F90
sed -i '/EXTERNAL SUBINI/d' *.F90
sed -i '/EXTERNAL SUBEND/d' *.F90
sed -i '/EXTERNAL ISGHOSTCELL/d' b2us_prep_diff.F90 b2mod_geo2_diff.F90 b2mod_geo_diff.F90
sed -i '/LOGICAL :: ISGHOSTCELL/d' b2us_prep_diff.F90 b2mod_geo2_diff.F90 b2mod_geo_diff.F90
sed -i '/EXTERNAL ISREALCELL/d' b2us_prep_diff.F90 b2mod_geo_diff.F90 b2mod_geo2_diff.F90
sed -i '/LOGICAL :: ISREALCELL/d' b2us_prep_diff.F90 b2mod_geo_diff.F90 b2mod_geo2_diff.F90
sed -i '/EXTERNAL ISINDOMAIN/d' b2mod_geo_diff.F90 b2mod_geo2_diff.F90
sed -i '/LOGICAL :: ISINDOMAIN/d' b2mod_geo_diff.F90 b2mod_geo2_diff.F90
sed -i '/EXTERNAL ISCLASSICALGRID/d' b2mod_geo_diff.F90
sed -i '/LOGICAL :: ISCLASSICALGRID/d' b2mod_geo_diff.F90
sed -i '/EXTERNAL ISBOUNDARYCELL/d' b2us_prep_diff.F90
sed -i '/LOGICAL :: ISBOUNDARYCELL/d' b2us_prep_diff.F90
sed -i '/EXTERNAL ISUNUSEDCELL/d' b2us_prep_diff.F90 b2mod_geo2_diff.F90 b2xvsg_d.F90 b2mod_geo_diff.F90
sed -i '/LOGICAL :: ISUNUSEDCELL/d' b2us_prep_diff.F90 b2mod_geo2_diff.F90 b2xvsg_d.F90 b2mod_geo_diff.F90
sed -i '/EXTERNAL ISCLASSICALGRID/d' b2us_prep_diff.F90 
sed -i '/LOGICAL :: ISCLASSICALGRID/d' b2us_prep_diff.F90
sed -i '/EXTERNAL RESTART_MA28_FOR_US/d' b2news__d.F90 b2npmo_d.F90 b2usht_d.F90 
sed -i '/EXTERNAL DEALLOC_B2MOD_MA28_FOR_US/d' b2mod_driver_diff.F90
sed -i -e 's/MSTEP_NODIFF/MSTEP/g' heatdiff1D_d.F90
sed -i -e 's/LINES2C_NODIFF/LINES2C/g' heatdiff1D_d.F90
sed -i '/EXTERNAL RWCDF/d' b2mod_mwti_diff.F90 
sed -i '/EXTERNAL B2CRTIMECDF/d' b2mod_mwti_diff.F90 
sed -i '/EXTERNAL CHECK_CDF_STATUS/d' b2mod_mwti_diff.F90 
sed -i '/EXTERNAL OR/d' b2mod_mwti_diff.F90 
sed -i '/INTEGER :: OR/d' b2mod_mwti_diff.F90 
sed -i -e 's/B2UXUS_NODIFF/B2UXUS/g' b2usco_d.F90 b2usmo_d.F90 b2usht_d.F90 b2uspo_d.F90
sed -i -e 's/B2MOD_GEO_DIFF/B2MOD_GEO/g' ./*.F90
sed -i -e 's/GET_JSEP_NODIFF/GET_JSEP/g' ./*.F90
sed -i -e 's/CFWURE_NODIFF/CFWURE/g' ./*.F90
sed -i -e 's/USE B2MOD_RESIDUALS_DIFF/USE B2MOD_RESIDUALS/g' b2mod_diag_diff.F90 b2us_prep_diff.F90 b2mwmv_d.F90
sed -i -e 's/USE B2MOD_SOURCES_DIFF/USE B2MOD_SOURCES/g' b2mod_batch_average_diff.F90 b2us_prep_diff.F90 b2mod_ual_io_diff.F90 b2mwmv_d.F90 b2sihs_d.F90 profile_average_d.F90
sed -i -e 's/USE B2MOD_TRANSPORT_DIFF/USE B2MOD_TRANSPORT/g' b2us_prep_diff.F90 b2mod_ual_io_diff.F90 b2mwmv_d.F90
sed -i -e 's/USE B2MOD_ANOMALOUS_TRANSPORT_DIFF/USE B2MOD_ANOMALOUS_TRANSPORT/g' b2us_prep_diff.F90 b2mod_ual_io_diff.F90 b2stbc_bas_d.F90  b2stbc_spb_d.F90 b2txvspr_d.F90
sed -i -e '/INTEGER :: regiontype_yedge/d' b2mod_ual_io_grid_diff.F90
sed -i -e '/INTEGER :: regiontype_xedge/d' b2mod_ual_io_grid_diff.F90
sed -i -e '/INTEGER :: regiontype_cell/d' b2mod_ual_io_grid_diff.F90

sed -i -e 's/CHARACTER(len=13), DIMENSION(:), DIMENSION(:), ALLOCATABLE :: text/CHARACTER(len=13), DIMENSION(:), ALLOCATABLE :: text(:)/g' b2us_plasma_diff.F90
sed -i -e 's/DO ii2=1,SIZE(state_extd%text(ii1), 1)/DO ii2=1,SIZE(state_extd%text, 1)-1/g' b2us_plasma_diff.F90
sed -i -e 's/state_extd%text(ii1)(ii2) =/state_extd%text =/g' b2us_plasma_diff.F90

sed -i -e 's/MY_OUT_US_NODIFF/MY_OUT_US/g' ./*.F90
sed -i -e 's/sort_faces/sort_faces_nodiff/g' b2wdat.F

sed -i -e 's/DAMAX_NODIFF/samax/g' b2mndt_d.F90 b2mxac_d.F90 b2stcx_d.F90 b2stel_d.F90
sed -i -e 's/damax/samax/g' b2stcx_d.F90
sed -i -e 's/SMIN_NODIFF/smin/g' ./*.F90
sed -i -e 's/SMAX_NODIFF/smax/g' ./*.F90
sed -i '/EXTERNAL ANINT/d' b2xvcp_d.F90 
sed -i '/REAL(kind=r8) :: ANINT/d' b2xvcp_d.F90
sed -i -e 's/calc_dist(/calc_dist_nodiff(/g' b2wdat.F
sed -i -e 's/calc_dist_f/calc_dist_f_nodiff/g' b2wdat.F
sed -i '/EXTERNAL XERSET/d' b2mod_main_diff.F90
sed -i '/EXTERNAL IPGETC/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL B2TRCS/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL B2TRCF/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL B2TRACE/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL B2TRCI/d' b2mod_driver_diff.F90
sed -i '/EXTERNAL B2MWTI/d' b2mod_driver_diff.F90
sed -i 's/b2usr_loads/b2usr_loads_nodiff/g' b2mod_usrtrc.F
sed -i 's/b2xppz_st/b2xppz_st_nodiff/g' b2mod_usrtrc.F
sed -i 's/b2xzef_st/b2xzef_st_nodiff/g' b2mod_wrsep.F
sed -i 's/fill/fill_nodiff/g' prvrt*.F
sed -i 's/FIX_USER_NODIFF/FIX_USER/g' fix_user_d.F90
sed -i '/EXTERNAL OR/d' b2stbr_d.F90
sed -i '/INTEGER :: OR/d' b2stbr_d.F90
#remove_initializations_d.sh

sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_diff.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_diff.F90
sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_d.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_d.F90

sed -i -e "/TYPE(B2RATESWORK_DIFF) :: rtw/i\      TYPE(B2DIAGNOSTIC) :: diag" b2us_plasma_diff.F90
sed -i -e "/END TYPE MAPPING_DIFF/i\      INTEGER :: ncv, nfc, nvx, ncg, nci, ncmxvx, ncmxfc, nvmxcv, nvmxfc&" b2us_map_diff.F90
sed -i -e "/END TYPE MAPPING_DIFF/i\&     , nfs, nbc, mxnbc, nrc, mxnrc, ncmxnv, ncf, mxncf" b2us_map_diff.F90

sed -i -e "s/B2MNDR_2_D(nout, ns, geo, mpg, state, state_ext)/B2MNDR_2_D(nout, ns, geo, mpg, state, stated, state_ext)/g" b2mod_driver_diff.F90 b2mod_main_diff.F90

cp $TAPENADEDIR/ADFirstAidKit/adContext.c .
cp $TAPENADEDIR/ADFirstAidKit/adContext.h .
cp $TAPENADEDIR/ADFirstAidKit/adDebug.c .
cp $TAPENADEDIR/ADFirstAidKit/adDebug.h .
cp $TAPENADEDIR/ADFirstAidKit/adStack.c .
cp $TAPENADEDIR/ADFirstAidKit/adStack.h .

#################### for feedback TBD!!!


#sed -i '/saved_cbsna_sold = 0.0/d' b2mod_driver_diff.F90
#sed -i '/saved_cbsna_pfr2d = 0.0/d' b2mod_driver_diff.F90
#sed -i '/saved_cbsna_pfr1d = 0.0/d' b2mod_driver_diff.F90
#sed -i '/saved_cbsch_cored = 0.0/d' b2mod_driver_diff.F90
#sed -i '/saved_cbsna_cored = 0.0/d' b2mod_driver_diff.F90
#sed -i '/saved_cbshi_cored = 0.0/d' b2mod_driver_diff.F90
#sed -i '/saved_cbshe_cored = 0.0/d' b2mod_driver_diff.F90
#sed -i '/saved_na_feedback_actuatord = 0.0/d' b2mod_driver_diff.F90



