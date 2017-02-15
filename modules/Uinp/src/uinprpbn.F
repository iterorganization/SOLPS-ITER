      subroutine uinprpbn
c
c  version : 22.01.2003 20:03
c
      external subini, subend
c=======================================================================
c*** Prepare the data on the boundary conditions at the grid edges
c=======================================================================
      call subini ('uinprpbn')

c*** Determine the gross boundary regions

      call uinbndrg

c*** Determine the boundary zones

      call uinbndzn

c*** Fill in the data for explicitly specified zones

      call uinbndxp

c*** Fill in the default data

      call uinbndfl

c*** Assign material properties of the grid edges (Eirene)

      call uinprpge

c*** Prepare the data for B2-Eirene input files

      call uinbnddt

c=======================================================================
      call subend ()
      return
      end
