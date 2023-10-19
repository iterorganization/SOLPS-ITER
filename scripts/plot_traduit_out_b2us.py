#!/usr/bin/env python
# coding: utf-8
help="""Plot_traduit_out_b2us plots content of traduit.out.b2us formatted file

Plots a general unstructured ‘traduit.out.b2us’-file format as the basis to
further develop the interface between TIARA – GGD – SOLPS (b2ag). It makes no a
priori assumptions about grid structure, but does include some fields/options
to specify whether for example faces are aligned with the field etc. A
structured grid can of course also easily be written in this format. 

Tested on the following examples:

files = ['traduit.out.b2us.target',   # unstructured AUG file
         'traduit.out.b2us.standard', # structured AUG file
         'traduit.out.b2us_iter',     # unstructured ITER file
         'tiara.122408_4_b2us',       # unstructured ITER file from TIARA
        ]

Examples for an AUG case to play with: one for a standard structured grid. Has
isClassicalGrid=1 (can be mapped back to a structured grid), and includes the
relevant mapping information to do this one for a target-mode grid. In
principle could also have “isClassicalGrid=1” and be mapped back to a
structured grid, but we set “isClassicalGrid=0” here to show what a file for a
truly unstructured grid would look like (i.e. it excludes the info on mapping
back to structured format)

# Description of traduit.out.b2us file format

File format proposed to provide unstructured grid info to B2.5 code, for
creation of the b2fgmtry file with b2ag. The format follows the typical
format of B2.5 input files.

## File structure

The following lines/fields/variables are contained in the file:

- Header line with version number
   TBD: should contain name & version number of the grid generation tool?

- *cf:    int                6    nCi,nFc,nVx,nCg,nFs,nFt
  Line containing characteristic grid dimensions:
         - nCi: number of true plasma cells (“Control Volumes”), excluding guard 
           cells (see below). Eventually, the total number of cells in the 
           simulation will be nCv = nCi + nCg
         - nFc: number of faces
         - nVx: number of vertices
         - nCg: number of “guard cells” needed to impose boundary conditions. 
           Note: the actual guard cells are currently not included in the file,
           but will be added/created by b2ag
         - nFs: number of flux surfaces (if any). A flux surface is a continuous 
           set of faces aligned with the magnetic field
         - nFt: number of flux tubes (if any). A flux tube is a continuous set 
           of cells in between two flux surfaces

- *cf:    int                5    nCmxVx,nCmxFc,nFmxCv,nVmxCv,nVmxFc 
  Line containing some dimensions for the mapping arrays:
  (Note: some of these numbers are currently not needed for the arrays in 
  traduit.out.b2us, but only for further grid preparation by b2ag. Eventually 
  might be removed from this input file, and computed in b2ag.)
         - nCmxVx: dimension of cvVx array
         - nCmxFc: dimension of cvFc array
         - nFmxCv: dimension of fcCv array
         - nVmxCv: dimension of vxCv array
         - nVmxFc: dimension of vxFc array

- *cf:    int                1    isClassicalGrid
  Switch describing whether grid is based on underlying structured topology
  (1) or not (0)

- *cf:    int                3    nx,ny,nncut 
  Only for grids based on structured grid. If grid based on underlying 
  structured grid, the corresponding dimensions of that grid
         - nx: number of poloidal cells (excl. guard cells)
         - ny: number of radial cells (excl. guard cells)
         - nncut: number of cuts

- *cf: Vx vxX vxY vxPsi vxBx vxBy vxFfbz
  Array with vertex data; dimension (nVx, 7)
         - Vx: vertex number
         - vxX: X-coordinate (typically: ‘R’) of the vertex
         - vxY: Y-coordinate (typically: ‘Z’) of the vertex
         - vxPsi: Psi-value of the vertex
         - vxBx: x-component of the magnetic field in the vertex
         - vxBy: y-component of the magnetic field in the vertex
         - vxFfbz: value of toroidal flux function in the vertex

- *cf: cv cvVxP(:,1) cvVxP(:,2) cvX cvY psi bp bt cflags(:) cvReg cvFt
  Array with cell center data; dimension (nCi, 11)
         - cv: number of the cell
         - cvVxP(iCv,1): index in cvVx array where vertex list of the cell iCv
           starts
         - cvVxP(iCv,2): number of vertices corresponding to the cell iCv
         - cvX: X-coordinate (typically: ‘R’) of the cell center
           (possibly recomputed by the code)
         - cvY: Y-coordinate (typically: ‘Z’) of the cell center
           (possibly recomputed by the code)
         - psi: psi-value at the cell center
         - bp: poloidal field at the cell center (note: currently not used –
           recomputed based on vertex values)
         - bt: toroidal field at the cell center  (note: currently not used –
           recomputed based on vertex values)
         - cflags: indicator for type of cell; cf Carre2 convention. Available
           values at the moment:
             - 0: unlabeled/neglected cell
             - 1: internal plasma cell (not in contact with boundary)
             - 2: external/isolated cell
             - 3: boundary cell (true plasma cell, with at least one face a
               boundary face)
             - 9: guard cell
         - cvReg: region flag (cf. region(:,:,0) of structured code)
         - cvFt: index of the flux tube the cell belongs to (if any)

- *cf:    int            22461    cvVx
  Array containing list of vertices corresponding to each cell. Dimensions
  (1:nCmxVx). To be combined with cvVxP-array to access individual cell info.

- *cf:    int            22461    cvFc
  Array containing list of faces corresponding to each cell. Dimensions
  (1:nCmxFc). To be combined with cvFcP-array to access individual cell info.

- *cf: fc fcVx(:,1) fcVx(:,2) fcLbl fcReg fcAligned
  Array with face data; dimension (nFc, 6)
         - fc: number of the face
         - fcVx(:,1): index of first vertex of the face
         - fcVx(:,2): index of second vertex of the face
         - fcLbl: face label for boundary condition/recycling stratum
           specification
         - fcReg: region flag for the face. For conversion of structured grids:
             - fcReg = region(:,:,1) for ‘poloidal’ faces
             - fcReg = region(:,:,2) + max(region(:,:,1)) for ‘radial’ faces
         - fcAligned: flag to indicate face alignment
             - 0:  indicates that the face is not aligned with the poloidal
               magnetic field 
             - 1: indicates that the face is aligned with the poloidal magnetic
               field (used for numerically precise computations of some
               geometric quantities)

- *cf: ft ftCvP(:,1) ftCvP(:,2) ftFcP(:,1) ftFcP(:,2) ftReg 
  Array with flux tube data; dimension (nFt, 6)
         - ft: number of the flux tube
         - ftCvP(:,1): starting point of cell list corresponding to this flux
           tube in ftCv
         - ftCvP(:,2): number of cells in the flux tube
         - ftFcP(:,1): starting point of face list corresponding to this flux
           tube in ftFc
         - ftFcP(:,2): number of faces in the flux tube
         - ftReg: region label of the flux tube

- *cf:    int             1782    ftCv
  Array containing list of cells corresponding to each flux tube. Dimensions
  (1:nCi). To be combined with ftCvP-array to access individual flux tube
  info.

- *cf:    int             1783    ftFc
  Array containing list of faces corresponding to each flux tube. Dimensions
  (1:nFc). To be combined with ftFcP-array to access individual flux tube
  info.

- *cf: fs fsFcP(:,1) fsFcP(:,2) fsPsi 
  Array with flux surface data; dimension (nFs, 4)
         - fs: number of the flux surface
         - fsFcP(:,1): starting point of face list corresponding to this flux
           surface in fsFc
         - fsFcP(:,2): number of faces in the flux surface
         - fsPsi: psi-value of the flux surface

- *cf:    int             5827    fsFc
  Array containing list of faces corresponding to each flux surface. Dimensions
  (1:nFc). To be combined with fsFcP-array to access individual flux surface
  info.

- *cf:    int             6345    
  imapCv Only for grids based on structured grid. Array containing for each cell 
  in the structured grid, the corresponding cv number in the unstructured list. 
  Dimensions (-1:nx,-1:ny).

- *cf:    int             6345    imapFcx
  Only for grids based on structured grid. Array containing for each poloidal
  face in the structured grid, the corresponding face number in the
  unstructured list. Dimensions (-1:nx,-1:ny).

- *cf:    int             6345    imapFcy
  Only for grids based on structured grid. Array containing for each radial face
  in the structured grid, the corresponding face number in the unstructured
  list. Dimensions (-1:nx,-1:ny).

- *cf:    int             6345    imapVx
  Only for grids based on structured grid. Array containing for each vertex in
  the structured grid, the corresponding vertex number in the unstructured
  list. Dimensions (-1:nx,-1:ny).

"""

