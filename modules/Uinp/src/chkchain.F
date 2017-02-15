c      parameter (n=6,m=6)
c      dimension p1(3,n),p2(3,n),ind(m*2),ls(m)
c      data (p1(1,j),p1(2,j),p2(1,j),p2(2,j),j=1,n) /
c     1        0.,     0.,     1.,     0.,
c     2        1.,     0.,     1.,     1.,
c     3        1.,     1.,     1.,     2.,
c     4        1.,     2.,     0.,     2.,
c     5        0.,     2.,     0.,     1.,
c     6        0.,     1.,     0.,     0./
c      data ls /1,2,5,3,6,4/
c      call chkchain(p1,p2,3,n,ls,4,2,ind,irt)
c      print *,'irt= ',irt
c      if(irt.gt.0) print *,'ind= ',ind
c      end


      subroutine chkchain(p1,p2,mp,np,ls,ns,nc,ind,irt,
     . jedgep,jedgec,jedge,nt)

c  version : 31.03.2005 19:39

c=======================================================================
c*** Sort the list of segments to form chains
c***
c*** Input:
c*** 
c***  p1,p2 : starting and ending points of the segments (x,y,...)
c***  mp    : the first dimension in arrays p1, p2 - only first 2 used
c***  np    : total number of segments
c***  ls    : list of segments to be ordered
c***  ns    : its length
c***  nc    : max. number of chains
c***  nt    : number of targets
c*** 
c*** Output:
c*** 
c***  ind   : sorted list of the segment indices
c***  irt   : return code (>0 - number of chains, <0 - error)
c***
c*** ind is organised in sections corresponding to the found chains.
c*** The absolute value of the first element of a section gives the
c*** length of the chain, negative if the chain is closed.
c=======================================================================

      implicit none
      integer mp,np,ns,nc,nt,ls(ns),irt,ind(ns+nc)
      integer jedgep(nt),jedgec(nt),jedge(2,nc)
      real p1(mp,np),p2(mp,np)

c*** Local variables

c*** tol:     tolerance in the alignment of the segment ends

      real tol
      parameter (tol=1.e-6)

c*** inext and iprvs are the references to the next and previous segment

      integer inext(ns),iprvs(ns)

c*** done:  the segment is not yet written to the output
c*** next:    the next segment not found yet
c*** prvs:    the previous segment not found yet
c*** free:    one of the ends of the segment is not yet linked

      logical done(ns),next(ns),prvs(ns),free(ns),b,open

      integer i,j,k,l,i1,i2,ib,ic,ii,iii
      real w
      logical match
      external subini, subend, xerrab
c      logical bbb !###
c=======================================================================
      call subini ('chkchain')
