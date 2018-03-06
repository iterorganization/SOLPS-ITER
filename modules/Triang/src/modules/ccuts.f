      module ccuts
      implicit none
      public :: realloc_ccuts
      integer, allocatable, public, save :: nxcut1(:), nxcut2(:),
     .                                      nycut1(:), nycut2(:)
      integer, allocatable, public, save :: nxiso1(:), nxiso2(:),
     .                                      nyiso1(:), nyiso2(:)

      INTEGER, public, save :: NNCUT, NNISO
      INTEGER, ALLOCATABLE, PUBLIC, SAVE :: NCELL(:,:)

      contains
      subroutine realloc_ccuts(kennung,incr)
      character*(*) kennung
      integer incr

      integer, allocatable :: ihelp(:)

      if (kennung .eq. 'cut') then
c         write(6,*) 'vergroessern von ',kennung,' von ',size(nxcut1),
c     .              ' auf ',size(nxcut1)+incr
         allocate(ihelp(size(nxcut1)))
         ihelp = nxcut1
         deallocate (nxcut1)
         allocate(nxcut1(size(ihelp)+incr))
         nxcut1 = 0.
         nxcut1(1:size(ihelp)) = ihelp(1:size(ihelp))

         ihelp = nxcut2
         deallocate (nxcut2)
         allocate(nxcut2(size(ihelp)+incr))
         nxcut2 = 0.
         nxcut2(1:size(ihelp)) = ihelp(1:size(ihelp))

         ihelp = nycut1
         deallocate (nycut1)
         allocate(nycut1(size(ihelp)+incr))
         nycut1 = 0.
         nycut1(1:size(ihelp)) = ihelp(1:size(ihelp))

         ihelp = nycut2
         deallocate (nycut2)
         allocate(nycut2(size(ihelp)+incr))
         nycut2 = 0.
         nycut2(1:size(ihelp)) = ihelp(1:size(ihelp))

         deallocate(ihelp)
      else
         write(6,*) 'unknown flag in realloc_ccuts ', kennung
         stop 'error'
      endif
      end subroutine realloc_ccuts
      end module ccuts