import numpy as np
import re
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon 
import argparse

vector_type = {
    'Vx': 'nVx', 'vxX': float, 'vxY': float, 'vxPsi':float,                 # Vx
    'vxBx': float, 'vxBy': float, 'vxFfbz': float,   
    'cv': 'nCi', 'cvVxP1': int, 'cvVxP2': int, 'cvX': float, 'cvY': float,  # cv
    'psi': float, 'bp': float, 'bt': float, 'cflags': int,
    'cvReg': int, 'cvFt': int,              
    'fc': 'nFc', 'fcVx1': int, 'fcVx2': int, 'fcLbl': int, 'fcReg': int,    # fc
    'fcAligned':int,               
    'ft': 'nFt', 'ftCvP1': int, 'ftCvP2': int, 'ftFcP1': int, 'ftFcP2': int,# ft
    'ftReg': int,                
    'fs': 'nFs', 'fsFcP1': int, 'fsFcP2': int, 'fsPsi': float,              # fs              
}
class CustomFormatter(argparse.ArgumentDefaultsHelpFormatter, 
                      argparse.RawTextHelpFormatter):
    pass

description="A program that generate plots for b2us files."
parser = argparse.ArgumentParser(description=help,
                                 formatter_class=CustomFormatter)

parser.add_argument('input_file', type=str, help="Input data file in b2us format")
parser.add_argument('-t', '--plot-type', default=0, type=int, 
                    help='Plot type:\n'
                         '0: all plots (default),\n'
                         '1: vertices,\n'
                         '2: vertices+vxPsi,\n'
                         '3: cells,\n'
                         '4: faces,\n'
                         '5: flux_tube_cells,\n'
                         '6: flux_tube_faces,\n'
                         '7: flux surface,\n'
                         '8: flux surface + fsPsi,\n'
                         '9: DivDeo template file')
