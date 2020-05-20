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
rm b2mod_ual_io_grid_p.F90

$SOLPSTOP/modules/B2.5/src/differentiation/grab_files_p.sh
mv b2mn_p.F90 b2mn_d.F90
mv logging_p.F90 logging.F90
mv tradui_constants_p.F90 tradui_constants.F90
mv carre_constants_p.F90 carre_constants.F90 
mv b2ag_ghostcells_p.F90 b2ag_ghostcells.F90
mv carre_b2ag_p.F90 carre_b2ag.F90


sed -i '/EXTERNAL ISUNUSEDCELL/d' b2xgbs_p.F90 b2xvsg_p.F90 b2mod_grid_mapping.F90
sed -i '/LOGICAL :: ISUNUSEDCELL/d' b2xgbs_p.F90 b2xvsg_p.F90 b2mod_grid_mapping.F90
sed -i '/EXTERNAL ISINDOMAIN/d' b2xgbs_p.F90
sed -i '/LOGICAL :: ISINDOMAIN/d' b2xgbs_p.F90
sed -i '/EXTERNAL ISGHOSTCELL/d' b2us_prep.F90 b2mod_indirect.F90 b2mod_grid_mapping.F90
sed -i '/LOGICAL :: ISGHOSTCELL/d' b2us_prep.F90 b2mod_indirect.F90 b2mod_grid_mapping.F90
sed -i '/EXTERNAL ISREALCELL/d' b2us_prep.F90 b2mod_indirect.F90
sed -i '/LOGICAL :: ISREALCELL/d' b2us_prep.F90 b2mod_indirect.F90
sed -i '/EXTERNAL ISBOUNDARYCELL/d' b2us_prep.F90
sed -i '/LOGICAL :: ISBOUNDARYCELL/d' b2us_prep.F90
sed -i '/EXTERNAL ISUNUSEDCELL/d' b2us_prep.F90 b2mod_geo2.F90
sed -i '/LOGICAL :: ISUNUSEDCELL/d' b2us_prep.F90 b2mod_geo2.F90
sed -i '/EXTERNAL ISCLASSICALGRID/d' b2us_prep.F90 b2mod_geo.F90
sed -i '/LOGICAL :: ISCLASSICALGRID/d' b2us_prep.F90 b2mod_geo.F90
sed -i '/EXTERNAL ISINDOMAIN/d' b2mod_indirect.F90
sed -i '/LOGICAL :: ISINDOMAIN/d' b2mod_indirect.F90
sed -i '/EXTERNAL INT2STR/d' b2mod_grid_mapping.F90
sed -i '/CHARACTER :: INT2STR/d' b2mod_grid_mapping.F90

sed -i -e "s/MSTEP_NODIFF/MSTEP/g" ./heatdiff1D_d.F90
sed -i -e "s/LINES2C_NODIFF/LINES2C/g" ./heatdiff1D_d.F90

## compile with context
cp $TAPENADEDIR/ADFirstAidKit/adContext.c .
cp $TAPENADEDIR/ADFirstAidKit/adContext.h .



# dealing with wrong use of b2mod_cdf_d
sed -i '/EXTERNAL WRITE_CDF_/d' *.F90
sed -i '/EXTERNAL RWCDF/d' *.F90
sed -i '/EXTERNAL DEFINE_CDF_B2MOD_/d' *.F90
sed -i '/EXTERNAL B2CRTIMECDF/d' *.F90

# dealing with ids routines (only for TAPENADE 3.14)
rm b2mod_cellhelper_d.F90 b2mod_connectivity_d.F90 b2mod_grid_mapping_d.F90 b2mod_interp_d.F90 b2mod_ual_io_data_d.F90 b2mod_ual_io_d.F90 b2mod_ual_io_grid_d.F90 logging_d.F90
sed -i -e 's/USE B2MOD_GRID_MAPPING_DIFF/USE B2MOD_GRID_MAPPING/g' *.F90
sed -i -e 's/USE B2MOD_CONNECTIVITY_DIFF/USE B2MOD_CONNECTIVITY/g' *.F90
sed -i -e 's/USE B2MOD_CELLHELPER_DIFF/USE B2MOD_CELLHELPER/g' *.F90
sed -i -e 's/USE LOGGING_DIFF/USE LOGGING/g' *.F90

# Modify some calls which use 0.0 instead of 0.0_R8
sed -i -e 's/ev, 0.0, zb/ev, 0.0_R8, zb/g' b2mod_sputter_d.F90
sed -i -e 's/0.0, NINT(zn(is))/0.0_R8, NINT(zn(is))/g' b2mod_sputter_d.F90
sed -i -e 's/0.0_R8/0.0/g' b2stbr_phys_d.F90
sed -i -e 's/0.0/0.0_R8/g' b2stbr_phys_d.F90

