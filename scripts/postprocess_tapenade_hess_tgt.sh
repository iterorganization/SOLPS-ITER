#! /usr/bin/env tcsh

modify_tapenade_files_d_d_multi.sh

touch b2mod_diffsizes.F
echo "      module b2mod_diffsizes" >> b2mod_diffsizes.F
echo "      implicit none" >> b2mod_diffsizes.F
echo "      integer ,parameter :: nbdirsmax=10" >> b2mod_diffsizes.F
echo "      integer ,parameter :: nbdirsmax0=nbdirsmax" >> b2mod_diffsizes.F
echo "      end module b2mod_diffsizes" >> b2mod_diffsizes.F

# define block 1
setenv l1 `grep -n ADCONTEXTTGT_INIT b2mod_main_diffv_diffv.F90 | head -n 1 | awk -F ':' '{print $1}'`
setenv l2 `grep -n B2MNDR_1_DV_DV b2mod_main_diffv_diffv.F90 | tail -n 1 | awk -F ':' '{print $1}'`
# define block 2
setenv l3 `grep -n 'ADCONTEXTTGT_STARTCONCLUDE()' b2mod_main_diffv_diffv.F90 | head -n 1 | awk -F ':' '{print $1}'`
setenv l4 `grep -n 'ADCONTEXTTGT_CONCLUDE()' b2mod_main_diffv_diffv.F90 | tail -n 1 | awk -F ':' '{print $1}'`
@ l2m1 = $l2 - 1
if ( "$l1" == "" || "$l2" == "" ) then
    echo "ERROR: could not find markers for block1 in b2mod_main_diffv_diffv, it needs to be manually modified"
endif
if ( "$l3" == "" || "$l4" == "" ) then
    echo "ERROR: could not find markers for block2 in b2mod_main_diffv_diffv, it needs to be manually modified"
endif
sed -i -e "${l3},${l4} d" b2mod_main_diffv_diffv.F90
sed -i -e "${l1},${l2m1} d" b2mod_main_diffv_diffv.F90
sed -i -e 's/B2MN_STEP_DV_DV(j, jd0, jd, jdd, nbdirs)/B2MN_STEP_DV_DV(j, jd0, jd, jdd, nbdirs, nbdirs0)/g' b2mod_main_diffv_diffv.F90
sed -i -e 's/nbdirs0)/npar_opt)/g' b2mn_hess.F90
sed -i -e 's/CALL B2MN_STEP_DV_DV(j, jd0, jd, jdd, arg1, npar_opt)/CALL B2MN_STEP_DV_DV(j, jd0, jd, jdd, arg1, arg1)/g' b2mn_hess.F90
sed -i -e '/CALL B2MN_STEP_DV_DV/i\  CALL SET_TGT_TGT_PERTURBATION(switchd,switchd0)' b2mn_hess.F90

sed -i -e 's/arg10, nbdirs0)/arg10, arg10)/g' b2mod_driver_diffv_diffv.F90
sed -i -e 's/\&                            nbdirs0)/\&                            arg10)/g' b2mod_driver_diffv_diffv.F90
sed -i -e '0,/CALL PRINT_TGT_GRADIENT_NODIFF(jd)/s/CALL PRINT_TGT_GRADIENT_NODIFF(jd)/CALL PRINT_TGT_HESSIAN(jd,jdd)/g' b2mod_driver_diffv_diffv.F90
sed -i -e '0,/CALL PRINT_TGT_GRADIENT_NODIFF(jd)/s/CALL PRINT_TGT_GRADIENT_NODIFF(jd)/CALL PRINT_TGT_HESSIAN(jd,jdd)/g' b2mod_driver_diffv_diffv.F90
sed -i -e '/CALL PRINT_TGT_GRADIENT_NODIFF(jd)/d' b2mod_driver_diffv_diffv.F90

sed -i -e "s/potpardd(:, :, :, :) = 0.0_8/\!potpardd(:, :, :, :) = 0.0_8/g" b2mod_driver_diffv_diffv.F90
sed -i -e "s/conpardd(:, :, :, :, :) = 0.0_8/\!conpardd(:, :, :, :, :) = 0.0_8/g" b2mod_driver_diffv_diffv.F90
sed -i -e "s/enipardd(:, :, :, :) = 0.0_8/\!enipardd(:, :, :, :) = 0.0_8/g" b2mod_driver_diffv_diffv.F90
sed -i -e "s/enepardd(:, :, :, :) = 0.0_8/\!enepardd(:, :, :, :) = 0.0_8/g" b2mod_driver_diffv_diffv.F90

