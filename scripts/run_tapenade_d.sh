cd $SOLPSTOP

gmake listobj
gmake depend
gmake b25

rm -r $SOLPSTOP/modules/B2.5/builds/differentiation
mkdir $SOLPSTOP/modules/B2.5/builds/differentiation
cd $SOLPSTOP/modules/B2.5/builds/differentiation

# $TAPENADEDIR/bin/tapenade -d -O . -head "b2mn_call_main(J)/(var)" `$SOLPSTOP/modules/B2.5/src/differentiation/collect_files.sh` -ext $SOLPSTOP/modules/B2.5/src/differentiation/solpsGeneralLib -html -context -java "-mx30g" -msglevel 30 >! tapenade.log

# all files are .f90 files, move them to .F90 extension
$SOLPSTOP/modules/B2.5/src/differentiation/move_to_F90.sh

$SOLPSTOP/modules/B2.5/src/differentiation/grab_files_d.sh

sed -i '/EXTERNAL RESTART_MA28_FOR_US/d' b2usht_d.F90 b2npmo_d.F90 b2news__d.F90
sed -i -e 's/ISIZE1OFgeo%vxonedbsq/nVx/g' b2sihs__d.F90
sed -i -e 's/ISIZE1OFgeo%cvonedbsq/nCv/g' b2sihs__d.F90
sed -i '/EXTERNAL DEALLOC_B2MOD_MA28_FOR_US/d' b2mod_driver_diff.F90

