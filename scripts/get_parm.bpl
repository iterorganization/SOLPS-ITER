#! /bin/ksh

#  VERSION : 16.09.2013 01:59

# This script extracts some parameters necessary for any script calling b2plot
# It should be invoked in the same shell, i. e. ". get_parm.bpl", and it
# results in assigning the values to the following variables

# The basic variables (to be found from b2.parameters):

#   NSPEC     : number of atomic species
#   NS        : number of ion species
#   SPEC[i]   : species names
#   SUMZ_1[i] : the first fluid of a species
#   SUMZ_N[i] : the last fluid of a species
#   NX        : the last column of the grid (the outer target)
#   NY        : the last row of the grid (the outer edge)
#   NSEP      : the separatrix row of the grid
#   NMP_I     : the inner midplane column
#   NMP_O     : the outer midplane column
#   NTP_I     : the inner top target column
#   NTP_O     : the outer top target column
#   NXC_I     : the inner x-point column
#   NXC_O     : the outer x-point column
#   NXT_I     : the inner top x-point column
#   NXT_O     : the outer top x-point column
#   NNISO     : the number of isolating cuts

# Additional variables (found from other files)

#   L         : the run number (VarID)
#   LL        : the case ID    (VarID)
#   BB        : viewing frame(s)  (box.b2p)
#   SB        : suffices for PS files with different frames (box.b2p)
#   KW        : keywords for the frames:
#                        P for PostScript, g for gmeta, empty for both

# Derived variables

#   SUMZ_ALL_I: b2plot command to sum over all ion species
#   SUMZ_ALL_F: b2plot command to sum over all neutral species


function spec_symbol {
  case "$1" in
    (  1 )  S=$H;;
    (  2 )  S=He;;
    (  3 )  S=Li;;
    (  4 )  S=Be;;
    (  5 )  S=B_;;
    (  6 )  S=C_;;
    (  7 )  S=N_;;
    (  8 )  S=O_;;
    ( 10 )  S=Ne;;
    ( 18 )  S=Ar;;
    ( 74 )  S=W_;;
    (  * )  S=xx;;
  esac
}

# [ -s b2.parameters ] && [ -r b2.parameters ] || {
#   print -u2 "No b2.parameters - cannot proceed"
#   exit 2
# }

[ -s b2fstate ] && [ -r b2fstate ] || {
  print -u2 "No b2fstate file - cannot proceed"
  exit 2
}

u=`grep -A1 'nx,ny,ns' b2fstate | tail -1 | awk '{print $1}'`
let "NX=$u"

u=`grep -A1 'nx,ny,ns' b2fstate | tail -1 | awk '{print $2}'`
let "NY=$u"

u=`grep -A1 'nx,ny,ns' b2fstate | tail -1 | awk '{print $3}'`
let "NS=$u"
let "NLINES=1+$NS/6"

m=`grep -A$NLINES ' am' b2fstate | tail -$NLINES | paste -s`
zamin=`grep -A$NLINES 'zamin' b2fstate | tail -$NLINES | paste -s`
zamax=`grep -A$NLINES 'zamax' b2fstate | tail -$NLINES | paste -s`

u=`pipe_run.log | grep jxi | grep User-corrected | head -1 | awk '{print $8}'`
let "NMP_I=$u"

u=`pipe_run.log | grep jxa | grep User-corrected | head -1 | awk '{print $9}'`
let "NMP_O=$u"

u=`pipe_run.log | grep jsep | grep User-corrected | head -1 | awk '{print $10+1}'`
let "NSEP=$u"

