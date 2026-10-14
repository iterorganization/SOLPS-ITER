import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
from scipy.constants import e
import scienceplots
import os

"""
This file contains a library of plotting and diagnostis 
functionalities.
"""

def plot_traces(SOLPS_run):
    # This function plots selected timetraces to assess
    # convergence.
    matplotlib.use('TkAgg')
    fig, axs = plt.subplots(1, 5, figsize=(50,5))
    axs[0].plot(SOLPS_run.tracing['time'],
                SOLPS_run.tracing['nesep'])
    axs[0].set_ylim(np.min(SOLPS_run.tracing['nesep'])*0.9,
                    np.max(SOLPS_run.tracing['nesep'])*1.1)
    axs[1].plot(SOLPS_run.tracing['time'],
                SOLPS_run.tracing['tesep'])
    axs[1].set_ylim(np.min(SOLPS_run.tracing['tesep'])*0.9,
                    np.max(SOLPS_run.tracing['tesep'])*1.1)
    axs[2].plot(SOLPS_run.tracing['time'],
                SOLPS_run.tracing['tisep'])
    axs[2].set_ylim(np.min(SOLPS_run.tracing['tisep'])*0.9,
                    np.max(SOLPS_run.tracing['tisep'])*1.1)
    axs[3].plot(SOLPS_run.tracing['time'],
                SOLPS_run.tracing['hesep'])
    axs[3].set_ylim(np.min(SOLPS_run.tracing['hesep'])*0.9,
                    np.max(SOLPS_run.tracing['hesep'])*1.1)
    axs[4].plot(SOLPS_run.tracing['time'],
                SOLPS_run.tracing['impsep'])
    axs[4].set_ylim(np.min(SOLPS_run.tracing['impsep'])*0.9,
                    np.max(SOLPS_run.tracing['impsep'])*1.1)
    fig1, axs1 = plt.subplots(1, 5, figsize=(50,5))
    axs1[0].plot(SOLPS_run.tracing['time'],
                SOLPS_run.tracing['p_neut'])
    axs1[0].set_ylim(np.min(SOLPS_run.tracing['p_neut'])*0.9,
                    np.max(SOLPS_run.tracing['p_neut'])*1.1)
    axs1[1].plot(SOLPS_run.tracing['time'],
                SOLPS_run.tracing['te_o'])
    axs1[1].set_ylim(np.min(SOLPS_run.tracing['te_o'])*0.9,
                    np.max(SOLPS_run.tracing['te_o'])*1.1)
    axs1[2].plot(SOLPS_run.tracing['time'],
                SOLPS_run.tracing['te_i'])
    axs1[2].set_ylim(np.min(SOLPS_run.tracing['te_i'])*0.9,
                    np.max(SOLPS_run.tracing['te_i'])*1.1)
    axs1[3].plot(SOLPS_run.tracing['time'],
                SOLPS_run.tracing['q_i'])
    axs1[3].set_ylim(np.min(SOLPS_run.tracing['q_i'])*0.9,
                    np.max(SOLPS_run.tracing['q_i'])*1.1)
    axs1[4].plot(SOLPS_run.tracing['time'],
                SOLPS_run.tracing['q_o'])
    axs1[4].set_ylim(np.min(SOLPS_run.tracing['q_o'])*0.9,
                    np.max(SOLPS_run.tracing['q_o'])*1.1)
    fig2, axs2 = plt.subplots(1, 3, figsize=(50,5))
    idx = np.min([len(SOLPS_run.tracing['time']),
                len(SOLPS_run.tracing['Dcore'])])
    axs2[0].plot(SOLPS_run.tracing['time'][:idx],
                SOLPS_run.tracing['Dcore'][:idx])
    axs2[0].set_ylim(np.min(SOLPS_run.tracing['Dcore'])*0.9,
                    np.max(SOLPS_run.tracing['Dcore'])*1.1)
    axs2[1].plot(SOLPS_run.tracing['time'][:idx],
                SOLPS_run.tracing['Hecore'][:idx])
    axs2[1].set_ylim(np.min(SOLPS_run.tracing['Hecore'])*0.9,
                    np.max(SOLPS_run.tracing['Hecore'])*1.1)
    axs2[2].plot(SOLPS_run.tracing['time'][:idx],
                SOLPS_run.tracing['Necore'][:idx])
    axs2[2].set_ylim(np.min(SOLPS_run.tracing['Necore'])*0.9,
                    np.max(SOLPS_run.tracing['Necore'])*1.1)
    plt.show()
    