parser.add_argument('-o', '--ogr',metavar='FILE', default='divgeo.ogr', type=str,
   help='Saves as mesh in DivGeo template format if --plot-type=9')
args = parser.parse_args()

plot_type = args.plot_type 

#Read the b2us files which are stored in Downloads.
with open(args.input_file, 'r') as file:
    lines=file.readlines()
for i in range(0, len(lines)):
    if lines[i].startswith("*cf:"):
        line_without_arrays = re.sub(r'\(:,*([1-9]*)\)', r'\1', lines[i]).strip()
        line = re.split(r'[ ,]+', line_without_arrays)
        data_type = line[1]
        if data_type in ('int', 'real'):
            if data_type == 'real':
                dtype = 'float'
            else:
                dtype = 'int'
            num_elements = int(line[2])
            if num_elements > len(line)-3: # array of values e.g. nCmxVx,nCmxFc,
                array_name = line[3]
                array_size = line[2]
                exec( f"{array_name} = np.empty(({array_size}), dtype={dtype})")
                j = 0
                while j < num_elements:
                    i += 1
                    values = np.fromstring(lines[i],dtype=dtype, sep=' ')
                    exec(f"{array_name}[{j}:{j+values.size}] = values")
                    j += values.size              
            else: # singletons, read next line only
                i += 1
                values = re.findall(r'\d+', lines[i])
                for var in range(len(values)):
                    exec(line[var+3] + '=' + values[var])
                    
        elif data_type in vector_type:
            exec(f'vector_size = {vector_type[data_type]}')
            exec(f'{data_type} = np.empty({vector_size}, dtype=int)')
            for vector_name in line[2:]:
                exec(f'{vector_name} = np.empty({vector_size},'
                     f' dtype={vector_type[vector_name].__name__})')
            for j in range(vector_size):
                lhs_tuple_str = ', '.join([_+'[j]' for _ in line[1:]])
                exec(f"({lhs_tuple_str}) = np.fromstring(lines[i+1+j],"
                      " dtype=float, sep=' ')")
            i += 1 + vector_size
        else:
            print(f"Warning: Unhandled {data_type}")
