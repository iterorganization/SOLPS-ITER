#! /bin/csh -f
if($1 == "") then
  awk '\
      /^[#]/{print $0}\
      /^[^#]/{for (j=1;j<=NF;j++) {VAL[j]=VAL[j]+$j};COUNT=COUNT+1;OLDNF=NF}\
      END{for (j=1;j<=OLDNF;j++) {printf "%s ",VAL[j];VAL[j]=0};printf "\n"}'
else
  awk '\
      /^[#]/{print $0}\
      /^[^#]/{for (j=1;j<=NF;j++) {VAL[j]=VAL[j]+$j};COUNT=COUNT+1}\
      COUNT=='$1'{for (j=1;j<=NF;j++) {printf "%s ",VAL[j];VAL[j]=0};printf "\n";COUNT=0}'
endif