def plot_2d_grid(SOLPS_run,
                 xmin=3.8, xmax=8.5, ymin=-4.6, ymax=4.8,
                 pfr_inds = [12, 13, 14, 15, 76,
                             77, 78, 79, 80],
                 plot_pfr=False, save_fig=False):
    SOLPS_run.read_f33()
    SOLPS_run.read_f34()
    SOLPS_run.read_f35()
    SOLPS_run.read_input_dat()
    SOLPS_run.read_b2fgmtry()
    if save_fig == False:
        matplotlib.use('TkAgg') 
    plt.figure(1)
    for i in range(SOLPS_run.f35['nump']):
        trl = SOLPS_run.f35['trilist'][i,:]
        trn = trl[0]
        idx = trl[-1]
        if idx == -1:
            trid = SOLPS_run.f34['trilist'][i,1:]
            #Python vs. Fortran indexing.
            crx = SOLPS_run.f33['xc'][trid-1] 
            cry = SOLPS_run.f33['yc'][trid-1]
            XY = np.array([[crx[0], cry[0]],
                           [crx[1], cry[1]],
                           [crx[2], cry[2]],
                           [crx[0], cry[0]]
                           ])
            # From cm to m.
            XY = XY*1e-2 
            plt.gca().add_patch(Polygon(XY, closed=True,
                                        facecolor='g',
                                        edgecolor='k',
                                        linewidth=0.5))


    crx = SOLPS_run.gmtry['crx']
    cry = SOLPS_run.gmtry['cry']
    nx = SOLPS_run.gmtry['nx']
    ny = SOLPS_run.gmtry['ny']
    for i in range(nx):
        for j in range(ny):
            XY = np.array([[crx[i,j,0], cry[i,j,0]],
                           [crx[i,j,2], cry[i,j,2]],
                           [crx[i,j,3], cry[i,j,3]],
                           [crx[i,j,1], cry[i,j,1]]
                           ])
              
            plt.gca().add_patch(Polygon(XY,
                                        closed=True,
                                        facecolor='w',
                                        edgecolor='b',
                                        linewidth=0.5))
            if j == 1:
                if  i in pfr_inds:
                    plt.plot(XY[-1:0,0], XY[-1:0,1], 'r') 
      
    plt.gca().plot(crx[21:72,13,0],cry[21:72,13,0],'r')

    # Hard coding the surfaces for puff
    puffid = range(19,22)
    for idx in puffid:
        plt.plot(1e-2*SOLPS_run.add_surf[idx]['coords'][:,0],
                 1e-2*SOLPS_run.add_surf[idx]['coords'][:,1],'r')
    
    plt.xlim(xmin, xmax)
    plt.ylim(ymin, ymax)
    plt.gca().set_aspect(1.0)
    if save_fig:
        plt.savefig('2d_grid_plot.svg')
    else:
        plt.show()     

        
