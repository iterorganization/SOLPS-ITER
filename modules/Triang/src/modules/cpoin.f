      module cpoin      
      implicit none
      public :: realloc_cpoin
C---- X(*)   : X-COORDINATES OF BOUNDARIES
C---- Y(*)   : Y-COORDINATES OF BOUNDARIES
C---- XA,XB,XC : X-Y- COORDINATES OF VECTORS
C---- NODCON() : THE COORDINATES OF CONNECTION NODE
C---- NPOIN   : TOTAL NUMBER OF POINTS
C---- IA,IB,IC  : INDICES OF POINTS
C---- INODCON : INDEX OF CONNECTION NODE
C---- NFRONT  : TOTAL NUMBER OF FRONTIERS
C---- IKONT  : TOTAL NUMBER OF POINTS FOR EACH FRONTIER
      double precision, allocatable, public, save :: x(:), y(:)
      integer, allocatable, public, save :: ikont(:)

      DOUBLE PRECISION, public, save :: XA(2),XB(2),XC(2),NODCON(2)
      INTEGER, public, save :: NPOIN,IA,IB,IC,INODCON,NFRONT

      contains
      subroutine realloc_cpoin(kennung,incr)
      character*(*) kennung
      integer incr

      double precision, allocatable :: help(:)
      integer, allocatable :: ihelp(:)
      if (kennung .eq. 'xy') then
c         write(6,*) 'vergroessern von ',kennung,' von ',size(x),
c     .              ' auf ',size(x)+incr
         allocate(help(size(x)))

         help = x
         deallocate (x)
         allocate(x(size(help)+incr))
         x = 0.
         x(1:size(help)) = help

         help = y
         deallocate (y)
         allocate(y(size(help)+incr))
         y = 0.
         y(1:size(help)) = help

         deallocate(help)
      elseif (kennung .eq. 'ikont') then
c         write(6,*) 'vergroessern von ',kennung,' von ',size(ikont),
c     .              ' auf ',size(ikont)+incr
         allocate(ihelp(size(ikont)))
         ihelp = ikont
         deallocate (ikont)
         allocate(ikont(size(ihelp)+incr))
         ikont = 0
         ikont(1:size(ihelp)) = ihelp
         deallocate(ihelp)
      else
         write(6,*) 'unknown flag in realloc_cpoin ', kennung
         stop 'error'
      endif
      end subroutine realloc_cpoin
      end module cpoin
