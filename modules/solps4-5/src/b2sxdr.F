*-----------------------------------------------------------------------
*.specification

      program b2sxdr
      use b2mod_types
      use b2mod_geo
      use b2mod_work
      use b2mod_rates
      use b2mod_plasma
      use b2mod_indirect
      use b2mod_geo_corner
      use b2mod_residuals
      use b2mod_transport
      use b2mod_constants
     , , only : mp
      use b2mod_sources
      use b2mod_anomalous_transport
      use b2mod_neutrals_namelist
     , , only : nstraid
      use b2mod_neutr_src_scaling
      use b2mod_version
      use b2_4to5
      use b2mod_b2cmpa
     , , only : am, zamin, zamax, zn
      use b2mod_b2cmpb
      use b2mod_b2cmpt
      use b2mod_b2cmfs
      use parmmod
      use ccoupl, only : alloc_ccoupl
      use ctrcei, only : alloc_ctrcei
      use cgeom, only : alloc_cgeom
      use csdvi, only : alloc_csdvi
      use clogau, only : alloc_clogau
      use cpolyg, only : alloc_cpolyg
      use cadgeo, only : alloc_cadgeo
      use comusr, only : alloc_comusr, eirene96
      use cplot, only : alloc_cplot
      use cai, only : alloc_cai
      use cestim, only : alloc_cestim
      use comprt, only : alloc_comprt
      use cinit, only : alloc_cinit
      use cupd, only : alloc_cupd
      use cgrid, only : alloc_cgrid
      use cspez, only : alloc_cspez
      use czt1, only : alloc_czt1
      use ctext, only : alloc_ctext
      use ctetra, only : alloc_ctetra
      use cpes, only : alloc_cpes, nprs, my_pe
      use comsou, only : alloc_comsou
      use comspl, only : alloc_comspl
      use clgin, only : alloc_clgin
      use comxs, only : alloc_comxs
      use comnnl, only : alloc_comnnl
      use ctrig, only : alloc_ctrig
      use braeir, only : alloc_braeir
      use eirdiag, only : alloc_eirdiag
      use b2mod_dimensions
      implicit none
*   ..common blocks

*-----------------------------------------------------------------------
*.documentation
*
*  1. purpose
*
*     B2SXDR converts a B2SXDR output file from version 4.0 of the code
*     to a b2fstati file ready for use as input file for the SOLPS5.0 code.
*
*  2. specification
*
*     Main program.
*
*  3. description (see also routine b2cdca)
*
*     The input units are:
*     ninp(0): formatted; provides physics and numerics parameters.
*
*     The output units are:
*     nout(0): formatted; provides summary print output.
*     nout(1): un*formatted; provides the geometry.
*     nout(2): un*formatted; provides the converted final state.
*     nout(3): un*formatted; provides default physics parameters.
*     nout(4): unformatted; provides the detailed final state.
*
*     (See routine b2cdca for the meaning of 'un*formatted'.)
*
*     nx, ny - integer, input.
*     nx and ny specify the number of interior cells along the first
*     and the second coordinate, respectively. The total number of
*     cells is (nx+2)*(ny+2); they are indexed by (-1:nx,-1:ny).
*     It will hold that 0.le.nx and 0.le.ny.
*
*     ns - integer, input.
*     ns specifies the number of atomic species in the calculation.
*     The species are indexed by (0:ns-1).
*     It will hold that 1.le.ns.
*
*     ns0 - integer, input.
*     ns0 specifies the number of atomic species in the data file
*     for the initial state.  The initial data for species (0:ns0-1)
*     are taken from that file, while the initial densities for species
*     (ns0:ns-1) are set to some very small value.
*     It will hold that 1.le.ns0.le.ns.
*
*  4. references
*
*     (Refs. /1/ and /2/ are out of date; !! to be replaced.)
*     /1/ B. J. Braams, "Computational Studies in Tokamak Equilibrium
*     and Transport", thesis, State University at Utrecht, June 1986.
*     /2/ B. J. Braams, "A Multi-Fluid Code for Simulation of the Edge
*     Plasma in Tokamaks", NET Report Nr 68, January 1987.
*
*  5. parameters (see also routine b2cdcv)
*
*     /b2cmpa/ specifies basic physics parameters.
*      nsdecl - integer constant.
*     nsdecl is an upper bound for the number of species (ns), and is
*     used in dimension specifications.
*      zamin, zamax, zn, am - (0:nsdecl-1) real*8 array.
*     For (is) in (0:ns-1), zn(is) specifies the nuclear charge of
*     species (is), am(is) specifies its atomic mass, and zamin(is) and
*     zamax(is) specify its atomic charge range. All are dimensionless.
*     It will hold that 0.le.zamin(is).le.zamax(is), 0.lt.zn(is) and
*     0.lt.am(is). It is required that neutral species not be bundled
*     with charged species.
*     For ns.le.is.lt.nsdecl, zamin(is), zamax(is), zn(is), am(is)
*     are undefined.
*
*  6. error indicators
*
*     In case an error condition is detected, a call is made to the
*     routine xerrab. This causes an error message to be printed,
*     after which the program halts.
*
*  8. further comments
*
*-----------------------------------------------------------------------
*.declarations

