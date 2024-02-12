MODLIST=`ls b2mod*_b.F90 b2us_*_b.F90 | sed -e 's/_b.F90//g'`
cat $SOLPSTOP/modules/B2.5/src/differentiation/files_to_exclude.txt > tmp
ls b2mod*_b.F90 b2us_*_b.F90 | sed -e 's/_b.F90//g' >> tmp
for d in $MODLIST; do
mv $d"_b.F90" $d"_diff.F90"
done;
ls *_b.F90 | sed -e 's/_b.F90//g' >> tmp
SRCPATH="equations"
# grab the files that have been excluded from differentiation but not the MAIN programs
# To facilitate things SRCPATH can be extended to other folders to automatically grab files in new differentiation, but will also get files not stritly needed for TGT compilation
rm -r temp
mkdir temp
cd temp
mv ../tmp .
for d in $SRCPATH; do
find $SOLPSTOP/modules/B2.5/src/$d -name \*.F -exec basename \{} .F \; | ( while read filename
do
if ! (grep -q -w -i $filename tmp) then
file=`find $SOLPSTOP/modules/B2.5/src/$d -name \$filename.F`
cp $file .
echo "Copied filed "$filename".F to differentiation"
fi
done)

find $SOLPSTOP/modules/B2.5/src/$d -name \*.F90 -exec basename \{} .F90 \; | ( while read filename
do
if ! (grep -q -w -i $filename tmp) then
file=`find $SOLPSTOP/modules/B2.5/src/$d -name \$filename.F90`
cp $file .
echo "Copied filed "$filename".F90 to differentiation"
fi
done)
done;

