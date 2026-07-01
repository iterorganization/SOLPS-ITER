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
copy_nodiff_files.sh
cp $SOLPSTOP/modules/B2.5/src/differentiation/erf_b.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/b2uxus_b.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/solve_covariance_b.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/calc_res_fp_diff.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/b2optim* .
cp $SOLPSTOP/modules/B2.5/src/differentiation/set_parameters.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/set_adj_gradient.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/print_adj_parameters.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/write_b2fstate_diff.F .
cp $SOLPSTOP/modules/B2.5/src/differentiation/invert_matrix_b.F .
cp $SOLPSTOP/modules/B2.5/src/catalyst/cxxAdaptor.cxx ../

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


