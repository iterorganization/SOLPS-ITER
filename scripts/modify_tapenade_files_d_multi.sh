
# all files are .f90 files, move them to .F90 extension
move_to_F90.sh
rm b2uxus_dv.F90 solve_covariance_dv.F90 calc_res_fp_dv.F90
collect_nodiff_d_multi.sh
rm samax_dv.F90 smin_dv.F90 smax_dv.F90 get_jsep_dv.F90 my_outi_us_dv.F90 
mv b2mn_dv.F90 b2mn_d.F90

sed -i "/INCLUDE 'DIFFSIZES.inc'/d" ./*.F90
sed -i "/USE DIFFSIZES/d" ./*.F90
sed -i -e "/IMPLICIT NONE/i\  USE B2MOD_DIFFSIZES" ./*.F90

sed -i -e 's/ISIZE1OFfceb/mpg%nFc/g' b2us_geo_diffv.F90

sed -i -e 's/DIMENSION(SIZE(x1, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x2, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x3, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x4, 1), SIZE(x4, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x5, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x6, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x7, 1), SIZE(x7, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diffv.F90
sed -i -e 's/ISIZE1OFarg1/mpg%nCv/g' b2mod_driver_diffv.F90
sed -i -e 's/ISIZE1OFarg1/nCv/g' b2npmo_dv.F90 b2stbr_phys_dv.F90 b2tqna_dv.F90 eirene_f30f31_dv.F90 b2mod_recycle_diffv.F90 b2sikt_dv.F90 b2trcl_dv.F90
sed -i -e 's/ISIZE1OFabs/mpg%nCv/g' b2mod_driver_diffv.F90
sed -i -e 's/ISIZE2OFabs/0:state%pl%ns-1/g' b2mod_driver_diffv.F90
sed -i -e "s/REAL(r8), DIMENSION(:,/REAL(r8), DIMENSION(nbdirsmax,/g" b2news__dv.F90
sed -i -e 's/ISIZE1OFdv%fch_pi_c/nCv/g' b2news__dv.F90
sed -i -e 's/ISIZE1OFfch_p/nFc/g' b2news__dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd0/INTEGER :: dummyzerodiffd0(nbdirsmax)/g" b2mod_recycle_diffv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd29/INTEGER :: dummyzerodiffd29(nbdirsmax)/g" b2news__dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd33/INTEGER :: dummyzerodiffd33(nbdirsmax)/g" b2news__dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd37/INTEGER :: dummyzerodiffd37(nbdirsmax)/g" b2news__dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd54/INTEGER :: dummyzerodiffd54(nbdirsmax)/g" b2news__dv.F90
sed -i -e 's/ISIZE1OFtemp/nCv/g' b2news__dv.F90 b2tfcc_dv.F90 b2tfnb_dv.F90 b2tqna_dv.F90 b2xpic_dv.F90 b2us_feedback_diffv.F90 b2npmo_dv.F90 b2sikt_dv.F90 b2tral_dv.F90 b2trcl_dv.F90 b2mndt_dv.F90
sed -i -e 's/ISIZE1OFlnlam/nCv/g' b2npmo_dv.F90 b2trcl_dv.F90
sed -i -e 's/ISIZE1OFcvsa/nFc/g' b2npmo_dv.F90
sed -i -e 's/ISIZE1OFresult1/nCv/g' b2npmo_dv.F90 b2tqna_dv.F90 b2sikt_dv.F90 b2trcl_dv.F90
sed -i -e 's/ISIZE1OFcvvol/nCv/g' b2sikt_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd10/INTEGER :: dummyzerodiffd10(nbdirsmax)/g" b2npmo_dv.F90 
sed -i -e "s/INTEGER :: dummyzerodiffd14/INTEGER :: dummyzerodiffd14(nbdirsmax)/g" b2npmo_dv.F90
sed -i -e 's/ISIZE1OFcvhz/nCv/g' b2nxfv_dv.F90
sed -i -e 's/ISIZE1OFvxhz/nVx/g' b2nxfv_dv.F90
sed -i -e 's/ISIZE1OFfcqalf/nFc/g' b2sian_dv.F90 b2stbc_dv.F90 b2stbc_phys_dv.F90 b2tfhe__dv.F90 b2tfhi__dv.F90 b2trno_dv.F90 b2tfch__dv.F90 b2tfnb_dv.F90 b2tinnt_dv.F90 b2tvskt_dv.F90 b2tfrn_dv.F90
sed -i -e 's/ISIZE1OFgeo%vxonedbsq/nVx/g' b2sihs__dv.F90
sed -i -e 's/ISIZE1OFgeo%cvonedbsq/nCv/g' b2sihs__dv.F90
sed -i -e "s/REAL(kind=r8), DIMENSION(:,/REAL(kind=r8), DIMENSION(nbdirsmax,/g" b2sihs__dv.F90 b2stbc_dv.F90
sed -i -e 's/ISIZE1OFgeo%cvvol/nCv/g' b2stbc_dv.F90
sed -i -e 's/ISIZE1OFcvbb/nCv/g' b2stbm_dv.F90 b2tfnb_dv.F90 b2tqna_dv.F90 b2tvspa_dv.F90 b2sikt_dv.F90 b2trno_dv.F90 b2siav_dv.F90 b2trcl_dv.F90 b2tvsq_dv.F90
sed -i -e 's/ISIZE1OFfcbb/nFc/g' b2siav_dv.F90 b2tvskt_dv.F90 b2tvspa_dv.F90 b2tvsq_dv.F90
sed -i -e 's/ISIZE1OFvxbb/nVx/g' b2siav_dv.F90
sed -i -e 's/ISIZE1OFcvsahz_eff/nFc/g' b2stbr_phys_dv.F90 b2mod_recycle_diffv.F90
sed -i -e 's/ISIZE2OFcvsahz_eff/0:1/g' b2stbr_phys_dv.F90 b2mod_recycle_diffv.F90
sed -i -e 's/ISIZE1OFcvsahz/nFc/g' b2stbr_phys_dv.F90 b2mod_recycle_diffv.F90
sed -i -e 's/ISIZE2OFcvsahz/0:1/g' b2stbr_phys_dv.F90 b2mod_recycle_diffv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd0/INTEGER :: dummyzerodiffd0(nbdirsmax)/g" b2stbr_phys_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd4/INTEGER :: dummyzerodiffd4(nbdirsmax)/g" b2stbr_phys_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd6/INTEGER :: dummyzerodiffd6(nbdirsmax)/g" b2stbr_phys_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd1/INTEGER :: dummyzerodiffd1(nbdirsmax)/g" b2tanml_dv.F90
sed -i -e 's/ISIZE1OFcdpa/nFc/g' b2tfcc_dv.F90 b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFne/nCv/g' b2tfhe__dv.F90 b2tfrn_dv.F90
sed -i -e 's/ISIZE1OFni/nCv/g' b2tfhi__dv.F90 
sed -i -e 's/ISIZE1OFcdna/nFc/g' b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFfchz/nFc/g' b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFpa/nCv/g' b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFfnapsch/nFc/g' b2tfnb_dv.F90
sed -i -e 's/DIMENSION(:, ISIZE1OFdv%fna_52(:, :, isb), 0:1)/DIMENSION(nbdirsmax, nFc, 0:1)/g' b2tfnb_dv.F90
sed -i -e 's/DIMENSION(:, SIZE(st_ext%za, 1), SIZE(st_ext%za, 2))/DIMENSION(nbdirsmax, SIZE(st_ext%za, 1), SIZE(st_ext%za, 2))/g' b2sral_dv.F90
sed -i -e 's/ISIZE1OFfchc/nFc/g' b2tinnt_dv.F90
sed -i -e "s/cfdna(0, is), cfdnad(:, 0, is)/cfdna(0, is), cfdnad(1:nbdirs, 0, is)/g" b2tqna_dv.F90
sed -i -e "s/cfvla(0, is), cfvlad(:, 0, is)/cfvla(0, is), cfvlad(1:nbdirs, 0, is)/g" b2tqna_dv.F90
sed -i -e "s/cfhci(0, is), cfhcid(:, 0, is)/cfhci(0, is), cfhcid(1:nbdirs, 0, is)/g" b2tqna_dv.F90
sed -i -e "s/cfdpa(0, is), cfdpad(:, 0, is)/cfdpa(0, is), cfdpad(1:nbdirs, 0, is)/g" b2tqna_dv.F90
sed -i -e "s/cfvsa(0, is), cfvsad(:, 0, is)/cfvsa(0, is), cfvsad(1:nbdirs, 0, is)/g" b2tqna_dv.F90
sed -i -e 's/ISIZE1OFcvbzb/nCv/g' b2tral_dv.F90
sed -i -e 's/ISIZE1OFco%cthi/nFc/g' b2tral_dv.F90
sed -i -e 's/ISIZE2OFco%cthi/0:ns-1/g' b2tral_dv.F90
sed -i -e 's/ISIZE1OFco%cthe/nFc/g' b2tral_dv.F90
sed -i -e 's/ISIZE2OFco%cthe/0:ns-1/g' b2tral_dv.F90
sed -i -e 's/DIMENSION(:/DIMENSION(nbdirsmax/g' b2tral_dv.F90 b2trno_dv.F90
sed -i -e 's/ISIZE1OFco%fllim0fhi/nfc/g' b2trno_dv.F90
sed -i -e 's/ISIZE3OFco%fllim0fhi/0:ns-1/g' b2trno_dv.F90
sed -i -e 's/CHARACTER(len=\*) :: arg1/CHARACTER(len=20) :: arg1/g' b2usco_dv.F90
sed -i -e 's/CHARACTER(len=\*) :: arg10/CHARACTER(len=20) :: arg10/g' b2usmo_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd1/INTEGER :: dummyzerodiffd1(nbdirsmax)/g" b2xpve_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd4/INTEGER :: dummyzerodiffd4(nbdirsmax)/g" b2xpve_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd7/INTEGER :: dummyzerodiffd7(nbdirsmax)/g" b2xpve_dv.F90
sed -i -e 's/ISIZE1OFarg1/20/g' calc_err_dv.F90
sed -i -e 's/ISIZE1OFarg2/20/g' calc_err_dv.F90
sed -i -e 's/REAL :: result1$/integer :: result1/g' b2mod_input_profile_diffv.F90
sed -i -e 's/#NBDirsMax#/nbdirsmax/g' ./*.F90 #why?
sed -i -e 's/#DIM_DV#/DIM_DV/g' dim_dv.F90 #why?
sed -i -e 's/DAMAX_NODIFF/samax/g' b2mndt_dv.F90 b2mxac_dv.F90 b2stcx_dv.F90 b2stel_dv.F90
sed -i -e 's/damax/samax/g' b2stcx_dv.F90
sed -i -e 's/SMIN_NODIFF/smin/g' ./*.F90
sed -i -e 's/SMAX_NODIFF/smax/g' ./*.F90
sed -i -e 's/calc_dist(/calc_dist_nodiff(/g' b2wdat.F
sed -i -e 's/calc_dist_f/calc_dist_f_nodiff/g' b2wdat.F
sed -i -e 's/result10 = ISGHOSTCELL(cflag(:, :, cellflag_type))/result10 = count(ISGHOSTCELL(cflag(:, :, cellflag_type)))/g' b2mod_geo2_diffv.F90
sed -i -e 's/IF (COUNT(result10) .EQ. 0) THEN/IF (result10 .EQ. 0) THEN/g' b2mod_geo2_diffv.F90
sed -i -e 's/result10 = ISUNUSEDCELL(cflag(0:nx-1, 0:ny-1, cellflag_type))/result10 = count(ISUNUSEDCELL(cflag(0:nx-1, 0:ny-1, cellflag_type)))/g' b2mod_geo2_diffv.F90
sed -i -e 's/fullgrid = COUNT(result10) .EQ. 0/fullgrid = result10 .EQ. 0/g' b2mod_geo2_diffv.F90
sed -i '/REAL(kind=r8) :: const_h/i\# ifndef CONSTANTS_PROVIDED' heatdiff1D_dv.F90 ratstr_dv.F90
sed -i '/PARAMETER (const_h/a\# endif' heatdiff1D_dv.F90 ratstr_dv.F90
sed -i -e 's/md0%cfoncv(nd, 1:m%ncf) = 0.D0/md0%cfoncv(nd, 1:m%ncf) = .true./g' b2us_map_diffv.F90
sed -i -e 's/d0%cvonclosedsurface(nd, 1:m%ncv) = 0.D0/d0%cvonclosedsurface(nd, 1:m%ncv) = .true./g' b2us_map_diffv.F90
sed -i -e 's/state_extd%is_neutral(nd, 0:ns_ext-1) = 0.D0/state_extd%is_neutral(nd, 0:ns_ext-1) = .true./g' b2us_plasma_diffv.F90
sed -i -e 's/INTEGER, SAVE :: ank_tracing=0/INTEGER :: ank_tracing=0/g' b2mod_diag_diffv.F90
sed -i '/INTRINSIC HUGE/d' b2mod_neutrals_namelist_diffv.F90 b2mod_geo2_diffv.F90
sed -i -e 's/LOGICAL :: result10/INTEGER :: result10/g' b2mod_geo2_diffv.F90
sed -i '/INTRINSIC MAX/d' b2stbc_fb_dv.F90 b2stbc_phys_dv.F90 b2usr_cost_function_dv.F90 fix_user_dv.F90

sed -i '/EXTERNAL SUBINI/d' *.F90
sed -i '/EXTERNAL SUBEND/d' *.F90
sed -i '/EXTERNAL RESTART_MA28_FOR_US/d' b2news__dv.F90 b2npmo_dv.F90 b2usht_dv.F90  
sed -i '/EXTERNAL DEALLOC_B2MOD_MA28_FOR_US/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL ISGHOSTCELL/d' b2us_prep_diffv.F90 b2mod_geo2_diffv.F90 b2mod_geo_diffv.F90
sed -i '/LOGICAL :: ISGHOSTCELL/d' b2us_prep_diffv.F90 b2mod_geo2_diffv.F90 b2mod_geo_diffv.F90
sed -i '/EXTERNAL ISREALCELL/d' b2us_prep_diffv.F90 b2mod_geo_diffv.F90 b2mod_geo2_diffv.F90
sed -i '/LOGICAL :: ISREALCELL/d' b2us_prep_diffv.F90 b2mod_geo_diffv.F90 b2mod_geo2_diffv.F90
sed -i '/EXTERNAL ISINDOMAIN/d' b2mod_geo_diffv.F90 b2mod_geo2_diffv.F90
sed -i '/LOGICAL :: ISINDOMAIN/d' b2mod_geo_diffv.F90 b2mod_geo2_diffv.F90
sed -i '/EXTERNAL ISCLASSICALGRID/d' b2mod_geo_diffv.F90
sed -i '/LOGICAL :: ISCLASSICALGRID/d' b2mod_geo_diffv.F90
sed -i '/EXTERNAL ISBOUNDARYCELL/d' b2us_prep_diffv.F90
sed -i '/LOGICAL :: ISBOUNDARYCELL/d' b2us_prep_diffv.F90
sed -i '/EXTERNAL ISUNUSEDCELL/d' b2us_prep_diffv.F90 b2mod_geo2_diffv.F90 b2xvsg_dv.F90 b2mod_geo_diffv.F90
sed -i '/LOGICAL :: ISUNUSEDCELL/d' b2us_prep_diffv.F90 b2mod_geo2_diffv.F90 b2xvsg_dv.F90 b2mod_geo_diffv.F90
sed -i '/EXTERNAL ISCLASSICALGRID/d' b2us_prep_diffv.F90 
sed -i '/LOGICAL :: ISCLASSICALGRID/d' b2us_prep_diffv.F90 
sed -i -e 's/MSTEP_NODIFF/MSTEP/g' heatdiff1D_dv.F90
sed -i -e 's/LINES2C_NODIFF/LINES2C/g' heatdiff1D_dv.F90
sed -i '/EXTERNAL OR/d' b2stbr_dv.F90
sed -i '/INTEGER :: OR/d' b2stbr_dv.F90
sed -i -e 's/B2UXUS_NODIFF/B2UXUS/g' b2usco_dv.F90 b2usmo_dv.F90 b2usht_dv.F90 b2uspo_dv.F90
sed -i -e 's/GET_JSEP_NODIFF/GET_JSEP/g' ./*.F90
sed -i -e 's/CFWURE_NODIFF/CFWURE/g' ./*.F90
sed -i '/EXTERNAL IPSETC/d' b2mnds_dv.F90 
sed -i '/EXTERNAL IPPRHP/d' b2mnds_dv.F90 
sed -i '/EXTERNAL ANINT/d' b2xvcp_dv.F90 
sed -i '/REAL(kind=r8) :: ANINT/d' b2xvcp_dv.F90
sed -i '/EXTERNAL XERSET/d' b2mod_main_diffv.F90
sed -i '/EXTERNAL IPGETC/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL B2TRCS/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL B2TRCF/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL B2TRACE/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL B2TRCI/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL B2MWTI/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL OUTPUT_DS/d' b2mod_input_profile_diffv.F90
sed -i '/TRIM_DV/d' b2mod_main_diffv.F90
sed -i 's/FIX_USER_NODIFF/FIX_USER/g' fix_user_dv.F90
sed -i 's/b2usr_loads/b2usr_loads_nodiff/g' b2mod_usrtrc.F
sed -i 's/b2xppz_st/b2xppz_st_nodiff/g' b2mod_usrtrc.F
sed -i 's/b2xzef_st/b2xzef_st_nodiff/g' b2mod_wrsep.F
sed -i 's/fill/fill_nodiff/g' prvrt*.F

sed -i -e 's/PUBLIC :: to_struct_plasma_dv,/PUBLIC :: /g' b2us_prep_diffv.F90
sed -i '/PUBLIC :: alloc_switches_dv/d' b2mod_switches_diffv.F90
sed -i '/& check_values_switches_dv/d' b2mod_switches_diffv.F90
sed -i -e 's/alloc_b2mod_balance_dv, dealloc_b2mod_balance/dealloc_b2mod_balance/g' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_b2mod_balance_dv, dealloc_b2mod_eirene_sources/dealloc_b2mod_eirene_sources/g' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_b2mod_eirene_sources_dv, balance_average/balance_average/g' b2mod_driver_diffv.F90
sed -i -e 's/run_av_get_plasma, run_av_get_plasma_dv, run_av_save, run_av_save_dv/run_av_get_plasma, run_av_save/g' b2mod_driver_diffv.F90
sed -i -e 's/batch_av_all_init_dv, batch_av_all_save, batch_av_all_fin, &/batch_av_all_save, batch_av_all_fin/g' b2mod_driver_diffv.F90
sed -i '/& batch_av_all_fin_dv/d' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_b2mod_wall, dealloc_b2mod_wall_dv/dealloc_b2mod_wall/g' b2mod_driver_diffv.F90
sed -i -e 's/ONLY : dealloc_b2mod_ysmp_sdrv, &/ONLY : dealloc_b2mod_ysmp_sdrv/g' b2mod_driver_diffv.F90
sed -i '/& dealloc_b2mod_ysmp_sdrv_dv/d' b2mod_driver_diffv.F90
sed -i -e 's/\& write_b2us_feedback_dv, init_feedback, init_feedback_dv, \&/\& init_feedback, \&/g' b2mod_driver_diffv.F90
sed -i -e 's/\& dealloc_feedback, dealloc_feedback_dv/\& dealloc_feedback/g' b2mod_driver_diffv.F90
sed -i -e 's/\& read_b2mod_par_opt, read_b2mod_par_opt_dv, par_opt_phys, par_opt_physd/\& read_b2mod_par_opt, par_opt_phys, par_opt_physd, nsigma_opt/g' b2mod_driver_diffv.F90


sed -i -e 's/alloc_geometry_dv, dealloc_geometry_dv, read_geometry_dv, &/alloc_geometry_dv, dealloc_geometry_dv, read_geometry_dv/g' b2us_geo_diffv.F90
sed -i '/& check_geometry_dv/d' b2us_geo_diffv.F90
sed -i -e 's/read_b2fgmtry_dv, read_b2fstate_dv, write_b2fstate_dv, &/read_b2fgmtry_dv, read_b2fstate_dv/g' b2us_io_diffv.F90
sed -i '/& write_b2fplasma_dv/d' b2us_io_diffv.F90
sed -i -e 's/USE B2MOD_RESIDUALS_DIFFV/USE B2MOD_RESIDUALS/g' b2mod_diag_diffv.F90 b2us_prep_diffv.F90 b2mwmv_dv.F90
sed -i -e 's/=> NULL()/= 0.0_R8/g' b2mndt_dv.F90 b2sral_dv.F90

sed -i -e 's/CHARACTER(len=13), DIMENSION(:), DIMENSION(:, :), ALLOCATABLE ::/CHARACTER(len=13), DIMENSION(:, :), ALLOCATABLE ::/g' b2us_plasma_diffv.F90
sed -i -e 's/\&     text/\&     text(:,:)/g' b2us_plasma_diffv.F90
sed -i -e 's/DO ii2=1,SIZE(state_extd%text(ii1), 1)/DO ii2=1,SIZE(state_extd%text, 2)-1/g' b2us_plasma_diffv.F90
sed -i -e 's/state_extd%text(ii1)(nd, ii2) =/state_extd%text(nd, ii2) =/g' b2us_plasma_diffv.F90

sed -i -e 's/MY_OUT_US_NODIFF/MY_OUT_US/g' ./*.F90
sed -i -e 's/sort_faces/sort_faces_nodiff/g' b2wdat.F

# remove when b2ual_* are excluded from differentiation
sed -i -e '/INTEGER :: regiontype_yedge/d' b2mod_ual_io_grid_diffv.F90
sed -i -e '/INTEGER :: regiontype_xedge/d' b2mod_ual_io_grid_diffv.F90
sed -i -e '/INTEGER :: regiontype_cell/d' b2mod_ual_io_grid_diffv.F90

# for residuals calculation
sed -i -e 's/B2MXAR_DIFF/B2MXAR_DIFFv/g' b2mndt_dv.F90
sed -i -e 's/B2MXAC_DIFF/B2MXAC_DIFFv/g' b2mndt_dv.F90
sed -i -e 's/B2MWQT_DIFF/B2MWQT_DIFFv/g' b2mndt_dv.F90
sed -i -e "/CALL B2MWQ0_NODIFF(nout(4), ns, switch)/a\  call b2mwq0_nodiff(nout(10), ns, switch)" b2mnds_dv.F90
sed -i -e "/CALL B2MWQ0_NODIFF(nout(4), ns, switch)/a\  call cfwuch(nout(10), 120, lblmn, 'label')" b2mnds_dv.F90
sed -i -e "/CALL B2MWQ0_NODIFF(nout(4), ns, switch)/a\  call cfwuin(nout(10), 1, idum, 'ns')" b2mnds_dv.F90
sed -i -e "/CALL B2MWQ0_NODIFF(nout(4), ns, switch)/a\  idum(0) = ns" b2mnds_dv.F90
sed -i -e "/CALL ALLOC_MAPPING_DV(mpg, mpgd, nbdirs)/i\    call cfopen(nout(10),'b2ftraced','new','un*formatted')" b2mod_main_diffv.F90
sed -i -e '0,/CALL B2MXAC_NODIFF(ncv, ns, st%dv, st%diag)/s//CALL B2MXAC_NODIFF(ncv, ns, st%dv, st%diag)\n          CALL B2MXAC_DIFFv(ncv, ns, std%dv, std%diag)/' b2mndt_dv.F90
sed -i -e '0,/CALL B2MXAC_NODIFF(ncv, ns, st%dv, st%diag)/s//CALL B2MXAC_NODIFF(ncv, ns, st%dv, st%diag)\n\!*      ..compute norms of the differentiated corrections/' b2mndt_dv.F90
sed -i -e '0,/CALL B2MXAC_NODIFF(ncv, ns, st%dv, st%diag)/s//CALL B2MXAC_NODIFF(ncv, ns, st%dv, st%diag)\n\&                      std%pl, std%dv, std%diag)/' b2mndt_dv.F90
sed -i -e '0,/CALL B2MXAC_NODIFF(ncv, ns, st%dv, st%diag)/s//CALL B2MXAC_NODIFF(ncv, ns, st%dv, st%diag)\n          CALL B2MXAR_DIFFv(nCv, ns, nnreg(0), switch%BoRiS, switch, geo, mpg, \&/' b2mndt_dv.F90
sed -i -e '0,/CALL B2MXAC_NODIFF(ncv, ns, st%dv, st%diag)/s//CALL B2MXAC_NODIFF(ncv, ns, st%dv, st%diag)\n\!*      ..compute norms of the differentiated residuals/' b2mndt_dv.F90
sed -i -e "0,/IF (MOD(ncall_b2mndt, ntim_step_out) .EQ. 0) THEN/s//IF (MOD(ncall_b2mndt, ntim_step_out) .EQ. 0) THEN\n              FLUSH(nout(10))/" b2mndt_dv.F90
sed -i -e '0,/IF (MOD(ncall_b2mndt, ntim_step_out) .EQ. 0) THEN/s//IF (MOD(ncall_b2mndt, ntim_step_out) .EQ. 0) THEN\n\&               switch%BoRiS, switch, geo, std%pl, std%dv, std%diag)/' b2mndt_dv.F90
sed -i -e '0,/IF (MOD(ncall_b2mndt, ntim_step_out) .EQ. 0) THEN/s//IF (MOD(ncall_b2mndt, ntim_step_out) .EQ. 0) THEN\n              CALL B2MWQT_DIFFv(nout(10), ncv, ns, itim, b2mndt_itcnt, \&/' b2mndt_dv.F90
sed -i -e '0,/IF (MOD(ncall_b2mndt, ntim_step_out) .EQ. 0) THEN/s//IF (MOD(ncall_b2mndt, ntim_step_out) .EQ. 0) THEN\n\!*      ..output differentiated residuals/' b2mndt_dv.F90

sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_diffv.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_diffv.F90
sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_dv.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_dv.F90

sed -i -e "/END TYPE MAPPING_DIFFV/i\      INTEGER :: ncv(nbdirsmax), nfc(nbdirsmax), nvx(nbdirsmax), ncg(nbdirsmax), &" b2us_map_diffv.F90
sed -i -e "/END TYPE MAPPING_DIFFV/i\&     nci(nbdirsmax), ncmxvx(nbdirsmax), ncmxfc(nbdirsmax), nvmxcv(nbdirsmax), nvmxfc(nbdirsmax),&" b2us_map_diffv.F90
sed -i -e "/END TYPE MAPPING_DIFFV/i\&     nfs(nbdirsmax), nbc(nbdirsmax), mxnbc(nbdirsmax), nrc(nbdirsmax), mxnrc(nbdirsmax),&" b2us_map_diffv.F90
sed -i -e "/END TYPE MAPPING_DIFFV/i\&     ncmxnv(nbdirsmax), ncf(nbdirsmax), mxncf(nbdirsmax)" b2us_map_diffv.F90

sed -i -e '/par_opt_physd(nd, 1:npar_opt) = 0.D0/a\        par_opt_physd(nd, nd) = 1.0_R8' b2mod_driver_diffv.F90

sed -i -e "s/b2mod_main_diff/b2mod_main_diffv/g" b2optim_*.F*
sed -i -e "s/b2mod_ad_diff/b2mod_ad_diffv/g" b2optim_*.F*
sed -i -e "s/b2mod_par_opt_diff/b2mod_par_opt_diffv/g" b2optim_*.F* set_parameters.F
sed -i -e "s/b2mn_init_diff/b2mn_init_dv/g" b2optim_*.F*
sed -i -e "s/b2mn_fin_diff/b2mn_fin_dv/g" b2optim_*.F*
sed -i -e "s/b2mn_step_diff/b2mn_step_dv/g" b2optim_*.F*
sed -i -e "s/b2us_data_diff/b2us_data_diffv/g" b2optim_*.F*
sed -i -e "s/b2us_io_diff/b2us_io_diffv/g" b2optim_*.F*
sed -i -e "s/b2mod_b2cmpa_diff/b2mod_b2cmpa_diffv/g" b2optim_*.F*
sed -i -e "s/b2mod_transport_namelist_diff/b2mod_transport_namelist_diffv/g" b2optim_*.F* set_parameters.F
sed -i -e "s/b2mod_input_profile_diff/b2mod_input_profile_diffv/g" b2optim_*.F* set_parameters.F
sed -i -e "s/b2mod_boundary_namelist_diff/b2mod_boundary_namelist_diffv/g" b2optim_*.F* set_parameters.F
sed -i -e "s/b2mod_switches_diff/b2mod_switches_diffv/g" set_parameters.F
sed -i -e "s/b2mod_neutrals_namelist_diff/b2mod_neutrals_namelist_diffv/g" set_parameters.F
sed -i -e "s/geodiff/geod/g" b2optim_*.F*
sed -i -e "s/mpgdiff/mpgd/g" b2optim_*.F*
sed -i -e "s/statediff/stated/g" b2optim_*.F*
sed -i -e "s/state_extdiff/state_extd/g" b2optim_*.F*
sed -i -e "s/switchdiff/switchd/g" b2optim_*.F*
sed -i -e "s/par_opt_physdiff/par_opt_physd/g" b2optim_*.F*
sed -i -e "s/state_ext, state_extd)/state_ext, state_extd, npar_opt)/g" b2optim_*.F*
sed -i -e "s/state_ext, state_extd, j, jdiff)/state_ext, state_extd, j, jdiff, npar_opt-nsigma_opt-nmean_opt-nshift_opt-ncorr_opt)/g" b2optim_*.F*
sed -i -e 's/jdiff(nncf)/jdiff(nbdirsmax,nncf)/g' b2optim_*.F*
sed -i -e "/subroutine EV_GRAD_F(/a\      use b2mod_diffsizes" b2optim_ipopt.F
sed -i -e "/subroutine FormFunctionGradient(/a\      use b2mod_diffsizes" b2optim_tao.F90
sed -i -e "s/g_v(ipar) = jdiff(1)/g_v(ipar) = jdiff(ipar,1)/g" b2optim_tao.F90
sed -i -e "s/grad(ipar) = DBLE(jdiff(1))/grad(ipar) = DBLE(jdiff(ipar,1))/g" b2optim_ipopt.F


# fixed point loop variables
sed -i -e "/REAL(kind=r8) :: min_areshe, min_areshi, min_aresco, res_quit, res_max/a\  real (kind=r8), save :: res_maxd" b2mod_driver_diffv.F90
sed -i -e '0,/REAL(kind=r8) :: EPOCH_SECONDS/s//REAL(kind=r8) :: EPOCH_SECONDS\n    LOGICAL, SAVE :: first_opt_call=.true./'  b2mod_driver_diffv.F90
sed -i -e '0,/res_max = 10.0_R8\*res_quit/s//res_max = 10.0_R8\*res_quit\n    res_maxd = 10.0_R8\*res_quit/'  b2mod_driver_diffv.F90
sed -i -e '0,/^! The FIXED_POINT.*/s/^! The FIXED_POINT.*/    first_opt_call = .false.\n    endif\n&/' b2mod_driver_diffv.F90
sed -i -e '0,/res_max = 0.0_R8/s/      res_max = 0.0_R8/      res_maxd = 0.0_R8\n      call calc_res_fp_multi(nbdirs, nCv, ns, switch%tn_style, \&\n\&       switch%solve_keps, stated%diag, res_maxd)\n&/' b2mod_driver_diffv.F90
sed -i -e "0,/WRITE(\*, \*) 'MAX RESIDUAL ', res_max/s//WRITE(\*, \*) 'MAX RESIDUAL ', res_max\n      WRITE(\*, \*) 'MAX TGT RESIDUAL ', res_maxd\n      res_max = max(res_max, res_maxd)/"  b2mod_driver_diffv.F90

## sed -i -e '0,/fb_rescaled(nd, :) = 0.D0/{0,/END DO/d;}'  b2mod_driver_diffv.F90 should try something else for inserting "     if (first_opt_call .and. .not.reset_gradient) then" and same for npar_opt when par_opt_physd is allocated
