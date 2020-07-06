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

$SOLPSTOP/modules/B2.5/src/differentiation/grab_files_d_multi.sh

mv b2mn_dv.F90 b2mn_d.F90

sed -i "/INCLUDE 'DIFFSIZES.inc'/d" ./*.F90
sed -i "/USE DIFFSIZES/d" ./*.F90
sed -i -e "/IMPLICIT NONE/i\      USE DIFFSIZES" ./*.F90
sed -i -e "/END TYPE MAPPING_DIFFV/i\      INTEGER :: ncv(nbdirsmax), nfc(nbdirsmax), nvx(nbdirsmax), ncg(nbdirsmax), &" b2us_map_diffv.F90
sed -i -e "/END TYPE MAPPING_DIFFV/i\&     nci(nbdirsmax), ncmxvx(nbdirsmax), ncmxfc(nbdirsmax), nvmxcv(nbdirsmax), nvmxfc(nbdirsmax),&" b2us_map_diffv.F90
sed -i -e "/END TYPE MAPPING_DIFFV/i\&     nfs(nbdirsmax), nbc(nbdirsmax), mxnbc(nbdirsmax), nrc(nbdirsmax), mxnrc(nbdirsmax),&" b2us_map_diffv.F90
sed -i -e "/END TYPE MAPPING_DIFFV/i\&     ncmxnv(nbdirsmax), ncf(nbdirsmax), mxncf(nbdirsmax)" b2us_map_diffv.F90

sed -i -e 's/ISIZE1OFfceb/mpg%nFc/g' b2us_geo_diffv.F90
sed -i -e 's/PUBLIC :: to_struct_plasma_dv,/PUBLIC :: /g' b2us_prep_diffv.F90
sed -i -e 's/alloc_b2mod_balance_dv, dealloc_b2mod_balance/dealloc_b2mod_balance/g' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_b2mod_balance_dv, dealloc_b2mod_eirene_sources/dealloc_b2mod_eirene_sources/g' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_b2mod_eirene_sources_dv, balance_average/balance_average/g' b2mod_driver_diffv.F90
sed -i -e 's/run_av_get_plasma, run_av_get_plasma_dv, run_av_save, run_av_save_dv/run_av_get_plasma, run_av_save/g' b2mod_driver_diffv.F90
sed -i -e 's/batch_av_all_init_dv, batch_av_all_save, batch_av_all_fin, &/batch_av_all_save, batch_av_all_fin/g' b2mod_driver_diffv.F90
sed -i '/& batch_av_all_fin_dv/d' b2mod_driver_diffv.F90

sed -i -e 's/DIMENSION(SIZE(x1, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x2, 1), SIZE(x2, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x3, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x4, 1), SIZE(x4, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diffv.F90

sed -i -e 's/=> NULL()/= 0.0_R8/g' ./*.F90

sed -i '/EXTERNAL RESTART_MA28_FOR_US/d' b2usht_dv.F90 b2npmo_dv.F90 b2news__dv.F90
sed -i -e 's/ISIZE1OFarg1/mpg%nCv/g' b2mod_driver_diffv.F90 b2npmo_dv.F90 b2stbr_phys_dv.F90 b2tqna_dv.F90 eirene_f30f31_dv.F90
sed -i -e 's/ISIZE1OFabs/mpg%nCv/g' b2mod_driver_diffv.F90
sed -i -e 's/ISIZE2OFabs/0:state%pl%ns-1/g' b2mod_driver_diffv.F90
sed -i -e 's/ISIZE1OFdv%fch_pi_c/nCv/g' b2news__dv.F90
sed -i -e 's/ISIZE1OFtemp/nCv/g' b2news__dv.F90 b2tfcc_dv.F90 b2tfnb_dv.F90 b2tqna_dv.F90 b2xpic_dv.F90
sed -i -e 's/ISIZE1OFcvsahz_eff/nFc/g' b2stbr_phys_dv.F90
sed -i -e 's/ISIZE2OFcvsahz_eff/0:1/g' b2stbr_phys_dv.F90
sed -i -e 's/ISIZE1OFcvsahz/nFc/g' b2stbr_phys_dv.F90
sed -i -e 's/ISIZE2OFcvsahz/0:1/g' b2stbr_phys_dv.F90
sed -i -e 's/ISIZE1OFcvsa/nFc/g' b2npmo_dv.F90
sed -i -e 's/ISIZE1OFresult1/nCv/g' b2npmo_dv.F90
sed -i -e 's/ISIZE1OFcvhz/nCv/g' b2nxfv_dv.F90
sed -i -e 's/ISIZE1OFvxhz/nVx/g' b2nxfv_dv.F90 
sed -i -e 's/ISIZE1OFfcqalf/nFc/g' b2sian_dv.F90 b2stbc_dv.F90 b2stbc_phys_dv.F90 b2tfhe__dv.F90 b2tfhi__dv.F90 b2trno_dv.F90
sed -i -e 's/ISIZE1OFgeo%vxonedbsq/nVx/g' b2sihs__dv.F90
sed -i -e 's/ISIZE1OFgeo%cvonedbsq/nCv/g' b2sihs__dv.F90
sed -i -e 's/ISIZE1OFcvvol/nCc/g' b2stbc_dv.F90 
sed -i -e 's/ISIZE1OFgeo%cvvol/nCv/g' b2stbc_dv.F90
sed -i -e 's/ISIZE1OFcvbb/nCv/g' b2stbm_dv.F90 b2tvspa_dv.F90 b2tfnb_dv.F90 b2tqna_dv.F90
sed -i -e 's/ISIZE1OFcdpa/nFC/g' b2tfcc_dv.F90 b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFne/nCv/g' b2tfhe__dv.F90 b2tfrn_dv.F90
sed -i -e 's/ISIZE1OFni/nCv/g' b2tfhi__dv.F90 
sed -i -e 's/ISIZE1OFcdna/nFc/g' b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFpa/nCv/g' b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFfchz/nFc/g' b2tfnb_dv.F90
sed -i -e 's/DIMENSION(:, ISIZE1OFdv%fna_52(:, :, isb), 0:1)/DIMENSION(nbdirsmax, nFc, 0:1)/g' b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFfchc/nFc/g' b2tinnt_dv.F90
sed -i -e 's/ISIZE1OFcvbzb/nCv/g' b2tral_dv.F90
sed -i -e 's/DIMENSION(:, ISIZE1OFgeo%cvbb, 0:3)/DIMENSION(nbdirsmax, nCv, 0:3)/g' b2xpve_dv.F90 

sed -i -e 's/CHARACTER(len=\*) :: arg1/CHARACTER(len=20) :: arg1/g' b2usco_dv.F90
sed -i -e 's/CHARACTER(len=\*) :: arg10/CHARACTER(len=20) :: arg10/g' b2usmo_dv.F90

cp $TAPENADEDIR/ADFirstAidKit/adContext.c .
cp $TAPENADEDIR/ADFirstAidKit/adContext.h .
cp ../useful_wg/cond_coef.F .

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
sed -i '/EXTERNAL DEALLOC_B2MOD_MA28_FOR_US/d' b2mod_driver_diffv.F90
sed -i -e 's/LINES2C_NODIFF/LINES2C/g' heatdiff1D_dv.F90
#sed -i '/EXTERNAL ERF_DV/d' b2mod_recycle_diffv.F90 

sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_diffv.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_diffv.F90

sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_dv.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_dv.F90

$SOLPSTOP/modules/B2.5/src/differentiation/substitute_allocation_v.sh
sed -i -e "/TYPE(B2RATESWORK_DIFFV) :: rtw/i\      TYPE(B2DIAGNOSTIC) :: diag" b2us_plasma_diffv.F90
sed -i -e "/CALL B2MN_INIT_DV(nbdirs)/i\  nbdirs = 5" b2mn_d.F90
sed -i -e 's/DIMENSION(:), DIMENSION(:, :), ALLOCATABLE :: text/DIMENSION(:, :), ALLOCATABLE :: text/g' b2us_plasma_diff.F90

sed -i -e "s/POINTER/ALLOCATABLE/g" b2us_*

sed -i -e "s/REAL(kind=r8), DIMENSION(:,/REAL(kind=r8), DIMENSION(nbdirsmax,/g" b2sihs__dv.F90 b2stbc_dv.F90
sed -i -e "s/REAL(r8), DIMENSION(:,/REAL(r8), DIMENSION(nbdirsmax,/g" b2news__dv.F90

sed -i -e "s/INTEGER :: dummyzerodiffd27/INTEGER :: dummyzerodiffd27(nbdirsmax)/g" b2news__dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd31/INTEGER :: dummyzerodiffd31(nbdirsmax)/g" b2news__dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd36/INTEGER :: dummyzerodiffd36(nbdirsmax)/g" b2news__dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd38/INTEGER :: dummyzerodiffd38(nbdirsmax)/g" b2news__dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd57/INTEGER :: dummyzerodiffd57(nbdirsmax)/g" b2news__dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd10/INTEGER :: dummyzerodiffd10(nbdirsmax)/g" b2npmo_dv.F90 
sed -i -e "s/INTEGER :: dummyzerodiffd14/INTEGER :: dummyzerodiffd14(nbdirsmax)/g" b2npmo_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd0/INTEGER :: dummyzerodiffd0(nbdirsmax)/g" b2stbr_phys_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd4/INTEGER :: dummyzerodiffd4(nbdirsmax)/g" b2stbr_phys_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd6/INTEGER :: dummyzerodiffd6(nbdirsmax)/g" b2stbr_phys_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd1/INTEGER :: dummyzerodiffd1(nbdirsmax)/g" b2tanml_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd2/INTEGER :: dummyzerodiffd2(nbdirsmax)/g" b2xpve_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd5/INTEGER :: dummyzerodiffd5(nbdirsmax)/g" b2xpve_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd8/INTEGER :: dummyzerodiffd8(nbdirsmax)/g" b2xpve_dv.F90

sed -i -e "s/cfdnad(:, 0, is), nbdirs)/cfdnad(nbdirs, 0, is), nbdirs)/g" b2tqna_dv.F90
sed -i -e "s/cfhcid(:, 0, is), nbdirs)/cfhcid(nbdirs, 0, is), nbdirs)/g" b2tqna_dv.F90






sed -i -e 's/DIMENSION() :: abs6/DIMENSION(mpg%nCv) :: abs6/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION() :: abs11/DIMENSION(mpg%nCv) :: abs11/g' b2mod_driver_diff.F90

sed -i -e 's/= NULL()/= 0.0_R8/g' b2mod_driver_diff.F90


$SOLPSTOP/modules/B2.5/src/differentiation/remove_allocation.sh


## compile with debug
cp $TAPENADEDIR/ADFirstAidKit/adDebug.c .
cp $TAPENADEDIR/ADFirstAidKit/adStack.c .
cp $TAPENADEDIR/ADFirstAidKit/adStack.h .

cd $SOLPSTOP
setenv DIFF_D yes
gmake listobj
gmake depend
gmake b25_diff_d


