      subroutine uinaux(nam)
      use b2mod_constants
      use b2mod_layer
     , , only: ntrack, nalloys
      use b2mod_subsys
      use b2mod_impcon
      use eirmod_solps
#ifdef DIMENSIONS_MODULE
      use b2mod_dimensions
#endif
c
c  version : 03.01.2005 16:55
c
c=======================================================================
c*** Input of user data from the file AUX
c=======================================================================
      implicit none
      character*8 nam
#include "uinput.inc"
      integer nnms
      parameter (nnms=38)
      character*8 name, unm(nnms)
      integer i,j,l,itrsrc(0:nstra),iitalv(ntalv),iiiplt(5),idum(11)
      integer nfiles,ntimv,nprnl
      data nprnl /999999/
      real u
      real rdum(6)
      logical ublplt(5)
      equivalence (ublplt,pl1st)
      logical streql
      external streql, xerrab
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
      i=0
      do 1000 i=1,nnms
        if(streql(name,unm(i))) exit
 1000 continue
      select case (i)
      case (1)
        call resime(u)
        zaa=2.0_R8*pi*u
      case (2)
        call rearri(npts,nstra,i)
        print *,'npts read. n,npts=',i,npts
      case (3)
        call resimi(nprnli)
        if (nprnli.gt.nprnl) then
          nprmul=(nprnli/nprnl)+1
          nprnli=nprnli/nprmul
        end if
        usetmstr=usetmstr.or.nprnli.gt.0
      case (4)
        call resimi(ntimv)
      case (5)
        call rearre(rdum,2,i)
        dtimv=rdum(1)
        time0=rdum(2)
      case (6)
        continue
      case (7)
        call rearre(rdum,5,i)
        ch2mx=rdum(1)
        ch2my=rdum(2)
        ch2x0=rdum(3)
        ch2y0=rdum(4)
        ch2z0=rdum(5)
      case (8)
        call rearre(rdum,6,i)
        ch3mx=rdum(1)
        ch3my=rdum(2)
        ch3mz=rdum(3)
        ch3x0=rdum(4)
        ch3y0=rdum(5)
        ch3z0=rdum(6)
      case (9)
        call rearri(ntls,nlimps,nsurpr)
      case (10)
        call rearri(idum,11,i)
        i1trc=idum(1)
        i2trc=idum(2)
        isyplt(1:8)=idum(3:10)
        ilinie=idum(11)
      case (11)
        call resimi(ntcpu)
      case (12)
        call resimi(nfile)
      case (13)
        call resime(alloc)
      case (14)
        call resimi(lfrm15)
      case (15)
        i=0
        if(trcamd) i=1
        call resimi(i)
        trcamd=i.ne.0
      case (16)
        i=0
        if(trchst) i=1
        call resimi(i)
        trchst=i.ne.0
      case (17)
        i=0
        if(trcsou) i=1
        call resimi(i)
        trcsou=i.ne.0
      case (18)
        do i=0,nstrai
          itrsrc(i)=0
          if(trcsrc(i)) itrsrc(i)=1
        end do
        call rearri(itrsrc,nstrai+1,j)
        do i=1,j
          trcsrc(i-1)=itrsrc(i-1).ne.0
        end do
      case (19)
        l=lena
        lena=60
        path=' '
        call resima(path)
      lena=l
      case (20)
        l=lena
        lena=8
        call rearra(filtrm(luftrm+1:nhd6),nhd6-luftrm,nfiles)
        nnftrm=luftrm+nfiles
      case (21)
        call scipit
      case (22)
        continue
      case (23)
        do i=0,nstrai
          itrsrc(i)=0
          if(pltsrc(i)) itrsrc(i)=1
        end do
        call rearri(itrsrc,nstrai+1,j)
        do i=1,j
          pltsrc(i-1)=itrsrc(i-1).ne.0
        end do
      case (24)
        call rearre(talzmi,ntalv,i)
      case (25)
        do i=1,ntalv
          iitalv(i)=0
          if(pltllg(i)) iitalv(i)=1
        end do
        call rearri(iitalv,ntalv,j)
        do i=1,j
          pltllg(i)=iitalv(i).ne.0
        end do
      case (26)
        do i=1,5
          iiiplt(i)=0
          if(ublplt(i)) iiiplt(i)=1
        end do
        call rearri(iiiplt,5,j)
        do i=1,j
          ublplt(i)=iiiplt(i).ne.0
        end do
      case (27)
        call rearri(nemods,nstrai,i)
      case (28)
        call rearre(soreni,nstrai,i)
      case (29)
        call rearre(sorene,nstrai,i)
      case (30)
        call rearre(sorcos,nstrai,i)
      case (31)
        i=0
        if(trcbla) i=1
        call resimi(i)
        trcbla=i.ne.0
      case (32)
        i=0
        if(trcblm) i=1
        call resimi(i)
        trcblm=i.ne.0
      case (33)
        i=0
        if(trcbli) i=1
        call resimi(i)
        trcbli=i.ne.0
      case (34)
        i=0
        if(trcblp) i=1
        call resimi(i)
        trcblp=i.ne.0
      case (35)
        i=0
        if(nldrft) i=1
        call resimi(i)
        nldrft=i.ne.0
      case (36)
        i=0
        if(nlscl) i=1
        call resimi(i)
        nlscl=i.ne.0
      case (37)
        i=0
        if(nlcrr) i=1
        call resimi(i)
        nlcrr=i.ne.0
      case (38)
        i=0
        if(plhst) i=1
        call resimi(i)
        plhst=i.ne.0
      case default
c       call skipit
        print *,'uinaux: variable name ',name,' is not foreseen - ',
     ,    'check the $DEVICE.aux file'
        call xerrab ('Unknown variable name in $DEVICE.aux file')
      end select
c=======================================================================
 9999 call subend ()
      return
      end subroutine uinaux
