trgdrop phys zero sep

fhey 1 nreg 2 nreg m+ m* sumx
'Radial electron energy flux (W)' glbl
0.0 fmin 0.0 fmax jxa f.y

fhiy 1 nreg 2 nreg m+ m* sumx
'Radial ion energy flux (W)' glbl
0.0 fmin 0.0 fmax jxa f.y

m+
'Radial total energy flux (W)' glbl
0.0 fmin 0.0 fmax jxa f.y
drop

0 she
'Electron energy 0 sources (W)' glbl
0.0 fmin 0.0 fmax jxa f.y

1 she te ev rm* m*
'Electron energy 1 sources (W)' glbl
0.0 fmin 0.0 fmax jxa f.y
m+

2 she ne m*
'Electron energy 2 sources (W)' glbl
0.0 fmin 0.0 fmax jxa f.y
m+

3 she ne m* te ev rm* m*
'Electron energy 3 sources (W)' glbl
0.0 fmin 0.0 fmax jxa f.y
m+

rlcl m* 1 nreg 2 nreg m+ m* sumx
'Electron energy sources (W)' glbl
0.0 fmin 0.0 fmax jxa f.y

0 shi
'Ion energy 0 sources (W)' glbl
0.0 fmin 0.0 fmax jxa f.y

1 shi ti ev rm* m*
'Ion energy 1 sources (W)' glbl
0.0 fmin 0.0 fmax jxa f.y
m+

2 shi na 0 0 sumz m*
'Ion energy 2 sources (W)' glbl
0.0 fmin 0.0 fmax jxa f.y
m+

3 shi na 0 0 sumz m* ti ev rm* m*
'Ion energy 3 sources (W)' glbl
0.0 fmin 0.0 fmax jxa f.y
m+

rlcl m* 1 nreg 2 nreg m+ m* sumx
'Ion energy sources (W)' glbl
0.0 fmin 0.0 fmax jxa f.y

m+
'Total energy sources (W)' glbl
0.0 fmin 0.0 fmax jxa f.y
drop

brhe
rlcl m* 1 nreg 2 nreg m+ m* sumx
'Recycling electron energy source (W)' glbl
0.0 fmin 0.0 fmax jxa f.y

brhi
rlcl m* 1 nreg 2 nreg m+ m* sumx
'Recycling ion energy source (W)' glbl
0.0 fmin 0.0 fmax jxa f.y

m+
'Total recycling energy sources (W)' glbl
0.0 fmin 0.0 fmax jxa f.y
drop

dvue
rlcl m* 1 nreg 2 nreg m+ m* sumx
'Div ue term (W)' glbl
0.0 fmin 0.0 fmax jxa f.y

dvua
rlcl m* 1 nreg 2 nreg m+ m* sumx
'Div ua term (W)' glbl
0.0 fmin 0.0 fmax jxa f.y
m+

visa
rlcl m* 1 nreg 2 nreg m+ m* sumx
'Visa term (W)' glbl
0.0 fmin 0.0 fmax jxa f.y
m+

joul
rlcl m* 1 nreg 2 nreg m+ m* sumx
'Joule heating term (W)' glbl
0.0 fmin 0.0 fmax jxa f.y
m+

fraa
rlcl m* 1 nreg 2 nreg m+ m* sumx
'Friction heating term (W)' glbl
0.0 fmin 0.0 fmax jxa f.y
m+

str
rlcl m* 1 nreg 2 nreg m+ m* sumx
'Strange heating term (W)' glbl
0.0 fmin 0.0 fmax jxa f.y
m+

'Total b2sihs contributions (W)' glbl
0.0 fmin 0.0 fmax jxa f.y
drop
