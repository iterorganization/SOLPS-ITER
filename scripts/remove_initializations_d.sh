#! /bin/csh -f
# this scripts removes the initialization to 0.0_R8 of differentiated variables in b2mod_driver_diff.F90. 
# If this is not done then run continuation with AD b2fdiff* files is not possible, i.e. each time the diff'ed quantities will start from zero.
set num = `egrep -c -ai "cfrure" read_plasma_state_diff.F` #number of times a variable is read from the diff'ed state file
set ii = 1
while ( $ii <= $num )
   set lstart = `egrep -i -n "SUBROUTINE B2MNDR_1_D\(" b2mod_driver_diff.F90 | awk '{sub(/:/, "", $1);print $1}'`
   set lend = `egrep -i -n -m 1 "guess the next state" b2mod_driver_diff.F90 | awk -F":" '{print $1}'`
   # read lines with cfrure, take only the ii-th one and record the variable dimension, the field (pl or dv) and the name
   set record = `grep -i "cfrure" read_plasma_state_diff.F | grep -i -v "time" | awk "NR==$ii{print}" | awk '{sub(/,/, "", $9);print $4, $7, $9}'`
   # build variable name concatenating the field and the name
   set v1 = `echo "$record" | awk '{print $2}'`
   set v2 = `echo "$record" | awk '{print $3}'`
   set varname = "stated%$v1%$v2 = 0.0"
   set counts = `egrep -i -c "$varname" b2mod_driver_diff.F90`
   if ($counts > 0) then
     set jj = 1
     while ( $jj <= $counts )
       set ll = `egrep -i -n "$varname" b2mod_driver_diff.F90 | awk "NR==$jj{print}" | awk '{sub(/:/, "", $1);print $1}'`
       if ($ll > $lstart & $ll < $lend) then
         sed -i "$ll"d b2mod_driver_diff.F90
       endif
       @ jj ++
     end
   endif
  @ ii ++
end
