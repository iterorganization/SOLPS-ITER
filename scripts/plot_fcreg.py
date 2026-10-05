import numpy as np, re, sys
import matplotlib; matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection
fn = sys.argv[1]
data = {}
with open(fn) as f:
    lines = f.read().splitlines()
i = 1
while i < len(lines):
    h = lines[i]
    if h.startswith('*cf:'):
        p = h.split(); typ, n, name = p[1], int(p[2]), p[3]
        vals = []; i += 1
        while i < len(lines) and not lines[i].startswith('*cf:'):
            vals += lines[i].split(); i += 1
        if typ == 'int': data[name] = np.array(vals, int)
        elif typ == 'real': data[name] = np.array(vals, float)
        else: data[name] = ' '.join(vals)
    else: i += 1
nFc = data['nCi,nCg,nCv,nFc,nVx,nFs,nFt'][3]
fcVx = data['fcVx'].reshape(2, nFc).T - 1
x, y = data['vxX'], data['vxY']
reg = data['fcReg']
print('vertex idx range', fcVx.min(), fcVx.max(), 'nVx', len(x))
regs, cnt = np.unique(reg, return_counts=True)
print('fcReg values/counts:', dict(zip(regs.tolist(), cnt.tolist())))
segs = np.stack([np.c_[x[fcVx[:,0]], y[fcVx[:,0]]], np.c_[x[fcVx[:,1]], y[fcVx[:,1]]]], axis=1)
fig, ax = plt.subplots(figsize=(9, 14))
ax.add_collection(LineCollection(segs[reg == 0], colors='0.75', linewidths=0.3))
nz = [r for r in regs if r != 0]
cmap = plt.get_cmap('tab20' if len(nz) > 10 else 'tab10')
for k, r in enumerate(nz):
    ax.add_collection(LineCollection(segs[reg == r], colors=[cmap(k % cmap.N)], linewidths=1.6, label=f'fcReg={r} ({(reg==r).sum()})'))
ax.autoscale(); ax.set_aspect('equal'); ax.set_xlabel('R [m]'); ax.set_ylabel('Z [m]')
ax.set_title(f'{fn}\nfaces with fcReg != 0')
ax.legend(loc='upper left', bbox_to_anchor=(1.01, 1), fontsize=8)
fig.savefig(sys.argv[2], dpi=200, bbox_inches='tight')
