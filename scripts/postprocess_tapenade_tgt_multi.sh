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
sed -i -e 's/state_avgd, nbdirs/state_avgd, npar_opt/g' b2mn_d.F90
sed -i -e 's/\&             nbdirs/\&             npar_opt-nsigma_opt-nmean_opt-nshift_opt-ncorr_opt/g' b2mn_d.F90

## insert an extra call to b2usr_cost_function_DV within the fixed point loop, only for output purposes.
## This could have been done using $AD DO-NOT-DIFF pragmas but they fail for adjoint AD
sed -i '/&                         , state, stated, state_ext, switch%boris, j, &/d' b2mod_driver_diffv.F90
sed -i '/&                         jd, nbdirs)/d' b2mod_driver_diffv.F90
sed -i -e "/&              nbdirs)/a\      CALL B2USR_COST_FUNCTION_DV(ncv, nfc, nvx, ns, geo, geod, mpg, mpgd\&" b2mod_driver_diffv.F90
sed -i -e "/&              nbdirs)/a\!     manually inserted call to cost function, for output purposes only" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\    call print_tgt_gradient(jd)" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\    if (first_time_step) write(*,*) 'nbdirs: ',nbdirs+nsigma_opt+nmean_opt+nshift_opt+ncorr_opt" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\&                         jd, nbdirs+nsigma_opt+nmean_opt+nshift_opt+ncorr_opt)" b2mod_driver_diffv.F90
sed -i -e "/B2USR_COST_FUNCTION_DV/a\&                         , state, stated, state_ext, switch%boris, j, &" b2mod_driver_diffv.F90
sed -i -e "0,/call print_tgt_gradient(jd)/s/call print_tgt_gradient(jd)/call print_tgt_gradient(jd)\n      do icf=1,ncf\n        write(ss, \'(I1)\') icf\n        write(\*, \*) 'Cost function value '\/\/ss\/\/': ', j(icf)\n      end do/" b2mod_driver_diffv.F90

## insert an extra call to b2usr_cost_function_NODIFF within the fixed point loop, only for output purposes.
## This could have been done using $AD DO-NOT-DIFF pragmas but they fail for adjoint AD
sed -i -e "/&                  , ierr)/a\      end do" b2mod_driver_diffv.F90
sed -i -e "/&                  , ierr)/a\        write(\*, \*) 'Cost function value '//ss//': ', j(icf)" b2mod_driver_diffv.F90
sed -i -e "/&                  , ierr)/a\        write(ss, '(I1)') icf" b2mod_driver_diffv.F90
sed -i -e "/&                  , ierr)/a\      do icf=1,ncf" b2mod_driver_diffv.F90
sed -i -e "/&                  , ierr)/a\&                             state_ext, switch\%boris, j)" b2mod_driver_diffv.F90
sed -i -e "/&                  , ierr)/a\      call b2usr_cost_function_nodiff(ncv, nfc, nvx, ns, geo, mpg, state, \&" b2mod_driver_diffv.F90
sed -i -e "/&                  , ierr)/a\!     manually inserted call to cost function, for output purposes only" b2mod_driver_diffv.F90

sed -i -e "0,/primal_iterations = itim/s/primal_iterations = itim/primal_iterations = itim\n      gradient_iterations = itim/" b2mod_driver_diffv.F90

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