*   ..local variables
      integer nout(0:4), idum(0:9), nx, ny, ns
      integer is, it, ix, iy, n2
      real (kind=R8) :: xcnt, ycnt, scale
      real (kind=R8) :: parg(0:99)
      real (kind=R8), allocatable :: wrk(:,:,:)
      logical ex
      character filename*80, lblgm*120, lblmn*120, idout*80
      character*8 device
#ifndef NO_GETENV
      integer lenval, ierror
#ifndef USE_PXFGETENV
      intrinsic get_environment_variable
#endif
#endif
*   ..procedures
      logical streql
      external prgini, prgend, xerset_5, xertst
      external cfopen, streql
      external b2wups, b2wuzd, b2xgbs
      external intfaceh1, intfacer1, intfacev1
*   ..initialisation
      data nout/60,61,62,63,64/
*-----------------------------------------------------------------------
*.computation
*   ..program start-up calls
      nprs = 1
      my_pe = 0
      call prgini ('b2sxdr')
c=================================================================
c*** Read the old data from the input file (b2.parameters.src) and
c*** the source file (B2SXDR)
c
      call default
      filename = 'b2.parameters.src'
      call init(filename)
      call b2rw(.true.)
      call init(filename)
*   ..open files
      call cfopen (nout(0),'b2sxdr.prt','new','formatted')
      call cfopen (nout(1),'b2fgmtry','new','un*formatted')
      call cfopen (nout(2),'b2fstati','new','un*formatted')
      call cfopen (nout(3),'b2fparam','new','un*formatted')
      call cfopen (nout(4),'b2fplasma','new','unformatted')
*   ..mark output unit for error messages
      call xerset_5 (0)
*   ..import parameters from Eirene input.dat file
      inquire(file='input.dat',exist=ex)
      if (ex) then
        STANDARD_INPUT=45
        open(unit=45,file='input.dat')
        CALL FIND_PARAM
        CALL SET_PARMMOD(1)
        write(*,*) 'Called FIND_PARAM'
        write(*,*) '   NDX = ',NDX
        write(*,*) '   NDY = ',NDY
        write(*,*) ' NSTRA = ',NSTRA
        write(*,*) '   NFL = ',NFL
        write(*,*) '  NATM = ',NATM
        write(*,*) '  NMOL = ',NMOL
        write(*,*) '  NION = ',NION
        write(*,*) '  NPLS = ',NPLS
        write(*,*) 'NLMPGS = ',NLMPGS
        CALL ALLOC_CLOGAU
        CALL ALLOC_COMPRT
        CALL ALLOC_CESTIM(1)  !VKMPI
        CALL ALLOC_COMUSR(1)
        CALL ALLOC_CADGEO
        CALL ALLOC_CAI
