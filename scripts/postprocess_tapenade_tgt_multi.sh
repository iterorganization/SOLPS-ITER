#! /usr/bin/env tcsh

modify_tapenade_files_d_multi.sh

touch b2mod_diffsizes.F
echo "      module b2mod_diffsizes" >> b2mod_diffsizes.F
echo "      implicit none" >> b2mod_diffsizes.F
echo "      integer ,parameter :: nbdirsmax=20" >> b2mod_diffsizes.F
echo "      end module b2mod_diffsizes" >> b2mod_diffsizes.F
sed -i -e "/CALL B2MN_INIT_DV/i\  nbdirs=6" b2mn_d.F90

sed -i '/&                           mpgd, state, stated, state_ext, state_extd, &/d' b2mod_driver_diffv.F90
sed -i '/&                           switch%boris, j, jd, nbdirs)/d' b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\      END DO" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\      END DO" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\        write(*,*) 'Cost function gradient '//trim(ss)//': ',Jd(nd,icf)" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\        if (icf.gt.9) write (ss,'(I2)') icf" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\        write (ss,'(I1)') icf" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\      DO nd=1,nbdirs" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\      DO ICF=1, NCF" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\      if (first_time_step) write(*,*) 'nbdirs: ',nbdirs" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\&                           switch%boris, j, jd, nndirs)" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\&                           mpgd, state, stated, state_ext, state_extd, &" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/i\      if (flag_optim) then" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/i\        nndirs = nbdirs+nsigma_opt" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/i\      else" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/i\        nndirs = nbdirs" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/i\      endif" b2mod_driver_diffv.F90
sed -i -e "/TYPE(SWITCHES_DIFFV), INTENT(INOUT) :: switchd/a\    INTEGER :: nndirs" b2mod_driver_diffv.F90

sed -i "/ADCONTEXTTGT/d" b2mn_d.F90 b2stbr_dv.F90 b2mod_user_namelist_diffv.F90
sed -i "/r8\*nbcd\*2/d" b2mn_d.F90
sed -i "/\*8\*nsdecl\/8/d" b2mn_d.F90
sed -i "/r8\/8/d" b2mn_d.F90
sed -i "/r8\*nsdmax/d" b2mn_d.F90
sed -i "/nsigmx/d" b2mn_d.F90
sed -i "/\*nkind_coeff/d" b2mn_d.F90

#sed -i -e 's/ipgtmx=400/ipgtmx=4000/g' b2mod_ipmain.F

sed -i -e '/enkpard(nd, :, :) = 0.D0/d' b2mod_driver_diffv.F90
sed -i -e '/parm_dnad(nd, 1) = 0.D0/d' b2tqna_dv.F90
sed -i -e '/parm_hced(nd) = 0.D0/d' b2tqna_dv.F90 
sed -i -e '/parm_hcid(nd, 1) = 0.D0/d' b2tqna_dv.F90
sed -i -e '/tdatad(nd, :, :, :, :) = 0.D0/d' b2mod_input_profile_diffv.F90
sed -i -e '/fd(nd, i) = 0.D0/d' b2mod_input_profile_diffv.F90

sed -i -e "/CALL B2MNDR_1/i\    call set_parameters(switch)" b2mod_main_diffv.F90

sed -i -e "/CALL B2MN_STEP_DV/i\  parm_dnad = 0.0_R8" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  parm_hcid = 0.0_R8" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  parm_hced = 0.0_R8" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  parm_vsad = 0.0_R8" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  parm_sigd = 0.0_R8" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  parm_alfd = 0.0_R8" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  conpard = 0.0_R8" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  mompard = 0.0_R8" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  potpard = 0.0_R8" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  enepard = 0.0_R8" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  enipard = 0.0_R8" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  enkpard = 0.0_R8" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  enkpard = 0.0_R8" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  tdatad = 0.0_R8" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  b2recycd = 0.0_R8" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  tdatad(9,2,5,4,1) = 1.0_R8 \!Xe_perp" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  tdatad(8,2,3,4,1) = 1.0_R8 \!Xe_perp" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  tdatad(7,2,6,3,1) = 1.0_R8 \!Xi_perp" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  tdatad(6,2,1,3,1) = 1.0_R8 \!Xi_perp" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  tdatad(5,2,4,1,1) = 1.0_R8 \!D_perp" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  tdatad(4,2,2,1,1) = 1.0_R8 \!D_perp" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  parm_hcid(3,1) = 1.0_R8" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  parm_hced(2) = 1.0_R8" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  parm_dnad(1,1) = 1.0_R8" b2mn_d.F90
