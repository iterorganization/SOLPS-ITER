      module creg      
      implicit none
      public :: realloc_creg
C---- REGION : ALLOWS ADJUSTMENTS OF PRECICION OF GRID
C---- XADEL,YADEL : COORDINATES OF START POINT OF A FRONTIER PART
C---- XEDEL,YEDEL : COORDINATES OF END POINT OF A FRONTIER PART
C---- DELPOIN : MAXIMAL LENGTH BETWEEN OF A FRONTIER PART (CAN BE
C----           CHANGED BY REGION)
C---- DELX : WIDTH OF A REGION
C---- DELY : HEIGHT OF A REGION
C---- NREG : TOTAL NUMBER OF REGIONS
      double precision, allocatable, public, save :: region(:,:)

      DOUBLE PRECISION, public, save :: XADEL,XEDEL,YADEL,YEDEL,
     >                 DELPOIN,DELX,DELY
      INTEGER, public, save :: NREG

      contains
      subroutine realloc_creg(kennung,incr)
      character*(*) kennung
      integer incr

      double precision, allocatable :: help(:,:)
      integer dim1, dim2

      if (kennung .eq. 'region') then
         dim1 = size(region,1)
         dim2 = size(region,2)
c         write(6,*) 'vergroessern von ',kennung,' von (',dim1,
c     .              ',',dim2,') auf (',dim1,',',dim2+incr,')'
         allocate(help(dim1,dim2))
         help = region
         deallocate (region)
         allocate(region(dim1,dim2+incr))
         region = 0.
         region(1:dim1,1:dim2) = help(1:dim1,1:dim2)
         deallocate(help)
      else
         write(6,*) 'unknown flag in realloc_creg ', kennung
         stop 'error'
      endif
      end subroutine realloc_creg
      end module creg
