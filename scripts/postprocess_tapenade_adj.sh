#! /usr/bin/env tcsh

modify_tapenade_files_b.sh

sed -i -e "/CALL B2MNDR_1_B/i\    jb = 0.0_R8" b2mod_main_diff.F90
sed -i -e "/CALL B2MNDR_1_B/i\    jb(1) = 1.0_R8" b2mod_main_diff.F90

sed -i -e "/REAL(kind=r8) :: jb(nncf)/i\    REAL(kind=r8) :: jsave(nncf)" b2mod_driver_diff.F90
sed -i -e "/B2USR_COST_FUNCTION_B/i\    jsave = j" b2mod_driver_diff.F90
sed -i -e "/END SUBROUTINE B2MNDR_1_B/i\    j = jsave" b2mod_driver_diff.F90

sed -i -e 's/ipgtmx=40/ipgtmx=4000/g' b2mod_ipmain.F

sed -i -e "/CALL B2MNDR_1/i\    call set_parameters(switch)" b2mod_main_diff.F90

sed -i -e "/CALL B2MNDT_B/i\      parm_dnab = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_B/i\      parm_hceb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_B/i\      parm_hcib = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_B/i\      parm_vsab = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_B/i\      parm_sigb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_B/i\      parm_alfb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_B/i\      conparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_B/i\      momparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_B/i\      potparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_B/i\      eneparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_B/i\      eniparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_B/i\      enkparb = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_B/i\      tdatab = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_B/i\      switchb%b2sikt_fac_sheath = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_B/i\      switchb%b2sikt_fac_sheath_core = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_B/i\      switchb%keps_cd = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_B/i\      switchb%keps_heat = 0.D0" b2mod_driver_diff.F90
sed -i -e "/CALL B2MNDT_B/i\      switchb%keps_heat_i = 0.D0" b2mod_driver_diff.F90
sed -i -e 's/TYPE(SWITCHES_DIFF)/TYPE(SWITCHES)/g' ./*.F90

sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      write(*,*) 'GRADIENT dna ',parm_dnab(1)" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      write(*,*) 'GRADIENT hce ',parm_hceb" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      write(*,*) 'GRADIENT hci ',parm_hcib(1)" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      write(*,*) 'GRADIENT conpar 1',conparb(1,1,1)" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      write(*,*) 'GRADIENT enepar 1',eneparb(1,1)" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      write(*,*) 'GRADIENT enipar 1',eniparb(1,1)" b2mod_driver_diff.F90
sed -i -e "/CALL ADSTACK_RESETREPEAT/i\      write(*,*) 'GRADIENT recyc 2',b2recycb(1,2)" b2mod_driver_diff.F90


sed -i -e "/REAL(kind=r8) :: jb(nncf)/i\    integer :: ii" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT dna ',parm_dnab(1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT hce ',parm_hceb" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT hci ',parm_hcib(1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT conpar 1',conparb(1,1,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT conpar 2',conparb(1,2,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT conpar 3',conparb(1,3,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT conpar 4',conparb(1,4,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT conpar 5',conparb(1,5,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT conpar 6',conparb(1,6,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enepar 1',eneparb(1,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enepar 2',eneparb(2,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enepar 3',eneparb(3,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enepar 4',eneparb(4,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enepar 5',eneparb(5,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enepar 6',eneparb(6,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enipar 1',eniparb(1,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enipar 2',eniparb(2,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enipar 3',eniparb(3,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enipar 4',eniparb(4,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enipar 5',eniparb(5,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enipar 6',eniparb(6,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enkpar 1',enkparb(1,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enkpar 2',enkparb(2,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enkpar 3',enkparb(3,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enkpar 4',enkparb(4,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enkpar 5',enkparb(5,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT enkpar 6',enkparb(6,1)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT b2sikt_fac_sheath',switchb%b2sikt_fac_sheath" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT b2sikt_fac_sheath_core',switchb%b2sikt_fac_sheath_core" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT keps_cd',switchb%keps_cd" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT keps_heat',switchb%keps_heat" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      write(*,*) 'GRADIENT keps_heat_i',switchb%keps_heat_i" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      do ii=1,nsigma" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\        write(*,*) 'GRADIENT sigma',sigmab(ii)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      end do" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      if (allocated(par_opt_physb)) then" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\        do ii=1,npar_opt" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\          write(*,*) 'GRADIENT par_opt_phys',par_opt_physb(ii)" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\        end do" b2mod_main_diff.F90
sed -i -e "/CALL ADCONTEXTADJ_STARTCONCLUDE/i\      endif" b2mod_main_diff.F90

sed -i '/ADCONTEXTADJ/d' b2mod_main_diff.F90
sed -i '/r8\*/d' b2mod_main_diff.F90
sed -i '/r8\/8/d' b2mod_main_diff.F90