#print(nCi,nFc,nVx,nCg,nFs,nFt,isClassicalGrid)


# # Plot of vertices vxX and vxY
if plot_type in (0, 1):
    fig1 = plt.figure(figsize=(7, 7)) 
    ax = fig1.add_subplot(111, aspect='equal')

    plt.plot(vxX, vxY, '.')
        
    ax.set_xlim((min(vxX)-0.1, max(vxX)+0.1)) 
    ax.set_ylim((min(vxY)-0.1, max(vxY)+0.1))
    plt.xlabel('R [m]')
    plt.ylabel('Z [m]')
    plt.title('Vertices ')
    plt.show()

# # Plot of vertices vxX and vxY + vxPsi
if plot_type in (0, 2):
    fig2 = plt.figure(figsize=(7, 7))
    ax = fig2.add_subplot(111, aspect='equal')

    # Create a scatter plot with color mapping based on vxPsi values
    sc = plt.scatter(vxX, vxY, c=vxPsi, cmap='plasma', marker='.', s=25)

    ax.set_xlim((min(vxX)-0.1, max(vxX)+0.1))
    ax.set_ylim((min(vxY)-0.1, max(vxY)+0.1))
    plt.xlabel('R [m]')
    plt.ylabel('Z [m]')
    plt.title('Vertices')
    plt.colorbar(sc, label='vxPsi [Wb]')

    plt.show()


# # Plot of cells
if plot_type in (0, 3):
    fig3 = plt.figure(figsize=(7, 7)) 
    ax = fig3.add_subplot(111, aspect='equal')

    for i in range(nCi):
    #     print(cvVxP1[i], cvVxP2[i])
        cvVx_start = cvVxP1[i] - 1
        number_of_vertices = cvVxP2[i]
        cell_vertices = []
        for j in range(number_of_vertices):
            vertex_number = cvVx[cvVx_start+j] - 1
            cell_vertices.append([vxX[vertex_number], vxY[vertex_number]])
            #print(i, vertex_number, vxX[vertex_number], vxY[vertex_number])
        ax.add_patch(Polygon(cell_vertices, closed=True,fill=False))
        
    ax.set_xlim((min(vxX)-0.1, max(vxX)+0.1)) 
    ax.set_ylim((min(vxY)-0.1, max(vxY)+0.1))
    plt.xlabel('R [m]')
    plt.ylabel('Z [m]')
    plt.title('Cells')
    plt.show()


# # Plot of faces
if plot_type in (0, 4):
    fig4, (ax1, ax2) = plt.subplots(1, 2, figsize=(7, 7))

    # Aligned Faces
    ax1.set_aspect('equal')
    for i in range(nFc):
        if fcAligned[i] == 1:
            fcVx_first_point = fcVx1[i] - 1
            fcVx_second_point = fcVx2[i] - 1

            first_point = [vxX[fcVx_first_point], vxY[fcVx_first_point]]
            second_point = [vxX[fcVx_second_point], vxY[fcVx_second_point]]
            face_points = np.array([first_point, second_point])
            ax1.add_patch(Polygon(face_points, closed=False, fill=False))

    ax1.set_xlim((min(vxX)-0.1, max(vxX)+0.1))
    ax1.set_ylim((min(vxY)-0.1, max(vxY)+0.1))
    ax1.set_xlabel('R [m]')
    ax1.set_ylabel('Z [m]')
    ax1.set_title('Aligned Faces')

    # Non-aligned Faces
    ax2.set_aspect('equal')
    for i in range(nFc):
        if fcAligned[i] == 0:
            fcVx_first_point = fcVx1[i] - 1
            fcVx_second_point = fcVx2[i] - 1

            first_point = [vxX[fcVx_first_point], vxY[fcVx_first_point]]
            second_point = [vxX[fcVx_second_point], vxY[fcVx_second_point]]
            face_points = np.array([first_point, second_point])
            ax2.add_patch(Polygon(face_points, closed=False, fill=False))

    ax2.set_xlim((min(vxX)-0.1, max(vxX)+0.1))
    ax2.set_ylim((min(vxY)-0.1, max(vxY)+0.1))
    ax2.set_xlabel('R [m]')
    ax2.set_title('Non-aligned Faces')

    plt.show()

