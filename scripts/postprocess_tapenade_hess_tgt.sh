#! /usr/bin/env tcsh

modify_tapenade_files_d_d_multi.sh

touch b2mod_diffsizes.F
echo "      module b2mod_diffsizes" >> b2mod_diffsizes.F
echo "      implicit none" >> b2mod_diffsizes.F
echo "      integer ,parameter :: nbdirsmax=10" >> b2mod_diffsizes.F
echo "      integer ,parameter :: nbdirsmax0=nbdirsmax" >> b2mod_diffsizes.F
echo "      end module b2mod_diffsizes" >> b2mod_diffsizes.F

sed -i -e '/ADCONTEXT/d' b2mn_hess.F90
sed -i -e 's/state_avg, state_avgd, npar_opt, nbdirs0/state_avg, state_avgd, npar_opt, npar_opt/g' b2mn_hess.F90
sed -i -e '/CALL B2MN_STEP_DV_DV/i\  CALL SET_TGT_TGT_PERTURBATION(switchd,switchd0)' b2mn_hess.F90
sed -i -e 's/jd, jdd, arg1, nbdirs0)/jd, jdd, arg1, arg1)/g' b2mn_hess.F90

sed -i -e 's/jdd, arg10, nbdirs0)/jdd, arg10, arg10)/g' b2mod_driver_diffv_diffv.F90
sed -i -e '0,/CALL PRINT_TGT_GRADIENT_NODIFF(jd)/s/CALL PRINT_TGT_GRADIENT_NODIFF(jd)/CALL PRINT_TGT_HESSIAN(jd,jdd)/g' b2mod_driver_diffv_diffv.F90
sed -i -e '0,/CALL PRINT_TGT_GRADIENT_NODIFF(jd)/s/CALL PRINT_TGT_GRADIENT_NODIFF(jd)/CALL PRINT_TGT_HESSIAN(jd,jdd)/g' b2mod_driver_diffv_diffv.F90
sed -i -e '/CALL PRINT_TGT_GRADIENT_NODIFF(jd)/d' b2mod_driver_diffv_diffv.F90

sed -i -e "s/potpardd(:, :, :, :) = 0.0_8/\!potpardd(:, :, :, :) = 0.0_8/g" b2mod_driver_diffv_diffv.F90
sed -i -e "s/conpardd(:, :, :, :, :) = 0.0_8/\!conpardd(:, :, :, :, :) = 0.0_8/g" b2mod_driver_diffv_diffv.F90
sed -i -e "s/enipardd(:, :, :, :) = 0.0_8/\!enipardd(:, :, :, :) = 0.0_8/g" b2mod_driver_diffv_diffv.F90
sed -i -e "s/enepardd(:, :, :, :) = 0.0_8/\!enepardd(:, :, :, :) = 0.0_8/g" b2mod_driver_diffv_diffv.F90

