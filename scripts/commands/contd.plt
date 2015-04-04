'${HOST} ${PWD} `date` T=${TIME}' extl glob
'plusminus' cltb
a4p
2 2 page
phys vesl
clvl lbof
1.1 rmin 1.9 rmax -0.7 zmax -1.2 zmin sep

logf
smfr smpr m+ smth m+ pvol
-100.0 -10.0 -1.0 -0.1 -0.01 -0.001 -1e-4
1e-4 0.001 0.01 0.1 1.0 10.0 100.0
14 clvs
cont

quit

logf
smfr smpr m+ smth m+ pvol
-100.0 -50.0 -20.0 -10.0 -5.0 -2.0 -1.0 -0.5 -0.2 -0.1 
-0.01 0.01
0.1 0.2 0.5 1.0 2.0 5.0 10.0 20.0 50.0 100.0
22 clvs
cont

quit

smfr smpr smth m+ m/ 
linf 
dup 1 1 sumz 1.0e-1 fmin 10.0 fmax cont drop
dup 2 2 sumz 1.0e-1 fmin 10.0 fmax cont drop
dup 3 3 sumz 1.0e-1 fmin 10.0 fmax cont drop
dup 8 8 sumz 1.0e-1 fmin 10.0 fmax cont drop
dup 9 9 sumz 1.0e-1 fmin 10.0 fmax cont drop
dup 18 18 sumz 1.0e-1 fmin 10.0 fmax cont drop
dup 19 19 sumz 1.0e-1 fmin 10.0 fmax cont drop
drop
smpr abs pvol logf 0.0 fmin 0.0 fmax cont
drop
smth abs pvol logf 0.0 fmin 0.0 fmax cont
drop
smfr abs pvol logf 0.0 fmin 0.0 fmax cont



