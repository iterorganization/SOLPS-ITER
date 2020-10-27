
# all files are .f90 files, move them to .F90 extension
move_to_F90.sh

collect_nodiff_b.sh

add_ncall.sh
sed -i -e 's/ipgtmx=40/ipgtmx=100/g' ipmain.F

#!FIXME
sed -i '/POPPOINTER8/d' ./*.F90 
sed -i '/PUSHPOINTER8/d' ./*.F90 
sed -i '/CALL PUSHINTEGER4ARRAY(mpg%ictcntrl/d' ./*.F90 
sed -i '/CALL POPINTEGER4ARRAY(mpg%ictcntrl/d' ./*.F90 
#!FIXME
# the above is needed otherwise the program fails with segmentation fault because attempts to fecth from the variables that have been de-allocated(prabably)



sed -i '/DIFFSIZES/d' ./*.F90 
sed -i -e 's/REAL :: result1$/integer :: result1/g' b2mod_input_profile_diff.F90
sed -i -e 's/LOGICAL :: mask$/LOGICAL :: mask(-1:m%nx,-1:m%ny)/g' b2us_prep_diff.F90
sed -i -e 's/LOGICAL :: mask0/LOGICAL :: mask0(m%ncmxvx)/g' b2us_prep_diff.F90
sed -i -e 's/LOGICAL :: mask1/LOGICAL :: mask1(m%nfc,2)/g' b2us_prep_diff.F90
sed -i -e 's/LOGICAL :: arg1/LOGICAL :: arg1(2*m%nfc)/g' b2us_prep_diff.F90
sed -i -e 's/DIMENSION(SIZE(x1, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x2, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x3, 1), SIZE(x3, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x4, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x5, 1), SIZE(x5, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE1OFabs/mpg%nCv/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE2OFabs/0:state%pl%ns-1/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE1OFarg1/mpg%nCv/g' b2mod_driver_diff.F90 b2mod_recycle_diff.F90
sed -i -e 's/ISIZE1OFmask/mpg%nCv/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE2OFmask/state%pl%ns/g' b2mod_driver_diff.F90 
sed -i -e 's/ISIZE1OFcvsahz_eff/nFc/g'  b2mod_recycle_diff.F90
sed -i -e 's/ISIZE2OFcvsahz_eff/0:1/g' b2mod_recycle_diff.F90
sed -i -e 's/ISIZE1OFcvsahz/nFc/g' b2mod_recycle_diff.F90
sed -i -e 's/ISIZE2OFcvsahz/0:1/g' b2mod_recycle_diff.F90
sed -i -e 's/ISIZE1OFdv%fch_pi_c/nCv/g' b2news__b.F90
sed -i -e 's/alfx_c, co%sigx_c, pl%po, dv%ne, pl%te, pl%na, pl%ua, \&/alfx_c, co%sigx_c, dv%fch_pi_c, pl%po, dv%ne, pl%te, pl\&/g' b2news__b.F90
sed -i -e 's/\&                st_ext, dv%ue)/\&                %na, pl%ua, st_ext, dv%ue)/g' b2news__b.F90
sed -i -e 's/ISIZE1OFcvsa/nFc/g' b2npmo_b.F90
sed -i -e 's/ISIZE1OFvxhz/nVx/g' b2nxfv_b.F90 
sed -i -e 's/ISIZE1OFcvhz/nCv/g' b2nxfv_b.F90
sed -i -e 's/ISIZE1OFgeo%vxonedbsq/nVx/g' b2sihs__b.F90
sed -i -e 's/ISIZE1OFgeo%cvonedbsq/nCv/g' b2sihs__b.F90
sed -i -e "/GRADC_NODIFF(ncv, nfc, nvx, 1, geo, mpg, donedbsqc)/a\&             vxonedbsq, donedbsqc)" b2sihs__b.F90
sed -i -e "s/GRADC_NODIFF(ncv, nfc, nvx, 1, geo, mpg, donedbsqc)/GRADC_NODIFF(ncv, nfc, nvx, 1, geo, mpg, geo%cvonedbsq, geo%\&/g" b2sihs__b.F90
sed -i -e 's/ISIZE1OFgeo%cvvol/nCv/g' b2stbc_b.F90
sed -i -e 's/ISIZE1OFfcqalf/nFc/g' b2stbc_b.F90 b2stbc_phys_b.F90 b2tfch__b.F90 b2tfhe__b.F90 b2tfhi__b.F90 b2trno_b.F90 
sed -i -e "s/CALL B2SAXPY(ncv, sna0ep, 1, srw%sna0(1, 0, is), 1)/CALL B2SAXPY(ncv, sna0ep, geo%cvvol, 1, srw%sna0(1, 0, is), 1)/g" b2stbc_b.F90
sed -i -e "s/CALL B2SAXPY(ncv, she0ep, 1, srw%she0(1, 0), 1)/CALL B2SAXPY(ncv, she0ep, geo%cvvol, 1, srw%she0(1, 0), 1)/g" b2stbc_b.F90
sed -i -e "s/CALL B2SAXPY(ncv, shi0ep, 1, srw%shi0(1, 0), 1)/CALL B2SAXPY(ncv, shi0ep, geo%cvvol, 1, srw%shi0(1, 0), 1)/g" b2stbc_b.F90
#maybe TBC
sed -i -e "s/CALL PUSHREAL4(result11)/CALL PUSHREAL4ARRAY(result11, r8\/4)/g" b2stbc_phys_b.F90 
sed -i -e "s/CALL POPREAL4(result11)/CALL POPREAL4ARRAY(result11, r8\/4)/g" b2stbc_phys_b.F90 
#maybe TBC
sed -i -e 's/ISIZE1OFcdpa/nFc/g' b2tfcc_b.F90 b2tfnb_b.F90
sed -i -e 's/ISIZE1OFne/nCv/g' b2tfhe__b.F90 b2tfrn_b.F90
sed -i -e 's/ISIZE1OFni/nCv/g' b2tfhi__b.F90 
sed -i -e 's/ISIZE1OFfchanml/nFc/g' b2tfhi__b.F90 
sed -i -e 's/ISIZE1OFcdna/nFc/g' b2tfnb_b.F90
sed -i -e 's/ISIZE1OFpa/nCv/g' b2tfnb_b.F90
sed -i -e 's/ISIZE1OFtemp/nCv/g' b2tfnb_b.F90
sed -i -e 's/ISIZE1OFvadia/nFc/g' b2tfnb_b.F90
sed -i -e 's/ISIZE1OFdv%fna_52(:, :, isb)/nFc/g' b2tfnb_b.F90 
sed -i -e "s/\&                :, :, isb))/\&                :, :, isb), dv%fna_52(:, :, isb))/g" b2tfnb_b.F90
sed -i -e 's/ISIZE1OFfchc/nFc/g' b2tinnt_b.F90
sed -i -e 's/ISIZE1OFcvbzb/nCv/g' b2tral_b.F90
sed -i -e 's/ISIZE1OFcvbb/nCv/g' b2trno_b.F90
sed -i -e 's/CHARACTER(len=\*) :: arg1/CHARACTER(len=20) :: arg1/g' b2usco_b.F90 b2usmo_b.F90
# FIXME
sed -i '/PUSHCHARACTERARRAY(name/d' b2usco_b.F90 b2usmo_b.F90 b2uspo_b.F90
sed -i '/POPCHARACTERARRAY(name/d' b2usco_b.F90 b2usmo_b.F90 b2uspo_b.F90
sed -i -e 's/DIMENSION(mpg%cvnvp(icv., 2))/DIMENSION(11)/g' b2usco_b.F90 b2usht_b.F90 b2usmo_b.F90 b2uspo_b.F90
# FIXME
#maybe TBC
sed -i -e "s/CALL PUSHREAL4(result1)/CALL PUSHREAL4ARRAY(result1, r8\/4)/g" b2usht_b.F90 
sed -i -e "s/CALL POPREAL4(result1)/CALL POPREAL4ARRAY(result1, r8\/4)/g" b2usht_b.F90
#maybe TBC
sed -i -e 's/ISIZE1OFarg1/20/g' calc_err_b.F90
sed -i -e 's/ISIZE1OFarg2/20/g' calc_err_b.F90
sed -i -e 's/LOGICAL :: arg1/LOGICAL :: arg1(m%nFc)/g' find_faces_b.F90

sed -i -e 's/PUBLIC :: to_struct_plasma_b,/PUBLIC :: /g' b2us_prep_diff.F90
sed -i '/PUBLIC :: to_struct_cell_b, to_struct_face_b/d' b2us_debug_diff.F90
sed -i -e 's/dealloc_b2mod_wall, dealloc_b2mod_wall_b/dealloc_b2mod_wall/g' b2mod_driver_diff.F90
sed -i -e 's/alloc_b2mod_balance_b, dealloc_b2mod_balance, dealloc_b2mod_balance_b,/dealloc_b2mod_balance,/g' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_eirene_sources, dealloc_b2mod_eirene_sources_b,/dealloc_b2mod_eirene_sources,/g' b2mod_driver_diff.F90
sed -i -e 's/run_av_get_plasma, run_av_get_plasma_b, run_av_save, run_av_save_b/run_av_get_plasma, run_av_save/g' b2mod_driver_diff.F90
sed -i -e 's/batch_av_all_init_b, batch_av_all_save, batch_av_all_fin, &/batch_av_all_save, batch_av_all_fin/g' b2mod_driver_diff.F90
sed -i '/& batch_av_all_fin_b/d' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_ysmp_sdrv, &/dealloc_b2mod_ysmp_sdrv/g' b2mod_driver_diff.F90
sed -i '/& dealloc_b2mod_ysmp_sdrv_b/d' b2mod_driver_diff.F90

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
sed -i '/EXTERNAL RESTART_MA28_FOR_US/d' b2news__b.F90 b2npmo_b.F90 b2usht_b.F90 
#sed -i '/PUBLIC :: read_mapping_b/d' b2us_map_diff.F90
sed -i '/EXTERNAL DEALLOC_B2MOD_MA28_FOR_US/d' b2mod_driver_diff.F90
sed -i -e 's/MSTEP_NODIFF/MSTEP/g' heatdiff1D_b.F90
sed -i -e 's/LINES2C_NODIFF/LINES2C/g' heatdiff1D_b.F90
sed -i '/EXTERNAL RWCDF/d' b2mod_mwti_diff.F90 
sed -i '/EXTERNAL B2CRTIMECDF/d' b2mod_mwti_diff.F90 
sed -i '/EXTERNAL CHECK_CDF_STATUS/d' b2mod_mwti_diff.F90 
sed -i '/EXTERNAL OR/d' b2mod_mwti_diff.F90 
sed -i '/INTEGER :: OR/d' b2mod_mwti_diff.F90 


sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_diff.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_diff.F90
sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_b.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_b.F90

#sed -i -e "/TYPE(B2RATESWORK_DIFF) :: rtw/i\      TYPE(B2DIAGNOSTIC) :: diag" b2us_plasma_diff.F90
#sed -i -e "/END TYPE MAPPING_DIFF/i\      INTEGER :: ncv, nfc, nvx, ncg, nci, ncmxvx, ncmxfc, nvmxcv, nvmxfc&" b2us_map_diff.F90
#sed -i -e "/END TYPE MAPPING_DIFF/i\&     , nfs, nbc, mxnbc, nrc, mxnrc, ncmxnv, ncf, mxncf" b2us_map_diff.F90
#sed -i -e "/END TYPE MAPPING_DIFF/i\      INTEGER :: nnreg(0:1)" b2us_map_diff.F90

cp $TAPENADEDIR/ADFirstAidKit/adContext.c .
cp $TAPENADEDIR/ADFirstAidKit/adContext.h .
cp $TAPENADEDIR/ADFirstAidKit/adStack.c .
cp $TAPENADEDIR/ADFirstAidKit/adStack.h .
cp $TAPENADEDIR/ADFirstAidKit/adBuffer.f adBuffer.F
cp $TAPENADEDIR/ADFirstAidKit/admm_tapenade_interface.f90 admm_tapenade_interface.F90
sed -i -e 's/USE ISO_C_BINDING/USE, intrinsic :: ISO_C_BINDING/g' admm_tapenade_interface.F90


