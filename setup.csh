#! /bin/tcsh -f

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
#   2. SETUP/setup.csh.HOST_NAME.local file (sourced if present)
#   3. output of `whereami` script
#   4. fallback to UNKNOWN
#
# Variable COMPILER is determined with decreasing priority from:
#   1. First argument to `source setup.csh` command
#   2. $SOLPS_COMPILER_FORCE
#   3. output of `default_compiler` script
#   4. fallback to ifort64
#

echo Welcome to SOLPS-ITER!
echo Documentation can be found at:
echo https://sharepoint.iter.org/departments/POP/CM/IMAS/SOLPS-ITER
echo and
echo https://user.iter.org/\?uid=Q92BAQ
echo "(both require a valid ITER IDM account)"
echo The full SOLPS-ITER manual can be found in \$SOLPSTOP/doc/solps/solps.pdf
echo or online at:
echo https://sharepoint.iter.org/departments/POP/CM/IMDesign/Code%20Documentation/solps-doc/solps.pdf
echo The Eirene manual can be found in \$SOLPSTOP/modules/Eirene/Manual/eirene.pdf
echo or online at http://www.eirene.de/

( ps -p $$ | grep -Eq "tcsh|csh" ) || ( echo ; echo "*** Use tcsh to source setup.csh! *** " ; echo ; return 1 2> /dev/null ; exit 1 )

# Obtain the directory where setup.csh is located to use as SOLPSTOP,
# or bypass this by providing the path in SOLPSTOP_FORCE (can cause issues in scripts)
if ( $?SOLPSTOP_FORCE ) then
  setenv SOLPSTOP $SOLPSTOP_FORCE
else
  setenv LAST_COMMAND `echo $_`
  if (`echo ${LAST_COMMAND}` == "") then
    setenv SOLPSTOP $PWD
  else
    setenv SETUP_FILE `echo ${LAST_COMMAND} | cut -d " " -f 2`
    setenv REAL_FILE `eval echo ${SETUP_FILE}`
    setenv SETUP_PATH `dirname ${REAL_FILE}`
    setenv SOLPSTOP `cd ${SETUP_PATH}; pwd -L`
  endif
endif
setenv SOLPSWORK ${SOLPSTOP}/runs

# Set HOST_NAME and COMPILER, which will determine setup files to be used
#------------------------------------------------------------------------

if (`uname` != "Darwin") then   # Assuming to work on some HPC cluster
  if ( $?SOLPS_HOST_NAME_FORCE ) then
    setenv HOST_NAME $SOLPS_HOST_NAME_FORCE
    echo "Running at $HOST_NAME (set by SOLPS_HOST_NAME_FORCE)"
  else if (-s ${SOLPSTOP}/SETUP/setup.csh.HOST_NAME.local) then
    echo Loading SETUP/setup.csh.HOST_NAME.local.
    source ${SOLPSTOP}/SETUP/setup.csh.HOST_NAME.local
  else
    if (-s ${SOLPSTOP}/whereami) then
      set iamat=`${SOLPSTOP}/whereami|tail -1`
      echo Running at $iamat.
    else
      set iamat="UNKNOWN"
    endif
    switch ($iamat)
    case "*UNKNOWN":
      setenv HOST_NAME UNKNOWN
      breaksw
    default:
      setenv HOST_NAME ${iamat}
    endsw
  endif
else   # Using MacOS, so assuming to work on a local device
  setenv SYSNAME `uname`_`arch`
  setenv ARCH `arch`
  echo Running on MacOS, architecture ${ARCH}.
  setenv HOST_NAME 'DARWIN'
endif

# COMPILER can also be the argument to setup.csh call
if ($1 != "") then
  setenv COMPILER $1
  echo Using specified compiler $1.
else if ( $?SOLPS_COMPILER_FORCE ) then
  setenv COMPILER $SOLPS_COMPILER_FORCE
  echo "Using compiler $COMPILER (set by SOLPS_COMPILER_FORCE)".
else if (-s ${SOLPSTOP}/default_compiler) then
  setenv COMPILER `${SOLPSTOP}/default_compiler|tail -1`
  echo Using compiler $COMPILER.
else
  setenv COMPILER ifort64
  echo Assuming default compiler ifort64.
endif

if(! $?COMPILER) then
  echo COMPILER not defined!
endif

limit stacksize unlimited

