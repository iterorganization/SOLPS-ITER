      module cfront      
      implicit none
      public :: realloc_cfront
C---- DELFRO : LENTGH OF FRONTIER-PARTS
C---- IFRONT : LIST OF FRONTIER-PARTS
C----          IFRONT(1,*) : START POINT OF FRONTIER PART
C----          IFRONT(2,*) : END POINT OF FRONTIER PART
C---- NPARTFR : TOTAL NUMBER OF FRONTIER-PARTS
      double precision, allocatable, public, save :: delfro(:)
      integer, allocatable, public, save :: ifront(:,:)

      INTEGER, public, save :: NPARTFR

      contains
      subroutine realloc_cfront(kennung,incr)
      character*(*) kennung
      integer incr

      double precision, allocatable :: help(:)
      integer, allocatable :: ihelp(:,:)

      integer dim1, dim2

      if (kennung .eq. 'delfro') then
c         write(6,*) 'vergroessern von ',kennung,' von ',size(delfro),
c     .              ' auf ',size(delfro)+incr
         allocate(help(size(delfro)))
         help = delfro
         deallocate (delfro)
         allocate(delfro(size(help)+incr))
         delfro = 0.
         delfro(1:size(help)) = help
         deallocate(help)
      elseif (kennung .eq. 'ifront') then
         dim1 = size(ifront,1)
         dim2 = size(ifront,2)
c         write(6,*) 'vergroessern von ',kennung,' von (',dim1,
c     .              ',',dim2,') auf (',dim1,',',dim2+incr,')'
         allocate(ihelp(dim1,dim2))
         ihelp = ifront
         deallocate (ifront)
         allocate(ifront(dim1,dim2+incr))
         ifront = 0
         ifront(1:dim1,1:dim2) = ihelp(1:dim1,1:dim2)
         deallocate(ihelp)
      else
         write(6,*) 'unknown flag in realloc_cfront ', kennung
         stop 'error'
      endif
      end subroutine realloc_cfront
      end module cfront
