      subroutine uincrr(lun)
!
!
!
!======================================================================
!*** Obtain the grid size from carre.out
!======================================================================
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_solps
      implicit none
#include "uinput.inc"
      integer :: lun, ireg, nreg
      character*80 uline
      character*7  dum0
      character*11 dum1
      character*8  dum2
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
      read (uline,'(a, i5)') dum0, nreg
      ! read number of poloidal and radial points per region
      rewind (lun)
      do ireg=1,nreg
        lfound=.false.
        do while (.not.lfound)
          read (lun,'(a)') uline
          lfound=index(uline,'nptseg(').gt.0
        end do
        if(.not.lfound) stop 'Problem with carre.out file'
        read (uline,'(a, i3)') dum1, nptseg(ireg)
      end do
      do ireg=1,nreg
        lfound=.false.
        do while (.not.lfound)
          read (lun,'(a)') uline
          lfound=index(uline,'npr(').gt.0
        end do
        if(.not.lfound) stop 'Problem with carre.out file'
        read (uline,'(a, i3)') dum2, npr(ireg)
      end do
!      do ireg=1,nreg
!        write (*,*) 'Region ', ireg, ' has nptseg, npr = ',
!     .             nptseg(ireg), npr(ireg)
!      enddo
      mnptseg = nreg
      mnpr = nreg

      return
!======================================================================
      end
