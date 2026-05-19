#! /bin/ksh

# This script sets up the environment for SOLPS-ITER (paths, env, aliases, etc.)
# including the site identification via HOST_NAME and COMPILER variables.
# It is intended to be sourced from the command line, not executed.
#
# The main variables SOLPSTOP, HOST_NAME, COMPILER are determined according
# to a precedence logic described below.
#
# Variable SOLPSTOP is determined with decreasing priority from:
#   1. $SOLPSTOP_FORCE
#   2. Automatic detection, fallback to $PWD
#
# Variable HOST_NAME is determined with decreasing priority from:
#   1. $SOLPS_HOST_NAME_FORCE
#   2. SETUP/setup.ksh.HOST_NAME.local file (sourced if present)
#   3. output of `whereami` script
#   4. fallback to UNKNOWN
#
# Variable COMPILER is determined with decreasing priority from:
#   1. First argument to `source setup.ksh` command
#   2. $SOLPS_COMPILER_FORCE
#   3. output of `default_compiler` script
#   4. fallback to ifort64
#

echo Welcome to SOLPS-ITER!
echo Documentation can be found at:
echo https://iterorganization.sharepoint.com/sites/SOLPS-ITER/Shared%20Documents/General
echo and
echo https://user.iter.org/\?uid=Q92BAQ
echo "(requires a valid ITER IDM account)"
echo The full SOLPS-ITER manual can be found in \$SOLPSTOP/doc/solps/solps.pdf
echo The Eirene manual can be found in \$SOLPSTOP/modules/Eirene/Manual/eirene.pdf
echo or online at http://www.eirene.de/

export LAST_COMMAND=`echo $_`
if [ "$SOLPSTOP_FORCE" != "" ]; then
  setenv SOLPSTOP $SOLPSTOP_FORCE
elif [ "$LAST_COMMAND" = "" ]; then
  export SETUP_FILE=`echo ${LAST_COMMAND} | cut -d " " -f 2`
  export REAL_FILE=`eval echo ${SETUP_FILE}`
  export REAL_PATH=`dirname ${REAL_FILE}`
  export SOLPSTOP=`cd ${REAL_PATH}; pwd -L`
else
  export SOLPSTOP=$PWD
fi
export SOLPSWORK=$SOLPSTOP/runs

# Set HOST_NAME and COMPILER, which will determine setup files to be used
#------------------------------------------------------------------------

if [ "$SOLPS_HOST_NAME_FORCE" != "" ]; then
  export HOST_NAME=$SOLPS_HOST_NAME_FORCE
  echo "Running at $HOST_NAME (set by SOLPS_HOST_NAME_FORCE)"
elif [ -s "${SOLPSTOP}/SETUP/setup.ksh.HOST_NAME.local" ]; then
  echo Loading SETUP/setup.ksh.HOST_NAME.local.
  . ${SOLPSTOP}/SETUP/setup.ksh.HOST_NAME.local
else
  [ -s ${SOLPSTOP}/whereami ] && {
    iamat=`${SOLPSTOP}/whereami|tail -1`
    echo Running at $iamat
  } || {
    iamat="UNKNOWN"
  }
  case $iamat in
  *UNKNOWN )
    export HOST_NAME=UNKNOWN
    ;;
  * )
    export HOST_NAME=$iamat
    ;;
  esac
fi

# COMPILER can also be the argument to setup.csh call
if [ "$1" != "" ]; then
  export COMPILER=$1
  echo "Using compiler $1 (set by command argument)."
elif [ "$SOLPS_COMPILER_FORCE" != "" ]; then
  export COMPILER=$SOLPS_COMPILER_FORCE
  echo "Using compiler $COMPILER (set by SOLPS_COMPILER_FORCE)."
elif [ -s ${SOLPSTOP}/default_compiler ]; then
  export COMPILER=`${SOLPSTOP}/default_compiler|tail -1`
  echo Using compiler $COMPILER.
else
  export COMPILER=ifort64
  echo Assuming default compiler ifort64.
