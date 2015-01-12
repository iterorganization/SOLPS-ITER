export OLDOBJECTCODE=$OBJECTCODE
export OBJECTCODE=`echo $OBJECTCODE | sed 's:.debug::'`
unset SOLPS_DEBUG
export PATH=`echo $PATH | sed "s|base/b2/$OLDOBJECTCODE|base/b2/$OBJECTCODE|"`