def plot_2d(SOLPS_run, varname='vadia', fluxdim=3,
            ind=1, s_ind=1, vmin=0, vmax=0, cmap='jet',
            levels=30,
            xmin = 3.8, xmax = 8.5, ymin=-4.6, ymax=4.8,
            save_fig=False):
    clevels = matplotlib.colormaps[cmap](np.linspace(0, 1, levels))
    SOLPS_run.read_b2fgmtry()
    SOLPS_run.read_b2fstate()
    SOLPS_run.read_f33()
    SOLPS_run.read_f34()
    SOLPS_run.read_f35()
    SOLPS_run.read_input_dat()
    if save_fig == False:
        matplotlib.use('TkAgg')
    crx = SOLPS_run.gmtry['crx']
    cry = SOLPS_run.gmtry['cry']
    if varname == 'neut_pres':
        SOLPS_run.read_f44()
        SOLPS_run.read_f46()
        edena = SOLPS_run.f46['edena']
        edena = edena.reshape((SOLPS_run.f34['nump'],
                               SOLPS_run.f46['natom']),
                              order='F')
        edenm = SOLPS_run.f46['edenm']
        edenm = edenm.reshape((SOLPS_run.f34['nump'],
                               SOLPS_run.f46['nmol']),
                              order='F')
        pres = np.zeros(SOLPS_run.f34['nump'])
        for i in range(SOLPS_run.f46['natom']):
            pres += (2.0/3.0)*edena[:,i]*1e6
        for i in range(SOLPS_run.f46['nmol']):
            pres += (2.0/3.0)*edenm[:,i]*1e6
        var = pres*e
        
        nx = SOLPS_run.f44['nx']
        ny = SOLPS_run.f44['ny']
        natom = SOLPS_run.f44['natom']
        nmol = SOLPS_run.f44['nmol']
        var1 = np.zeros((nx, ny))
        dab2 = SOLPS_run.f44['dab2']
        tab2 = SOLPS_run.f44['tab2']
        dmb2 = SOLPS_run.f44['dmb2']
        tmb2 = SOLPS_run.f44['tmb2']
        dab2 = dab2.reshape((nx, ny, natom), order='F')
        tab2 = tab2.reshape((nx, ny, natom), order='F')
        dmb2 = dmb2.reshape((nx, ny, nmol), order='F')
        tmb2 = tmb2.reshape((nx, ny, nmol), order='F')
        for i in range(natom):
            var1 += dab2[:,:,i]*tab2[:,:,i]
        for i in range(nmol):
            var1 += dmb2[:,:,i]*tmb2[:,:,i]
        #    crx = crx[1:nx+1, 1:ny+1, :]
        #    cry = cry[1:nx+1, 1:ny+1, :]
    else:
        var = np.array(SOLPS_run.state[varname])
        if var.ndim == 3:
            var = var[:,:,ind]
        if var.ndim == 4:
            var = var[:,:,ind, s_ind]
    nx = SOLPS_run.state['nx']
    ny = SOLPS_run.state['ny']
    ns = SOLPS_run.state['ns']
    # Compute cell centers.
    cx = 0.25*(crx[:,:,0]+crx[:,:,1]+crx[:,:,2]+crx[:,:,3])
    cy = 0.25*(cry[:,:,0]+cry[:,:,1]+cry[:,:,2]+cry[:,:,3])
    if np.abs(vmin) + np.abs(vmax)  == 0:
        vmin = np.min(var)
        vmax = np.max(var)
    cvecs = np.linspace(vmin, vmax, levels)
    plt.figure(1)
    if varname == 'neut_pres':
        XYMEM = []
        ixlist = SOLPS_run.psudiv_ixlist 
        totpres = 0
        totvol = 0
        for i in ixlist:
            j = 1
            XY = [[crx[i,j,0], cry[i,j,0]],
                  [crx[i,j,2], cry[i,j,2]],
                  [crx[i,j,3], cry[i,j,3]],
                  [crx[i,j,1], cry[i,j,1]],
                  [crx[i,j,0], cry[i,j,0]]
                  ]
            XY = np.array(XY)
            XYMEM.append(XY)
            totvol += SOLPS_run.gmtry['vol'][i,j]
            totpres += var1[i-1,j-1]*SOLPS_run.gmtry['vol'][i,j]
        print(totpres/totvol)
 
    for i in range(SOLPS_run.f35['nump']):
        trl = SOLPS_run.f35['trilist'][i,:]
        trn = trl[0]
        idx = trl[-1]
        if varname != 'neut_pres':
            if idx == -1:
                trid = SOLPS_run.f34['trilist'][i,1:]
                # Python vs. Fortran indexing.
                crxe = SOLPS_run.f33['xc'][trid-1] 
                crye = SOLPS_run.f33['yc'][trid-1]
                XY = np.array([[crxe[0], crye[0]],
                               [crxe[1], crye[1]],
                               [crxe[2], crye[2]],
                               [crxe[0], crye[0]]
                               ])
                # From cm to m conversion.
                XY = XY*1e-2 # 
                    
                plt.gca().add_patch(Polygon(XY,
                                            closed=True,
                                            facecolor='g',
                                            edgecolor='k',
                                            linewidth=0.5))
            else:
                trid = SOLPS_run.f34['trilist'][i,1:]
                # Python vs. Fortran indexing.
                crxe = SOLPS_run.f33['xc'][trid-1]
                crye = SOLPS_run.f33['yc'][trid-1]
                XY = np.array([[crxe[0], crye[0]],
                               [crxe[1], crye[1]],
                               [crxe[2], crye[2]],
                               [crxe[0], crye[0]]
                               ])
                # From cm to m conversion.
                XY = XY*1e-2
                varf = var.flatten()
                if i > len(varf)-1:
                    idx = -1
                else:
                    idx = np.where(cvecs>varf[i])
                    idx = idx[0]
                    if len(idx) > 1:
                        idx = idx[0]
                    if varf[i] >= np.max(cvecs):
                        idx = len(cvecs)-1
                clev = clevels[idx]
                try:
                    plt.gca().add_patch(Polygon(XY,
                                                closed=True,
                                                color=clev))
                except:
                    plt.gca().add_patch(Polygon(XY,
                                                closed=True,
                                                color='w'))
                XY = np.array(XY)
                    
    if varname == 'neut_pres':                        
        for XY in XYMEM:    
            plt.plot(XY[:,0], XY[:,1], 'w-')
        plt.plot([crx[ixlist[0],1,0], crx[ixlist[-1],1,1]],
                 [cry[ixlist[0],1,0], cry[ixlist[-1],1,1]],
                 'w--')
    if varname != 'neut_pres':
        for i in range(1, len(crx[:, 0, 0])-1):
            for j in range(1, len(crx[0, :, 0])-1):
                idx = np.where(cvecs > var[i,j])
                idx = idx[0]
                if len(idx) > 1:
                    idx = idx[0]
                if var[i,j] >= np.max(cvecs):
                    idx = len(cvecs)-1
                XY = [[crx[i,j,0], cry[i,j,0]],
                      [crx[i,j,2], cry[i,j,2]],
                      [crx[i,j,3], cry[i,j,3]],
                      [crx[i,j,1], cry[i,j,1]]
                      ]
                clev = clevels[idx]
                try:
                    plt.gca().add_patch(Polygon(XY,
                                                closed=True,
                                                color=clev))
                except:
                    plt.gca().add_patch(Polygon(XY,
                                                closed=True,
                                                color='w'))
            
    plt.xlim(xmin, xmax)
    plt.ylim(ymin, ymax)
    plt.gca().set_aspect(1.0)
    if save_fig:
        plt.savefig('2d_plot.svg')
    else:
        plt.show()    
        
