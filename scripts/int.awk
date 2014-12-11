#! /bin/csh -f
awk '\
    /^[#]/{print $0}\
    /^[^#]/{printf "%s ",$1;for (j=2;j<=NF;j++) {VAL[j]=VAL[j]+$j*($1-o1);printf "%s ",VAL[j]};printf "\n";o1=$1}'
