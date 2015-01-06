#! /bin/tcsh -f

echo "Welcome to SOLPS-ITER!"
echo "Documentation can be found at: https://user.iter.org/?uid=QB8YQ2 (requires IDM account)"

setenv SOLPSTOP $PWD

if (-e whereami) then
  set iamat=`./whereami|tail -1`
  echo Running at $iamat
else
  set iamat="unknown"
endif

if($1 == "") then
  if (-e setup.csh.OBJECTCODE) source setup.csh.OBJECTCODE
  if (-e setup.csh.OBJECTCODE.local) source setup.csh.OBJECTCODE.local
else
  setenv OBJECTCODE $1
endif
if(! $?OBJECTCODE) then
  echo "OBJECTCODE not defined !"
endif

if (-e setup.csh.NAG) source setup.csh.NAG
if (-e setup.csh.NAG.$OBJECTCODE) source setup.csh.NAG.$OBJECTCODE
if (-e setup.csh.NAG.local) source setup.csh.NAG.local
if (-e setup.csh.NAG.local.$OBJECTCODE) source setup.csh.NAG.local.$OBJECTCODE

if(! $?NAG) then 
  source setup.csh.NAG.guess
endif

if (-e setup.csh.NCARG) source setup.csh.NCARG
if (-e setup.csh.NCARG.$OBJECTCODE) source setup.csh.NCARG.$OBJECTCODE
if (-e setup.csh.NCARG.local) source setup.csh.NCARG.local
if (-e setup.csh.NCARG.local.$OBJECTCODE) source setup.csh.NCARG.local.$OBJECTCODE

if(! $?NCARG_ROOT) then
  if (-e $SOLPSTOP/src/NCARG/$OBJECTCODE) setenv NCARG_ROOT $SOLPSTOP/src/NCARG/$OBJECTCODE
endif

if(! $?NCARG_ROOT) then 
  source setup.csh.NCARG.guess
endif
if(! $?NCARG) then 
  if($?NCARG_ROOT) then
    setenv NCARG_PATH `echo $NCARG_ROOT | sed -e "s:$SOLPSTOP/::"`
    switch ($NCARG_PATH)
    case '*3.*':
      echo 'Found NCAR Version 3.*'
      setenv NCARG '-L$(NCARG_ROOT)/lib -lncarg -lncarg_gks -lncarg_c -lncarg_loc -lX11 -lm'
      setenv NCAR_VERSION 3
      breaksw
    case '*4.*':
      echo 'Found NCAR Version 4.*'
      setenv NCARG '-L$(NCARG_ROOT)/lib -lncarg -lncarg_gks -lncarg_c -lX11 -lm'
      setenv NCAR_VERSION 4
      if (! $?SOLPS_CPP) then
        setenv SOLPS_CPP "-DNCAR4"
      else
        setenv SOLPS_CPP "$SOLPS_CPP -DNCAR4"
      endif
      breaksw
    default:
      echo 'Found NCAR Version ?.?; Assume 4'
      setenv NCARG '-L$(NCARG_ROOT)/lib -lncarg -lncarg_gks -lncarg_c -lX11 -lm'
      setenv NCAR_VERSION 4
      if (! $?SOLPS_CPP) then
        setenv SOLPS_CPP "-DNCAR4"
      else
        setenv SOLPS_CPP "$SOLPS_CPP -DNCAR4"
      endif
      breaksw
    endsw
  endif
endif

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

setenv GLI_HOME $SOLPSTOP/lib
setenv WSTYPE $OBJECTCODE
# setenv GLI_WSTYPE 210
setenv GRSOFT_DEVICE "211 62"
setenv SonnetTopDirectory ${SOLPSTOP}/src/Sonnet
setenv EscapeSonnet `echo ${SonnetTopDirectory} | sed 's:\/:\\\/:g'`

setenv DG ${SOLPSTOP}/src/DivGeo/dg
setenv CARRE_STOREDIR $SOLPSTOP/src/Carre/SAVE 