rm tmp
cp $SOLPSTOP/modules/B2.5/src/b2aux/b2xxgs.F .
cp $SOLPSTOP/modules/B2.5/src/b2aux/b2xxid.F .
cp $SOLPSTOP/modules/B2.5/src/b2aux/b2xzmf.F .
cp $SOLPSTOP/modules/B2.5/src/b2plot/chord.F .
cp $SOLPSTOP/modules/B2.5/src/b2plot/lower_case.F .
cp $SOLPSTOP/modules/B2.5/src/catalyst/fortranAdaptor.F90 .
cp $SOLPSTOP/modules/B2.5/src/catalyst/cxxAdaptor.cxx .
cp $SOLPSTOP/modules/B2.5/src/equations/b2nxcm.F .
cp $SOLPSTOP/modules/B2.5/src/equations/b2nxst.F .
cp $SOLPSTOP/modules/B2.5/src/ids/b2mod_constants.F90 .
cp $SOLPSTOP/modules/B2.5/src/ids/carre_constants.F90 .
cp $SOLPSTOP/modules/B2.5/src/ids/b2mod_cellhelper.F90 .
cp $SOLPSTOP/modules/B2.5/src/ids/tradui_constants.F90 .
cp $SOLPSTOP/modules/B2.5/src/ids/logging.F90 .
cp $SOLPSTOP/modules/B2.5/src/ids/helper.F90 .
cp $SOLPSTOP/modules/B2.5/src/ids/b2mod_grid_mapping.F90 .
cp $SOLPSTOP/modules/B2.5/src/ids/b2mod_connectivity.F90 .
cp $SOLPSTOP/modules/B2.5/src/ids/b2mod_interp.F90 .
cp $SOLPSTOP/modules/B2.5/src/input/b2rflb.F .
cp $SOLPSTOP/modules/B2.5/src/input/b2rusr.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_openmp.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_rates.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_geo_corner.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_b2cmfs.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_eirdiag.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_indirect.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_types.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_time.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_residuals.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_eirene_globals.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_mwti.F90 .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_cdf.F90 .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_ma28_for_us.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_eirbra.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_b2_to_astr* .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_astra_to_b2.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_b2cmgs.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_b2plot_wall_loading.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_ranges.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_work.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2mod_b2plot_debug.F .
cp $SOLPSTOP/modules/B2.5/src/modules/b2us_debug.F .
cp $SOLPSTOP/modules/B2.5/src/output/b2wdat.F .
cp $SOLPSTOP/modules/B2.5/src/solvers/b2uxus.F .
cp $SOLPSTOP/modules/B2.5/src/sources/average.F .
cp $SOLPSTOP/modules/B2.5/src/sources/setwrk0.F .
cp $SOLPSTOP/modules/B2.5/src/sources/integrate.F .
cp $SOLPSTOP/modules/B2.5/src/sources/ggfill.F .
cp $SOLPSTOP/modules/B2.5/src/sources/eirene_mc_init.F .
cp $SOLPSTOP/modules/B2.5/src/user/batch_average.F .
cp $SOLPSTOP/modules/B2.5/src/user/b2mod_file.F .
cp $SOLPSTOP/modules/B2.5/src/user/b2mod_trace.F .
cp $SOLPSTOP/modules/B2.5/src/user/b2mod_bln* .
cp $SOLPSTOP/modules/B2.5/src/user/b2mod_wr* .
cp $SOLPSTOP/modules/B2.5/src/user/b2mod_usrtrc.F .
cp $SOLPSTOP/modules/B2.5/src/user/combfile.F .
cp $SOLPSTOP/modules/B2.5/src/user/parsehdr.F .
cp $SOLPSTOP/modules/B2.5/src/user/eirflux_map.F .
cp $SOLPSTOP/modules/B2.5/src/utility/b2mod_ipmain.F .
cp $SOLPSTOP/modules/B2.5/src/utility/xer* .
cp $SOLPSTOP/modules/B2.5/src/utility/b2mod_xerset.F .
cp $SOLPSTOP/modules/B2.5/src/utility/b2mod_subsys.F .
cp $SOLPSTOP/modules/B2.5/src/utility/b2mod_lw* .
cp $SOLPSTOP/modules/B2.5/src/utility/smin.F .
cp $SOLPSTOP/modules/B2.5/src/utility/smax.F .
cp $SOLPSTOP/modules/B2.5/src/utility/samax.F .
cp $SOLPSTOP/modules/B2.5/src/utility/open_file.F .
cp $SOLPSTOP/modules/B2.5/src/utility/lnblnk.F .
cp $SOLPSTOP/modules/B2.5/src/utility/ipget* .
cp $SOLPSTOP/modules/B2.5/src/utility/mstep.F .
cp $SOLPSTOP/modules/B2.5/src/utility/hybr.F .
cp $SOLPSTOP/modules/B2.5/src/utility/upwind.F .
cp $SOLPSTOP/modules/B2.5/src/utility/intface.F .
cp $SOLPSTOP/modules/B2.5/src/utility/ilutern_us_solps.F .
cp $SOLPSTOP/modules/B2.5/src/utility/trimg.F .
cp $SOLPSTOP/modules/B2.5/src/utility/cfru* .
cp $SOLPSTOP/modules/B2.5/src/utility/cfwuch.F .
cp $SOLPSTOP/modules/B2.5/src/utility/cfwuin.F .
cp $SOLPSTOP/modules/B2.5/src/utility/cfopen.F .
cp $SOLPSTOP/modules/B2.5/src/utility/get_jsep.F .
cp $SOLPSTOP/modules/B2.5/src/utility/prg* .
cp $SOLPSTOP/modules/B2.5/src/utility/streql.F .
cp $SOLPSTOP/modules/B2.5/src/utility/machsfr.F .
cp $SOLPSTOP/modules/B2.5/src/utility/ma28copy.F .
cp $SOLPSTOP/modules/B2.5/src/utility/cdf_routines.F .
cp $SOLPSTOP/modules/B2.5/src/utility/interp1d.F .
cp $SOLPSTOP/modules/B2.5/src/utility/intp_* .
cp $SOLPSTOP/modules/B2.5/src/utility/harm.F .
cp $SOLPSTOP/modules/B2.5/src/utility/nancheck.F .
cp $SOLPSTOP/modules/B2.5/src/utility/strip_spaces.F .
cp $SOLPSTOP/modules/B2.5/src/utility/is_comment.F .
cp $SOLPSTOP/modules/B2.5/src/utility/uxcm.F .
cp $SOLPSTOP/modules/B2.5/src/utility/ratio.F .
cp $SOLPSTOP/modules/B2.5/src/utility/cpeir_* .
cp $SOLPSTOP/modules/B2.5/src/utility/epoch_seconds.F .
cp $SOLPSTOP/modules/B2.5/src/utility/bfill.F .
cp $SOLPSTOP/modules/B2.5/src/utility/len_of_digits.F .
cp $SOLPSTOP/modules/B2.5/src/utility/prvrt* .
cp $SOLPSTOP/modules/B2.5/src/utility/chcase.F .
cp $SOLPSTOP/modules/B2.5/src/utility/trilinear_int.F .
cp $SOLPSTOP/modules/B2.5/src/utility/lefta.F .
cp $SOLPSTOP/modules/B2.5/src/utility/sys* .
cp $SOLPSTOP/modules/B2.5/src/utility/intersects.F .
cp $SOLPSTOP/modules/B2.5/src/utility/jobnam.F .
cp $SOLPSTOP/modules/B2.5/src/utility/nagsubst.F .
cp $SOLPSTOP/modules/B2.5/src/utility/cfvers.F .
cp $SOLPSTOP/modules/B2.5/src/utility/daytim.F .
cp $SOLPSTOP/modules/B2.5/src/utility/usrnam.F .
cp $SOLPSTOP/modules/B2.5/src/utility/strcopy.F .
cp $SOLPSTOP/modules/B2.5/src/utility/dfmin.F .
cp $SOLPSTOP/modules/B2.5/src/utility/dseval.F .
cp $SOLPSTOP/modules/B2.5/src/utility/dspline.F .
cp $SOLPSTOP/modules/B2.5/src/utility/cond_coef.F .
cp $SOLPSTOP/modules/B2.5/src/utility/my_outi_us.F .
cp $SOLPSTOP/modules/B2.5/src/utility/solve_covariance.F .
#cp $SOLPSTOP/modules/B2.5/src/utility/mass_density.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/erf_b.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/b2uxus_b.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/calc_res_fp_diff.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/b2optim_ipopt.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/b2optim_tao.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/set_parameters.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/set_adj_gradient.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/print_adj_parameters.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/solve_covariance_b.F .

# and now modify the 'use modules' which have been differentiated
files=`ls *.F*`
for d in $MODLIST; do
f=$d"_diff"
echo "Now modifying the use of "$d" into "$f
sed -i -e "s/\<use $d\>/use $f/g" $files
done;

echo "Files that have been excluded from differentiation have been copied to differentiation directory for compiling"

mv ./*.F ../
mv ./*.F90 ../
cd ../
rm -r temp


