      subroutine filepltd(jc,kc)

c  version : 30.11.2005 18:08

c=======================================================================
c** Produces files with geometrical data for debugging purposes.
c** jc controls the output:
c**   1 only frontier - and self-intersection, if any, - data
c**     to "structures.dat"
c**   2 frontier to "frontier.dat", triangles to "triangles.dat",
c**     the last triangle to "curtrngl.dat"
c** kc is the index of the last point
c=======================================================================
      use cpoin
      use cfront
      use celm
      use cslfxs

      implicit none
      integer jc,kc
      integer igivelun
      integer i,j,lun,lex(2)
      double precision d,x0,y0,x1,y1
      parameter (d=0.2)
      character*10 fns(4),fn*14
      data fns / 'structures', 'frontier', 'triangles', 'curtrngl' /
c=======================================================================

      print *,'filepltd(',jc,',',kc,'), npartfr=',npartfr !###
      lun=igivelun(10,90,lex,0)
      if(lun.lt.0) then !{
        write(0,*) '** filepltd(',jc,' ): no free unit found - ',
     ,                                                'no plot data!!!'
        return
      end if !}
      if(jc.eq.1) then !{
c** First call - output the structures (initial frontier)
        fn=trim(fns(1))//'.dat'
        open(lun,file=fn,err=900)
        write(lun,'(a1,6(7x,a2,6x))') '#','x','y','xo','yo','xs','ys'
        do i=1,npartfr !{
          x0=0.5*(x(ifront(1,i))+x(ifront(2,i)))
          y0=0.5*(y(ifront(1,i))+y(ifront(2,i)))
          x1=x0+d*(y(ifront(2,i))-y(ifront(1,i)))
          y1=y0-d*(x(ifront(2,i))-x(ifront(1,i)))
          write(lun,*)
          if(i.gt.nsx) then !{
            write(lun,'(1p,4e15.6)') x(ifront(1,i)),y(ifront(1,i)),x0,y0
          else !}{
            write(lun,'(1p,6e15.6)') x(ifront(1,i)),y(ifront(1,i)),
     ,                                               x0,y0,xsx(i),ysx(i)
          end if !}
          write(lun,'(1p,4e15.6)') x(ifront(2,i)),y(ifront(2,i)),x1,y1
c          write(lun,*)
c          write(lun,'(1p,2e15.6)') x0,y0
c          write(lun,'(1p,2e15.6)') x1,y1
        end do !}
        call dealloc_cslfxs
      else if(jc.eq.2) then !}{
c** Output the current frontier
        fn=trim(fns(2))//'.dat'
        open(lun,file=fn,err=900)
        write(lun,'(a1,2(8x,a1,6x))') '#','x','y'
        do i=1,npartfr !{
          x0=0.5*(x(ifront(1,i))+x(ifront(2,i)))
          y0=0.5*(y(ifront(1,i))+y(ifront(2,i)))
          x1=x0-0.1*(y(ifront(2,i))-y(ifront(1,i)))
          y1=y0+0.1*(x(ifront(2,i))-x(ifront(1,i)))
          write(lun,*)
          write(lun,'(1p,2e15.6)') x(ifront(1,i)),y(ifront(1,i))
          write(lun,'(1p,2e15.6)') x(ifront(2,i)),y(ifront(2,i))
          write(lun,*)
          write(lun,'(1p,2e15.6)') x0,y0,x1,y1
        end do !}
c** Output the triangles created by now
        fn=trim(fns(3))//'.dat'
        open(lun,file=fn,err=900)
        write(lun,'(a1,2(8x,a1,6x))') '#','x','y'
        do i=1,nelm !{
          write(lun,*)
          write(lun,'(1p,2e15.6)') (x(ielm(j,i)),y(ielm(j,i)),j=1,3)
          write(lun,'(1p,2e15.6)') x(ielm(1,i)),y(ielm(1,i))
        end do !}
c** Output the current triangle which apparently causes the problem
        fn=trim(fns(4))//'.dat'
        open(lun,file=fn,err=900)
        write(lun,'(a1,2(8x,a1,6x),2(7x,a2,6x))') '#','x','y','xc','yc'
        if(kc.gt.0) then !{
          x0=0.5*(x(ia)+x(ib))
          y0=0.5*(y(ia)+y(ib))
          x1=x0-d*(y(ib)-y(ia))
          y1=y0+d*(x(ib)-x(ia))
          write(lun,'(1p,4e15.6)') x(kc),y(kc),x(kc),y(kc)
          write(lun,'(1p,2e15.6)') x(ia),y(ia),x(ib),y(ib),x(kc),y(kc)
          write(lun,*)
          write(lun,'(1p,2e15.6)') x0,y0,x1,y1
        end if !}
      else !}{
        print *,'** filepltd(',jc,' ): unforeseen parameter'
        return
      end if !}
      close(lun)
      print *,'filepltd(',jc,' ): finished'
      return
c=======================================================================
  900 write(0,*) '** filepltd(',jc,' ): error opening the "',
     ,  trim(fn),'" file - no plot data!!!'
      return
c=======================================================================
      end
