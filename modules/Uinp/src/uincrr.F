      subroutine uincrr(lun)
!======================================================================
!*** Obtain the grid size from carre.out
!======================================================================
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_solps
#ifdef DIMENSIONS_MODULE
      use b2mod_dimensions
#endif
      use carre_dimensions
      implicit none
#include "uinput.inc"
      integer :: lun, i,j, ireg
      character*80 uline
      character*12  dum0, dum1
      logical lfound
!======================================================================
!
      rewind (lun)
      ! scan file until line 'nreg=' is found
      lfound=.false.
      do while (.not.lfound)
        read (lun,'(a)') uline
        lfound=index(uline,'nreg=').gt.0
      end do
      if(.not.lfound) stop 'Problem with carre.out file'
      read (uline,'(a7, i5)') dum0, nnreg
      mnpr = nnreg
      select case (mnpr)
      case (3)
        mnptseg = 3
      case (5, 6)
        mnptseg = 6
      case default
        write(0,*) 'Unexpected number of radal regions : mnpr = ', mnpr
        call xerrab ('Unknown number of radial regions !')
      end select
      ! read nptseg and npr per region
      rewind (lun)
      do ireg=1,mnptseg
        lfound=.false.
        do while (.not.lfound)
          read (lun,'(a)') uline
          lfound=index(uline,'nptseg(').gt.0
        end do
        if(.not.lfound) stop 'Problem with carre.out file'
        read (uline,'(a11, i3)') dum0, nptseg(ireg)
      end do
      do ireg=1,mnpr
        lfound=.false.
        do while (.not.lfound)
          read (lun,'(a)') uline
          lfound=index(uline,'npr(').gt.0
        end do
        if(.not.lfound) stop 'Problem with carre.out file'
        read (uline,'(a8, i3)') dum0, npr(ireg)
      end do
      ! read nppol and nprad per region
      do ireg=1,nnreg
        lfound=.false.
        do while (.not.lfound)
          read (lun,'(a)') uline
          lfound=index(uline,'nppol=').gt.0
        end do
        if(.not.lfound) stop 'Problem with carre.out file'
        read (uline,'(a8, i5, 2X, a8, i5)')
     .    dum0, nppol(ireg), dum1, nprad(ireg)
      end do
      ! read cellflags and info on degenerate faces
      rewind (lun)
      cflags = 0
      do ireg=1,nnreg
        lfound=.false.
        do while (.not.lfound)
          read (lun,'(a)') uline
          lfound=index(uline,'cellflags').gt.0
        end do
        if(.not.lfound) stop 'Problem with carre.out file'
        do j=1,nprad(ireg)-1
          do i=1,nppol(ireg)-1
            read (lun,'(5i4)') cflags(1:5,i,j,ireg)
          end do
        end do
        lfound=.false.
        do while (.not.lfound)
          read (lun,'(a)') uline
          lfound=index(uline,'degenerate faces').gt.0
        end do
        if(.not.lfound) stop 'Problem with carre.out file'
        do j=1,nprad(ireg)-1
          do i=1,nppol(ireg)-1
            read (lun,'(4i4)') fdegen(1:4,i,j,ireg)
          end do
        end do
      end do
      ! compute number of interal cells, boundary cells and faces
      ncells = 0
      nicells = 0
      nbcells = 0
      nfaces = 0
      ndfaces = 0
      do ireg = 1,nnreg
        ! number of physical cells in this region
        nicells = nicells + count(
     .    (cflags(1,1:nppol(ireg)-1,1:nprad(ireg)-1,ireg).eq.1).or.
     .    (cflags(1,1:nppol(ireg)-1,1:nprad(ireg)-1,ireg).eq.3))
        ! number of boundary faces in this region
        nbcells = nbcells + count(
     .     cflags(2:5,1:nppol(ireg)-1,1:nprad(ireg)-1,ireg).ne.0)
        ! count degenerate faces
        ndfaces = ndfaces + count(
     .     fdegen(:,1:nppol(ireg)-1,1:nprad(ireg)-1,ireg).ne.0)
      enddo
      nbcells = nbcells - ndfaces
      ncells = nicells + nbcells
      nfaces = (4*(nicells - ndfaces) + 3*ndfaces - nbcells)/2 + nbcells
#ifdef DBG
      write (*,*) 'uincrr - nCv, nCi, nCg, nFc = ',
     .  ncells, nicells, nbcells, nfaces
#endif
      return
!======================================================================
      end subroutine uincrr
