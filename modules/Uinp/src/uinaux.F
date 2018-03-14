      subroutine uinaux(nam)
      use b2mod_constants
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
c
c  version : 03.01.2005 16:55
c
c=======================================================================
c*** Input of user data from the file AUX
c=======================================================================
      implicit none
      character*8 nam
#include "uinput.inc"
#include "impcon.inc"
      integer nnms
      parameter (nnms=38)
      character*8 name, unm(nnms)
      integer i,j,l,itrsrc(0:nstra),iitalv(ntalv),iiiplt(5),idum(11)
      integer nfiles,ntimv
      real u
      real rdum(6)
      logical ublplt(5)
      equivalence (ublplt,pl1st)
      logical streql
      external streql, xerrab, subini, subend
c*** List of the valid input keywords
      data unm /
     1    'rmajor  ','npts    ','nprnli  ','ntimv   ','dtimv   ',
     2    '        ','ch2mx   ','ch3mx   ','ntls    ','i1trc   ',
     3    'ntime   ','nfile   ','alloc   ','lfrm15  ','trcamd  ',
     4    'trchst  ','trcsou  ','trcsrc  ','trimpath','trimfls ',
     5    '#       ','        ','pltsrc  ','talzmi  ','pltllg  ',
     6    'pl1st   ','nemods  ','soreni  ','sorene  ','sorcos  ',
     7    'trcbla  ','trcblm  ','trcbli  ','trcblp  ','nldrft  ',
     7    'nlscl   ','nlcrr   ','plhst   '/
c=======================================================================
c
      call subini('uinaux')
      call locase(nam,name,8)
      do 1000 i=1,nnms
          if(streql(name,unm(i)))
     ,             go to (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
     ,                    16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,
     ,                                       31,32,33,34,35,36,37,38),i
 1000 continue
c      call skipit
      print *,'uinaux: variable name ',name,' is not foreseen - ',
     ,  'check the $DEVICE.aux file'
      call xerrab ('Unknown variable name in $DEVICE.aux file')
      goto 9999
c
 1    call resime(u)
      zaa=2.0_R8*pi*u
      goto 9999
 2    call rearri(npts,nstra,i)
      print *,'npts read. n,npts=',i,npts
      goto 9999
 3    call resimi(nprnli)
      goto 9999
 4    call resimi(ntimv)
      goto 9999
 5    call rearre(rdum,2,i)
      dtimv=rdum(1)
      time0=rdum(2)
      goto 9999
 6    continue
      goto 9999
 7    call rearre(rdum,5,i)
      ch2mx=rdum(1)
      ch2my=rdum(2)
      ch2x0=rdum(3)
      ch2y0=rdum(4)
      ch2z0=rdum(5)
      goto 9999
 8    call rearre(rdum,6,i)
      ch3mx=rdum(1)
      ch3my=rdum(2)
      ch3mz=rdum(3)
      ch3x0=rdum(4)
      ch3y0=rdum(5)
      ch3z0=rdum(6)
      goto 9999
 9    call rearri(ntls,nlimps,nsurpr)
      goto 9999
 10   call rearri(idum,11,i)
      i1trc=idum(1)
      i2trc=idum(2)
      isyplt(1:8)=idum(3:10)
      ilinie=idum(11)
      goto 9999
 11   call resimi(ntcpu)
      goto 9999
 12   call resimi(nfile)
      goto 9999
 13   call resime(alloc)
      goto 9999
 14   call resimi(lfrm15)
      goto 9999
 15   i=0
      if(trcamd) i=1
      call resimi(i)
      trcamd=i.ne.0
      goto 9999
 16   i=0
      if(trchst) i=1
      call resimi(i)
      trchst=i.ne.0
      goto 9999
 17   i=0
      if(trcsou) i=1
      call resimi(i)
      trcsou=i.ne.0
      goto 9999
 18   do i=0,nstrai
          itrsrc(i)=0
          if(trcsrc(i)) itrsrc(i)=1
      end do
      call rearri(itrsrc,nstrai+1,j)
      do i=1,j
          trcsrc(i-1)=itrsrc(i-1).ne.0
      end do
      goto 9999
 19   l=lena
      lena=60
      path=' '
      call resima(path)
      lena=l
      goto 9999
 20   l=lena
      lena=8
      call rearra(filtrm(luftrm+1:nhd6),nhd6-luftrm,nfiles)
      nnftrm=luftrm+nfiles
      goto 9999
 21   call scipit
      goto 9999
 22   continue
      goto 9999
 23   do i=0,nstrai
          itrsrc(i)=0
          if(pltsrc(i)) itrsrc(i)=1
      end do
      call rearri(itrsrc,nstrai+1,j)
      do i=1,j
          pltsrc(i-1)=itrsrc(i-1).ne.0
      end do
      goto 9999
 24   call rearre(talzmi,ntalv,i)
      goto 9999
 25   do i=1,ntalv
          iitalv(i)=0
          if(pltllg(i)) iitalv(i)=1
      end do
      call rearri(iitalv,ntalv,j)
      do i=1,j
          pltllg(i)=iitalv(i).ne.0
      end do
      goto 9999
 26   do i=1,5
          iiiplt(i)=0
          if(ublplt(i)) iiiplt(i)=1
      end do
      call rearri(iiiplt,5,j)
      do i=1,j
          ublplt(i)=iiiplt(i).ne.0
      end do
      goto 9999
 27   call rearri(nemods,nstrai,i)
      goto 9999
 28   call rearre(soreni,nstrai,i)
      goto 9999
 29   call rearre(sorene,nstrai,i)
      goto 9999
 30   call rearre(sorcos,nstrai,i)
      goto 9999
 31   i=0
      if(trcbla) i=1
      call resimi(i)
      trcbla=i.ne.0
      goto 9999
 32   i=0
      if(trcblm) i=1
      call resimi(i)
      trcblm=i.ne.0
      goto 9999
 33   i=0
      if(trcbli) i=1
      call resimi(i)
      trcbli=i.ne.0
      goto 9999
 34   i=0
      if(trcblp) i=1
      call resimi(i)
      trcblp=i.ne.0
      goto 9999
 35   i=0
      if(nldrft) i=1
      call resimi(i)
      nldrft=i.ne.0
      goto 9999
 36   i=0
      if(nlscl) i=1
      call resimi(i)
      nlscl=i.ne.0
      goto 9999
 37   i=0
      if(nlcrr) i=1
      call resimi(i)
      nlcrr=i.ne.0
      goto 9999
 38   i=0
      if(plhst) i=1
      call resimi(i)
      plhst=i.ne.0
      goto 9999
c=======================================================================
 9999 call subend ()
      return
      end
