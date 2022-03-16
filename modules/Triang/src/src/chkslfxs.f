      subroutine chkslfxs(found)

c  version : 02.11.2005 01:10

c=======================================================================
c** Checks the imported structure for self-intersections.
c** On return, nsx is the number of these intersections, and
c** xsx,ysx their coordinates (module cslfxs)
c** found=nsx.gt.0
c=======================================================================
      use cpoin
      use cfront
      use celm
      use cslfxs

      implicit none
      logical found,lfxsgm1
      integer i,j
      double precision x0(2),y0(2),x1(2),y1(2),xs,ys
c=======================================================================

      nsx=0
      found=.false.
      if(npartfr.le.0) then !{
        print *,'chkslfxs: no structure imported, npartfr=',npartfr
        return
      end if !}
      print *,'chkslfxs: npartfr=',npartfr  !###
      call alloc_cslfxs(npartfr)

      do i=1,npartfr !{
        x0(1)=x(ifront(1,i))
        x0(2)=x(ifront(2,i))
        y0(1)=y(ifront(1,i))
        y0(2)=y(ifront(2,i))
        do j=i+1,npartfr !{
          x1(1)=x(ifront(1,j))
          x1(2)=x(ifront(2,j))
          y1(1)=y(ifront(1,j))
          y1(2)=y(ifront(2,j))
          if(lfxsgm1(x0,y0,x1,y1,xs,ys)) then !{
            if(nsx.ge.npartfr) then !{
              print *,'chkslfxs: unexpected error. nsx,npartfr=',
     ,                                                      nsx,npartfr
              go to 10
            end if !}
            nsx=nsx+1
            xsx(nsx)=xs
            ysx(nsx)=ys
            print *
            print '(1p,5e15.6)',x0,x1,xs  !###
            print '(1p,5e15.6)',y0,y1,ys  !###
          end if !}
        end do !}
      end do !}

      print *,'chkslfxs finished. nsx=',nsx
 10   found=nsx.gt.0
      if(found) then !{
        print *,'Intersections (x,y [mm]):'
        print '(1x,1p,2e15.6)',(xsx(i)*10,ysx(i)*10,i=1,nsx)
      end if !}
      return
c=======================================================================
      end
