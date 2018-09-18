C******* -SUBROUTINE COMPLETE- *****************************************
C----
C---- THIS SUBROUTINE UPDATES THE NODE LIST AND THE ELEMENT LIST

      subroutine complete

c  version : 19.09.2005 18:04

      use cpoin
      use cfront
      use celm
      implicit none

      integer i

c---- the new element is the triangle limited by the points ia, ib and
c---- inodcon
      nelm = nelm+1
      if (nelm .gt. size(ielm,2)) then
         call realloc_celm('ielm',100)
      endif
      ielm(1,nelm) = ia
      ielm(2,nelm) = ib
      ielm(3,nelm) = inodcon

c---- if inodcon is the new point c it must be added to the grid
c---- coordinates
      if (inodcon .eq. ic) then
        if ((xc(1) .gt. maxval(x(1:npoin))) .or.
     .      (xc(1) .lt. minval(x(1:npoin))) .or. 
     .      (xc(2) .gt. maxval(y(1:npoin))) .or.
     .      (xc(2) .lt. minval(y(1:npoin)))) then
          write(6,*) 'stop in complete, new point is outside the',
     .         ' polygons.'
          print *,' ==> perhaps the direction of the polygon',
     .         ' is incorrect'
          print '(a,i6,1p,2e12.4)',' new point: ',inodcon,xc
          print '(a,i5,a,1p,2(i6,a,2e12.4,a))',' triangle',nelm,
     ,      ' with ',ia,' (',x(ia),y(ia),' ),',ib,' (',x(ib),y(ib),' )'
          print *,'Nodes: '
          print *,'    i      x           y'
          print '(i5,1p,2e12.4)',(i,x(i),y(i),i=1,npoin)
          print *,'Segments:'
          print *,'   i   i1   i2      dl'
          print '(3i5,1p,e12.4)',
     ,                (i,ifront(1,i),ifront(2,i),delfro(i),i=1,npartfr)
          print *
          call filepltd(2,inodcon)
          stop ': error in complete'
        endif
        npoin = npoin + 1
        if (npoin .gt. size(x)) then
           call realloc_cpoin('xy',100)
        endif
        x(npoin) = xc(1)
        y(npoin) = xc(2)
c     if (((xc(1).gt.1100.).and.(xc(1).le.1200.).and.
c    .     (xc(2).gt.250.).and.(xc(2).lt.350.))) then
c       write(10,*) 'zugef. punkt',npoin,xc
c     endif
      endif
c     call grjmp(real(x(ielm(1,nelm))),real(y(ielm(1,nelm))))
c     call grdrw(real(x(ielm(2,nelm))),real(y(ielm(2,nelm))))
c     call grdrw(real(x(ielm(3,nelm))),real(y(ielm(3,nelm))))
c     call grdrw(real(x(ielm(1,nelm))),real(y(ielm(1,nelm))))
      end
