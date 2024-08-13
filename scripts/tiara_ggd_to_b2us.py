#!/usr/bin/env python
# coding: utf-8
help = """
This program reads Equlibrium IDS from IMAS database created by TIARA and saves
the data in the b2us file format. If you want to know more about the
description of the traduit.out.b2us file format, you need to read it with
plot_traduit_out_b2us.py --help script.

### ToDo:

nFt - Flux tube data : (ft ftCvP(:,1) ftCvP(:,2) ftFcP(:,1) ftFcP(:,2) ftReg)
Missing due to y-aligned surfaces not being flux-perpendicular only?.
"""
import imas
import getpass
import time
import numpy as np
import argparse

#description= "Reads Equlibrium IDS from IMAS database and saves the data to b2us file format."
formatter_class=argparse.ArgumentDefaultsHelpFormatter

parser = argparse.ArgumentParser(description=help,
                                 formatter_class=formatter_class)

parser.add_argument("-s", "--shot", type=int, default=122408, help="Shot number")
parser.add_argument("-r", "--run", type=int, default=4, help="Run number")
parser.add_argument("-u", "--user", type=str, default=getpass.getuser(),
                    help="Location of ~$USER/public/imasdb")
parser.add_argument("-d", "--database", type=str, default="ITER", 
                    help="Database name under public/imasdb/")
parser.add_argument("-o", "--occurrence", type=int, default=0, 
                    help="Occurrence number")
parser.add_argument("-b", "--backend", type=int, default=12,
                    help="Database format: 12=MDSPLUS, 13=HDF5")

parser.add_argument("-f", "--file", type=str, default='tiara.122408_4.b2us',
                    help="Output filename")

args = parser.parse_args()

# Open IMAS DB entry
def get_ggd():
    dbentry = imas.DBEntry(args.backend, args.database, args.shot, args.run, 
                           args.user)
    status, idx = dbentry.open()
    if status != 0:
        print('Creation of data entry FAILED! Exiting.')
        sys.exit(status)
    equilibrium = dbentry.get("equilibrium")
    return equilibrium

eq = get_ggd()

# Nodes from GGD_space
nodes = eq.grids_ggd[0].grid[0].space[0].objects_per_dimension[0].object
number_of_nodes = len(nodes)
print(f"Number of nodes: {number_of_nodes}")

# Cells from GGD_space
cells = eq.grids_ggd[0].grid[0].space[0].objects_per_dimension[2].object
number_of_cells = len(cells)
print(f"Number of cells: {number_of_cells}")

# Faces from GGD_space
faces = eq.grids_ggd[0].grid[0].space[0].objects_per_dimension[1].object
number_of_faces = len(faces)
print(f"Number of faces: {number_of_faces}")

# Psi of nodes 
psi_nodes = eq.time_slice[0].ggd[0].psi[0].values
number_of_psi_nodes = len(psi_nodes)
vxPsi = psi_nodes

# Psi of faces
psi_faces = eq.time_slice[0].ggd[0].psi[1].values


nCi = number_of_cells
nFc = number_of_faces
nVx = number_of_nodes
nCg = 0  
nFt = 0
cvVxP = np.array([])

# Compute number of vertices for all cells, faces
ncvVx = 0
for i in range(nCi):
    number_of_cell_vertices = len(cells[i].nodes)
    ncvVx += number_of_cell_vertices
    
nfcVx = 0
for i in range(nFc):
    number_of_face_vertices = len(faces[i].nodes)
    nfcVx += number_of_face_vertices
    
# # Grid_subset_indentifier_name
grid_subset_indices = dict()
grid_subsets = eq.grids_ggd[0].grid[0].grid_subset    
number_of_grid_subsets = len(grid_subsets)
#print('Grid_subset_indentifier_name:')
for i in range(number_of_grid_subsets):
    grid_subset = grid_subsets[i]
    grid_subset_indices[grid_subset.identifier.index] = i
    #print(f'{i}: {grid_subset.identifier.index} = {grid_subset.identifier.name}')

