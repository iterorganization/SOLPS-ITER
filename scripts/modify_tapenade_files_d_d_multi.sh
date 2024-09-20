
# all files are .f90 files, move them to .F90 extension
move_to_F90.sh
rm b2mod_astra_to_b2_dv.F90 b2mod_eirdiag_dv.F90 my_outi_us_dv.F90 b2uxus_tgt_dv.F90 b2uxus_dv_dv.F90 eirflux_map_dv.F90 get_jsep_dv.F90 smax_dv.F90 smin_dv.F90 print_tgt_gradient_dv.F90 set_tgt_perturbation_dv.F90 dim_dv.F90 solve_covariance_dv_dv.F90
collect_nodiff_d_d_multi.sh
mv b2mn_d_dv.F90 b2mn_hess.F90

sed -i -e 's/use b2mod_user_namelist/use b2mod_user_namelist_diffv_diffv/g' b2mod_cdf.F90 b2mod_mwti.F90 b2mod_trace.F b2mod_usrtrc.F b2mod_wrsep.F
sed -i -e 's/use b2us_map/use b2us_map_diffv_diffv/g' b2mod_cdf.F90 b2mod_astra_to_b2.F b2mod_b2_to_astra.F b2mod_blnc.F b2mod_blnm.F b2mod_geometry.F90 b2mod_mwti.F90 b2mod_trace.F b2uxus.F tallies.F
sed -i -e 's/use b2mod_neutrals_namelist/use b2mod_neutrals_namelist_diffv_diffv/g' b2mod_b2_to_astra.F b2mod_blnc.F b2mod_blne.F b2mod_mwti.F90 b2mod_trace.F b2mod_wrsep.F eirflux_map.F
sed -i -e 's/use b2mod_b2cmpa/use b2mod_b2cmpa_diffv_diffv/g' b2mod_b2_to_astra.F b2mod_blnc.F b2mod_blne.F b2mod_blnm.F b2mod_file.F b2mod_mwti.F90 b2mod_trace.F b2mod_usrtrc.F b2mod_wrint.F b2mod_wrsep.F tallies.F b2mod_wrsrt.F
sed -i -e 's/use b2us_geo/use b2us_geo_diffv_diffv/g' b2mod_blnc.F b2mod_geometry.F90 b2mod_mwti.F90 b2mod_trace.F cdfmovie.F tallies.F
sed -i -e 's/use b2us_plasma/use b2us_plasma_diffv_diffv/g' b2mod_blnc.F b2mod_blnm.F b2mod_mwti.F90 b2mod_trace.F calc_err.F cdfmovie.F tallies.F
sed -i -e 's/use b2mod_switches/use b2mod_switches_diffv_diffv/g' b2mod_blnc.F b2mod_blne.F b2mod_blnm.F b2mod_file.F b2mod_mwti.F90 b2mod_trace.F b2mod_usrtrc.F b2mod_wrint.F b2mod_wrsep.F b2mod_wrsrt.F calc_err.F cdfmovie.F tallies.F
sed -i -e 's/use b2mod_plasma/use b2mod_plasma_diffv_diffv/g' b2mod_b2_to_astra.F b2mod_blnc.F b2mod_blne.F b2mod_file.F b2mod_mwti.F90 b2mod_usrtrc.F b2mod_wrint.F b2mod_wrsep.F b2mod_wrsrt.F
sed -i -e 's/use b2mod_indirect/use b2mod_indirect_diffv_diffv/g' b2mod_b2_to_astra.F b2mod_blnc.F b2mod_blne.F b2mod_geo2.F b2mod_interp.F90 b2mod_mwti.F90 b2mod_trace.F b2mod_usrtrc.F b2mod_wrint.F b2mod_wrsep.F  b2mod_wrsrt.F get_jsep.F
sed -i -e 's/use b2mod_external/use b2mod_external_diffv_diffv/g' b2mod_blne.F b2mod_mwti.F90 b2mod_usrtrc.F b2mod_wrint.F b2mod_wrsep.F b2mod_wrsrt.F
sed -i -e 's/use b2mod_geo/use b2mod_geo_diffv_diffv/g' b2mod_b2_to_astra.F b2mod_blnc.F b2mod_blne.F b2mod_interp.F90 b2mod_mwti.F90 b2mod_usrtrc.F b2mod_wrint.F b2mod_wrsep.F b2mod_wrsrt.F get_jsep.F
sed -i -e 's/use b2mod_diag/use b2mod_diag_diffv_diffv/g' b2mod_blnc.F b2mod_blne.F b2mod_blnm.F b2mod_file.F b2mod_trace.F b2mod_usrtrc.F b2mod_wrint.F b2mod_wrsep.F b2mod_wrsrt.F combfile.F parsehdr.F tallies.F
sed -i -e 's/use b2mod_version/use b2mod_version_diffv_diffv/g' b2mod_file.F
sed -i -e 's/use b2mod_numerics_namelist/use b2mod_numerics_namelist_diffv_diffv/g' b2mod_blnc.F b2mod_blne.F b2mod_blnm.F b2mod_usrtrc.F b2mod_wrint.F b2mod_wrsep.F b2mod_wrsrt.F
sed -i -e 's/use b2mod_boundary_namelist/use b2mod_boundary_namelist_diffv_diffv/g' b2mod_blnc.F b2mod_blne.F b2mod_usrtrc.F
sed -i -e 's/use b2mod_sources/use b2mod_sources_diffv_diffv/g' b2mod_blnc.F b2mod_wrsep.F b2mod_mwti.F90
sed -i -e 's/use b2mod_geo_diffv_diffvmetry/use b2mod_geometry/g' b2mod_blnc.F b2mod_mwti.F90
sed -i -e 's/use b2mod_tallies/use b2mod_tallies_diffv_diffv/g' b2mod_mwti.F90 b2mod_wrint.F b2mod_wrsep.F b2mod_wrsrt.F tallies.F
sed -i -e 's/use b2mod_anomalous_transport/use b2mod_anomalous_transport_diffv_diffv/g' b2mod_b2_to_astra.F
sed -i -e 's/use b2mod_math/use b2mod_math_diffv_diffv/g' b2mod_geo2.F b2mod_interp.F90 damax.F ifill.F ma28copy.F sfill.F smax.F smin.F
sed -i -e 's/use b2mod_ad/use b2mod_ad_diffv_diffv/g' my_outi_us.F

