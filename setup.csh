#! /bin/tcsh -f

echo "Welcome to SOLPS-ITER!"
echo "Documentation can be found at: https://user.iter.org/?uid=QB8YQ2 (requires IDM account)"

setenv SOLPSTOP $PWD


# Set HOSTNAME, which will determine setup-files to be used

if (-e whereami) then
  set iamat=`./whereami|tail -1`
  setenv HOSTNAME ${iamat}
  echo Running at $iamat
else
  set iamat="unknown"
  setenv HOSTNAME default
endif


if($1 == "") then
  setenv OBJECTCODE ifort64
  echo "Using default compiler ifort64"
else
  setenv OBJECTCODE $1
endif
if(! $?OBJECTCODE) then
  echo "OBJECTCODE not defined!"
endif

if (-e SETUP/setup.csh.${HOSTNAME}.${OBJECTCODE})       source SETUP/setup.csh.${HOSTNAME}.${OBJECTCODE}
if (-e SETUP/setup.csh.${HOSTNAME}.${OBJECTCODE}.local) source SETUP/setup.csh.${HOSTNAME}.${OBJECTCODE}.local


if (! $?GRAPHCAP) setenv GRAPHCAP X11

switch ($OBJECTCODE)
case "IBMaix":
  setenv nOBJECTCODE Aix
  breaksw
case "DECalpha":
  setenv nOBJECTCODE Alpha
  breaksw
case "SGIirix":
  setenv nOBJECTCODE Iris
  breaksw
case "sun4c":
  setenv nOBJECTCODE SunOS
  breaksw
case "sun5":
  setenv nOBJECTCODE Solaris
  breaksw
case "unicos":
  setenv nOBJECTCODE Unicos
  breaksw
case "linux.ifort64":
  setenv nOBJECTCODE Intel
  breaksw
default:
  setenv nOBJECTCODE Unknown
  breaksw
endsw

#setenv GLI_HOME $SOLPSTOP/lib
#setenv WSTYPE $OBJECTCODE
# setenv GLI_WSTYPE 210
setenv GRSOFT_DEVICE "211 62"
setenv SonnetTopDirectory ${SOLPSTOP}/src/Sonnet
setenv EscapeSonnet `echo ${SonnetTopDirectory} | sed 's:\/:\\\/:g'`

setenv DG ${SOLPSTOP}/src/DivGeo
#setenv CARRE_STOREDIR $SOLPSTOP/src/Carre/SAVE 

setenv PATH ${SOLPSTOP}/scripts:${SOLPSTOP}/bin:${PATH}
if ($?MANPATH) then
  setenv MANPATH ${MANPATH}:${SonnetTopDirectory}/man:${DG}/equtrn/doxygen/man
else
  setenv MANPATH ${SonnetTopDirectory}/man:${DG}/equtrn/doxygen/man
endif


setenv PATH $NCARG_ROOT/bin:$PATH
setenv MANPATH $NCARG_ROOT/man:$MANPATH


alias sb2 'cd ${SOLPSTOP}/src/B2.5'
alias sbb 'cd ${SOLPSTOP}/src/B2.5'
alias sei 'cd ${SOLPSTOP}/src/Eirene'
alias ssw 'cd ${SOLPSTOP}/src/Sonnet'
alias sst 'cd ${SOLPSTOP}/src/Triang'
alias ssd 'cd ${SOLPSTOP}/src/DivGeo'
alias ssc 'cd ${SOLPSTOP}/src/Carre'
alias ssu 'cd ${SOLPSTOP}/src/Uinp'
alias sbin 'cd ${SOLPSTOP}/bin/${OBJECTCODE}'
alias slib 'cd ${SOLPSTOP}/lib/${OBJECTCODE}'
alias srun 'cd ${SOLPSTOP}/runs'
alias sbr 'cd ${SOLPSTOP}/runs'
alias scr 'cd ${SOLPSTOP}/scripts'
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

alias set_debug 'source $SOLPSTOP/SETUP/debug'
alias unset_debug 'source $SOLPSTOP/SETUP/nodebug'


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

