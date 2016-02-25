#! /bin/ksh

echo Welcome to SOLPS-ITER!
echo Documentation can be found at:
echo https://portal.iter.org/departments/POP/CM/IMAS/SOLPS-ITER
echo "(requires ITER IDM account)"
echo The full SOLPS-ITER manual can be found in \$SOLPSTOP/doc/solps/solps.pdf
echo The Eirene manual is located at http://www.eirene.de/

export SOLPSTOP=$PWD

[ -e whereami ] && {
  iamat=`./whereami|tail -1`
  echo Running at $iamat
} || {
  iamat="unknown"
}

[ -e SETUP/setup.csh.HOST_NAME.local ] && {
  echo Loading SETUP/setup.csh.HOST_NAME.local
} || {
  if [ $iamat ==  "*UNKNOWN" ]  then
    export HOST_NAME=default
  else
    export HOST_NAME=$iamat
  fi
}

[ -e setup.ksh.SOLPSMASTER ] && . setup.ksh.SOLPSMASTER
[ -e setup.ksh.SOLPSMASTER.local ] && . setup.ksh.SOLPSMASTER.local

[ -z "$SOLPSMASTER" ] && {
  case $iamat in
  "IPP" )
    export SOLPSMASTER=/afs/ipp-garching.mpg.de/u/dpc
    export DEVICE upgrade
    ;;
  "ITM" | "EU_UNKNOWN" )
    export SOLPSMASTER=/afs/ipp-garching.mpg.de/u/dpc
    ;;
  "PPPL" | "USA_UNKNOWN" )
    export SOLPSMASTER=/afs/pppl.gov/u/dcoster
    ;;
  * )
    export SOLPSMASTER=/afs/ipp-garching.mpg.de/u/dpc
    ;;
  esac
}

# COMPILER can also be the argument to setup.csh call
if [ "$1" = "" ] ; then
  [ -e default_compiler ] && {
    export COMPILER=`./default_compiler|tail -1`
    echo Using compiler $COMPILER.
  } || {
    export COMPILER=ifort64
    echo Assuming default compiler ifort64.
  }
else
  export COMPILER=$1
fi
[ -z "$COMPILER" ] && echo 'COMPILER not defined!'

# setup files for combination of HOST_NAME and COMPILER, + local modifications if present
[ -e SETUP/setup.ksh.${HOST_NAME}.${COMPILER} ] && {
  echo Loading SETUP/setup.ksh.${HOST_NAME}.${COMPILER}.
  . SETUP/setup.ksh.${HOST_NAME}.${COMPILER}
} || {
  echo File SETUP/setup.ksh.${HOST_NAME}.${COMPILER} not found!
}
[ -e SETUP/setup.ksh.${HOST_NAME}.${COMPILER}.local ] && {
  echo Loading SETUP/setup.ksh.${HOST_NAME}.${COMPILER}.local.
  . SETUP/setup.ksh.${HOST_NAME}.${COMPILER}.local
}

limit stacksize unlimited

[ -z "$GRAPHCAP" ] && export GRAPHCAP=X11

case $OBJECTCODE in
"IBMaix" )
  export nOBJECTCODE=Aix
  ;;
"DECalpha" )
  export nOBJECTCODE=Alpha
  ;;
"SGIirix" )
  export nOBJECTCODE=Iris
  ;;
"sun4c" )
  export nOBJECTCODE=SunOS
  ;;
"sun5" )
  export nOBJECTCODE=Solaris
  ;;
"unicos" )
  export nOBJECTCODE=Unicos
  ;;
"linux.ifort64" )
  export nOBJECTCODE= Intel
  ;;
* )
  export nOBJECTCODE=Unknown
  ;;
esac

[ -z "$DEVICE" ] && export DEVICE=iter

export B2PLOT_DEV="x11 ps"
export GLI_HOME=$SOLPSTOP/lib
export WSTYPE=$OBJECTCODE
# export GLI_WSTYPE=210
export GRSOFT_DEVICE="211 62"
export SonnetTopDirectory=${SOLPSTOP}/src/Sonnet
export EscapeSonnet=`echo ${SonnetTopDirectory} | sed 's:\/:\\\/:g'`

export DG=${SOLPSTOP}/modules/DivGeo
export SOLPSLIB=${SOLPSTOP}/lib/${HOST_NAME}.${COMPILER}
export CARRE_STOREDIR=${SOLPSTOP}/modules/Carre/meshes