fi

[ -z "$COMPILER" ] && echo 'COMPILER not defined!'
[ -x "`which gmake`" ] && {
  export MAKE=`which gmake`
} || {
  export MAKE=`which make`
}

# setup files for combination of HOST_NAME and COMPILER, + local modifications if present
[ -s ${SOLPSTOP}/SETUP/setup.ksh.${HOST_NAME}.${COMPILER} ] && {
  echo Loading SETUP/setup.ksh.${HOST_NAME}.${COMPILER}.
  . ${SOLPSTOP}/SETUP/setup.ksh.${HOST_NAME}.${COMPILER}
} || {
  echo File SETUP/setup.ksh.${HOST_NAME}.${COMPILER} not found!
}
[ -s ${SOLPSTOP}/SETUP/setup.ksh.${HOST_NAME}.${COMPILER}.local ] && {
  echo Loading SETUP/setup.ksh.${HOST_NAME}.${COMPILER}.local.
  . ${SOLPSTOP}/SETUP/setup.ksh.${HOST_NAME}.${COMPILER}.local
}

ulimit -s unlimited

[ -z "$GRAPHCAP" ] && export GRAPHCAP=X11

[ -z "$B2PLOT_DEV" ] && export B2PLOT_DEV="x11 ps"
[ -z "$GRSOFT_DEVICE" ] && export GRSOFT_DEVICE="211 62"
export SonnetTopDirectory=${SOLPSTOP}/modules/Sonnet-light
export EscapeSonnet=`echo ${SonnetTopDirectory} | sed 's:\/:\\\/:g'`

export DG=${SOLPSTOP}/modules/DivGeo
export CARRE_STOREDIR=${SOLPSTOP}/modules/Carre/meshes
export INTDIR=${SOLPSTOP}/modules/Eirene/src/interfaces/couple_SOLPS_WG

# Set path to scripts and executables
#------------------------------------

# First, remove the old path to SOLPS if already set
# (avoid too long paths)

[ -n "$SOLPS_PATH" ] && export PATH=`echo $PATH | sed "s|${SOLPS_PATH}:||"`

# Default PATH: no mpi, no openmp, no debug
TOOLCHAIN=${HOST_NAME}.${COMPILER}
CARRE_PATH=${SOLPSTOP}/modules/Carre/builds/${TOOLCHAIN}
DIVGEO_PATH=${SOLPSTOP}/modules/DivGeo/builds/${TOOLCHAIN}:${SOLPSTOP}/modules/DivGeo/equtrn/builds/${TOOLCHAIN}:${SOLPSTOP}/modules/DivGeo/convert/builds/${TOOLCHAIN}
EIRENE_PATH=${SOLPSTOP}/modules/Eirene/builds/standalone.${TOOLCHAIN}
B25_PATH=${SOLPSTOP}/modules/B2.5/builds/standalone.${TOOLCHAIN}
B25EIRENE_PATH=${SOLPSTOP}/modules/B2.5/builds/couple_SOLPS-ITER.${TOOLCHAIN}
UINP_PATH=${SOLPSTOP}/modules/Uinp/builds/${TOOLCHAIN}
TRIANG_PATH=${SOLPSTOP}/modules/Triang/builds/${TOOLCHAIN}
SCRIPTS_PATH=${SOLPSTOP}/scripts.local:${SOLPSTOP}/scripts:${SOLPSTOP}/scripts/${TOOLCHAIN}:${SOLPSTOP}/modules/Eirene/scripts:${SOLPSTOP}/modules/Eirene/scripts/eirenex_v1.0.4:${SOLPSTOP}/modules/B2.5/src/test
AMDS_PATH=${SOLPSTOP}/modules/amds/builds/${TOOLCHAIN}
S45_PATH=${SOLPSTOP}/modules/solps4-5/builds/${TOOLCHAIN}

