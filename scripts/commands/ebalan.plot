write a4p 1 2 page comp 2.0 lbsz sep
fhex surf drop
fhey surf drop
fhix surf drop
fhiy surf drop
fhmx surf drop
fhmy surf drop
fhpx surf drop
fhpy surf drop
fhtx surf drop
fhty surf drop
ebal surf 
dup 1 nreg m* sumx sumy 'integrated energy balance core' 0 0 outp drop
dup 2 nreg m* sumx sumy 'integrated energy balance SOL' 0 0 outp drop
dup 3 nreg m* sumx sumy 'integrated energy balance inner' 0 0 outp drop
dup 4 nreg m* sumx sumy 'integrated energy balance outer' 0 0 outp drop
dup 3 nreg 4 nreg m+ m* sumx sumy 'integrated energy balance tot divertor' 0 0 outp drop
dup sumx sumy 'integrated energy balance total' 0 0 outp drop
ree surf
rei surf
m+ 'ree + rei' extl surf
rco pot m* ev rm* 0 0 sumz 'potential energy residual' extl surf
rmo 0.5 rm* ua m* 0 0 sumz 'kinetic energy residual' extl surf
m+ m+ 'total energy residuals' extl surf drop
' ' extl
rsan 0.0 fmin 0.0 fmax surf drop
rran 0.0 fmin 0.0 fmax surf drop
rrai 0.0 fmin 0.0 fmax surf drop
rsai 0.0 fmin 0.0 fmax surf drop
rcxn 0.0 fmin 0.0 fmax surf drop
rcxi 0.0 fmin 0.0 fmax surf drop

 