a4l
writ sep comp

dfhe surf 
dfhi surf 
  m+ 'div = dfhe + dfhi' extl surf '' extl
  'dfhe+dfhi' '4regsumoutp' cmd
dvue surf 
dvua surf m+ 
visa surf m+ 
joul surf m+ 
fraa surf m+ 
rqae 0 0 sumz surf m- 
rsai 0 0 sumz surf m+ 
rrai 0 0 sumz surf m+ 
rcxi 0 0 sumz surf m+
  'srcs = dvue + dvua + visa + joul + fraa - rqae + rsai + rrai + rcxi' extl surf 
  'srcs' '4regsumoutp' cmd
  m- '(div) - (srcs)' extl surf
  'div-srcs' '4regsumoutp' cmd

ree 'resee' extl surf 
rei 'resei' extl surf 
m+ 'res = resee + resei' extl surf
  'res' '4regsumoutp' cmd

m+ '(div) - (srcs) + (res)' extl surf
  'div-srcs+res core' '4regsumoutp' cmd
drop '' extl