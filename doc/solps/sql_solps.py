import pmds
import numpy

pmds.mdsconnect('solps-mdsplus.aug.ipp.mpg.de:8001')
shape=pmds.mdsvalue("shape(_s=sql(\'select solpsindex,shot,time,ompsep_ne,ompsep_te,user,exp from id where ompsep_te>10.0 and ompsep_te<1000.0\',\'solps\'))")
tmp=pmds.mdsvalue("_s")
ans=numpy.array(tmp).reshape(shape[::-1])
solpsindex=numpy.array(ans[0,:].tolist()).astype('i8')
shot=numpy.array(ans[1,:].tolist()).astype('i8')
time=numpy.array(ans[2,:].tolist()).astype('f8')
ompsep_ne=numpy.array(ans[3,:].tolist()).astype('f8')
ompsep_te=numpy.array(ans[4,:].tolist()).astype('f8')

import matplotlib.cm as cm
import matplotlib.pyplot as plt

plt.loglog(ompsep_ne,ompsep_te,'o')
plt.savefig('sql_scatter.png',dpi=200)
plt.clf()

plt.hexbin(ompsep_ne,ompsep_te,xscale='log',yscale='log',cmap=cm.OrRd)
plt.title("SOLPS")
plt.xlabel('ompsep_ne')
plt.ylabel('ompsep_te')
cb = plt.colorbar()
cb.set_label('N')
plt.savefig('sql_hexbin_lin.png',dpi=200)
plt.clf()

plt.hexbin(ompsep_ne,ompsep_te,bins='log',xscale='log',yscale='log',cmap=cm.OrRd)
plt.title("SOLPS")
plt.xlabel('ompsep_ne')
plt.ylabel('ompsep_te')
cb = plt.colorbar()
cb.set_label('log10(N)')
plt.savefig('sql_hexbin_log.png',dpi=200)
plt.clf()