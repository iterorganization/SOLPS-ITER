#! /bin/csh -f
if($1 == "") then
  awk '\
      BEGIN{COUNT=0}\
      /^[#]/{print $0}\
      /^[^#]/&&COUNT==0{print $0}\
      /^[^#]/{for (j=1;j<=NF;j++) {VAL[j]=$j};COUNT=COUNT+1;OLDNF=NF}\
      END{for (j=1;j<=OLDNF;j++) {printf "%s ",VAL[j]};printf "\n"}'
else
  awk '\
      BEGIN{COUNT=0}\
      /^[#]/{print $0}\
      /^[^#]/&&COUNT%'$1==0'{print $0}\
      /^[^#]/{COUNT=COUNT+1}'
endif
