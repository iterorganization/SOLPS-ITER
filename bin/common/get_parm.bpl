#! /bin/ksh

#  VERSION : 06.03.2001 16:39

# This script extracts some parameters necessary for any script calling b2plot
# It should be invoked in the same shell, i. e. ". get_parm.bpl", and it results
# in assigning the values to the following variables

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
#	              	      	  P for PostScript, g for gmeta, empty for both

# Derived variables

#   SUMZ_ALL_I: b2plot command to sum over all ion species
#   SUMZ_ALL_F: b2plot command to sum over all neutral species


function spec_symbol {
  case "$1" in
    (  1 )  S=$H;;
    (  2 )  S=He;;
    (  4 )  S=Be;;
    (  6 )  S=C_;;
    (  7 )  S=N_;;
    ( 10 )  S=Ne;;
    ( 18 )  S=Ar;;
    (  * )  S=xx;;
  esac
}

# [ -s b2.parameters ] && [ -r b2.parameters ] || {
#   print -u2 "No b2.parameters - cannot proceed"
#   exit 2
# }

file=b2ah.dat
[ -s $file ] && [ -r $file ] || {
  file=../baserun/b2ah.dat
  [ -s $file ] && [ -r $file ] || {  
    print -u2 "No b2ah.dat - cannot proceed"
    exit 2
  }
}