# Load environment cache if it exists and the setup files have not changed
if (`uname` != "Darwin") then   # Assuming to work on some HPC cluster
  set setup=${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER}
  if ((-f $setup.env.local.${USER}) && \
      ( -M $setup.env.local.${USER} ) >= ( -M $setup ) && \
      ( -M $setup.env.local.${USER} ) >= ( -M ${SOLPSTOP}/setup.csh ) && \
      (!(-f ${SOLPSTOP}/SETUP/setup.csh.local) || \
        ( -M $setup.env.local.${USER} ) >= ( -M ${SOLPSTOP}/SETUP/setup.csh.local )) && \
      (!(-f $setup.local) || ( -M $setup.env.local.${USER} ) >= ( -M $setup.local ))) then
      echo "Loading cached SETUP/setup.csh.${HOST_NAME}.${COMPILER}.env.local.${USER}."
      source $setup.env.local.${USER}
      exit 0
  else
      # Black magic with sed:
      #   sed ':a;N;$\!ba;s/\\\n//g' = collapse multiline aliases with "\"-escaped newlines into a single line
      set setup_pre = `mktemp` alias_pre = `mktemp` && alias | sed 's/a;N;$\!ba//g' >! $alias_pre
      env|sed -ne "/^[ }]\|=(/b; s/\([^=]*\)=\(.*\)/setenv \1 '\2'/p" >! $setup_pre
  endif
endif

if (-x `which gmake`) then
  setenv MAKE `which gmake`
else
  setenv MAKE `which make`
endif

if ($?PYTHONPATH) then
  setenv PYTHONPATH ${PYTHONPATH}:${SOLPSTOP}/lib/python
else
  setenv PYTHONPATH ${SOLPSTOP}/lib/python
endif
setenv SOLPSLIB ${SOLPSTOP}/lib/${HOST_NAME}.${COMPILER}

# setup files for combination of HOST_NAME and COMPILER, + local modifications if present
if (-s ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER}) then
  echo Loading SETUP/setup.csh.${HOST_NAME}.${COMPILER}.
  source ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER}
else
  echo File SETUP/setup.csh.${HOST_NAME}.${COMPILER} not found!
endif
if (-s ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER}.local) then
  echo Loading SETUP/setup.csh.${HOST_NAME}.${COMPILER}.local.
  source ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER}.local
endif

if (! $?GRAPHCAP) setenv GRAPHCAP X11

if (! $?B2PLOT_DEV) setenv B2PLOT_DEV "x11 ps"
if (! $?GRSOFT_DEVICE) setenv GRSOFT_DEVICE "211 62"
setenv SonnetTopDirectory ${SOLPSTOP}/modules/Sonnet-light
setenv EscapeSonnet `echo ${SonnetTopDirectory} | sed 's:\/:\\\/:g'`

setenv DG ${SOLPSTOP}/modules/DivGeo
#setenv CARRE_STOREDIR ${SOLPSTOP}/modules/Carre/meshes

# Set path to scripts and executables
#------------------------------------

# First, remove the old path to SOLPS if already set
# (avoid too long paths)
if ($?SOLPS_PATH) then
  setenv PATH `echo $PATH | sed "s|${SOLPS_PATH}:||"`
endif

# Default PATH: no mpi, no openmp, no debug
set      TOOLCHAIN =  ${HOST_NAME}.${COMPILER}
set     CARRE_PATH =  ${SOLPSTOP}/modules/Carre/builds/${TOOLCHAIN}
set    DIVGEO_PATH =  ${SOLPSTOP}/modules/DivGeo/builds/${TOOLCHAIN}:${SOLPSTOP}/modules/DivGeo/equtrn/builds/${TOOLCHAIN}:${SOLPSTOP}/modules/DivGeo/convert/builds/${TOOLCHAIN}
set    EIRENE_PATH =  ${SOLPSTOP}/modules/Eirene/builds/standalone.${TOOLCHAIN}
set       B25_PATH =  ${SOLPSTOP}/modules/B2.5/builds/standalone.${TOOLCHAIN}
set B25EIRENE_PATH =  ${SOLPSTOP}/modules/B2.5/builds/couple_SOLPS-ITER.${TOOLCHAIN}
set      UINP_PATH =  ${SOLPSTOP}/modules/Uinp/builds/${TOOLCHAIN}
set    TRIANG_PATH =  ${SOLPSTOP}/modules/Triang/builds/${TOOLCHAIN}
set   SCRIPTS_PATH =  ${SOLPSTOP}/scripts.local:${SOLPSTOP}/scripts:${SOLPSTOP}/scripts/${TOOLCHAIN}:${SOLPSTOP}/modules/Eirene/scripts:${SOLPSTOP}/modules/Eirene/scripts/eirenex_v1.0.4:${SOLPSTOP}/modules/B2.5/src/test
set      AMDS_PATH =  ${SOLPSTOP}/modules/amds/builds/${TOOLCHAIN}
set       S45_PATH =  ${SOLPSTOP}/modules/solps4-5/builds/${TOOLCHAIN}

