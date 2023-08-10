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
       parameter (nlim = 1000, nplgmax = 6, nsegplgmax = 10)
       integer nplg, nnwllplg(nplgmax), nnsegwllplg(nsegplgmax,nplgmax),
     ,      nsegwllplg(nplgmax), nfclblplg(nplgmax)
       integer plgfclbl(2*nsegplgmax,nplgmax)
       real wllplgcoords(3,nlim+1,nsegplgmax,nplgmax)

c*  data of the plasma grid boundary polygons
       integer nbmax, nbvmax
       parameter (nbmax = 100,nbvmax=500)
       integer nb, lblplsplg(nbmax), nnplsplg(nbmax)
       real plsplgcoords(3,nbvmax,nbmax)

c*  data for the final polygons
       integer nnplg(nplgmax)
       real coords(3,2*nsegplgmax*nbvmax+(nlim+1)*nsegplgmax,nplgmax),
     ,      coordsend(3)

c*  other
      integer i,j,k,l,n,iout,iplsplg
      real maxlen
      character line*72
      character filename*7, topo*4, dumm*20, hlp_frm*20
      logical dbg
#ifdef DBG
      data dbg /.true./
#else
      data dbg /.false./
#endif

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

c*** Read the data from the wall polygons from fort.48
      write (*,*) 'triainp --> reading fort.48'
      filename=fort_lc//'48'
      open(48,file=filename,status='old',action='read')
      read(48,'(a)') topo
      read(48,'(i4)') nplg

      wllplgcoords=0.0
      do i=1,nplg
        read(48,'(3(i4))') nnwllplg(i), nsegwllplg(i), nfclblplg(i)
        write(hlp_frm,'(a,i1,a)') '(',nfclblplg(i),'(i4))'
        read (48,hlp_frm) plgfclbl(1:nfclblplg(i),i)
        do j=1,nsegwllplg(i)
          read(48,'(i12)') n
          nnsegwllplg(j,i)=n
          do k=1,n
            read(48,'(2(2X,E21.14))') wllplgcoords(1:2,k,j,i)
          enddo
        end do
      end do
      !close(48)

c*** Connect the vessel and plasma grid polygons into closed polygons for void
c*** triangulation with tria

      nnplg=0
      coords=0.0

      write (*,*) 'Topology: ',topo

      do i=1,nplg
        if (nsegwllplg(i).gt.1) then
          write (*,*) 'Polygon ', i,' has more that one segment.'
          write (*,*) 'Not supported yet by trianinp.'
          stop
        endif

        ! polygon start: the first wall polygon
        ! exclude first and last points => to be replaced by grid points
        coords(1:2,2:nnwllplg(i)-1,i) = 
     ,    wllplgcoords(1:2,2:nnwllplg(i)-1,1,i)
        nnplg(i) = nnplg(i) + nnwllplg(i) - 1

        ! append the plasma polygons, in reverse order, following conventions for face normals
        do j=1,nfclblplg(i)
          iplsplg = findloc(lblplsplg,plgfclbl(j,i),1)
          if (iplsplg.ne.0) then
            coords(1:2,nnplg(i)+1:nnplg(i)+nnplsplg(iplsplg)-1,i) = 
     ,        plsplgcoords(1:2,nnplsplg(iplsplg):2:-1,iplsplg)
            nnplg(i) = nnplg(i) + nnplsplg(iplsplg) - 1
            coordsend(1:2) = plsplgcoords(1:2,1,iplsplg)
          else
            write (*,*) 'Found no plasma polygon with fcLbl ',
     ,                  plgfclbl(j,i),' needed for polygon ', i, '.'
            write (*,*) 'Skipping.'
          endif
        end do

        ! append end coordinate, and set equal to start
        nnplg(i) = nnplg(i) + 1
        coords(1:2,nnplg(i),i) = coordsend(1:2)
        coords(1:2,1,i) = coordsend(1:2)

      enddo

      ! tmp; dummy
      maxlen = 0.0

c*** Write output file
cwdk  write additional file with (part of) the polygons for triangulation
      open(78,file='fort.78')
      write (78,*) maxlen
      write (78,*)
      do i=1,nplg
        write(78,'(i12)') nnplg(i)
        do j=1,nnplg(i)
          write(78,'(2(2X,E21.14))') coords(1:2,j,i)*100.
        end do
      end do
      !close(78)

      write (*,*) 'triainp --> stopping'
      stop
c=======================================================================
      end program triainp