def plot_plate_heat(SOLPS_run):
    # This function plots the heat flux profiles at plates.
    matplotlib.use('TkAgg')
    plt.style.use(['science','no-latex'])
    fig, axs = plt.subplots(1, 2,
                            sharey=True,
                            figsize=(2*6.4, 6.4))
    axs[0].plot(SOLPS_run.it_x, SOLPS_run.it_tot_heat/1e6,
                'k-', linewidth=2, label='Total')
    axs[0].plot(SOLPS_run.it_x, SOLPS_run.it_rad_load/1e6,
                'r--', linewidth=1.5, label='Radiation')
    axs[0].plot(SOLPS_run.it_x, SOLPS_run.it_rec_load/1e6,
                'b--', linewidth=1.5, label='Recombination')
    axs[0].plot(SOLPS_run.it_x, SOLPS_run.it_neut_load/1e6,
                'm--', linewidth=1.5, label='Neutrals')
    axs[0].set_ylim(0, 50)
    axs[0].legend()
    axs[0].set_xlabel('$S - S_{sep}$ (m)')
    axs[0].set_ylabel('(MW/m$^2$)')
    axs[0].set_title('Inner target')
    axs[1].plot(SOLPS_run.ot_x, SOLPS_run.ot_tot_heat/1e6,
                'k-', linewidth=2)
    axs[1].plot(SOLPS_run.ot_x, SOLPS_run.ot_rad_load/1e6,
                'r--', linewidth=1.5)
    axs[1].plot(SOLPS_run.ot_x, SOLPS_run.ot_rec_load/1e6,
                'b--', linewidth=1.5)
    axs[1].plot(SOLPS_run.ot_x, SOLPS_run.ot_neut_load/1e6,
                'm--', linewidth=1.5)
    axs[1].set_ylim(0, 50)
    axs[1].set_xlabel('$S - S_{sep}$ (m)')
    axs[1].set_title('Outer target')
    plt.show()

def plot_heat_flux_width(SOLPS_run):
    # Plot heat flux width profiles at the outer plate
    matplotlib.use('TkAgg')
    plt.style.use(['science','no-latex'])
    fig, axs = plt.subplots(1, 2,
                            sharey=True,
                            figsize=(2*6.4, 6.4))
    axs[0].plot(SOLPS_run.it_xomp, SOLPS_run.it_per_u/1e6,
                'ks', linewidth=2)
    axs[0].set_xlabel('$S - S_{sep}$ (m)')
    axs[0].set_ylabel('(MW/m$^2$)')
    axs[0].set_title('Inner target')
    axs[1].plot(SOLPS_run.ot_xomp, SOLPS_run.ot_per_u/1e6,
                'ks', linewidth=2)
    maxval = np.max(SOLPS_run.ot_per_u/1e6)
    x0 = np.linspace(0,0.2,100)
    lam = 0.0034
    axs[1].plot(x0, maxval*np.exp(-x0/lam),
                'r',linewidth=2)
    axs[1].set_xlim(0, 0.015)
    axs[1].set_xlabel('$S - S_{sep}$ (m)')
    axs[1].set_title('Outer target')
    plt.show()

