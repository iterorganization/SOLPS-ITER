*-----------------------------------------------------------------------
*.specification

      program b2mn
      use b2mod_types
      use b2mod_version
      use b2mod_geo
      use b2mod_plasma
      use b2mod_rates
      use b2mod_residuals
      use b2mod_sources
      use b2mod_transport
      use b2mod_anomalous_transport
      use b2mod_work
      use b2mod_ma28
      use b2mod_indirect
      use b2mod_neutrals_namelist
      use b2mod_neutr_src_scaling
      use b2mod_ppout
      implicit none
csw 28feb2011 mpi
      include 'mpif.h'
      real*8 dumarr(100)
      logical ltrigger
csw

*-----------------------------------------------------------------------
*.documentation
*
*  1. purpose
*
*     B2MN is the main program for the b2 code. The code solves a
*     system of fluid equations that models a multi-species plasma
*     in a two-dimensional geometry. This program calls the driver
*     routine b2mndr for the actual computation.
*
*
*  2. specification
*
*     Main program.
*
*
*  3. description (see also routine b2cdca)
*
*     The b2 code /1,2/ solves a system of fluid equations that models
*     a multi-species plasma in a two-dimensional geometry. Its main
*     application is simulation of the edge plasma in tokamaks.
*
*     B2 is composed of several independent programs that communicate
*     through external files. The main sequence involves the programs
*     b2ag (prepares a geometry and magnetic field), b2ah (prepares
*     a table of default physics parameters), b2ai (prepares an
*     initial plasma state), b2mn (principal calculation), and b2yp
*     (post-processing).
*     Additional programs may prepare tables of rate coefficients for
*     atomic processes, tables of plasma-wall interaction processes,
*     external source terms, and other physics, or may perform further
*     post-processing.
*
*     The complete program b2mn is designed to solve the equations.
*     This program unit opens and closes the input/output units, and
*     may perform some other system-dependent operations. It calls
*     routine b2mndr to control the actual computation.
*
*     The input units are:
*     ninp(0): formatted; provides physics and numerics parameters.
*     ninp(1): un*formatted; provides the geometry.
*     ninp(2): un*formatted; provides default physics parameters.
*     ninp(3): un*formatted; provides the initial state.
*     ninp(4): un*formatted; provides atomic rate data.
*     ninp(5): un*formatted; provides source term data.
*
*     The output units are:
*     nout(0): formatted; provides summary print output.
*     nout(1): un*formatted; provides actual physics parameters.
*     nout(2): un*formatted; provides the final state.
*     nout(3): un*formatted; may provide data for movie.
*     nout(4): un*formatted; provides data on the numerical evolution.
*     nout(5): un*formatted; may provide detailed convergence data.
*     nout(6): un*formatted;
*     nout(7): un*formatted;
*     nout(8): formatted; post-processor output. [JET]
*
*     (See routine b2cdca for the meaning of 'un*formatted'.)
*
*
*  4. references
*
*     (Refs. /1/ and /2/ are out of date; !! to be replaced.)
*     /1/ B. J. Braams, "Computational Studies in Tokamak Equilibrium
*     and Transport", thesis, State University at Utrecht, June 1986.
*     /2/ B. J. Braams, "A Multi-Fluid Code for Simulation of the Edge
*     Plasma in Tokamaks", NET Report Nr 68, January 1987.
*
*
*  5. parameters (see also routine b2cdcv)
*
*     None.
*
*
*  6. error indicators
*
*     In case an error condition is detected, a call is made to the
*     routine xerrab. This causes an error message to be printed,
*     after which the program halts.
*
*
*  7. accuracy
*
*     As a measure of convergence we employ the scaled L1-norms of the
*     residuals of the individual equations (continuity for each
*     species, momentum balance for each species, electron heat
*     balance, atom heat balance, and charge balance). The scaling
*     provides numbers that have the dimension of (1/time). A reliable
*     estimate of the accuracy of a calculation can be obtained only
*     by continuing the calculation to better convergence.
*
*
*  8. further comments
*
*-----------------------------------------------------------------------
*.declarations

*   ..common blocks

*   ..local variables
#ifdef JET
      integer ninp(0:5), nout(0:8), nx, ny, ns, ns0, idum(0:9), io
#else
      integer ninp(0:5), nout(0:7), nx, ny, ns, ns0, idum(0:9), io
#endif
      integer, save :: istatus_file = 0                                !srv 14.10.09
*   ..procedures
      external prgini, prgend, xerset, xertst, cfopen, cfruin
      external b2mndr
*   ..initialise input/output unit numbers
      data ninp/50,51,52,53,54,55/
#ifdef JET
      data nout/60,61,62,63,64,65,66,67,68/
#else
      data nout/60,61,62,63,64,65,66,67/
#endif
*-----------------------------------------------------------------------
*.computation
crfs !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
crfs put here the other main programs b2ag (prepares geometry and
crfs  magnetic field), b2ah (prepares tables of default physics
crfs  parameters), b2ai (prepares an initial plasma state),
crfs !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

csw 28feb2011 mpi
      integer rank_mpi,size_mpi,ierr_mpi
      call mpi_init(ierr_mpi)
      call mpi_comm_rank(MPI_COMM_WORLD,rank_mpi,ierr_mpi)
      call mpi_comm_size(MPI_COMM_WORLD,size_mpi,ierr_mpi)
      if(rank_mpi .ne. 0) then
        call eirene_find_param
        do
          call mpi_bcast(ltrigger,1,MPI_LOGICAL,0,
     .                   MPI_COMM_WORLD,ierr_mpi)
          if(ltrigger) then
            call eirene_eirsrt(.false.,.false.,0.,dumarr,0,0,0,0,0.)
          else
            exit
          endif
        enddo
        call mpi_barrier(MPI_COMM_WORLD,ierr_mpi)
        call mpi_finalize(ierr_mpi)
        stop 'b2mn_mpi_child'
      endif
