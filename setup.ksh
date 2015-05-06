#! /bin/ksh

echo "Welcome to SOLPS-ITER!"
echo "Documentation can be found at: "
echo "https://portal.iter.org/departments/POP/CM/IMAS/Forms/AllItems.aspx"
echo "(requires ITER IDM account)"
echo "The full SOLPS-ITER manual can be found in SOLPSTOP/doc/solps/solps.pdf"
echo "The Eirene manual is located at http://www.eirene.de/"

export SOLPSTOP=$PWD

[ -e whereami ] && {
  iamat=`./whereami|tail -1`
  echo Running at $iamat
} || {
  iamat="unknown"
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

if [ "$1" = "" ] || [ "$1" = "dbg" ] ; then
  [ -e setup.ksh.OBJECTCODE ] && . setup.ksh.OBJECTCODE
  [ -e setup.ksh.OBJECTCODE.local ] && . setup.ksh.OBJECTCODE.local
  [ -z "$OBJECTCODE" ] && export OBJECTCODE=`$SOLPSMASTER/@sys/machine`
else
  export OBJECTCODE=$1
fi
[ -z "$OBJECTCODE" ] && echo 'OBJECTCODE not defined!'

[ -e setup.ksh.NAG ] && . setup.ksh.NAG
[ -e setup.ksh.NAG.$OBJECTCODE ] && . setup.ksh.NAG.$OBJECTCODE
[ -e setup.ksh.NAG.local ] && . setup.ksh.NAG.local
[ -e setup.ksh.NAG.local.$OBJECTCODE ] && . setup.ksh.NAG.local.$OBJECTCODE

[ -z "$NAG" ] && . setup.ksh.NAG.guess

[ -e setup.ksh.NCARG ] && . setup.ksh.NCARG
[ -e setup.ksh.NCARG.$OBJECTCODE ] && . setup.ksh.NCARG.$OBJECTCODE
[ -e setup.ksh.NCARG.local ] && . setup.ksh.NCARG.local
[ -e setup.ksh.NCARG.local.$OBJECTCODE ] && . setup.ksh.NCARG.local.$OBJECTCODE

[ -z "$NCARG_ROOT" ] && {
  [ -e $SOLPSTOP/src/NCARG/$OBJECTCODE ] && export NCARG_ROOT=$SOLPSTOP/src/NCARG/$OBJECTCODE
}

[ -z "$NCARG_ROOT" ] && . setup.ksh.NCARG.guess
[ -z "$NCARG" ] && {
  [ -n "$NCARG_ROOT" ] && {
    export NCARG_PATH=`echo $NCARG_ROOT | sed -e "s:$SOLPSTOP/::"`
    case $NCARG_PATH in
    '*3.*' )
      echo 'Found NCAR Version 3.*'
      export NCARG='-L$(NCARG_ROOT)/lib -lncarg -lncarg_gks -lncarg_c -lncarg_loc -lX11 -lm'
      export NCAR_VERSION=3
      ;;
    '*4.*' )
      echo 'Found NCAR Version 4.*'
      export NCARG='-L$(NCARG_ROOT)/lib -lncarg -lncarg_gks -lncarg_c -lX11 -lm'
      export NCAR_VERSION=4
      [ -z "$SOLPS_CPP" ] && {
        export SOLPS_CPP="-DNCAR4"
      } || {
        export SOLPS_CPP="$SOLPS_CPP -DNCAR4"
      }
      ;;
    * )
      echo 'Found NCAR Version ?.?; assume 4'
      export NCARG='-L$(NCARG_ROOT)/lib -lncarg -lncarg_gks -lncarg_c -lX11 -lm'
      export NCAR_VERSION=4
      [ -z "$SOLPS_CPP" ] && {
        export SOLPS_CPP="-DNCAR4"
      } || {
        export SOLPS_CPP="$SOLPS_CPP -DNCAR4"
      }
      ;;
    esac
  }
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

export B2PLOT_DEV=ps
export GLI_HOME=$SOLPSTOP/lib
export WSTYPE=$OBJECTCODE
# export GLI_WSTYPE=210
export GRSOFT_DEVICE="211 62"
export SonnetTopDirectory=${SOLPSTOP}/src/Sonnet
export EscapeSonnet=`echo ${SonnetTopDirectory} | sed 's:\/:\\\/:g'`

export DG=${SOLPSTOP}/src/DivGeo
export CARRE_STOREDIR=${SOLPSTOP}/src/Carre/SAVE 

alias sb2='cd ${SOLPSTOP}/src/b2'
alias sbb='cd ${SOLPSTOP}/src/b2'
alias sei='cd ${SOLPSTOP}/src/Eirene'
alias ssw='cd ${SOLPSTOP}/src/Sonnet'
alias ssd='cd ${SOLPSTOP}/src/DivGeo'
alias ssc='cd ${SOLPSTOP}/src/Carre'
alias sst='cd ${SOLPSTOP}/src/Triang'
alias ssu='cd ${SOLPSTOP}/src/uinp'
alias sbin='cd ${SOLPSTOP}/bin/${OBJECTCODE}'
alias slib='cd ${SOLPSTOP}/lib/${OBJECTCODE}'
alias srun='cd ${SOLPSTOP}/runs'
alias sbr='cd ${SOLPSTOP}/runs'
alias scr='cd ${SOLPSTOP}/scripts'
alias stop='cd ${SOLPSTOP}'
alias sdg='cd ${SOLPSTOP}/data/DivGeo/class/${DEVICE}'
alias ssf='cd ${SOLPSTOP}/src/Sonnet/device/${DEVICE}'

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

export PATH=${SOLPSTOP}/bin/${OBJECTCODE}:${SOLPSTOP}/scripts:${PATH}

export PATH=$NCARG_ROOT/bin:$PATH
export MANPATH=$NCARG_ROOT/man:${DG}/equtrn/doxygen/man:$MANPATH

[ -z "$IDL_PATH" ] && {
  export IDL_PATH="+$SOLPSTOP/data/IDL"
} || {
  export IDL_PATH="+$SOLPSTOP/data/IDL:${IDL_PATH}"
}

export SOLPS_LIB=${SOLPSTOP}/lib/${OBJECTCODE}
[ -e $SOLPS_LIB/libnetcdf.a ] && export NETCDF=-lnetcdf

[ -z "$LD_LIBRARY_PATH" ] && {
    export LD_LIBRARY_PATH=${SOLPS_LIB}
} || {
    export LD_LIBRARY_PATH=${SOLPS_LIB}:${LD_LIBRARY_PATH}
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

