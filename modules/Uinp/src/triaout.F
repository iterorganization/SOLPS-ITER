      subroutine triaout(filename)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_solps

c  version : 17.03.2005 00:03

CVK output data for Triang grid (file header)
      implicit none
#include "uinput.inc"
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
        write(hlp_frm,'(a,i1,a)') '(',nfclbltriplg(i),'(i4))'
        write (iunoo,hlp_frm) triplgfclbl(1:nfclbltriplg(i),i)
        l=1
        do j=1,nsegtriplg(i)
          n=triplg(l,i)
          write(iunoo,'(i12)') n+1
          do k=1,n
            write(iunoo,'(2(2X,E21.14))') p1(1:2,triplg(k+1,i))*0.01
          enddo
          write(iunoo,'(2(2X,E21.14))') p2(1:2,triplg(n+1,i))*0.01
          l=l+n
        end do
      end do
      write(iunoo,*)
      close(iunoo)
      write(*,*) '    ... fort.48 created'
  703 format (1p,6e13.5)
      end subroutine triaout
