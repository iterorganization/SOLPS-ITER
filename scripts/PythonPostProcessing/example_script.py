# This example shows some basic postprocessing capabilities of the PythonPostProcessing scripts. This example 
# makes use of the COMPASS_16515_1150ms_D_drift_AFN example case contained in $SOLPSTOP/runs/examples

# Set up the imports. Adapt based on your file structure.
import sys
import os
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../"))
sys.path.insert(0, project_root)
base = os.path.dirname(__file__)
import numpy as np
import matplotlib.pyplot as plt
from scripts.PythonPostProcessing.IO import *
from scripts.PythonPostProcessing.Calc import *
from scripts.PythonPostProcessing.Plotting import *
from pathlib import Path


### Constants (possible future improvement: read these from SOLPS itself)
ev = 1.602176565e-19
mp = 1.672621777e-27

### Variables
rzomp = np.array([[0.65, 0.75],[0.0, 0.0]])             # cartesian coordinates of segment where you want to define the OMP

### Directories (now the COMPASS_16515 example case, adapt to your own needs)
basedir =  "../../runs/examples/COMPASS_16515_1150ms_D_drift_AFN/"
dir_kin = basedir + "run_kin_mpi/"
dir_baserun = basedir + "baserun/"

### read b2fstate and b2fgmtry
state = read_b2fstate_us(dir_kin+"b2fstate")
gmtry = read_b2fgmtry_us(dir_baserun+"b2fgmtry")


### Find separatrix and OMP 

# OMP
cv_omp, listfc, nn = cv_intersections(rzomp, gmtry)     # get all the cells that are crossed by the rzomp line segment
cv_omp = cv_omp[cv_omp < gmtry.nCi]                     # excluce the guard cells
nomp = [len(cv_omp)]                                    # count number of cells
cv_omp = cv_omp[np.argsort(gmtry.cvX[cv_omp])]          # sort according to ascending X coordinate
# Separatrix
icsep = np.where(gmtry.cvReg[cv_omp] == 1)[0][-1] + 1   # find the index in the cv_omp list that borders the separatrix (outisde)
ft_sep = gmtry.cvFt[cv_omp[icsep]]                      # identify flux tube number of separatrix


### 2D colorplots 

# 2D colorplot of electron density
fig, ax = plt.subplots()
sh = Patchplot(gmtry, np.log10(state.ne))
sh.set_edgecolor('none')
ax.set_aspect('equal')
plotsep_us(gmtry, icsep, cv_omp, 'k')
plt.colorbar(sh)
ax.set_title(r'$n_\mathregular{e} [\mathregular{m^{-3}, log_{10} \ scale}]$')
plt.savefig("ne_plot.png", dpi=200, bbox_inches="tight")
plt.close()

# 2D colorplot of electron temperature
fig, ax = plt.subplots()
sh = Patchplot(gmtry, np.log10(state.te/ev))
sh.set_edgecolor('none')
ax.set_aspect('equal')
plotsep_us(gmtry, icsep, cv_omp, 'k')
plt.colorbar(sh)
ax.set_title(r'$T_\mathregular{e} [\mathregular{eV, log_{10} \ scale}]$')
plt.savefig("Te_plot.png", dpi=200, bbox_inches="tight")
plt.close()

# Plot the region numbers
fig, ax = plt.subplots()
sh = Patchplot(gmtry, gmtry.cvReg)
sh.set_edgecolor('none')
ax.set_aspect('equal')
plotsep_us(gmtry, icsep, cv_omp, 'k')
plt.colorbar(sh)
ax.set_title('cvReg')
plt.savefig("cvReg_plot.png", dpi=200, bbox_inches="tight")
plt.close()

### Line plots   

r_OMP = calc_dist(gmtry, cv_omp, nomp[0], icsep)        # calculate radial distance along OMP, with the separatrix as reference

# ne along OMP
fig, ax = plt.subplots()
ax.plot(r_OMP, state.ne[cv_omp], 'r-')
ax.set_title('Electron density along OMP')
ax.set_ylabel(r'$n_\mathregular{e} \ [\mathregular{m^{-3}}]$') 
ax.set_xlabel(r'$r-r_\mathregular{sep} \ [\mathregular{m}]$')
plt.savefig("ne_along_OMP.png", dpi=200, bbox_inches="tight")
plt.close()


# Inner target
lbl_IT = -13                                            # the face label (fcLbl) of the inner target
cv_IT, fc_IT = find_cv_faces_lbl(lbl_IT, gmtry)         # find the cell and face IDs corresponding to innter target
cv_IT = cv_IT[np.argsort(-gmtry.cvX[cv_IT])]            # sort according to decreasing X coordinate (to go from PFR to baffle for IT)
fc_IT = fc_IT[np.argsort(-gmtry.fcX[fc_IT])]            # same for faces
n_cv_IT = [len(cv_IT)]                                  # number of cells
tubes = gmtry.cvFt[cv_IT]                               # flux tube numbers of the cells
icsep_IT = np.where(tubes == ft_sep)[0]                 # get the index of the cell that corresponds to the separatrix (outside)
dist_IT = calc_dist(gmtry, cv_IT, n_cv_IT[0], icsep_IT) # get length along target, with the separatrix as reference

# Ti along IT
fig, ax = plt.subplots()
ax.plot(dist_IT, state.ti[cv_IT]/ev, 'r-')
ax.set_title('Ion temperature along inner target')
ax.set_ylabel(r'$T_\mathregular{i} \ [\mathregular{eV}]$') 
ax.set_xlabel(r'$s-s_\mathregular{sep} \ [\mathregular{m}]$')
plt.savefig("Ti_along_IT.png", dpi=200, bbox_inches="tight")
plt.close()

# particle flux density on IT (species-resolved)
fn = boundary_flux_density(gmtry,fc_IT,state.fna[:,:,:])

# Ion particle flux along IT
fig, ax = plt.subplots()
ax.plot(dist_IT, fn[:,1], 'r-')
ax.set_title('Ion particle flux density along inner target')
ax.set_xlabel(r'$s-s_\mathregular{sep} \ [\mathregular{m}]$')
ax.set_ylabel(r'$[\mathregular{m^{-2} s^{-1}}]$') 
plt.savefig("flux_along_IT.png", dpi=200, bbox_inches="tight")
plt.close()