export OLDOBJECTCODE=$OBJECTCODE
export OBJECTCODE=`echo $OBJECTCODE | sed 's:.debug::'`.debug
export SOLPS_DEBUG="yes"
export PATH=`echo $PATH | sed "s|base/b2/$OLDOBJECTCODE|base/b2/$OBJECTCODE|"`
