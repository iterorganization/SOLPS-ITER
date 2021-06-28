
# all files are .f90 files, move them to .F90 extension
move_to_F90.sh
rm b2uxus_b.F90
collect_nodiff_b.sh

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
sed -i -e 's/ISIZE1OFmask/nCv/g' b2tqna_b.F90
sed -i -e 's/ISIZE1OFcvsahz_eff/nFc/g'  b2mod_recycle_diff.F90
sed -i -e 's/ISIZE2OFcvsahz_eff/0:1/g' b2mod_recycle_diff.F90
sed -i -e 's/ISIZE1OFcvsahz/nFc/g' b2mod_recycle_diff.F90
sed -i -e 's/ISIZE2OFcvsahz/0:1/g' b2mod_recycle_diff.F90
sed -i -e 's/ISIZE1OFdv%fch_pi_c/nCv/g' b2news__b.F90
sed -i -e 's/ISIZE1OFcvsa/nFc/g' b2npmo_b.F90
sed -i -e 's/ISIZE1OFvxhz/nVx/g' b2nxfv_b.F90 
sed -i -e 's/ISIZE1OFcvhz/nCv/g' b2nxfv_b.F90
sed -i -e 's/ISIZE1OFgeo%cvvol/nCv/g' b2stbc_b.F90
sed -i -e 's/ISIZE1OFfcqalf/nFc/g' b2stbc_b.F90 b2stbc_phys_b.F90 b2tfch__b.F90 b2tfhe__b.F90 b2tfhi__b.F90 b2trno_b.F90 #b2sian_b.F90 b2tfnb_b.F90
# start issues with disappearing arguments in forward routines
sed -i -e "s/CALL B2SAXPY_FWD(ncv, switch%sna0ep, incx=1, sy=srw%sna0(1, 0, is)/CALL B2SAXPY_FWD(ncv, switch%sna0ep, geo%cvvol, 1, srw%sna0(1, 0, is)/g" b2stbc_b.F90
sed -i -e 's/\&              incy=1)/\&              1)/g' b2stbc_b.F90
sed -i -e "s/CALL B2SAXPY_FWD(ncv, switch%she0ep, incx=1, sy=srw%she0(1, 0), incy=1/CALL B2SAXPY_FWD(ncv, switch%she0ep, geo%cvvol, 1, srw%she0(1, 0), 1/g" b2stbc_b.F90
sed -i -e "s/CALL B2SAXPY_FWD(ncv, switch%shi0ep, incx=1, sy=srw%shi0(1, 0), incy=1/CALL B2SAXPY_FWD(ncv, switch%shi0ep, geo%cvvol, 1, srw%shi0(1, 0), 1/g" b2stbc_b.F90
sed -i -e "s/CALL B2SAXPY(ncv, switch%sna0ep, 1, srw%sna0(1, 0, is), 1)/CALL B2SAXPY(ncv, switch%sna0ep, geo%cvvol, 1, srw%sna0(1, 0, is), 1)/g" b2stbc_b.F90
sed -i -e "s/CALL B2SAXPY(ncv, switch%she0ep, 1, srw%she0(1, 0), 1)/CALL B2SAXPY(ncv, switch%she0ep, geo%cvvol, 1, srw%she0(1, 0), 1)/g" b2stbc_b.F90
sed -i -e "s/CALL B2SAXPY(ncv, switch%shi0ep, 1, srw%shi0(1, 0), 1)/CALL B2SAXPY(ncv, switch%shi0ep, geo%cvvol, 1, srw%shi0(1, 0), 1)/g" b2stbc_b.F90
sed -i -e "s/\&                :, :, isb))/\&                :, :, isb), dv%fna_52(:, :, isb))/g" b2tfnb_b.F90
sed -i -e "s/\&             :, isb))/\&             :, isb), dv%fna_52(:, :, isb))/g" b2tfnb_b.F90
sed -i -e 's/co%alfx_c, co%sigx_c, pl%po, dv%ne, pl%te, pl%na,/co%alfx_c, co%sigx_c, dv%fch_pi_c, pl%po, dv%ne, pl%te, pl%na,/g' b2news__b.F90
# end
sed -i -e 's/ISIZE1OFcdpa/nFc/g' b2tfcc_b.F90 b2tfnb_b.F90
sed -i -e 's/ISIZE1OFne/nCv/g' b2tfhe__b.F90 b2tfrn_b.F90 b2tqna_b.F90
sed -i -e 's/ISIZE1OFni/nCv/g' b2tfhi__b.F90 b2sikt_b.F90
sed -i -e 's/ISIZE1OFfchanml/nFc/g' b2tfhi__b.F90 
sed -i -e 's/ISIZE1OFfhe_exb/nFc/g' b2tfhi__b.F90 
sed -i -e 's/ISIZE2OFfhe_exb/0:1/g' b2tfhi__b.F90 
sed -i -e 's/ISIZE1OFdv%fna_52(:, :, isb)/nFc/g' b2tfnb_b.F90 
sed -i -e 's/ISIZE1OFcdna/nFc/g' b2tfnb_b.F90
sed -i -e 's/ISIZE1OFtemp/nCv/g' b2tfnb_b.F90 b2sikt_b.F90 b2tqna_b.F90
sed -i -e 's/ISIZE1OFvadia/nFc/g' b2tfnb_b.F90
sed -i -e 's/ISIZE1OFpa/nCv/g' b2tfnb_b.F90
sed -i -e 's/ISIZE1OFfchc/nFc/g' b2tinnt_b.F90
sed -i -e 's/ISIZE1OFcvbzb/nCv/g' b2tral_b.F90
sed -i -e 's/ISIZE1OFco%cthi/nFc/g' b2tral_b.F90
sed -i -e 's/ISIZE2OFco%cthi/0:ns-1/g' b2tral_b.F90
sed -i -e 's/ISIZE1OFco%cthe/nFc/g' b2tral_b.F90
sed -i -e 's/ISIZE2OFco%cthe/0:ns-1/g' b2tral_b.F90
sed -i -e 's/\&              chve0, chci0, chvi0, csig0, calf0, co%csigin, co%vsaf_cl\&/\&              chve0, chci0, chvi0, csig0, calf0, co%csigin, co%cthe, co\&/g' b2tral_b.F90
sed -i -e 's/\&              , co%cvsa_cl, co%cvsahz_cl, co%fllimvisc, co%csig_cl, co%\&/\&              %cthi, co%vsaf_cl, co%cvsa_cl, co%cvsahz_cl, co%fllimvisc, co%csig_cl, co%\&/g' b2tral_b.F90
sed -i -e 's/ISIZE1OFcvbb/nCv/g' b2trno_b.F90 b2tqna_b.F90 
sed -i -e 's/ISIZE1OFco%fllim0fhi/nfc/g' b2trno_b.F90
sed -i -e 's/ISIZE3OFco%fllim0fhi/0:ns-1/g' b2trno_b.F90
sed -i -e 's/\&              pl%tn, chcib, co%chcb)/\&              pl%tn, chcib, co%chcb, co%fllim0fhi)/g' b2trno_b.F90
sed -i -e 's/CHARACTER(len=\*) :: arg1/CHARACTER(len=20) :: arg1/g' b2usco_b.F90 b2usmo_b.F90
# FIXME
sed -i '/PUSHCHARACTERARRAY(name/d' b2usco_b.F90 
sed -i '/POPCHARACTERARRAY(name/d' b2usco_b.F90 
sed -i -e 's/DIMENSION(mpg%cvnvp(icv., 2))/DIMENSION(11)/g' b2usco_b.F90 b2usht_b.F90 b2usmo_b.F90 b2uspo_b.F90
echo " ******************"
echo " !!!! WARNING  !!!!"
echo " This postprocessing script assumes that the maximum number of points in the stencil is 11"
echo " If this is not true please correct the dimension of the LOGICAL ARRAYS MASK* in b2usco_b b2usht_b b2usmo_b and b2uspo_b"
echo " !!!! WARNING  !!!!"
echo " ******************"
# FIXME
sed -i -e 's/ISIZE1OFarg1/20/g' calc_err_b.F90
sed -i -e 's/ISIZE1OFarg2/20/g' calc_err_b.F90
sed -i -e 's/LOGICAL :: arg1/LOGICAL :: arg1(m%nFc)/g' find_faces_b.F90


