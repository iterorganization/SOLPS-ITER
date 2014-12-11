#  VERSION : 06.06.2005 18:24

# This is a library of ksh functions to be used in solps scripts
# To use it, include a statement ". functions.ksh" in the script.


#===================================================================================================
function get_serial_number {

# Prints the largest serial number found in the filenames following the specified pattern 
# in the specified directory, incremented by 1.
# Usage: get_serial_number [ -d <directory> ] [ -p '<pattern>' ] [ -s <strip> ] [ -l <length> ]
#   The pattern must be quoted to avoid its expansion by the shell. Assumed to be * if not specified.
#   If a relative path, not starting from '.' is specified for the directory, is looked for starting
#   first from the current directory, then from the $SOLPSTOP. The current directory is the default.
#   The strip parameter specifies, how many period-separated fields to be stripped from the right of
#   the filenames.
#   The length parameter specifies the minimum length of the serial number to return, it is left-padded
#   with zeroes, if necessary.

  D_FUN=.
  P_FUN=\*
  S_FUN=0
  L_FUN=1
  while [ -n "$1" ]; do {
    { case $1 in 
      ( -d )  D_FUN="$2"; shift 2;;
      ( -p )  P_FUN="$2"; shift 2;;
      ( -s )  S_FUN="$2"; shift 2;;
      ( -l )  L_FUN="$2"; shift 2;;
      ( -* )  return 10;;
      (  * )  return 11;;
    esac; }
  }; done
  [ -n "$2" ] && return 12
  [ -z "$L_FUN" ] && return 13
  [ -z "$S_FUN" ] && return 14
  [ -z "$P_FUN" ] && return 15
  [ -z "$D_FUN" ] && return 16
  [ 0 -le "$S_FUN" ] || return 17
  [ 0 -le "$L_FUN" ] || return 18
  { case $D_FUN in
    ( /* )  ;;
    ( .* )  ;;
    (  * )  [ -d "./$D_FUN" ] || [ -d "$SOLPSTOP/$D_FUN" ] && D_FUN="$SOLPSTOP/$D_FUN" || return 30;;
  esac; }
  (cd "$D_FUN" || return 32
    F_FUN=`ls -d $P_FUN | sort | tail -1`
    I_FUN=$S_FUN
    while [ 0 -lt $I_FUN ]; do {
      F_FUN=${F_FUN%.*}
      ((I_FUN+=-1))
    }; done
    F_FUN=${F_FUN##*.}
    [ 0 -le "$F_FUN" ] || return 34
    ((F_FUN+=1))
    F_FUN=${F_FUN##*.}
    while [ $L_FUN -gt ${#F_FUN} ]; do F_FUN="0$F_FUN"; done
    print -- "$F_FUN"
  )
  return 0
}

#===================================================================================================
function check_files {

# Returns 0 if all the files are present, readable, and not empty, or 1 if not
# The files to check are specified as parameters

  for F_FUN in "$@"; do {
    [ -s $F_FUN ] && [ -r $F_FUN ] || return 1
  }; done
  return 0
}

#===================================================================================================
function comma_separate {

# Prints a string where the input parameters are comma-separated
# The string is braced by "{.....}", if more than one parameter is included (for the shell expansion)

  [ -z "$1" ] && return
  F_FUN=
  E_FUN=
  while { [ -n "$1" ]; }; do {
    [ -z "$F_FUN" ] && F_FUN="$1" || { F_FUN="$F_FUN,$1"; E_FUN=y; }
    shift
  }; done
  [ -n "$E_FUN" ] && F_FUN="{$F_FUN}"
  print -- "$F_FUN"
  return 0
}
