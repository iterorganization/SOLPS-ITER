      subroutine uingoatvoids(lun)
!======================================================================
!*** Obtain void polygon data from the goat void polygon description
!*** (typically stored in fort_goat.78). It is assumed that the file is
!*** contains for (closed) void polygon the following data (in this 
!*** order): x, y, dosplit, gridvertexID, elID1, elID2, vertID. Here:
!***  - x, y are the coordinates of the point
!***  - dosplit is 1 if it connects to a splittable edge (for tria)
!***  - gridvertexID: the grid vertex index, if it is a grid vertex 
!***    (zero otherwise)
!***  - elID1, elID2 are the elements in DivGeo it connects to
!***  - vertID: the vertex index (not used here)
!======================================================================
      use uinput_mod
      implicit none
      integer :: lun, i, j, ireg, ncount, minfclbl, maxfclbl, dumi(1:6), 
     .   readstatus, np, nvoidel
      integer, allocatable, dimension(:)    :: fcLbl_in, tempelID1, 
     .  tempelID2, tempvertID, tempgridvertID, tempdosplit, tempvoidelID
      real, allocatable, dimension(:) :: tempx, tempy, tempvoidx1, 
     .  tempvoidx2, tempvoidy1, tempvoidy2 
      logical, allocatable, dimension(:)  :: isvoidvertex
      character*80 uline
      character*12  dum0, dum1
      logical lfound, templ1, templ2 
      integer :: vc 
!======================================================================
!
      ! Rewind just in case the file was already operated on before
      rewind (lun)

      ! Initialize
      !-----------
      ! Check initialization
      if (allocated(voidelID)) deallocate(voidelID)
      if (allocated(voidelx1)) deallocate(voidelx1)
      if (allocated(voidelx2)) deallocate(voidelx2)
      if (allocated(voidely1)) deallocate(voidely1)
      if (allocated(voidely2)) deallocate(voidely2)

      ! Preallocate and grow dynamically later
      allocate(voidelID(0), voidelx1(0), voidelx2(0), voidely1(0), 
     .  voidely2(0))

      ! Skip the first line - contains delta0
      read (lun, '(a)') uline 

      ! Read until a non-empty line is found
      lfound = .false.
      do while (.not. lfound)
        read (lun, '(a)') uline
        if (len(trim(uline)) /= 0) then 
          lfound = .true.
          backspace(lun)
        end if 
      end do 

      ! Read polygons
      do while (.true.)
        ! Read the number of vertices of the next polygon, if present
        read(lun, *, iostat=readstatus) np
        
        ! Check for eof
        if (readstatus /= 0) then 
          exit 
        end if 

        ! Read data
        allocate(tempx(np), tempy(np), tempdosplit(np), 
     .    tempgridvertID(np), tempelID1(np), tempelID2(np), 
     .    tempvertID(np), isvoidvertex(np))
        do i = 1, np 
          ! Read
          read(lun, *, iostat=readstatus) tempx(i), tempy(i), 
     .       tempdosplit(i), tempgridvertID(i), tempelID1(i), 
     .       tempelID2(i), tempvertID(i)

          ! Check
          if (readstatus /= 0) then 
            ! This shouldn't happen - premature end of file
             call xerrab('uingoatvoids: premature end of file while ' // 
     .        'reading void polygons from goat, check input.goatvoids')
          end if

          ! Check if vertex is a void vertex
          if (tempdosplit(i) == 1) then 
            isvoidvertex(i) = .true. 
          else
            isvoidvertex(i) = .false. 
          end if 
        end do

        ! Get an overestimate of the number of void elements of this polygon
        nvoidel = count(isvoidvertex)

        ! Allocate
        allocate(tempvoidx1(nvoidel), tempvoidx2(nvoidel), 
     .    tempvoidy1(nvoidel), tempvoidy2(nvoidel), 
     .    tempvoidelID(nvoidel))

        ! Assign to void data structures 
        vc = 0
        do i = 1, np-1
          ! Check if the next two vertices form a void element
          if (isvoidvertex(i) .and. isvoidvertex(i+1)) then 
            ! Update counter
            vc = vc + 1

            ! Checks
            if (tempelID1(i) == 0) then ! second entry can be zero, but not nonzero if the first one is zero
              if (tempelID2(i) /= 0) then 
                ! Move to ID1
                tempelID1(i) = tempelID2(i)
                tempelID2(i) = 0
              else
                ! May happen if goat was not started from divgeo input...
                call xerrab('uingoatvoids: void vertex that does not '//
     .           'have any elements encountered. Did you run goat ' // 
     .           'starting from DivGeo .dgo input?')
              end if 
            end if 
            if (tempelID1(i+1) == 0) then 
              if (tempelID2(i+1) /= 0) then 
                ! Move to ID1
                tempelID1(i+1) = tempelID2(i+1)
                tempelID2(i+1) = 0
              else
                ! May happen if goat was not started from divgeo input...
                call xerrab('uingoatvoids: void vertex that does not '//
     .           'have any elements encountered. Did you run goat ' // 
     .           'starting from DivGeo .dgo input?')
              end if 
            end if 
            if ((tempelID1(i) == tempelID2(i)) .or. 
     .        (tempelID1(i) == tempelID2(i))) then 
              ! Shouldn't happen
              call xerrab('uingoatvoids: element has twice the same ' //
     .           'element ID, unexpected')
            end if 

            ! Assign coordinates
            tempvoidx1(vc) = tempx(i)
            tempvoidx2(vc) = tempx(i+1)
            tempvoidy1(vc) = tempy(i)
            tempvoidy2(vc) = tempy(i+1)

            templ1 = any(
     .         tempelID1(i) == [tempelID1(i+1), tempelID2(i+1)] 
     .         .and. ([tempelID1(i+1), tempelID2(i+1)] /= 0))
            templ2 =  any(
     .         tempelID2(i) == [tempelID1(i+1), tempelID2(i+1)] 
     .         .and. ([tempelID1(i+1), tempelID2(i+1)] /= 0))
            if (tempelID2(i) == 0) then 
              if (templ1) then 
                tempvoidelID(vc) = tempelID1(i)
              else
                call xerrab('uingoatvoids: could not find element')
              end if 
            else
              if (templ1 .and. templ2) then
                ! Duplicate elements
                call xerrab('uingoatvoids: multiple elements found')
              elseif (templ1) then 
                tempvoidelID(vc) = tempelID1(i)
              elseif (templ2) then 
                tempvoidelID(vc) = tempelID2(i)
              else
                ! None foud
                call xerrab('uingoatvoids: could not find element')
              end if 
            end if   
          end if         
        end do 

        ! Add
        voidelID = [voidelID, tempvoidelID(1:vc)]
        voidelx1 = [voidelx1, tempvoidx1(1:vc)]
        voidelx2 = [voidelx2, tempvoidx2(1:vc)]
        voidely1 = [voidely1, tempvoidy1(1:vc)]
        voidely2 = [voidely2, tempvoidy2(1:vc)]

        ! Housekeeping
        deallocate(tempx, tempy, tempdosplit, tempgridvertID, 
     .    tempelID1, tempelID2, tempvertID)
        deallocate(tempvoidx1, tempvoidx2, tempvoidy1, tempvoidy2, 
     .    tempvoidelID, isvoidvertex)

      end do
      return
!======================================================================
      end subroutine uingoatvoids
