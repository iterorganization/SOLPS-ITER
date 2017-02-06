#! /bin/tcsh -f

echo Welcome to SOLPS-ITER!
echo Documentation can be found at:
echo https://portal.iter.org/departments/POP/CM/IMAS/SOLPS-ITER
echo and
echo https://user.iter.org/\?uid=Q92BAQ
echo "(both require a valid ITER IDM account)"
echo The full SOLPS-ITER manual can be found in \$SOLPSTOP/doc/solps/solps.pdf
echo The Eirene manual is located at http://www.eirene.de/

setenv SOLPSTOP $PWD
setenv SOLPSWORK ${SOLPSTOP}/runs


# Set HOST_NAME and COMPILER, which will determine setup-files to be used
#------------------------------------------------------------------------

if (-e whereami) then
  set iamat=`./whereami|tail -1`
  echo Running at $iamat.
else
  set iamat="UNKNOWN"
endif

if (-e SETUP/setup.csh.HOST_NAME.local) then
  echo Loading SETUP/setup.csh.HOST_NAME.local
  setenv HOST_NAME `cat SETUP/setup.csh.HOST_NAME.local`
else
  if ( $iamat == "*UNKNOWN" ) then
    setenv HOST_NAME default
  else
    setenv HOST_NAME ${iamat}
  endif
endif

# COMPILER can also be the argument to setup.csh call
if($1 == "") then
  if (-e default_compiler) then
    setenv COMPILER `./default_compiler|tail -1`
    echo Using compiler $COMPILER.
  else
    setenv COMPILER ifort64
    echo Assuming default compiler ifort64.
  endif
else
  setenv COMPILER $1
endif
if(! $?COMPILER) then
  echo COMPILER not defined!
endif

if ($?PYTHONPATH) then
  setenv PYTHONPATH ${PYTHONPATH}:${SOLPSTOP}/lib/python
else
  setenv PYTHONPATH ${SOLPSTOP}/lib/python
endif

# setup files for combination of HOST_NAME and COMPILER, + local modifications if present
if (-e SETUP/setup.csh.${HOST_NAME}.${COMPILER}) then
  echo Loading SETUP/setup.csh.${HOST_NAME}.${COMPILER}.
  source SETUP/setup.csh.${HOST_NAME}.${COMPILER}
else
  echo File SETUP/setup.csh.${HOST_NAME}.${COMPILER} not found!
endif
if (-e SETUP/setup.csh.${HOST_NAME}.${COMPILER}.local) then
  echo Loading SETUP/setup.csh.${HOST_NAME}.${COMPILER}.local.
  source SETUP/setup.csh.${HOST_NAME}.${COMPILER}.local
endif

limit stacksize unlimited

if (! $?GRAPHCAP) setenv GRAPHCAP X11

if (! $?B2PLOT_DEV) setenv B2PLOT_DEV "x11 ps" 
if (! $?GRSOFT_DEVICE) setenv GRSOFT_DEVICE "211 62"
setenv SonnetTopDirectory ${SOLPSTOP}/modules/Sonnet-light
setenv EscapeSonnet `echo ${SonnetTopDirectory} | sed 's:\/:\\\/:g'`

setenv DG ${SOLPSTOP}/modules/DivGeo
setenv SOLPSLIB ${SOLPSTOP}/lib/${HOST_NAME}.${COMPILER}
#setenv CARRE_STOREDIR $SOLPSTOP/modules/Carre/meshes




# Set path to scripts and executables
#------------------------------------

# First, remove the old path to SOLPS if already set
# (avoid too long paths)
if ($?SOLPS_PATH) then
  setenv PATH `echo $PATH | sed "s|${SOLPS_PATH}:||"`
endif

# Default PATH: no mpi, no debug
set      TOOLCHAIN =  ${HOST_NAME}.${COMPILER}
set     CARRE_PATH =  ${SOLPSTOP}/modules/Carre/builds/${TOOLCHAIN}
set    DIVGEO_PATH =  ${SOLPSTOP}/modules/DivGeo/builds/${TOOLCHAIN}:${SOLPSTOP}/modules/DivGeo/equtrn/builds/${TOOLCHAIN}:${SOLPSTOP}/modules/DivGeo/convert/builds/${TOOLCHAIN}
set    EIRENE_PATH =  ${SOLPSTOP}/modules/Eirene/builds/standalone.${TOOLCHAIN}
set       B25_PATH =  ${SOLPSTOP}/modules/B2.5/builds/standalone.${TOOLCHAIN}
set B25EIRENE_PATH =  ${SOLPSTOP}/modules/B2.5/builds/couple_SOLPS-ITER.${TOOLCHAIN}
set      UINP_PATH =  ${SOLPSTOP}/modules/Uinp/builds/${TOOLCHAIN}
set    TRIANG_PATH =  ${SOLPSTOP}/modules/Triang/builds/${TOOLCHAIN}
set   SCRIPTS_PATH =  ${SOLPSTOP}/scripts.local:${SOLPSTOP}/scripts:${SOLPSTOP}/modules/Eirene/scripts
set      AMDS_PATH =  ${SOLPSTOP}/modules/amds/builds/${TOOLCHAIN}
set       S45_PATH =  ${SOLPSTOP}/modules/solps4-5/builds/${TOOLCHAIN}

