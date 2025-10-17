#! /usr/bin/env tcsh

modify_tapenade_files_d_multi.sh

touch b2mod_diffsizes.F
echo "      module b2mod_diffsizes" >> b2mod_diffsizes.F
echo "      implicit none" >> b2mod_diffsizes.F
echo "      integer ,parameter :: nbdirsmax=20" >> b2mod_diffsizes.F
echo "      end module b2mod_diffsizes" >> b2mod_diffsizes.F

sed -i -e "/CALL B2MN_STEP_DV/i\  call xertst(npar_opt.le.nbdirsmax, 'Increase size of nbdirsmax in b2mod_diffsizes.F')" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  call xertst(switch%b2optim_namelist.eq.1, 'Sensitivity calculation needs b2optim_namelist=1!')" b2mn_d.F90
sed -i -e "/CALL B2MN_STEP_DV/i\  call set_tgt_perturbation(switchd)" b2mn_d.F90
sed -i -e 's/DV(nbdirs)/DV(npar_opt)/g' b2mn_d.F90
sed -i -e 's/DV(j, jd, nbdirs)/DV(j, jd, npar_opt-nsigma_opt-nmean_opt-nshift_opt-ncorr_opt)/g' b2mn_d.F90
sed -i '/b2sikt_fac_sheath/d' b2mn_d.F90
sed -i '/b2sikt_fac_diss/d' b2mn_d.F90
sed -i '/b2sikt_fac_vis_rs/d' b2mn_d.F90
sed -i '/b2tfhi_fkt_hie/d' b2mn_d.F90
sed -i '/b2tqna_ballooning/d' b2mn_d.F90
sed -i '/\&                            8)/d' b2mn_d.F90

## insert an extra call to b2usr_cost_function_DV within the fixed point loop, only for output purposes.
## This could have been done using $AD DO-NOT-DIFF pragmas but they fail for adjoint AD
sed -i -e "0,/!    ..increment/s/!    ..increment/!    ..incre1ment/g" b2mod_driver_diffv.F90
sed -i -e '/incre1ment/i\!     manually inserted call to cost function, for output purposes only' b2mod_driver_diffv.F90
sed -i -e '/incre1ment/i\      CALL B2USR_COST_FUNCTION_DV(ncv, nfc, nvx, ns, geo, mpg, state, &' b2mod_driver_diffv.F90
sed -i -e '/incre1ment/i\&             stated, state_ext, j, jd,&' b2mod_driver_diffv.F90
sed -i -e '/incre1ment/i\&             nbdirs+nsigma_opt+nmean_opt+nshift_opt+ncorr_opt)' b2mod_driver_diffv.F90
sed -i -e "/incre1ment/i\      if (first_time_step) write(*,*) 'nbdirs: ',nbdirs+nsigma_opt+nmean_opt+nshift_opt+ncorr_opt" b2mod_driver_diffv.F90
sed -i -e '/incre1ment/i\      call print_tgt_gradient(jd)' b2mod_driver_diffv.F90
sed -i -e '/incre1ment/i\      do icf=1,ncf' b2mod_driver_diffv.F90
sed -i -e "/incre1ment/i\        write(ss, '(I1)') icf" b2mod_driver_diffv.F90
sed -i -e "/incre1ment/i\        if (icf.gt.9) write (ss,'(I2)') icf" b2mod_driver_diffv.F90
sed -i -e "/incre1ment/i\        write(*, *) 'Cost function value '//ss//': ', j(icf)" b2mod_driver_diffv.F90
sed -i -e '/incre1ment/i\      end do' b2mod_driver_diffv.F90

# modify last call to b2usr_cost_function_dv
sed -i -e "/\&                         stated, state_ext, j, jd, nbdirs)/a\    call print_tgt_gradient(jd)" b2mod_driver_diffv.F90
sed -i -e "/\&                         stated, state_ext, j, jd, nbdirs)/a\    if (first_time_step) write(*,*) 'nbdirs: ',nbdirs+nsigma_opt+nmean_opt+nshift_opt+ncorr_opt" b2mod_driver_diffv.F90
sed -i -e "/\&                         stated, state_ext, j, jd, nbdirs)/a\&                         nbdirs+nsigma_opt+nmean_opt+nshift_opt+ncorr_opt)" b2mod_driver_diffv.F90
sed -i -e 's/\&                         stated, state_ext, j, jd, nbdirs)/\&                         stated, state_ext, j, jd, \&/g' b2mod_driver_diffv.F90

## insert an extra call to b2usr_cost_function_NODIFF within the fixed point loop, only for output purposes.
## This could have been done using $AD DO-NOT-DIFF pragmas but they fail for adjoint AD
sed -i -e '/!    ..increment/i\!     manually inserted call to cost function, for output purposes only' b2mod_driver_diffv.F90
sed -i -e '/!    ..increment/i\      call b2usr_cost_function_nodiff(ncv, nfc, nvx, ns, geo, mpg, state, &' b2mod_driver_diffv.F90
sed -i -e '/!    ..increment/i\&                             state_ext, j)' b2mod_driver_diffv.F90
sed -i -e '/!    ..increment/i\      do icf=1,ncf' b2mod_driver_diffv.F90
sed -i -e "/!    ..increment/i\        write(ss, '(I1)') icf" b2mod_driver_diffv.F90
sed -i -e "/!    ..increment/i\        if (icf.gt.9) write (ss,'(I2)') icf" b2mod_driver_diffv.F90
sed -i -e "/!    ..increment/i\        write(*, *) 'Cost function value '//ss//': ', j(icf)" b2mod_driver_diffv.F90
sed -i -e '/!    ..increment/i\      end do' b2mod_driver_diffv.F90

sed -i -e 's/incre1ment/increment/g' b2mod_driver_diffv.F90

sed -i -e "0,/primal_iterations = itim/s/primal_iterations = itim/primal_iterations = itim\n      gradient_iterations = itim/" b2mod_driver_diffv.F90

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

sed -i -e "/CALL B2MNDT_DV/i\      call set_parameters(switch)" b2mod_driver_diffv.F90
sed -i -e "/CALL B2MNDT_NODIFF/i\      call set_parameters(switch)" b2mod_driver_diffv.F90
