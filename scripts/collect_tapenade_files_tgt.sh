#!/usr/bin/env bash

dir="$SOLPSTOP/modules/B2.5/builds/standalone.$HOST_NAME.$COMPILER.tgt"
diff="$SOLPSTOP/modules/B2.5/src/differentiation"

cat $SOLPSTOP/modules/B2.5/src/differentiation/files_to_exclude_tgt.txt > excluded.txt

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

for extra in b2uxus_tgt.f dim.f solve_covariance.f invert_matrix.f; do
    printf '%s\n' "$diff/$extra" >> testfile
done

cat testfile