def compare_pressures(SOLPS_run):
    # This function compares the neutral pressure
    # computed from fort.44 and fort.46.
    # Originally written to compare
    # neutral pressure calculation methods.
    matplotlib.use('TkAgg')
    SOLPS_run.read_b2fgmtry()
    SOLPS_run.read_b2fstate()
    SOLPS_run.read_f33()
    SOLPS_run.read_f34()
    SOLPS_run.read_f35()
    SOLPS_run.read_f44()
    SOLPS_run.read_f46()
    trl = SOLPS_run.f35['trilist']
    nx = SOLPS_run.f44['nx']
    ny = SOLPS_run.f44['ny']
    natom = SOLPS_run.f44['natom']
    nmol = SOLPS_run.f44['nmol']
    var = np.zeros((nx, ny))
    dab2 = SOLPS_run.f44['dab2']
    tab2 = SOLPS_run.f44['tab2']
    dmb2 = SOLPS_run.f44['dmb2']
    tmb2 = SOLPS_run.f44['tmb2']
    dab2 = dab2.reshape((nx, ny, natom), order='F')
    tab2 = tab2.reshape((nx, ny, natom), order='F')
    dmb2 = dmb2.reshape((nx, ny, nmol), order='F')
    tmb2 = tmb2.reshape((nx, ny, nmol), order='F')
    for i in range(natom):
        var += dab2[:,:,i]*tab2[:,:,i]
    for i in range(nmol):
        var += dmb2[:,:,i]*tmb2[:,:,i]
    edena = SOLPS_run.f46['edena']
    edena = edena.reshape((SOLPS_run.f34['nump'],
                           SOLPS_run.f46['natom']),
                          order='F')
    edenm = SOLPS_run.f46['edenm']
    edenm = edenm.reshape((SOLPS_run.f34['nump'],
                           SOLPS_run.f46['nmol']),
                          order='F')
    pres = np.zeros(SOLPS_run.f34['nump'])
    for i in range(SOLPS_run.f46['natom']):
        pres += (2.0/3.0)*edena[:,i]*1e6
    for i in range(SOLPS_run.f46['nmol']):
        pres += (2.0/3.0)*edenm[:,i]*1e6
    pres = pres*e
    pvec = np.zeros((nx+2, ny+2))
    for i in range(nx+2):
        for j in range(ny+2):
            idx1 = np.where(trl[:,-1] == j)
            idx2 = np.where(trl[:,-2] == i)
            idx3 = np.intersect1d(idx1,idx2)
            avep = 0
            for idx in idx3:
                avep += pres[trl[idx,0]-1]
            if len(idx3) > 0:
                avep = avep/len(idx3)
            pvec[i,j] = avep
    print(np.shape(var))
    print(np.shape(pvec))
    plt.plot(var[:,10],'k-')
    plt.plot(pvec[1:,11],'r-')
    plt.show()

def pump_run_log(SOLPS_run, show_fig=True):
    # This function is written to analyze
    # particle balance convergence of the
    # simulation.
    starting_dir = os.getcwd()
    os.chdir(SOLPS_run.run_dir)
    fid = open('run.log.last10','r')
    neof = True
    Dpump = []
    Hepump = []
    Nepump = []
    Dpuff = []
    Nepuff = []
    count = 0
    while neof:
        line = fid.readline()
        if len(line)<1:
            count += 1
        else:
            count = 0
        if count > 20:
            neof = False
        else:
            if '-1 HE' in line:
                ls = line.split()
                necore = float(ls[2])
            if 'PUMPED FLUX (ATOMIC) PER SPECIES' in line:
                try:
                    line1 = fid.readline()
                    line2 = fid.readline()
                    line3 = fid.readline()
                    line4 = fid.readline()
                    ls1 = line1.split()
                    ls2 = line2.split()
                    ls3 = line3.split()
                    ls4 = line4.split()
                    Dpump.append(float(ls1[1])/e + float(ls4[1])/e)
                    Hepump.append(float(ls2[1])/e-necore/e)
                    Nepump.append(float(ls3[1])/e)
                except:
                    print('exception')
            if 'Number of gas puff sources:' in line:
                ls = line.split()
                numgas = int(ls[5])
                dpu = 0
                nepu = 0
                for i in range(numgas):
                    line = fid.readline()
                    ls = line.split()
                    if int(ls[5]) == 1:
                        dpu += float(ls[4])
                    if int(ls[5]) == 3:
                        nepu += float(ls[4])
                Dpuff.append(dpu)
                Nepuff.append(nepu)

    fid.close()
    fid = open('b2.boundary.parameters','r')
    line = fid.readline()
    while 'CONPAR' not in line:
        line = fid.readline()
    ls = line.split()
    Dcore = float(ls[3][:-1])
    Hecore = float(ls[6][:-1])
    Dp = np.array(Dpump)
    Hep = np.array(Hepump)
    Nep = np.array(Nepump)
    Dpuff = np.array(Dpuff)
    Nepuff = np.array(Nepuff)
    if show_fig:
        matplotlib.use('TkAgg')
        plt.style.use(['science','no-latex'])
    gasnumber = [1, 2, 3]
    yerr = np.array([np.std(Dp)/np.mean(Dp),
                     np.std(Hep)/np.mean(Hep),
                     np.std(Nep)/np.mean(Nep)])
    yerr = 100*yerr
    y = [(np.mean(Dpuff)+Dcore)/np.mean(Dp),
         Hecore/np.mean(Hep),
         np.mean(Nepuff)/np.mean(Nep)]
    y = np.array(y)*100
    if show_fig:
        plt.errorbar(gasnumber, 100*np.ones(3), yerr=yerr,
                     ecolor='k', marker='s',
                     markerfacecolor='k', markeredgecolor='k',
                     linestyle='--')
        plt.plot(gasnumber, y, 'rs')
        plt.ylabel('Particle balance (%)')
        plt.xticks(ticks=[1, 2, 3], labels=['D', 'He', 'Ne'])
        plt.show()
    else:
        print('D pump ', str(np.mean(Dp)), ' +/- ', str(np.std(Dp)))
        print('He pump ', str(np.mean(Hep)), ' +/- ', str(np.std(Hep)))
        print('Ne pump ', str(np.mean(Nep)), ' +/- ', str(np.std(Nep)))
        print('D, He, Ne source/pump (%) ', str(y))
    os.chdir(starting_dir)

