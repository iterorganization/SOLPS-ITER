      module ctria  
      implicit none
      public :: realloc_ctria
      double precision, allocatable, public, save :: xcoord(:),ycoord(:)
      integer, allocatable, public, save :: tria (:,:), neighb(:,:),
     .                                      neighs(:,:), neighr(:,:),
     .                                      trix(:), triy(:)

      INTEGER, public, save :: NCOORD, NTRIA, NTRIA1

      contains
      subroutine realloc_ctria(kennung,incr)
      character*(*) kennung
      integer incr

      double precision, allocatable :: help(:,:), help1(:)
      integer dim1, dim2

      if (kennung .eq. 'xycoord') then
c         write(6,*) 'vergroessern von ',kennung,' von ',size(xcoord),
c     .              ' auf ',size(xcoord)+incr
         allocate(help1(size(xcoord)))
         help1 = xcoord
         deallocate (xcoord)
         allocate(xcoord(size(help1)+incr))
         xcoord = 0.
         xcoord(1:size(help1)) = help1(1:size(help1))

         help1 = ycoord
         deallocate (ycoord)
         allocate(ycoord(size(help1)+incr))
         ycoord = 0.
         ycoord(1:size(help1)) = help1(1:size(help1))
         deallocate(help1)
      elseif (kennung .eq. 'neigh') then
         dim1 = size(neighb,1)
         dim2 = size(neighb,2)
c         write(6,*) 'vergroessern von ',kennung,' von (',dim1,',',dim2,
c     .              ') auf (',dim1,',',dim2+incr,')'
         allocate(help(dim1,dim2))
         help = neighb
         deallocate (neighb)
         allocate(neighb(dim1+incr,dim2))
         neighb = 0.
         neighb(1:dim1,1:dim2) = help(1:dim1,1:dim2)

         help = neighs
         deallocate (neighs)
         allocate(neighs(dim1+incr,dim2))
         neighs = 0.
         neighs(1:dim1,1:dim2) = help(1:dim1,1:dim2)

         help = neighr
         deallocate (neighr)
         allocate(neighr(dim1+incr,dim2))
         neighr = 0.
         neighr(1:dim1,1:dim2) = help(1:dim1,1:dim2)
         deallocate(help)
      elseif (kennung .eq. 'tria') then
         dim1 = size(tria,1)
         dim2 = size(tria,2)
c         write(6,*) 'vergroessern von ',kennung,' von (',dim1,',',dim2,
c     .              ') auf (',dim1,',',dim2+incr,')'
         allocate(help(dim1,dim2))
         help = tria
         deallocate (tria)
         allocate(tria(dim1+incr,dim2))
         tria = 0.
         tria(1:dim1,1:dim2) = help(1:dim1,1:dim2)
         deallocate(help)
      elseif (kennung .eq. 'trixy') then
c         write(6,*) 'vergroessern von ',kennung,' von ',size(trix),
c     .              ' auf ',size(trix)+incr
         allocate(help1(size(trix)))
         help1 = trix
         deallocate (trix)
         allocate(trix(size(help1)+incr))
         trix = 0.
         trix(1:size(help1)) = help1(1:size(help1))

         help1 = triy
         deallocate (triy)
         allocate(triy(size(help1)+incr))
         triy = 0.
         triy(1:size(help1)) = help1(1:size(help1))
         deallocate(help1)
      else
         write(6,*) 'unknown flag in realloc_ctria ', kennung
         stop 'error'
      endif
      end subroutine realloc_ctria
      end module ctria