# Create mirror scripts directory links
#   - only re-creating links if they are not correct, so that we are compatible with read-only file systems (container)
link_scripts="${SOLPSTOP}/scripts/${TOOLCHAIN}"
if [ -z "$NO_MPI" ]; then
  for suffix in ".mpi" ".openmp.mpi"; do
    [ -d ${link_scripts}${suffix} ] && rm -Rf ${link_scripts}${suffix}
    [ "`readlink ${link_scripts}${suffix}`" != "${link_scripts}" ] && ln -sf ${link_scripts} ${link_scripts}${suffix}
    [ -d ${link_scripts}${suffix}.debug ] && rm -Rf ${link_scripts}${suffix}.debug
    [ "`readlink ${link_scripts}${suffix}.debug`" != "${link_scripts}.debug" ] && ln -sf ${link_scripts}.debug ${link_scripts}${suffix}.debug
  done
fi
suffix=".openmp"
[ -d ${link_scripts}${suffix} ] && rm -Rf ${link_scripts}${suffix}
[ "`readlink ${link_scripts}${suffix}`" != "${link_scripts}" ] && ln -sf ${link_scripts} ${link_scripts}${suffix}
[ -d ${link_scripts}${suffix}.debug ] && rm -Rf ${link_scripts}${suffix}.debug
[ "`readlink ${link_scripts}${suffix}.debug`" != "${link_scripts}.debug" ] && ln -sf ${link_scripts}.debug ${link_scripts}${suffix}.debug
if [ "`readlink ${link_scripts}.debug`" == "${link_scripts}" ]; then
  rm -Rf ${link_scripts}.debug
  mkdir -p ${link_scripts}.debug
fi

# Note: in case of name clash between script and executable, script will be found first
export SOLPS_PATH=${SCRIPTS_PATH}:${CARRE_PATH}:${DIVGEO_PATH}:${B25EIRENE_PATH}:${EIRENE_PATH}:${B25_PATH}:${UINP_PATH}:${TRIANG_PATH}:${AMDS_PATH}:${S45_PATH}
export SOLPSLIB=${SOLPSTOP}/lib/${HOST_NAME}.${COMPILER}
export OLD_PATH=${PATH}
export PATH=${SOLPS_PATH}:${PATH}
[ -n "$LD_LIBRARY_PATH" ] && {
  export LD_LIBRARY_PATH=${SOLPSLIB}:${SOLPSTOP}/lib/python:${LD_LIBRARY_PATH}
} || {
  export LD_LIBRARY_PATH=${SOLPSLIB}:${SOLPSTOP}/lib/python
}

[ -z "$PYTHONPATH" ] && {
  export PYTHONPATH="$SOLPSTOP/lib/python:${SCRIPTS_PATH}"
} || {
  export PYTHONPATH="${PYTHONPATH}:$SOLPSTOP/lib/python:${SCRIPTS_PATH}"
}
[ -z "$PYTHON_PATH" ] || {
  export PYTHONPATH="${PYTHONPATH}:${PYTHON_PATH}"
}

unset TOOLCHAIN SCRIPTS_PATH CARRE_PATH DIVGEO_PATH EIRENE_PATH B25_PATH B25EIRENE_PATH UINP_PATH TRIANG_PATH AMDS_PATH S45_PATH

# Check whether SOLPS_DEBUG, SOLPS_OPENMP and SOLPS_MPI have been set already by the user

[ -n "$SOLPS_OPENMP" ] && . $SOLPSTOP/SETUP/openmp.ksh
[ -n "$SOLPS_DEBUG" ] && . $SOLPSTOP/SETUP/debug.ksh
[ -n "$SOLPS_MPI" ] && . $SOLPSTOP/SETUP/mpi.ksh

# Set path to manuals
#--------------------

[ -n "$MANPATH" ] && {
  export MANPATH=${MANPATH}:${SonnetTopDirectory}/man:${DG}/equtrn/doxygen/man
} || {
  export MANPATH=${SonnetTopDirectory}/man:${DG}/equtrn/doxygen/man
}

# Remove double entries from some environment variables, if there are any

