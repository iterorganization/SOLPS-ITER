      subroutine triaout(filename)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx

c  version : 17.03.2005 00:03

CVK output data for Triang grid (file header)
      implicit none
#include "uinput.inc"
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
  703 format (1p,6e13.5)
      end subroutine triaout
