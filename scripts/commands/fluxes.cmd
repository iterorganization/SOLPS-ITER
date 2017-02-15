zero sep phys
2 2 page
1.5 lbsz 3 lfsz 2.5 lwid
aspc trgdrop

same

fnax za m* 0 0 sumz te m* ev rm* fhex m+
bb bpol m/ abs m* psxperp
'1: Electron heat flux 2: Qe_BC (W/m^{2})' glbl
16 dcol
chs 0.0 fmin 3.0e7 fmax 'Inner target' extl -1 f.y
drop

pr ro 0 0 sumz m/ sqrt ne m* ev rm* fchx m+
te m* po te m/ 2.5 rm+ m*
5 dcol
-1 f.y
drop

new same

fhix ev ti rm* fnax 0 0 sumz m* m+
mi fnax m* ua m* ua m* 0.5 rm* 0 0 sumz m+
bb bpol m/ abs m* psxperp
'1: Ion heat flux 2: Qi_BC (W/m^{2})' glbl
16 dcol
chs 0.0 fmin 1.0e7 fmax 'Inner target' extl -1 f.y
drop

pr ro 0 0 sumz m/ sqrt ni 1 zsel m* 
ti m* ev rm* po te m/ 0.9 rm+ m* 1.5 rm*
5 dcol
-1 f.y
drop

new same

fnax za m* 0 0 sumz te m* ev rm* fhex m+
bb bpol m/ abs m* psxperp
'1: Electron heat flux 2: Qe_BC (W/m^{2})' glbl
16 dcol
0.0 fmin 3.0e7 fmax 'Outer target' extl nx f.y
drop

pr ro 0 0 sumz m/ sqrt ne m* ev rm* fchx m-
te m* po te m/ 2.5 rm+ m*
5 dcol
nx f.y
drop

new same

fhix ev ti rm* fnax 0 0 sumz m* m+
mi fnax m* ua m* ua m* 0.5 rm* 0 0 sumz m+
bb bpol m/ abs m* psxperp
'1: Ion heat flux 2: Qi_BC (W/m^{2})' glbl
16 dcol
0.0 fmin 0.0 fmax 'Outer target' extl nx f.y

pr ro 0 0 sumz m/ sqrt
ti m* ev rm* ni 1 zsel m* po te m/ 0.9 rm+ m* 1.5 rm*
5 dcol
nx f.y

