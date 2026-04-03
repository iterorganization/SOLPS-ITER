      Program FXDR
c
c  version : 05.08.95 18:12
c
c=====================================================
c                       Interface program
c     for transfer of equilibrium and geometry data to Sonnet
c
c        By call to the routine CDXDR, the configuration- and device-
c     specific data are written to the file sonnet.xdr in XDR form.
c     This file is suitable as the input file for the boundary layer
c     mapping program Sonnet.
c        The ASCII input file for the Sonnet control, input.snn,
c     is also adjusted in order to incorporate the information from the
c     DG user interface routine. The result is written in sonnet.asc
c     file.
c
c        This version relies strongly on the assumptions that
c
c     -   the configuration is lower single null;
c     -   the middle row of the flux array intersects the main plasma;
c     -   the magnetic flux read from the equilibrium file is in Vs/rad
c=====================================================
c
c... Routine for XDR
      external cdxdr
C... subroutine for data input
      external fxdrnm

#ifndef CRAY_YMP
#define CDXDR cdxdr
#endif
#include "sonparm.inc"
#include "impcon.inc"
      character*24 xdrfle, snnin, snnout
      integer ngpr, ngpz
      real twopi, u, s, p, b, r
      parameter (twopi=2.*3.1415926535898)
#ifdef CRAY_YMP
      real rgr(nnpr), zgr(nnpz)
      real pfm(nnpr, nnpz)
      real upfm(nnpr*nnpz)
c... Toroidal field in Tesla, radius in m
      real btf, rtf
#else
      double precision rgr(nnpr), zgr(nnpz)
      double precision pfm(nnpr, nnpz)
      real*8 upfm(nnpr*nnpz)
c... Toroidal field in Tesla, radius in m
      double precision btf, rtf
#endif
      integer i, j, k
c      equivalence (pfm,upfm)
c
c*** Number of structures NST, of points NPTS >= MAX of NPT over NST
c
      integer nnn, nst
      parameter (nnn=nnst*npts)
      integer npt(nnst)

#ifdef CRAY_YMP
      real rst(nnn), zst(nnn)
#else
      double precision rst(nnn), zst(nnn)
#endif
c=====================================================
c*** Generate the filenames for XDR data and Sonnet input files
c
      xdrfle = 'sonnet.xdr'
      snnin = 'input.snn'
      snnout = 'sonnet.asc'
      call lefta(xdrfle,24,i)
      call lefta(snnin,24,i)
      call lefta(snnout,24,i)
c
c***  Set up the input routine
c
      immed = .false.
c
c***  Read the plasma equilibrium ...
c
      open(unit=8,file='equilibr.snn',status='old')
      call rdeqlh(8,ngpr,ngpz,b,r,*99)
c%%
      print *,'ngpr, ngpz  = ',ngpr,ngpz
c%%
      read(8,8000) (rgr(i),i=1,ngpr)
      read(8,*)
      read(8,*)
      read(8,8000) (zgr(i),i=1,ngpz)
      read(8,*)
      read(8,*)
      read(8,8000) ((pfm(i,j),i=1,ngpr),j=1,ngpz)
 8000 format(5(3x,e14.8))
c
      if(r.le.0.) then
c
c***  ... then the toroidal field and the corresponding radius...
c
          open(8,file='field.snn',status='old')
          read(8,*)
          read(8,*) b, r
          close(8)
      end if
      btf = b
      rtf = r
c
c*** rescale the poloidal flux from Vs/rad to Vs
c
      do i=1,ngpr
          do j=1,ngpz
              pfm(i,j)=pfm(i,j)*twopi
          end do
      end do
c
c***  ... and read the data on the plasma limiting structures
c
      open(8,file='struct.snn')
      read (8,*) nst
      nst=min0(nst,nnst)
      do 100 i=1,nst
            read(8,*) k
            npt(i)=min0(k,npts)
            k=i
            do 100 j=1,npt(i)
                read(8,*) r,z
c
c*** r, z are in millimeters - rescale them
c
                rst(k)=0.001*r
                zst(k)=0.001*z
 100        k=k+nst
c
c***  Compress the flux data to avoid dimensioning collision in CDXDR
c
      k=1
      do 101 j=1,ngpz
          do 101 i=1,ngpr
              upfm(k)=pfm(i,j)
101   k=k+1
c
c***  Create XDR Data File
c***
c***  This routine writes the configuration and device
c***  specific data in XDR form to a file
c
      CALL CDXDR (XDRFLE, RGR, ZGR, UPFM, NGPR, NGPZ,
     ,                              RST, ZST, NST, NPT, NPTS, BTF, RTF)
c-----------------------------------------------------
c
c***  Now correct the input file for the target information
c***
c*** First, read the data from the DG output file ...
c
      open (5, file='targets.snn', status='old', err=50)
      call import(fxdrnm)
      close (5)
c
c*** ... find the flux value at the magnetic axes ...
c
      u=-1.e20
      s=sign(1.,flvl(1,1))
c%%%
      print *,'*** fxdr: s = ',s
c%%%
      k=ngpz/2
      do 110 j=k,ngpz
          if(s*pfm(1,j).lt.0.) then
              uu=-1.e20
              do 112 i=1,ngpr
                  p=s*pfm(i,j)
                  if(p.gt.uu) uu=p
 112          continue
              if(uu.gt.0. .and. uu.lt.u) go to 20
              u=uu
          end if
 110  continue
 20   do 115 j=k-1,2,-1
          if(s*pfm(1,j).lt.0.) then
              uu=-1.e20
              do 117 i=1,ngpr
                  p=s*pfm(i,j)
                  if(p.gt.uu) uu=p
 117          continue
              if(uu.gt.0. .and. uu.lt.u) go to 30
              u=uu
          end if
 115  continue
c
c*** Something is wrong with the equilibrium data: failed to find
c*** a positive flux maximum corresponding to the magnetic axis
c
      stop  '*** fxdr: failed to find the magnetic axis'
c=====================================================
 30   flxnr=u*s
c
c*** ... then check the data for consistency
c*** and make necessary corrections ...
c
      call chkinp
c
c*** ... and finally produce the new input file for SONNET
c
      open (5, file=snnin, status='old', err=50)
      open (8, file=snnout)
      call crrinf(5,8)
      stop '   ... in Fortran program FXDR'
c=====================================================
c
 50   stop '  The template for SONNET input not found - no correction!'
c=====================================================
c
 99   stop '   Error in Fortran program FXDR'
c=====================================================
      end
