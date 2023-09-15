#! /usr/bin/env tcsh

modify_tapenade_files_d_multi.sh

touch b2mod_diffsizes.F
echo "      module b2mod_diffsizes" >> b2mod_diffsizes.F
echo "      implicit none" >> b2mod_diffsizes.F
echo "      integer ,parameter :: nbdirsmax=20" >> b2mod_diffsizes.F
echo "      end module b2mod_diffsizes" >> b2mod_diffsizes.F

sed -i -e "/CALL B2MN_STEP_DV/i\  call xertst(npar_opt.le.nbdirsmax, 'Increase size of nbdirsmax in diffsizes.F')" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  call xertst(switch%b2optim_namelist.eq.1, 'Sensitivity calculation needs b2optim_namelist=1!')" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  call set_tgt_perturbation(switchd)" b2mn_d.F90
sed -i -e 's/state_extd, nbdirs/state_extd, npar_opt/g' b2mn_d.F90
sed -i -e 's/j, jd, nbdirs/j, jd, npar_opt-nsigma_opt-nmean_opt-nshift_opt/g' b2mn_d.F90


sed -i '/&                           mpgd, state, stated, state_ext, state_extd, &/d' b2mod_driver_diffv.F90
sed -i '/&                           switch%boris, j, jd, nbdirs)/d' b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\      call print_tgt_gradient(jd,ncf)" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\      if (first_time_step) write(*,*) 'nbdirs: ',nbdirs" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\&                           switch%boris, j, jd, nbdirs+nsigma_opt+nmean_opt+nshift_opt)" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\&                           mpgd, state, stated, state_ext, state_extd, &" b2mod_driver_diffv.F90
sed -i -e "/TYPE(SWITCHES_DIFFV), INTENT(INOUT) :: switchd/a\    INTEGER :: nndirs" b2mod_driver_diffv.F90

sed -i "/ADCONTEXTTGT/d" b2mn_d.F90 b2stbr_dv.F90 b2mod_user_namelist_diffv.F90
sed -i "/r8\*nbcd\*2/d" b2mn_d.F90
sed -i "/\*8\*nsdecl\/8/d" b2mn_d.F90
sed -i "/r8\/8/d" b2mn_d.F90
sed -i "/r8\*nsdmax/d" b2mn_d.F90
sed -i "/nsigmx/d" b2mn_d.F90
sed -i "/\*nkind_coeff/d" b2mn_d.F90

sed -i -e '/enkpard(nd, :, :) = 0.D0/d' b2mod_driver_diffv.F90
sed -i -e '/parm_dnad(nd, 1) = 0.D0/d' b2tqna_dv.F90
sed -i -e '/parm_hced(nd) = 0.D0/d' b2tqna_dv.F90 
sed -i -e '/parm_hcid(nd, 1) = 0.D0/d' b2tqna_dv.F90
sed -i -e '/tdatad(nd, :, :, :, :) = 0.D0/d' b2mod_input_profile_diffv.F90
sed -i -e '/fd(nd, i) = 0.D0/d' b2mod_input_profile_diffv.F90

sed -i -e "/CALL B2MNDR_1/i\    call set_parameters(switch)" b2mod_main_diffv.F90
