string=''

dir="$SOLPSTOP/modules/B2.5/builds/standalone.$HOST_NAME.$COMPILER"

exclude_tapenade_files.sh

find $dir -name \*.f -exec basename \{} .f \;| ( while read filename 
do
if grep -q -w "$filename" excluded.txt
then
string+=""
else
string+=" $dir/"$filename".f"
fi
done

echo $string > testfile)


find $dir -name \*.f90 -exec basename \{} .f90 \;| ( while read filename 
do
if grep -q -w "$filename" excluded.txt
then
string+=""
else
string+="  $dir/"$filename".f90"
fi
done

echo $string >> testfile)

cat testfile