c!###{
c      write(*,*) '=== Starting chkchain: mp,np,ns,nc=',mp,np,ns,nc
c      write(*,'(1x,a4,20i4/(5x,20i4))') 'ls= ',ls
c      write(*,*) 'p1,p2:'
c      write(*,'(1p,4e13.4)') (p1(1,i),p1(2,i),p2(1,i),p2(2,i),i=1,np)
c      write(*,*)
c!###}
      if(mp.lt.2) then !{
#ifdef FLUSH
        call FLUSH(6)
#endif
        write(0,*) 'chkchain: too small first dimension in the ',
     ,                            'segment arrays. Must be > 1, is ',mp
#ifdef FLUSH
        call FLUSH(0)
#endif
        irt=-3
        goto 9999
      end if !}
      k=0
      do i=1,ns !{
        free(i)=.true.
        next(i)=.true.
        prvs(i)=.true.
        done(i)=.false.
        inext(i)=0
        iprvs(i)=0
        if(ls(i).le.0 .or. ls(i).gt.np) then !{
          k=k+1
          ind(k)=i
        end if !}
      end do !}
      if(k.gt.0) then !{
#ifdef FLUSH
        call FLUSH(6)
#endif
        write(*,*) 'chkchain: requested index outside ',
     ,                                      'the segment list.  np= ',np
        write(*,'(/1x,2a12)') 'index','requested'
        write(*,'(1x,i8,i12)') (ind(i),ls(ind(i)),i=1,k)
#ifdef FLUSH
        call FLUSH(0)
#endif
        irt=-2
        goto 9999
      end if !}

      do 100 i=1,ns-1 !{
c!###{
c        write(*,'(1x,a,2i5,1p,4f6.1)') '=== i,ls(i),p1,p2 = ',i,
c     ,            ls(i),p1(1,ls(i)),p1(2,ls(i)),p2(1,ls(i)),p2(2,ls(i))
c        bbb=i.eq.135
c        bbb=.true.
c        write(*,*) '       free next prvs inext iprvs'
c        write(*,'(i5,3l5,2i6)') (l,free(l),next(l),prvs(l),
c     ,                                        inext(l),iprvs(l),l=1,ns)
c!###}
        if(free(i)) then !{
          do 110 j=i+1,ns !{
c!###{
c            if(bbb) write(*,*) '=== j,ls(j),... = ',j,ls(j),
c     ,                        free(j),next(j),prvs(j),inext(j),iprvs(j)
c!###}            if(.not. free(j)) go to 110
            if(next(j)) then !{

c              write(*,*) '== next(j)' !###

              if(prvs(i)) then !{

c*** begin i vs end j
c!###{
c                write(*,'(1x,a,2x,1p,4e13.5)') '== prvs(i):',
c     ,                  p1(1,ls(i)),p2(1,ls(j)),p1(2,ls(i)),p2(2,ls(j))
c!###}
                match = .true.
                do k = 1, nt !{
                  if ((ls(i).eq.jedgep(k) .and.
     .                          jedge(1,(k-1)*2+1).eq.1) .or.
     .                (ls(j).eq.jedgec(k) .and.
     .                          jedge(1,k*2).eq.2)) then
                    match = .false.
                  end if
                end do !}
                match = match .and.
     .                 (abs(p1(1,ls(i))-p2(1,ls(j))).le.tol .and.
     .                  abs(p1(2,ls(i))-p2(2,ls(j))).le.tol)
                if (match) then !{
c!###{
c                  bbb=j.eq.136 .or.bbb
c                  if(bbb) write(*,*) '=== i,j,...(j) = ',i,j,
c     ,                        free(j),next(j),prvs(j),inext(j),iprvs(j)
c!###}
                  inext(j)=i
                  iprvs(i)=j
                  prvs(i)=.false.
                  next(j)=.false.
                  free(j)=next(j).or.prvs(j)
                  free(i)=next(i).or.prvs(i)
                  if(.not.free(i)) go to 100
                  go to 110
                end if !}
              end if !}
              if(next(i)) then !{

c*** end i vs end j
c!###{
c                if(bbb) write(*,'(1x,a,2x,1p,4e10.2)') '== next(i)',
c     ,                  p2(1,ls(i)),p2(1,ls(j)),p2(2,ls(i)),p2(2,ls(j))
c!###}
                match = .true.
                do k = 1, nt !{
                  if ((ls(i).eq.jedgep(k) .and.
     .                          jedge(1,(k-1)*2+1).eq.2) .or.
     .                (ls(j).eq.jedgec(k) .and.
     .                          jedge(1,k*2).eq.2)) then
                    match = .false.
                  end if
                end do !}
                match = match .and.
     .                 (abs(p2(1,ls(i))-p2(1,ls(j))).le.tol .and.
     .                  abs(p2(2,ls(i))-p2(2,ls(j))).le.tol)
                if (match) then !{
c!###{
c                  bbb=j.eq.136 .or.bbb
c                  if(bbb) write(*,*) '=== i,j,... :'
c                  if(bbb) write(*,*) i,ls(i),
c     ,                        free(i),next(i),prvs(i),inext(i),iprvs(i)
c                  if(bbb) write(*,*) j,ls(j),
c     ,                        free(j),next(j),prvs(j),inext(j),iprvs(j)
c!###}
                  inext(j)=i
                  next(j)=.false.
                  free(j)=next(j).or.prvs(j)
                  inext(i)=j
                  next(i)=.false.
                  free(i)=next(i).or.prvs(i)

c*** change the orientation of the chain descending from j

                  k=j

c                  if(bbb) write(*,*) '*40: start. k =',k         !###

                  do ii=1,ns !{
c!###{
c
c                    if(bbb) write(*,*) 'ii,k,...(k) = ',ii,k,
c     ,                        free(k),next(k),prvs(k),inext(k),iprvs(k)
c!###}
                    w=p1(1,ls(k))
                    p1(1,ls(k))=p2(1,ls(k))
                    p2(1,ls(k))=w
                    w=p1(2,ls(k))
                    p1(2,ls(k))=p2(2,ls(k))
                    p2(2,ls(k))=w
                    b=prvs(k)
                    prvs(k)=next(k)
                    next(k)=b
                    l=iprvs(k)
                    iprvs(k)=inext(k)
                    inext(k)=l

c                    if(bbb) write(*,*) ii,k,inext(k),next(k) !###

                    if(next(k)) go to 40
                    k=inext(k)
                  end do !}
#ifdef FLUSH
                  call FLUSH(6)
#endif
                  call xerrab ('Something wrong with re-ordering')
 40               if(.not.free(i)) go to 100
                  go to 110
                end if !}
              end if !}
            end if !}
            if(prvs(j)) then !{

c*** end i vs begin j

c              write(*,*) '== prvs(j)'         !###

              if(next(i)) then !{
c!###{
c
c              write(*,'(1x,a,2x,1p,4e13.5)') '== next(i)',
c     ,             p2(1,ls(i)),p1(1,ls(j)),p2(2,ls(i)),p1(2,ls(j))
c!###}
                match = .true.
                do k = 1, nt !{
                  if ((ls(i).eq.jedgep(k) .and.
     .                          jedge(1,(k-1)*2+1).eq.2) .or.
     .                (ls(j).eq.jedgec(k) .and.
     .                          jedge(1,k*2).eq.1)) then
                    match = .false.
                  end if
                end do !}
                match = match .and.
     .                 (abs(p2(1,ls(i))-p1(1,ls(j))).le.tol .and.
     .                  abs(p2(2,ls(i))-p1(2,ls(j))).le.tol)
                if (match) then !{
c!###{
c
c                  bbb=j.eq.136 .or.bbb
c                  if(bbb) write(*,*) '=== i,j,...(j) = ',i,j,
c     ,                        free(j),next(j),prvs(j),inext(j),iprvs(j)
c!###}


                  iprvs(j)=i
                  inext(i)=j
                  next(i)=.false.
                  prvs(j)=.false.
                  free(j)=prvs(j).or.next(j)
                  free(i)=prvs(i).or.next(i)
                  if(.not.free(i)) go to 100
                  go to 110
                end if !}
              end if !}
              if(prvs(i)) then !{

c*** begin i vs begin j
c!###{
c
c                write(*,'(1x,a,2x,1p,4e10.2)') '== prvs(i)',
c     ,                  p1(1,ls(i)),p1(1,ls(j)),p1(2,ls(i)),p1(2,ls(j))
c!###}
                match = .true.
                do k = 1, nt !{
                  if ((ls(i).eq.jedgep(k) .and.
     .                          jedge(1,(k-1)*2+1).eq.1) .or.
     .                (ls(j).eq.jedgec(k) .and.
     .                          jedge(1,k*2).eq.1)) then
                    match = .false.
                  end if
                end do !}
                match = match .and.
     .                 (abs(p1(1,ls(i))-p1(1,ls(j))).le.tol .and.
     .                  abs(p1(2,ls(i))-p1(2,ls(j))).le.tol)
                if (match) then !{
c!###{
c
c                  bbb=j.eq.136 .or.bbb
c                  if(bbb) write(*,*) '=== i,j,...(j) = ',i,j,
c     ,                        free(j),next(j),prvs(j),inext(j),iprvs(j)
c!###}

                  iprvs(j)=i
                  prvs(j)=.false.
                  free(j)=prvs(j).or.next(j)
                  iprvs(i)=j
                  prvs(i)=.false.
                  free(i)=prvs(i).or.next(i)

c*** change the orientation of the chain ascending from j

                  k=j

c                  if(bbb) write(*,*) '*50: start. k ='     !###

 50               w=p2(1,ls(k))
                  p2(1,ls(k))=p1(1,ls(k))
                  p1(1,ls(k))=w
                  w=p2(2,ls(k))
                  p2(2,ls(k))=p1(2,ls(k))
                  p1(2,ls(k))=w
                  b=next(k)
                  next(k)=prvs(k)
                  prvs(k)=b
                  l=inext(k)
                  inext(k)=iprvs(k)
                  iprvs(k)=l
                  if(.not.prvs(k)) then !{
                    k=iprvs(k)
                    go to 50
                  end if !}
                end if !}
                if(.not.free(i)) go to 100
                go to 110
              end if !}
            end if !}
 110      continue !}
        end if !}
 100  continue !}
