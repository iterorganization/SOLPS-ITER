      subroutine triaout(filename)
CVK output data for Triang grid (file header)
      use uinput_mod
      implicit none
      integer :: i
      character*(*) filename
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
      return
  703 format (1p,6e13.5)
      end subroutine triaout