sed -i '/PUBLIC :: to_struct_cell_b, to_struct_face_b/d' b2us_debug_diff.F90
sed -i -e 's/PUBLIC :: to_struct_plasma_b,/PUBLIC :: /g' b2us_prep_diff.F90
sed -i '/PUBLIC :: alloc_switches_b/d' b2mod_switches_diff.F90
sed -i '/& check_values_switches_b/d' b2mod_switches_diff.F90
sed -i -e 's/dealloc_b2mod_wall, dealloc_b2mod_wall_b/dealloc_b2mod_wall/g' b2mod_driver_diff.F90
sed -i -e 's/alloc_b2mod_balance_b, dealloc_b2mod_balance, dealloc_b2mod_balance_b,/dealloc_b2mod_balance,/g' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_eirene_sources, dealloc_b2mod_eirene_sources_b,/dealloc_b2mod_eirene_sources,/g' b2mod_driver_diff.F90
sed -i -e 's/run_av_get_plasma, run_av_get_plasma_b, run_av_save, run_av_save_b/run_av_get_plasma, run_av_save/g' b2mod_driver_diff.F90
sed -i -e 's/batch_av_all_init_b, batch_av_all_save, batch_av_all_fin, &/batch_av_all_save, batch_av_all_fin/g' b2mod_driver_diff.F90
sed -i '/& batch_av_all_fin_b/d' b2mod_driver_diff.F90
sed -i -e 's/\& run_av_fin, run_av_fin_b/\& run_av_fin/g' b2mod_driver_diff.F90
sed -i -e 's/run_av_init, run_av_init_b,/run_av_init,/g' b2mod_driver_diff.F90
sed -i -e 's/dealloc_b2mod_ysmp_sdrv, &/dealloc_b2mod_ysmp_sdrv/g' b2mod_driver_diff.F90
sed -i '/& dealloc_b2mod_ysmp_sdrv_b/d' b2mod_driver_diff.F90