def core_balance(SOLPS_run, idx1=21, idx2=71):
    # This function analyses core particle balance
    SOLPS_run.read_b2fstate()
    SOLPS_run.read_b2fgmtry()
    SOLPS_run.read_f44()
    nx = SOLPS_run.f44['nx']
    ny = SOLPS_run.f44['ny']
    ns = SOLPS_run.f44['natom']
    rfa = SOLPS_run.f44['rfluxa'].reshape((nx, ny, ns), order='F')
    d_core = np.sum(SOLPS_run.state['fna'][idx1:idx2,1,1,1])
    he_core = np.sum(SOLPS_run.state['fna'][idx1:idx2,1,1,3] +
                         SOLPS_run.state['fna'][idx1:idx2,1,1,4])
    ne_core = 0
    for i in range(10):
        ne_core += np.sum(SOLPS_run.state['fna'][idx1:idx2,1,1,6+i])

    d_sep = np.sum(SOLPS_run.state['fna'][idx1:idx2,12,1,1])
    he_sep = np.sum(SOLPS_run.state['fna'][idx1:idx2,12,1,3] +
                         SOLPS_run.state['fna'][idx1:idx2,12,1,4])
    ne_sep = 0
    for i in range(10):
        ne_sep += np.sum(SOLPS_run.state['fna'][idx1:idx2,12,1,6+i])

    d_neut = np.sum(np.sum(np.multiply(SOLPS_run.gmtry['gs'][idx1:idx2,1,1],
                                    rfa[idx1-1:idx2-1,0,0])) - \
                        np.multiply(SOLPS_run.gmtry['gs'][idx1:idx2,12,1],
                                    np.sum(rfa[idx1-1:idx2-1,11,0])))
    he_neut = np.sum(np.sum(np.multiply(SOLPS_run.gmtry['gs'][idx1:idx2,1,1],
                                     rfa[idx1-1:idx2-1,0,1])) - \
                         np.multiply(SOLPS_run.gmtry['gs'][idx1:idx2,12,1],
                                     np.sum(rfa[idx1-1:idx2-1,11,1])))
    ne_neut = np.sum(np.sum(np.multiply(SOLPS_run.gmtry['gs'][idx1:idx2,1,1],
                                     rfa[idx1-1:idx2-1,0,2])) - \
                         np.multiply(SOLPS_run.gmtry['gs'][idx1:idx2,12,1],
                                     np.sum(rfa[idx1-1:idx2-1,11,2])))

    print(he_core)
    print(he_sep)
    print(he_neut)

### Below this line are plotting functionalities for SOLPS_series

def plot_ot_profiles(SOLPS_series):
    matplotlib.use('TkAgg')
    plt.style.use(['science','no-latex'])
    plt.rcParams.update({'font.size': 20})
    plt.figure(num = 1, figsize=(10, 10))
    for i in range(len(SOLPS_series.sruns)):
        SOLPS_series.sruns[i].plate_profiles()
        plt.plot(SOLPS_series.sruns[i].ot_plate_profiles['s'],
                 SOLPS_series.sruns[i].ot_plate_profiles['te'],
                 linewidth=2)
    plt.xlim(-5, 20)
    plt.ylim(0, 75)
    plt.xlabel('$S - S_{sep}$ (cm)')
    plt.ylabel('$T_e$ (eV)')
    plt.figure(num = 2, figsize=(10, 10))
    for i in range(len(SOLPS_series.sruns)):
        plt.plot(SOLPS_series.sruns[i].ot_plate_profiles['s'],
                 SOLPS_series.sruns[i].ot_plate_profiles['fna']/1e23,
                 linewidth=2)
    plt.xlim(-5,20)
    plt.ylim(0, 11)
    plt.xlabel('$S - S_{sep}$ (cm)')
    plt.ylabel('$\Gamma_{\perp}$ ($10^{23}$ m$^{-2}$s$^{-1}$)')
    plt.figure(num = 3, figsize=(10, 10))
    for i in range(len(SOLPS_series.sruns)):
        plt.plot(SOLPS_series.sruns[i].ot_plate_profiles['s'],
                 SOLPS_series.sruns[i].ot_plate_profiles['ne']/1e21,
                 linewidth=2)
    plt.xlim(-5,20)
    plt.ylim(0, 3.0)
    plt.xlabel('$S - S_{sep}$ (cm)')
    plt.ylabel('$n_e$ (10$^{21}$ m$^{-3}$)')
    plt.show()
              
