a4l
writ sep comp

ebal surf
  dup 1 nreg m* sumx sumy 'energy balance core'           0 0 outp drop 
  dup 2 nreg m* sumx sumy 'energy balance sol'            0 0 outp drop 
  dup 3 nreg m* sumx sumy 'energy balance inner divertor' 0 0 outp drop 
  dup 4 nreg m* sumx sumy 'energy balance outer divertor' 0 0 outp drop 
  sumx sumy 'energy balance sum' 0 0 outp drop
ebld surf
  dup 1 nreg m* sumx sumy 'energy balance (div) core'           0 0 outp drop 
  dup 2 nreg m* sumx sumy 'energy balance (div) sol'            0 0 outp drop 
  dup 3 nreg m* sumx sumy 'energy balance (div) inner divertor' 0 0 outp drop 
  dup 4 nreg m* sumx sumy 'energy balance (div) outer divertor' 0 0 outp drop 
  sumx sumy 'energy balance (div) sum' 0 0 outp drop
ebls surf
  dup 1 nreg m* sumx sumy 'energy balance (src) core'           0 0 outp drop 
  dup 2 nreg m* sumx sumy 'energy balance (src) sol'            0 0 outp drop 
  dup 3 nreg m* sumx sumy 'energy balance (src) inner divertor' 0 0 outp drop 
  dup 4 nreg m* sumx sumy 'energy balance (src) outer divertor' 0 0 outp drop 
  sumx sumy 'energy balance (src) sum' 0 0 outp drop

dhet 'dfhet' extl surf 
  dup 1 nreg m* sumx sumy 'dfhet core'           0 0 outp drop 
  dup 2 nreg m* sumx sumy 'dfhet sol'            0 0 outp drop 
  dup 3 nreg m* sumx sumy 'dfhet inner divertor' 0 0 outp drop 
  dup 4 nreg m* sumx sumy 'dfhet outer divertor' 0 0 outp drop 
  dup           sumx sumy 'dfhet sum' 0 0 outp drop                  m+
dhit 'dfhit' extl surf
  dup 1 nreg m* sumx sumy 'dfhit core'           0 0 outp drop 
  dup 2 nreg m* sumx sumy 'dfhit sol'            0 0 outp drop 
  dup 3 nreg m* sumx sumy 'dfhit inner divertor' 0 0 outp drop 
  dup 4 nreg m* sumx sumy 'dfhit outer divertor' 0 0 outp drop 
  dup           sumx sumy 'dfhit sum' 0 0 outp drop                  m+
dfhj 'dfhj' extl surf
  dup 1 nreg m* sumx sumy 'dfhj core'           0 0 outp drop 
  dup 2 nreg m* sumx sumy 'dfhj sol'            0 0 outp drop 
  dup 3 nreg m* sumx sumy 'dfhj inner divertor' 0 0 outp drop 
  dup 4 nreg m* sumx sumy 'dfhj outer divertor' 0 0 outp drop 
  dup           sumx sumy 'dfhj sum' 0 0 outp drop                  m+
dfhm 'dfhm' extl surf 0 0 sumz surf
  dup 1 nreg m* sumx sumy 'dfhm core'           0 0 outp drop 
  dup 2 nreg m* sumx sumy 'dfhm sol'            0 0 outp drop 
  dup 3 nreg m* sumx sumy 'dfhm inner divertor' 0 0 outp drop 
  dup 4 nreg m* sumx sumy 'dfhm outer divertor' 0 0 outp drop 
  dup           sumx sumy 'dfhm sum' 0 0 outp drop                  m+
dfhp 'dfhp' extl surf 0 0 sumz surf
  dup 1 nreg m* sumx sumy 'dfhp core'           0 0 outp drop 
  dup 2 nreg m* sumx sumy 'dfhp sol'            0 0 outp drop 
  dup 3 nreg m* sumx sumy 'dfhp inner divertor' 0 0 outp drop 
  dup 4 nreg m* sumx sumy 'dfhp outer divertor' 0 0 outp drop 
  dup           sumx sumy 'dfhp sum' 0 0 outp drop                  m+
'dfhet+dfhit+dfhj+dfhm+dfhp' extl surf
  dup 1 nreg m* sumx sumy 'df core'           0 0 outp drop 
  dup 2 nreg m* sumx sumy 'df sol'            0 0 outp drop 
  dup 3 nreg m* sumx sumy 'df inner divertor' 0 0 outp drop 
  dup 4 nreg m* sumx sumy 'df outer divertor' 0 0 outp drop 
  dup           sumx sumy 'df sum' 0 0 outp drop

