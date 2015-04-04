stdl glob 1.5 lbsz 
phys vesl sep outl 
logf 3 ndec
a4l 1.1 rmin 1.7 rmax -1.1 zmin -0.6 zmax 
te surf drop
ti surf drop
ne surf drop
ahal mhal m+ 4.0 pi r* rm/ 'ahal+mhal' extl surf drop
'halpha.5' cmd 4.0 pi r* rm/ surf drop
'hbeta.5' cmd 4.0 pi r* rm/ surf drop
'hgamma.5' cmd 4.0 pi r* rm/ surf drop
eirc 
0 6561 1 nspec '656.1 nm D0' extl surf drop
0 4861 1 nspec '486.1 nm D0' extl surf drop
0 4340 1 nspec '434.0 nm D0' extl surf drop
3 6581 1 nspec '658 nm CII'  extl surf drop
4 4650 1 nspec '465 nm CIII' extl surf drop
