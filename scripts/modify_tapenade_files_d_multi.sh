
# all files are .f90 files, move them to .F90 extension
move_to_F90.sh
rm b2uxus_dv.F90
collect_nodiff_d_multi.sh

mv b2mn_dv.F90 b2mn_d.F90

sed -i "/INCLUDE 'DIFFSIZES.inc'/d" ./*.F90
sed -i "/USE DIFFSIZES/d" ./*.F90
sed -i -e "/IMPLICIT NONE/i\  USE DIFFSIZES" ./*.F90

sed -i -e 's/ISIZE1OFfceb/mpg%nFc/g' b2us_geo_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x1, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x2, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x3, 1), SIZE(x3, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x4, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x5, 1), SIZE(x5, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diffv.F90
sed -i -e 's/ISIZE1OFarg1/mpg%nCv/g' b2mod_driver_diffv.F90 b2npmo_dv.F90 b2stbr_phys_dv.F90 b2tqna_dv.F90 eirene_f30f31_dv.F90 b2mod_recycle_diffv.F90
sed -i -e 's/ISIZE1OFabs/mpg%nCv/g' b2mod_driver_diffv.F90
sed -i -e 's/ISIZE2OFabs/0:state%pl%ns-1/g' b2mod_driver_diffv.F90
sed -i -e "s/REAL(r8), DIMENSION(:,/REAL(r8), DIMENSION(nbdirsmax,/g" b2news__dv.F90
sed -i -e 's/ISIZE1OFdv%fch_pi_c/nCv/g' b2news__dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd0/INTEGER :: dummyzerodiffd0(nbdirsmax)/g" b2mod_recycle_diffv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd29/INTEGER :: dummyzerodiffd29(nbdirsmax)/g" b2news__dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd33/INTEGER :: dummyzerodiffd33(nbdirsmax)/g" b2news__dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd37/INTEGER :: dummyzerodiffd37(nbdirsmax)/g" b2news__dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd54/INTEGER :: dummyzerodiffd54(nbdirsmax)/g" b2news__dv.F90
sed -i -e 's/ISIZE1OFtemp/nCv/g' b2news__dv.F90 b2tfcc_dv.F90 b2tfnb_dv.F90 b2tqna_dv.F90 b2xpic_dv.F90
sed -i -e 's/ISIZE1OFcvsa/nFc/g' b2npmo_dv.F90
sed -i -e 's/ISIZE1OFresult1/nCv/g' b2npmo_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd10/INTEGER :: dummyzerodiffd10(nbdirsmax)/g" b2npmo_dv.F90 
sed -i -e "s/INTEGER :: dummyzerodiffd14/INTEGER :: dummyzerodiffd14(nbdirsmax)/g" b2npmo_dv.F90
sed -i -e 's/ISIZE1OFcvhz/nCv/g' b2nxfv_dv.F90
sed -i -e 's/ISIZE1OFvxhz/nVx/g' b2nxfv_dv.F90
sed -i -e 's/ISIZE1OFfcqalf/nFc/g' b2sian_dv.F90 b2stbc_dv.F90 b2stbc_phys_dv.F90 b2tfhe__dv.F90 b2tfhi__dv.F90 b2trno_dv.F90 b2tfch__dv.F90 b2tfnb_dv.F90 b2tinnt_dv.F90
sed -i -e 's/ISIZE1OFgeo%vxonedbsq/nVx/g' b2sihs__dv.F90
sed -i -e 's/ISIZE1OFgeo%cvonedbsq/nCv/g' b2sihs__dv.F90
sed -i -e "s/REAL(kind=r8), DIMENSION(:,/REAL(kind=r8), DIMENSION(nbdirsmax,/g" b2sihs__dv.F90 b2stbc_dv.F90
sed -i -e 's/ISIZE1OFgeo%cvvol/nCv/g' b2stbc_dv.F90
sed -i -e 's/ISIZE1OFcvbb/nCv/g' b2stbm_dv.F90 b2tfnb_dv.F90 b2tqna_dv.F90 b2tvspa_dv.F90 b2sikt_dv.F90 b2trno_dv.F90
sed -i -e 's/ISIZE1OFcvsahz_eff/nFc/g' b2stbr_phys_dv.F90 b2mod_recycle_diffv.F90
sed -i -e 's/ISIZE2OFcvsahz_eff/0:1/g' b2stbr_phys_dv.F90 b2mod_recycle_diffv.F90
sed -i -e 's/ISIZE1OFcvsahz/nFc/g' b2stbr_phys_dv.F90 b2mod_recycle_diffv.F90
sed -i -e 's/ISIZE2OFcvsahz/0:1/g' b2stbr_phys_dv.F90 b2mod_recycle_diffv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd0/INTEGER :: dummyzerodiffd0(nbdirsmax)/g" b2stbr_phys_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd4/INTEGER :: dummyzerodiffd4(nbdirsmax)/g" b2stbr_phys_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd6/INTEGER :: dummyzerodiffd6(nbdirsmax)/g" b2stbr_phys_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd1/INTEGER :: dummyzerodiffd1(nbdirsmax)/g" b2tanml_dv.F90
sed -i -e 's/ISIZE1OFcdpa/nFC/g' b2tfcc_dv.F90 b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFne/nCv/g' b2tfhe__dv.F90 b2tfrn_dv.F90
sed -i -e 's/ISIZE1OFni/nCv/g' b2tfhi__dv.F90 
sed -i -e 's/ISIZE1OFcdna/nFc/g' b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFfchz/nFc/g' b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFpa/nCv/g' b2tfnb_dv.F90
sed -i -e 's/DIMENSION(:, ISIZE1OFdv%fna_52(:, :, isb), 0:1)/DIMENSION(nbdirsmax, nFc, 0:1)/g' b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFfchc/nFc/g' b2tinnt_dv.F90
sed -i -e "s/cfdna(0, is), cfdnad(:, 0, is)/cfdna(0, is), cfdnad(1:nbdirs, 0, is)/g" b2tqna_dv.F90
sed -i -e "s/cfhci(0, is), cfhcid(:, 0, is)/cfhci(0, is), cfhcid(1:nbdirs, 0, is)/g" b2tqna_dv.F90
sed -i -e 's/ISIZE1OFcvbzb/nCv/g' b2tral_dv.F90
sed -i -e 's/CHARACTER(len=\*) :: arg1/CHARACTER(len=20) :: arg1/g' b2usco_dv.F90
sed -i -e 's/CHARACTER(len=\*) :: arg10/CHARACTER(len=20) :: arg10/g' b2usmo_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd1/INTEGER :: dummyzerodiffd1(nbdirsmax)/g" b2xpve_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd4/INTEGER :: dummyzerodiffd4(nbdirsmax)/g" b2xpve_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd7/INTEGER :: dummyzerodiffd7(nbdirsmax)/g" b2xpve_dv.F90
sed -i -e 's/ISIZE1OFarg1/20/g' calc_err_dv.F90
sed -i -e 's/ISIZE1OFarg2/20/g' calc_err_dv.F90
sed -i -e 's/REAL :: result1$/integer :: result1/g' b2mod_input_profile_diffv.F90

sed -i '/EXTERNAL RESTART_MA28_FOR_US/d' b2news__dv.F90 b2npmo_dv.F90 b2usht_dv.F90  
sed -i '/EXTERNAL DEALLOC_B2MOD_MA28_FOR_US/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL ISGHOSTCELL/d' b2us_prep_diffv.F90 
sed -i '/LOGICAL :: ISGHOSTCELL/d' b2us_prep_diffv.F90
sed -i '/EXTERNAL ISREALCELL/d' b2us_prep_diffv.F90 
sed -i '/LOGICAL :: ISREALCELL/d' b2us_prep_diffv.F90 
sed -i '/EXTERNAL ISBOUNDARYCELL/d' b2us_prep_diffv.F90
sed -i '/LOGICAL :: ISBOUNDARYCELL/d' b2us_prep_diffv.F90
sed -i '/EXTERNAL ISUNUSEDCELL/d' b2us_prep_diffv.F90 
sed -i '/LOGICAL :: ISUNUSEDCELL/d' b2us_prep_diffv.F90 
sed -i '/EXTERNAL ISCLASSICALGRID/d' b2us_prep_diffv.F90 
sed -i '/LOGICAL :: ISCLASSICALGRID/d' b2us_prep_diffv.F90 
sed -i -e 's/MSTEP_NODIFF/MSTEP/g' heatdiff1D_dv.F90
sed -i -e 's/LINES2C_NODIFF/LINES2C/g' heatdiff1D_dv.F90
sed -i '/EXTERNAL RWCDF/d' b2mod_mwti_diffv.F90 
sed -i '/EXTERNAL B2CRTIMECDF/d' b2mod_mwti_diffv.F90 
sed -i '/EXTERNAL CHECK_CDF_STATUS/d' b2mod_mwti_diffv.F90 
sed -i '/EXTERNAL OR/d' b2mod_mwti_diffv.F90 
sed -i '/INTEGER :: OR/d' b2mod_mwti_diffv.F90 
sed -i -e 's/B2UXUS_NODIFF/B2UXUS/g' b2usco_dv.F90 b2usmo_dv.F90 b2usht_dv.F90 b2uspo_dv.F90

sed -i -e 's/PUBLIC :: to_struct_plasma_dv,/PUBLIC :: /g' b2us_prep_diffv.F90
sed -i '/PUBLIC :: to_struct_cell_dv, to_struct_face_dv/d' b2us_debug_diffv.F90
sed -i -e 's/alloc_b2mod_balance_dv, dealloc_b2mod_balance/dealloc_b2mod_balance/g' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_b2mod_balance_dv, dealloc_b2mod_eirene_sources/dealloc_b2mod_eirene_sources/g' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_b2mod_eirene_sources_dv, balance_average/balance_average/g' b2mod_driver_diffv.F90
sed -i -e 's/run_av_get_plasma, run_av_get_plasma_dv, run_av_save, run_av_save_dv/run_av_get_plasma, run_av_save/g' b2mod_driver_diffv.F90
sed -i -e 's/batch_av_all_init_dv, batch_av_all_save, batch_av_all_fin, &/batch_av_all_save, batch_av_all_fin/g' b2mod_driver_diffv.F90
sed -i '/& batch_av_all_fin_dv/d' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_b2mod_wall, dealloc_b2mod_wall_dv/dealloc_b2mod_wall/g' b2mod_driver_diffv.F90
sed -i -e 's/ONLY : dealloc_b2mod_ysmp_sdrv, &/ONLY : dealloc_b2mod_ysmp_sdrv/g' b2mod_driver_diffv.F90
sed -i '/& dealloc_b2mod_ysmp_sdrv_dv/d' b2mod_driver_diffv.F90

sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_diffv.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_diffv.F90
sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_dv.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_dv.F90

sed -i -e "/END TYPE MAPPING_DIFFV/i\      INTEGER :: ncv(nbdirsmax), nfc(nbdirsmax), nvx(nbdirsmax), ncg(nbdirsmax), &" b2us_map_diffv.F90
sed -i -e "/END TYPE MAPPING_DIFFV/i\&     nci(nbdirsmax), ncmxvx(nbdirsmax), ncmxfc(nbdirsmax), nvmxcv(nbdirsmax), nvmxfc(nbdirsmax),&" b2us_map_diffv.F90
sed -i -e "/END TYPE MAPPING_DIFFV/i\&     nfs(nbdirsmax), nbc(nbdirsmax), mxnbc(nbdirsmax), nrc(nbdirsmax), mxnrc(nbdirsmax),&" b2us_map_diffv.F90
sed -i -e "/END TYPE MAPPING_DIFFV/i\&     ncmxnv(nbdirsmax), ncf(nbdirsmax), mxncf(nbdirsmax)" b2us_map_diffv.F90

sed -i -e "/TYPE(B2RATESWORK_DIFFV) :: rtw/i\      TYPE(B2DIAGNOSTIC) :: diag" b2us_plasma_diffv.F90

sed -i -e "s/b2mod_main_diff/b2mod_main_diffv/g" b2optim_*.F*
sed -i -e "s/b2mn_init_d/b2mn_init_dv/g" b2optim_*.F*
sed -i -e "s/b2mn_fin_d/b2mn_fin_dv/g" b2optim_*.F*
sed -i -e "s/b2mn_step_d/b2mn_step_dv/g" b2optim_*.F*
sed -i -e "s/b2mod_user_namelist_diff/b2mod_user_namelist_diffv/g" b2optim_*.F*
sed -i -e "s/b2mod_plasma_diff/b2mod_plasma_diffv/g" b2optim_*.F*
sed -i -e "s/call b2mn_init_dv/call b2mn_init_dv(nvar)/g" b2optim_*.F*
sed -i -e "s/call b2mn_fin_dv/call b2mn_fin_dv(nvar)/g" b2optim_*.F*
sed -i -e "s/call b2mn_step_dv(j,jd)/call b2mn_step_dv(j,jd,nvar)/g" b2optim_ipopt.F
sed -i -e "s/call b2mn_step_dv(j,jd)/call b2mn_step_dv(j,jd,nnvar)/g" b2optim_tao.F90
sed -i -e 's/jd(nncf)/jd(nbdirsmax,nncf)/g' b2optim_*.F*
sed -i -e "/subroutine EV_GRAD_F(/a\      use diffsizes" b2optim_ipopt.F
sed -i -e "/subroutine FormFunctionGradient(/a\      use diffsizes" b2optim_tao.F90
sed -i -e "s/g_v(g_i+iv-1) = jd(1)/g_v(g_i+iv-1) = jd(iv,1)/g" b2optim_tao.F90
sed -i -e "s/grad(iv) = DBLE(jd(1))/grad(iv) = DBLE(jd(iv,1))/g" b2optim_ipopt.F

cp $TAPENADEDIR/ADFirstAidKit/adContext.c .
cp $TAPENADEDIR/ADFirstAidKit/adContext.h .

