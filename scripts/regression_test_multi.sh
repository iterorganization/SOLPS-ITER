#! /usr/bin/env tcsh

modify_tapenade_files_d_multi.sh

touch diffsizes.F
echo "      module diffsizes" >> diffsizes.F
echo "      implicit none" >> diffsizes.F
echo "      integer ,parameter :: nbdirsmax=20" >> diffsizes.F
echo "      end module" >> diffsizes.F
sed -i -e "/CALL B2MN_INIT_DV/i\  nbdirs=6" b2mn_d.F90

sed -i '/&                           nbdirs)/d' b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\      END DO" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\      END DO" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\        write(*,*) 'Cost function gradient '//ss//': ',Jd(nd,icf)" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\        write (ss,'(I1)') icf" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\      DO nd=1,nbdirs" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\      DO ICF=1, NCF" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\      if (first_time_step) write(*,*) 'nbdirs: ',nbdirs" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\&                           nbdirs)" b2mod_driver_diffv.F90

sed -i "/ADCONTEXTTGT/d" b2mn_d.F90 b2stbr_dv.F90 b2mod_user_namelist_diffv.F90
sed -i "/r8\*nbcd\*2/d" b2mn_d.F90
sed -i "/\*8\*nsdecl\/8/d" b2mn_d.F90
sed -i "/r8\/8/d" b2mn_d.F90
sed -i "/r8\*nsdmax/d" b2mn_d.F90

sed -i -e "/enepar = 0.0_R8/i\    enepard = 0.0_R8" b2mod_boundary_namelist_diffv.F90
sed -i -e "/enepar = 0.0_R8/i\    enepard(4,1,1) = 1.0_R8" b2mod_boundary_namelist_diffv.F90
sed -i -e "/enipar = 0.0_R8/i\    enipard = 0.0_R8" b2mod_boundary_namelist_diffv.F90
sed -i -e "/enipar = 0.0_R8/i\    enipard(5,1,1) = 1.0_R8" b2mod_boundary_namelist_diffv.F90
sed -i -e "/conpar = 0.0_R8/i\    conpard = 0.0_R8" b2mod_boundary_namelist_diffv.F90
sed -i -e "/conpar = 0.0_R8/i\    conpard(6,1,1,1) = 1.0_R8" b2mod_boundary_namelist_diffv.F90

sed -i -e "/READ_B2MOD_TRANSPORT_NAMELIST/a\  parm_dnad(1,1) = 1.0_R8" b2tqna_dv.F90 b2mod_driver_diffv.F90
sed -i -e "/READ_B2MOD_TRANSPORT_NAMELIST/a\  parm_hcid(3,1) = 1.0_R8" b2tqna_dv.F90 b2mod_driver_diffv.F90
sed -i -e "/READ_B2MOD_TRANSPORT_NAMELIST/a\  parm_hced(2) = 1.0_R8" b2tqna_dv.F90 b2mod_driver_diffv.F90
sed -i -e "/READ_B2MOD_TRANSPORT_NAMELIST/a\  parm_dnad = 0.0_R8" b2tqna_dv.F90 b2mod_driver_diffv.F90
sed -i -e "/READ_B2MOD_TRANSPORT_NAMELIST/a\  parm_hcid = 0.0_R8" b2tqna_dv.F90 b2mod_driver_diffv.F90
sed -i -e "/READ_B2MOD_TRANSPORT_NAMELIST/a\  parm_hced = 0.0_R8" b2tqna_dv.F90 b2mod_driver_diffv.F90

sed -i -e 's/ipgtmx=40/ipgtmx=4000/g' ipmain.F

sed -i -e '/parm_dnad(nd, 1) = 0.D0/d' b2tqna_dv.F90
sed -i -e '/parm_hced(nd) = 0.D0/d' b2tqna_dv.F90 
sed -i -e '/parm_hcid(nd, 1) = 0.D0/d' b2tqna_dv.F90
sed -i -e '/tdatad(nd, :, :, :, :) = 0.D0/d' b2mod_input_profile_diffv.F90
sed -i -e '/fd(nd, i) = 0.D0/d' b2mod_input_profile_diffv.F90

setenv DIFF_D yes
cd $SOLPSTOP
gmake listobj
gmake depend
gmake b25_diff_d
unsetenv DIFF_D
