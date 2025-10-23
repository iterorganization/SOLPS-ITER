#! /usr/bin/env tcsh

modify_tapenade_files_b.sh

sed -i -e 's/TYPE(SWITCHES_DIFF)/TYPE(SWITCHES)/g' ./*.F90

sed -i -e "/CALL B2MN_STEP_B/i\  call xertst(switch%b2optim_namelist.eq.1, &" b2mn_b.F90
sed -i -e "/CALL B2MN_STEP_B/i\&   'Sensitivity calculation needs b2optim_namelist=1!')" b2mn_b.F90
sed -i -e "/CALL B2MN_STEP_B/i\  par_opt_physb = 0.0_R8" b2mn_b.F90
sed -i -e "/CALL B2MN_STEP_B/i\  call print_adj_parameters()" b2mn_b.F90

sed -i -e "/CALL B2MNDR_1_B/i\    jb = 0.0_R8" b2mod_main_diff.F90
sed -i -e "/CALL B2MNDR_1_B/i\    jb(1) = 1.0_R8" b2mod_main_diff.F90

sed -i -e "/REAL(kind=r8) :: jb(nncf)/i\    REAL(kind=r8) :: jsave(nncf)" b2mod_driver_diff.F90
sed -i -e "/REAL(kind=r8) :: jb(nncf)/i\    REAL(kind=r8) :: dummygrad(npar_opt)" b2mod_driver_diff.F90
sed -i -e "/B2USR_COST_FUNCTION_B/i\    jsave = j" b2mod_driver_diff.F90
sed -i -e "/END SUBROUTINE B2MNDR_1_B/i\    j = jsave" b2mod_driver_diff.F90

sed -i -e "/  LOGICAL, SAVE :: b2news_solving(4)=.true./a\  LOGICAL, SAVE :: last_call_transp=.false." b2mod_ad_diff.F90

sed -i -e 's/ipgtmx=4/ipgtmx=40/g' b2mod_ipmain.F

sed -i -e "/^    CALL B2MNDT_NODIFF/i\    call set_parameters(switch)" b2mod_driver_diff.F90
sed -i -e "/^      CALL B2MNDT_NODIFF/i\      call set_parameters(switch)" b2mod_driver_diff.F90

sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      call set_adj_gradient(npar_opt,dummygrad,switchb)" b2mod_driver_diff.F90
sed -i -e "/END SUBROUTINE B2MNDR_1_B/i\    call set_adj_gradient(npar_opt,dummygrad,switchb)" b2mod_driver_diff.F90

sed -i -e '0,/CALL B2MNDT_B0/s/CALL B2MNDT_B0/CALL B2MNDT_B10/ g' b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B10/i\      conparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B10/i\      potparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B10/i\      eneparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B10/i\      eniparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B10/i\      tdatab = 0.D0" b2mod_driver_diff.F90

sed -i -e "/    CALL B2MNDT_B0/i\    switchb%keps_cd = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%keps_heat = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%keps_heat_i = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%keps_sig = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%keps_alf = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%keps_visc = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%keps_dkt = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%keps_dzt = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%keps_shear = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%b2sikt_fac_sheath = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%b2sikt_fac_sheath_core = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%b2sikt_fac_diss = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%b2sikt_fac_diss_core = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%b2sikt_fac_vis_rs = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%b2tfhi_fflokt = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%b2tfhi_fconkt = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%b2tfhi_fflozt = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%b2tfhi_fconzt = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%b2tfhi_fsigkt = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%b2tfhi_fkt_hie = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%b2tfhe_vis_kt = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%b2tqna_ballooning = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    switchb%b2tqna_ballooning_rescale = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    IF (ALLOCATED(rtlcxb)) rtlcxb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    IF (ALLOCATED(rtlqab)) rtlqab = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    IF (ALLOCATED(rtlrab)) rtlrab = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    IF (ALLOCATED(rtlsab)) rtlsab = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    parm_hcib = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    parm_vsab = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    parm_vlab = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    parm_dpab = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    parm_dnab = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    parm_alfb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    parm_sigb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    parm_hceb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    enkparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    momparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    b2recycb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    conparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    potparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    eneparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    eniparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    tdatab = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\!   csc the next enables to save the sensitivity of transport coefficients" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\!   for each point of the domain but only for the call to b2tqna within" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\!   the next call to b2mndt" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B0/i\    last_call_transp = .true." b2mod_driver_diff.F90
sed -i -e 's/CALL B2MNDT_B10/CALL B2MNDT_B0/ g' b2mod_driver_diff.F90

sed -i '/copy_background_iout/d' b2mod_driver_diff.F90
sed -i '/b2tqce_style_guard_cells/d' b2mod_driver_diff.F90
sed -i -e "/rtlcxb = rtlcxb0/i\    write(*,*) 'TOTAL ADJOINT GRADIENT ITERATIONS ',ITERCOUNT" b2mod_driver_diff.F90
sed -i -e "/rtlcxb = rtlcxb0/i\    gradient_iterations = ITERCOUNT" b2mod_driver_diff.F90
sed -i -e "/rtlcxb = rtlcxb0/i\    switchb = switchb0" b2mod_driver_diff.F90

sed -i -e "/REAL(kind=r8) :: jb(nncf)/i\    integer :: ii" b2mod_main_diff.F90

sed -i '/ADCONTEXTADJ/d' b2mod_main_diff.F90
sed -i '/r8\*/d' b2mod_main_diff.F90
sed -i '/r8\/8/d' b2mod_main_diff.F90