# Remove definitions of intrinsic "dim"
sed -i '/\<EXTERNAL DIM\>/d' ./*.F90
sed -i '/\<REAL(kind=r8) :: DIM\>/d' ./*.F90
sed -i '/\<REAL :: DIM\>/d' ./*.F90

# Modify not accepted string treatment for my_output quantities
sed -i -e 's/CHARACTER(len=\*) :: arg10/CHARACTER(len=20) :: arg10/g' b2usc9_d.F90
sed -i -e 's/CHARACTER(len=\*) :: arg10/CHARACTER(len=20) :: arg10/g' b2usco_d.F90
sed -i -e 's/CHARACTER(len=\*) :: arg10/CHARACTER(len=20) :: arg10/g' b2usht_d.F90
sed -i -e 's/CHARACTER(len=\*) :: arg10/CHARACTER(len=20) :: arg10/g' b2usm9_d.F90
sed -i -e 's/CHARACTER(len=\*) :: arg11/CHARACTER(len=20) :: arg11/g' b2usmo_d.F90

# Remove use my_out_d and my_outi_d, ipgetr_d e ipgeti_d
rm ipgetr_d.F90 ipgeti_d.F90 my_out_d.F90 my_outi_d.f
sed -i -e "s/CALL MY_OUT_NODIFF/call my_out/g" ./*
sed -i -e "s/CALL MY_OUTI_NODIFF/call my_outi/g" ./*
sed -i -e "s/IPGETR_NODIFF/ipgetr/g" ./*
sed -i -e "s/IPGETI_NODIFF/ipgeti/g" ./*


# grab the files that have been ignored by the differentiation but are needed for compiling the program
# and also modify the various 'use b2mod_' if the module has been differentiated
$SOLPSTOP/modules/B2.5/src/differentiation/grab_files_p.sh
mv b2mn_p.F90 b2mn_d.F90
mv logging_p.F90 logging.F90
mv tradui_constants_p.F90 tradui_constants.F90
mv carre_constants_p.F90 carre_constants.F90 
mv b2ag_ghostcells_p.F90 b2ag_ghostcells.F90
mv carre_b2ag_p.F90 carre_b2ag.F90

$SOLPSTOP/modules/B2.5/src/differentiation/correct_r8.sh

# Other wrong differentiation output
sed -i -e 's/EXTERNAL SUBINI, SUBEND, XERTST, ipgeti, BATCH_AVERAGE/EXTERNAL XERTST, ipgeti, BATCH_AVERAGE/g' b2mod_mwti_diff.F90
sed -i '/USE DIFFSIZES/d' calc_err_d.F90
sed -i -e 's/CHARACTER(len=ISIZE1OFarg1)/CHARACTER(len=20)/g' calc_err_d.F90
sed -i -e 's/REAL(kind=r8), DIMENSION(ISIZE1OFarg1, ISIZE2OFarg1) :: arg14/REAL(kind=r8), DIMENSION(-1:nx,-1:ny) :: arg14/g' b2mod_driver_diff.F90
sed -i -e 's/REAL(kind=r8), DIMENSION(ISIZE1OFarg1, ISIZE2OFarg1) :: arg15/REAL(kind=r8), DIMENSION(-1:nx,-1:ny) :: arg15/g' b2mod_driver_diff.F90
sed -i '/USE DIFFSIZES/d' b2mod_driver_diff.F90
sed -i -e 's/USE B2MOD_SOURCES_DIFF, ONLY : write_b2mod_sources, &/USE B2MOD_SOURCES_DIFF, ONLY : write_b2mod_sources/g' b2mod_driver_diff.F90
sed -i '/& write_b2mod_sources_d/d' b2mod_driver_diff.F90
sed -i -e 's/write_b2mod_sputter_namelist_d, dealloc_sputter_data,/dealloc_sputter_data,/g' b2mod_driver_diff.F90
sed -i -e 's/dealloc_sputter_data_d, dealloc_b2mod_sputter, dealloc_b2mod_sputter_d/dealloc_b2mod_sputter/g' b2mod_driver_diff.F90
sed -i -e 's/USE B2MOD_RECYCLE_DIFF, ONLY : dealloc_recycle_fnn, &/USE B2MOD_RECYCLE_DIFF, ONLY : dealloc_recycle_fnn/g' b2mod_driver_diff.F90
sed -i '/& dealloc_recycle_fnn_d/d' b2mod_driver_diff.F90
sed -i -e 's/USE B2MOD_YSMP_SDRV_DIFF, ONLY : dealloc_b2mod_ysmp_sdrv, &/USE B2MOD_YSMP_SDRV_DIFF, ONLY : dealloc_b2mod_ysmp_sdrv/g' b2mod_driver_diff.F90
sed -i '/& dealloc_b2mod_ysmp_sdrv_d/d' b2mod_driver_diff.F90
sed -i -e 's/USE B2MOD_MA28_FOR_7DIAG_DIFF, ONLY : dealloc_b2mod_ma28_for_7diag, &/USE B2MOD_MA28_FOR_7DIAG_DIFF, ONLY : dealloc_b2mod_ma28_for_7diag/g' b2mod_driver_diff.F90
sed -i '/& dealloc_b2mod_ma28_for_7diag_d/d' b2mod_driver_diff.F90
sed -i -e 's/batch_av_all_init_d, batch_av_all_save, batch_av_all_fin, &/batch_av_all_save, batch_av_all_fin/g' b2mod_driver_diff.F90
sed -i '/& batch_av_all_fin_d/d' b2mod_driver_diff.F90
sed -i -e 's/USE B2MOD_RUNNING_AVERAGE_DIFF, ONLY : run_av_init, run_av_init_d,/USE B2MOD_RUNNING_AVERAGE_DIFF, ONLY : run_av_init,/g' b2mod_driver_diff.F90
sed -i -e 's/run_av_get_plasma, run_av_get_plasma_d, run_av_save, run_av_save_d,/run_av_get_plasma, run_av_save,/g' b2mod_driver_diff.F90
sed -i -e 's/run_av_fin, run_av_fin_d/run_av_fin/g' b2mod_driver_diff.F90
sed -i -e 's/USE B2MOD_BALANCE_DIFF, ONLY : write_balance, write_balance_d,/USE B2MOD_BALANCE_DIFF, ONLY : write_balance,/g' b2mod_driver_diff.F90
sed -i -e 's/USE B2MOD_INIT_WALL_DIFF, ONLY : wall_final, wall_final_d/USE B2MOD_INIT_WALL_DIFF, ONLY : wall_final/g' b2mod_driver_diff.F90
sed -i -e 's/USE B2MOD_B2_TO_ASTRA_DIFF, ONLY : write_b2_to_astra, &/USE B2MOD_B2_TO_ASTRA_DIFF, ONLY : write_b2_to_astra/g' b2mod_driver_diff.F90
sed -i '/& write_b2_to_astra_d/d' b2mod_driver_diff.F90
sed -i -e 's/USE B2MOD_B2STBC_FB_DIFF, ONLY : b2stbc_fb_final, b2stbc_fb_final_d/USE B2MOD_B2STBC_FB_DIFF, ONLY : b2stbc_fb_final/g' b2mod_driver_diff.F90
sed -i -e 's/alloc_b2mod_b2_to_astra_d, dealloc_b2mod_b2_to_astra, &/dealloc_b2mod_b2_to_astra/g' b2mod_main_diff.F90
sed -i '/& dealloc_b2mod_b2_to_astra_d/d' b2mod_main_diff.F90
sed -i -e 's/init_wall, init_wall_d/init_wall/g' b2stbr_d.F90

# XXXX
sed -i '/EXTERNAL ISUNUSEDCELL/d' b2wugm_d.F90
sed -i '/EXTERNAL ISINDOMAIN/d' b2wugm_d.F90
sed -i '/LOGICAL :: ISUNUSEDCELL/d' b2wugm_d.F90
sed -i '/LOGICAL :: ISINDOMAIN/d' b2wugm_d.F90
sed -i '/EXTERNAL ISCLASSICALGRID/d' b2mod_geo_diff.F90
sed -i '/LOGICAL :: ISCLASSICALGRID/d' b2mod_geo_diff.F90
sed -i '/EXTERNAL ISGHOSTCELL/d' b2mod_indirect_diff.F90
sed -i '/LOGICAL :: ISGHOSTCELL/d' b2mod_indirect_diff.F90
sed -i '/EXTERNAL ISINDOMAIN/d' b2mod_indirect_diff.F90
sed -i '/LOGICAL :: ISINDOMAIN/d' b2mod_indirect_diff.F90
sed -i '/EXTERNAL ISREALCELL/d' b2mod_indirect_diff.F90
sed -i '/LOGICAL :: ISREALCELL/d' b2mod_indirect_diff.F90
sed -i -e 's/REAL(kind=r8) FUNCTION MASS_DENSITY_D1/  FUNCTION MASS_DENSITY_D/g' heatdiff1D_d.F90
sed -i -e 's/END FUNCTION MASS_DENSITY_D1/END FUNCTION MASS_DENSITY_D/g' heatdiff1D_d.F90

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



## compile with debug
cp $TAPENADEDIR/ADFirstAidKit/adDebug.c .
cp $TAPENADEDIR/ADFirstAidKit/adStack.c .
cp $TAPENADEDIR/ADFirstAidKit/adStack.h .

cd $SOLPSTOP
setenv DIFF_D yes
gmake listobj
gmake depend
gmake b25_diff_d


