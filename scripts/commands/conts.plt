'${HOST} ${PWD} `date` T=${TIME}' extl glob
a4p
2 2 page
phys vesl
clvl lbof sep
1.5 rmin 1.7 rmax -1.05 zmin -0.85 zmax ! outer plate
1.1 rmin 1.8 rmax -1.0 zmin -0.8 zmax ! both plates
logf
b2nn pvol 1 1 sumz abs 0.0 fmin 0.0 fmax surf drop
b2nn pvol 2 2 sumz 0.0 fmin 0.0 fmax surf drop
b2nn pvol 8 8 sumz 0.0 fmin 0.0 fmax surf drop
b2nn pvol 18 18 sumz 0.0 fmin 0.0 fmax surf drop
logf
! fnix 1 1 sumz dup 1e14 fmin 1e23 fmax 'Positive FNIX' extl cont drop chs 1e14 fmin 1e23 fmax 'Negative FNIX' extl cont drop
! fnix 2 7 sumz dup 1e14 fmin 1e23 fmax 'Positive FNIX' extl cont drop chs 1e14 fmin 1e23 fmax 'Negative FNIX' extl cont drop
! fnix 8 17 sumz dup 1e14 fmin 1e23 fmax 'Positive FNIX' extl cont drop chs 1e14 fmin 1e23 fmax 'Negative FNIX' extl cont drop
! fnix 18 19 sumz dup 1e14 fmin 1e23 fmax 'Positive FNIX' extl cont drop chs 1e14 fmin 1e23 fmax 'Negative FNIX' extl cont drop
linf '' extl
b2ra pvol abs 11 1.0e4 5.0e4 1.0e5 5.0e5 1.0e6 2.0e6 5.0e6 1.0e7 2.0e7 5.0e7 1.0e8 clvs surf drop
b2ne pvol abs 11 0.0 2.5e5 5.e5 7.5e5 1.e6 1.25e6 1.5e6 1.75e6 2.0e6 2.25e6 2.5e6 clvs surf drop
b2ni pvol 11 -8.0e5 -6.0e5 -4.0e5 -2.0e5 -1.0e5 0.0 1.0e5 2.0e5 4.0e5 6.0e5 8.0e5 clvs surf drop
b2nn pvol 1 1 sumz 10 0.0 2.5e21 5.0e21 7.5e21 1.0e22 2.5e22 5.0e22 7.5e22 1.0e23 2.5e23 clvs surf drop
b2nn pvol 1 1 sumz 10 0.0 -2.5e21 -5.0e21 -7.5e21 -1.0e22 -2.5e22 -5.0e22 -7.5e22 -1.0e23 -2.5e23 clvs surf drop
logf 0 clvs
ahal 0.0 fmin 0.0 fmax surf drop