sed -i '/EXTERNAL RESTART_MA28_FOR_US/d' b2news__b.F90 b2npmo_b.F90 b2usht_b.F90
 
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
sed -i '/EXTERNAL DEALLOC_B2MOD_MA28_FOR_US/d' b2mod_driver_diff.F90
sed -i -e 's/MSTEP_NODIFF/MSTEP/g' heatdiff1D_b.F90
sed -i -e 's/LINES2C_NODIFF/LINES2C/g' heatdiff1D_b.F90
sed -i '/EXTERNAL RWCDF/d' b2mod_mwti_diff.F90 
sed -i '/EXTERNAL B2CRTIMECDF/d' b2mod_mwti_diff.F90 
sed -i '/EXTERNAL CHECK_CDF_STATUS/d' b2mod_mwti_diff.F90 
sed -i '/EXTERNAL OR/d' b2mod_mwti_diff.F90 
sed -i '/INTEGER :: OR/d' b2mod_mwti_diff.F90 
sed -i -e 's/B2MOD_GEO_DIFF/B2MOD_GEO/g' ./*.F90 #why this?
sed -i -e 's/GET_JSEP_NODIFF/GET_JSEP/g' ./*.F90
sed -i -e 's/CFWURE_NODIFF/CFWURE/g' ./*.F90
sed -i -e '/EXTERNAL DIM_FWD/a\  real(kind=r8) :: dim_fwd' b2usht_b.F90 expu_b.F90 expu2_b.F90
sed -i -e '/EXTERNAL EXPU_FWD/a\  real(kind=r8) :: expu_fwd' b2sqcx_b.F90 b2sqel_b.F90 b2mod_recycle_diff.F90
sed -i -e '/EXTERNAL INTP_2DTABLE_B, INTP_2DTABLE0_B, EXPU_FWD/a\  real(kind=r8) :: expu_fwd' b2mod_recycle_diff.F90
sed -i -e 's/#DIM_FWD#/DIM_FWD/g' dim_b.F90
sed -i -e 's/#DIM_BWD#/DIM_BWD/g' dim_b.F90
sed -i -e 's/#DIM_B#/DIM_B/g' dim_b.F90
sed -i -e 's/REAL(kind=r8) FUNCTION DIM_FWD(x, y) RESULT (dim)/FUNCTION DIM_FWD(x, y) RESULT (dim)/g' dim_b.F90
sed -i -e 's/SIZE(sy, 1)+1/n/g' myblas_b.F90
sed -i -e 's/SIZE(sx, 1)+1/n/g' sfill_b.F90

sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_diff.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_diff.F90
sed -i -e "s/REAL\*8/REAL(kind=r8)/g" *_b.F90
sed -i -e "s/REAL\([^(].*::\)/REAL(kind=r8)\1/g" *_b.F90

sed -i -e 's/=>/=/g' b2mod_driver_diff.F90
sed -i -e 's/NULL()/0.0_R8/g' b2mod_driver_diff.F90

sed -i -e "/CALL B2UXUS_B/i\  aab = 0.0_R8" b2usco_b.F90 b2usmo_b.F90 b2usht_b.F90 b2uspo_b.F90
sed -i -e 's/B2UXUS_NODIFF/B2UXUS/g' b2usco_b.F90 b2usmo_b.F90 b2usht_b.F90 b2uspo_b.F90

sed -i -e "/TYPE(B2PLASMASNAPSHOT_DIFF) :: psnc/i\      TYPE(B2PLASMASNAPSHOT_DIFF) :: psnl" b2us_plasma_diff.F90
sed -i -e "s/dtimb, cpustartb/dtimb, cpustartb,dtimb0, cpustartb0, res_quitb0/g" b2mod_driver_diff.F90
sed -i -e "s/dtcob(0:nsdmax-1, 0:cvregmax)/dtcob(0:nsdmax-1, 0:cvregmax),dtcob0(0:nsdmax-1, 0:cvregmax)/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/dtmob(0:nsdmax-1, 0:cvregmax)/dtmob(0:nsdmax-1, 0:cvregmax),dtmob0(0:nsdmax-1, 0:cvregmax)/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/dteeb(0:cvregmax)/dteeb(0:cvregmax),dteeb0(0:cvregmax)/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/dteib(0:cvregmax)/dteib(0:cvregmax),dteib0(0:cvregmax)/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/dtenb(0:cvregmax)/dtenb(0:cvregmax),dtenb0(0:cvregmax)/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/time_factor_requiredb/time_factor_requiredb,time_factor_requiredb0/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/core_dt_suppressionb/core_dt_suppressionb,core_dt_suppressionb0/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/core_dt_factorb/core_dt_factorb,core_dt_factorb0/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/numerics_time_modb/numerics_time_modb,numerics_time_modb0/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/numerics_time_switchb/numerics_time_switchb,numerics_time_switchb0/g" b2mod_numerics_namelist_diff.F90
sed -i -e "s/transport_time_modb/transport_time_modb,transport_time_modb0/g" b2mod_transport_namelist_diff.F90
sed -i -e "s/transport_time_switchb/transport_time_switchb,transport_time_switchb0/g" b2mod_transport_namelist_diff.F90
sed -i -e "s/transport_ip_time_modb/transport_ip_time_modb,transport_ip_time_modb0/g" b2mod_input_profile_diff.F90
sed -i -e "s/transport_ip_time_switchb/transport_ip_time_switchb,transport_ip_time_switchb0/g" b2mod_input_profile_diff.F90
sed -i -e "s/cfdf0b(0:7, 0:nsdecl-1)/cfdf0b(0:7, 0:nsdecl-1),cfdf0b0(0:7, 0:nsdecl-1)/g" b2mod_b2cmpt_diff.F90
sed -i -e "s/rcionb(0:nsdmax-1, nstraid)/rcionb(0:nsdmax-1, nstraid),rcionb0(0:nsdmax-1, nstraid)/g" b2mod_neutrals_namelist_diff.F90
sed -i -e "s/e_fcb/e_fcb,e_fcb0/g" b2mod_neutrals_namelist_diff.F90
sed -i -e "s/b2recycb(0:nsdmax-1, nstraid)/b2recycb(0:nsdmax-1, nstraid),b2recycb0(0:nsdmax-1, nstraid)/g" b2mod_neutrals_namelist_diff.F90
sed -i -e "s/mrecycb(0:nsdmax-1, nstraid)/mrecycb(0:nsdmax-1, nstraid),mrecycb0(0:nsdmax-1, nstraid)/g" b2mod_neutrals_namelist_diff.F90
sed -i -e "s/erecycb(0:nsdmax-1, nstraid)/erecycb(0:nsdmax-1, nstraid),erecycb0(0:nsdmax-1, nstraid)/g" b2mod_neutrals_namelist_diff.F90
sed -i -e "s/monolayer_depositionb(nwall, ntrack)/monolayer_depositionb(nwall, ntrack),monolayer_depositionb0(nwall, ntrack)/g" b2mod_wall_diff.F90
sed -i -e "s/monolayer_erosionb(nwall, ntrack)/monolayer_erosionb(nwall, ntrack),monolayer_erosionb0(nwall, ntrack),erosionb0(nwall, ntrack)/g" b2mod_wall_diff.F90
sed -i -e "s/plate_timeb(nwall)/plate_timeb(nwall),plate_timeb0(nwall)/g" b2mod_wall_diff.F90
sed -i -e "s/ depositionb(nwall, ntrack)/ depositionb(nwall, ntrack),depositionb0(nwall, ntrack),plate_areab0(nwall)/g" b2mod_wall_diff.F90
sed -i -e "s/momparb(0:nsdmax-1, nbcd, 2)/momparb(0:nsdmax-1, nbcd, 2),momparb0(0:nsdmax-1, nbcd, 2)/g" b2mod_boundary_namelist_diff.F90
sed -i -e "s/gammaeb/gammaeb,gammaeb0/g" b2mod_boundary_namelist_diff.F90
sed -i -e "s/conparb(0:nsdmax-1, nbcd, 3)/conparb(0:nsdmax-1, nbcd, 3),conparb0(0:nsdmax-1, nbcd, 3)/g" b2mod_boundary_namelist_diff.F90
sed -i -e "s/eneparb(nbcd, 2)/eneparb(nbcd, 2),eneparb0(nbcd, 2)/g" b2mod_boundary_namelist_diff.F90
sed -i -e "s/eniparb(nbcd, 2)/eniparb(nbcd, 2),eniparb0(nbcd, 2)/g" b2mod_boundary_namelist_diff.F90
sed -i -e "s/potparb(nbcd, 2)/potparb(nbcd, 2),potparb0(nbcd, 2)/g" b2mod_boundary_namelist_diff.F90
sed -i -e "s/znb0(0:nsdecl-1)/znb0(0:nsdecl-1),znb1(0:nsdecl-1)/g" b2mod_b2cmpa_diff.F90
sed -i -e "s/amb0(0:nsdecl-1)/amb0(0:nsdecl-1),amb1(0:nsdecl-1)/g" b2mod_b2cmpa_diff.F90
sed -i -e "s/zaminb(0:nsdecl-1)/zaminb(0:nsdecl-1),zaminb0(0:nsdecl-1),zamaxb0(0:nsdecl-1)/g" b2mod_b2cmpa_diff.F90
sed -i -e "s/b2sian_epsb=0.D0/b2sian_epsb=0.D0,b2sian_epsb0=0.D0,b2tqna_keps_epsb0=0.0D0/g" b2mod_ad_diff.F90
sed -i "/mpgb/d" b2mod_driver_diff.F90 ## CAREFUL! might be needed in future
sed -i "/state_extb/d" b2mod_driver_diff.F90 ## CAREFUL! might be needed in future
sed -i "/stateb2/d" b2mod_driver_diff.F90 ## CAREFUL! might be needed in future
sed -i "/stateb3/d" b2mod_driver_diff.F90 ## CAREFUL! might be needed in future
sed -i "/stateb4/d" b2mod_driver_diff.F90 ## CAREFUL! might be needed in future
sed -i "/stateb5/d" b2mod_driver_diff.F90 ## CAREFUL! might be needed in future
sed -i "/cumul = cumul/d" b2mod_driver_diff.F90 ## CAREFUL! might be needed in future
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      call calc_res_fp(nCv, ns, stateb1, stateb0, cumul)" b2mod_driver_diff.F90
sed -i -e "s/DO WHILE (cumul .GT. 1.0e-6)/DO WHILE (cumul .GT. res_quit)/g" b2mod_driver_diff.F90
sed -i -e "/REAL(kind=r8) :: cumul/i\    INTEGER :: ITERCOUNT" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      ITERCOUNT = ITERCOUNT + 1" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_STARTREPEAT/i\    ITERCOUNT = 0" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      write(*,*) 'GRADIENT ITERATION ',ITERCOUNT" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      write(*,*) 'GRADIENT MAX RES ',cumul" b2mod_driver_diff.F90


sed -i -e "s/b2mn_init_d/b2mn_init_b/g" b2optim_*.F*
sed -i -e "s/b2mn_fin_d/b2mn_fin_b/g" b2optim_*.F*
sed -i -e "s/b2mn_step_d/b2mn_step_b/g" b2optim_*.F*
sed -i -e "s/call b2mn_step_b(j,jd,switchdiff)/call b2mn_step_b(j,switchdiff)/g" b2optim_*.F*
sed -i -e "s/type(switches_diffv)/type(switches)/g" b2optim_*.F*
sed -i -e "/REAL(kind=r8) :: j(nncf)/i\  TYPE(SWITCHES), SAVE :: switchb" b2mn_b.F90
sed -i -e "s/CALL B2MN_STEP_B(j)/CALL B2MN_STEP_B(j,switchb)/g" b2mn_b.F90
sed -i "/TYPE(SWITCHES_DIFF), SAVE :: switchb/d" b2mod_main_diff.F90
sed -i -e "s/SUBROUTINE B2MN_STEP_B(j)/SUBROUTINE B2MN_STEP_B(j,switchb)/g" b2mod_main_diff.F90
sed -i -e "/REAL(kind=r8) :: jb(nncf)/i\    TYPE(SWITCHES), intent(inout) :: switchb" b2mod_main_diff.F90

cp $TAPENADEDIR/ADFirstAidKit/adContext.c .
cp $TAPENADEDIR/ADFirstAidKit/adContext.h .
cp $TAPENADEDIR/ADFirstAidKit/adStack.c .
cp $TAPENADEDIR/ADFirstAidKit/adStack.h .
cp $TAPENADEDIR/ADFirstAidKit/adDebug.c .
cp $TAPENADEDIR/ADFirstAidKit/adDebug.h .
cp $TAPENADEDIR/ADFirstAidKit/adBuffer.f adBuffer.F
cp $TAPENADEDIR/ADFirstAidKit/admm_tapenade_interface.f90 admm_tapenade_interface.F90
sed -i -e 's/USE ISO_C_BINDING/USE, intrinsic :: ISO_C_BINDING/g' admm_tapenade_interface.F90


