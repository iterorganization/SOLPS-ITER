      module celm     
      implicit none
      public :: realloc_celm
C---- IELM : ARRAY OF TRIANGLES
C---- NELM : TOTAL NUMBER OF TRIANGLES
C---- IADJA : ADJACENCY-MATRIX
C---- ISIDE : ADJACENT SIDE OF NEIGHBOURING TRIANGLE
C---- IPROP : 0 IF THERE IS AN ADJACENT TRIANGLE, OTHERWISE VALUE
C----         DEPENDS ON INDEX OF BOUNDARY
      integer, allocatable, public, save :: ielm(:,:), iadja(:,:), 
     .                                      iside(:,:), iprop(:,:)

      INTEGER, public, save :: NELM

      contains
      subroutine realloc_celm(kennung,incr)
      character*(*) kennung
      integer incr

      integer, allocatable :: ihelp(:,:)
      integer dim1, dim2

      if (kennung .eq. 'ielm') then
         dim1 = size(ielm,1)
         dim2 = size(ielm,2)
c         write(6,*) 'vergroessern von ',kennung,' von (',dim1,
c     .              ',',dim2,') auf (',dim1,',',dim2+incr,')'
         allocate(ihelp(dim1,dim2))
         ihelp = ielm
         deallocate (ielm)
         allocate(ielm(dim1,dim2+incr))
         ielm = 0.
         ielm(1:dim1,1:dim2) = ihelp(1:dim1,1:dim2)
         deallocate(ihelp)
      else
         write(6,*) 'unknown flag in realloc_celm ', kennung
         stop 'error'
      endif
      end subroutine realloc_celm
      end module celm
