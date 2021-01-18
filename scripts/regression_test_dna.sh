#! /usr/bin/env tcsh

modify_tapenade_files_d.sh

sed -i '/&                          jd)/d' b2mod_driver_diff.F90
sed -i -e "/B2USR_COST_FUNCTION_D/a\      END DO" b2mod_driver_diff.F90
sed -i -e "/B2USR_COST_FUNCTION_D/a\        write(*,*) 'Cost function gradient '//ss//': ',Jd(icf)" b2mod_driver_diff.F90
sed -i -e "/B2USR_COST_FUNCTION_D/a\        write (ss,'(I1)') icf" b2mod_driver_diff.F90
sed -i -e "/B2USR_COST_FUNCTION_D/a\      DO ICF=1, NCF" b2mod_driver_diff.F90
sed -i -e "/B2USR_COST_FUNCTION_D/a\&                          jd)" b2mod_driver_diff.F90

sed -i "/ADCONTEXTTGT/d" b2mn_d.F90
sed -i "/r8\*nsdmax/d" b2mn_d.F90

sed -i -e "/READ_B2MOD_TRANSPORT_NAMELIST/a\  parm_dnad(1) = 1.0_R8" b2tqna_d.F90 b2mod_driver_diff.F90
sed -i -e "/READ_B2MOD_TRANSPORT_NAMELIST/a\  parm_dnad = 0.0_R8" b2tqna_d.F90 b2mod_driver_diff.F90
sed -i -e 's/parm_dnad(1) = 0.0/parm_dnad(1) = 1.0_R8/g' b2tqna_d.F90 # can be directly removed??

sed -i -e 's/ipgtmx=40/ipgtmx=4000/g' ipmain.F

setenv DIFF_D yes
cd $SOLPSTOP
gmake listobj
gmake depend
gmake b25_diff_d
unsetenv DIFF_D


