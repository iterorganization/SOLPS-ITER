      subroutine uingoat(lun)
!======================================================================
!*** Obtain grid data from the goat grid output file (typically 
!*** traduit.out.b2us)
!======================================================================
      use uinput_mod
      implicit none
      integer :: lun, i, j, ireg, ncount, minfclbl, maxfclbl, dumi(1:6)
      integer, allocatable, dimension(:)    :: fcLbl_in
      character*80 uline
      character*12  dum0, dum1
      logical lfound
!======================================================================
!
      ! Rewind just in case the file was already operated on before
      rewind (lun)

      ! Grid dimensions
      !----------------
      ! scan file until line with 'nCi,nFc,nVx,nCg,nFs,nFt' is found - 
      ! these are the number of internal cells, faces, vertices and
      ! guard cells
      lfound=.false.
      do while (.not.lfound)
        read (lun,'(a)') uline
        lfound=index(uline,'nCi,nFc,nVx,nCg,nFs,nFt').gt.0
      end do

      ! Check if found
      if(.not.lfound) stop 'uingoat: problem with goat grid file ' // 
     , '- could not find the number of cells, faces and vertices.' //
     , ' Check if grid file is corrupt'

      ! Read in dimensions 
      read (lun, *) nicells, nfaces, dumi(1), nbcells, dumi(2:3)

      ! Compute auxiliary dimensions
      ncells = nbcells + nicells ! total number of cells
      
      ! Face labels
      !------------
      ! Rewind
      rewind (lun)

      ! Find face data
      lfound = .false. 
      do while (.not.lfound)
        read (lun,'(a)') uline
        lfound=index(uline,
     ,    '*cf: fc fcVx(:,1) fcVx(:,2) fcLbl fcReg fcAligned').gt.0
      end do
      
      ! Check if found
      if (.not. lfound) stop 'uingoat: could not find face data in ' //
     ,    'grid file, check if grid file is corrupt' 

      ! Read in fcLbl - expected format: face ID, vert1, vert2, fcLbl, fcReg, fcAligned
      allocate(fcLbl_in(nfaces))
      fcLbl = 0
      do i = 1, nfaces 
        read(lun, *) dumi(1:3), fcLbl_in(i), dumi(5:6)
      end do 
      
      ! check which values of fclbl are actually present in the grid (i.e. in cflags).
      nfclblused = 0
      nfclblcoreused = 0
      fclblused = 0
      fclblcoreused = 0
      minfclbl = minval(fcLbl_in)
      maxfclbl = maxval(fcLbl_in)
      do i = minfclbl,maxfclbl
        !tmp: skip core labels, which are treated separately
        if (i == 0) cycle
        if ((i < 0) .and. (mod(i+21, -4) == 0)) then ! core boundaries are assumed to be -21, -25, -29 ...
            if (any(i == fcLbl_in)) then 
                nfclblcoreused = nfclblcoreused + 1
                fclblcoreused(nfclblcoreused) = i 
            end if 
        elseif (any(i == fcLbl_in)) then 
            nfclblused = nfclblused + 1
            fclblused(nfclblused) = i 
        end if 
      enddo

      ! Housekeeping
      deallocate(fcLbl_in)
#ifdef DBG
      write (*,*) 'uincrr - nCv, nCi, nCg, nFc = ',
     .  ncells, nicells, nbcells, nfaces
#endif
      return
!======================================================================
      end subroutine uingoat
