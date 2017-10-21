'${HOST} ${PWD} `date` T=${TIME}' extl glob

a4p 2 3 page phys 2.0 lbsz

clvl lbof

1.0 xref -0.10 omin 0.0 omax

rsan rran m- brna m+ pvol linf
same dup 1  1 zrng -1e25 fmin 1e26 fmax 20 f.x drop new
same dup 8 17 zrng -1e21 fmin 1e22 fmax 20 f.x drop new
same 18 19 zrng -1e18 fmin 1e19 fmax 20 f.x drop new

na linf
same dup 1  1 zrng 2e20 fmax 20 f.x drop new !was 1e20
same dup 8 17 zrng 6e16 fmax 20 f.x drop new !was 3e16
same 18 19 zrng 3e13 fmax 20 f.x drop new

same '(1) smpt, (2) smpr, (3) smth, (4) smfr, (5) sum' extl
smpt na vol m* mi m* m/ 1 1 sumz -2.0e9 fmin 2.0e9 fmax 20 f.x
smpr na vol m* mi m* m/ 1 1 sumz -2.0e9 fmin 2.0e9 fmax 20 f.x
smth na vol m* mi m* m/ 1 1 sumz -2.0e9 fmin 2.0e9 fmax 20 f.x
smfr na vol m* mi m* m/ 1 1 sumz -2.0e9 fmin 2.0e9 fmax 20 f.x
m+                      -2.0e9 fmin 2.0e9 fmax 20 f.x new drop

same '(1) smpt, (2) smpr, (3) smth, (4) smfr, (5) sum' extl
smpt na vol m* mi m* m/ 10 10 sumz -2.0e9 fmin 2.0e9 fmax 20 f.x
smpr na vol m* mi m* m/ 10 10 sumz -2.0e9 fmin 2.0e9 fmax 20 f.x
smth na vol m* mi m* m/ 10 10 sumz -2.0e9 fmin 2.0e9 fmax 20 f.x
smfr na vol m* mi m* m/ 10 10 sumz -2.0e9 fmin 2.0e9 fmax 20 f.x
m+                          -2.0e9 fmin 2.0e9 fmax 20 f.x new drop

quit

0.0 fmin 0.0 fmax 20 f.x

na zi zi m* m* ne m/
dup  1  1 sumz 20 f.x drop
dup  2  7 sumz 20 f.x drop
dup  8 17 sumz 0.0 fmin 0.05 fmax 20 f.x drop
    18 19 sumz 20 f.x drop

rsan rran m- brna m+ pvol 0.0 fmin 0.0 fmax 30 f.x

na zi zi m* m* ne m/
dup  1  1 sumz 30 f.x drop
dup  2  7 sumz 30 f.x drop
dup  8 17 sumz 0.0 fmin 0.05 fmax 30 f.x drop
    18 19 sumz 30 f.x drop

quit

same 'smth' extl smth na vol m* mi m* zi zi m* m* m/ -2.0e9 fmin 2.0e9 fmax 30 f.x new
same 'smfr' extl smfr na vol m* mi m* zi zi m* m* m/ -2.0e9 fmin 2.0e9 fmax 30 f.x new

