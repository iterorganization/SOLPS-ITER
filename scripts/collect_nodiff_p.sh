MODLIST=`ls b2mod*_p.F90 b2us_*_p.F90 | sed -e 's/_p.F90//g'`
cat $SOLPSTOP/modules/B2.5/src/differentiation/files_to_exclude.txt > tmp
ls b2mod*_p.F90 b2us_*_p.F90 | sed -e 's/_p.F90//g' >> tmp
for d in $MODLIST; do
mv $d"_p.F90" $d".F90"
done;
#check that _d routines have their counterpart _nodiff, otherwise they need to be recovered (only for TAPENADE 3.14)
ls *_p.F90 | sed -e 's/_p.F90//g' >> tmp
#for d in $DLIST; do
#f=$d"_nodiff"
#if (grep -q -w -i $f $d"_d.F90") then
#echo $d >> tmp
#fi
#done;
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

echo "Files that have been excluded from differentiation have been copied to differentiation directory for compiling"

mv ./*.F ../
mv ./*.F90 ../
cd ../
rm -r temp