def plot_p_subdiv_part_sum(SOLPS_series):
    pvec = []
    otsum = []
    itsum = []
    for i in range(len(SOLPS_series.sruns)):
        SOLPS_series.sruns[i].plate_fluxes()
        SOLPS_series.sruns[i].read_p_subdiv()
        pvec.append(SOLPS_series.sruns[i].p_subdiv)
        otsum.append(1e-24*SOLPS_series.sruns[i].ot_part_sum)
        itsum.append(1e-24*SOLPS_series.sruns[i].it_part_sum)
    plt.plot(pvec,
             otsum,
             SOLPS_series.psymbol,
             color=SOLPS_series.color,
             markersize=12)
    plt.plot(pvec,
             itsum,
             SOLPS_series.psymbol,
             color=SOLPS_series.color,
             markersize=12,
             markerfacecolor='white')

def plot_p_subdiv_ne_sep(SOLPS_series):
    pvec = []
    nevec = []
    for i in range(len(SOLPS_series.sruns)):
        SOLPS_series.sruns[i].read_sep_data()
        SOLPS_series.sruns[i].read_p_subdiv()
        pvec.append(SOLPS_series.sruns[i].p_subdiv)
        nevec.append(1e-19*SOLPS_series.sruns[i].nesep)
    plt.plot(pvec,
             nevec,
             SOLPS_series.psymbol,
             color=SOLPS_series.color,
             markersize=12)

def plot_p_subdiv_ne_conc(SOLPS_series):
    pvec = []
    cvec = []
    for i in range(len(SOLPS_series.sruns)):
        SOLPS_series.sruns[i].read_sep_data()
        SOLPS_series.sruns[i].read_p_subdiv()
        pvec.append(SOLPS_series.sruns[i].p_subdiv)
        cvec.append(1e2*SOLPS_series.sruns[i].ne_conc)
    plt.plot(pvec,
             cvec,
             SOLPS_series.psymbol,
             color=SOLPS_series.color,
             markersize=12)

def plot_p_subdiv_heatr(SOLPS_series):
    pvec = []
    heatr = []
    for i in range(len(SOLPS_series.sruns)):
        SOLPS_series.sruns[i].power_balance()
        SOLPS_series.sruns[i].read_p_subdiv()
        pvec.append(SOLPS_series.sruns[i].p_subdiv)
        heatr.append(100*SOLPS_series.sruns[i].target_plasma_heat\
                     /SOLPS_series.sruns[i].heat_in)
    plt.plot(pvec,
             heatr,
             SOLPS_series.psymbol,
             color=SOLPS_series.color,
             markersize=12)

def plot_p_subdiv_plasma_heat(SOLPS_series):
    pvec = []
    peak_ot = []
    peak_it = []
    for i in range(len(SOLPS_series.sruns)):
        SOLPS_series.sruns[i].plate_heat(run_b2plot=False)
        SOLPS_series.sruns[i].read_p_subdiv()
        pvec.append(SOLPS_series.sruns[i].p_subdiv)
        peak_ot.append(1e-6*SOLPS_series.sruns[i].ot_peak)
        peak_it.append(1e-6*SOLPS_series.sruns[i].it_peak)
    plt.plot(pvec,
             peak_ot,
             SOLPS_series.psymbol,
             color=SOLPS_series.color,
             markersize=12)
    plt.plot(pvec,
             peak_it,
             SOLPS_series.psymbol,
             color=SOLPS_series.color,
             markersize=12,
             markerfacecolor='white')

def plot_p_subdiv_radtot(SOLPS_series):
    pvec = []
    radvectot = []
    radvecsol = []
    for i in range(len(SOLPS_series.sruns)):
        SOLPS_series.sruns[i].read_p_subdiv()
        pvec.append(SOLPS_series.sruns[i].p_subdiv)
        radvectot.append(1e-2*SOLPS_series.sruns[i].q_radtot)
        radvecsol.append(SOLPS_series.sruns[i].q_radsol\
                         /SOLPS_series.sruns[i].q_radtot)
    plt.plot(pvec,
             radvectot,
             SOLPS_series.psymbol,
             color=SOLPS_series.color,
             markersize=12,
             markerfacecolor='white')
    plt.plot(pvec,
             radvecsol,
             SOLPS_series.psymbol,
             color=SOLPS_series.color,
             markersize=12)

### Below this line are SOLPS_nanny level plotting functionalities

