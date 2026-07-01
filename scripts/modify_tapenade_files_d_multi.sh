
# all files are .f90 files, move them to .F90 extension
move_to_F90.sh
rm b2uxus_dv.F90 solve_covariance_dv.F90 calc_res_fp_dv.F90 cfwure_dv.F90 cfwuin_dv.F90 invert_matrix_dv.F90 b2mod_blns_dv.F90
collect_nodiff_d_multi.sh
rm damax_dv.F90 smin_dv.F90 smax_dv.F90 get_jsep_dv.F90 my_outi_us_dv.F90
mv b2mn_dv.F90 b2mn_d.F90

sed -i "/INCLUDE 'DIFFSIZES.inc'/d" ./*.F90
sed -i "/USE DIFFSIZES/d" ./*.F90
sed -i -e "/IMPLICIT NONE/i\  USE B2MOD_DIFFSIZES" ./*.F90

sed -i '/INTRINSIC DABS/d' b2us_geo_diffv.F90 b2trcl_dv.F90 b2srsm_dv.F90
sed -i -e 's/DIMENSION(:) :: dabs0/DIMENSION(mpg%nFs) :: dabs0/g' b2us_geo_diffv.F90
sed -i -e 's/DIMENSION(ISIZE1OFMETAVAR:abs)/DIMENSION(mpg%nFs)/g' b2us_geo_diffv.F90
sed -i -e 's/INTEGER, DIMENSION(ISIZE1OFresult1)/INTEGER/g' b2us_geo_diffv.F90
sed -i -e 's/DIMENSION(ISIZE1OFfspsi)/DIMENSION(mpg%nFs)/g' b2us_geo_diffv.F90
sed -i -e 's/result1 = MAXVAL(arg1(1:mpg%cvvxp(icv, 2)))/result1 = MAXVAL(gm%vxfpsi(verts(1:mpg%cvvxp(icv, 2))))/g' b2us_geo_diffv.F90
sed -i -e 's/result2 = MINVAL(arg2(1:mpg%cvvxp(icv, 2)))/result2 = MINVAL(gm%vxfpsi(verts(1:mpg%cvvxp(icv, 2))))/g' b2us_geo_diffv.F90
sed -i '/arg1(1:mpg%cvvxp(icv, 2)) = gm%vxfpsi(verts(1:mpg%cvvxp(icv, 2)))/d' b2us_geo_diffv.F90
sed -i '/arg2(1:mpg%cvvxp(icv, 2)) = gm%vxfpsi(verts(1:mpg%cvvxp(icv, 2)))/d' b2us_geo_diffv.F90
sed -i '/ISIZE1OFarg.INinit_geometry/d' b2us_geo_diffv.F90

sed -i -e 's/REAL(r8), DIMENSION(:, nfc, 0:1), ALLOCATABLE :: fne_he/REAL(r8), DIMENSION(:, :, :), ALLOCATABLE :: fne_he/g' b2us_plasma_diffv.F90

sed -i -e 's/CHARACTER(len=\*, 13), DIMENSION(:), DIMENSION(:), ALLOCATABLE/CHARACTER(len=13), ALLOCATABLE/ g' b2us_plasma_diffv.F90

sed -i -e 's/DIMENSION(SIZE(x1, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x2, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x3, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x4, 1), SIZE(x4, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x5, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x6, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(SIZE(x7, 1), SIZE(x7, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diffv.F90
sed -i -e 's/ISIZE1OFarg1/mpg%nCv/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(:, :) :: dabs0/DIMENSION(mpg%nCv, 0:ns-1) :: dabs0/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(:, :) :: dabs1/DIMENSION(mpg%nCv, 0:ns-1) :: dabs1/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(:, :) :: dabs2/DIMENSION(mpg%nCv, 0:ns-1) :: dabs2/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(:, :) :: dabs3/DIMENSION(mpg%nCv, 0:ns-1) :: dabs3/g' b2mod_driver_diffv.F90
sed -i -e 's/DIMENSION(:) :: dabs4/DIMENSION(mpg%nCv) :: dabs4/g' b2mod_driver_diffv.F90
sed -i -e 's/ISIZE1OFarg1/nCv/g' b2npmo_dv.F90 b2stbr_phys_dv.F90 b2tqna_dv.F90 eirene_f30f31_dv.F90 b2mod_recycle_diffv.F90 b2sikt_dv.F90 b2trcl_dv.F90 b2tfhe__dv.F90 b2trzh_dv.F90
sed -i -e 's/ISIZE1OFtemp/nCv/g' b2trzh_dv.F90

sed -i -e 's/ISIZE1OFabs/mpg%nCv/g' b2mod_driver_diffv.F90
sed -i -e 's/ISIZE2OFabs/0:state%pl%ns-1/g' b2mod_driver_diffv.F90
sed -i -e "s/REAL(r8), DIMENSION(:,/REAL(r8), DIMENSION(nbdirsmax,/g" b2news__dv.F90 b2news_m_dv.F90 b2sral_dv.F90
sed -i -e "s/REAL(kind=r8), DIMENSION(:,/REAL(kind=r8), DIMENSION(nbdirsmax,/g" b2news_m_dv.F90
sed -i -e 's/ISIZE1OFdv%fch_pi_c/nCv/g' b2news__dv.F90
sed -i -e 's/ISIZE1OFfch_p/nFc/g' b2news__dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd0/INTEGER :: dummyzerodiffd0(nbdirsmax)/g" b2mod_recycle_diffv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd29/INTEGER :: dummyzerodiffd29(nbdirsmax)/g" b2news__dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd33/INTEGER :: dummyzerodiffd33(nbdirsmax)/g" b2news__dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd37/INTEGER :: dummyzerodiffd37(nbdirsmax)/g" b2news__dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd54/INTEGER :: dummyzerodiffd54(nbdirsmax)/g" b2news__dv.F90
sed -i -e 's/ISIZE1OFtemp/nCv/g' b2news__dv.F90 b2tfcc_dv.F90 b2tfnb_dv.F90 b2tqna_dv.F90 b2xpic_dv.F90 b2us_feedback_diffv.F90 b2npmo_dv.F90 b2sikt_dv.F90 b2tral_dv.F90 b2trcl_dv.F90 b2mndt_dv.F90 b2news_m_dv.F90
sed -i -e 's/ISIZE1OFlnlam/nCv/g' b2npmo_dv.F90 b2trcl_dv.F90 b2trzh_dv.F90
sed -i -e 's/ISIZE1OFcvsa/nFc/g' b2npmo_dv.F90
sed -i -e 's/ISIZE1OFresult1/nCv/g' b2npmo_dv.F90 b2tqna_dv.F90 b2sikt_dv.F90 b2trcl_dv.F90 b2trzh_dv.F90
sed -i -e 's/ISIZE1OFcvvol/nCv/g' b2sikt_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd10/INTEGER :: dummyzerodiffd10(nbdirsmax)/g" b2npmo_dv.F90 
sed -i -e "s/INTEGER :: dummyzerodiffd14/INTEGER :: dummyzerodiffd14(nbdirsmax)/g" b2npmo_dv.F90
sed -i -e 's/ISIZE1OFcvhz/nCv/g' b2nxfv_dv.F90 b2npmo_dv.F90
sed -i -e 's/ISIZE1OFdv%ni/nCv/g' b2npmo_dv.F90
sed -i -e 's/ISIZE1OFdv%ne2/nCv/g' b2npmo_dv.F90 b2npht_dv.F90
sed -i -e 's/ISIZE1OFdv%lnlam/nCv/g' b2npmo_dv.F90
sed -i -e 's/ISIZE1OFvxhz/nVx/g' b2nxfv_dv.F90
sed -i -e 's/ISIZE1OFfcqalf/nFc/g' b2sian_dv.F90 b2stbc_dv.F90 b2stbc_phys_dv.F90 b2tfhe__dv.F90 b2tfhi__dv.F90 b2trno_dv.F90 b2tfch__dv.F90 b2tfnb_dv.F90 b2tinnt_dv.F90 b2tvskt_dv.F90 b2tfrn_dv.F90
sed -i -e 's/ISIZE1OFgeo%vxonedbsq/nVx/g' b2sihs__dv.F90
sed -i -e 's/ISIZE1OFgeo%cvonedbsq/nCv/g' b2sihs__dv.F90
sed -i -e "s/REAL(kind=r8), DIMENSION(:,/REAL(kind=r8), DIMENSION(nbdirsmax,/g" b2sihs__dv.F90 b2stbc_dv.F90
sed -i -e 's/ISIZE1OFgeo%cvvol/nCv/g' b2stbc_dv.F90 b2news_m_dv.F90
sed -i -e 's/ISIZE1OFcvbb/nCv/g' b2stbm_dv.F90 b2tfnb_dv.F90 b2tqna_dv.F90 b2tvspa_dv.F90 b2sikt_dv.F90 b2trno_dv.F90 b2siav_dv.F90 b2trcl_dv.F90 b2tvsq_dv.F90 b2tinnt_dv.F90 b2siav_zh_dv.F90
sed -i -e 's/ISIZE1OFfcbb/nFc/g' b2siav_dv.F90 b2tvskt_dv.F90 b2tvspa_dv.F90 b2tvsq_dv.F90 b2siav_zh_dv.F90
sed -i -e 's/ISIZE1OFvxbb/nVx/g' b2siav_dv.F90 b2siav_zh_dv.F90
sed -i -e 's/ISIZE1OFcvsahz_eff/nFc/g' b2stbr_phys_dv.F90 b2mod_recycle_diffv.F90
sed -i -e 's/ISIZE2OFcvsahz_eff/0:1/g' b2stbr_phys_dv.F90 b2mod_recycle_diffv.F90
sed -i -e 's/ISIZE1OFcvsahz/nFc/g' b2stbr_phys_dv.F90 b2mod_recycle_diffv.F90
sed -i -e 's/ISIZE2OFcvsahz/0:1/g' b2stbr_phys_dv.F90 b2mod_recycle_diffv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd0/INTEGER :: dummyzerodiffd0(nbdirsmax)/g" b2stbr_phys_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd4/INTEGER :: dummyzerodiffd4(nbdirsmax)/g" b2stbr_phys_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd6/INTEGER :: dummyzerodiffd6(nbdirsmax)/g" b2stbr_phys_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd1/INTEGER :: dummyzerodiffd1(nbdirsmax)/g" b2tanml_dv.F90
sed -i -e "s/DIMENSION(:, SIZE(st%psnc%zt, 1))/DIMENSION(nbdirsmax, SIZE(st%psnc%zt, 1))/g" b2mndt_dv.F90
sed -i -e "s/DIMENSION(:, SIZE(st%psnc%kt, 1))/DIMENSION(nbdirsmax, SIZE(st%psnc%kt, 1))/g" b2mndt_dv.F90
sed -i -e "s/DIMENSION(:, ISIZE1OFgeo%cvvol)/DIMENSION(nbdirsmax, nCv)/g" b2mndt_dv.F90 b2news__dv.F90
sed -i -e 's/ISIZE1OFst%dv%nn/nCv/g' b2mndt_dv.F90 b2news__dv.F90 b2news_m_dv.F90
sed -i -e 's/ISIZE1OFst%dv%ni/nCv/g' b2mndt_dv.F90 b2news__dv.F90 b2news_m_dv.F90 b2sral_dv.F90
sed -i -e 's/ISIZE1OFst%dv%ne/nCv/g' b2mndt_dv.F90 b2news__dv.F90 b2news_m_dv.F90
sed -i -e 's/ISIZE1OFst%dv%kinrgy/nCv/g' b2mndt_dv.F90 b2news__dv.F90 b2news_m_dv.F90
sed -i -e 's/ISIZE1OFgeo%cvvol/nCv/g' b2mndt_dv.F90 b2news__dv.F90 b2news_m_dv.F90
sed -i -e 's/ISIZE2OFst%dv%\&/0:ns-1\&/g' b2mndt_dv.F90 b2news__dv.F90 b2news_m_dv.F90
sed -i -e 's/\& kinrgy) :: dummyzerodiffd/\& ) :: dummyzerodiffd/g' b2mndt_dv.F90 b2news__dv.F90 b2news_m_dv.F90
sed -i -e "s/DIMENSION(:, SIZE(pl%te, 1)) /DIMENSION(nbdirsmax, SIZE(pl%te, 1)) /g" b2nppo_dv.F90
sed -i -e 's/ISIZE1OFcdpa/nFc/g' b2tfcc_dv.F90 b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFne/nCv/g' b2tfhe__dv.F90 b2tfrn_dv.F90
sed -i -e 's/ISIZE1OFne/mpg%nCv/g' b2mod_driver_diffv.F90
sed -i -e 's/ISIZE1OFni/nCv/g' b2tfhi__dv.F90
sed -i -e 's/ISIZE1OFfni_he/nFc/g' b2tfhi__dv.F90
sed -i -e 's/ISIZE2OFfni_he/0:1/g' b2tfhi__dv.F90
sed -i -e 's/ISIZE1OFcdna/nFc/g' b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFfchz/nFc/g' b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFpa/nCv/g' b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFfnapsch/nFc/g' b2tfnb_dv.F90
sed -i -e 's/ISIZE1OFcvla/nFc/g' b2tfnb_dv.F90
sed -i -e 's/ISIZE2OFcvla/0:1/g' b2tfnb_dv.F90
sed -i -e 's/DIMENSION(nbdirsmax, ISIZE1OFdv%fna_52(:, :, isb), 0:1)/DIMENSION(nbdirsmax, nFc, 0:1)/g' b2tfnb_dv.F90
sed -i -e 's/DIMENSION(:, SIZE(st_ext%za, 1), SIZE(st_ext%za, 2))/DIMENSION(nbdirsmax, SIZE(st_ext%za, 1), SIZE(st_ext%za, 2))/g' b2sral_dv.F90
sed -i -e 's/ISIZE1OFfchc/nFc/g' b2tinnt_dv.F90
sed -i -e 's/ISIZE2OFfchc/1:2/g' b2us_feedback_diffv.F90
sed -i -e 's/DIMENSION(:) :: dabs/DIMENSION(nCv) :: dabs/g' b2tinnt_dv.F90
sed -i -e "s/cfdna(0, is), cfdnad(:, 0, is)/cfdna(0, is), cfdnad(1:nbdirs, 0, is)/g" b2tqna_dv.F90
sed -i -e "s/cfvla(0, is), cfvlad(:, 0, is)/cfvla(0, is), cfvlad(1:nbdirs, 0, is)/g" b2tqna_dv.F90
sed -i -e "s/cfhci(0, is), cfhcid(:, 0, is)/cfhci(0, is), cfhcid(1:nbdirs, 0, is)/g" b2tqna_dv.F90
sed -i -e "s/cfdpa(0, is), cfdpad(:, 0, is)/cfdpa(0, is), cfdpad(1:nbdirs, 0, is)/g" b2tqna_dv.F90
sed -i -e "s/cfvsa(0, is), cfvsad(:, 0, is)/cfvsa(0, is), cfvsad(1:nbdirs, 0, is)/g" b2tqna_dv.F90
sed -i -e 's/DIMENSION(:) :: dabs/DIMENSION(nCv) :: dabs/g' b2tqna_dv.F90 b2trcl_dv.F90
sed -i -e 's/DIMENSION(:, :) :: dabs/DIMENSION(nbdirsmax, nCv) :: dabs/g' b2tqna_dv.F90 b2trcl_dv.F90
sed -i -e 's/ISIZE1OFcvbzb/nCv/g' b2tral_dv.F90
sed -i -e 's/ISIZE1OFco%cthi/nFc/g' b2tral_dv.F90
sed -i -e 's/ISIZE2OFco%cthi/0:ns-1/g' b2tral_dv.F90
sed -i -e 's/ISIZE1OFco%cthe/nFc/g' b2tral_dv.F90
sed -i -e 's/ISIZE2OFco%cthe/0:ns-1/g' b2tral_dv.F90
sed -i -e 's/DIMENSION(:/DIMENSION(nbdirsmax/g' b2tral_dv.F90 b2trno_dv.F90
sed -i -e 's/ISIZE1OFco%fllim0fhi/nfc/g' b2trno_dv.F90
sed -i -e 's/ISIZE3OFco%\&/0:ns-1\&/g' b2trno_dv.F90
sed -i -e 's/\& fllim0fhi) :: dummyzerodiffd2/\& ) :: dummyzerodiffd2/g' b2trno_dv.F90
sed -i -e 's/DIMENSION(SIZE(nal, 1))/DIMENSION(nCv)/g' b2tvsq_dv.F90
sed -i -e 's/CHARACTER(len=\*) :: arg1/CHARACTER(len=20) :: arg1/g' b2usco_dv.F90
sed -i -e 's/CHARACTER(len=\*) :: arg10/CHARACTER(len=20) :: arg10/g' b2usmo_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd1/INTEGER :: dummyzerodiffd1(nbdirsmax)/g" b2xpve_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd4/INTEGER :: dummyzerodiffd4(nbdirsmax)/g" b2xpve_dv.F90
sed -i -e "s/INTEGER :: dummyzerodiffd7/INTEGER :: dummyzerodiffd7(nbdirsmax)/g" b2xpve_dv.F90
sed -i -e 's/REAL :: result1$/integer :: result1/g' b2mod_input_profile_diffv.F90
sed -i -e '/she0d(nd, :, :) = 0.D0/a\        sne0d(nd, :, :) = 0.D0' b2mod_input_profile_diffv.F90
sed -i -e 's/#NBDirsMax#/nbdirsmax/g' ./*.F90 #why?
sed -i -e 's/#DIM_DV#/DIM_DV/g' dim_dv.F90 #why?
sed -i -e 's/DAMAX_NODIFF/damax/g' b2mndt_dv.F90 b2mxac_dv.F90 b2stcx_dv.F90 b2stel_dv.F90
sed -i -e 's/SMIN_NODIFF/smin/g' ./*.F90
sed -i -e 's/SMAX_NODIFF/smax/g' ./*.F90
sed -i -e 's/calc_dist(/calc_dist_nodiff(/g' b2wdat.F
sed -i -e 's/calc_dist_f/calc_dist_f_nodiff/g' b2wdat.F
sed -i '/REAL(kind=r8) :: const_h/i\# ifndef CONSTANTS_PROVIDED' heatdiff1D_dv.F90 ratstr_dv.F90
sed -i '/PARAMETER (const_h/a\# endif' heatdiff1D_dv.F90 ratstr_dv.F90

sed -i -e 's/INTEGER, SAVE :: ank_tracing=0/INTEGER :: ank_tracing=0/g' b2mod_diag_diffv.F90
sed -i '/INTRINSIC HUGE/d' b2mod_neutrals_namelist_diffv.F90 b2mod_boundary_namelist_diffv.F90
sed -i '/INTRINSIC MAX/d' b2stbc_phys_dv.F90 b2usr_cost_function_dv.F90 fix_user_dv.F90 b2news__dv.F90 b2news_m_dv.F90 b2stel_dv.F90 b2tqna_dv.F90 b2mod_recycle_diffv.F90
sed -i '/INTRINSIC ABS/d' b2srsm_dv.F90 b2mod_feedback_diffv.F90 b2trcl_dv.F90 b2srdt_dv.F90

sed -i '/EXTERNAL ALLOC_B2MOD_B2_TO_ASTRA/d' b2mod_driver_diffv.F90 b2mod_main_diffv.F90
sed -i '/EXTERNAL CDFMOVIE/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL DEALLOC_B2MOD_MWTI/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL TALLIES/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL REPEAT/d' b2trzh_dv.F90 b2mod_geometry_diffv.F90 b2mod_running_average_diffv.F90
sed -i '/EXTERNAL SUBINI/d' *.F90
sed -i '/EXTERNAL SUBEND/d' *.F90
sed -i '/EXTERNAL RESTART_MA28_FOR_US/d' b2news__dv.F90 b2npmo_dv.F90 b2usht_dv.F90 b2news_m_dv.F90
sed -i '/EXTERNAL DEALLOC_B2MOD_MA28_FOR_US/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL ISGHOSTCELL/d' b2mod_geo_diffv.F90 b2mod_indirect_diffv.F90
sed -i '/LOGICAL :: ISGHOSTCELL/d' b2mod_geo_diffv.F90 b2mod_indirect_diffv.F90
sed -i '/EXTERNAL ISREALCELL/d' b2mod_geo_diffv.F90 b2mod_indirect_diffv.F90
sed -i '/LOGICAL :: ISREALCELL/d' b2mod_geo_diffv.F90 b2mod_indirect_diffv.F90
sed -i '/EXTERNAL ISINDOMAIN/d' b2mod_geo_diffv.F90 b2mod_indirect_diffv.F90
sed -i '/LOGICAL :: ISINDOMAIN/d' b2mod_geo_diffv.F90 b2mod_indirect_diffv.F90
sed -i '/EXTERNAL ISCLASSICALGRID/d' b2mod_geo_diffv.F90
sed -i '/LOGICAL :: ISCLASSICALGRID/d' b2mod_geo_diffv.F90
sed -i '/EXTERNAL ISUNUSEDCELL/d' b2mod_geo_diffv.F90
sed -i '/LOGICAL :: ISUNUSEDCELL/d' b2mod_geo_diffv.F90
sed -i '/EXTERNAL DEALLOCATEB2GRIDMAP/d' b2mod_geo_diffv.F90
sed -i -e 's/MSTEP_NODIFF/MSTEP/g' heatdiff1D_dv.F90
sed -i -e 's/LINES2C_NODIFF/LINES2C/g' heatdiff1D_dv.F90
sed -i '/EXTERNAL OR/d' b2stbr_dv.F90
sed -i '/INTEGER :: OR/d' b2stbr_dv.F90
sed -i -e 's/B2UXUS_NODIFF/B2UXUS/g' b2usco_dv.F90 b2usmo_dv.F90 b2usht_dv.F90 b2uspo_dv.F90
sed -i -e 's/GET_JSEP_NODIFF/GET_JSEP/g' ./*.F90
sed -i -e 's/CFWURE_NODIFF/CFWURE/g' ./*.F90
sed -i -e 's/CFWUIN_NODIFF/CFWUIN/g' ./*.F90
sed -i '/EXTERNAL IPSETC/d' b2mnds_dv.F90 
sed -i '/EXTERNAL IPPRHP/d' b2mnds_dv.F90 
sed -i '/EXTERNAL ANINT/d' b2xvcp_dv.F90 
sed -i '/REAL(kind=r8) :: ANINT/d' b2xvcp_dv.F90
sed -i '/EXTERNAL XERSET/d' b2mod_main_diffv.F90
sed -i '/EXTERNAL IPGETC/d' b2mod_driver_diffv.F90 b2trzh_dv.F90
sed -i '/EXTERNAL B2TRCS/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL B2TRCF/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL B2TRACE/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL B2TRCI/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL B2MWTI/d' b2mod_driver_diffv.F90
sed -i '/EXTERNAL OUTPUT_DS/d' b2mod_input_profile_diffv.F90
sed -i '/EXTERNAL B2FILE./d' b2mndt_dv.F90
sed -i '/EXTERNAL GEOMETRYID/d' b2sihs__dv.F90 b2us_feedback_diffv.F90
sed -i '/INTEGER :: GEOMETRYID/d' b2sihs__dv.F90 b2us_feedback_diffv.F90
sed -i '/INTEGER :: geometry_sn/d' b2sihs__dv.F90
sed -i '/INTEGER :: geometry_linear/d' b2sihs__dv.F90
sed -i '/INTEGER :: geometry_lfs_snowflake_minus/d' b2sihs__dv.F90
sed -i '/INTEGER :: geometry_ddn_top/d' b2sihs__dv.F90
sed -i '/INTEGER :: geometry_ddn_bottom/d' b2sihs__dv.F90
sed -i '/INTEGER :: geometry_limiter/d' b2sihs__dv.F90
sed -i '/INTEGER :: geometry_lfs_snowflake_plus/d' b2sihs__dv.F90
sed -i '/INTEGER :: geometry_cdn/d' b2sihs__dv.F90
sed -i '/TRIM_DV/d' b2mod_main_diffv.F90
sed -i 's/FIX_USER_NODIFF/FIX_USER/g' fix_user_dv.F90
sed -i 's/B2XPNE_ST_NODIFF/B2XPNE_ST/g' b2mod_running_average_diffv.F90
sed -i 's/b2xppz/b2xppz_nodiff/g' b2mod_blnm.F b2mod_usrtrc.F
sed -i 's/b2xzef/b2xzef_nodiff/g' b2mod_wrsep.F
sed -i 's/gradc_r/gradc_r_nodiff/g' b2mod_usrtrc.F
sed -i 's/fill/fill_nodiff/g' prvrt*.F b2xpne_st.F
sed -i 's/B2XVFX_NODIFF/B2XVFX/g' b2xtvx_dv.F90
sed -i 's/B2XVFF_NODIFF/B2XVFF/g' b2npp7_dv.F90 b2tr21_dv.F90 b2usp7_dv.F90
sed -i '/PRGINI_DV/d' b2mod_main_diffv.F90
sed -i 's/b2xvfy/b2xvfy_nodiff/g' b2xvff.F
sed -i -e 's/B2WUZD_NODIFF/B2WUZD/g' b2mod_driver_diffv.F90 b2mnds_dv.F90 b2mod_running_average_diffv.F90 b2mod_batch_average_diffv.F90 b2wucp_dv.F90
sed -i 's/call intcell/call intcell_nodiff/g' b2mod_mwti.F90
sed -i -e 's/USE B2MOD_ANOMALOUS_TRANSPORT_DIFFV/USE B2MOD_ANOMALOUS_TRANSPORT/g' b2txvspr_dv.F90
sed -i -e 's/USE B2MOD_NEUTR_SRC_SCALING_DIFFV/USE B2MOD_NEUTR_SRC_SCALING/g' b2mod_diag_diffv.F90 b2mod_driver_diffv.F90 b2mod_main_diffv.F90 b2stbr_dv.F90
sed -i -e 's/MY_OUT_US_NODIFF/MY_OUT_US/g' ./*.F90
sed -i -e 's/sort_faces/sort_faces_nodiff/g' b2wdat.F b2pwlprp.F
sed -i -e 's/USE B2MOD_PLASMA_DIFFV/USE B2MOD_PLASMA/g' heatdiff2D_dv.F90 init_wall_dv.F90

sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_diffv.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_diffv.F90
sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_dv.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_dv.F90

sed -i '/MINVAL_DV/d' ./*.F90
sed -i '/MAXVAL_DV/d' ./*.F90
sed -i '/EXTERNAL XERRAB_DV/d' ./*.F90
sed -i '/ANY_DV/d' ./*.F90
sed -i '/COUNT_DV/d' ./*.F90
sed -i '/ALLOCATED_DV/d' ./*.F90
sed -i '/GET_B25_HASH_DV/d' b2mod_main_diffv.F90
sed -i '/MINLOC_DV/d' b2mod_neutrals_namelist_diffv.F90
sed -i -e 's/DOUBLE PRECISION, DIM/REAL(kind=r8), DIM/g' b2mod_driver_diffv.F90 b2mod_feedback_diffv.F90 b2siav_dv.F90 b2sikt_dv.F90 b2srdt_dv.F90 b2srsm_dv.F90 b2stcx_dv.F90 b2tdia_dv.F90 b2tinnt_dv.F90 b2tqna_dv.F90 b2trcl_dv.F90 b2tvsq_dv.F90 b2us_geo_diffv.F90
sed -i -e 's/DOUBLE PRECISION :: res/REAL(kind=r8) :: res/g' b2mod_driver_diffv.F90 b2mod_feedback_diffv.F90 b2srdt_dv.F90 b2srsm_dv.F90 b2stcx_dv.F90 b2tdia_dv.F90 b2us_geo_diffv.F90
sed -i -e 's/DOUBLE PRECISION :: dab/REAL(kind=r8) :: dab/g' b2sikt_dv.F90 b2tqna_dv.F90
sed -i -e 's/INTRINSIC DABS/INTRINSIC ABS/g' ./*.F90
sed -i -e 's/REAL(kind=r8) :: result16/INTEGER :: result16/g' b2us_geo_diffv.F90
sed -i -e 's/REAL(kind=r8) :: result10/INTEGER :: result10/g' b2srdt_dv.F90

# removing non-existing call to READ_NEUTRALS_NAMELIST_US_DV0
sed -i -e 's/MODULE PROCEDURE READ_NEUTRALS_NAMELIST_US_DV, \&/MODULE PROCEDURE READ_NEUTRALS_NAMELIST_US_DV/g' b2mod_neutrals_namelist_diffv.F90
sed -i -e '/\&     READ_NEUTRALS_NAMELIST_US_DV0/d' b2mod_neutrals_namelist_diffv.F90
l1=`grep -n READ_NEUTRALS_NAMELIST_US_DV0 b2mod_neutrals_namelist_diffv.F90 | head -n 1| awk -F ':' '/1/ {print $1}'`
l2=`grep -n READ_NEUTRALS_NAMELIST_US_DV0 b2mod_neutrals_namelist_diffv.F90 | tail -n 1| awk -F ':' '/1/ {print $1}'`
sed -i -e "$l1,$l2 d" b2mod_neutrals_namelist_diffv.F90

sed -i '/PUBLIC :: alloc_switches_dv/d' b2mod_switches_diffv.F90
sed -i '/& check_values_switches_dv/d' b2mod_switches_diffv.F90
sed -i '/& read_first_switches_dv/d' b2mod_switches_diffv.F90
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
sed -i '/& dealloc_b2mod_sputter_dv/d' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_sputter_data_dv, dealloc_b2mod_sputter, &/dealloc_b2mod_sputter/g' b2mod_driver_diffv.F90
sed -i '/& dealloc_b2mod_neoclassical_dv/d' b2mod_driver_diffv.F90
sed -i '/& dealloc_b2mod_transport_disruption_dv/d' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_b2mod_neoclassical, &/dealloc_b2mod_neoclassical/g' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_b2mod_transport_disruption, &/dealloc_b2mod_transport_disruption/g' b2mod_driver_diffv.F90
sed -i -e 's/\& alloc_b2mod_balance_dv, write_balance, write_balance_dv, \&/\& alloc_b2mod_balance_dv, write_balance, \&/g' b2mod_driver_diffv.F90
sed -i -e 's/\& dealloc_b2mod_eirene_sources, dealloc_b2mod_eirene_sources_dv, \&/\& dealloc_b2mod_eirene_sources, \&/g' b2mod_driver_diffv.F90
sed -i -e 's/\& balance_average, update_average_balance, update_average_balance_dv/\& balance_average, update_average_balance/g' b2mod_driver_diffv.F90
sed -i -e 's/\& alloc_b2mod_b2plot_dv, dealloc_b2mod_b2plot, dealloc_b2mod_b2plot_dv/\& dealloc_b2mod_b2plot/g' b2mod_driver_diffv.F90
sed -i -e 's/dealloc_b2mod_facdrift_exb, \&/dealloc_b2mod_facdrift_exb/g' b2mod_driver_diffv.F90
sed -i -e '/\& dealloc_b2mod_facdrift_exb_dv/d' b2mod_driver_diffv.F90

# some wrong initialization from Tapenade
sed -i -e 's/(nd) = 0/ = 0/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%cvfcp(m/ALLOCATE(md0%cvfcp(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%cvfc(m/ALLOCATE(md0%cvfc(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%fccv(m/ALLOCATE(md0%fccv(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%fcvx(m/ALLOCATE(md0%fcvx(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%cvvxp(m/ALLOCATE(md0%cvvxp(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%cvvx(m/ALLOCATE(md0%cvvx(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%vxfcp(m/ALLOCATE(md0%vxfcp(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%vxfc(m/ALLOCATE(md0%vxfc(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%vxcvp(m/ALLOCATE(md0%vxcvp(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%vxcv(m/ALLOCATE(md0%vxcv(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%ftcv(m/ALLOCATE(md0%ftcv(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%ftcvp(m/ALLOCATE(md0%ftcvp(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%ftfc(m/ALLOCATE(md0%ftfc(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%ftfcp(m/ALLOCATE(md0%ftfcp(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%cvft(m/ALLOCATE(md0%cvft(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%fsfc(m/ALLOCATE(md0%fsfc(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%fsfcp(m/ALLOCATE(md0%fsfcp(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%fcfs(m/ALLOCATE(md0%fcfs(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%fcreg(m/ALLOCATE(md0%fcreg(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%cvreg(m/ALLOCATE(md0%cvreg(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%ftreg(m/ALLOCATE(md0%ftreg(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%fcaligned(m/ALLOCATE(md0%fcaligned(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%cvonclosedsurface(m/ALLOCATE(md0%cvonclosedsurface(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%fsvxp(m/ALLOCATE(md0%fsvxp(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%vxfs(m/ALLOCATE(md0%vxfs(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%imapcv(-1/ALLOCATE(md0%imapcv(nbdirsmax, -1/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%imapfcx(-1/ALLOCATE(md0%imapfcx(nbdirsmax, -1/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%imapfcy(-1/ALLOCATE(md0%imapfcy(nbdirsmax, -1/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%imapvx(-1/ALLOCATE(md0%imapvx(nbdirsmax, -1/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%icornvx(1/ALLOCATE(md0%icornvx(nbdirsmax, 1/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%imapcv(0/ALLOCATE(md0%imapcv(nbdirsmax, 0/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%imapfcx(0/ALLOCATE(md0%imapfcx(nbdirsmax, 0/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%imapfcy(0/ALLOCATE(md0%imapfcy(nbdirsmax, 0/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%imapvx(0/ALLOCATE(md0%imapvx(nbdirsmax, 0/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%icornvx(0/ALLOCATE(md0%icornvx(nbdirsmax, 0/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%fclbl(m/ALLOCATE(md0%fclbl(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%ftlbl(m/ALLOCATE(md0%ftlbl(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%cvlbl(m/ALLOCATE(md0%cvlbl(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%bccvp(m/ALLOCATE(md0%bccvp(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%bccv(m/ALLOCATE(md0%bccv(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%bcfcp(m/ALLOCATE(md0%bcfcp(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%bcfc(m/ALLOCATE(md0%bcfc(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%fcbc(m/ALLOCATE(md0%fcbc(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%rccvp(m/ALLOCATE(md0%rccvp(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%rccv(m/ALLOCATE(md0%rccv(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%rcfcp(m/ALLOCATE(md0%rcfcp(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%rcfc(m/ALLOCATE(md0%rcfc(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%cfregp(m/ALLOCATE(md0%cfregp(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%cfreg(m/ALLOCATE(md0%cfreg(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%cfoncv(m/ALLOCATE(md0%cfoncv(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%cvnvp(m/ALLOCATE(md0%cvnvp(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%cvnv(m/ALLOCATE(md0%cvnv(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%fsvx(m/ALLOCATE(md0%fsvx(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%xpt(m/ALLOCATE(md0%xpt(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%strvxp(m/ALLOCATE(md0%strvxp(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%strvx(m/ALLOCATE(md0%strvx(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%strdiv(m/ALLOCATE(md0%strdiv(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%tgvx(m/ALLOCATE(md0%tgvx(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%strdiv(2/ALLOCATE(md0%strdiv(nbdirsmax, 2/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%strvxp(1/ALLOCATE(md0%strvxp(nbdirsmax, 1/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%ifdiv(MAX/ALLOCATE(md0%ifdiv(nbdirsmax, MAX/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%ivdiv(MAX/ALLOCATE(md0%ivdiv(nbdirsmax, MAX/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%divfcp(MAX/ALLOCATE(md0%divfcp(nbdirsmax, MAX/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%divfc(ico/ALLOCATE(md0%divfc(nbdirsmax, ico/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%cvalongboundary(m/ALLOCATE(md0%cvalongboundary(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%fcs_wall(m/ALLOCATE(md0%fcs_wall(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/ALLOCATE(md0%fcs_wall_ind(m/ALLOCATE(md0%fcs_wall_ind(nbdirsmax, m/g' b2us_map_diffv.F90
sed -i -e 's/userfluxparmd(:, 0:0) = 0.D0/userfluxparmd(:, :, :) = 0.D0/g' b2mod_driver_diffv.F90
sed -i -e 's/cfnormd(:, 0:0) = 0.D0/cfnormd = 0.D0/g' b2usr_cost_function_dv.F90
sed -i -e 's/voldd(:, 0:0) = 0.D0/voldd = 0.D0/g' b2usr_cost_function_dv.F90
sed -i -e 's/ALLOCATE(rtd%iscx(0:rt%nscxmax-1), source=0)/ALLOCATE(rtd%iscx(nbdirsmax, 0:rt%nscxmax-1), source=0)/g' b2us_plasma_diffv.F90
sed -i -e 's/rtd%iscx(nd) = 0/rtd%iscx = 0/ g' b2us_plasma_diffv.F90
sed -i -e 's/ALLOCATE(state_extd%text(0:ns_ext-1))/ALLOCATE(state_extd%text(nbdirsmax, 0:ns_ext-1))/ g' b2us_plasma_diffv.F90
sed -i -e 's/ALLOCATE(state_extd%is_neutral(0:ns_ext-1))/ALLOCATE(state_extd%is_neutral(nbdirsmax, 0:ns_ext-1))/ g' b2us_plasma_diffv.F90
sed -i -e 's/state_extd%is_neutral(nd) = 0.D0/state_extd%is_neutral = .false./g' b2us_plasma_diffv.F90

# missing arguments in calls to b2siav_zh, b2sifr_ b2sifrtf inside b2npmo
sed -i -e 's/dummyzerodiffd2, rt%rz2, dummyzerodiffd1, dv%lnlam/dv%ne2, dummyzerodiffd2, rt%rz2, dummyzerodiffd1, dv%lnlam/g' b2npmo_dv.F90
sed -i -e 's/dummyzerodiffd5, rt%rz2, dummyzerodiffd4, dv%lnlam/dv%ne2, dummyzerodiffd5, rt%rz2, dummyzerodiffd4, dv%lnlam/g' b2npmo_dv.F90
sed -i -e 's/dummyzerodiffd8, rt%rz2, dummyzerodiffd7, dv%lnlam/dv%ne2, dummyzerodiffd8, rt%rz2, dummyzerodiffd7, dv%lnlam/g' b2npmo_dv.F90

#missing arguments in call to b2tlh0 in b2trno
sed -i -e 's/\&          chcb, cod%chcb, dummyzerodiffd2, nbdirs)/\&          chcb, cod%chcb, co%fllim0fhi, dummyzerodiffd2, nbdirs)/g' b2trno_dv.F90

# missing arguments in calls to b2srst, b2srsm, b2treq, b2srdt in b2mndt
sed -i -e 's/\&                %pl%tn, std%pl%tn, st%pl%po, std%pl%po, dummyzerodiffd7\&/\&                %pl%tn, std%pl%tn, st%pl%po, std%pl%po, st%dv%ne, dummyzerodiffd7\&/g' b2mndt_dv.F90
sed -i -e 's/\&                , dummyzerodiffd6, dummyzerodiffd5, st%pl%kt, std%pl%kt\&/\&                , st%dv%ni, dummyzerodiffd6, st%dv%nn, dummyzerodiffd5, st%pl%kt, std%pl%kt\&/g' b2mndt_dv.F90
sed -i -e 's/\&                dummyzerodiffd20, dummyzerodiffd19, dummyzerodiffd18, \&/\&                st%dv%ne, dummyzerodiffd20, st%dv%ni, dummyzerodiffd19, st%dv%nn, dummyzerodiffd18, \&/g' b2mndt_dv.F90
sed -i -e 's/\&              dummyzerodiffd4, st%sr, std%sr, .true., nbdirs)/\&              st%dv%nn, dummyzerodiffd4, st%sr, std%sr, .true., nbdirs)/g' b2mndt_dv.F90
sed -i -e 's/CALL B2TREQ_DV(ncv, switch, switchd, dummyzerodiffd21, st%pl%te/CALL B2TREQ_DV(ncv, switch, switchd, geo%cvvol, dummyzerodiffd21, st%pl%te/g' b2mndt_dv.F90
sed -i -e 's/\&                , dummyzerodiffd14, dummyzerodiffd13, dummyzerodiffd12\&/               , dummyzerodiffd14, st%dv%ne, dummyzerodiffd13, st%dv%ni, dummyzerodiffd12\&/g' b2mndt_dv.F90
sed -i -e 's/\&                , dummyzerodiffd11, dummyzerodiffd10, st%pl%kt, \&/\&                , st%dv%nn, dummyzerodiffd11, st%dv%kinrgy, dummyzerodiffd10, st%pl%kt, \&/g' b2mndt_dv.F90

# missing arguments in calls to b2srst, b2srsm, b2srdt, b2treq in b2news_
sed -i -e 's/\&            std%pl%tn, st%pl%po, std%pl%po, dummyzerodiffd12, \&/\&            std%pl%tn, st%pl%po, std%pl%po, st%dv%ne, dummyzerodiffd12, \&/g' b2news__dv.F90
sed -i -e 's/\&            dummyzerodiffd11, dummyzerodiffd10, st%pl%kt, std%pl%kt, st\&/\&            st%dv%ni, dummyzerodiffd11, st%dv%nn, dummyzerodiffd10, st%pl%kt, std%pl%kt, st\&/g' b2news__dv.F90
sed -i -e 's/\&            dummyzerodiffd, st%sr, std%sr, .false., nbdirs)/\&            st%dv%nn, dummyzerodiffd, st%sr, std%sr, .false., nbdirs)/g' b2news__dv.F90
sed -i -e 's/\&            , st%pl%tn, dummyzerodiffd6, dummyzerodiffd5, \&/\&            , st%pl%tn, dummyzerodiffd6, st%dv%ne, dummyzerodiffd5, st%dv%ni, \&/g' b2news__dv.F90
sed -i -e 's/\&            dummyzerodiffd4, dummyzerodiffd3, dummyzerodiffd2, st%pl%kt\&/\&            dummyzerodiffd4, st%dv%nn, dummyzerodiffd3, st%dv%kinrgy, dummyzerodiffd2, st%pl%kt\&/g' b2news__dv.F90
sed -i -e 's/\&            dummyzerodiffd20, st%pl%tn, dummyzerodiffd19, \&/\&            dummyzerodiffd20, st%pl%tn, dummyzerodiffd19, st%dv%ne, \&/g' b2news__dv.F90
sed -i -e 's/\&            dummyzerodiffd18, dummyzerodiffd17, dummyzerodiffd16, \&/\&            dummyzerodiffd18, st%dv%ni, dummyzerodiffd17, st%dv%nn, dummyzerodiffd16, \&/g' b2news__dv.F90
sed -i -e 's/\&            dummyzerodiffd15, st%pl%kt, dummyzerodiffd14, st%pl%zt, \&/\&            st%dv%kinrgy, dummyzerodiffd15, st%pl%kt, dummyzerodiffd14, st%pl%zt, \&/g' b2news__dv.F90
sed -i -e 's/CALL B2TREQ_DV(ncv, switch, switchd, dummyzerodiffd23/CALL B2TREQ_DV(ncv, switch, switchd, geo%cvvol, dummyzerodiffd23/g' b2news__dv.F90

# missing arguments in calls to b2srst, b2srsm, b2srdt, b2treq in b2news_m
sed -i -e 's/\&            std%pl%tn, st%pl%po, std%pl%po, dummyzerodiffd13, \&/\&            std%pl%tn, st%pl%po, std%pl%po, st%dv%ne, dummyzerodiffd13, \&/g' b2news_m_dv.F90
sed -i -e 's/\&            dummyzerodiffd12, dummyzerodiffd11, st%pl%kt, std%pl%kt, st\&/\&            st%dv%ni, dummyzerodiffd12, st%dv%nn, dummyzerodiffd11, st%pl%kt, std%pl%kt, st\&/g' b2news_m_dv.F90
sed -i -e 's/\&            dummyzerodiffd0, st%sr, std%sr, .false., nbdirs)/\&            st%dv%nn, dummyzerodiffd0, st%sr, std%sr, .false., nbdirs)/g' b2news_m_dv.F90
sed -i -e 's/\&            dummyzerodiffd8, st%pl%tn, dummyzerodiffd7, dummyzerodiffd6\&/\&            dummyzerodiffd8, st%pl%tn, dummyzerodiffd7, st%dv%ne, dummyzerodiffd6, st%dv%ni\&/g' b2news_m_dv.F90
sed -i -e 's/\&            , dummyzerodiffd5, dummyzerodiffd4, dummyzerodiffd3, st%pl%\&/\&            , dummyzerodiffd5, st%dv%nn, dummyzerodiffd4, st%dv%kinrgy, dummyzerodiffd3, st%pl%\&/g' b2news_m_dv.F90
sed -i -e 's/CALL B2TREQ_DV(ncv, switch, switchd, dummyzerodiffd/CALL B2TREQ_DV(ncv, switch, switchd, geo%cvvol, dummyzerodiffd/g' b2news_m_dv.F90

# missing arguments in call to b2stcx inside b2sral
sed -i -e 's/\&            ti, std%pl%ti, st%pl%tn, std%pl%tn, dummyzerodiffd3, st%rtw\&/\&            ti, std%pl%ti, st%pl%tn, std%pl%tn, st%dv%ni, dummyzerodiffd3, st%rtw\&/g' b2sral_dv.F90

# missing argument call to b2saxpy in b2stbc
sed -i -e 's/CALL B2SAXPY_DV(ncv, switch%sna0ep/CALL B2SAXPY_DV(ncv, switch%sna0ep, geo%cvvol/g' b2stbc_dv.F90
sed -i -e 's/CALL B2SAXPY_DV(ncv, switch%she0ep/CALL B2SAXPY_DV(ncv, switch%she0ep, geo%cvvol/g' b2stbc_dv.F90
sed -i -e 's/CALL B2SAXPY_DV(ncv, switch%shi0ep/CALL B2SAXPY_DV(ncv, switch%shi0ep, geo%cvvol/g' b2stbc_dv.F90

#missing arguments in call to b2trcl in b2tral
sed -i -e 's/\&          dummyzerodiffd0, dummyzerodiffd, co%vsaf_cl, cod%vsaf_cl, co%\&/\&          co%cthe, dummyzerodiffd0, co%cthi, dummyzerodiffd, co%vsaf_cl, cod%vsaf_cl, co%\&/g' b2tral_dv.F90

#missing arguments in call to calcflow in b2tfnb
sed -i -e 's/\&            dummyzerodiffd, nbdirs)/\&            dv%fna_52(:, :, isb), dummyzerodiffd, nbdirs)/g' b2tfnb_dv.F90

#missing arguments in call to b2sihs in b2npht
sed -i -e 's/\&             pld%ti, pl%tn, pld%tn, pl%po, pld%po, dv%ne, dvd%ne, \&/\&             pld%ti, pl%tn, pld%tn, pl%po, pld%po, dv%ne, dvd%ne, dv%ne2, \&/g' b2npht_dv.F90

# adjusting get_mult_dt
sed -i -e '/REAL(kind=r8), DIMENSION(nbdirsmax) :: max2d/a\  INTEGER :: idx(1)' get_mult_dt_dv.F90
sed -i -e 's/LOG(10)/LOG(10.0)/g' get_mult_dt_dv.F90
sed -i -e '/dt_var4_min(icv), dt_var4_mind(:, icv), nbdirs)/a\      ! csc manually adjusted part, not sure if this will be correct\n      idx = MINLOC(dt_var4_ns(icv, :))\n      DO nd=1,nbdirs\n        dt_var4_mind(nd, icv) = dt_var4_nsd(nd, icv, idx(1))\n      END DO\n      dt_var4_min(icv) = dt_var4_ns(icv, idx(1))' get_mult_dt_dv.F90
sed -i -e '/dt_var4_min(icv), dt_var4_mind(:, icv), nbdirs)/d' get_mult_dt_dv.F90

sed -i -e "s/REAL(kind=r8) :: result1/integer :: result1/g" b2us_map_diffv.F90 b2usmo_dv.F90 b2uspo_dv.F90
sed -i -e "s/REAL(kind=r8) :: result10/integer :: result10/g" b2usco_dv.F90
sed -i -e "s/REAL(kind=r8) :: result12/integer :: result12/g" b2us_geo_diffv.F90
sed -i -e "s/md0%cvalongboundary = 0.D0/md0%cvalongboundary = .false./g" b2us_map_diffv.F90
sed -i -e "s/md0%cvonclosedsurface = 0.D0/md0%cvonclosedsurface = .false./g" b2us_map_diffv.F90
sed -i -e "s/md0%cfoncv = 0.D0/md0%cfoncv = .true./g" b2us_map_diffv.F90

sed -i -e 's/alloc_geometry_dv, dealloc_geometry_dv, read_geometry_dv, &/alloc_geometry_dv, dealloc_geometry_dv, read_geometry_dv/g' b2us_geo_diffv.F90
sed -i '/& check_geometry_dv/d' b2us_geo_diffv.F90
sed -i -e 's/read_b2fgmtry_dv, read_b2fstate_dv, write_b2fstate_dv, &/read_b2fgmtry_dv, read_b2fstate_dv/g' b2us_io_diffv.F90
sed -i '/& write_b2fplasma_dv/d' b2us_io_diffv.F90
sed -i -e 's/USE B2MOD_RESIDUALS_DIFFV/USE B2MOD_RESIDUALS/g' b2mod_diag_diffv.F90
sed -i -e 's/=> NULL()/= 0.0_R8/g' b2mndt_dv.F90 b2sral_dv.F90

sed -i -e 's/CHARACTER(len=13), DIMENSION(:), DIMENSION(:, :), ALLOCATABLE ::/CHARACTER(len=13), DIMENSION(:, :), ALLOCATABLE ::/g' b2us_plasma_diffv.F90
sed -i -e 's/\&     text/\&     text(:,:)/g' b2us_plasma_diffv.F90
sed -i -e 's/DO ii2=1,SIZE(state_extd%text(ii1), 1)/DO ii2=1,SIZE(state_extd%text, 2)-1/g' b2us_plasma_diffv.F90
sed -i -e 's/state_extd%text(ii1)(nd, ii2) =/state_extd%text(nd, ii2) =/g' b2us_plasma_diffv.F90

sed -i -e '/my_out_folder/a\#ifdef DBG\n  CHARACTER(len=16), SAVE :: my_out_sf(0:1)\n#endif' b2mod_ad_diffv.F90

# for residuals calculation
sed -i -e "/CALL B2MWQ0_NODIFF(nout(4), ns, switch)/a\  call b2mwq0_nodiff(nout(10), ns, switch)" b2mnds_dv.F90
sed -i -e "/CALL B2MWQ0_NODIFF(nout(4), ns, switch)/a\  call cfwuch(nout(10), 120, lblmn, 'label')" b2mnds_dv.F90
sed -i -e "/CALL B2MWQ0_NODIFF(nout(4), ns, switch)/a\  call cfwuin(nout(10), 1, idum, 'ns')" b2mnds_dv.F90
sed -i -e "/CALL B2MWQ0_NODIFF(nout(4), ns, switch)/a\  idum(0) = ns" b2mnds_dv.F90
sed -i -e "/CALL ALLOC_MAPPING_DV(mpg, mpgd, nbdirs)/i\    call cfopen(nout(10),'b2ftraced','new','un*formatted')" b2mod_main_diffv.F90
sed -i -e '0,/CALL B2MXAC_NODIFF/s/CALL B2MXAC_NODIFF/CALL B2MXAC_NO1DIFF/g' b2mndt_dv.F90
sed -i -e '0,/CALL B2MXAC_NODIFF/s/CALL B2MXAC_NODIFF/CALL B2MXAC_NO1DIFF/g' b2mndt_dv.F90
sed -i -e '/CALL B2MXAC_NO1DIFF/a\        CALL B2MXAC_DIFFv(ncv, ns, std%dv, std%diag)' b2mndt_dv.F90
sed -i -e '/CALL B2MXAC_NO1DIFF/a\!      ..compute norms of the differentiated corrections' b2mndt_dv.F90
sed -i -e '/CALL B2MXAC_NO1DIFF/a\&         std%pl, std%dv, std%diag)' b2mndt_dv.F90
sed -i -e '/CALL B2MXAC_NO1DIFF/a\        CALL B2MXAR_DIFFv(nCv, ns, switch, geo, mpg, &' b2mndt_dv.F90
sed -i -e '/CALL B2MXAC_NO1DIFF/a\!      ..compute norms of the differentiated residuals' b2mndt_dv.F90
sed -i -e 's/B2MXAC_NO1DIFF/B2MXAC_NODIFF/g' b2mndt_dv.F90
sed -i -e '0,/IF (MOD(ncall_b2mndt, switch%ntim_step_out) .EQ. 0) THEN/s/IF (MOD(ncall_b2mndt, switch%ntim_step_out) .EQ. 0) THEN/IF (MOD1(ncall_b2mndt, switch%ntim_step_out) .EQ. 0) THEN/g' b2mndt_dv.F90
sed -i -e '0,/IF (MOD(ncall_b2mndt, switch%ntim_step_out) .EQ. 0) THEN/s/IF (MOD(ncall_b2mndt, switch%ntim_step_out) .EQ. 0) THEN/IF (MOD1(ncall_b2mndt, switch%ntim_step_out) .EQ. 0) THEN/g' b2mndt_dv.F90
sed -i -e '/IF (MOD1(ncall_b2mndt, switch%ntim_step_out) .EQ. 0) THEN/a\              FLUSH(nout(10))' b2mndt_dv.F90
sed -i -e '/IF (MOD1(ncall_b2mndt, switch%ntim_step_out) .EQ. 0) THEN/a\&             switch, geo, std%pl, std%dv, std%diag)' b2mndt_dv.F90
sed -i -e '/IF (MOD1(ncall_b2mndt, switch%ntim_step_out) .EQ. 0) THEN/a\            CALL B2MWQT_DIFFv(nout(10), ncv, ns, itim, b2mndt_itcnt, &' b2mndt_dv.F90
sed -i -e '/IF (MOD1(ncall_b2mndt, switch%ntim_step_out) .EQ. 0) THEN/a\!       ..output differentiated residuals' b2mndt_dv.F90
sed -i -e 's/IF (MOD1(ncall_b2mndt, switch%ntim_step_out) .EQ. 0) THEN/IF (MOD(ncall_b2mndt, switch%ntim_step_out) .EQ. 0) THEN/g' b2mndt_dv.F90

sed -i -e "/END TYPE MAPPING_DIFFV/i\      INTEGER :: ncv(nbdirsmax), nfc(nbdirsmax), nvx(nbdirsmax), ncg(nbdirsmax), &" b2us_map_diffv.F90
sed -i -e "/END TYPE MAPPING_DIFFV/i\&     nci(nbdirsmax), ncmxvx(nbdirsmax), ncmxfc(nbdirsmax), nvmxcv(nbdirsmax), nvmxfc(nbdirsmax),&" b2us_map_diffv.F90
sed -i -e "/END TYPE MAPPING_DIFFV/i\&     nfs(nbdirsmax), nbc(nbdirsmax), mxnbc(nbdirsmax), nrc(nbdirsmax), mxnrc(nbdirsmax),&" b2us_map_diffv.F90
sed -i -e "/END TYPE MAPPING_DIFFV/i\&     ncmxnv(nbdirsmax), ncf(nbdirsmax), mxncf(nbdirsmax)" b2us_map_diffv.F90

sed -i -e '/par_opt_physd(nd, 1:npar_opt) = 0.D0/a\        par_opt_physd(nd, nd) = 1.0_R8' b2mod_driver_diffv.F90

sed -i -e "s/b2mod_main_diff/b2mod_main_diffv/g" b2optim_tao.F90
sed -i -e "s/b2mod_ad_diff/b2mod_ad_diffv/g" b2optim_tao.F90
sed -i -e "s/b2mod_par_opt_diff/b2mod_par_opt_diffv/g" b2optim_tao.F90 set_parameters.F
sed -i -e "s/b2mn_init_diff/b2mn_init_dv/g" b2optim_tao.F90
sed -i -e "s/b2mn_fin_diff/b2mn_fin_dv/g" b2optim_tao.F90
sed -i -e "s/b2mn_step_diff/b2mn_step_dv/g" b2optim_tao.F90
sed -i -e "s/b2us_data_diff/b2us_data_diffv/g" b2optim_tao.F90
sed -i -e "s/b2us_io_diff/b2us_io_diffv/g" b2optim_tao.F90
sed -i -e "s/b2mod_b2cmpa_diff/b2mod_b2cmpa_diffv/g" b2optim_tao.F90
sed -i -e "s/b2mod_facdrift_exb_diff/b2mod_facdrift_exb_diffv/g" b2optim_tao.F90
sed -i -e "s/b2mod_transport_namelist_diff/b2mod_transport_namelist_diffv/g" b2optim_tao.F90 set_parameters.F
sed -i -e "s/b2mod_input_profile_diff/b2mod_input_profile_diffv/g" b2optim_tao.F90 set_parameters.F
sed -i -e "s/b2mod_boundary_namelist_diff/b2mod_boundary_namelist_diffv/g" b2optim_tao.F90 set_parameters.F
sed -i -e "s/b2mod_switches_diff/b2mod_switches_diffv/g" set_parameters.F
sed -i -e "s/b2mod_neutrals_namelist_diff/b2mod_neutrals_namelist_diffv/g" set_parameters.F
sed -i -e "s/geodiff/geod/g" b2optim_tao.F90
sed -i -e "s/mpgdiff/mpgd/g" b2optim_tao.F90
sed -i -e "s/statediff/stated/g" b2optim_tao.F90
sed -i -e "s/state_extdiff/state_extd/g" b2optim_tao.F90
sed -i -e "s/state_avgdiff/state_avgd/g" b2optim_tao.F90
sed -i -e "s/switchdiff/switchd/g" b2optim_tao.F90
sed -i -e "s/par_opt_physdiff/par_opt_physd/g" b2optim_tao.F90
sed -i -e "s/b2mn_init_dv()/b2mn_init_dv(npar_opt)/g" b2optim_tao.F90
sed -i -e "s/b2mn_fin_dv()/b2mn_fin_dv(npar_opt)/g" b2optim_tao.F90
sed -i -e "s/b2mn_step_dv(j, jdiff)/b2mn_step_dv(j, jdiff, npar_opt-nsigma_opt-nmean_opt-nshift_opt-ncorr_opt)/g" b2optim_tao.F90
sed -i -e 's/jdiff(nncf)/jdiff(nbdirsmax,nncf)/g' b2optim_tao.F90
sed -i -e "/subroutine FormFunctionGradient(/a\      use b2mod_diffsizes" b2optim_tao.F90
sed -i -e "s/g_v(ipar) = jdiff(1)/g_v(ipar) = jdiff(ipar,1)/g" b2optim_tao.F90


# fixed point loop variables
sed -i -e '0,/REAL(kind=r8) :: EPOCH_SECONDS/s//REAL(kind=r8) :: EPOCH_SECONDS\n    LOGICAL, SAVE :: first_opt_call=.true./'  b2mod_driver_diffv.F90
sed -i -e '0,/res_max = 10.0_R8\*res_quit/s//res_max = 10.0_R8\*res_quit\n    gradient_res = 10.0_R8\*res_quit/'  b2mod_driver_diffv.F90
sed -i -e '0,/^! The FIXED_POINT.*/s/^! The FIXED_POINT.*/    first_opt_call = .false.\n    endif\n&/' b2mod_driver_diffv.F90
sed -i -e '0,/res_max = 0.0_R8/s/      res_max = 0.0_R8/      gradient_res = 0.0_R8\n      call calc_res_fp_multi(nbdirs, nCv, ns, switch%tn_style, \&\n\&       switch%solve_keps, stated%diag, gradient_res)\n&/' b2mod_driver_diffv.F90
sed -i -e "0,/WRITE(\*, \*) 'MAX RESIDUAL ', res_max/s//WRITE(\*, \*) 'MAX RESIDUAL ', res_max\n      WRITE(\*, \*) 'MAX TGT RESIDUAL ', gradient_res\n      res_max = max(res_max, gradient_res)/"  b2mod_driver_diffv.F90
sed -i -e "/WRITE(\*, \*) 'MAX RESIDUAL ', res_max/a\      primal_res = res_max" b2mod_driver_diffv.F90

