      program triainp

c  version : 09.08.2023 14:00

c======================================================================
c* This routine prepares the polygons for tria from uinp and b2ag
c* output files:
c* - fort.30 from b2ag, containing the boundary polygons of the plasma
c*   grid
c* - fort.40 from uinp, containing the element polygons of the vessel
c* The output is the fort.78 file
c======================================================================
      use eirmod_cinit, only: fort_lc
      implicit none

c*  data of the wall element polygons
       integer nlim, nplgmax, nsegplgmax
       parameter (nlim = 1000, nplgmax = 20, nsegplgmax = 20)
       integer nplg, nnwllplg(nplgmax), nnsegwllplg(nsegplgmax,nplgmax),
     ,      nsegwllplg(nplgmax), nfclblplg(nplgmax)
       integer plgfclbl(2*nsegplgmax,nplgmax)
       double precision wllplgcoords(3,nlim+1,nsegplgmax,nplgmax)

c*  data of the plasma grid boundary polygons
       integer nbmax, nbvmax
       parameter (nbmax = 100,nbvmax=500)
       integer nb, lblplsplg(nbmax), nnplsplg(nbmax)
       double precision plsplgcoords(3,nbvmax,nbmax)

c*  data for the final polygons
       integer nnplg(nplgmax), nnsegpls(nsegplgmax,nplgmax)
       integer split(2*nsegplgmax*nbvmax+(nlim+1)*nsegplgmax,nplgmax)
       double precision
     ,      coords(3,2*nsegplgmax*nbvmax+(nlim+1)*nsegplgmax,nplgmax),
     ,      coordsend(3), c0(3), c1(3), n0(3), n1(3),
     ,      plscoords(3,nbvmax,nsegplgmax,nplgmax)

c*  other
      integer i,j,k,n,iplsplg
      double precision maxlen
      logical lfound, lstop, lbeg, lend
      character filename*7, topo*4, hlp_frm*20
      integer find_loc
      double precision dist
      external find_loc, dist

c=======================================================================

c*** Read the data from the plasma boundary polygons from fort.30
      write (*,*) 'triainp --> reading fort.30'
      filename=fort_lc//'30'
      open(30,file=filename,status='old',action='read')

      read(30,'(i3)') nB
      if (nB.gt.nbmax) stop 'triainp -- increase value of nbmax'

      plsplgcoords=0.0
      do i = 1,nb
        read(30,'(i3)') lblplsplg(i)
        read(30,'(i12)') nnplsplg(i)
        do j = 1,nnplsplg(i)
          read(30,'(2(2X,E21.14))') plsplgcoords(1:2,j,i)
        end do
      end do
      !close(30)

      write (*,'(a,i3,a)') 'Read ',nB,' plasma boundaries from fort.30'
      write (*,'(a,100(i3))') 'fcLbl  = ', lblplsplg(1:nB)
      write (*,'(a,100(i3))') 'length = ', nnplsplg(1:nB)

