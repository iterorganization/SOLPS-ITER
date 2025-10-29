
# all files are .f90 files, move them to .F90 extension
move_to_F90.sh
rm my_outi_us_dv.F90 b2uxus_tgt_dv.F90 b2uxus_dv_dv.F90 get_jsep_dv.F90 smax_dv.F90 smin_dv.F90 print_tgt_gradient_dv.F90 set_tgt_perturbation_dv.F90 dim_dv.F90 solve_covariance_dv_dv.F90 cfwure_dv.F90 cfwuin_dv.F90 invert_matrix_dv.F90
collect_nodiff_d_d_multi.sh
mv b2mn_d_dv.F90 b2mn_hess.F90

sed -i -e 's/\<0_8\>/D0/g' ./*_dv.F90 ./*_diffv.F90

sed -i -e 's/use b2mod_user_namelist/use b2mod_user_namelist_diffv_diffv/g' b2mod_cdf.F90 b2mod_mwti.F90 b2mod_trace.F b2mod_usrtrc.F b2mod_wrsep.F b2mod_wrint.F
sed -i -e 's/use b2us_map/use b2us_map_diffv_diffv/g' b2mod_cdf.F90 b2mod_b2_to_astra.F b2mod_blnc.F b2mod_blnm.F b2mod_mwti.F90 b2mod_trace.F b2uxus.F tallies.F  b2mod_wrsrt.F b2mod_blne.F b2mod_wrint.F b2mod_wrsep.F
sed -i -e 's/use b2mod_neutrals_namelist/use b2mod_neutrals_namelist_diffv_diffv/g' b2mod_b2_to_astra.F b2mod_blnc.F b2mod_blne.F b2mod_mwti.F90 b2mod_trace.F b2mod_wrsep.F
sed -i -e 's/use b2mod_b2cmpa/use b2mod_b2cmpa_diffv/g' b2mod_b2_to_astra.F b2mod_blnc.F b2mod_blne.F b2mod_blnm.F b2mod_file.F b2mod_mwti.F90 b2mod_trace.F b2mod_usrtrc.F b2mod_wrint.F b2mod_wrsep.F tallies.F b2mod_wrsrt.F b2mod_ppout.F
sed -i -e 's/use b2us_geo/use b2us_geo_diffv_diffv/g' b2mod_blnc.F b2mod_mwti.F90 b2mod_trace.F cdfmovie.F tallies.F b2mod_wrsrt.F b2mod_blne.F b2mod_blnm.F b2mod_wrint.F b2mod_wrsep.F
sed -i -e 's/use b2us_plasma/use b2us_plasma_diffv_diffv/g' b2mod_blnc.F b2mod_blnm.F b2mod_mwti.F90 b2mod_trace.F calc_err.F cdfmovie.F tallies.F b2mod_file.F b2mod_wrsrt.F b2mod_blne.F b2mod_wrint.F b2mod_wrsep.F
sed -i -e 's/use b2mod_switches/use b2mod_switches_diffv_diffv/g' b2mod_blnc.F b2mod_blne.F b2mod_blnm.F b2mod_file.F b2mod_mwti.F90 b2mod_trace.F b2mod_usrtrc.F b2mod_wrint.F b2mod_wrsep.F b2mod_wrsrt.F calc_err.F cdfmovie.F tallies.F
sed -i -e 's/use b2mod_indirect/use b2mod_indirect_diffv_diffv/g' b2mod_b2_to_astra.F b2mod_blnc.F b2mod_blne.F b2mod_geo2.F b2mod_interp.F90 b2mod_mwti.F90 b2mod_trace.F b2mod_usrtrc.F b2mod_wrint.F b2mod_wrsep.F  b2mod_wrsrt.F get_jsep.F b2mod_ppout.F
sed -i -e 's/use b2mod_external/use b2mod_external_diffv_diffv/g' b2mod_blne.F b2mod_mwti.F90 b2mod_usrtrc.F b2mod_wrint.F b2mod_wrsep.F b2mod_wrsrt.F
sed -i -e 's/use b2mod_geo$/use b2mod_geo_diffv_diffv/g' b2mod_b2_to_astra.F b2mod_blnc.F b2mod_blne.F b2mod_interp.F90 b2mod_mwti.F90 b2mod_usrtrc.F b2mod_wrint.F b2mod_wrsep.F b2mod_wrsrt.F get_jsep.F b2mod_ppout.F
sed -i -e 's/use b2mod_diag/use b2mod_diag_diffv_diffv/g' b2mod_blnc.F b2mod_blne.F b2mod_blnm.F b2mod_file.F b2mod_trace.F b2mod_usrtrc.F b2mod_wrint.F b2mod_wrsep.F b2mod_wrsrt.F combfile.F parsehdr.F tallies.F
sed -i -e 's/use b2mod_numerics_namelist/use b2mod_numerics_namelist_diffv_diffv/g' b2mod_blnc.F b2mod_blne.F b2mod_blnm.F b2mod_usrtrc.F b2mod_wrint.F b2mod_wrsep.F b2mod_wrsrt.F calc_err.F
sed -i -e 's/use b2mod_boundary_namelist/use b2mod_boundary_namelist_diffv_diffv/g' b2mod_blnc.F b2mod_blne.F b2mod_usrtrc.F
sed -i -e 's/use b2mod_geo_diffv_diffvmetry/use b2mod_geometry/g' b2mod_blnc.F b2mod_mwti.F90 b2mod_blne.F b2mod_wrsep.F
sed -i -e 's/use b2mod_math/use b2mod_math_diffv_diffv/g' b2mod_geo2.F b2mod_interp.F90 damax.F ma28copy.F smax.F smin.F calc_err.F
sed -i -e 's/use b2mod_ad/use b2mod_ad_diffv_diffv/g' my_outi_us.F
sed -i -e 's/use b2mod_geometry/use b2mod_geometry_diffv_diffv/g' b2mod_blnc.F b2mod_blne.F b2mod_geo2.F b2mod_mwti.F90 b2mod_wrsep.F b2mod_usrtrc.F
sed -i -e 's/use b2us_geo/use b2us_geo_diffv_diffv/g' b2mod_usrtrc.F
sed -i -e 's/use b2us_plasma/use b2us_plasma_diffv_diffv/g' b2mod_usrtrc.F
sed -i -e 's/use b2us_map/use b2us_map_diffv_diffv/g' b2mod_usrtrc.F calc_err.F
sed -i -e 's/use b2mod_astra_to_b2/use b2mod_astra_to_b2_diffv_diffv/g' b2mod_b2_to_astra.F
sed -i -e 's/use b2mod_eirdiag/use b2mod_eirdiag_diffv_diffv/g' b2mod_b2_to_astra.F cdfmovie.F
sed -i -e 's/use b2mod_plasma/use b2mod_plasma_diffv/g' b2mod_ppout.F b2mod_b2_to_astra.F
sed -i -e 's/use b2mod_elements/use b2mod_elements_diffv/g' b2mod_ppout.F
sed -i -e 's/use b2mod_balance/use b2mod_balance_diffv_diffv/g' cdfmovie.F
sed -i -e 's/b2ptrdl/b2ptrdl_nodiff/g' b2mod_usrtrc.F
sed -i -e 's/gradc_r/gradc_r_nodiff_nodiff/g' b2mod_usrtrc.F
sed -i -e 's/B2PWINP_NODIFF/B2PWINP/g' b2ptrdl_dv.F90
sed -i -e 's/b2pwlprp/b2pwlprp_nodiff/g' b2pwinp.F
sed -i -e 's/ank_interface/ank_interface_nodiff/g' wallon.F
sed -i -e 's/CFWURE_NODIFF/CFWURE/g' b2us_plasma_diffv_diffv.F90 b2wucp_dv_dv.F90 b2us_map_diffv_diffv.F90 b2us_geo_diffv_diffv.F90 b2mwqt_*.F90 b2mwmv_dv_dv.F90 b2mwit_dv_dv.F90 b2mod_running_average_diffv_diffv.F90 b2mod_geo_diffv_diffv.F90 b2mod_batch_average_diffv_diffv.F90
sed -i -e 's/CFWUIN_NODIFF/CFWUIN/g' b2us_plasma_diffv_diffv.F90 b2wucp_dv_dv.F90 b2us_map_diffv_diffv.F90 b2us_geo_diffv_diffv.F90 b2mwqt_*.F90 b2mwmv_dv_dv.F90 b2mwit_dv_dv.F90 b2mod_running_average_diffv_diffv.F90 b2mod_geo_diffv_diffv.F90 b2mod_batch_average_diffv_diffv.F90 b2mwq0_dv_dv.F90 b2mod_driver_diffv_diffv.F90 b2mnds_dv_dv.F90
sed -i -e 's/use b2mod_ad/use b2mod_ad_diffv_diffv/g' cfwuin.F cfwure.F
sed -i -e 's/call sfill/call sfill_nodiff_nodiff/g' b2xpne_st.F prvrt.F
sed -i -e 's/external sfill/external sfill_nodiff_nodiff/g' b2xpne_st.F prvrt.F
sed -i -e 's/call ifill/call ifill_nodiff_nodiff/g' prvrti.F
sed -i -e 's/external ifill/external ifill_nodiff_nodiff/g' prvrti.F

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
sed -i -e '/INTRINSIC HUGE/d' b2mod_neutrals_namelist_diffv_diffv.F90 b2mod_boundary_namelist_diffv_diffv.F90
sed -i -e '/INTRINSIC MAX/d' b2wdat_dv.F90 b2tqna_dv_dv.F90 b2news__dv_dv.F90 b2news_m_dv_dv.F90 b2stel_dv_dv.F90 b2tqna_dv_dv.F90 set_parameters_dv.F90 b2pwlprp_dv.F90
sed -i -e "s/USE B2MOD_NEUTR_SRC_SCALING_DIFFV/USE B2MOD_NEUTR_SRC_SCALING/g" b2mod_diag_diffv_diffv.F90 b2mod_driver_diffv_diffv.F90 b2mod_main_diffv_diffv.F90 b2stbr_dv_dv.F90
sed -i -e "s/USE B2MOD_NEUTR_SRC_SCALING_DIFFV/USE B2MOD_NEUTR_SRC_SCALING/g" b2mod_diag_diffv_diffv.F90 b2mod_driver_diffv_diffv.F90 b2mod_main_diffv_diffv.F90 b2stbr_dv_dv.F90
sed -i -e "s/USE B2MOD_PLASMA_DIFFV_DIFFV/USE B2MOD_PLASMA_DIFFV/g" heatdiff2D_dv_dv.F90 init_wall_dv_dv.F90

sed -i -e '/CALL MAXVAL_DV/a\    result10 = MAXVAL(abs0)' b2stcx_dv_dv.F90
sed -i '/MINVAL_DV/d' ./*.F90
sed -i '/MAXVAL_DV/d' ./*.F90

sed -i -e 's/B2UXUS_NODIFF/b2uxus/g' b2usco_dv_dv.F90 b2usmo_dv_dv.F90 b2uspo_dv_dv.F90 b2usht_dv_dv.F90

# add output of twice diff'ed residuals
sed -i -e 's/nout(0:10)/nout(0:11)/g' b2mod_main_diffv_diffv.F90 b2mndt_dv_dv.F90 b2mnds_dv_dv.F90 b2mod_driver_diffv_diffv.F90
sed -i -e "0,/\&       , 'faulty argument ninp, nout')/s/\&       , 'faulty argument ninp, nout')/\&       .AND. 1 .LE. nout(11), 'faulty argument ninp, nout')/g" b2mnds_dv_dv.F90
sed -i -e "0,/CALL B2MWQ0_NODIFF_NODIFF(nout(10), ns, switch)/s/CALL B2MWQ0_NODIFF_NODIFF(nout(10), ns, switch)/CALL B2MWQ0_NODIFF_NODIFF(nout(10), ns, switch)\n  idum(0) = ns\n  CALL CFWUIN(nout(11), 1, idum, 'ns')\n  CALL CFWUCH(nout(11), 120, lblmn, 'label')\n  CALL B2MWQ0_NODIFF_NODIFF(nout(11), ns, switch)/g" b2mnds_dv_dv.F90
sed -i -e 's/DATA nout \/60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70\//DATA nout \/60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71\//g' b2mod_main_diffv_diffv.F90
sed -i -e "0,/CALL CFOPEN(nout(10), 'b2ftraced', 'new', 'un\*formatted')/s/CALL CFOPEN(nout(10), 'b2ftraced', 'new', 'un\*formatted')/CALL CFOPEN(nout(10), 'b2ftraced', 'new', 'un\*formatted')\n    CALL CFOPEN(nout(11), 'b2ftracedd', 'new', 'un\*formatted')/g" b2mod_main_diffv_diffv.F90


sed -i -e "0,/compute norms of the differentiated corrections/s/compute norms of the differentiated corrections/compute norms of the differe11ntiated corrections/g" b2mndt_dv_dv.F90
sed -i -e "0,/compute norms of the differentiated corrections/s/compute norms of the differentiated corrections/compute norms of the differe22ntiated corrections/g" b2mndt_dv_dv.F90
sed -i -e "/compute norms of the differe22ntiated corrections/i\        CALL B2MXAR_DIFFV_DIFFV(ncv, ns, switch, geo, mpg, stdd%pl, \&\n\&                          stdd%dv, stdd%diag)" b2mndt_dv_dv.F90
sed -i -e '0,/CALL B2MXAC_DIFFV_NODIFF/s/B2MXAC_DIFFV_NODIFF/B2MXAC_DIFFV_NO11DIFF/g' b2mndt_dv_dv.F90
sed -i -e '0,/CALL B2MXAC_DIFFV_NODIFF(ncv, ns, std%dv, std%diag)/s/CALL B2MXAC_DIFFV_NODIFF(ncv, ns, std%dv, std%diag)/CALL B2MXAC_DIFFV_NODIFF(ncv, ns, std%dv, std%diag)\n        CALL B2MXAC_DIFFV_DIFFV(ncv, ns, stdd%dv, stdd%diag)/g' b2mndt_dv_dv.F90
sed -i -e 's/B2MXAC_DIFFV_NO11DIFF/B2MXAC_DIFFV_NODIFF/g' b2mndt_dv_dv.F90
sed -i -e '0,/FLUSH(nout(10))/s/FLUSH(nout(10))/FLUSH(nout(6666))/g' b2mndt_dv_dv.F90
sed -i -e '0,/FLUSH(nout(10)) /s/FLUSH(nout(10)) /FLUSH(nout(10)) \n            CALL B2MWQT_DIFFV_DIFFV(nout(11), ncv, ns, itim, \&\n\&                              b2mndt_itcnt, switch, geo, \&\n\&                              stdd%pl, stdd%dv, stdd%diag)\n            FLUSH(nout(11)) /g' b2mndt_dv_dv.F90
sed -i -e 's/FLUSH(nout(6666))/FLUSH(nout(10))/g' b2mndt_dv_dv.F90
sed -i -e "s/compute norms of the differe11ntiated corrections/compute norms of the differentiated corrections/g" b2mndt_dv_dv.F90
sed -i -e "s/compute norms of the differe22ntiated corrections/compute norms of the differentiated corrections/g" b2mndt_dv_dv.F90

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
sed -i -e 's/ISIZE1OFne/nCv/g' b2mndt_dv_dv.F90 b2news__dv_dv.F90 b2news_m_dv_dv.F90 b2npht_dv_dv.F90 b2npmo_dv_dv.F90 b2stel_dv_dv.F90
sed -i -e 's/ISIZE1OFkinrgy/nCv/g' b2mndt_dv_dv.F90
sed -i -e 's/ISIZE2OFkinrgy/0:ns-1/g' b2mndt_dv_dv.F90
sed -i -e 's/ISIZE2OFtemp/0:ns-1/g' b2mndt_dv_dv.F90
sed -i -e "s/REAL(r8), DIMENSION(:,/REAL(r8), DIMENSION(nbdirsmax0,/g" b2news__dv_dv.F90 b2news_m_dv_dv.F90
sed -i -e "s/REAL(kind=r8), DIMENSION(:,/REAL(kind=r8), DIMENSION(nbdirsmax0,/g" b2sihs__dv_dv.F90 b2stbc_dv_dv.F90
sed -i -e 's/ISIZE1OFgeo%cvvol/nCv/g' b2stbc_dv_dv.F90
sed -i -e 's/DIMENSION(nbdirsmax0, ISIZE1OFdv%fna_52(:, :, isb), 0:1)/DIMENSION(nbdirsmax0, nFc, 0:1)/g' b2tfnb_dv_dv.F90
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
sed -i -e 's/ISIZE1OFnn/nCv/g' b2npht_dv_dv.F90

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

sed -i -e 's/REAL :: result1/INTEGER :: result1/g' b2us_map_diffv_diffv.F90 b2ptrdl_dv.F90

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
sed -i -e 's/\& batch_av_all_init_dv, batch_av_all_save, batch_av_all_fin, \&/\& batch_av_all_save, batch_av_all_fin/g' b2mod_driver_diffv_diffv.F90
sed -i -e '/\& batch_av_all_fin_dv/d' b2mod_driver_diffv_diffv.F90
sed -i -e 's/run_av_init_dv0, run_av_init_dv, run_av_init_dv_dv, run_av_get_plasma/run_av_init_dv, run_av_get_plasma/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/run_av_get_plasma_dv, run_av_save, run_av_save_dv, run_av_fin/run_av_save, run_av_fin/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/run_av_fin_dv0, run_av_fin_dv, run_av_fin_dv_dv/run_av_fin_dv/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/dealloc_b2mod_facdrift_exb,\&/dealloc_b2mod_facdrift_exb/g' b2mod_driver_diffv_diffv.F90
sed -i -e '/\& dealloc_b2mod_facdrift_exb_dv/d' b2mod_driver_diffv_diffv.F90

sed -i -e 's/b2mn_init_dv, b2mn_init_dv_dv, b2mn_step, b2mn_step_dv0, b2mn_step_dv/b2mn_init_dv, b2mn_init_dv_dv, b2mn_step, b2mn_step_dv/g' b2mn_hess.F90
sed -i -e 's/b2mn_step_dv0, b2mn_fin, b2mn_fin_dv0/b2mn_fin, b2mn_fin_dv0/g' b2mn_hess.F90

sed -i -e "s/USE B2MOD_RESIDUALS_DIFFV/USE B2MOD_RESIDUALS/g" b2mod_diag_diffv_diffv.F90
sed -i -e 's/INTEGER, SAVE :: ank_tracing=0/INTEGER :: ank_tracing=0/g' b2mod_diag_diffv_diffv.F90
sed -i -e 's/USE B2MOD_ANOMALOUS_TRANSPORT_DIFFV/USE B2MOD_ANOMALOUS_TRANSPORT/g' b2txvspr_dv_dv.F90

sed -i '/EXTERNAL SUBINI/d' *.F90
sed -i '/EXTERNAL SUBEND/d' *.F90
sed -i -e '/EXTERNAL OUTPUT_DS_CV/d' b2mod_input_profile_diffv_diffv.F90
sed -i -e '/she0d(nd, :, :) = 0.d0/a\        sne0d(nd, :, :) = 0.d0' b2mod_input_profile_diffv_diffv.F90
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
sed -i '/EXTERNAL REPEAT/d' b2mod_geometry_diffv_diffv.F90 b2trzh_dv_dv.F90
sed -i '/EXTERNAL XERSET/d' b2mod_main_diffv_diffv.F90
sed -i '/EXTERNAL IPGETC/d' b2mod_driver_diffv_diffv.F90 b2trzh_dv_dv.F90
sed -i '/EXTERNAL B2TRCS/d' b2mod_driver_diffv_diffv.F90
sed -i '/EXTERNAL B2TRCF/d' b2mod_driver_diffv_diffv.F90
sed -i '/EXTERNAL B2TRACE/d' b2mod_driver_diffv_diffv.F90
sed -i '/EXTERNAL B2TRCI/d' b2mod_driver_diffv_diffv.F90
sed -i '/EXTERNAL B2MWTI/d' b2mod_driver_diffv_diffv.F90
sed -i '/EXTERNAL DEALLOC_B2MOD_MA28_FOR_US/d' b2mod_driver_diffv_diffv.F90

sed -i 's/B2XPNE_ST_NODIFF0/B2XPNE_ST/g' b2mod_running_average_diffv_diffv.F90
sed -i 's/MY_OUTI_US_NODIFF/MY_OUTI_US/g' b2wdat_dv.F90
sed -i 's/b2xppz_st/b2xppz_st_nodiff_nodiff/g' b2mod_usrtrc.F
sed -i 's/b2xppz/b2xppz_nodiff_nodiff/g' b2mod_blnm.F b2mod_usrtrc.F b2mod_ppout.F
sed -i 's/FIX_USER_NODIFF/FIX_USER/g' fix_user_dv_dv.F90
sed -i 's/call b2usr_loads(nx,ny,ns,nxtl,nxtr,BoRiS,wtarg_max)/call b2usr_loads_nodiff_nodiff(nx,ny,ns,nxtl,nxtr,BoRiS,\n     \&    wtarg_max)/g' b2mod_usrtrc.F
sed -i 's/call species/call species_nodiff/g' tallies.F
sed -i 's/b2xzef/b2xzef_nodiff_nodiff/g' b2mod_wrsep.F
sed -i 's/B2UXUS_DV_NODIFF/b2uxus_dv/g' b2usco_dv_dv.F90 b2usmo_dv_dv.F90 b2usht_dv_dv.F90 b2uspo_dv_dv.F90
sed -i -e '/SET_TGT_PERTURBATION_NODIFF/d' b2mn_hess.F90
sed -i -e '/EXTERNAL DEALLOCATEB2GRIDMAP/d' b2mod_geo_diffv_diffv.F90
sed -i -e 's/ERF_DV0/ERF_DV/g' erf_dv_dv.F90 b2mod_recycle_diffv_diffv.F90
sed -i -e '/EXTERNAL ERF_DV/d' b2mod_recycle_diffv_diffv.F90
sed -i -e 's/DIM_DV0/DIM_DV/g' dim_dv_dv.F90
sed -i 's/call intcell/call intcell_nodiff_nodiff/g' b2mod_mwti.F90
sed -i -e 's/B2WUZD_NODIFF/B2WUZD/g' b2mod_driver_diffv_diffv.F90 b2mnds_dv_dv.F90 b2mod_running_average_diffv_diffv.F90 b2mod_batch_average_diffv_diffv.F90 b2wucp_dv_dv.F90
sed -i -e 's/INVERT_MATRIX_DV0/INVERT_MATRIX_DV/g' invert_matrix_dv_dv.F90

sed -i -e 's/cvfpsi(icv) = SUM(arg1)\/mpg%cvvxp(icv, 2)/cvfpsi(icv) = SUM(gm%vxfpsi(verts))\/mpg%cvvxp(icv, 2)/g' b2us_geo_diffv_diffv.F90
sed -i -e '/arg1 = gm%vxfpsi(verts)/d' b2us_geo_diffv_diffv.F90

sed -i -e '/REAL(kind=r8) :: const_h/i\# ifndef CONSTANTS_PROVIDED' heatdiff1D_dv_dv.F90 ratstr_dv_dv.F90
sed -i -e '/PARAMETER (const_h=6.62607015e-34_R8)/a\# endif' heatdiff1D_dv_dv.F90 ratstr_dv_dv.F90

sed -i -e "s/\&'            , '')/\&'            )/g" b2mod_geometry_diffv_diffv.F90
sed -i -e "s/\&                 'b2mod_connectivity.geometryId(): iden', \&/\&                 'b2mod_connectivity.geometryId(): iden\&/g" b2mod_geometry_diffv_diffv.F90
sed -i -e "s/\&                 'tified GEOMETRY_LFS_SNOWFLAKE_MINUS')/\&                 tified GEOMETRY_LFS_SNOWFLAKE_MINUS')/g" b2mod_geometry_diffv_diffv.F90
sed -i -e "s/\&                 'tified GEOMETRY_LFS_SNOWFLAKE_PLUS')/\&                 tified GEOMETRY_LFS_SNOWFLAKE_PLUS')/g" b2mod_geometry_diffv_diffv.F90
sed -i -e "s/\&                   'b2mod_connectivity.geometryId(): id', \&/\&                   'b2mod_connectivity.geometryId(): id\&/g" b2mod_geometry_diffv_diffv.F90
sed -i -e "s/\&                   'entified grid GEOMETRY_DDN(_BOTTOM?)')/\&                   entified grid GEOMETRY_DDN(_BOTTOM?)')/g" b2mod_geometry_diffv_diffv.F90
sed -i -e "s/\&'                    , '')/\&'                    )/g" b2mod_geometry_diffv_diffv.F90

# some wrong allocation from tapenade
sed -i -e 's/ALLOCATE(rtdd%iscx(nbdirsmax, 0:rt%nscxmax-1), source=0)/ALLOCATE(rtdd%iscx(nbdirsmax0, nbdirsmax, 0:rt%nscxmax-1), source=0)/g' b2us_plasma_diffv_diffv.F90
sed -i -e 's/rtdd%iscx(nd0) = 0/rtdd%iscx = 0/g' b2us_plasma_diffv_diffv.F90
sed -i -e 's/ALLOCATE(rtd0%iscx(0:rt%nscxmax-1), source=0)/ALLOCATE(rtd0%iscx(nbdirsmax0, 0:rt%nscxmax-1), source=0)/g' b2us_plasma_diffv_diffv.F90
sed -i -e 's/rtd0%iscx(nd0) = 0/rtd0%iscx = 0/g' b2us_plasma_diffv_diffv.F90
sed -i -e 's/ALLOCATE(rtd%iscx(0:rt%nscxmax-1), source=0)/ALLOCATE(rtd%iscx(nbdirsmax, 0:rt%nscxmax-1), source=0)/g' b2us_plasma_diffv_diffv.F90
sed -i -e 's/rtd%iscx(nd) = 0/rtd%iscx = 0/g' b2us_plasma_diffv_diffv.F90
sed -i -e 's/ALLOCATE(state_extd0%is_neutral(0:ns_ext-1))/ALLOCATE(state_extd0%is_neutral(nbdirsmax0, 0:ns_ext-1))/g' b2us_plasma_diffv_diffv.F90
sed -i -e 's/state_extd0%is_neutral(nd0) = 0.D0/state_extd0%is_neutral(nd0, :) = .false./g' b2us_plasma_diffv_diffv.F90

# wrong initialization from tapenade
sed -i -e 's/userfluxparmd0(:, 0:0) = 0.D0/userfluxparmd0(:, :, :) = 0.D0/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/userfluxparmdd(:, 0:0) = 0.D0/userfluxparmdd(:, :, :, :) = 0.D0/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/enepardd(:, 0:0) = 0.D0/enepardd(:, :, :, :) = 0.D0/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/enipardd(:, 0:0) = 0.D0/enipardd(:, :, :, :) = 0.D0/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/potpardd(:, 0:0) = 0.D0/potpardd(:, :, :, :) = 0.D0/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/cfnormd0(:, 0:0) = 0.D0/cfnormd0(:, :) = 0.D0/g' b2usr_cost_function_dv_dv.F90
sed -i -e 's/voldd0(:, 0:0) = 0.D0/voldd0(:, :) = 0.D0/g' b2usr_cost_function_dv_dv.F90
sed -i -e 's/cfnormdd(:, 0:0) = 0.D0/cfnormdd(:, :, :) = 0.D0/g' b2usr_cost_function_dv_dv.F90
sed -i -e 's/volddd(:, 0:0) = 0.D0/volddd(:, :, :) = 0.D0/g' b2usr_cost_function_dv_dv.F90

# disappearing argument in call to calcflow in b2tfnb
sed -i -e 's/\&               fna_32(:, :, :, :, isb), dummyzerodiffd0, dummyzerodiffd\&/\&               fna_32(:, :, :, :, isb), dv%fna_52(:, :, isb), dummyzerodiffd0, dummyzerodiffd\&/g' b2tfnb_dv_dv.F90

# disappearing argument in calls to b2xazpy in b2stbc
sed -i -e 's/CALL B2SAXPY_DV_DV(ncv, switch%sna0ep, dummyzerodiffd/CALL B2SAXPY_DV_DV(ncv, switch%sna0ep, geo%cvvol, dummyzerodiffd/g' b2stbc_dv_dv.F90
sed -i -e 's/CALL B2SAXPY_DV_DV(ncv, switch%she0ep, dummyzerodiffd/CALL B2SAXPY_DV_DV(ncv, switch%she0ep, geo%cvvol, dummyzerodiffd/g' b2stbc_dv_dv.F90
sed -i -e 's/CALL B2SAXPY_DV_DV(ncv, switch%shi0ep, dummyzerodiffd/CALL B2SAXPY_DV_DV(ncv, switch%shi0ep, geo%cvvol, dummyzerodiffd/g' b2stbc_dv_dv.F90

# missing calls to some diff'ed functions CONTAINed inside b2stbc_phys
sed -i -e '0,/CONTAINS/s/CONTAINS/CONTA11INS/g' b2stbc_phys_dv_dv.F90
sed -i -e "/CONTA11INS/a\!\n  FUNCTION PIT(icv)\n  USE B2MOD_DIFFSIZES\n    IMPLICIT NONE\n    INTEGER, INTENT(IN) :: icv\n    REAL(kind=r8) :: pit\n    INTRINSIC ABS\n    REAL(kind=r8) :: abs23\n    IF (geo%cvbb(icv, 0) .GE. 0.) THEN\n      abs23 = geo%cvbb(icv, 0)\n    ELSE\n      abs23 = -geo%cvbb(icv, 0)\n    END IF\n!\n    pit = abs23/geo%cvbb(icv, 3)\n!\n    RETURN\n  END FUNCTION PIT" b2stbc_phys_dv_dv.F90
sed -i -e "/CONTA11INS/a\  FUNCTION SHEATH_G(t0)\n    USE B2MOD_TYPES\n  USE B2MOD_DIFFSIZES\n    IMPLICIT NONE\n    REAL(kind=r8) :: sheath_g, t0\n    INTRINSIC SQRT, ERF, EXP\n    REAL(kind=r8) :: result12\n    REAL(kind=r8) :: result21\n    REAL(kind=r8) :: arg13\n!\n    result12 = SQRT(pi)\n    result21 = ERF(t0)\n    arg13 = t0**2\n    sheath_g = 1.0_R8 + result12*t0*(1+result21)*EXP(arg13)\n!\n    RETURN\n  END FUNCTION SHEATH_G\n" b2stbc_phys_dv_dv.F90
sed -i -e 's/CONTA11INS/CONTAINS/g' b2stbc_phys_dv_dv.F90