!pb      CALL ALLOC_CGRPTL
        CALL ALLOC_CPLOT
        CALL ALLOC_CINIT
        CALL ALLOC_CUPD
        CALL ALLOC_CPOLYG
        CALL ALLOC_CGRID
        CALL ALLOC_CSPEZ
        CALL ALLOC_CZT1(1)
        CALL ALLOC_CTRCEI
        CALL ALLOC_CGEOM(1) !VK (1)
        CALL ALLOC_CSDVI(1)
        CALL ALLOC_CTETRA
        CALL ALLOC_CPES
        CALL ALLOC_COMSOU(1)
        CALL ALLOC_COMSPL
        CALL ALLOC_CTEXT(1)
        CALL ALLOC_CLGIN
        CALL ALLOC_COMXS(1)
        CALL ALLOC_CTRIG
        CALL ALLOC_COMNNL
        CALL ALLOC_CCOUPL(1)
        CALL SETCON
      endif
      if (.not.ex) then
        natm = DEF_NATM
        nmol = DEF_NMOL
        nion = DEF_NION
        npls = DEF_NPLS
        nlim = DEF_NLIM
        nsts = DEF_NSTS
        nstra = DEF_NSTRA
        nsrfs = DEF_NSRFS
        nlmpgs = DEF_NLIM+DEF_NSTS
      end if
*   ..conversion calls
      call b2conv_plasma_1
      call b2conv_plasma_2(nx,ny,ns,lblgm)
      n2 = (nx+2)*(ny+2)
      call xertst (1.le.n2, 'faulty parameter n2')
*   ..interpolate velocities here
cxpb Next line not needed if inherited from UPC instead!
      call map4_5x(nx,ny,ns,crx,cry,vol,bb,ua)
      allocate(wrk(-1:nx,-1:ny,0:ns-1))
      wrk = uadia(-1:nx,-1:ny,0,0,0:ns-1)
      call map4_5x(nx,ny,ns,crx,cry,vol,bb,wrk)
      uadia(-1:nx,-1:ny,0,0,0:ns-1) = wrk
      wrk = uadia(-1:nx,-1:ny,1,1,0:ns-1)
      call map4_5y(nx,ny,ns,crx,cry,vol,bb,wrk)
      uadia(-1:nx,-1:ny,1,1,0:ns-1) = wrk
      deallocate(wrk)
      ua0 = ua
      uap = ua
      vadia = uadia
      wadia = uadia
      vedia = 0.0_R8
      do is = 0, ns-1
        kinrgy(-1:nx,-1:ny,is) =
     .   0.5_R8 * am(is) * mp * ua(-1:nx,-1:ny,is)**2
        fmo(-1:nx,-1:ny,0,0,is) =
     .   am(is) * mp * ua(-1:nx,-1:ny,is) * fna(-1:nx,-1:ny,0,0,is)
        fmo(-1:nx,-1:ny,1,1,is) =
     .   am(is) * mp * ua(-1:nx,-1:ny,is) * fna(-1:nx,-1:ny,1,1,is)
        vedia(-1:nx,-1:ny,0,0) = vedia(-1:nx,-1:ny,0,0) +
     .   uadia(-1:nx,-1:ny,0,0,is) *
     .   rza(-1:nx,-1:ny,is) * na(-1:nx,-1:ny,is) / ne(-1:nx,-1:ny)
        vedia(-1:nx,-1:ny,1,1) = vedia(-1:nx,-1:ny,1,1) +
     .   uadia(-1:nx,-1:ny,1,1,is) *
     .   rza(-1:nx,-1:ny,is) * na(-1:nx,-1:ny,is) / ne(-1:nx,-1:ny)
      enddo
*  ..output
      idout = '....'
*   ..write summary of geometry
      call b2wfgm (nout(0), idout, nx, ny)