c*** Read the data from the wall polygons from fort.48
      write (*,*) 'triainp --> reading fort.48'
      filename=fort_lc//'48'
      open(48,file=filename,status='old',action='read')
      read(48,'(a)') topo
      read(48,'(i4)') nplg

      if (nplg.gt.nplgmax)  stop 'triainp -- increase value of nplgmax'

      wllplgcoords=0.0
      do i=1,nplg
        read(48,'(3(i4))') nnwllplg(i), nsegwllplg(i), nfclblplg(i)
        if (nsegwllplg(i).gt.nsegplgmax)  
     .    stop 'triainp -- increase value of nsegplgmax'
        if (nfclblplg(i) .gt. 0 ) then
          write(hlp_frm,'(a,i1,a)') '(',nfclblplg(i),'(i4))'
          read (48,hlp_frm) plgfclbl(1:nfclblplg(i),i)
        endif
        do j=1,nsegwllplg(i)
          read(48,'(i12)') n
          nnsegwllplg(j,i)=n
          do k=1,n
            read(48,'(2(2X,E13.6))') wllplgcoords(1:2,k,j,i)
          enddo
        end do
      end do
      !close(48)

      write (*,'(a,i3,a)') 'Read ', nplg, ' polygons from fort.48'
      do i = 1,nplg
        write(hlp_frm,'(a,i2,a)') '(a,i3,a,i3,a,',nsegwllplg(i),'(i3))'
        write (*,hlp_frm) 'Plg ', i, ' has ', nsegwllplg(i),
     ,          ' segments with length ', nnsegwllplg(1:nsegwllplg(i),i)
        if (nfclblplg(i) .gt. 0) then
        write (*,'(a,i3,a,10(i4))') 'Plasma boundaries to close plg ',i,
     ,          ': ', plgfclbl(1:nfclblplg(i),i)
        elseif (nsegwllplg(i).ne.1) then

          write(*,'(a,i3,a,i3,a)') 'Problem with polygon ', i,': ',
     ,      nsegwllplg(i), ' segments but no plasma boundaries defined.'
        endif
      enddo


c*** Connect the parts of the plasma polygons that form a continuous boundary
c*** Assume that NSS parts will be sorted per wall segment, but possibly in reverse order

      write (*,*) 'triainp --> constructing plasma polygons'

      plscoords = 0.0
      nnsegpls = 0


      do i = 1,nplg

        if (nfclblplg(i).eq.0) cycle

        k = 0

        do j = 1,nsegwllplg(i)

          ! find the first segment
          lfound = .false.
          do while (.not.lfound.and.k.lt.nfclblplg(i))

            k = k + 1

            ! The face label of the next plasma part
            iplsplg = find_loc(lblplsplg,nB,plgfclbl(k,i))

            if (iplsplg.ne.0) then

                ! add first plasma boundary segment to beginning of plasma polygon
                plscoords(1:2,1:nnplsplg(iplsplg),j,i) =
     ,            plsplgcoords(1:2,1:nnplsplg(iplsplg),iplsplg)
                nnsegpls(j,i) = nnplsplg(iplsplg)

                ! store start and end
                c0 = plscoords(:,1,j,i)
                c1 = plscoords(:,nnsegpls(j,i),j,i)

                lfound = .true.

            else

              write (*,'(a,i3,a,i3)') 'Found no plasma polygon with '//
     ,          'fcLbl ', plgfclbl(k,i),' needed for polygon ', i, '.'
              write (*,*) 'Skipping.'

            endif

          enddo

          if (.not.lfound) then
            write (*,'(a,i3,i3)') 'trianp -- did not find plasma '//
     .                  'boundary for segment ipol, iseg = ', i, j
            stop
          endif

          ! check for consecutive segments

          lstop = .false.

          ! Start from the next plasma polygon section
          do while (.not.lstop.and.k.lt.nfclblplg(i))

            ! The face label of the next plasma part
            iplsplg = find_loc(lblplsplg,nB,plgfclbl(k+1,i))

            if (iplsplg.ne.0) then

              lbeg = .false.
              lend = .false.

              ! start and end points of the new boundary segment
              n0(1:2) = plsplgcoords(1:2,1,iplsplg)
              n1(1:2) = plsplgcoords(1:2,nnplsplg(iplsplg),iplsplg)

              ! check whether it connects to start or end of current segment
              if (dist(c0(1),c0(2),n1(1),n1(2)).lt.1.e-6) lbeg = .true.
              if (dist(c1(1),c1(2),n0(1),n0(2)).lt.1.e-6) lend = .true.

              if (lbeg) then

                k = k + 1

                ! shift polygon back
                plscoords(1:2,nnplsplg(iplsplg):
     ,            nnplsplg(iplsplg)+nnsegpls(j,i)-1,j,i) =
     ,            plscoords(1:2,1:nnsegpls(j,i),j,i)

                ! add plasma boundary segment to beginning of plasma polygon
                plscoords(1:2,1:nnplsplg(iplsplg)-1,j,i) =
     ,            plsplgcoords(1:2,1:nnplsplg(iplsplg)-1,iplsplg)
                nnsegpls(j,i) = nnsegpls(j,i) + nnplsplg(iplsplg) - 1

                ! store start and end
                c0 = plscoords(:,1,j,i)
                c1 = plscoords(:,nnsegpls(j,i),j,i)

              elseif (lend) then

                k = k + 1

                ! add plasma boundary segment to beginning of plasma polygon
                plscoords(1:2,nnsegpls(j,i)+1:
     ,            nnsegpls(j,i)+nnplsplg(iplsplg)-1,j,i) =
     ,            plsplgcoords(1:2,2:nnplsplg(iplsplg),iplsplg)
                nnsegpls(j,i) = nnsegpls(j,i) + nnplsplg(iplsplg) - 1

                ! store start and end
                c0 = plscoords(:,1,j,i)
                c1 = plscoords(:,nnsegpls(j,i),j,i)

              else

                ! reached end of the continuous plasma boundary
                lstop = .true.

              endif

            else

              k = k + 1

            endif

          end do

        end do

      end do




