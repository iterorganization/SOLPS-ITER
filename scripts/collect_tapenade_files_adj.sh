string=''

dir="$SOLPSTOP/modules/B2.5/builds/standalone.$HOST_NAME.$COMPILER.adj"

cat $SOLPSTOP/modules/B2.5/src/differentiation/files_to_exclude_adj.txt > excluded.txt

find $dir -name \*.f -exec basename \{} .f \;| ( while read filename 
do
if `echo "$filename" | grep -q -i -v "genmod"`
then
if grep -q -w "$filename" excluded.txt
then
string+=""
else
string+=" $dir/"$filename".f"
fi
fi
done

echo $string > testfile)


find $dir -name \*.f90 -exec basename \{} .f90 \;| ( while read filename 
do
if `echo "$filename" | grep -q -i -v "genmod"`
then
if grep -q -w "$filename" excluded.txt
then
string+=""
else
string+=" $dir/"$filename".f90"
fi
fi
done

echo $string >> testfile)

echo "$SOLPSTOP/modules/B2.5/src/differentiation/b2uxus_adj.f" >> testfile
echo "$SOLPSTOP/modules/B2.5/src/differentiation/dim.f" >> testfile
echo "$SOLPSTOP/modules/B2.5/src/differentiation/solve_covariance.f" >> testfile
echo "$SOLPSTOP/modules/B2.5/src/differentiation/b2uxus_b.f" >> testfile
echo "$SOLPSTOP/modules/B2.5/src/differentiation/invert_matrix.f" >> testfile

cat testfile