alias sb2='cd ${SOLPSTOP}/src/b2'
alias sbb='cd ${SOLPSTOP}/src/b2'
alias sei='cd ${SOLPSTOP}/src/Eirene'
alias ssw='cd ${SOLPSTOP}/src/Sonnet'
alias ssd='cd ${SOLPSTOP}/src/DivGeo'
alias ssc='cd ${SOLPSTOP}/src/Carre'
alias sst='cd ${SOLPSTOP}/src/Triang'
alias ssu='cd ${SOLPSTOP}/src/uinp'
alias sbin='cd ${SOLPSTOP}/bin/${OBJECTCODE}'sbb
alias slib='cd ${SOLPSTOP}/lib/${OBJECTCODE}'
alias srun='cd ${SOLPSTOP}/runs'
alias sbr='cd ${SOLPSTOP}/runs'
alias scr='cd ${SOLPSTOP}/scripts'
alias stop='cd ${SOLPSTOP}'
alias sdg='cd ${SOLPSTOP}/modules/DivGeo/device/${DEVICE}'
alias ssf='cd ${SOLPSTOP}/modules/DivGeo/device/${DEVICE}'

alias xyplot='plot xyplot'
alias xyplot2='plot xyplot2'
alias xyplot3='plot xyplot3'
alias xyplot4='plot xyplot4'
alias xyplot5='plot xyplot5'
alias xyplot6='plot xyplot6'
alias xyplot7='plot xyplot7'
alias xyplot8='plot xyplot8'
alias xyplot8='plot xyplot8'
alias xyplot9='plot xyplot9'
alias xlyplot='plot xlyplot'
alias xlyplot2='plot xlyplot2'
alias xlyplot3='plot xlyplot3'
alias xlyplot4='plot xlyplot4'
alias xlyplot5='plot xlyplot5'
alias xlyplot6='plot xlyplot6'
alias xlyplot7='plot xlyplot7'
alias xlyplot8='plot xlyplot8'
alias xlyplot8='plot xlyplot8'
alias xlyplot9='plot xlyplot9'
alias xylplot='plot xylplot'
alias xylplot2='plot xylplot2'
alias xylplot3='plot xylplot3'
alias xylplot4='plot xylplot4'
alias xylplot5='plot xylplot5'
alias xylplot6='plot xylplot6'
alias xylplot7='plot xylplot7'
alias xylplot8='plot xylplot8'
alias xylplot8='plot xylplot8'
alias xylplot9='plot xylplot9'
alias xlylplot='plot xlylplot'
alias xlylplot2='plot xlylplot2'
alias xlylplot3='plot xlylplot3'
alias xlylplot4='plot xlylplot4'
alias xlylplot5='plot xlylplot5'
alias xlylplot6='plot xlylplot6'
alias xlylplot7='plot xlylplot7'
alias xlylplot8='plot xlylplot8'
alias xlylplot8='plot xlylplot8'
alias xlylplot9='plot xlylplot9'

alias set_debug='. $SOLPSTOP/debug.ksh'
alias unset_debug='. $SOLPSTOP/nodebug.ksh'

[ -e setup.ksh.$OBJECTCODE ] && . setup.ksh.$OBJECTCODE
[ -e setup.ksh.local ] && . setup.ksh.local
[ -e setup.ksh.local.$OBJECTCODE ] && . setup.ksh.local.$OBJECTCODE
[ -e setup.ksh.mdsplus ] && . setup.ksh.mdsplus
[ -e setup.ksh.mdsplus.$OBJECTCODE ] && . setup.ksh.mdsplus.$OBJECTCODE
[ -e setup.ksh.$USER ] && . setup.ksh.$USER
[ -e setup.ksh.$USER.$OBJECTCODE ] && . setup.ksh.$USER.$OBJECTCODE

export PATH=${SOLPSTOP}/bin/${OBJECTCODE}:${SOLPSTOP}/scripts.local:${SOLPSTOP}/scripts:${PATH}

export PATH=$NCARG_ROOT/bin:$PATH
export MANPATH=$NCARG_ROOT/man:${DG}/equtrn/doxygen/man:$MANPATH

[ -z "$IDL_PATH" ] && {
  export IDL_PATH="+$SOLPSTOP/data/IDL"
} || {
  export IDL_PATH="+$SOLPSTOP/data/IDL:${IDL_PATH}"
}

[ -e $SOLPSLIB/libnetcdf.a ] && export NETCDF=-lnetcdf

[ -z "$LD_LIBRARY_PATH" ] && {
    export LD_LIBRARY_PATH=${SOLPSLIB}
} || {
    export LD_LIBRARY_PATH=${SOLPSLIB}:${LD_LIBRARY_PATH}
}

[ -z "$error" ] && {
  [ -n "$dbg" ] && {
    . debug.ksh
  }
  export WSTYPE OBJECTCODE
  [ -n $XLFRTEOPTS ] && export XLFRTEOPTS
  echo "$OBJECTCODE"
}

[ -z "$PYTHONPATH" ] && {
  export PYTHONPATH="$SOLPSTOP/lib/python"
} || {
  export PYTHONPATH="${PYTHONPATH}:$SOLPSTOP/lib/python"
}

export PLOT_SET_PATH=":..:../..:$SOLPSTOP/data.local/plot_set:$SOLPSTOP/data/plot_set"

[ -x module ] && module list
