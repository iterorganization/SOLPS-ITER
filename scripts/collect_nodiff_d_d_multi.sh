MODLIST=`ls b2mod*_diffv_dv.F90 b2us_*_diffv_dv.F90 | sed -e 's/_dv.F90//g'`
cat $SOLPSTOP/modules/B2.5/src/differentiation/files_to_exclude.txt > tmp
ls b2mod*_dv.F90 b2us_*_dv.F90 | sed -e 's/_dv.F90//g' >> tmp
for d in $MODLIST; do
mv $d"_dv.F90" $d"_diffv.F90"
done;
ls *_dv.F90 | sed -e 's/_dv.F90//g' >> tmp

rm -r temp
mkdir temp
cd temp
mv ../tmp .

copy_nodiff_files.sh

# remove some files that are not needed for hessian tgt (for the moment)
rm ank_interface.F b2mod_b2plot_debug.F b2mod_work.F b2ptrdl.F b2pwlprp.F b2pwrdld.F b2wdat.F b2xpnn.F b2xpnr.F b2xppb.F b2xvff.F b2xvfx.F cond_coef.F find_faces.F fortranAdaptor.F90 interp2d.F mstep.F rlcomp.F

cp $SOLPSTOP/modules/B2.5/src/differentiation/solve_covariance_dv.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/solve_covariance_dv_dv.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/erf_dv.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/b2uxus_dv.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/b2uxus_dv_dv.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/dim_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/print_tgt_hessian.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/b2mwqt_diffv_diffv.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/b2mxac_diffv_diffv.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/b2mxar_diffv_diffv.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/set_tgt_tgt_perturbation.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/invert_matrix_dv.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/intp_2dtable_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/intp_3dtable_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/cpeir_bilinear_int_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2xzmf_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2nxcm_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2nxst_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2uppo_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/intface_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/upwind_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/hybr_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/trilinear_int_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/interp1d_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/nagsubst_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/map_and_interpolate_cf_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/uxcm_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2mod_b2cmpa_diffv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2mod_elements_diffv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2mod_b2cmpb_diffv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2mod_plasma_diffv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2us_work_diffv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2trca_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2trcv_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2trtf_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2trhw_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2xpnr_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2xppb_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2xpnn_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2trnu_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/species_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/tangent/b2ruzd_dv.F90 .

# and now modify the 'use modules' which have been differentiated
files=`ls *.F*`
for d in $MODLIST; do
f=$d"_diffv"
echo "Now modifying the use of "$d" into "$f
sed -i -e "s/\<use $d\>/use $f/g" $files
done;

echo "Files that have been excluded from differentiation have been copied to differentiation directory for compiling"

mv ./*.F ../
mv ./*.F90 ../
cd ../
rm -r temp


