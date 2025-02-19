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

sed -i -e "/CALL B2MNDT_NODIFF/i\    call set_parameters(switch)" b2mod_driver_diff.F90

sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      call set_adj_gradient(npar_opt,dummygrad,switchb)" b2mod_driver_diff.F90
sed -i -e "/END SUBROUTINE B2MNDR_1_B/i\    call set_adj_gradient(npar_opt,dummygrad,switchb)" b2mod_driver_diff.F90

sed -i -e '0,/CALL B2MNDT_B/{s/CALL B2MNDT_B/CALL B2MNDT_FIRST/g}' b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_FIRST/i\      conparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_FIRST/i\      potparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_FIRST/i\      eneparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_FIRST/i\      eniparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_FIRST/i\      tdatab = 0.D0" b2mod_driver_diff.F90

sed -i -e "/    CALL B2MNDT_B/i\    parm_dnab = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    parm_hceb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    parm_hcib = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    parm_vsab = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    parm_sigb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    parm_alfb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    conparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    momparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    potparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    eneparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    eniparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    enkparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    tdatab = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%keps_cd = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%keps_heat = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%keps_heat_i = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%keps_sig = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%keps_alf = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%keps_visc = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%keps_dkt = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%keps_dzt = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%keps_shear = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%b2sikt_fac_sheath = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%b2sikt_fac_sheath_core = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%b2sikt_fac_diss = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%b2sikt_fac_diss_core = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%b2sikt_fac_vis_rs = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%b2tfhi_fflokt = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%b2tfhi_fconkt = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%b2tfhi_fflozt = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%b2tfhi_fconzt = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%b2tfhi_fsigkt = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%b2tfhi_fkt_hie = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%b2tfhe_vis_kt = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%b2tqna_ballooning = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    switchb%b2tqna_ballooning_rescale = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    IF (ALLOCATED(rtlcxb)) rtlcxb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    IF (ALLOCATED(rtlqab)) rtlqab = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    IF (ALLOCATED(rtlrab)) rtlrab = 0.D0" b2mod_driver_diff.F90
sed -i -e "/    CALL B2MNDT_B/i\    IF (ALLOCATED(rtlsab)) rtlsab = 0.D0" b2mod_driver_diff.F90

sed -i -e "/ CALL B2MNDT_B/i\!   csc the next enables to save the sensitivity of transport coefficients" b2mod_driver_diff.F90
sed -i -e "/ CALL B2MNDT_B/i\!   for each point of the domain but only for the call to b2tqna within" b2mod_driver_diff.F90
sed -i -e "/ CALL B2MNDT_B/i\!   the next call to b2mndt" b2mod_driver_diff.F90
sed -i -e "/ CALL B2MNDT_B/i\    last_call_transp = .true." b2mod_driver_diff.F90
sed -i -e 's/CALL B2MNDT_FIRST/CALL B2MNDT_B/g' b2mod_driver_diff.F90

sed -i -e "/REAL(kind=r8) :: jb(nncf)/i\    integer :: ii" b2mod_main_diff.F90

sed -i '/ADCONTEXTADJ/d' b2mod_main_diff.F90
sed -i '/r8\*/d' b2mod_main_diff.F90
sed -i '/r8\/8/d' b2mod_main_diff.F90
