#! /usr/bin/env tcsh

modify_tapenade_files_d_multi.sh

touch diffsizes.F
echo "      module diffsizes" >> diffsizes.F
echo "      implicit none" >> diffsizes.F
echo "      integer ,parameter :: nbdirsmax=5" >> diffsizes.F
echo "      end module" >> diffsizes.F
sed -i -e "/CALL B2MN_INIT_DV/i\  nbdirs=5" b2mn_d.F90

sed -i '/&                           nbdirs)/d' b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\      END DO" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\      END DO" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\        write(*,*) 'Cost function gradient '//ss//': ',Jd(nd,icf)" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\        write (ss,'(I1)') icf" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\      DO nd=1,nbdirs" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\      DO ICF=1, NCF" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\      if (first_time_step) write(*,*) 'nbdirs: ',nbdirs" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\&                           nbdirs)" b2mod_driver_diffv.F90

sed -i "/ADCONTEXTTGT/d" b2mod_main_diffv.F90
sed -i "/r8\*nbcd\*2/d" b2mod_main_diffv.F90
sed -i "/\*8\*nsdecl\/4/d" b2mod_main_diffv.F90
sed -i "/\*8\/4/d" b2mod_main_diffv.F90

sed -i -e "/enepar = 0.0_R8/i\    enepard = 0.0_R8" b2mod_boundary_namelist_diffv.F90
sed -i -e "/enepar = 0.0_R8/i\    enepard(1,1,1) = 1.0_R8" b2mod_boundary_namelist_diffv.F90
sed -i -e "/enipar = 0.0_R8/i\    enipard = 0.0_R8" b2mod_boundary_namelist_diffv.F90
sed -i -e "/enipar = 0.0_R8/i\    enipard(2,1,1) = 1.0_R8" b2mod_boundary_namelist_diffv.F90

sed -i -e "/CALL SFILL_DV(ncv, 0.0_R8, hci0, hci0d, 1, nbdirs)/i\  cfhced = 0.0_R8" b2tqna_dv.F90
sed -i -e "/CALL SFILL_DV(ncv, 0.0_R8, hci0, hci0d, 1, nbdirs)/i\  cfhcid = 0.0_R8" b2tqna_dv.F90
sed -i -e "/CALL SFILL_DV(ncv, 0.0_R8, hci0, hci0d, 1, nbdirs)/i\  cfdnad = 0.0_R8" b2tqna_dv.F90
sed -i -e "/CALL SFILL_DV(ncv, 0.0_R8, hci0, hci0d, 1, nbdirs)/i\  cfhced(3,0) = 1.0_R8" b2tqna_dv.F90
sed -i -e "/CALL SFILL_DV(ncv, 0.0_R8, hci0, hci0d, 1, nbdirs)/i\  cfhcid(4,0,1) = 1.0_R8" b2tqna_dv.F90
sed -i -e "/CALL SFILL_DV(ncv, 0.0_R8, hci0, hci0d, 1, nbdirs)/i\  cfdnad(5,0,1) = 1.0_R8" b2tqna_dv.F90

setenv DIFF_D yes
cd $SOLPSTOP
gmake listobj
gmake depend
gmake b25_diff_d
unsetenv DIFF_D