c!###{
c
c      write(*,*) '=== Rearranged.'
c      write(*,'(2i6,3l5,2i6,1p,4e13.5)') (i,ls(i),free(i),next(i),
c     ,            prvs(i),inext(i),iprvs(i),p1(1,ls(i)),p1(2,ls(i)),
c     ,                                  p2(1,ls(i)),p2(2,ls(i)),i=1,ns)
c!###}

c*** We have got the lists now. Start tracing the chains

      k=0

c*** ic: index of the current chain
c*** ib: index of the starting point of the current chain in ind
c*** l : counter for the chain indices
c*** open: flag for a search for open chains
      
      ic=0
      ib=0
      l=0
      open=.true.
      do iii=1,2 !{

c*** First, check for the open structures - they must start from an end,
c*** and then, at the second pass, proceed with the closed structures
c!###{
c
c        write(*,*) 'iii,open= ',iii,open
c        write(*,'(6x,4a5,2a6,10x,a2,23x,a2)') 'free','next','prvs',
c     ,                                 'done','inext','iprvs','p1','p2'
c        write(*,'(i5,4l5,2i6,1p,4e13.5)') (i,free(i),next(i),prvs(i),
c     ,              done(i),inext(i),iprvs(i),p1(1,ls(i)),p1(2,ls(i)),
c     ,                                  p2(1,ls(i)),p2(2,ls(i)),i=1,ns)
c!###}

        do i=1,ns !{

c          write(*,*) '== i, = ',i,done(i),free(i),prvs(i),iprvs(i) !###

          if(done(i) .or. (.not.free(i).and.open)) cycle

c*** This is an end of a chain

          ic=ic+1
          if(ic.gt.nc) then !{
#ifdef FLUSH
            call FLUSH(6)
#endif
            write(0,*) 'chkchain: too many chains. nc= ',nc
#ifdef FLUSH
            call FLUSH(0)
#endif
            irt=-1
            goto 9999
          end if !}

          ib=l+1
          l=l+1
          k=0

c*** Follow the chain
c!###{
c          write(*,*) '   i  free next prvs inext iprvs'
c          write(*,'(i4,3l5,2i6)') (ii,free(ii),
c     ,                   prvs(ii),next(ii),iprvs(ii),inext(ii),ii=1,ns)
c!###}
          j=i
          if(prvs(i)) then !{
            do ii=1,ns !{

c              write(*,*) 'j = ',j,done(j),next(j),inext(j)

              if(done(j)) exit
              l=l+1
              ind(l)=ls(j)
              k=k+1
              done(j)=.true.
              if(next(j)) exit
              j=inext(j)
            end do !}
          else !}{
            do ii=1,ns !{
              if(done(j)) exit
              l=l+1
              ind(l)=ls(j)
              k=k+1
              done(j)=.true.
              if(prvs(j)) exit
              j=iprvs(j)
            end do !}
            i1=ib+1
            i2=ib+k
            do ii=1,k/2 !{
              j=ind(i1)
              ind(i1)=ind(i2)
              ind(i2)=j
              i1=i1+1
              i2=i2-1
            end do !}
          end if !}
          if(open) then !{
            ind(ib)=k
          else !}{
            ind(ib)=-k
          end if !}
        end do !}
        open=.false.
      end do !}
      l=0
      k=0
      do i=1,ic !{
        l=l+1
        k=k+abs(ind(l))
        l=l+abs(ind(l))
      end do !}
      if(k.ne.ns) then !{
#ifdef FLUSH
        call FLUSH(6)
#endif
        write(0,*) 'chkchain: internal error - k =/= ns ',k,ns
        write(0,*) 'ns,ls: ',ns
        write(0,'(20i5)') ls
        write(0,*) 'ic, chains: ',ic
        l=0
        do i=1,ic !{
          l=l+1
          k=abs(ind(l))
          write(0,'(20i5)') i,k
          write(0,'(20i5)') (ind(l+ii),ii=1,k)
          l=l+k
        end do !}
#ifdef FLUSH
        call FLUSH(0)
#endif
        irt=-4
        goto 9999
      end if !}
      
      irt=ic
      
c=======================================================================
 9999 call subend ()
      return
      end
