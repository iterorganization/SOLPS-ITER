      module cslfxs

c  version : 09.04.2008 15:10

      implicit none
      public :: alloc_cslfxs, dealloc_cslfxs

c*** nsx : number of self-intersections found
c*** xsx, ysx : coordinates of self-intersections

      double precision, allocatable, public, save :: xsx(:),ysx(:)

      integer, public, save :: nsx

      contains

      subroutine alloc_cslfxs(n)
      integer n

      allocate(xsx(n))
      allocate(ysx(n))
      
      end subroutine alloc_cslfxs

      subroutine dealloc_cslfxs()

      if(allocated(xsx)) deallocate(xsx,ysx)
      nsx=0
      
      end subroutine dealloc_cslfxs

      end module cslfxs