ebld '' extl surf
m+ 'dfhet+dfhit+dfhj+dfhm+dfhp + ebld' extl surf

'' extl
dfmo surf ua m* 'dfmo . ua' extl surf 0 0 sumz surf
ebld '' extl surf 
m- 'dfmo . ua - ebld' extl surf
drop

'' extl
dfna surf ua m* ua m* mi m* 'dfna . ua^2' extl surf 0 0 sumz surf
ebld '' extl surf 
m- 'dfna . ma . ua^2 - ebldl' extl surf
drop

'' extl
dfhe surf dfhet surf m- surf drop
dfhi surf dfhit surf m- surf drop

dfhe 'dfhe' extl surf 
  dup 1 nreg m* sumx sumy 'dfhe core'           0 0 outp drop 
  dup 2 nreg m* sumx sumy 'dfhe sol'            0 0 outp drop 
  dup 3 nreg m* sumx sumy 'dfhe inner divertor' 0 0 outp drop 
  dup 4 nreg m* sumx sumy 'dfhe outer divertor' 0 0 outp drop 
  dup           sumx sumy 'dfhe sum' 0 0 outp drop                  m+
dfhi 'dfhi' extl surf
  dup 1 nreg m* sumx sumy 'dfhi core'           0 0 outp drop 
  dup 2 nreg m* sumx sumy 'dfhi sol'            0 0 outp drop 
  dup 3 nreg m* sumx sumy 'dfhi inner divertor' 0 0 outp drop 
  dup 4 nreg m* sumx sumy 'dfhi outer divertor' 0 0 outp drop 
  dup           sumx sumy 'dfhi sum' 0 0 outp drop                  m+
dfhj 'dfhj' extl surf
  dup 1 nreg m* sumx sumy 'dfhj core'           0 0 outp drop 
  dup 2 nreg m* sumx sumy 'dfhj sol'            0 0 outp drop 
  dup 3 nreg m* sumx sumy 'dfhj inner divertor' 0 0 outp drop 
  dup 4 nreg m* sumx sumy 'dfhj outer divertor' 0 0 outp drop 
  dup           sumx sumy 'dfhj sum' 0 0 outp drop                  m+
dfhm 'dfhm' extl surf 0 0 sumz surf
  dup 1 nreg m* sumx sumy 'dfhm core'           0 0 outp drop 
  dup 2 nreg m* sumx sumy 'dfhm sol'            0 0 outp drop 
  dup 3 nreg m* sumx sumy 'dfhm inner divertor' 0 0 outp drop 
  dup 4 nreg m* sumx sumy 'dfhm outer divertor' 0 0 outp drop 
  dup           sumx sumy 'dfhm sum' 0 0 outp drop                  m+
dfhp 'dfhp' extl surf 0 0 sumz surf
  dup 1 nreg m* sumx sumy 'dfhp core'           0 0 outp drop 
  dup 2 nreg m* sumx sumy 'dfhp sol'            0 0 outp drop 
  dup 3 nreg m* sumx sumy 'dfhp inner divertor' 0 0 outp drop 
  dup 4 nreg m* sumx sumy 'dfhp outer divertor' 0 0 outp drop 
  dup           sumx sumy 'dfhp sum' 0 0 outp drop                  m+
'dfhe+dfhi+dfhj+dfhm+dfhp' extl surf
  dup 1 nreg m* sumx sumy 'df core'           0 0 outp drop 
  dup 2 nreg m* sumx sumy 'df sol'            0 0 outp drop 
  dup 3 nreg m* sumx sumy 'df inner divertor' 0 0 outp drop 
  dup 4 nreg m* sumx sumy 'df outer divertor' 0 0 outp drop 
  dup           sumx sumy 'df sum' 0 0 outp drop
drop

'' extl
fhex surf
fhetx surf
m- surf drop
fhey surf
fhety surf
m- surf drop
fhix surf
fhitx surf
m- surf drop
fhiy surf
fhity surf
m- surf drop

fhpx surf drop
fhpy surf drop
fhmx surf drop
fhmy surf drop
fhjx surf drop
fhjy surf drop
