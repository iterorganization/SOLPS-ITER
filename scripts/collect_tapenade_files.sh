#!/usr/bin/env bash

dir="$SOLPSTOP/modules/B2.5/builds/standalone.$HOST_NAME.$COMPILER"
diff="$SOLPSTOP/modules/B2.5/src/differentiation"

bash exclude_tapenade_files.sh

> testfile

for ext in f f90; do
    while read -r filename; do
        if ! echo "$filename" | grep -qi "genmod"; then
            if ! grep -qw "$filename" excluded.txt; then
                printf '%s\n' "$dir/$filename.$ext" >> testfile
            fi
        fi
    done < <(find "$dir" -name "*.$ext" -exec basename {} .$ext \;)
done

for extra in b2uxus.f dim.f solve_covariance.f invert_matrix.f; do
    printf '%s\n' "$diff/$extra" >> testfile
done

printf '%s\n' "$dir/b2mwmv.f" >> testfile

cat testfile