# Create mirror scripts directory links
#   - only re-creating links if they are not correct, so that we are compatible with read-only file systems (container)
set link_scripts="${SOLPSTOP}/scripts/${TOOLCHAIN}"
if (! $?NO_MPI) then
  foreach suffix ( ".mpi" ".mpi.debug" ".openmp.mpi" ".openmp.mpi.debug" )
    if (-d ${link_scripts}${suffix}) rm -Rf ${link_scripts}${suffix}
    if (`readlink ${link_scripts}${suffix}` != $link_scripts) ln -sf $link_scripts ${link_scripts}${suffix}
  end
endif
foreach suffix ( ".openmp" ".debug" ".openmp.debug" )
  if (-d ${link_scripts}${suffix}) rm -Rf ${link_scripts}${suffix}
  if (`readlink ${link_scripts}${suffix}` != $link_scripts) ln -sf $link_scripts ${link_scripts}${suffix}
end

# Note: in case of name clash between script and executable, script will be found first
setenv SOLPS_PATH  ${SCRIPTS_PATH}:${CARRE_PATH}:${DIVGEO_PATH}:${B25EIRENE_PATH}:${EIRENE_PATH}:${B25_PATH}:${UINP_PATH}:${TRIANG_PATH}:${AMDS_PATH}:${S45_PATH}
setenv OLD_PATH    "${PATH}"
setenv PATH        "${SOLPS_PATH}:${PATH}"
if ($?LD_LIBRARY_PATH) then
  setenv LD_LIBRARY_PATH ${SOLPSLIB}:${SOLPSTOP}/lib/python:${LD_LIBRARY_PATH}
else
  setenv LD_LIBRARY_PATH ${SOLPSLIB}:${SOLPSTOP}/lib/python
endif
setenv PYTHONPATH ${PYTHONPATH}:${SCRIPTS_PATH}
if ($?PYTHON_PATH) then
  setenv PYTHONPATH ${PYTHONPATH}:${PYTHON_PATH}
endif

unset TOOLCHAIN SCRIPTS_PATH CARRE_PATH DIVGEO_PATH EIRENE_PATH B25_PATH B25EIRENE_PATH UINP_PATH TRIANG_PATH AMDS_PATH S45_PATH

# Check whether SOLPS_DEBUG, SOLPS_OPENMP and SOLPS_MPI have been set already by the user
if ($?SOLPS_OPENMP) source ${SOLPSTOP}/SETUP/openmp
if ($?SOLPS_DEBUG)  source ${SOLPSTOP}/SETUP/debug
if ($?SOLPS_MPI)    source ${SOLPSTOP}/SETUP/mpi

# Set path to manuals
#--------------------

if ($?MANPATH) then
  setenv MANPATH ${MANPATH}:${SonnetTopDirectory}/man:${DG}/equtrn/doxygen/man
else
  setenv MANPATH ${SonnetTopDirectory}/man:${DG}/equtrn/doxygen/man
endif

# Remove double entries from some environment variables, if there are any

setenv PATH  `echo $PATH | awk -v RS=: -v ORS= '\\!a[$0]++ {if (NR>1) printf(":"); printf("%s",$0) }'`
setenv LD_LIBRARY_PATH  `echo $LD_LIBRARY_PATH | awk -v RS=: -v ORS= '\\!a[$0]++ {if (NR>1) printf(":"); printf("%s",$0) }'`
setenv MANPATH  `echo $MANPATH | awk -v RS=: -v ORS= '\\!a[$0]++ {if (NR>1) printf(":"); printf("%s",$0) }'`
setenv PYTHONPATH  `echo $PYTHONPATH | awk -v RS=: -v ORS= '\\!a[$0]++ {if (NR>1) printf(":"); printf("%s",$0) }'`
setenv OLD_PATH  `echo $OLD_PATH | awk -v RS=: -v ORS= '\\!a[$0]++ {if (NR>1) printf(":"); printf("%s",$0) }'`

