#!/usr/bin/env bash

base="$SOLPSTOP/modules/B2.5/src"
excluded_file="./excluded.txt"
to_keep="$base/differentiation/files_to_keep.txt"

cat "$base/differentiation/files_to_exclude.txt" > "$excluded_file"

for dir in b2plot convert documentation postprocessing preprocessing output; do
    while read -r filename; do
        if ! grep -qw "$filename" "$to_keep"; then
            printf '%s\n' "$filename" >> "$excluded_file"
        fi
    done < <(find "$base/$dir" -name '*.F*' -exec basename {} .F \;)
done