sed -i '/DIFFSIZES/d' ./*.F90 
sed -i -e 's/ISIZE1OFarg1/mpg%nCv/g' b2mod_driver_diff.F90 b2npmo_d.F90 b2stbr_phys_d.F90
sed -i -e 's/ISIZE1OFcvsahz_eff/nFc/g' b2stbr_phys_d.F90
sed -i -e 's/ISIZE2OFcvsahz_eff/0:1/g' b2stbr_phys_d.F90
sed -i -e 's/ISIZE1OFcvsahz/nFc/g' b2stbr_phys_d.F90
sed -i -e 's/ISIZE2OFcvsahz/0:1/g' b2stbr_phys_d.F90
sed -i -e 's/ISIZE1OFabs/mpg%nCv/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE2OFabs/0:state%pl%ns-1/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION() :: abs6/DIMENSION(mpg%nCv) :: abs6/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION() :: abs11/DIMENSION(mpg%nCv) :: abs11/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x1, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x2, 1), SIZE(x2, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x3, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x4, 1), SIZE(x4, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diff.F90
sed -i -e 's/ISIZE1OFtemp/nCv/g' b2news__d.F90 b2tfcc_d.F90 b2tfnb_d.F90 b2tqna_d.F90 b2xpic_d.F90
sed -i -e 's/ISIZE1OFdv%fch_pi_c/nCv/g' b2news__d.F90
sed -i -e 's/ISIZE1OFcvsa/nFc/g' b2npmo_d.F90
sed -i -e 's/ISIZE1OFresult1/nCv/g' b2npmo_d.F90
sed -i -e 's/ISIZE1OFcvhz/nCv/g' b2nxfv_d.F90
sed -i -e 's/ISIZE1OFfcqalf/nFc/g' b2sian_d.F90 b2stbc_d.F90 b2stbc_phys_d.F90 b2tfhe__d.F90 b2tfhi__d.F90 b2trno_d.F90
sed -i -e 's/ISIZE1OFcvvol/nCc/g' b2stbc_d.F90 
sed -i -e 's/ISIZE1OFcvbb/nCv/g' b2stbm_d.F90 b2tvspa_d.F90 b2tfnb_d.F90
sed -i -e 's/ISIZE1OFcdpa/nFC/g' b2tfcc_d.F90 b2tfnb_d.F90
sed -i -e 's/ISIZE1OFne/nCv/g' b2tfhe__d.F90 b2tfrn_d.F90
sed -i -e 's/ISIZE1OFni/nCv/g' b2tfhi__d.F90 
sed -i -e 's/ISIZE1OFcdna/nFc/g' b2tfnb_d.F90
sed -i -e 's/ISIZE1OFpa/nCv/g' b2tfnb_d.F90
sed -i -e 's/ISIZE1OFfna_52/nFc/g' b2tfnb_d.F90
sed -i -e 's/ISIZE1OFfchz/nFc/g' b2tfnb_d.F90
sed -i -e 's/ISIZE1OFfchc/nFc/g' b2tinnt_d.F90
sed -i -e 's/ISIZE1OFgeo%cvvol/nCv/g' b2stbc_d.F90
sed -i -e 's/ISIZE1OFdv%fna_52(:, :, isb)/nFc/g' b2tfnb_d.F90 
sed -i -e 's/ISIZE1OFcvbzb/nCv/g' b2tral_d.F90
sed -i -e 's/ISIZE1OFgeo%cvbb/nCv/g' b2xpve_d.F90 
sed -i -e 's/ISIZE1OFfceb/mpg%nFc/g' b2us_geo_diff.F90
sed -i -e 's/ISIZE1OFvxhz/nVx/g' b2nxfv_d.F90 
sed -i -e 's/= NULL()/= 0.0_R8/g' b2mod_driver_diff.F90
sed -i -e 's/=> NULL()/= 0.0_R8/g' ./*.F90

sed -i -e 's/PUBLIC :: to_struct_plasma_d,/PUBLIC :: /g' b2us_prep_diff.F90
sed -i '/PUBLIC :: read_mapping_d/d' b2us_map_diff.F90
sed -i '/REAL :: boundary/d' b2mod_boundary_namelist_diff.F90
sed -i '/REAL :: user/d' b2mod_user_namelist_diff.F90

sed -i -e 's/alloc_b2mod_balance_d, dealloc_b2mod_balance, dealloc_b2mod_balance_d,/dealloc_b2mod_balance,/g' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_eirene_sources, dealloc_b2mod_eirene_sources_d,/dealloc_b2mod_eirene_sources,/g' b2mod_driver_diff.F90
sed -i -e 's/run_av_get_plasma, run_av_get_plasma_d, run_av_save, run_av_save_d/run_av_get_plasma, run_av_save/g' b2mod_driver_diff.F90
sed -i -e 's/batch_av_all_init_d, batch_av_all_save, batch_av_all_fin, &/batch_av_all_save, batch_av_all_fin/g' b2mod_driver_diff.F90
sed -i '/& batch_av_all_fin_d/d' b2mod_driver_diff.F90

sed -i -e 's/CHARACTER(len=\*) :: arg1/CHARACTER(len=20) :: arg1/g' b2usco_d.F90
sed -i -e 's/CHARACTER(len=\*) :: arg10/CHARACTER(len=20) :: arg10/g' b2usmo_d.F90

cp $TAPENADEDIR/ADFirstAidKit/adContext.c .
cp $TAPENADEDIR/ADFirstAidKit/adContext.h .

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

sed -i -e 's/MSTEP_NODIFF/MSTEP/g' heatdiff1D_d.F90
sed -i -e 's/LINES2C_NODIFF/LINES2C/g' heatdiff1D_d.F90

$SOLPSTOP/modules/B2.5/src/differentiation/remove_allocation.sh

$SOLPSTOP/modules/B2.5/src/differentiation/substitute_allocation.sh

sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_diff.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_diff.F90

sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_d.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_d.F90

sed -i -e "/TYPE(B2RATESWORK_DIFF) :: rtw/i\      TYPE(B2DIAGNOSTIC) :: diag" b2us_plasma_diff.F90
sed -i -e 's/DIMENSION(:), DIMENSION(:), ALLOCATABLE :: text/DIMENSION(:), ALLOCATABLE :: text(:)/g' b2us_plasma_diff.F90
sed -i -e "/END TYPE MAPPING_DIFF/i\      INTEGER :: ncv, nfc, nvx, ncg, nci, ncmxvx, ncmxfc, nvmxcv, nvmxfc&" b2us_map_diff.F90
sed -i -e "/END TYPE MAPPING_DIFF/i\&     , nfs, nbc, mxnbc, nrc, mxnrc, ncmxnv, ncf, mxncf" b2us_map_diff.F90

sed -i -e "s/B2MNDR_2_D(nout, ns, geo, mpg, state, state_ext)/B2MNDR_2_D(nout, ns, geo, mpg, state, stated, state_ext)/g" b2mod_driver_diff.F90 b2mod_main_diff.F90
sed -i -e "/'03.002.000') CALL XERRAB(&/i\&       '03.002.000' .or. b2fdiffi_version .LT.&" b2mod_main_diff.F90

cp ../useful_wg/cond_coef.F .

#################### for restart

sed -i '/IF (ALLOCATED(ned)) ned = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(uadiad)) uadiad = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(ted)) ted = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(nad)) nad = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(uad)) uad = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(tid)) tid = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(pod)) pod = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fnad)) fnad = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fhed)) fhed = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fhid)) fhid = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fchd)) fchd = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fch_32d)) fch_32d = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fch_52d)) fch_52d = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fch_pd)) fch_pd = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(kinrgyd)) kinrgyd = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fna_mdfd)) fna_mdfd = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fhe_mdfd)) fhe_mdfd = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fhi_mdfd)) fhi_mdfd = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fna_fcord)) fna_fcord = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fna_nodriftd)) fna_nodriftd = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fna_hed)) fna_hed = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fnaPSchd)) fnaPSchd = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fhePSchd)) fhePSchd = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fhiPSchd)) fhiPSchd = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fna_eird)) fna_eird = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fne_eird)) fne_eird = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fhe_eird)) fhe_eird = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fhi_eird)) fhi_eird = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fna_32d)) fna_32d = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fna_52d)) fna_52d = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fni_32d)) fni_32d = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fni_52d)) fni_52d = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fne_32d)) fne_32d = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fne_52d)) fne_52d = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fchdiad)) fchdiad = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fchind)) fchind = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fchvispard)) fchvispard = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fchvisperd)) fchvisperd = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fchvisqd)) fchvisqd = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(fchinertd)) fchinertd = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(vaecrbd)) vaecrbd = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(vadiad)) vadiad = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(wadiad)) wadiad = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(veecrbd)) veecrbd = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(vediad)) vediad = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(floe_nocd)) floe_nocd = 0.0/d' b2mod_driver_diff.F90
sed -i '/IF (ALLOCATED(floi_nocd)) floi_nocd = 0.0/d' b2mod_driver_diff.F90

sed -i '/saved_cbsna_sold = 0.0/d' b2mod_driver_diff.F90
sed -i '/saved_cbsna_pfr2d = 0.0/d' b2mod_driver_diff.F90
sed -i '/saved_cbsna_pfr1d = 0.0/d' b2mod_driver_diff.F90
sed -i '/saved_cbsch_cored = 0.0/d' b2mod_driver_diff.F90
sed -i '/saved_cbsna_cored = 0.0/d' b2mod_driver_diff.F90
sed -i '/saved_cbshi_cored = 0.0/d' b2mod_driver_diff.F90
sed -i '/saved_cbshe_cored = 0.0/d' b2mod_driver_diff.F90
sed -i '/saved_na_feedback_actuatord = 0.0/d' b2mod_driver_diff.F90

## compile with context
cp $TAPENADEDIR/ADFirstAidKit/adContext.c .
cp $TAPENADEDIR/ADFirstAidKit/adContext.h .

## compile with debug
cp $TAPENADEDIR/ADFirstAidKit/adDebug.c .
cp $TAPENADEDIR/ADFirstAidKit/adStack.c .
cp $TAPENADEDIR/ADFirstAidKit/adStack.h .

cd $SOLPSTOP
setenv DIFF_D yes
gmake listobj
gmake depend
gmake b25_diff_d


