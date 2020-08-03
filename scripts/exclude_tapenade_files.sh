string=''

cat $SOLPSTOP/modules/B2.5/src/differentiation/files_to_exclude.txt > excluded.txt
cat $SOLPSTOP/modules/B2.5/src/differentiation/files_to_ignore.txt >> excluded.txt

to_keep=$SOLPSTOP/modules/B2.5/src/differentiation/files_to_keep.txt

find $SOLPSTOP/modules/B2.5/src/b2plot -name \*.F* -exec basename \{} .F \; | ( while read filename 
do
if grep -q -w "$filename" "$to_keep"
then
string+=""
else
string+=" "$filename
fi
done

echo $string >> excluded.txt)


find $SOLPSTOP/modules/B2.5/src/convert -name \*.F* -exec basename \{} .F \; | ( while read filename 
do 
if grep -q -w "$filename" "$to_keep"
then
string+=""
else
string+=" "$filename
fi
done

echo $string >> excluded.txt)


find $SOLPSTOP/modules/B2.5/src/documentation -name \*.F* -exec basename \{} .F \; | ( while read filename 
do 
if grep -q -w "$filename" "$to_keep"
then
string+=""
else
string+=" "$filename
fi
done

echo $string >> excluded.txt)


find $SOLPSTOP/modules/B2.5/src/postprocessing -name \*.F* -exec basename \{} .F \; | ( while read filename 
do 
if grep -q -w "$filename" "$to_keep"
then
string+=""
else
string+=" "$filename
fi
done

echo $string >> excluded.txt)


find $SOLPSTOP/modules/B2.5/src/preprocessing -name \*.F* -exec basename \{} .F \; | ( while read filename 
do 
if grep -q -w "$filename" "$to_keep"
then
string+=""
else
string+=" "$filename
fi
done

echo $string >> excluded.txt)


find $SOLPSTOP/modules/B2.5/src/output -name \*.F* -exec basename \{} .F \; | ( while read filename 
do 
if grep -q -w "$filename" "$to_keep"
then
string+=""
else
string+=" "$filename
fi
done

echo $string >> excluded.txt)