# Note: in case of name-clash between script and executable, script will be found first
setenv SOLPS_PATH  ${SCRIPTS_PATH}:${CARRE_PATH}:${DIVGEO_PATH}:${B25EIRENE_PATH}:${EIRENE_PATH}:${B25_PATH}:${UINP_PATH}:${TRIANG_PATH}:${AMDS_PATH}:${S45_PATH}
setenv OLD_PATH    ${PATH}
setenv PATH        ${SOLPS_PATH}:${PATH}
if ($?LD_LIBRARY_PATH) then
  setenv LD_LIBRARY_PATH ${SOLPSLIB}:${LD_LIBRARY_PATH}
else
  setenv LD_LIBRARY_PATH ${SOLPSLIB}
endif

unset TOOLCHAIN SCRIPTS_PATH CARRE_PATH DIVGEO_PATH EIRENE_PATH B25_PATH B25EIRENE_PATH UINP_PATH TRIANG_PATH AMDS_PATH S45_PATH

# Check whether SOLPS_DEBUG and SOLPS_MPI had been set already by the user
if ($?SOLPS_DEBUG) source $SOLPSTOP/SETUP/debug
if ($?SOLPS_MPI)   source $SOLPSTOP/SETUP/mpi


# Set path to manuals
#--------------------

if ($?MANPATH) then
  setenv MANPATH ${MANPATH}:${SonnetTopDirectory}/man:${DG}/equtrn/doxygen/man
else
  setenv MANPATH ${SonnetTopDirectory}/man:${DG}/equtrn/doxygen/man
endif



alias sb2  'cd ${SOLPSTOP}/modules/B2.5'
alias sbb  'cd ${SOLPSTOP}/modules/B2.5'
alias sei  'cd ${SOLPSTOP}/modules/Eirene'
alias ssw  'cd ${SOLPSTOP}/modules/Sonnet'
alias sst  'cd ${SOLPSTOP}/modules/Triang'
alias ssd  'cd ${SOLPSTOP}/modules/DivGeo'
alias ssc  'cd ${SOLPSTOP}/modules/Carre'
alias ssu  'cd ${SOLPSTOP}/modules/Uinp'
alias slib 'cd ${SOLPSTOP}/lib/${HOST_NAME}.${COMPILER}'
alias srun 'cd ${SOLPSTOP}/runs'
alias sbr  'cd ${SOLPSTOP}/runs'
alias scr  'cd ${SOLPSTOP}/scripts'
alias stop 'cd ${SOLPSTOP}'

alias sdg 'cd ${SOLPSTOP}/modules/DivGeo/device/${DEVICE}'
alias ssf 'cd ${SOLPSTOP}/modules/DivGeo/device/${DEVICE}'


alias xyplot plot xyplot
alias xyplot2 plot xyplot2
alias xyplot3 plot xyplot3
alias xyplot4 plot xyplot4
alias xyplot5 plot xyplot5
alias xyplot6 plot xyplot6
alias xyplot7 plot xyplot7
alias xyplot8 plot xyplot8
alias xyplot8 plot xyplot8
alias xyplot9 plot xyplot9
alias xlyplot plot xlyplot
alias xlyplot2 plot xlyplot2
alias xlyplot3 plot xlyplot3
alias xlyplot4 plot xlyplot4
alias xlyplot5 plot xlyplot5
alias xlyplot6 plot xlyplot6
alias xlyplot7 plot xlyplot7
alias xlyplot8 plot xlyplot8
alias xlyplot8 plot xlyplot8
alias xlyplot9 plot xlyplot9
alias xylplot plot xylplot
alias xylplot2 plot xylplot2
alias xylplot3 plot xylplot3
alias xylplot4 plot xylplot4
alias xylplot5 plot xylplot5
alias xylplot6 plot xylplot6
alias xylplot7 plot xylplot7
alias xylplot8 plot xylplot8
alias xylplot8 plot xylplot8
alias xylplot9 plot xylplot9
alias xlylplot plot xlylplot
alias xlylplot2 plot xlylplot2
alias xlylplot3 plot xlylplot3
alias xlylplot4 plot xlylplot4
alias xlylplot5 plot xlylplot5
alias xlylplot6 plot xlylplot6
alias xlylplot7 plot xlylplot7
alias xlylplot8 plot xlylplot8
alias xlylplot8 plot xlylplot8
alias xlylplot9 plot xlylplot9


alias   set_debug 'source $SOLPSTOP/SETUP/debug'
alias unset_debug 'source $SOLPSTOP/SETUP/nodebug'
alias   set_mpi   'source $SOLPSTOP/SETUP/mpi'
alias unset_mpi   'source $SOLPSTOP/SETUP/nompi'
alias   set_ig   'source $SOLPSTOP/SETUP/ig'
alias unset_ig   'source $SOLPSTOP/SETUP/noig'


#if (! $?IDL_PATH) setenv IDL_PATH
#setenv IDL_PATH +$SOLPSTOP/data/IDL:${IDL_PATH}
#
#
#

#
#setenv PLOT_SET_PATH '..:../..:${SOLPSTOP}/data.local/plot_set:${SOLPSTOP}/data/plot_set'


# Add any local settings if present
if (-e SETUP/setup.csh.local) then
  echo Loading SETUP/setup.csh.local.
  source SETUP/setup.csh.local
endif

# Add links to the IMAS solps-iter database

if ($HOST_NAME == "ITER") then
  source scripts/imasdb_solps-iter
  module list
endif

# List loaded modules

if (-e module) then
  module list
endif

  
