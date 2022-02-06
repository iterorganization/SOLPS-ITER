MODLIST=`ls b2mod*_dv.F90 b2us_*_dv.F90 | sed -e 's/_dv.F90//g'`
cat $SOLPSTOP/modules/B2.5/src/differentiation/files_to_exclude.txt > tmp
ls b2mod*_dv.F90 b2us_*_dv.F90 | sed -e 's/_dv.F90//g' >> tmp
for d in $MODLIST; do
mv $d"_dv.F90" $d"_diffv.F90"
done;
ls *_dv.F90 | sed -e 's/_dv.F90//g' >> tmp

SRCPATH="modules b2aux convert documentation driver equations input output postprocessing preprocessing solvers sources transport utility b2plot user ids"
# grab the files that have been excluded from differentiation but not the MAIN programs
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

cp $SOLPSTOP/modules/B2.5/src/utility/sfill.F .
cp $SOLPSTOP/modules/B2.5/src/utility/intface.F .
cp $SOLPSTOP/modules/B2.5/src/utility/myblas.F .
cp $SOLPSTOP/modules/B2.5/src/utility/trimg.F .
cp $SOLPSTOP/modules/B2.5/src/utility/calc_err.F .
cp $SOLPSTOP/modules/B2.5/src/utility/intp_2dtable.F .
cp $SOLPSTOP/modules/B2.5/src/utility/intp_3dtable.F .
cp $SOLPSTOP/modules/B2.5/src/utility/cpeir_bilinear_int.F .
cp $SOLPSTOP/modules/B2.5/src/utility/trilinear_int.F .
cp $SOLPSTOP/modules/B2.5/src/utility/mstep.F .
cp $SOLPSTOP/modules/B2.5/src/utility/expu.F .
cp $SOLPSTOP/modules/B2.5/src/utility/expu2.F .
cp $SOLPSTOP/modules/B2.5/src/utility/med.F .
cp $SOLPSTOP/modules/B2.5/src/utility/uxcm.F .
cp $SOLPSTOP/modules/B2.5/src/utility/ma28copy.F .
cp $SOLPSTOP/modules/B2.5/src/utility/nagsubst.F .
cp $SOLPSTOP/modules/B2.5/src/utility/interp1d.F .
cp $SOLPSTOP/modules/B2.5/src/utility/hybr.F .
cp $SOLPSTOP/modules/B2.5/src/utility/upwind.F .
cp $SOLPSTOP/modules/B2.5/src/transport/b2tlnl.F .
cp $SOLPSTOP/modules/B2.5/src/b2aux/b2xpne.F .
cp $SOLPSTOP/modules/B2.5/src/b2aux/b2xpnm.F .
cp $SOLPSTOP/modules/B2.5/src/b2aux/b2xpnr.F .
cp $SOLPSTOP/modules/B2.5/src/equations/b2nxst.F .
cp $SOLPSTOP/modules/B2.5/src/equations/b2nxcm.F .
cp $SOLPSTOP/modules/B2.5/src/solvers/b2uppo.F .
cp $SOLPSTOP/modules/B2.5/src/sources/b2sqcx.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/cond_coef.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/erf_dv.F .
#cp $SOLPSTOP/modules/B2.5/src/differentiation/dim_dv.F90 .
cp $SOLPSTOP/modules/B2.5/src/differentiation/b2uxus_dv.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/b2mwqt_diffv.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/b2mxar_diffv.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/b2mxac_diffv.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/b2optim* .
#cp $SOLPSTOP/modules/B2.5/src/differentiation/read_plasma_state_diff.F .
#cp $SOLPSTOP/modules/B2.5/src/differentiation/write_plasma_state_diff.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/set_parameters.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/set_tgt_perturbation.F .
cp $SOLPSTOP/modules/B2.5/src/b2aux/b2xzmf.F .

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