set -A Hiso -- \* H D T
H=D_
unset ZMIN ZMAX
typeset -a ZMIN
typeset -a ZMAX
[ -n "$zamin" ] && {
  i=0; for f in ${zamin#*=}; do {
    let "i=i+1"; ZMIN[$i]=$f
    [ "$i" -eq "$NS" ] && break
}; done }
[ -n "$zamax" ] && {
  i=0; for f in ${zamax#*=}; do {
    let "i=i+1"; ZMAX[i]=$f
    [ "$i" -eq "$NS" ] && break
}; done }
[ -n "$m" ] && [ -n "$zamin" ] && [ -n "$zamax" ] && {
unset MI ZI
typeset -a MI
typeset -a ZI
  i=0; for f in ${m#*=}; do {
    let "i=i+1";
    MI[$i]=$(("$f"));
    ZI[$i]=$((0.5*"${ZMIN[$i]}"+0.5*"${ZMAX[$i]}"));
    [ "$i" -eq "$NS" ] && break
  }; done

  i=1; while [ -n "${MI[$i]}" ] && [ -n "${ZI[$i]}" ]; do {
    [ "${ZI[$i]}" -eq 1 ] && {
      j=${MI[$i]}
      H=${Hiso[$j]}_
      break
    }
    let "i=i+1"
  }; done
}

unset Hiso MI ZI i j m z NTP_I NTP_O NXT_I NXT_O

u=`pipe_run.log | grep natm | head -1 | awk '{print $4}'`
let "NSPEC=$u"
if [ "$NSPEC" -gt 1 ]
 then {
  u=`pipe_run.log | grep nfluids | head -1 | awk '{for (i=2;i<=NF;i++) print $i}'`
  set -A u -- `echo ${u#*=} | tr , \ `
  n=0; p=0
  i=0; until [ $i -eq "$NSPEC" ]; do {
    let "i=i+1"
    f=${u[i]}
    let "k=p+i"
    let "p=p+f"
    let "n=k+f-1"
    SUMZ_1[i]=$k
    SUMZ_N[i]=$n
    spec_symbol $f
    SPEC[i]="$S"
    [ "$i" -ge "$NSPEC" ] && break
  }; done
 }
else
  NSPEC=1
  SPEC=$H
  SUMZ_1=1
  SUMZ_N=1
fi
unset u f n p k i S

SUMZ_ALL_I="1 $(($NS-1)) sumz"
SUMZ_ALL_F="1 $NSPEC sumz"

[ -s b2.boundary.parameters ]  || {
    print -u2 "No b2.boundary.parameters file found"
  }