def plot_p_subdiv_ne_conc(SOLPS_nanny):
    matplotlib.use('TkAgg')
    plt.style.use(['science','no-latex'])
    plt.rcParams.update({'font.size': 20})
    fig1 = plt.figure(figsize=(10, 10))
    for series in SOLPS_nanny.sl:
        plot_p_subdiv_ne_conc(series)
    plt.xlabel('Divertor neutral pressure (Pa)')
    plt.ylabel('$C_{Ne}$ (%)')
    plt.xlim([2,20])
    plt.ylim([0.3, 1.9])
    plt.yticks(ticks=[0.4, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8])
    plt.xscale('log')
    ax1 = fig1.get_axes()
    ax1 = ax1[0]
    
    ax1.set_xticks([2, 3, 4, 5, 6, 7, 8, 9, 10, 20],
                   labels=['2', '3', '4', '5', '6', '7', '8', '9', '10', '20'])
    ax1.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())   
    plt.show()

def plot_p_subdiv_ne_sep(SOLPS_nanny):
    matplotlib.use('TkAgg')
    plt.style.use(['science','no-latex'])
    plt.rcParams.update({'font.size': 20})
    fig1 = plt.figure(figsize=(10, 10))
    for series in SOLPS_nanny.sl:
        plot_p_subdiv_ne_sep(series)
    plt.xlabel('Divertor neutral pressure (Pa)')
    plt.ylabel('$n_{e,SEP}$ ($10^{19}$ m$^{-3}$)')
    plt.xlim([2,20])
    plt.xscale('log')
    ax1 = fig1.get_axes()
    ax1 = ax1[0]
    
    ax1.set_xticks([2, 3, 4, 5, 6, 7, 8, 9, 10, 20],
                   labels=['2', '3', '4', '5', '6', '7', '8', '9', '10', '20'])
    ax1.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    plt.show()
        
def plot_p_subdiv_part_sum(SOLPS_nanny):
    matplotlib.use('TkAgg')
    plt.style.use(['science','no-latex'])
    plt.rcParams.update({'font.size': 20})
    fig1 = plt.figure(figsize=(10, 10))
    for series in SOLPS_nanny.sl:
        plot_p_subdiv_part_sum(series)
    plt.xlabel('Divertor neutral pressure (Pa)')
    plt.ylabel('$\int \Gamma_{\perp}$ ($10^{24}$ s$^{-1}$)')
    plt.xlim([2,20])
    plt.xscale('log')
    ax1 = fig1.get_axes()
    ax1 = ax1[0]
    
    ax1.set_xticks([2, 3, 4, 5, 6, 7, 8, 9, 10, 20],
                       labels=['2', '3', '4', '5', '6', '7', '8', '9', '10', '20'])
    ax1.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    plt.show()

def plot_p_subdiv_heatr(self):
    matplotlib.use('TkAgg')
    plt.style.use(['science','no-latex'])
    plt.rcParams.update({'font.size': 20})
    plt.figure(figsize=(10, 10))
    for series in SOLPS_nanny.sl:
        plot_p_subdiv_heatr(series)
    plt.xlabel('Divertor neutral pressure (Pa)')
    plt.ylabel('$P_{t}/P_{in}$ (%)')
    plt.ylim(0, 100)
    plt.show()

def plot_p_subdiv_plasma_heat(SOLPS_nanny, savefig=False):
    if savefig == False:
        matplotlib.use('TkAgg')
    plt.style.use(['science','no-latex'])
    plt.rcParams.update({'font.size': 20})
    fig1 = plt.figure(figsize=(10, 10))
    for series in SOLPS_nanny.sl:
        plot_p_subdiv_plasma_heat(series)
    plt.xlabel('Divertor neutral pressure (Pa)')
    plt.ylabel('$q_{OT/IT}$ (MW/m$^2$)')
    plt.ylim(1, 25)
    plt.yscale('log')
    plt.yticks(ticks=[5, 10, 15, 20, 25],
               labels=['5','10','15','20','25'])
    plt.xlim([2,20])
    plt.xscale('log')
    ax1 = fig1.get_axes()
    ax1 = ax1[0]
    
    ax1.set_xticks([2, 3, 4, 5, 6, 7, 8, 9, 10, 20],
                   labels=['2', '3', '4', '5', '6', '7', '8', '9', '10', '20'])
    ax1.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    if savefig:
        plt.savefig('plasma_heat.svg')
    else:
        plt.show()

def plot_p_subdiv_radtot(SOLPS_nanny):
    matplotlib.use('TkAgg')
    plt.style.use(['science','no-latex'])
    plt.rcParams.update({'font.size': 20})
    plt.figure(figsize=(10, 10))
    for series in SOLPS_nanny.sl:
        plot_p_subdiv_radtot(series)
    plt.xlabel('Divertor neutral pressure (Pa)')
    plt.ylabel('$f_{RAD}$ (MW)')
    plt.ylim(0.2, 1.0)
    plt.xscale('log')
    plt.show()