# # Plot of flux_tube_cells
if plot_type in (0, 5):  
    if 'nFt' in locals() and 'ftCvP1' in locals() and 'ftCvP2' in locals() and \
      'ftCv' in locals() and 'cvVxP1' in locals() and 'cvVxP2' in locals() and \
      'cvVx' in locals() and 'vxX' in locals() and 'vxY' in locals():    

        fig5 = plt.figure(figsize=(7, 7)) 
        ax = fig5.add_subplot(111, aspect='equal')
        for i in range(nFt):
            ftCv_start = ftCvP1[i] - 1
            number_of_cells = ftCvP2[i]
            flux_tube_cells = []
            color = plt.cm.jet(i / nFt)
            for j in range(number_of_cells):
                cell_number = ftCv[ftCv_start+j] - 1
                cvVx_start = cvVxP1[cell_number] - 1 
                number_of_vertices = cvVxP2[cell_number] 
                cell_vertices = []
                for k in range(number_of_vertices):
                    vertex_number = cvVx[cvVx_start+k] - 1
                    cell_vertices.append([vxX[vertex_number], vxY[vertex_number]])

                ax.add_patch(Polygon(cell_vertices, closed=True, fill=False, \
                edgecolor=color))

        ax.set_xlim((min(vxX)-0.1, max(vxX)+0.1)) 
        ax.set_ylim((min(vxY)-0.1, max(vxY)+0.1))
        plt.xlabel('R [m]')
        plt.ylabel('Z [m]')
        plt.title('Flux tube-cells')
        plt.show()
    else:
        print('Warning: Required data is missing for plot of flux_tube_cells.')

# # Plot of flux_tube_faces
if plot_type in (0, 6): 
    if 'nFt' in locals() and 'ftFcP1' in locals() and 'ftFcP2' in locals() \
        and 'ftFc' in locals() and 'fcVx1' in locals() and 'fcVx2' in locals() \
        and 'vxX' in locals() and 'vxY' in locals():      

        fig6 = plt.figure(figsize=(7, 7))
        ax = fig6.add_subplot(111, aspect='equal')

        for i in range(nFt):
            ftFc_start = ftFcP1[i] - 1
            number_of_faces_flux_tube = ftFcP2[i]
            color = plt.cm.jet(i / nFt)

            for j in range(number_of_faces_flux_tube):
                face_number = ftFc[ftFc_start + j] - 1
                fcVx_first_point = fcVx1[face_number] - 1
                fcVx_second_point = fcVx2[face_number] - 1
                first_point = [vxX[fcVx_first_point], vxY[fcVx_first_point]]
                second_point = [vxX[fcVx_second_point], vxY[fcVx_second_point]]
                face_points = np.array([first_point, second_point])

                ax.add_patch(Polygon(face_points, closed=False, fill=False,
                    edgecolor=color))

        ax.set_xlim((min(vxX) - 0.1, max(vxX) + 0.1))
        ax.set_ylim((min(vxY) - 0.1, max(vxY) + 0.1))
        plt.xlabel('R [m]')
        plt.ylabel('Z [m]')
        plt.title('Flux tube-faces')
        plt.show()
    else:
        print("Warning: Required data is missing for plot of flux_tube_faces.")

