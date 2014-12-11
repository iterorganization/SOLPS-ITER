      subroutine fxdrnm(nam)
c
c  version : 09.08.95 20:42
c
c=====================================================
c*** User subroutine for the input routine IMPORT
c
#include "sonparm.inc"
      parameter (nnms=7)
      character*6 nam, unm(nnms)
c
c*** provide the following for rescaling the grid levels to Vs
      real twopi
      parameter (twopi=2.*3.1415926535898)
c
c*** List of the valid input keywords
      data unm /
     1    'target','line  ','region','levels','zone  ',
     2    'points','#     ' /
      data l, lr, lz / 0, 0, 0 /
c=====================================================
c
      call locase(nam,nam,6)
      do 1000 i=1,nnms
          if(nam.eq.unm(i)) go to (10,20,30,40,50,60,70),i
 1000 continue
      return
c
 10   call resimi(l)
      if(l.le.0 .or. l.gt.nntrg) l=0
      return
c
 20   if(l.gt.0) then
          call rearre(rztg(1,1,l),2*npts,i)
c*** Input in mm, output in m
          call vscale(rztg(1,1,l),0.001,rztg(1,1,l),i)
          nmtrg(l)=i/2
      end if
      return
c
 30   call resimi(lr)
      if(lr.le.0 .or. lr.gt.nnreg) then
          print *,'*** Correction data: wrong region label ',lr
          lr=0
      end if
      return
c
 40   if(lr.gt.0) then
          call rearre(flvl(1,lr),nlvl,nmlvl(lr))
      end if
c
c*** rescale from Vs/rad to Vs
      do i=1,nmlvl(lr)
          flvl(i,lr) = twopi*flvl(i,lr)
      end do
      return
c
 50   call resimi(lz)
      lz=lz+1
      if(lz.le.0 .or. lz.gt.nnzon) then
          print *,'*** Correction data: wrong zone label ',lz-1
          lz=0
      end if
      return
c
 60   if(lz.gt.0) then
          call rearre(arcln(1,lz),narc,nmarc(lz))
      end if
      return
 70   call scipit
      return
c=====================================================
      end