sed -i "/INCLUDE 'DIFFSIZES.inc'/d" ./*.F90
sed -i "/USE DIFFSIZES/d" ./*.F90
sed -i -e 's/GET_JSEP_NODIFF/GET_JSEP/g' ./*.F90
sed -i -e 's/#NBDirsMax#/nbdirsmax/g' dim_dv.F90
sed -i -e 's/#NBDirsMax#/nbdirsmax0/g' damax_dv.F90
sed -i -e 's/#DIM_DV#/DIM_DV/g' dim_dv.F90
sed -i -e '/USE B2MOD_TYPES/a\  USE B2MOD_DIFFSIZES' dim_dv.F90
sed -i -e 's/MY_OUT_US_NODIFF/MY_OUT_US/g' ./*.F90
sed -i -e 's/SMIN_NODIFF/smin/g' ./*.F90
sed -i -e 's/SMAX_NODIFF/smax/g' ./*.F90
sed -i -e 's/DAMAX_NODIFF/damax/g' b2mndt_dv_dv.F90 b2mxac_dv_dv.F90 b2mxac_diffv_dv.F90 b2mxac_dv_dv.F90 b2stcx_dv_dv.F90 b2stel_dv_dv.F90
sed -i -e '/INTRINSIC HUGE/d' b2mod_neutrals_namelist_diffv_diffv.F90
sed -i -e '/INTRINSIC MAX/d' b2wdat_dv.F90

sed -i -e '/CALL MAXVAL_DV/a\    result10 = MAXVAL(abs0)' b2stcx_dv_dv.F90
sed -i '/MINVAL_DV/d' ./*.F90
sed -i '/MAXVAL_DV/d' ./*.F90

sed -i -e 's/B2UXUS_NODIFF/b2uxus/g' b2usco_dv_dv.F90 b2usmo_dv_dv.F90 b2uspo_dv_dv.F90 b2usht_dv_dv.F90

# add output of twice diff'ed residuals
sed -i -e 's/nout(0:10)/nout(0:11)/g' b2mod_main_diffv_diffv.F90 b2mndt_dv_dv.F90 b2mnds_dv_dv.F90 b2mod_driver_diffv_diffv.F90
sed -i -e "0,/\&       , 'faulty argument ninp, nout')/s/\&       , 'faulty argument ninp, nout')/\&       .AND. 1 .LE. nout(11), 'faulty argument ninp, nout')/g" b2mnds_dv_dv.F90
sed -i -e "0,/CALL B2MWQ0_NODIFF_NODIFF(nout(10), ns, switch)/s/CALL B2MWQ0_NODIFF_NODIFF(nout(10), ns, switch)/CALL B2MWQ0_NODIFF_NODIFF(nout(10), ns, switch)\n  idum(0) = ns\n  CALL CFWUIN(nout(11), 1, idum, 'ns')\n  CALL CFWUCH(nout(11), 120, lblmn, 'label')\n  CALL B2MWQ0_NODIFF_NODIFF(nout(11), ns, switch)/ g" b2mnds_dv_dv.F90
sed -i -e 's/DATA nout \/60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70\//DATA nout \/60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71\//g' b2mod_main_diffv_diffv.F90
sed -i -e "0,/CALL CFOPEN(nout(10), 'b2ftraced', 'new', 'un\*formatted')/s/CALL CFOPEN(nout(10), 'b2ftraced', 'new', 'un\*formatted')/CALL CFOPEN(nout(10), 'b2ftraced', 'new', 'un\*formatted')\n    CALL CFOPEN(nout(11), 'b2ftracedd', 'new', 'un\*formatted')/g" b2mod_main_diffv_diffv.F90
sed -i -e "0,/!\*      ..compute norms of the differentiated corrections/s/!\*      ..compute norms of the differentiated corrections/        CALL B2MXAR_DIFFV_DIFFV(ncv, ns, nnreg(0), switch%boris, switch\&\n\&                          , geo, mpg, stdd%pl, stdd%dv, stdd%diag)\n!\*      ..compute norms of the differentiated corrections/g" b2mndt_dv_dv.F90
sed -i -e '0,/CALL B2MXAC_DIFFV_NODIFF(ncv, ns, std%dv, std%diag)/s/CALL B2MXAC_DIFFV_NODIFF(ncv, ns, std%dv, std%diag)/CALL B2MXAC_DIFFV_NODIFF(ncv, ns, std%dv, std%diag)\n        CALL B2MXAC_DIFFV_DIFFV(ncv, ns, stdd%dv, stdd%diag)/g' b2mndt_dv_dv.F90

sed -i -e '0,/FLUSH(nout(10)) /s/FLUSH(nout(10)) /FLUSH(nout(10)) \n            CALL B2MWQT_DIFFV_DIFFV(nout(11), ncv, ns, itim, \&\n\&                              b2mndt_itcnt, switch%boris, switch, geo, \&\n\&                              stdd%pl, stdd%dv, stdd%diag)\n            FLUSH(nout(11)) /g' b2mndt_dv_dv.F90


# here we change nested loops like
# do nd = 1, nbdirs
#   do nd0 = 1, nbdirs0
# into
# do nd = 1, nbdirs
#   do nd0 = nd, nbdirs0
# to exploit symmetry of the hessian
grep -iwn -A1 'do nd=1,nbdirs' ./* | grep -i 'do nd0=1,nbdirs0' | awk -v FS=- '{print $1, $2}' > tmp
while read -r line
do
    file=`echo $line | awk '{print $1}'`
    ll=`echo $line | awk '{print $2}'`
    sed -i -e "${ll}s/nd0=1,nbdirs0/nd0=nd,nbdirs0/" $file
done < tmp
rm tmp

sed -i -e 's/ISIZE1OFtemp/nCv/g' b2us_feedback_diffv_diffv.F90 b2mndt_dv_dv.F90 b2news__dv_dv.F90 b2news_m_dv_dv.F90 b2npht_dv_dv.F90 b2npmo_dv_dv.F90 b2sikt_dv_dv.F90 b2tfhi__dv_dv.F90 b2tfnb_dv_dv.F90 b2tqna_dv_dv.F90 b2tral_dv_dv.F90
sed -i -e 's/ISIZE1OFne/nCv/g' b2mndt_dv_dv.F90 b2news__dv_dv.F90 b2news_m_dv_dv.F90 b2npht_dv_dv.F90 b2npmo_dv_dv.F90
sed -i -e 's/ISIZE1OFkinrgy/nCv/g' b2mndt_dv_dv.F90
sed -i -e 's/ISIZE2OFkinrgy/0:ns-1/g' b2mndt_dv_dv.F90
sed -i -e 's/ISIZE2OFtemp/0:ns-1/g' b2mndt_dv_dv.F90
sed -i -e "s/REAL(r8), DIMENSION(:,/REAL(r8), DIMENSION(nbdirsmax0,/g" b2news__dv_dv.F90 b2news_m_dv_dv.F90
sed -i -e "s/REAL(kind=r8), DIMENSION(:,/REAL(kind=r8), DIMENSION(nbdirsmax0,/g" b2sihs__dv_dv.F90 b2stbc_dv_dv.F90
sed -i -e 's/ISIZE1OFgeo%cvvol/nCv/g' b2stbc_dv_dv.F90
sed -i -e 's/DIMENSION(:, ISIZE1OFdv%fna_52(:, :, isb), 0:1)/DIMENSION(nbdirsmax0, nFc, 0:1)/g' b2tfnb_dv_dv.F90
sed -i -e 's/ISIZE1OFfcqalf/nFc/g' b2tfnb_dv_dv.F90 b2tvskt_dv_dv.F90
sed -i -e 's/ISIZE1OFpa/nCv/g' b2tfnb_dv_dv.F90
sed -i -e 's/ISIZE1OFfacdrift/nFc/g' b2tfnb_dv_dv.F90
sed -i -e 's/DIMENSION(:/DIMENSION(nbdirsmax0/g' b2tral_dv_dv.F90 b2trno_dv_dv.F90
sed -i -e 's/ISIZE1OFco%cthi/nFc/g' b2tral_dv_dv.F90
sed -i -e 's/ISIZE2OFco%cthi/0:ns-1/g' b2tral_dv_dv.F90
sed -i -e 's/ISIZE1OFco%cthe/nFc/g' b2tral_dv_dv.F90
sed -i -e 's/ISIZE2OFco%cthe/0:ns-1/g' b2tral_dv_dv.F90
sed -i -e 's/ISIZE1OFlnlam/nCv/g' b2npmo_dv_dv.F90 b2trcl_dv_dv.F90
sed -i -e 's/ISIZE1OFco%fllim0fhi/nfc/g' b2trno_dv_dv.F90
sed -i -e 's/ISIZE3OFco%fllim0fhi/0:ns-1/g' b2trno_dv_dv.F90

sed -i -e "s/cfdna(:, is), cfdnad0(:, :, is)/cfdna(0, is), cfdnad0(1:nbdirs0, 0, is)/g" b2tqna_dv_dv.F90
sed -i -e "s/cfvla(:, is), cfvlad0(:, :, is)/cfvla(0, is), cfvlad0(1:nbdirs0, 0, is)/g" b2tqna_dv_dv.F90
sed -i -e "s/cfhci(:, is), cfhcid0(:, :, is)/cfhci(0, is), cfhcid0(1:nbdirs0, 0, is)/g" b2tqna_dv_dv.F90
sed -i -e "s/cfdpa(:, is), cfdpad0(:, :, is)/cfdpa(0, is), cfdpad0(1:nbdirs0, 0, is)/g" b2tqna_dv_dv.F90
sed -i -e "s/cfvsa(:, is), cfvsad0(:, :, is)/cfvsa(0, is), cfvsad0(1:nbdirs0, 0, is)/g" b2tqna_dv_dv.F90
sed -i -e "s/(:, :, is), nbdirs, nbdirs0)/(1:nbdirs, 0, is), nbdirs, nbdirs0)/g" b2tqna_dv_dv.F90
sed -i -e "s/cfdna(:, is), cfdnad(:, :, is)/cfdna(0, is), cfdnad(1:nbdirs, 0, is)/g" b2tqna_dv_dv.F90
sed -i -e "s/cfdpa(:, is), cfdpad(:, :, is)/cfdpa(0, is), cfdpad(1:nbdirs, 0, is)/g" b2tqna_dv_dv.F90
sed -i -e "s/cfvla(:, is), cfvlad(:, :, is)/cfvla(0, is), cfvlad(1:nbdirs, 0, is)/g" b2tqna_dv_dv.F90
sed -i -e "s/cfvsa(:, is), cfvsad(:, :, is)/cfvsa(0, is), cfvsad(1:nbdirs, 0, is)/g" b2tqna_dv_dv.F90
sed -i -e "s/cfhci(:, is), cfhcid(:, :, is)/cfhci(0, is), cfhcid(1:nbdirs, 0, is)/g" b2tqna_dv_dv.F90
sed -i -e "s/cfdna(:, is))/cfdna(0, is))/g" b2tqna_dv_dv.F90
sed -i -e "s/cfdpa(:, is))/cfdpa(0, is))/g" b2tqna_dv_dv.F90
sed -i -e "s/cfvla(:, is))/cfvla(0, is))/g" b2tqna_dv_dv.F90
sed -i -e "s/cfvsa(:, is))/cfvsa(0, is))/g" b2tqna_dv_dv.F90
sed -i -e "s/cfhci(:, is))/cfhci(0, is))/g" b2tqna_dv_dv.F90

sed -i -e 's/state_extd0\%is_neutral(:, 0:ns_ext-1) = 0.0_8/state_extd0\%is_neutral(:, 0:ns_ext-1) = .true./g' b2us_plasma_diffv_diffv.F90
sed -i -e 's/REAL :: result1/INTEGER :: result1/g' b2us_map_diffv_diffv.F90

sed -i -e 's/alloc_b2mod_b2plot_dv, dealloc_b2mod_b2plot, dealloc_b2mod_b2plot_dv/dealloc_b2mod_b2plot/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/write_b2us_feedback_dv, init_feedback, init_feedback_dv/init_feedback/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/dealloc_feedback, dealloc_feedback_dv, fb_target, fb_targetd0,/dealloc_feedback, fb_target, fb_targetd0,/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/dealloc_sputter_data_dv, dealloc_b2mod_sputter, \&/dealloc_b2mod_sputter/g' b2mod_driver_diffv_diffv.F90
sed -i -e '/\& dealloc_b2mod_sputter_dv/d' b2mod_driver_diffv_diffv.F90
sed -i -e '/\& dealloc_b2mod_ysmp_sdrv_dv/d' b2mod_driver_diffv_diffv.F90
sed -i -e '/\& dealloc_b2mod_wall_dv/d' b2mod_driver_diffv_diffv.F90
sed -i -e '/& dealloc_b2mod_neoclassical_dv/d' b2mod_driver_diffv_diffv.F90
sed -i -e '/& dealloc_b2mod_transport_disruption_dv/d' b2mod_driver_diffv_diffv.F90
sed -i -e 's/dealloc_b2mod_ysmp_sdrv, \&/dealloc_b2mod_ysmp_sdrv/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/dealloc_b2mod_wall, \&/dealloc_b2mod_wall/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/dealloc_b2mod_neoclassical,\&/dealloc_b2mod_neoclassical/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/\& dealloc_b2mod_transport_disruption, \&/\& dealloc_b2mod_transport_disruption/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/batch_av_all_init_dv, batch_av_all_save, batch_av_all_save_dv/batch_av_all_save/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/batch_av_all_fin, batch_av_all_fin_dv/batch_av_all_fin/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/run_av_init_dv0, run_av_init_dv, run_av_init_dv_dv, run_av_get_plasma/run_av_init_dv, run_av_get_plasma/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/run_av_get_plasma_dv, run_av_save, run_av_save_dv, run_av_fin/run_av_save, run_av_fin/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/run_av_fin_dv0, run_av_fin_dv, run_av_fin_dv_dv/run_av_fin_dv/g' b2mod_driver_diffv_diffv.F90

sed -i -e 's/b2mn_init_dv, b2mn_init_dv_dv, b2mn_step, b2mn_step_dv0, b2mn_step_dv/b2mn_init_dv, b2mn_init_dv_dv, b2mn_step, b2mn_step_dv/g' b2mn_hess.F90
sed -i -e 's/b2mn_step_dv0, b2mn_fin, b2mn_fin_dv0/b2mn_fin, b2mn_fin_dv0/g' b2mn_hess.F90

sed -i -e "s/USE B2MOD_ASTRA_TO_B2_DIFFV/USE B2MOD_ASTRA_TO_B2/g" b2mod_main_diffv_diffv.F90 b2stbc_phys_dv_dv.F90
sed -i -e "s/USE B2MOD_RESIDUALS_DIFFV/USE B2MOD_RESIDUALS/g" b2mod_diag_diffv_diffv.F90
sed -i -e 's/INTEGER, SAVE :: ank_tracing=0/INTEGER :: ank_tracing=0/g' b2mod_diag_diffv_diffv.F90
sed -i -e "s/USE B2MOD_EIRDIAG_DIFFV/USE B2MOD_EIRDIAG/g" b2mod_neutrals_namelist_diffv_diffv.F90 b2mod_balance_diffv_diffv.F90 b2news__dv_dv.F90 b2news_m_dv_dv.F90 b2sral_dv_dv.F90 b2tinnt_dv_dv.F90 b2tqin_dv_dv.F90 eirene_mc_init_dv.F90

sed -i '/EXTERNAL SUBINI/d' *.F90
sed -i '/EXTERNAL SUBEND/d' *.F90
sed -i -e '/EXTERNAL OUTPUT_DS_CV/d' b2mod_input_profile_diffv_diffv.F90
sed -i '/EXTERNAL IPSETC/d' b2mnds_dv_dv.F90 
sed -i '/EXTERNAL IPPRHP/d' b2mnds_dv_dv.F90 
sed -i '/EXTERNAL B2FILE./d' b2mndt_dv_dv.F90
sed -i '/EXTERNAL RESTART_MA28_FOR_US/d' b2news__dv_dv.F90 b2npmo_dv_dv.F90 b2usht_dv_dv.F90 b2news_m_dv_dv.F90

sed -i '/EXTERNAL ISGHOSTCELL/d' b2mod_geo_diffv_diffv.F90 b2mod_indirect_diffv_diffv.F90
sed -i '/LOGICAL :: ISGHOSTCELL/d' b2mod_geo_diffv_diffv.F90 b2mod_indirect_diffv_diffv.F90
sed -i '/EXTERNAL ISREALCELL/d' b2mod_geo_diffv_diffv.F90 b2mod_indirect_diffv_diffv.F90
sed -i '/LOGICAL :: ISREALCELL/d' b2mod_geo_diffv_diffv.F90 b2mod_indirect_diffv_diffv.F90
sed -i '/EXTERNAL ISINDOMAIN/d' b2mod_geo_diffv_diffv.F90 b2mod_indirect_diffv_diffv.F90
sed -i '/LOGICAL :: ISINDOMAIN/d' b2mod_geo_diffv_diffv.F90 b2mod_indirect_diffv_diffv.F90
sed -i '/EXTERNAL ISCLASSICALGRID/d' b2mod_geo_diffv_diffv.F90
sed -i '/LOGICAL :: ISCLASSICALGRID/d' b2mod_geo_diffv_diffv.F90
sed -i '/EXTERNAL ISUNUSEDCELL/d' b2mod_geo_diffv_diffv.F90
sed -i '/LOGICAL :: ISUNUSEDCELL/d' b2mod_geo_diffv_diffv.F90
sed -i '/EXTERNAL OR/d' b2stbr_dv_dv.F90
sed -i '/INTEGER :: OR/d' b2stbr_dv_dv.F90
sed -i '/EXTERNAL DAMAX_DV/d' b2mndt_dv_dv.F90 b2stcx_dv_dv.F90 b2stel_dv_dv.F90
sed -i '/EXTERNAL ANINT/d' b2xvcp_dv_dv.F90
sed -i '/INTEGER :: ANINT/d' b2xvcp_dv_dv.F90
sed -i '/EXTERNAL ALLOC_B2MOD_B2_TO_ASTRA/d' b2mod_driver_diffv_diffv.F90 b2mod_main_diffv_diffv.F90
sed -i '/EXTERNAL CDFMOVIE/d' b2mod_driver_diffv_diffv.F90
sed -i '/EXTERNAL DEALLOC_B2MOD_MWTI/d' b2mod_driver_diffv_diffv.F90
sed -i '/EXTERNAL TALLIES/d' b2mod_driver_diffv_diffv.F90
sed -i '/EXTERNAL REPEAT/d' b2mod_elements_diffv_diffv.F90
sed -i '/EXTERNAL XERSET/d' b2mod_main_diffv_diffv.F90
sed -i '/EXTERNAL IPGETC/d' b2mod_driver_diffv_diffv.F90
sed -i '/EXTERNAL B2TRCS/d' b2mod_driver_diffv_diffv.F90
sed -i '/EXTERNAL B2TRCF/d' b2mod_driver_diffv_diffv.F90
sed -i '/EXTERNAL B2TRACE/d' b2mod_driver_diffv_diffv.F90
sed -i '/EXTERNAL B2TRCI/d' b2mod_driver_diffv_diffv.F90
sed -i '/EXTERNAL B2MWTI/d' b2mod_driver_diffv_diffv.F90
sed -i '/EXTERNAL DEALLOC_B2MOD_MA28_FOR_US/d' b2mod_driver_diffv_diffv.F90

sed -i 's/B2XPNE_ST_NODIFF/B2XPNE_ST/g' b2mod_running_average_diffv_diffv.F90 b2rups_dv_dv.F90 profile_average_dv_dv.F90
sed -i 's/MY_OUTI_US_NODIFF/MY_OUTI_US/g' b2wdat_dv.F90
sed -i 's/b2xppz_st/b2xppz_st_nodiff_nodiff/g' b2mod_usrtrc.F
sed -i 's/b2xppz/b2xppz_nodiff_nodiff/g' b2mod_blnm.F
sed -i 's/FIX_USER_NODIFF/FIX_USER/g' fix_user_dv_dv.F90
sed -i 's/call b2usr_loads(nx,ny,ns,nxtl,nxtr,BoRiS,wtarg_max)/call b2usr_loads_nodiff_nodiff(nx,ny,ns,nxtl,nxtr,BoRiS,\n     \&    wtarg_max)/g' b2mod_usrtrc.F
sed -i 's/call species/call species_nodiff_nodiff/g' tallies.F
sed -i 's/b2xzef_st/b2xzef_st_nodiff_nodiff/g' b2mod_wrsep.F
sed -i 's/B2NEUT_IND_NODIFF/b2neut_ind/g' b2usr_loads_dv_dv.F90
sed -i 's/B2NEUT_SURFCHECK_NODIFF/b2neut_surfcheck/g' b2usr_loads_dv_dv.F90
sed -i 's/B2NEUT_ENG_NODIFF/b2neut_eng/g' b2usr_loads_dv_dv.F90
sed -i 's/B2UXUS_DV_NODIFF/b2uxus_dv/g' b2usco_dv_dv.F90 b2usmo_dv_dv.F90 b2usht_dv_dv.F90 b2uspo_dv_dv.F90
sed -i -e '/SET_TGT_PERTURBATION_NODIFF/d' b2mn_hess.F90
sed -i -e '/EXTERNAL DEALLOCATEB2GRIDMAP/d' b2mod_geo_diffv_diffv.F90
sed -i -e 's/ERF_DV0/ERF_DV/g' erf_dv_dv.F90 b2mod_recycle_diffv_diffv.F90
sed -i -e '/EXTERNAL ERF_DV/d' b2mod_recycle_diffv_diffv.F90
sed -i -e 's/DIM_DV0/DIM_DV/g' dim_dv_dv.F90

sed -i -e 's/cvfpsi(icv) = SUM(arg1)\/mpg%cvvxp(icv, 2)/cvfpsi(icv) = SUM(gm%vxfpsi(verts))\/mpg%cvvxp(icv, 2)/g' b2us_geo_diffv_diffv.F90
sed -i -e '/arg1 = gm%vxfpsi(verts)/d' b2us_geo_diffv_diffv.F90
#sed -i -e 's/result1 = MAXVAL(arg1(:))/result1 = MAXVAL(gm%vxfpsi(verts(1:mpg%cvvxp(icv, 2))))/g' b2us_geo_diffv_diffv.F90
#sed -i -e 's/result2 = MINVAL(arg2(:))/result2 = MINVAL(gm%vxfpsi(verts(1:mpg%cvvxp(icv, 2))))/g' b2us_geo_diffv_diffv.F90