# export PATH=`echo $PATH | awk -v RS=: -v ORS= '\\!a[$0]++ {if (NR>1) printf(":"); printf("%s",$0) }'`
# export LD_LIBRARY_PATH=`echo $LD_LIBRARY_PATH | awk -v RS=: -v ORS= '\\!a[$0]++ {if (NR>1) printf(":"); printf("%s",$0) }'`
# export MANPATH=`echo $MANPATH | awk -v RS=: -v ORS= '\\!a[$0]++ {if (NR>1) printf(":"); printf("%s",$0) }'`
# export PYTHONPATH=`echo $PYTHONPATH | awk -v RS=: -v ORS= '\\!a[$0]++ {if (NR>1) printf(":"); printf("%s",$0) }'`
# export OLD_PATH=`echo $OLD_PATH | awk -v RS=: -v ORS= '\\!a[$0]++ {if (NR>1) printf(":"); printf("%s",$0) }'`

alias sb2='cd ${SOLPSTOP}/modules/B2.5'
alias sbb='cd ${SOLPSTOP}/modules/B2.5'
alias sei='cd ${SOLPSTOP}/modules/Eirene'
alias ssw='cd ${SOLPSTOP}/modules/Sonnet-light'
alias ssd='cd ${SOLPSTOP}/modules/DivGeo'
alias ssc='cd ${SOLPSTOP}/modules/Carre'
alias ssc2='cd ${SOLPSTOP}/modules/Carre2'
alias sst='cd ${SOLPSTOP}/modules/Triang'
alias ssu='cd ${SOLPSTOP}/modules/Uinp'
alias sbin='cd ${SOLPSTOP}/scripts'
alias slib='cd ${SOLPSTOP}/lib/${HOST_NAME}.${COMPILER}'
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

alias set_debug='. $SOLPSTOP/SETUP/debug.ksh'
alias unset_debug='. $SOLPSTOP/SETUP/nodebug.ksh'
alias set_openmp='. $SOLPSTOP/SETUP/openmp'
alias unset_openmp='. $SOLPSTOP/SETUP/noopenmp'
alias set_mpi='. $SOLPSTOP/SETUP/mpi'
alias unset_mpi='. $SOLPSTOP/SETUP/nompi'
alias set_ig='. $SOLPSTOP/SETUP/ig'
alias unset_ig='. $SOLPSTOP/SETUP/noig'
alias set_tgt='. $SOLPSTOP/SETUP/tgt'
alias unset_tgt='. $SOLPSTOP/SETUP/notgt'
alias set_adj='. $SOLPSTOP/SETUP/adj'
alias unset_adj='. $SOLPSTOP/SETUP/noadj'
alias set_tao='. $SOLPSTOP/SETUP/tao'
alias unset_tao='. $SOLPSTOP/SETUP/notao'

# Check if Motif library is present

[ -e "`which mwm`" ] || {
  export NO_MOTIF=1
}
[ -n "$NO_MOTIF" ] && {
  [ `whereis libXm | wc -w` != 1 ] && unset NO_MOTIF
}
[ -n "$NO_MOTIF" ] && {
  [ `ldconfig -p | grep 'libXm\.' | wc -l` != 0 ] && unset NO_MOTIF
}

# Check if Manual can be built
export LATEX=`${SOLPSTOP}/scripts/which_latex`
[ "$LATEX" = "" ] && {
  export NO_MANUAL=true
  echo 'No LaTeX executable found: Manual will not be built'
}

# Check if CMake available for Eirene compilation
export CMAKE=`which cmake`
[ "$CMAKE" = "" ] && {
  export NO_CMAKE=true
  echo 'Did not find a CMake installation. Will revert to traditional Eirene compilation style'
}

# Add any local settings if present
[ -s ${SOLPSTOP}/SETUP/setup.ksh.local ] && {
   echo "Loading SETUP/setup.ksh.local"
   . ${SOLPSTOP}/SETUP/setup.ksh.local
}