c*** Connect the vessel and plasma grid polygons into closed polygons for void
c*** triangulation with tria

      write (*,*) 'triainp --> combining wall & plasma polygon segments'

      nnplg = 0
      coords = 0.0
      split = 0

      do i = 1,nplg

        if (nfclblplg(i).eq.0) then

          ! special case of simple closed polygon, no plasma segments
          coords(1:2,2:nnsegwllplg(1,i),i) =
     ,      wllplgcoords(1:2,2:nnsegwllplg(1,i),1,i)
          ! wall segments can be split by tria later on
          split(2:nnsegwllplg(1,i),i) = 1
          nnplg(i) = nnsegwllplg(1,i) - 1

        else

        do j = 1,nsegwllplg(i)

          ! add the next wall polygon segment
          ! exclude first and last points => to be replaced by grid points
          coords(1:2,nnplg(i)+2:nnplg(i)+nnsegwllplg(j,i)-1,i) =
     ,      wllplgcoords(1:2,2:nnsegwllplg(j,i)-1,j,i)
          ! wall segments can be split by tria later on
          split(nnplg(i)+1:nnplg(i)+nnsegwllplg(j,i)-1,i) = 1
          nnplg(i) = nnplg(i) + nnsegwllplg(j,i) - 1

          ! add the next the plasma boundary for this segment
          ! coordinates per segment in reverse order, following conventions for face normals
          ! keep the exact coordinates for the end points of the plasma boundary to avoid gaps
          coords(1:2,nnplg(i)+1:nnplg(i)+nnsegpls(j,i),i) =
     ,      plscoords(1:2,nnsegpls(j,i):1:-1,j,i)
          nnplg(i) = nnplg(i) + nnsegpls(j,i) - 1
          coordsend(1:2) = plscoords(1:2,1,j,i)

        end do

        end if

        ! set start of polygon equal to end
        nnplg(i) = nnplg(i) + 1
        coords(1:2,1,i) = coords(1:2,nnplg(i),i)

        ! last point equal to first => set value of split to correspond to wall
        split(nnplg(i),i) = 1

      enddo

      ! tmp; dummy
      maxlen = 0.0

c*** Write output file
cwdk  write additional file with (part of) the polygons for triangulation

      write (*,*) 'triainp --> writing fort.78 file'

      open(78,file='fort.78')
      write (78,*) maxlen
      write (78,*)
      do i=1,nplg
        write(78,'(i12)') nnplg(i)
        do j=1,nnplg(i)
          write(78,'(2(2X,E21.14),I3)') coords(1:2,j,i)*100.,split(j,i)
        end do
      end do
      !close(78)

      write (*,*) 'triainp --> end'
      stop
c=======================================================================
      end program triainp
