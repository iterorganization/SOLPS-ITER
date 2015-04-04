a4l
writ sep comp

pbal surf 
  dup 1 nreg m* sumx sumy 'particle balance core'           0 0 outp drop 
  dup 2 nreg m* sumx sumy 'particle balance sol'            0 0 outp drop 
  dup 3 nreg m* sumx sumy 'particle balance inner divertor' 0 0 outp drop 
  dup 4 nreg m* sumx sumy 'particle balance outer divertor' 0 0 outp drop 
  dup sumx sumy 'particle balance sum' 0 0 outp drop

logf 3 ndec
surf
chs surf
drop
