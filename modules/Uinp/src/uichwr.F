      subroutine uichwr(lun,ic,mm,n)
c
c  version : 02.07.98 15:40
c
c======================================================================
c*** write "CH-cards" in the unit lun.
c***  ic  is the card identifier (0 to 3),
c***  mm  is the array containing the corresponding element numbers.
c***      the valid elements of mm must be sorted in ascending order
c***      and followed by 0 if there are less than n of them.
c======================================================================
      integer mm(*)
      character uss*68,uhd*4,utr*16
      logical udbg
c======================================================================
c<<<
c      if(mm(1).gt.0) print *,'uichwr: start. n=',n
#ifdef DBG
       udbg=.true.
#else
       udbg=.false.
#endif
      do i=1,n
        if(udbg) print *,mm(i)
        udbg = udbg .and. mm(i).gt.0
      end do
c>>>
      write(uhd,'(2hCH,i1)') ic
      uss=' '
c
      k=0
      mb=0
      do 100 i=1,n
        m=mm(i)
        if(m.eq.0) go to 10
        if(mb.eq.0) then
          mb=m
          me=m
          if(i.ne.n) go to 100
        else if(m.eq.me+1) then
          me=m
          if(i.ne.n) go to 100
        end if
 10     if(mb.ne.0) then
          write(utr,'(i4,1h/,i4)') mb,me
          mb=m
          me=m
          call lefta(utr,16,j)
          j=j+1
          kk=k+j
          if(kk.ge.68) then
            write(lun,'(a4,a68)') uhd,uss
            uss=' '
            k=0
            kk=k+j
          end if
          uss(k+1:kk+1)=utr(1:j)
          k=kk
        end if
        if((i.eq.n .or. m.eq.0) .and. k.ne.0)
     -                                    write(lun,'(a4,a68)') uhd,uss
        if(m.eq.0) return
 100  continue
c======================================================================
      end