# u=`grep -i -e ' *ns *=' -e '^ns *=' -e ',ns *=' $file | tr [A-Z] [a-z]`
u=`grep -A1 'dimens' $file | paste - -`
u=${u#*dimens}
u=${u#*ns}
u=${u#*format)}
u=${u%%,*}
let "NS=$u"

file=b2fstate
[ -s $file ] && [ -r $file ] || {
  file=b2fstati
  [ -s $file ] && [ -r $file ] || {  
    file=../baserun/b2fstati
    [ -s $file ] && [ -r $file ] || {  
      print -u2 "No b2fstate - cannot proceed"
      exit 2
    }
  }
}

# m=`grep -i -e ' *mi *=' -e '^mi *=' $file | tr , \ `
m=`grep -A$NS '  am' $file | tail -$NS | tr , \ `
# z=`grep -i -e ' *zi *=' -e '^zi *=' $file | tr , \ `
z=`grep -A$NS '  za' $file | tail -$NS | tr , \ `
y=`grep -A$NS '  zn' $file | tail -$NS | tr , \ `
set -A Hiso -- \* H D T
H=D_
[ -n "$m" ] && [ -n "$z" ] && [ -n "$y" ] && {
  unset MI ZI ZN
  i=0; for f in ${m}; do {
    case $f in
      ( *\** ) n=${f%\**}; l=${f#*\*}
               j=0; while { let "j=j+1"; [ $j -le $n ]; }; do {
                 let "i=i+1"; MI[i]=$l
                 [ "$i" -eq "$NS" ] && break 2
               }; done;;
      (  *   ) let "i=i+1"; MI[i]=$f; [ "$i" -eq "$NS" ] && break;;
    esac
  }; done
  i=0; for f in ${z}; do {
    case $f in
      ( *\** ) n=${f%\**}; l=${f#*\*}
               j=0; while { let "j=j+1"; [ $j -eq $n ]; }; do {
                 let "i=i+1"; ZI[i]=$l
                 [ "$i" -eq "$NS" ] && break 2
               }; done;;
      (  *   ) let "i=i+1"; ZI[i]=$f; [ "$i" -eq "$NS" ] && break;;
    esac
  }; done
  i=0; for f in ${y}; do {
    case $f in
      ( *\** ) n=${f%\**}; l=${f#*\*}
               j=0; while { let "j=j+1"; [ $j -eq $n ]; }; do {
                 let "i=i+1"; ZN[i]=$l
                 [ "$i" -eq "$NS" ] && break 2
               }; done;;
      (  *   ) let "i=i+1"; ZN[i]=$f; [ "$i" -eq "$NS" ] && break;;
    esac
  }; done

  i=0; while [ -n "${MI[i]}" ] && [ -n "${ZI[i]}" ] && [ -n "${ZN[i]}" ]; do {
    [ "${ZN[i]}" -eq 1 ] && {
      j=${MI[i]}
      H=${Hiso[j]}_
      break
    }
    let "i=i+1"
  }; done
}

unset NTP_I NTP_O NXT_I NXT_O

# replaced by nx in b2plot
# u=`grep -i -e ' *nx *=' -e '^nx *=' -e ',nx *=' b2.parameters | tr [A-Z] [a-z]`
# u=${u#*nx}
# u=${u#*=}
# u=${u%%,*}
# let "NX=$u"

# replaced by ny in b2plot
# u=`grep -i -e ' *ny *=' -e '^ny *=' -e ',ny *=' b2.parameters | tr [A-Z] [a-z]`
# u=${u#*ny}
# u=${u#*=}
# u=${u%%,*}
# let "NY=$u"

# replaced by jxi in b2plot
# u=`grep -i -e ' *jxi *=' -e '^jxi *=' -e ',jxi *=' b2.parameters | tr [A-Z] [a-z]`
# u=${u#*jxi}
# u=${u#*=}
# u=${u%%,*}
# let "NMP_I=$u"

# replaced by jxa in b2plot
# u=`grep -i -e ' *jxa *=' -e '^jxa *=' -e ',jxa *=' b2.parameters | tr [A-Z] [a-z]`
# u=${u#*jxa}
# u=${u#*=}
# u=${u%%,*}
# let "NMP_O=$u"

file=b2.boundary.parameters
[ -s $file ] && [ -r $file ] && {
  u=`grep -i -e ' *nniso *=' -e '^nniso *=' -e ',nniso *=' $file | tr [A-Z] [a-z]`
  u=${u#*nniso}
  u=${u#*=}
  u=${u%%,*}
  ((NNISO=$u))
  [ -n "$u" ] && [ "$u" -eq 1 ] && {
    u=`grep -i -e ' *nxiso1 *=' -e '^nxiso1 *=' -e ',nxiso1 *=' $file | tr [A-Z] [a-z]`
    u=${u#*nxiso1}
    u=${u#*=}
    u=${u%%,*}
    let "NTP_I=$u-1"
    let "NTP_O=$u+2"
  } || {
  NNISO=0
  NTP_I=-2
  NTP_O=-2
  }
}

# Take the shortest of the first two cuts to find the separatrix location.

# replaced by 'jsep 1 i+' in b2plot
# u=`grep -i -e ' *nycut2 *=' -e '^nycut2 *=' -e ',nycut2 *=' b2.parameters | tr [A-Z], [a-z]\ `
# u=${u#*nycut2}
# u=${u#*=}
# set -- $u
# [ -n "$2" ] && {
#   [ $1 -le $2 ] && let "NSEP=$1+1" || let "NSEP=$2+1"
# } || NSEP=1

file=b2fgmtry
[ -s $file ] && [ -r $file ] || {
  file=../baserun/b2fgmtry
  [ -s $file ] && [ -r $file ] || {  
    print -u2 "No b2fgmtry - cannot proceed"
    exit 2
  }
}

u=`grep -A1 nncut $file | paste - - `
u=${u#*nncut}
[ -n "$u" ] && [ "$u" -eq 2 ] && {
  u=`grep -A1 leftcut $file | paste - - `
  u=${u#*leftcut}
  set -A u ${u%,*}
  let "NXC_I=${u[1]}"
  let "NXT_I=${u[2]}-1"

  u=`grep -A1 rightcut $file | paste - - `
  u=${u#*rightcut}
  set -A u ${u%,*}
  let "NXC_O=${u[1]}-1"
  let "NXT_O=${u[2]}"
} || {
  u=`grep -A1 leftcut $file | paste - - `
  u=${u#*leftcut}
  let "NXC_I=$u"
  let "NXT_I=-2"

  u=`grep -A1 rightcut $file | paste - - `
  u=${u#*rightcut}
  let "NXC_O=$u-1"
  let "NXT_O=-2"
}

unset SUMZ_1 SUMZ_N SPEC

file=b2ar.dat
[ -s $file ] && [ -r $file ] || {
  file=../baserun/b2ar.dat
  [ -s $file ] && [ -r $file ] || {  
    print -u2 "No b2ar.dat - cannot proceed"
    exit 2
  }
}

u=`grep -A1 numnuc $file | paste - - `
u=${u#*format)}
u=${u%%,*}
let "NSPEC=$u"

u=`grep -A$NSPEC nucspec $file | tail -$NS | tr , \ `
u=${u#*line)}
u=${u%%,*}
set -A u ${u%,*}

#           u=`grep -i -e ' *nfluids *=' -e '^nfluids *=' -e ',nfluids *=' b2.parameters | tr [A-Z] [a-z]`
#           u=${u#*nfluids}
#           set -A u -- `echo ${u#*=} | tr , \ `

n=0
i=0; until [ $i -eq "$NSPEC" ]; do {
  f=${u[i*3+1]}
  let "k=n+1"
  let "n=n+f+1"
  SUMZ_1[i]=$k
  let "SUMZ_N[i]=n-1"
  spec_symbol $f
  SPEC[i]="$S"
  let "i=i+1"
  [ "$i" -ge "$NS" ] && break
}; done

unset u f n k i S

SUMZ_ALL_I="za 0.0 mgt m* 0 0 sumz"
SUMZ_ALL_F="0 0 sumz"

echo "NSPEC      : $NSPEC"
echo "NS         : $NS"
echo "SPEC       : ${SPEC[*]}"
echo "SUMZ_1     : ${SUMZ_1[*]}"
echo "SUMZ_N     : ${SUMZ_N[*]}"
# echo "NX         : $NX"
# echo "NY         : $NY"
# echo "NSEP       : $NSEP"
# echo "NMP_I      : $NMP_I"
# echo "NMP_O      : $NMP_O"
echo "NNISO      : $NNISO"
echo "NXC_I      : $NXC_I"
echo "NXC_O      : $NXC_O"
echo "SUMZ_ALL_I : $SUMZ_ALL_I"
echo "SUMZ_ALL_F : $SUMZ_ALL_F"

[ -s VarID ] && [ -r VarID ] && {
  L=`cat VarID | cut -f1 -d_ | cut -f2 -d#`
  LL=`cat VarID | tr _ ' '`
  [ -s time_dep/traces ] && [ time_dep/traces -nt Label ] && write_time_mark
  [ -r Label ] && LL="$LL `cat Label`"
  true
} || {
  L=000
  LL="${PWD#$SOLPSTOP}"
}
echo "LL         : $LL"
echo "L          : $L"

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
echo "BB         :"
ib=0
for f in "${BB[@]}"; do
  [ -n "${BB[1]}" ] && let 'ib=ib+1'
  echo "\t$f\t\t:  ${SB[ib]}\t:  ${KW[ib]}"
done