# Find x aligned faces for fcAligned and flux surface
x_aligned_indices = set()
## 3-> x_aligned_edges
x_aligned_edges = eq.grids_ggd[0].grid[0].grid_subset[grid_subset_indices[3]] 
x_aligned_edges_dimension = x_aligned_edges.dimension
x_aligned_edges_elements = x_aligned_edges.element
n=0
for i in range(len(x_aligned_edges_elements)):
    if len(x_aligned_edges_elements[i].object):
        x_aligned_indices.add(x_aligned_edges_elements[i].object[0].index)
        n += 1
#print(f"x_aligned_edges {n}/{len(x_aligned_edges_elements)}")

#Storing number of faces in the flux surface and value Psi in to arrays.
fsFc = dict()

# Loop through each value in fsPsi.
for i in x_aligned_indices:
    psi = psi_faces[i-1]
    if psi not in fsFc:
        fsFc[psi] = set()
    fsFc[psi].add(i)
    
nfsFc = len(x_aligned_indices) # Number of flux surface faces
nFs = len(fsFc)
print(f"Number of flux surface faces: {nFs}")

# Write the file in b2us format from GGD
print(f"Writing {args.file} ...")
with open(args.file, 'w') as f:
    print(f'VERSION03.002.000 TIARA b2us {time.asctime()}', file=f)
    print('*cf: int 6 nCi,nFc,nVx,nCg,nFs,nFt', file=f)
    print(f'{nCi} {nFc} {nVx} {nCg} {nFs} {nFt}', file=f)
    
    # Vertices
    print(f'*cf: Vx vxX vxY vxPsi vxBx vxBy vxFfbz', file=f)
    for i in range(nVx):
        print(f'{i+1:>10}  {nodes[i].geometry[0]:>10.15f}  {nodes[i].geometry[1]:>18.15f}'
              f'  {vxPsi[i]:>20.15f} 0 0 0', file=f)

    # Cells
    print(f'*cf:    int            {ncvVx}    cvVx', file=f)
    wrap_line = 0
    for i in range(nCi):
        number_of_cell_vertices = len(cells[i].nodes)
        for j in range(number_of_cell_vertices):
            index = cells[i].nodes[j]
            wrap_line += 1
            print(f' {index:10d}', file=f, end='\n' if wrap_line%12 == 0 or wrap_line == ncvVx else '')

    print(f'*cf: cv cvVxP(:,1) cvVxP(:,2) cvX cvY psi bp bt cflags(:) cvReg cvFt', file=f)
    k1 = 1
    for i in range(nCi):
        number_of_cell_vertices = len(cells[i].nodes)
        print(f'{i+1:>10}  {k1:>10}  {number_of_cell_vertices} 0 0 0 0 0 0 0 0', file=f)
        k1 += number_of_cell_vertices
        
    # Faces
    print(f'*cf: fc fcVx(:,1) fcVx(:,2) fcLbl fcReg fcAligned', file=f)
    for i in range(nFc):
        node1 = faces[i].nodes[0]
        node2 = faces[i].nodes[1]
        print(f'{i+1:>10}  {node1:>10}  {node2:>10} 0 0 {1 if i+1 in x_aligned_indices else 0}', file=f)
        
    #Flux tubes
    #TODO:
    print(f'*cf: ft ftCvP(:,1) ftCvP(:,2) ftFcP(:,1) ftFcP(:,2) ftReg', file=f)
    print(f' 0 0 0 0 0 0 ', file=f)

    # Flux surface
    print(f'*cf: fs fsFcP(:,1) fsFcP(:,2) fsPsi ', file=f)
    start = 1
    for i, psi in enumerate(fsFc):
        num_of_psi_indices = len(fsFc[psi])
        print(f'{i+1:>10}  {start:>7}  {num_of_psi_indices:>5} {psi:>20.15f}', file=f)
        start += num_of_psi_indices
        
    print(f'*cf:    int             {nfsFc}    fsFc ', file=f)
    wrap_line = 0
    for psi in fsFc:
        for index in fsFc[psi]:
            wrap_line += 1
            print(f' {index:10d}', file=f, end='\n' if wrap_line%12 == 0 or wrap_line == nfsFc else '')