setenv PATH ${SOLPSTOP}/bin.local/${OBJECTCODE}:${SOLPSTOP}/bin.local/common:${SOLPSTOP}/bin/${OBJECTCODE}:${SOLPSTOP}/bin/common:${SOLPSTOP}/lib/python:${SonnetTopDirectory}/bin/${nOBJECTCODE}:${SOLPSTOP}/base/b2/${OBJECTCODE}:${PATH}
if ($?MANPATH) then
  setenv MANPATH ${MANPATH}:${SonnetTopDirectory}/man:${DG}/equtrn/doxygen/man
else
  setenv MANPATH ${SonnetTopDirectory}/man:${DG}/equtrn/doxygen/man
endif

alias ssb 'cd ${SOLPSTOP}/src/B2.5'
alias sb2 'cd ${SOLPSTOP}/src/B2.5'
alias sse 'cd ${SOLPSTOP}/src/Eirene'
alias sei 'cd ${SOLPSTOP}/src/Eirene'
alias ssw 'cd ${SOLPSTOP}/src/Sonnet'
alias sst 'cd ${SOLPSTOP}/src/Triang'
alias ssd 'cd ${SOLPSTOP}/src/DivGeo'
alias ssc 'cd ${SOLPSTOP}/src/Carre'
alias sbb 'cd ${SOLPSTOP}/base/B2.5'
alias sbe 'cd ${SOLPSTOP}/base/Eirene'
alias sbc 'cd ${SOLPSTOP}/base/Carre'
alias sbt 'cd ${SOLPSTOP}/base/Triang'
alias sbin 'cd ${SOLPSTOP}/bin/${OBJECTCODE}'
alias slib 'cd ${SOLPSTOP}/lib/${OBJECTCODE}'
alias srun 'cd ${SOLPSTOP}/runs'
alias sbinc 'cd ${SOLPSTOP}/bin/common'
alias stop 'cd ${SOLPSTOP}'

#alias sdg 'cd ${SOLPSTOP}/src/DivGeo/dg/class/${DEVICE}'
#alias ssf 'cd ${SOLPSTOP}/src/Sonnet/device/${DEVICE}'
alias ssu 'cd ${SOLPSTOP}/src/uinp'

setenv PATH $NCARG_ROOT/bin:$PATH
setenv MANPATH $NCARG_ROOT/man:$MANPATH

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

alias set_debug 'source $SOLPSTOP/debug'
alias unset_debug 'source $SOLPSTOP/nodebug'

if (-e setup.csh.$OBJECTCODE) source setup.csh.$OBJECTCODE
if (-e setup.csh.local) source setup.csh.local
if (-e setup.csh.local.$OBJECTCODE) source setup.csh.local.$OBJECTCODE
if (-e setup.csh.mdsplus) source setup.csh.mdsplus
if (-e setup.csh.mdsplus.$OBJECTCODE) source setup.csh.mdsplus.$OBJECTCODE
if (-e setup.csh.$USER) source setup.csh.$USER
if (-e setup.csh.$USER.$OBJECTCODE) source setup.csh.$USER.$OBJECTCODE

if (! $?IDL_PATH) setenv IDL_PATH
setenv IDL_PATH +$SOLPSTOP/data/IDL:${IDL_PATH}

setenv SOLPS_LIB ${SOLPSTOP}/lib/${OBJECTCODE}

if ($?LD_LIBRARY_PATH) then
  setenv LD_LIBRARY_PATH ${SOLPS_LIB}:${LD_LIBRARY_PATH}
else
  setenv LD_LIBRARY_PATH ${SOLPS_LIB}
endif

if ($?PYTHONPATH) then
  setenv PYTHONPATH ${PYTHONPATH}:${SOLPSTOP}/lib/python
else
  setenv PYTHONPATH ${SOLPSTOP}/lib/python
endif

setenv PLOT_SET_PATH '..:../..:${SOLPSTOP}/data.local/plot_set:${SOLPSTOP}/data/plot_set'