*   ..write version number
      call cfverw (nout(1), newversion)
*   ..save dimensions
      idum(0) = nx
      idum(1) = ny
      call cfwuin (nout(1), 2, idum, 'nx,ny')
*   ..save label
      call cfwuch (nout(1), 120, lblgm, 'label')
      lblmn = lblgm
*   ..save isymm (default = 1)
      idum(0) = 1
      call cfwuin (nout(1), 1, idum, 'isymm')
c-xpb-end
*  ..interpolate magnetic field to cell faces
c!!!This interpolation scheme does not guarantee that bb(3)=sqrt(bb(0:2)**2)!!!
      call intfaceh1(nx,ny,2,leftix,leftiy,vol,bb,wbbl)
      call intfacer1(nx,ny,2,rightix,rightiy,vol,bb,wbbr)
      call intfacev1(nx,ny,2,bottomix,bottomiy,vol,bb,wbbv)
*   ..extrapolate magnetic field to edges
      do iy = -1, ny
        do ix = -1, nx
          if (leftix(ix,iy).eq.-2) wbbl(ix,iy,0:2) =
     &     bb(ix,iy,0:2) - (wbbr(ix,iy,0:2)-bb(ix,iy,0:2))
          if (rightix(ix,iy).eq.nx+1) wbbr(ix,iy,0:2) =
     &     bb(ix,iy,0:2) - (wbbl(ix,iy,0:2)-bb(ix,iy,0:2))
          if (bottomiy(ix,iy).eq.-2) wbbv(ix,iy,0:2) = bb(ix,iy,0:2) -
     &     (wbbv(topix(ix,iy),topiy(ix,iy),0:2)-bb(ix,iy,0:2))
        enddo
      enddo
*   ..compute extrapolated wbb.(:,:,3) components
      wbbl(:,:,3)=sqrt(wbbl(:,:,0)**2+wbbl(:,:,1)**2+wbbl(:,:,2)**2)
      wbbr(:,:,3)=sqrt(wbbr(:,:,0)**2+wbbr(:,:,1)**2+wbbr(:,:,2)**2)
      wbbv(:,:,3)=sqrt(wbbv(:,:,0)**2+wbbv(:,:,1)**2+wbbv(:,:,2)**2)
*   ..compute pbs (magnetic field pitch * surface area) at cell faces
      call b2xgbs (nx, ny, wbbl, wbbv, gs, qac, pbs,
     &  leftix, leftiy, bottomix, bottomiy, cflags)
*   ..save geometry
      call write_b2ag(nx,ny)
      call b2wugm (nout(1), nx, ny)
*   ..save parameters
      parg(0) = -1.0_R8
      parg(1:99) = 0.0_R8
      call cfwure (nout(1), 100, parg, 'parg')
      if (ex) then
        CALL INPUT
        close(45)
      endif
*   ..write dummy b2ag.prt
      write(*,*) 'Writing b2ag.prt'
      open(unit=70,file='b2ag.prt')
      write(70,'(a)') 'Dummy file, plasma geometry imported from B2SXDR'
      close(70)
*   ..write b2ai.dat
      call write_b2ai(ns)
*   ..write dummy b2ai.prt
      write(*,*) 'Writing b2ai.prt'
      open(unit=70,file='b2ai.prt')
      write(70,'(a)') 'Dummy file, plasma state imported from B2SXDR'
      close(70)
*   ..write b2yt.dat
      write(*,*) 'Writing b2yt.dat'
      open(unit=70,file='b2yt.dat')
      write(70,'(a)') '*dimens (nx1, ny1: free format)'
      write(70,'(2(2x,i4))') nx, ny
      if (EIRENE96) then
        write(70,'(a)') '''eirene_format''     ''old'''
      else
        write(70,'(a)') '''eirene_format''     ''facelift'''
      endif
      write(70,'(a)') '''solps_version''     ''4.3'''
