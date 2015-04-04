a4l
writ sep comp

dvue 1 nreg m* sumx sumy 'dvue core'           0 0 outp drop
dvua 1 nreg m* sumx sumy 'dvua core'           0 0 outp drop
visa 1 nreg m* sumx sumy 'visa core'           0 0 outp drop
joul 1 nreg m* sumx sumy 'joul core'           0 0 outp drop
rqae 1 nreg m* sumx sumy 'rqae core'           0 0 outp drop

dhet 'dfhet' extl surf 
dfhe 'dfhe' extl surf 
m- 'dfhet - dfhe' extl surf drop
dhit 'dfhit' extl surf 
dfhi 'dfhi' extl surf 
m- 'dfhit - dfhi' extl surf drop
ree 'resee' extl surf drop
rei 'resei' extl surf drop
visa '' extl surf drop

bvis 0 0 sumz psx vol m* 'bvis/sx*vol' extl surf                           ! 
  'bvis.term' '4regsumoutp' cmd
ua ddx hx m* cvsx m* ddx hx m* ua m* psx vol m* 'bas' extl 0 0 sumz surf   ! 
  'bas.term' '4regsumoutp' cmd
m- 'bvis-bas' extl surf
  'bvis-bas.term' '4regsumoutp' cmd
drop
0 smav ua m* psx vol m* 'smav.ua' extl 0 0 sumz surf drop

'' extl ! eof

ebal surf
  'energy balance' '4regsumoutp' cmd
  drop
ebld surf
  'energy balance (div)' '4regsumoutp' cmd
  drop
ebls surf
  'energy balance (src)' '4regsumoutp' cmd
  drop

logf 3 ndec
pbal surf chs surf drop
ebal surf chs surf drop

linf

dhet 'dfhet' extl surf 
  'dfhet' '4regsumoutp' cmd
dhit 'dfhit' extl surf
  'dfhit' '4regsumoutp' cmd
  m+
dfhj 'dfhj' extl surf
  'dfhj' '4regsumoutp' cmd
  m+
dfhm 'dfhm' extl surf 0 0 sumz surf
  'dfhm' '4regsumoutp' cmd
  m+
dfhp 'dfhp' extl surf 0 0 sumz surf
  'dfhp' '4regsumoutp' cmd
  m+
'dfhet+dfhit+dfhj+dfhm+dfhp' extl surf
  'df' '4regsumoutp' cmd

dup
dvue dvua m+ visa m+ joul m+ rqae 0 0 sumz m- 
  '(dvue + dvua + visa + joul - rqa)' extl surf
m- 'dfhet+dfhit+dfhj+dfhm+dfhp - (dvue + dvua + visa + joul - rqa)' extl 
  surf drop



dfch po m* 'dfch.po' extl surf m-
dfmo ua m* 'dfmo.ua' extl surf 0 0 sumz surf m-
dfna 0.5 rm* mi m* ua dup m* m* 'dfna. 0.5 m ua^2' extl surf 0 0 sumz surf m+
dfna pot m* qe rm* 'dfna. pot qe' extl surf 0 0 sumz surf m-
rqae '' extl surf 0 0 sumz surf m-
surf
  '(***) energy balance' '4regsumoutp' cmd
  drop

ebal surf drop

dfhp 'dfhp' extl surf 0 0 sumz surf drop



linf

ua ddx cvsx m* ddx ua m* psx vol m* 'bas' extl surf 0 0 sumz surf
  'bas.term' '4regsumoutp' cmd

0 smav ua m* 'smav.ua' extl surf 0 0 sumz surf
  'smav.ua' '4regsumoutp' cmd

m-
'bas-smav.ua' extl surf
  '(bas-smav.ua) energy balance' '4regsumoutp' cmd
  drop

eof

bvis 0 0 sumz 'bvis.ua' ua m* extl surf                     ! psx vol m* '
  'bvis.ua.term' '4regsumoutp' cmd
              psx vol m* 'bvis/sx*vol.ua' extl surf                     ! 
  'bvis/sx*vol.ua.term' '4regsumoutp' cmd
visa '' extl surf
  'visa' '4regsumoutp' cmd
m- 'bvis.ua.term - visa' surf
  'bvis.ua.term-visa' '4regsumoutp' cmd
  drop