# # Plot of flux surface
if plot_type in (0, 7):
    fig7 = plt.figure(figsize=(7, 7)) 
    ax = fig7.add_subplot(111, aspect='equal')

    for i in range(nFs):
    #     print(fsFcP1[i], fsFcP2[i])
        fsFc_start = fsFcP1[i] - 1
        number_of_faces = fsFcP2[i]

        for j in range(number_of_faces):
            face_number = fsFc[fsFc_start+j] - 1
            fcVx_first_point = fcVx1[face_number] - 1
            fcVx_second_point = fcVx2[face_number] - 1
            first_point=[vxX[fcVx_first_point],vxY[fcVx_first_point]]
            second_point=[vxX[fcVx_second_point],vxY[fcVx_second_point]]
            face_points = np.array([first_point, second_point])
            ax.add_patch(Polygon(face_points, closed=False,fill=False))

    ax.set_xlim((min(vxX)-0.1, max(vxX)+0.1)) 
    ax.set_ylim((min(vxY)-0.1, max(vxY)+0.1))
    plt.xlabel('R [m]')
    plt.ylabel('Z [m]')
    plt.title('Flux surface')
    plt.show()    

# # Plot of flux surface + fsPsi
if plot_type in (0, 8):
    fig8 = plt.figure(figsize=(7, 7))
    ax = fig8.add_subplot(111, aspect='equal')

    # Calculate the minimum and maximum values of fsPsi
    fsPsi_min = np.min(fsPsi)
    fsPsi_max = np.max(fsPsi)

    for i in range(nFs):
    #     print(fsFcP1[i], fsFcP2[i])
        fsFc_start = fsFcP1[i] - 1
        number_of_faces = fsFcP2[i]
    #     print(number_of_faces)

        for j in range(number_of_faces):
            face_number = fsFc[fsFc_start+j] - 1
            fcVx_first_point = fcVx1[face_number] - 1
            fcVx_second_point = fcVx2[face_number] - 1
            first_point=[vxX[fcVx_first_point],vxY[fcVx_first_point]]
            second_point=[vxX[fcVx_second_point],vxY[fcVx_second_point]]
            face_points = np.array([first_point, second_point])
            ax.add_patch(Polygon(face_points, closed=False,fill=False))
            
            # Calculate the color based on fsPsi value
            fs_value = fsPsi[i]
            normalized_value = (fs_value - fsPsi_min) / (fsPsi_max - fsPsi_min)
            color = plt.cm.jet(normalized_value)

            ax.add_patch(Polygon(face_points, closed=False, fill=False, 
                edgecolor=color))

    ax.set_xlim((min(vxX) - 0.1, max(vxX) + 0.1))
    ax.set_ylim((min(vxY) - 0.1, max(vxY) + 0.1))
    plt.xlabel('R [m]')
    plt.ylabel('Z [m]')
    plt.title('Flux surface')

    # Create a colorbar to show the mapping of colors to fsPsi values
    norm = plt.Normalize(vmin=fsPsi_min, vmax=fsPsi_max)
    sm = plt.cm.ScalarMappable(cmap=plt.cm.jet, norm=norm)
    sm.set_array([])  # Set an empty array to avoid warning
    cbar = plt.colorbar(sm, ax=ax)
    cbar.set_label('fsPsi [Wb]')

    plt.show()

if plot_type == 9:
    with open(args.ogr, 'w') as f:
        for i in range(nFc):
            fcVx_first_point = fcVx1[i] - 1
            fcVx_second_point = fcVx2[i] - 1

            first_point = [vxX[fcVx_first_point] * 1000, vxY[fcVx_first_point] * 1000]
            second_point = [vxX[fcVx_second_point] * 1000, vxY[fcVx_second_point] * 1000]
            face_points = np.array([first_point, second_point])

            np.savetxt(f, face_points, fmt='%.8f', delimiter='    ')
            f.write('\n')  # Add an empty line after each pair of points
