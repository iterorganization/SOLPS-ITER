#! /bin/tcsh -f

echo "Welcome to SOLPS-ITER!"
echo "Documentation can be found at: https://user.iter.org/?uid=QB8YQ2 (requires IDM account)"

setenv SOLPSTOP $PWD


# Set HOST and COMPILER, which will determine setup-files to be used
#-------------------------------------------------------------------

if (-e whereami) then
  set iamat=`./whereami|tail -1`
  echo Running at $iamat.
else
  set iamat="UNKNOWN"
endif

if ( $iamat == "*UNKNOWN" ) then
  setenv HOST default
else
  setenv HOST ${iamat}
endif

# COMPILER can also be the argument to setup.csh-call
if($1 == "") then
  if (-e setup.COMPILER) then
    setenv COMPILER `./setup.COMPILER|tail -1`
    echo Using compiler $COMPILER.
  else
    setenv COMPILER ifort64
    echo Using default compiler ifort64.
  endif
else
  setenv COMPILER $1
endif
if(! $?COMPILER) then
  echo COMPILER not defined!
endif

# setup files for combination of HOST and COMPILER, + local modifications if present
if (-e SETUP/setup.csh.${HOST}.${COMPILER})       source SETUP/setup.csh.${HOST}.${COMPILER}
if (-e SETUP/setup.csh.${HOST}.${COMPILER}.local) source SETUP/setup.csh.${HOST}.${COMPILER}.local



if (! $?GRAPHCAP) setenv GRAPHCAP X11



setenv GRSOFT_DEVICE "211 62"
setenv SonnetTopDirectory ${SOLPSTOP}/src/Sonnet-light
setenv EscapeSonnet `echo ${SonnetTopDirectory} | sed 's:\/:\\\/:g'`

setenv DG ${SOLPSTOP}/src/DivGeo
setenv CARRE_STOREDIR $SOLPSTOP/src/Carre/SAVE 


# Set path to scripts and executables
#------------------------------------

# First, remove the old path to SOLPS if already set
# (avoid too long paths)
if ($?PATH_SOLPS) then
    setenv PATH `echo $PATH | sed "s|${PATH_SOLPS}:||"`
endif

# Default PATH: no mpi, no debug
set TOOLCHAIN      =  ${HOST}.${COMPILER}
set PATH_CARRE     =  ${SOLPSTOP}/src/Carre/builds/${TOOLCHAIN}
set PATH_DIVGEO    =  ${SOLPSTOP}/src/DivGeo/builds/${TOOLCHAIN}
set PATH_EIRENE    =  ${SOLPSTOP}/src/Eirene/builds/standalone.${TOOLCHAIN}
set PATH_B25       =  ${SOLPSTOP}/src/B2.5/builds/standalone.${TOOLCHAIN}
set PATH_B25EIRENE =  ${SOLPSTOP}/src/B2.5/builds/couple_Eirene.${TOOLCHAIN}
set PATH_UINP      =  ${SOLPSTOP}/src/Uinp/builds/${TOOLCHAIN}
set PATH_TRIANG    =  ${SOLPSTOP}/src/Triang/builds/${TOOLCHAIN}
set PATH_SCRIPTS   =  ${SOLPSTOP}/scripts

# Note: in case of name-clash between script and executable, script will be found first
setenv PATH_SOLPS  ${PATH_SCRIPTS}:${PATH_CARRE}:${PATH_DIVGEO}:${PATH_B25EIRENE}:${PATH_EIRENE}:${PATH_B25}:${PATH_UINP}:${PATH_TRIANG}
setenv PATH        ${PATH_SOLPS}:${PATH}

unset TOOLCHAIN PATH_CARRE PATH_DIVGEO PATH_EIRENE PATH_B25 PATH_B25EIRENE PATH_UINP PATH_TRIANG

# Set path to manuals
#--------------------

if ($?MANPATH) then
  setenv MANPATH ${MANPATH}:${SonnetTopDirectory}/man:${DG}/equtrn/doxygen/man
else
  setenv MANPATH ${SonnetTopDirectory}/man:${DG}/equtrn/doxygen/man
endif


setenv PATH $NCARG_ROOT/bin:$PATH
setenv MANPATH $NCARG_ROOT/man:$MANPATH


alias sb2  'cd ${SOLPSTOP}/modules/B2.5'
alias sbb  'cd ${SOLPSTOP}/modules/B2.5'
alias sei  'cd ${SOLPSTOP}/modules/Eirene'
alias ssw  'cd ${SOLPSTOP}/modules/Sonnet'
alias sst  'cd ${SOLPSTOP}/modules/Triang'
alias ssd  'cd ${SOLPSTOP}/modules/DivGeo'
alias ssc  'cd ${SOLPSTOP}/modules/Carre'
alias ssu  'cd ${SOLPSTOP}/modules/Uinp'
alias slib 'cd ${SOLPSTOP}/lib/${HOST}.${COMPILER}'
alias srun 'cd ${SOLPSTOP}/runs'
alias sbr  'cd ${SOLPSTOP}/runs'
alias scr  'cd ${SOLPSTOP}/scripts'
alias stop 'cd ${SOLPSTOP}'


#alias sdg 'cd ${SOLPSTOP}/data/DivGeo/class/${DEVICE}'
#alias ssf 'cd ${SOLPSTOP}/src/Sonnet/device/${DEVICE}'



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


alias set_debug   'source $SOLPSTOP/SETUP/debug'
alias unset_debug 'source $SOLPSTOP/SETUP/nodebug'
alias set_mpi     'source $SOLPSTOP/SETUP/mpi'
alias unset_mpi   'source $SOLPSTOP/SETUP/nompi'


#if (! $?IDL_PATH) setenv IDL_PATH
#setenv IDL_PATH +$SOLPSTOP/data/IDL:${IDL_PATH}
#
#
#
#if ($?PYTHONPATH) then
#  setenv PYTHONPATH ${PYTHONPATH}:${SOLPSTOP}/lib/python
#else
#  setenv PYTHONPATH ${SOLPSTOP}/lib/python
#endif
#
#setenv PLOT_SET_PATH '..:../..:${SOLPSTOP}/data.local/plot_set:${SOLPSTOP}/data/plot_set'

