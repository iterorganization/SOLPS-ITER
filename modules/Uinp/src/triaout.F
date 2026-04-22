      subroutine triaout(filename)
CVK output data for Triang grid (file header)
      use uinput_mod
      implicit none
      integer :: i, j, k, l, n
      character*(*) filename
      character*22 hlp_frm
      open(iunoo,file=filename)
      write(iunoo,703) trisize(0)
      do i=1,ntriref
        write(iunoo,703) trixmin(i),triymin(i),
     ,                   trixmax(i),triymax(i),trisize(i)
      end do
      write(iunoo,*)
      close(iunoo)
      write(*,*) '    ... ',filename, ' created'
c       write(0,*) '    ... ',filename, ' created'
cwdk  write additional file with (part of) the polygons for triangulation
      open(iunoo,file='fort.48')
      write(iunoo,'(a)') topo
      write(iunoo,'(i4)') ntriplg
      do i=1,ntriplg
        write(iunoo,'(3(i4))') nntriplg(i),nsegtriplg(i),nfclbltriplg(i)
        if (nfclbltriplg(i) .gt. 0 ) then
          write(hlp_frm,'(a,i1,a)') '(',nfclbltriplg(i),'(i4))'
          write (iunoo,hlp_frm) triplgfclbl(1:nfclbltriplg(i),i)
        endif
        l=1
        do j=1,nsegtriplg(i)
          n=abs(triplg(l,i))
          write(iunoo,'(i12)') n+1
          do k=1,n
            write(iunoo,'(2(2X,E13.6))') p1(1:2,triplg(k+l,i))*0.01_R8
          enddo
          write(iunoo,'(2(2X,E13.6))') p2(1:2,triplg(n+l,i))*0.01_R8
          l=l+n+1
        end do
      end do
      write(iunoo,*)
      close(iunoo)
      write(*,*) '    ... fort.48 created'
      return
  703 format (1p,6e13.5)
      end subroutine triaout
