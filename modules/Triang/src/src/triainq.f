      program triainq

c  version : 03.10.2016 19:50

c======================================================================
c* This routine outputs info on the triangle containing the
c* reference point and its neighbours.
c* The reference point coordinates [mm] are obtained from standard input
c* If one number only is given, then it is the cell number
c* The triangular mesh data are taken from the fort.3[345] files
c======================================================================
c*  npoint is the actual number of nodes
c*  ntria ... of triangles
c*  px(:),py(:) are the x and y coordinates of nodes
c*  tri(3,:) : triangle vertices (node indices for each triangle)
c*  neigh(3,:) : full list of neighbours
c*  neigr(3,:) : list of open sides
c*  lnodes(3) : indices of their opposite nodes
c*  lcell(2,:) : B2.5 grid indices
c*  xr,yr : coordinates of the reference point

      use eirmod_cinit, only: fort
      implicit none
      integer npoint,ntria
      real,allocatable :: px(:),py(:)
      integer,allocatable :: tri(:,:), neigh(:,:),neigr(:,:),lcell(:,:)
      integer ltri
      integer i,j,k,l,s(3)
      integer cell
      data cell /0/
      character line*72
      real u,xr,yr,xm,xx,ym,yx
      logical dbg
#ifdef DBG
      data dbg /.true./
#else
      data dbg /.false./
#endif

c=======================================================================
c*** Open the data files
      open(21,file=fort//'34',status='old',action='read')
      open(22,file=fort//'33',status='old',action='read')
      open(23,file=fort//'35',status='old',action='read')

c*** Read the data from the input files

      read '(a72)',line
      line=adjustl(line)
      l=index(trim(line),' ')
      if(l.gt.0) then !{
        read (line,*) xr,yr
        xr=0.1*xr
        yr=0.1*yr
        print '(a,1p,2e17.8)','xr,yr=',xr,yr
      else !{
        read(line,*) cell
        print *,'cell= ',cell
      end if !}

      read(22,*) npoint
      write(0,*) 'npoint', npoint
      read(21,*) ntria
      read(23,*) k
      if(k.ne.ntria) then !{
        stop
     .   'ntria values in '//fort//'34 and '//fort//'35 files differ'
      end if !}
      if(cell.gt.ntria) then !{
        write(0,*) 'cell > ntria :',cell,ntria
        stop
      end if !}
c      ntria=11263     !###
      write(0,*) 'ntria ', ntria 
      allocate(tri(3,ntria),neigh(3,ntria),neigr(3,ntria),
     ,                                                  lcell(2,ntria))
      allocate(px(npoint),py(npoint))

c*** read nodes

      read(22,*) px
      read(22,*) py
      write(0,*) '    reading '//fort//'33 is finished'

c*** read elements 

      do i=1,ntria   
        read(21,*) j,(tri(l,i),l=1,3)
      end do
      write(0,*) '    reading '//fort//'34 is finished'
c!###{
c      do i=1,1   
c      write(0,'(a,t12,4i8,1p/(2e17.8))') 'triangle',i,tri(1:3,i),
c     ,                        (px(tri(j,i))*10.,py(tri(j,i))*10.,j=1,3)
c      end do 
c!###}
c*** read neighbours

      do i=1,ntria   
        read(23,*) j,(neigh(k,i),j,neigr(k,i),k=1,3),lcell(:,i)
      end do
      write(0,*) '    reading '//fort//'35 is finished'
c!###{
c      do i=1,1   
c      write(0,'(a,t12,4i8,1p/(2e17.8))') 'triangle',i,tri(1:3,i),
c     ,                        (px(tri(j,i))*10.,py(tri(j,i))*10.,j=1,3)
c      end do 
c!###}

      if(cell.eq.0) then !{

c*** loop over triangles

        ltri=0
        do i=1,ntria !{
c          dbg=i.eq.1      !###
          xm=min(px(tri(1,i)),px(tri(2,i)),px(tri(3,i)))
          ym=min(py(tri(1,i)),py(tri(2,i)),py(tri(3,i)))
          xx=max(px(tri(1,i)),px(tri(2,i)),px(tri(3,i)))
          yx=max(py(tri(1,i)),py(tri(2,i)),py(tri(3,i)))
          if(dbg) write(0,'(a,1p,4e17.8)') 'xm,xx,ym,yx =',xm,xx,ym,yx
          if(dbg) write(0,'(a,t12,4i8,1p/(2e17.8))') 'triangle',i,
     ,            tri(1:3,i),(px(tri(j,i))*10.,py(tri(j,i))*10.,j=1,3)
          if(xr.lt.xm .or. xr.gt.xx .or. yr.lt.ym .or. yr.gt.yx) cycle
          do j=1,3 !{
            k=mod(j,3)+1
            u=(xr-px(tri(j,i)))*(py(tri(k,i))-py(tri(j,i)))-
     -      (yr-py(tri(j,i)))*(px(tri(k,i))-px(tri(j,i))) 
            if(dbg) write(0,'(a,1p,3e17.8)') 'u ',u
            if(u.eq.0) then !{
              write(0,*) 'point on a segment ',tri(j,i),tri(k,i)
              stop
            end if !}
            s(j)=sign(1.,u)
          end do !}
          if(dbg) write(0,*) 'i,s: ',i,s
          if(s(1).eq.s(2) .and. s(2).eq.s(3)) then !{
            ltri=i
c            write(0,*) 'ltri =',ltri          !###
            exit
          end if !}
        end do !}
      else !}{
        ltri=cell
      end if !}
c      dbg=.false.      !###

      write(0,'(a,t12,i8,2x,3i8)') 'ltri=',ltri,tri(:,ltri)
      if(ltri.gt.0) then !{
        write(0,'(1p,t12,2e17.8,i5)') (px(tri(j,ltri))*10.,
     ,                        py(tri(j,ltri))*10.,neigr(j,ltri),j=1,3)
      
        do j=1,3 !{
          k=neigh(j,ltri)
          if(k.gt.0) then !{
            write(0,700) 'neighbour',k,tri(:,k),(px(tri(l,k))*10.,
     ,                                          py(tri(l,k))*10.,l=1,3)
 700        format(a,t12,i8,2x,3i8,1p/(2e17.8))
          end if !}
        end do !}
        if(lcell(1,ltri).gt.0 .or. lcell(2,ltri).gt.0)
     -                             write(0,*) 'B2 ix,iy:',lcell(:,ltri)
      end if !}
c=======================================================================
      end
