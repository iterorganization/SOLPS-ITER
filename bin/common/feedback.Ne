#! /bin/csh -f
if ($?LAST10) then
  set FILE=b2.log.last10
else
  set FILE=b2.log
endif
if (-x $SOLPSTOP/bin/$OBJECTCODE/zcat) then
    set ZCAT=$SOLPSTOP/bin/$OBJECTCODE/zcat
else if (-x $SOLPSMASTER/@sys/bin/zcat) then
    set ZCAT=$SOLPSMASTER/@sys/bin/zcat
else
    set ZCAT="gzip --decompress --force --stdout"
endif
$ZCAT -f $FILE |\
  grep Neon |\
  cut -d' ' -f 8- |\
  nl |\
  plot xyplot10 1 2 3 4 5 6 7 8 9 10
