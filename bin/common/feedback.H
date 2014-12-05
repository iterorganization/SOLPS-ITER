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
  egrep ITER\|Separatrix |\
  awk '/density/{sep=$4;core=$8}/TIME/{print $4,sep,core}' |\
  xyplot2 separatrix core time "" $PWD