#ifdef JET
      device='jet'
#else
      device='iter'
#endif
#ifndef NO_GETENV
#ifdef USE_PXFGETENV
      CALL PXFGETENV ('DEVICE', 0, device, lenval, ierror)
#else
      call get_environment_variable
     . ('DEVICE', status=ierror, length=lenval)
      if (ierror.eq.0) call get_environment_variable
     . ('DEVICE', value=device)
#endif
#endif
      if (streql(device,'iter'))
     > write(70,'(a)') '''invert_bpol''       ''1'''
      close(70)
*   ..write b2yg.dat
      write(*,*) 'Writing b2yg.dat'
      open(unit=70,file='b2yg.dat')
      write(70,'(a)') '*idout          (int, char*80, free format)'
      write(70,'(i3,a,1x,a)') 0,',','''....'''
      write(70,'(a)') '*nmbpcc'
      write(70,'(i3)') 1
      write(70,'(1x,2f5.2)') 0.5, 0.5
      write(70,'(a)') '*nmbpdm'
      write(70,'(i3)') 1
      xcnt = (minval(crx(1:nx,1:ny,0:3))+
     &        maxval(crx(1:nx,1:ny,0:3)))/2.0_R8
      ycnt = (minval(cry(1:nx,1:ny,0:3))+
     &        maxval(cry(1:nx,1:ny,0:3)))/2.0_R8
      scale = max(maxval(crx(1:nx,1:ny,0:3))-minval(crx(1:nx,1:ny,0:3)),
     &            maxval(cry(1:nx,1:ny,0:3))-minval(cry(1:nx,1:ny,0:3)))
      write(70,'(4(1x,g9.2))') xcnt-scale/2.0_R8, xcnt+scale/2.0_R8,
     &                         ycnt-scale/2.0_R8, ycnt+scale/2.0_R8
      close(70)
*   ..write b2yh.dat
      write(*,*) 'Writing b2yh.dat'
      open(unit=70,file='b2yh.dat')
      write(70,'(a)') '*style          (integer, free format)'
      write(70,'(i3)') 1
      close(70)
*   ..write b2yi.dat
      write(*,*) 'Writing b2yi.dat'
      open(unit=70,file='b2yi.dat')
      write(70,'(a)') '*idout          (int, char*80, free format)'
      write(70,'(i3,a,1x,a)') 0,',','''....'''
      close(70)
*   ..write b2ym.dat
      write(*,*) 'Writing b2ym.dat'
      open(unit=70,file='b2ym.dat')
      write(70,'(a)') '*idout          (int, char*80, free format)'
      write(70,'(i3,a,1x,a)') 0,',','''....'''
      close(70)
*   ..write b2yn.dat
      write(*,*) 'Writing b2yn.dat'
      open(unit=70,file='b2yn.dat')
      write(70,'(a)') '*idout          (int, char*80, free format)'
      write(70,'(i3,a,1x,a)') 0,',','''....'''
      close(70)
*   ..write b2yp.dat
      write(*,*) 'Writing b2yp.dat'
      open(unit=70,file='b2yp.dat')
      write(70,'(a)') '*idout          (int, char*80, free format)'
      write(70,'(i3,a,1x,a)') 0,',','''....'''
      write(70,'(a)') '*nmbpcc'
      write(70,'(i3)') 1
      write(70,'(1x,2f5.2)') 0.5, 0.5
      write(70,'(a)') '*nmbpdm'
      write(70,'(i3)') 1
      write(70,'(4(1x,g9.2))') xcnt-scale/2.0_R8, xcnt+scale/2.0_R8,
     &                         ycnt-scale/2.0_R8, ycnt+scale/2.0_R8
      close(70)
