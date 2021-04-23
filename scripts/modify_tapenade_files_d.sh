
# all files are .f90 files, move them to .F90 extension
move_to_F90.sh
rm b2uxus_d.F90
collect_nodiff_d.sh

sed -i '/DIFFSIZES/d' ./*.F90 
sed -i -e 's/ISIZE1OFfceb/mpg%nFc/g' b2us_geo_diff.F90
sed -i -e 's/DIMENSION(SIZE(x1, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x2, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x3, 1), SIZE(x3, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x4, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x5, 1), SIZE(x5, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE1OFabs/mpg%nCv/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE2OFabs/0:state%pl%ns-1/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE1OFarg1/mpg%nCv/g' b2mod_driver_diff.F90 b2npmo_d.F90 b2stbr_phys_d.F90 b2mod_recycle_diff.F90 b2tqna_d.F90
sed -i -e 's/ISIZE1OFdv%fch_pi_c/nCv/g' b2news__d.F90
sed -i -e 's/ISIZE1OFfch_p/nFc/g' b2news__d.F90
sed -i -e 's/ISIZE1OFtemp/nCv/g' b2news__d.F90 b2tfcc_d.F90 b2tfnb_d.F90 b2tqna_d.F90 b2xpic_d.F90 b2tral_d.F90
sed -i -e 's/ISIZE1OFfcbb/nFc/g' b2tfch__d.F90 b2tfnb_d.F90 b2tinnt_d.F90
sed -i -e 's/ISIZE1OFvadia/nFc/g' b2tfnb_d.F90
sed -i -e 's/ISIZE1OFcvsa/nFc/g' b2npmo_d.F90
sed -i -e 's/ISIZE1OFresult1/nCv/g' b2npmo_d.F90 b2tqna_d.F90
sed -i -e 's/ISIZE1OFcvhz/nCv/g' b2nxfv_d.F90
sed -i -e 's/ISIZE1OFvxhz/nVx/g' b2nxfv_d.F90 
sed -i -e 's/ISIZE1OFfcqalf/nFc/g' b2sian_d.F90 b2stbc_d.F90 b2stbc_phys_d.F90 b2tfhe__d.F90 b2tfhi__d.F90 b2trno_d.F90 b2tfch__d.F90 b2tfnb_d.F90 b2tinnt_d.F90
sed -i -e 's/ISIZE1OFgeo%vxonedbsq/nVx/g' b2sihs__d.F90
sed -i -e 's/ISIZE1OFgeo%cvonedbsq/nCv/g' b2sihs__d.F90
sed -i -e 's/ISIZE1OFcvvol/nCc/g' b2stbc_d.F90 
sed -i -e 's/ISIZE1OFgeo%cvvol/nCv/g' b2stbc_d.F90
sed -i -e 's/ISIZE1OFcvbb/nCv/g' b2stbm_d.F90 b2tfnb_d.F90 b2tvspa_d.F90 b2trno_d.F90 b2tfed_d.F90 b2tqna_d.F90
sed -i -e 's/ISIZE1OFcvsahz_eff/nFc/g' b2stbr_phys_d.F90 b2mod_recycle_diff.F90
sed -i -e 's/ISIZE2OFcvsahz_eff/0:1/g' b2stbr_phys_d.F90 b2mod_recycle_diff.F90
sed -i -e 's/ISIZE1OFcvsahz/nFc/g' b2stbr_phys_d.F90 b2mod_recycle_diff.F90
sed -i -e 's/ISIZE2OFcvsahz/0:1/g' b2stbr_phys_d.F90 b2mod_recycle_diff.F90
sed -i -e 's/ISIZE1OFcdpa/nFC/g' b2tfcc_d.F90 b2tfnb_d.F90
sed -i -e 's/ISIZE1OFne/nCv/g' b2tfhe__d.F90 b2tfrn_d.F90
sed -i -e 's/ISIZE1OFni/nCv/g' b2tfhi__d.F90 
sed -i -e 's/ISIZE1OFcdna/nFc/g' b2tfnb_d.F90
sed -i -e 's/ISIZE1OFpa/nCv/g' b2tfnb_d.F90
sed -i -e 's/ISIZE1OFdv%fna_52(:, :, isb)/nFc/g' b2tfnb_d.F90 
sed -i -e 's/ISIZE1OFfchz/nFc/g' b2tfnb_d.F90 
sed -i -e 's/ISIZE1OFfchc/nFc/g' b2tinnt_d.F90
sed -i -e 's/ISIZE1OFcvbzb/nCv/g' b2tral_d.F90
sed -i -e 's/CHARACTER(len=\*) :: arg1/CHARACTER(len=20) :: arg1/g' b2usco_d.F90
sed -i -e 's/CHARACTER(len=\*) :: arg10/CHARACTER(len=20) :: arg10/g' b2usmo_d.F90
sed -i -e 's/ISIZE1OFarg1/20/g' calc_err_d.F90
sed -i -e 's/ISIZE1OFarg2/20/g' calc_err_d.F90
sed -i -e 's/REAL :: result1$/integer :: result1/g' b2mod_input_profile_diff.F90
sed -i -e 's/CALL DIM_D(1.0_R8, 0.0/CALL DIM_D(1.0_R8, 0.0_R8/g' b2usht_d.F90
sed -i -e 's/#DIM_D#/DIM_D/g' dim_d.F90

sed -i -e 's/PUBLIC :: to_struct_plasma_d,/PUBLIC :: /g' b2us_prep_diff.F90
sed -i '/PUBLIC :: to_struct_cell_d, to_struct_face_d/d' b2us_debug_diff.F90
sed -i '/PUBLIC :: alloc_switches_d/d' b2mod_switches_diff.F90
sed -i '/& check_values_switches_d/d' b2mod_switches_diff.F90
sed -i -e 's/alloc_b2mod_balance_d, dealloc_b2mod_balance, dealloc_b2mod_balance_d,/dealloc_b2mod_balance,/g' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_eirene_sources, dealloc_b2mod_eirene_sources_d,/dealloc_b2mod_eirene_sources,/g' b2mod_driver_diff.F90
sed -i -e 's/run_av_get_plasma, run_av_get_plasma_d, run_av_save, run_av_save_d/run_av_get_plasma, run_av_save/g' b2mod_driver_diff.F90
sed -i -e 's/batch_av_all_init_d, batch_av_all_save, batch_av_all_fin, &/batch_av_all_save, batch_av_all_fin/g' b2mod_driver_diff.F90
sed -i '/& batch_av_all_fin_d/d' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_wall, dealloc_b2mod_wall_d/dealloc_b2mod_wall/g' b2mod_driver_diff.F90
sed -i -e 's/ONLY : dealloc_b2mod_ysmp_sdrv, &/ONLY : dealloc_b2mod_ysmp_sdrv/g' b2mod_driver_diff.F90
sed -i '/& dealloc_b2mod_ysmp_sdrv_d/d' b2mod_driver_diff.F90

sed -i '/EXTERNAL ISGHOSTCELL/d' b2us_prep_diff.F90 
sed -i '/LOGICAL :: ISGHOSTCELL/d' b2us_prep_diff.F90
sed -i '/EXTERNAL ISREALCELL/d' b2us_prep_diff.F90 
sed -i '/LOGICAL :: ISREALCELL/d' b2us_prep_diff.F90 
sed -i '/EXTERNAL ISBOUNDARYCELL/d' b2us_prep_diff.F90
sed -i '/LOGICAL :: ISBOUNDARYCELL/d' b2us_prep_diff.F90
sed -i '/EXTERNAL ISUNUSEDCELL/d' b2us_prep_diff.F90 
sed -i '/LOGICAL :: ISUNUSEDCELL/d' b2us_prep_diff.F90 
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
sed -i -e 's/B2MOD_GEO_DIFF/B2MOD_GEO/g' ./*.F90 #why this?
sed -i -e 's/GET_JSEP_NODIFF/GET_JSEP/g' ./*.F90
sed -i -e 's/CFWURE_NODIFF/CFWURE/g' ./*.F90
#sed -i -e 's/CALL READ_B2MOD_USER_NAMELIST_D(ns, ntns, geo, geod, m, md0)/CALL READ_B2MOD_USER_NAMELIST(ns, ntns, geo, m)/g' b2mod_user_namelist_diff.F90 #why this?
#sed -i '/READ_B2MOD_USER_NAMELIST_D/d' b2mod_user_namelist_diff.F90 #why this?
#sed -i 's/CALL READ_NEUTRALS_NAMELIST_D(ns, mpg, mpgd, switch/CALL READ_NEUTRALS_NAMELIST(ns, mpg, switch/g' b2stbr_d.F90 #why this?

remove_initializations_d.sh

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



