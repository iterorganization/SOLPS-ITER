      subroutine uinaux(nam)
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
#include "uinput.inc"
#include "impcon.inc"
      parameter (nnms=38)
      character*8 nam, unm(nnms)
      integer itrsrc(0:nstra),iitalv(ntalv),iiiplt(5)
      integer nfiles
      logical ublplt(5)
      equivalence (ublplt,pl1st)
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
      call locase(nam,nam,8)
      do 1000 i=1,nnms
          if(nam.eq.unm(i)) go to (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
     ,                    16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,
     ,                                       31,32,33,34,35,36,37,38),i
 1000 continue
c      call skipit
      print *,'uinaux: variable name ',nam,' is not foreseen - ',
     ,  'check the $DEVICE.aux file'
      stop
      return
c
 1    call resime(u)
      zaa=6.2831853*u
      return
 2    call rearri(npts,nstra,i)
      print *,'npts read. n,npts=',i,npts
      return
 3    call resimi(nprnli)
      return
 4    call resimi(ntimv)
      return
 5    call rearre(dtimv,2,i)
      return
 6    continue
      return
 7    call rearre(ch2mx,5,i)
      return
 8    call rearre(ch3mx,6,i)
      return
 9    call rearri(ntls,nlimps,nsurpr)
      return
 10   call rearri(i1trc,11,i)
      return
 11   call resimi(ntime)
      return
 12   call resimi(nfile)
      return
 13   call resime(alloc)
      return
 14   call resimi(lfrm15)
      return
 15   i=0
      if(trcamd) i=1
      call resimi(i)
      trcamd=i.ne.0
      return
 16   i=0
      if(trchst) i=1
      call resimi(i)
      trchst=i.ne.0
      return
 17   i=0
      if(trcsou) i=1
      call resimi(i)
      trcsou=i.ne.0
      return
 18   do i=0,nstrai
          itrsrc(i)=0
          if(trcsrc(i)) itrsrc(i)=1
      end do
      call rearri(itrsrc,nstrai+1,j)
      do i=1,j
          trcsrc(i-1)=itrsrc(i-1).ne.0
      end do
      return
 19   l=lena
      lena=60
      path=' '
      call resima(path)
      lena=l
      return
 20   l=lena
      lena=8
      call rearra(filtrm(luftrm+1:nhd6),nhd6-luftrm,nfiles)
      nnftrm=luftrm+nfiles
      return
 21   call scipit
      return
 22   continue
      return
 23   do i=0,nstrai
          itrsrc(i)=0
          if(pltsrc(i)) itrsrc(i)=1
      end do
      call rearri(itrsrc,nstrai+1,j)
      do i=1,j
          pltsrc(i-1)=itrsrc(i-1).ne.0
      end do
      return
 24   call rearre(talzmi,ntalv,i)
      return
 25   do i=1,ntalv
          iitalv(i)=0
          if(pltllg(i)) iitalv(i)=1
      end do
      call rearri(iitalv,ntalv,j)
      do i=1,j
          pltllg(i)=iitalv(i).ne.0
      end do
      return
 26   do i=1,5
          iiiplt(i)=0
          if(ublplt(i)) iiiplt(i)=1
      end do
      call rearri(iiiplt,5,j)
      do i=1,j
          ublplt(i)=iiiplt(i).ne.0
      end do
      return
 27   call rearri(nemods,nstrai,i)
      return
 28   call rearre(soreni,nstrai,i)
      return
 29   call rearre(sorene,nstrai,i)
      return
 30   call rearre(sorcos,nstrai,i)
      return
 31   i=0
      if(trcbla) i=1
      call resimi(i)
      trcbla=i.ne.0
      return
 32   i=0
      if(trcblm) i=1
      call resimi(i)
      trcblm=i.ne.0
      return
 33   i=0
      if(trcbli) i=1
      call resimi(i)
      trcbli=i.ne.0
      return
 34   i=0
      if(trcblp) i=1
      call resimi(i)
      trcblp=i.ne.0
      return
 35   i=0
      if(nldrft) i=1
      call resimi(i)
      nldrft=i.ne.0
      return
 36   i=0
      if(nlscl) i=1
      call resimi(i)
      nlscl=i.ne.0
      return
 37   i=0
      if(nlcrr) i=1
      call resimi(i)
      nlcrr=i.ne.0
      return
 38   i=0
      if(plhst) i=1
      call resimi(i)
      plhst=i.ne.0
      return
c=======================================================================
      end