setenv PATH_FOR_LOOP "${PATH}"
setenv MANPATH_FOR_LOOP "${MANPATH}"

alias sb2  'cd ${SOLPSTOP}/modules/B2.5'
alias sbb  'cd ${SOLPSTOP}/modules/B2.5'
alias sei  'cd ${SOLPSTOP}/modules/Eirene'
alias ssw  'cd ${SOLPSTOP}/modules/Sonnet-light'
alias sst  'cd ${SOLPSTOP}/modules/Triang'
alias ssd  'cd ${SOLPSTOP}/modules/DivGeo'
alias ssc  'cd ${SOLPSTOP}/modules/Carre'
alias ssu  'cd ${SOLPSTOP}/modules/Uinp'
alias slib 'cd ${SOLPSTOP}/lib/${HOST_NAME}.${COMPILER}'
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

alias   set_debug  'source $SOLPSTOP/SETUP/debug'
alias unset_debug  'source $SOLPSTOP/SETUP/nodebug'
alias   set_openmp 'source $SOLPSTOP/SETUP/openmp'
alias unset_openmp 'source $SOLPSTOP/SETUP/noopenmp'
alias   set_mpi    'source $SOLPSTOP/SETUP/mpi'
alias unset_mpi    'source $SOLPSTOP/SETUP/nompi'
alias   set_ig     'source $SOLPSTOP/SETUP/ig'
alias unset_ig     'source $SOLPSTOP/SETUP/noig'

# Check for Motif library
if (! -e `which mwm`) setenv NO_MOTIF 1
if ($?NO_MOTIF) then
  if (`whereis libXm | wc -w` != 1) unsetenv NO_MOTIF
endif
if ($?NO_MOTIF) then
  if (`ldconfig -p | grep 'libXm\.' | wc -l` != 0) unsetenv NO_MOTIF
endif

# Check if Manual can be built
setenv LATEX `${SOLPSTOP}/scripts/which_latex`
if ($LATEX == "") then
  setenv NO_MANUAL true
  echo 'No LaTeX executable found: Manual will not be built'
endif

# Check if CMake available for Eirene compilation
if (! -x `which cmake`) then
  setenv NO_CMAKE true
  echo 'Did not find a CMake installation. Will revert to traditional Eirene compilation style'
endif

# Add any local settings if present
if (-s ${SOLPSTOP}/SETUP/setup.csh.local) then
  echo Loading SETUP/setup.csh.local.
  source ${SOLPSTOP}/SETUP/setup.csh.local
endif

# Create environment cache for faster loading (setenv, unsetenv, and aliases)
if (`uname` != "Darwin") then   # Assuming to work on some HPC cluster
  set setup_post = `mktemp`
  env | sed -ne "/^[ }]\|=()/b; s/\([^=]*\)=\(.*\)/setenv \1 '\2'/p" \
     -e '1i# Generated environment cache. Do not edit!' >! $setup_post
  grep -F -v -f $setup_pre $setup_post >! $setup.env.local.${USER}
  sed -i -e "s/setenv/unsetenv/; s/ '.*'//" $setup_pre $setup_post
  grep -F -v -f $setup_post $setup_pre >> $setup.env.local.${USER}
  # Black magic with sed:
  #   sed ':a;N;$!ba;s/\\\n//g' = collapse multiline aliases with "\"-escaped newlines into a single line
  #   sed 's/^/alias /' = prepend "alias " for all lines
  #   sed 's/!/\\!/' = properly escape "!" characters ("!" is special in tcsh)
  alias | sed ':a;N;$\!ba;s/\\\n//g' | grep -F -v -f $alias_pre | sed -e 's/^/alias /' \
      -e "/\t(.*[;|&].*)/{s/\t(/\t'(/;s/)"'$'"/)'/;b}" \
      -e "s/\t\([^(].*\)/\t'\1'/" -e 's/\t(/\t/;s/)$//' \
      -e 's/\!/\\\!/' >> $setup.env.local.${USER}
  rm -f $setup_pre $setup_post $alias_pre
endif

# List loaded modules, assuming to work on some HPC cluster
if (`uname` != "Darwin") then
  module list
endif
