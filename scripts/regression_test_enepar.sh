#! /usr/bin/env tcsh

modify_tapenade_files_d.sh

sed -i -e "/B2USR_COST_FUNCTION_D/a\      END DO" b2mod_driver_diff.F90
sed -i -e "/B2USR_COST_FUNCTION_D/a\        write(*,*) 'Cost function gradient '//ss//': ',Jd(icf)" b2mod_driver_diff.F90
sed -i -e "/B2USR_COST_FUNCTION_D/a\        write (ss,'(I1)') icf" b2mod_driver_diff.F90
sed -i -e "/B2USR_COST_FUNCTION_D/a\      DO ICF=1, NCF" b2mod_driver_diff.F90

sed -i "/ADCONTEXTTGT/d" b2mod_main_diff.F90
sed -i "/r8\*nbcd\*2/d" b2mod_main_diff.F90

sed -i -e "/enepar = 0.0_R8/i\    enepard = 0.0_R8" b2mod_boundary_namelist_diff.F90
sed -i -e "/enepar = 0.0_R8/i\    enepard(1,1) = 1.0_R8" b2mod_boundary_namelist_diff.F90

setenv DIFF_D yes
cd $SOLPSTOP
gmake listobj
gmake depend
gmake b25_diff_d
unsetenv DIFF_D

cd runs/small


