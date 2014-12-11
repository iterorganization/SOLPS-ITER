      integer function mesh_cell_ind(mrk,ir,iz)

c  version : 28.01.2003 18:10

c=======================================================================
c*** Find B2 grid cell indices for a DG grid cell index
c***
c*** Input:
c***  mrk   DG grid cell index
c*** 
c*** Output:
c***  ir,iz radial and poloidal B2 grid cell indices
c***
c*** Function returns 0 if the valid indices are found
c=======================================================================
      integer mrk,ir,iz
#include "uinpcom.inc"
      integer i,j,k,l,m,l_pfr,l_wll
      logical ex
c=======================================================================
c*** Ranges for the markers pointing to either a PFR edge (ir.le.l_pfr)
c*** either a wall edge (ir.gt.l_wll)

      mesh_cell_ind=-1
      if(nx.le.0 .or. nx.gt.nxd .or. ny.le.0 .or. ny.gt.nyd) return
      mesh_cell_ind=0
      iz=mod(mrk+1,nx+2)-1
      ir=mrk/nx
      if(ir.gt.ny+1) mesh_cell_ind=1
c=======================================================================
      end
