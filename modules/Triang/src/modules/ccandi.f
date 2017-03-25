      module ccandi      
      implicit none
      public :: realloc_ccandi
C---- ICANDI : LIST OF POSSIBLE POINTS
C---- RADKAN : DISTANCE BETWEEN POINT C AND THE CANDIDATES
C---- NCANDI : TOTAL NUMBER OF POSSIBLE POINTS
      double precision, allocatable, public, save :: radkan(:)
      integer, allocatable, public, save :: icandi(:)

      INTEGER, public, save :: NCANDI

      contains
      subroutine realloc_ccandi(kennung,incr)
      character*(*) kennung
      integer incr

      double precision, allocatable :: help(:)
      integer, allocatable :: ihelp(:)

      if (kennung .eq. 'icandi') then
c         write(6,*) 'vergroessern von ',kennung,' von ',size(icandi),
c     .              ' auf ',size(icandi)+incr
         allocate(ihelp(size(icandi)))
         ihelp = icandi
         deallocate (icandi)
         allocate(icandi(size(ihelp)+incr))
         icandi = 0
         icandi(1:size(ihelp)) = ihelp
         deallocate(ihelp)
      elseif (kennung .eq. 'radkan') then
c         write(6,*) 'vergroessern von ',kennung,' von ',size(radkan),
c     .              ' auf ',size(radkan)+incr
         allocate(help(size(radkan)))
         help = radkan
         deallocate (radkan)
         allocate(radkan(size(help)+incr))
         radkan = 0.
         radkan(1:size(help)) = help
         deallocate(help)
      else
         write(6,*) 'unknown flag in realloc_ccandi ', kennung
         stop 'error'
      endif
      end subroutine realloc_ccandi
      end module ccandi
