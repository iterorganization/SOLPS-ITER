#! /usr/bin/env python3
import MDSplus
import numpy as np

conn = MDSplus.Connection('solps-mdsplus.ipp.mpg.de:8001')
shape = conn.get("shape(_s=sql(\'select solpsindex,shot,time,ompsep_ne,ompsep_te,user,exp from id where ompsep_te>10.0 and ompsep_te<1000.0\',\'solps\'))")
tmp = conn.get("_s")
ans = np.array(tmp).reshape(shape[::-1])

solpsindex = np.array(ans[0,:].tolist()).astype('i8')
shot       = np.array(ans[1,:].tolist()).astype('i8')
time       = np.array(ans[2,:].tolist()).astype('f8')
ompsep_ne  = np.array(ans[3,:].tolist()).astype('f8')
ompsep_te  = np.array(ans[4,:].tolist()).astype('f8')
user       = np.array([e.decode('utf8').strip() for e in ans[5]])
exp        = np.array([e.decode('utf8').strip() for e in ans[6]])

import matplotlib.cm as cm
import matplotlib.pyplot as plt

plt.clf()
plt.loglog(ompsep_ne, ompsep_te, 'o', alpha=0.1)
plt.xlabel('ompsep_ne')
plt.ylabel('ompsep_te')
plt.savefig('sql_scatter.png', dpi=200)
plt.savefig('sql_scatter.ps', dpi=200, bbox_inches='tight')
plt.savefig('sql_scatter.eps', dpi=200)

# filter a subset of the data
filter = (ompsep_ne > 1e19) & (ompsep_ne < 1e20) & (ompsep_te > 10.0) & (ompsep_te <  500.0)

plt.clf()
plt.hexbin(ompsep_ne[filter] ,ompsep_te[filter] ,xscale='log', yscale='log', cmap=cm.OrRd)
plt.title("SOLPS")
plt.xlabel('ompsep_ne')
plt.ylabel('ompsep_te')
cb = plt.colorbar()
cb.set_label('N')
plt.savefig('sql_hexbin_lin.png', dpi=200)
plt.savefig('sql_hexbin_lin.ps', dpi=200, bbox_inches='tight')
plt.savefig('sql_hexbin_lin.eps', dpi=200)

plt.clf()
plt.hexbin(ompsep_ne[filter], ompsep_te[filter], bins='log', xscale='log', yscale='log', cmap=cm.OrRd)
plt.title("SOLPS")
plt.xlabel('ompsep_ne')
plt.ylabel('ompsep_te')
cb = plt.colorbar()
cb.set_label('N')
plt.savefig('sql_hexbin_log.png', dpi=200, bbox_inches='tight')
plt.savefig('sql_hexbin_log.ps', dpi=200, bbox_inches='tight')
plt.savefig('sql_hexbin_log.eps', dpi=200,)