*   ..write b2yp.dat
      write(*,*) 'Writing b2yq.dat'
      open(unit=70,file='b2yq.dat')
      do is = 0, ns-1
        write(70,'(2i6)') 2, 3+is
      end do
      do is = 0, ns-1
        write(70,'(2i6)') 2, 3+ns+is
      end do
      write(70,'(2i6)') 2, 4+(2*ns)
      write(70,'(2i6)') 2, 5+(2*ns)
      write(70,'(2i6)') 2, 6+(2*ns)
      close(70)
*   ..write b2yr.dat
      write(*,*) 'Writing b2yr.dat'
      open(70,file='b2yr.dat')
      write(70,'(a)') '*nijdis        (integer, free format)'
      write(70,'(2i4)') 4, 4
      write(70,'(a)') '*idis          (nidis*integer, free format)'
      write(70,'(4i4)') 8, 16, 24, 32
      write(70,'(a)') '*jdis          (njdis*integer, free format)'
      write(70,'(4i4)') 2, 6, 10, 14
      close(70)
*   ..write header to converted state file
      idum(0) = nx
      idum(1) = ny
      idum(2) = ns
      call cfverw (nout(2), newversion)
      call cfwuin (nout(2), 3, idum, 'nx,ny,ns')
      call cfwuch (nout(2), 120, lblmn, 'label')
      call b2wuzd (nout(2), newversion, ns, zamin, zamax, zn, am)
*   ..write converted initial state file
      call b2wups (nout(2), nx, ny, ns,
     &  ne, na, ua, uadia, te, ti, ti, po, kt, zt,
     &  fna, fhe, fhi, fhn, fch, fch_32, fch_52, fch_p, kinrgy,
     &  fna_mdf, fhe_mdf, fhi_mdf, fna_fcor, fna_nodrift, fna_he,
     &  fnaPSch, fhePSch, fhiPSch, fna_eir, fne_eir, fhe_eir, fhi_eir,
     &  fna_32, fna_52, fni_32, fni_52, fne_32, fne_52,
     &  fchdia, fchin, fchvispar, fchvisper, fchvisq, fchinert,
     &  vaecrb, vadia, wadia, veecrb, vedia, floe_noc, floi_noc)
*   ..write header to nout(3)
      call cfverw (nout(3), newversion)
      idum(0) = ns
      call cfwuin (nout(3), 1, idum, 'ns')
      call cfwuch (nout(3), 120, lblmn, 'label')
*   ..save physics parameters to nout(3)
      call b2wucp (nout(3), newversion, ns)
*   ..write plasma state
      call cfverw(nout(4), newversion)
      call write_b2mod_geo(nout(4))
      call write_b2mod_plasma(nout(4))
      call write_b2mod_residuals(nout(4))
      call write_b2mod_sources(nout(4))
      call write_b2mod_transport(nout(4))
      call write_b2mod_anomalous_transport(nout(4))
      call write_b2mod_neutr_src_scaling(nout(4),nstraid)

*   ..write additional input files
      call b2conv_input_1
      call b2conv_input_2(nx,ny,ns)
      call write_b2ah(ns)
      call write_b2ar(ns)
      call write_b2mn(nx,ny,ns)
      call write_boundary_namelist(ns)
      call write_transport_namelist(ns)
      call write_neutrals_namelist(ns)
      call write_numerics_namelist(ns)
      call write_feedback_control_namelist(nx,ny)
      call write_user_namelist
      call write_SOLPS_FLUIDS_NREG(nnreg(0),ns)

*   ..deallocation of arrays and modules
      call dealloc_b2mod_geo
      call dealloc_b2mod_plasma
      call dealloc_b2mod_sources
      call dealloc_b2mod_residuals
      call dealloc_anomalous_transport
      call dealloc_b2_4to5_plasma
      call dealloc_b2_4to5_input

*   ..close files
      close(nout(0))
      close(nout(1))
      close(nout(2))
      close(nout(3))
      close(nout(4))

* ..end of computation
      call prgend ()
      stop 'b2sxdr'

*-----------------------------------------------------------------------
*.end b2sxdr

      end program b2sxdr