u=`grep -i -e '  *nniso *=' -e '^nniso *=' -e ',nniso *=' b2.boundary.parameters | tail -1 | tr [A-Z] [a-z]`
u=${u#*nniso}
u=${u#*=}
u=${u%%,*}
((NNISO=$u))
[ -n "$u" ] && [ "$u" -eq 1 ] && {
  u=`grep -i -e '  *nxiso1 *=' -e '^nxiso1 *=' -e ',nxiso1 *=' b2.boundary.parameters | tail -1 | tr [A-Z] [a-z]`
  u=${u#*nxiso1}
  u=${u#*=}
  u=${u%%,*}
  let "NTP_I=$u-1"
  let "NTP_O=$u+2"
}

[ -s b2fgmtry ] && {
  file=b2fgmtry
} || {
  [ -s ../baserun/b2fgmtry ] && {
    file=../baserun/b2fgmtry
  } || {
    print -u2 "No b2fgmtry file found"
  }
}

u=`grep -A1 leftcut $file | tail -1 | awk '{print $1}'`
let "NXC_I=$u"

u=`grep -A1 rightcut $file | tail -1 | awk '{print $1}'`
let "NXC_O=$u"

u=`grep -A1 nncut $file | tail -1 | awk '{print $1}'`
[ -n "$u" ] && [ "$u" -eq 2 ] && {
  u=`grep -A1 leftcut $file | tail -1 | awk '{print $2}'`
  let "NXT_I=$u"
  u=`grep -A1 rightcut $file | tail -1 | awk '{print $2}'`
  let "NXT_O=$u"
}

u=`grep -A1 label b2fstate | tail -1`
L=`echo $u | cut -f1 -d_ | cut -f2 -d# | sed -e 's: :_:g' -e 's:/:-:g' `
LL=`echo $u | tr _ ' ' | awk '{for (i=8;i<=NF;i++) printf "%s ",$i}'`
u=`grep -A1 time b2fstate | tail -1 | awk '{printf "%f\n", $1*1000}'`
let "t=$u"

LL="$LL - $t msec"
echo "LL        : $LL"
echo "L         : $L"

echo "NSPEC     : $NSPEC"
echo "NS        : $NS"
echo "SPEC      : ${SPEC[*]}"
echo "SUMZ_1    : ${SUMZ_1[*]}"
echo "SUMZ_N    : ${SUMZ_N[*]}"
echo "NX        : $NX"
echo "NY        : $NY"
echo "NSEP      : $NSEP"
echo "NMP_I     : $NMP_I"
echo "NMP_O     : $NMP_O"
echo "NNISO     : $NNISO"
echo "NXC_I     : $NXC_I"
echo "NXC_O     : $NXC_O"
echo "SUMZ_ALL_I: $SUMZ_ALL_I"
echo "SUMZ_ALL_F: $SUMZ_ALL_F"

# Old default:
#BB='-6.5 zmin -2.5 zmax 4.5 rmin 8.5 rmax'

unset BB SB
[ -s box.b2p ] && [ -r box.b2p ] && {
  { case "`head -1 box.b2p`" in
    ( \#* )
      grep -v '^#' box.b2p |&
      i=0
      while let 'i=i+1'; do {
        read -p u || break
        set -- $u
        [ -n "$4" ] && u="$2 zmin $4 zmax $1 rmin $3 rmax" || print -u2 "Wrong format of box.b2p - line $i"
        BB[i]="$u"
        SB[i]=$5
        KW[i]=$6
      }; done
      ;;
    ( *  )
      set -- `tail -1l box.b2p`
      [ -n "$4" ] && BB="$2 zmin $4 zmax $1 rmin $3 rmax" || print -u2 "Wrong format of box.b2p";;
  esac; }
}
echo "BB :"
ib=0
for f in "${BB[@]}"; do
  [ -n "${BB[1]}" ] && let 'ib=ib+1'
  echo -e "\t$f\t\t:  ${SB[ib]}\t:  ${KW[ib]}"
done

#Write the data to VarID file so dont have to invoke script next time
ff=.VarID
echo "LL=\"$LL\""                    > "$ff"
echo "L=$L"                          >>"$ff"
echo "NSPEC=$NSPEC"                  >>"$ff"
echo "NS=$NS"                        >>"$ff"
k=0
until [ $k -eq "$NSPEC" ]; do {
  let "k=k+1"
  echo "SPEC[$k]=${SPEC[k]}"         >>"$ff"
  echo "SUMZ_1[$k]=${SUMZ_1[k]}"     >>"$ff"
  echo "SUMZ_N[$k]=${SUMZ_N[k]}"     >>"$ff"
}; done
echo "NX=$NX"                        >>"$ff"
echo "NY=$NY"                        >>"$ff"
echo "NSEP=$NSEP"                    >>"$ff"
echo "NMP_I=$NMP_I"                  >>"$ff"
echo "NMP_O=$NMP_O"                  >>"$ff"
echo "NNISO=$NNISO"                  >>"$ff"
echo "NXC_I=$NXC_I"                  >>"$ff"
echo "NXC_O=$NXC_O"                  >>"$ff"
echo "NXT_I=$NXT_I"                  >>"$ff"
echo "NXT_O=$NXT_O"                  >>"$ff"
echo "NTP_I=$NTP_I"                  >>"$ff"
echo "NTP_O=$NTP_O"                  >>"$ff"
echo "SUMZ_ALL_I=\"$SUMZ_ALL_I\""    >>"$ff"
echo "SUMZ_ALL_F=\"$SUMZ_ALL_F\""    >>"$ff"
k=0
[ -n "${BB[1]}" ] || echo "BB="      >>"$ff"
for f in "${BB[@]}"; do
  [ -n "${BB[1]}" ] && let 'k=k+1'
  echo "BB[$k]=\"${BB[$k]}\""           >>"$ff"
  echo "KW[$k]=\"${KW[$k]}\""           >>"$ff"
done

[ -s "$ff" ] && echo "$ff written"
