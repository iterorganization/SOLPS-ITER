#! /bin/csh -f
if($1 == "") then
  awk '\
      {for (j=1;j<=NF;j++) {VAL[j]=VAL[j]+$j;if ($j < MIN[j] || COUNT==0) MIN[j]=$j; if ($j > MAX[j] || COUNT==0) MAX[j]=$j};COUNT=COUNT+1;OLDNF=NF}\
      END{for (j=1;j<=OLDNF;j++) {printf "%s %s %s ",MIN[j],VAL[j]/COUNT,MAX[j]};printf "\n"}'
else
  awk '\
      {for (j=1;j<=NF;j++) {VAL[j]=VAL[j]+$j;if ($j < MIN[j] || COUNT==0) MIN[j]=$j; if ($j > MAX[j] || COUNT==0) MAX[j]=$j};COUNT=COUNT+1}\
      COUNT=='$1'{for (j=1;j<=NF;j++) {printf "%s %s %s ",MIN[j],VAL[j]/COUNT,MAX[j];VAL[j]=0};printf "\n";COUNT=0}'
endif
