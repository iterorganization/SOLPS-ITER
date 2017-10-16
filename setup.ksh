#! /bin/ksh

echo Welcome to SOLPS-ITER!
echo Documentation can be found at:
echo https://portal.iter.org/departments/POP/CM/IMAS/SOLPS-ITER
echo and
echo https://user.iter.org/\?uid=Q92BAQ
echo "(both require a valid ITER IDM account)"
echo The full SOLPS-ITER manual can be found in \$SOLPSTOP/doc/solps/solps.pdf
echo The Eirene manual is located at http://www.eirene.de/

export SOLPSTOP=$PWD
export SOLPSWORK=$SOLPSTOP/runs

[ -e whereami ] && {
  iamat=`./whereami|tail -1`
  echo Running at $iamat
} || {
  iamat="unknown"
}

[ -e SETUP/setup.csh.HOST_NAME.local ] && {
  echo Loading SETUP/setup.csh.HOST_NAME.local
} || {
  [ $iamat ==  "*UNKNOWN" ] && {
    export HOST_NAME=default
  } || {
    export HOST_NAME=$iamat
  }
}

[ -e setup.ksh.SOLPSMASTER ] && . setup.ksh.SOLPSMASTER
[ -e setup.ksh.SOLPSMASTER.local ] && . setup.ksh.SOLPSMASTER.local

[ -z "$SOLPSMASTER" ] && {
  case $iamat in
  "IPP" )
    export SOLPSMASTER=/afs/ipp-garching.mpg.de/u/dpc
    [ -z "$DEVICE" ] && export DEVICE upgrade
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
[ "$1" = "" ] && {
  [ -e default_compiler ] && {
    export COMPILER=`./default_compiler|tail -1`
    echo Using compiler $COMPILER.
  } || {
    export COMPILER=ifort64
    echo Assuming default compiler ifort64.
  }
} || {
  export COMPILER=$1
}
[ -z "$COMPILER" ] && echo 'COMPILER not defined!'
[ -x `which gmake` ] && {
  export MAKE=`which gmake`
} || {
  export MAKE=`which make`
}

[ -z "$PYTHONPATH" ] && {
  export PYTHONPATH="$SOLPSTOP/lib/python"
} || {
  export PYTHONPATH="${PYTHONPATH}:$SOLPSTOP/lib/python"
}

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

[ -z "$B2PLOT_DEV" ] && export B2PLOT_DEV="x11 ps"
[ -z "$GLI_HOME"] && export GLI_HOME=$SOLPSTOP/lib
export WSTYPE=$OBJECTCODE
# export GLI_WSTYPE=210
[ -z "$GRSOFT_DEVICE"] && export GRSOFT_DEVICE="211 62"
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
alias set_mpi='. $SOLPSTOP/SETUP/mpi'
alias unset_mpi='. $SOLPSTOP/SETUP/nompi'
alias set_ig='. $SOLPSTOP/SETUP/ig'
alias unset_ig='. $SOLPSTOP/SETUP/noig'


[ -e setup.ksh.$OBJECTCODE ] && . setup.ksh.$OBJECTCODE
[ -e setup.ksh.local ] && . setup.ksh.local
[ -e setup.ksh.local.$OBJECTCODE ] && . setup.ksh.local.$OBJECTCODE
[ -e setup.ksh.mdsplus ] && . setup.ksh.mdsplus
[ -e setup.ksh.mdsplus.$OBJECTCODE ] && . setup.ksh.mdsplus.$OBJECTCODE
[ -e setup.ksh.$USER ] && . setup.ksh.$USER
[ -e setup.ksh.$USER.$OBJECTCODE ] && . setup.ksh.$USER.$OBJECTCODE

export      TOOLCHAIN=${HOST_NAME}.${COMPILER}
export     CARRE_PATH=${SOLPSTOP}/modules/Carre/builds/${TOOLCHAIN}
export    DIVGEO_PATH=${SOLPSTOP}/modules/DivGeo/builds/${TOOLCHAIN}:${SOLPSTOP}/modules/DivGeo/equtrn/builds/${TOOLCHAIN}:${SOLPSTOP}/modules/DivGeo/convert/builds/${TOOLCHAIN}
export    EIRENE_PATH=${SOLPSTOP}/modules/Eirene/builds/standalone.${TOOLCHAIN}
export       B25_PATH=${SOLPSTOP}/modules/B2.5/builds/standalone.${TOOLCHAIN}
export B25EIRENE_PATH=${SOLPSTOP}/modules/B2.5/builds/couple_SOLPS-ITER.${TOOLCHAIN}
export      UINP_PATH=${SOLPSTOP}/modules/Uinp/builds/${TOOLCHAIN}
export    TRIANG_PATH=${SOLPSTOP}/modules/Triang/builds/${TOOLCHAIN}
export   SCRIPTS_PATH=${SOLPSTOP}/scripts.local:${SOLPSTOP}/scripts:${SOLPSTOP}/modules/Eirene/scripts
export      AMDS_PATH=${SOLPSTOP}/modules/amds/builds/${TOOLCHAIN}
export       S45_PATH=${SOLPSTOP}/modules/solps4-5/builds/${TOOLCHAIN}

export SOLPS_PATH=${SCRIPTS_PATH}:${CARRE_PATH}:${DIVGEO_PATH}:${B25EIRENE_PATH}:${EIRENE_PATH}:${B25_PATH}:${UINP_PATH}:${TRIANG_PATH}:${AMDS_PATH}:${S45_PATH}
export OLD_PATH=${PATH}
export PATH=${SOLPS_PATH}:${PATH}

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

export PLOT_SET_PATH=":..:../..:$SOLPSTOP/data.local/plot_set:$SOLPSTOP/data/plot_set"

[ -x module ] && module list
