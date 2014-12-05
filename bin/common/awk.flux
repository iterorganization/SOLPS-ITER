#! /bin/csh -f
if ($?LAST10) then
  set FILE=run.log.last10
else
  set FILE=run.log
endif
if (-x $SOLPSTOP/bin/$OBJECTCODE/zcat) then
    set ZCAT=$SOLPSTOP/bin/$OBJECTCODE/zcat
else if (-x $SOLPSMASTER/@sys/bin/zcat) then
    set ZCAT=$SOLPSMASTER/@sys/bin/zcat
else
    set ZCAT="gzip --decompress --force --stdout"
endif
$ZCAT -f $FILE | \
  grep -A95 "$1" | \
  awk '/SURFACE AREA/{dabs=0;c12abs=0;;c13abs=0;neabs=0;heabs=0;d=0;c12=0;c13=0;ne=0;he=0;area=$4/1e4}\
       /FLUX INCIDENT ON SURFACE:/{sign=+1}\
       /FLUX RE.*EMITTED FROM INCIDENT ATOMS:/{sign=-1}\
       /FLUX RE.*EMITTED FROM INCIDENT MOLECULES:/{sign=-1}\
       /INCIDENT: ATOMS/{NC=1}\
       /INCIDENT: MOLECULES/{NC=2}\
       /RE.*EMITTED: ATOMS/{NC=1}\
       /RE.*EMITTED: MOLECULES/{NC=2}\
       /P-FLUX:/{NRACTIVE=NR+1}\
       NR==NRACTIVE&&sign>0{dabs+=$2*NC;c12abs+=$4*NC;c13abs+=$6*NC;heabs+=$8*NC}\
       NR==NRACTIVE{d+=$2*sign*NC;c12+=$4*sign*NC;c13+=$6*sign*NC;he+=$8*sign*NC}\
       /NO ALGEBRAIC SURFACE TALLIES AT THIS SURFACE/{print dabs,c12abs,c13abs,heabs,d,c12,c13,he}'