same 'smpt, smpr, smth, smfr, sum' extl
smpt na vol m* mi m* m/ 1 1 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smpr na vol m* mi m* m/ 1 1 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smth na vol m* mi m* m/ 1 1 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smfr na vol m* mi m* m/ 1 1 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
m+                               -2.0e9 fmin 2.0e9 fmax 30 f.x new drop
same 'smpt, smpr, smth, smfr, sum' extl
smpt na vol m* mi m* m/ 8 8 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smpr na vol m* mi m* m/ 8 8 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smth na vol m* mi m* m/ 8 8 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smfr na vol m* mi m* m/ 8 8 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
m+                               -2.0e9 fmin 2.0e9 fmax 30 f.x new drop
same 'smpt, smpr, smth, smfr, sum' extl
smpt na vol m* mi m* m/ 9 9 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smpr na vol m* mi m* m/ 9 9 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smth na vol m* mi m* m/ 9 9 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smfr na vol m* mi m* m/ 9 9 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
m+                               -2.0e9 fmin 2.0e9 fmax 30 f.x new drop
same 'smpt, smpr, smth, smfr, sum' extl
smpt na vol m* mi m* m/ 10 10 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smpr na vol m* mi m* m/ 10 10 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smth na vol m* mi m* m/ 10 10 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smfr na vol m* mi m* m/ 10 10 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
m+                                 -2.0e9 fmin 2.0e9 fmax 30 f.x new drop
same 'smpt, smpr, smth, smfr, sum' extl
smpt na vol m* mi m* m/ 11 11 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smpr na vol m* mi m* m/ 11 11 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smth na vol m* mi m* m/ 11 11 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smfr na vol m* mi m* m/ 11 11 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
m+                                 -2.0e9 fmin 2.0e9 fmax 30 f.x new drop
same 'smpt, smpr, smth, smfr, sum' extl
smpt na vol m* mi m* m/ 12 12 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smpr na vol m* mi m* m/ 12 12 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smth na vol m* mi m* m/ 12 12 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smfr na vol m* mi m* m/ 12 12 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
m+                            sumz -2.0e9 fmin 2.0e9 fmax 30 f.x new drop
same 'smpt, smpr, smth, smfr, sum' extl
smpt na vol m* mi m* m/ 13 13 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smpr na vol m* mi m* m/ 13 13 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smth na vol m* mi m* m/ 13 13 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smfr na vol m* mi m* m/ 13 13 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
m+                                 -2.0e9 fmin 2.0e9 fmax 30 f.x new drop
same 'smpt, smpr, smth, smfr, sum' extl
smpt na vol m* mi m* m/ 14 14 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smpr na vol m* mi m* m/ 14 14 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smth na vol m* mi m* m/ 14 14 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smfr na vol m* mi m* m/ 14 14 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
m+                                 -2.0e9 fmin 2.0e9 fmax 30 f.x new drop
same 'smpt, smpr, smth, smfr, sum' extl
smpt na vol m* mi m* m/ 15 15 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smpr na vol m* mi m* m/ 15 15 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smth na vol m* mi m* m/ 15 15 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smfr na vol m* mi m* m/ 15 15 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
m+                                 -2.0e9 fmin 2.0e9 fmax 30 f.x new drop
same 'smpt, smpr, smth, smfr, sum' extl
smpt na vol m* mi m* m/ 16 16 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smpr na vol m* mi m* m/ 16 16 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smth na vol m* mi m* m/ 16 16 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smfr na vol m* mi m* m/ 16 16 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
m+                                 -2.0e9 fmin 2.0e9 fmax 30 f.x new drop
same 'smpt, smpr, smth, smfr, sum' extl
smpt na vol m* mi m* m/ 17 17 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smpr na vol m* mi m* m/ 17 17 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smth na vol m* mi m* m/ 17 17 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smfr na vol m* mi m* m/ 17 17 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
m+                                 -2.0e9 fmin 2.0e9 fmax 30 f.x new drop
same 'smpt, smpr, smth, smfr, sum' extl
smpt na vol m* mi m* m/ 18 18 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smpr na vol m* mi m* m/ 18 18 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smth na vol m* mi m* m/ 18 18 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smfr na vol m* mi m* m/ 18 18 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
m+                                 -2.0e9 fmin 2.0e9 fmax 30 f.x new drop
same 'smpt, smpr, smth, smfr, sum' extl
smpt na vol m* mi m* m/ 19 19 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smpr na vol m* mi m* m/ 19 19 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smth na vol m* mi m* m/ 19 19 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
smfr na vol m* mi m* m/ 19 19 sumz -2.0e9 fmin 2.0e9 fmax 30 f.x
m+                                 -2.0e9 fmin 2.0e9 fmax 30 f.x new drop

quit

writ

1.0 xref -0.10 omin 0.0 omax linf
same 'smpt' extl smpt na vol m* mi m* m/ -1.0e11 fmin 1.0e11 fmax 30 f.x new
same 'smpr' extl smpr na vol m* mi m* m/ -1.0e11 fmin 1.0e11 fmax 30 f.x new
same 'smth' extl smth na vol m* mi m* m/ -1.0e11 fmin 1.0e11 fmax 30 f.x new
same 'smfr' extl smfr na vol m* mi m* m/ -1.0e11 fmin 1.0e11 fmax 30 f.x new
same 'sm sum' extl m+ -1.0e11 fmin 1.0e11 fmax 30 f.x new drop

quit

phys vesl 1.1 rmin 1.9 rmax -0.7 zmax -1.2 zmin sep
1.0 xref -0.10 omin 0.0 omax logf 5 ndec
same 'smpt' extl smpt na vol m* mi m* m/ 30 f.x new
same 'smpr' extl smpr na vol m* mi m* m/ 30 f.x new
same 'smth' extl smth na vol m* mi m* m/ 30 f.x new
same 'smfr' extl smfr na vol m* mi m* m/ 30 f.x new
same 'sm sum' extl m+ 30 f.x new drop