csw
*   ..program start-up calls
      call prgini ('b2mn')
!      call ipgeti ('b2mn_istatus_file', istatus_file)
*   ..open files
      call cfopen (ninp(0),'b2mn.dat','old','formatted')
      call cfopen (ninp(1),'b2fgmtry','old','un*formatted')
      call cfopen (ninp(2),'b2fpardf','old','un*formatted')
      call cfopen (ninp(3),'b2fstati','old','un*formatted')
      call cfopen (ninp(4),'b2frates','old','un*formatted')
*$$$  call cfopen (ninp(5),'b2fsourc','old','un*formatted')
*     (ninp(5) is reserved for interface to a neutral gas code)
      write(*,*) ' istatus_file = ', istatus_file
      if(istatus_file.eq.0) then
       call cfopen (nout(0),'b2mn.prt','new','formatted')
       call cfopen (nout(1),'b2fparam','new','un*formatted')
       call cfopen (nout(2),'b2fstate','new','un*formatted')
       call cfopen (nout(3),'b2fmovie','new','un*formatted')
       call cfopen (nout(4),'b2ftrace','new','un*formatted')
       call cfopen (nout(5),'b2ftrack','new','un*formatted')
       call cfopen (nout(7),'b2fplasma','new','unformatted')
      else
       call cfopen (nout(0),'b2mn.prt','replace','formatted')
       call cfopen (nout(1),'b2fparam','replace','un*formatted')
       call cfopen (nout(2),'b2fstate','replace','un*formatted')
       call cfopen (nout(3),'b2fmovie','replace','un*formatted')
       call cfopen (nout(4),'b2ftrace','replace','un*formatted')
       call cfopen (nout(5),'b2ftrack','replace','un*formatted')
       call cfopen (nout(7),'b2fplasma','replace','unformatted')
      endif
*   ..mark output unit for error messages
      call xerset (0)
*   ..obtain version numbers						 !xpb
      call cfverr (ninp(1), b2fgmtry_version)				 !xpb
      call cfverr (ninp(2), b2fparam_version)				 !xpb
      call cfverr (ninp(3), b2fstati_version)				 !xpb
*   ..obtain nx, ny from geometry file
      call cfruin (ninp(1), 2, idum, 'nx,ny')
      nx = idum(0)
      ny = idum(1)
      call xertst (0.le.nx.and.0.le.ny,
     &  'faulty input nx, ny from geometry file')
*   ..obtain ns from parameters file
      call cfruin (ninp(2), 1, idum, 'ns')
      ns = idum(0)
      call xertst (1.le.ns, 'faulty input ns from parameters file')
*   ..obtain nx, ny, ns0 from plasma state file
      call cfruin (ninp(3), 3, idum, 'nx,ny,ns')
      ns0 = idum(2)
      call xertst (idum(0).eq.nx.and.idum(1).eq.ny,
     &  'faulty input nx, ny from plasma state file')
      call xertst (1.le.ns0.and.ns0.le.ns,
     &  'faulty input ns from plasma state file')
*   ..call principal driver routine
      call alloc_b2mod_geo(nx,ny)
      call alloc_b2mod_plasma(nx,ny,ns)
      call alloc_b2mod_rates(nx,ny,ns)
      call alloc_b2mod_residuals(nx,ny,ns)
      call alloc_b2mod_sources(nx,ny,ns)
      call alloc_b2mod_transport(nx,ny,ns)
      call alloc_b2mod_anomalous_transport(nx,ny,ns)
      call alloc_b2mod_work(nx,ny,ns)
      call alloc_b2mod_indirect(nx,ny,nncutmax)                          !xpb
!      call alloc_b2mod_geo_corner(nx,ny)				 !xpb        !srv 08.07.13
      call alloc_b2mod_ppout(nx,ny,ns)
      call b2mndr (ninp, nout, nx, ny, ns, ns0)
*   ..write plasma state
      call cfverw(nout(7), newversion)
      call write_b2mod_geo(nout(7))
      call write_b2mod_plasma(nout(7))
      call write_b2mod_residuals(nout(7))
      call write_b2mod_sources(nout(7))
      call write_b2mod_transport(nout(7))
      call write_b2mod_anomalous_transport(nout(7))
      call write_b2mod_neutr_src_scaling(nout(7),nstrai)
      close(nout(7))
#ifdef JET
*   ..set and write ppout
      call cfopen (nout(8),'tran','new','unformatted')
      call set_b2mod_ppout
      call write_b2mod_ppout(nout(8))
      close (nout(8))
#endif
*   ..close files
      do io=0,size(ninp)-1
         close(ninp(io))
      enddo
      do io=0,5
         close(nout(io))
      enddo

* ..end of computation
      call prgend ()
csw 28feb2011 mpi
      ltrigger=.false.
      call mpi_bcast(ltrigger,1,MPI_LOGICAL,0,
     .                   MPI_COMM_WORLD,ierr_mpi)
      call mpi_barrier(MPI_COMM_WORLD,ierr_mpi)
      call mpi_finalize(ierr_mpi)
csw
      stop 'b2mn'

*-----------------------------------------------------------------------
*.end b2mn

      end program b2mn

