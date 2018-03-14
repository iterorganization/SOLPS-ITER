      program ub2p
      use b2mod_types
      implicit none
#ifdef USE_MPI
      include 'mpif.h'
#endif
c======================================================================
c*** Creates the additional input files for b2plot, provided that the
c*** corresponding data is present in the dg output files.
c***
c*** The files are:
c***
c***  mesh.extra        data for "vesl" option
c***  <set_id>.<label>  lines for "chvl" option
c***  <set_id>.chr      chords files
c***
c*** The DG "dgo" file must be linked (or copied) to "param.dg"
c======================================================================
c  version : 25.08.97 15:04
c
#include "ubpcom.h"
#include "impcon.inc"
      external prgini,prgend,xerset,ubpnam
#ifdef USE_MPI
      integer rank_mpi,size_mpi,ierr_mpi
#endif
c======================================================================
c*** set up the input routine
#ifdef USE_MPI
      call mpi_init(ierr_mpi)
      call mpi_comm_rank(MPI_COMM_WORLD,rank_mpi,ierr_mpi)
      call mpi_comm_size(MPI_COMM_WORLD,size_mpi,ierr_mpi)
      if(rank_mpi .ne. 0) then
        call mpi_barrier(MPI_COMM_WORLD,ierr_mpi)
        call mpi_finalize(ierr_mpi)
        stop 'ub2p_mpi_child'
      endif
#endif
      call prgini('ub2p')
      call xerset(0)
c
      immed=.false.
      keylen=8
      mimp=iunii
      lena=ufnlen
c
c*** Read the data from DG output
c
      open(iunii,file='param.dg')
      call import(ubpnam)
c
c*** Create additional files for b2plot
c
      call ubpb2pl
c======================================================================
      call prgend ()
#ifdef USE_MPI
      call mpi_barrier(MPI_COMM_WORLD,ierr_mpi)
      call mpi_finalize(ierr_mpi)
#endif
      stop 'ub2p'
      end program ub2p
