find . -name \*.f90 -exec basename \{} .f90 \;| ( while read filename 
do
mv "$filename".f90 "$filename".F90
done)

