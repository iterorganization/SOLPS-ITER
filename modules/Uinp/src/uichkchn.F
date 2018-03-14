      subroutine uichkchn(indelm,nni,nnx,indnss,nno,label)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx

c  version : 31.03.2005 20:05

c=======================================================================
c*** Check the element set specified to limit a triangular mesh.
c*** The set is supposed to consist either of a single closed polygon,
c*** or of several open chains. In the latter case, the set is 
c*** complemented with "non-default standard surfaces" (NSS) to form
c*** a closed polygon.
c*** 
c*** Input:
c***  indelm  : list of the elements in the chain (DG numbering)
c***  nni     : its length
c***  nnx     : maximum number of NSS
c***            to be added to the chain
c***  label   : chain label (used here for diagnostic output only)
c*** Output:
c***  indnss  : list of NSS making the chain closed
c***  nno     : its length. 0 - the original chain is closed,
c***            -1 - no chain specified (nni =<0)
c***            -2 - original chain contains "elements not for Eirene"
c***                 or invalid references 
c***            -3 - original chain is broken
c***            -4 - original chain is not ending at "target edges"
c***            -5 - original chain ends at inconsistent "target edges"
c***            -6 - NSS do not close the chain
c***          -100 - unexpected error
c***        < -100 - not enough space for NSS (needed nnx >= 100-nno) 
c=======================================================================

      implicit none
      integer nni,nnx,nno,label,indelm(max(nni,1)),indnss(max(nnx,1))

#include "uinput.inc"

      integer i,j,k,l,m,n,i1,i2,j1,j2,jj,k1,k2,irt,ntg,
     ,  ind(max(nni,1)+ntrgts),
     ,  ltge(2*ntrgts),mtge(2*ntrgts),mtgb(2*ntrgts),
     ,  kbnd(nnptseg),lbnd(nnptseg)
      integer ip,iz1,iz2,ik,loff(nbndknd),nz,lz(nnptseg)
      logical er,ex,lw(iztg,2)
      external subini,subend,xerrab
c*** mtge(i): target edge connected to the target edge i 
      data mtge / 7, 4, 5, 2, 3, 8, 1, 6 /
      data mtgb / 1, 2, 3, 2, 4, 5, 6, 5 /
      data kbnd / 3, 4, 3, 3, 4, 3 /  ! kind of boundary (PFR vs. SOL)
      data lbnd / 6, 0, 4, 3, 0, 1 /  ! adjacent zone
c=======================================================================
      call subini ('uichkchn')
!###{
      print *
      print *,'Starting uichkchn: label,nni,nnx= ',label,nni,nnx
      print *,'indelm:'
      print '(20i5)',(indelm(i),i=1,nni)
      print *
!###}
      ntg=ntrgte

c*** Check some dimensions

      nno=-100
      if(nni.le.0) then !{
        nno=-1
#ifdef FLUSH
        call FLUSH(6)
#endif
        write(0,*) 'uichkchn: no chain specified. nni= ',nni
#ifdef FLUSH
        call FLUSH(0)
#endif
        goto 9999
      end if !}
      
c-----------------------------------------------------------------------
c*** Check whether the specified chain consists of valid elements

      do i=1,nni !{
        j=indelm(i)
        if(j.le.0 .or. j.gt.nlim) then !{
#ifdef FLUSH
          call FLUSH(6)
#endif
          write(0,*) 'uichkchn: invalid index in the chain list ',i,j
#ifdef FLUSH
          call FLUSH(0)
#endif
          nno=-2
          goto 9999
        end if !}
        if(indasrfe(j).le.0 .or. indasrfe(j).gt.nlimi) then !{
#ifdef FLUSH
          call FLUSH(6)
#endif
          write(0,*) 'uichkchn: excluded segment in the chain ',
     ,                                                   i,j,indasrfe(j)
#ifdef FLUSH
          call FLUSH(0)
#endif
          nno=-2
          goto 9999
        end if !}
      end do !}

c*** Order the chain and check it for continuity

      call chkchain(p1,p2,3,nlim,indelm,nni,ntrgte,ind,irt,
     .              jedgep,jedgec,jedge,ntrgte/2)
      if(irt.le.0) then !{
#ifdef FLUSH
        call FLUSH(6)
#endif
        write(0,*) 'uichkchn: unexpected error ',
     ,                                       'in a call to chkchain',irt
#ifdef FLUSH
        call FLUSH(0)
#endif
        nno=-100
        goto 9999
      end if !}

c*** ind is now organised in sections corresponding to the found chains.
c*** The absolute value of the first element of a section gives the
c*** length of the chain, negative if the chain is closed.

c*** Check whether the chain is closed - no multiple chains then!!!

      l=0
      k=0
      do i=1,irt !{
        l=l+1
        j=ind(l)
        if(i.gt.1 .and. (k.lt.0 .or. j.lt.0)) then !{
c*** Closed polygon in a multiple chain - error!
#ifdef FLUSH
          call FLUSH(6)
#endif
          write(0,*) 'uichkchn: a closed polygon in a multiple chain'
          write(0,*) 'The same label cannot appear in multiple chains ',
     ,      'if one of the chains is closed.'
          nno=-3
          go to 900
        else if(k.eq.0) then !}{
          k=j
        end if !}
        l=l+abs(j)
      end do !}
      if(k.lt.0) then !{
c*** The chain is closed
        nno=0
        goto 9999
      else if(k.eq.0) then !}{
#ifdef FLUSH
        call FLUSH(6)
#endif
        write(0,*) 'uichkchn: unexpected error in parsing the chains ',
     ,    ' - k=0'
#ifdef FLUSH
        call FLUSH(0)
#endif
        nno=-100
        goto 9999
      end if !}

c*** Check whether all the chains end with "target edges"
c*** and prepare the "connection table"

      nno=0
      er=.false.
      ltge=0
      l=0
      do j=1,irt !{
        l=l+1
        n=abs(ind(l))
        k1=ind(l+1)
        k2=ind(l+n)
        if(k1.le.0 .or. k1.gt.nlim .or. k2.le.0 .or. k2.gt.nlim) then !{
#ifdef FLUSH
          call FLUSH(6)
#endif
          write(0,*) 'uichkchn: unexpected error - end index ',
     ,             'outside the DG range after chkchain.'
          write(0,'(a,5i5)') 'label,j,nlim,k1,k2= ',label,j,nlim,k1,k2
#ifdef FLUSH
          call FLUSH(0)
#endif
          er=.true.
          cycle
        end if !}
        i1=indasrfe(k1)
        i2=indasrfe(k2)
        if(i1.le.0 .or. i1.gt.nlimi .or.
     .                      i2.le.0 .or. i2.gt.nlimi) then !{
#ifdef FLUSH
          call FLUSH(6)
#endif
          write(0,*) 'uichkchn: unexpected error - end index ',
     ,                   'outside the Eirene range after chkchain.'
          write(0,'(a,5i5)') 'label,j,nlim,i1,i2= ',label,j,nlim,i1,i2
#ifdef FLUSH
          call FLUSH(0)
#endif
          er=.true.
          cycle
        end if !}
        j1=0
        j2=0
        do i=1,ntg !{
          if(i1.eq.jedge(2,i)) j1=i
          if(i2.eq.jedge(2,i)) j2=i
        end do !}
        if(j1.eq.0 .or. j2.eq.0) then !{
#ifdef FLUSH
          call FLUSH(6)
#endif
          write(0,*) 
     .     'uichkchn: the chain does not end at the target edges.'
          write(0,'(a,4i5)') 'label,j,j1,j2= ',label,j,j1,j2
#ifdef FLUSH
          call FLUSH(0)
#endif
          nno=-4
          er=.true.
          cycle
        end if !}
        ltge(j1)=1
        ltge(j2)=1
        l=l+n
      end do !}
      if(er) then !{
        if(nno.ge.0) nno=-100
        go to 900
      end if !}

c*** Check the consistency of the target edges. 
c***
c***                                      3   5
c***                                     /     \
c***              B                     /       \
c***              _                    / \ C  D/ \
c***             / \                  4   \   /   6
c***            /   \                      \ /
c***           /     \                      X
c***          |       |                    / \
c***          |       |                   /   \
c***           \     /                   /     \
c***            \   /                   |       |
c***             \ /                  B |       | E
c***              X                      \     /
c***             / \                      \   /
c***        2   /   \   4                  \ /
c***         \ /     \ /                    X
c***          \ A  C  /                    / \
c***           \     /                2   /   \   8
c***            1   3                  \ /     \ /
c***                                    \ A  F  /
c***                                     \     /
c***                                      1   7

      mtge(1)=ntg-1
      mtge(3)=ntg-3
      mtgb(3)=mnptseg
!###{
      print '(1x,a,(12i5))','ntg = ',ntg
      print '(1x,a,(12i5))','mtge= ',mtge
      print '(1x,a,(12i5))','mtgb= ',mtgb
      print '(1x,a,(12i5))','ltge= ',ltge
!###}
      ip=0
      ik=0
      iz1=0
      iz2=0
      nz=0
      lz=0
      do k=1,ntg !{
        if(ltge(k).eq.1) then !{
          m=mtge(k)
          if(ltge(m).eq.0) then !{
#ifdef FLUSH
            call FLUSH(6)
#endif
            write(0,*) 'uichkchn: inconsistent grid edge specification.'
            write(0,*) 'Both ends of a segment of the grid edge must ',
     ,        'have the same label.'
            write(0,*) 'label,k,m,ltge( 1 :',ntg,')= ',
     ,                                      label,k,m,(ltge(i),i=1,ntg)
#ifdef FLUSH
            call FLUSH(0)
#endif
            nno=-5
            er=.true.
            cycle
          else !}{
            ltge(m)=2
            n=max(m,k)
            nz=nz+1
            lz(nz)=mtgb(n)
          end if !}
        end if !}
      end do !}
      print '(a8,i4/(8x,20i4))','nz,lz: ',nz,(lz(i),i=1,nz)  !###
      if(er) then !{
        if(nno.ge.0) nno=-100
        go to 900
      end if !}

c*** Finally, produce the NSS list

      ex=.true.
      lw=.false.
      loff(1)=0
      do i=2,nbndknd !{
        loff(i)=loff(i-1)+nznbndt(i-1)
      end do !}
      nno=0
      lbnd(1)=mnptseg
      lbnd(3)=mnptseg-2
      do k=1,nz !{
        l=lz(k)
        do jj=1,2 !{
          if(l.eq.0) cycle
          ik=kbnd(l)
          if(l.eq.mnptseg) then !{
            ik=3
            iz1=izc2+1
            iz2=iztg
          else if(l.eq.5) then !}{
            ik=4
            iz1=izci+3
            iz2=iztg
          else if(l.eq.4) then !}{
            ik=3
            iz1=izci+3
            iz2=izc4-1
          else if(l.eq.3) then !}{
            ik=3
            iz1=izc3+1
            iz2=izci
          else if(l.eq.2) then !}{
            ik=4
            iz1=1
            iz2=iztg
            if(izci.gt.0) iz2=izci
          else if(l.eq.1) then !}{
            ik=3
            iz1=1
            iz2=izc1-1
          else !}{
#ifdef FLUSH
            call FLUSH(6)
#endif
            write(0,*) 'uichkchn: unexpected error with edge zones.'
            write(0,*) 'label,k,l,nz,lz(1:',nz,')= ',label,k,l,
     ,                                                nz,(lz(i),i=1,nz)
            go to 900
          end if !}
c          print *,'l,ik,iz1,iz2=',l,ik,iz1,iz2  !###
          ip=1
          if(ik.eq.4) ip=irwl
cvk       print *,'ik,ip,nznbndt(ik) ',ik,ip,nznbndt(ik)
cvk       if(nznbndt(ik).gt.0) then !{
cvk         print '(a,20i6)','jcpbnds ',(jcpbnds(j,ik),j=1,nznbndt(ik))
cvk         print '(a,20i6)','jc1bnds ',(jc1bnds(j,ik),j=1,nznbndt(ik))
cvk         print '(a,20i6)','jc2bnds ',(jc2bnds(j,ik),j=1,nznbndt(ik))
cvk       end if !}
          do j=1,nznbndt(ik) !{
            if(jcpbnds(j,ik).eq.ip) then !{
              i1=max(jc1bnds(j,ik),iz1)
              i2=min(jc2bnds(j,ik),iz2)
c!###{
c              print '(a,7i4)',
c     ,                     'j,i1,i2,iz1,iz2,jc1bnds,jc2bnds=',
c     ,                      j,i1,i2,iz1,iz2,jc1bnds(j,ik),jc2bnds(j,ik)
c!###}
              if(i2.gt.i1) then !{
                nno=nno+1
                if(nno.le.nnx) indnss(nno)=loff(ik)+j
                do i=i1,i2-1 !{
                  lw(i,ik-2)=.true.
                end do !}
              end if !}
            end if !}
          end do !}
          do i=iz1,iz2-1 !{
            ex=ex.and.lw(i,ik-2)
          end do !}
          l=lbnd(l)
        end do !}
      end do !}

      if(nno.gt.nnx) then !{
#ifdef FLUSH
        call FLUSH(6)
#endif
        write(0,*) 'uichkchn: too many non-default standard surfaces ',
     ,                           'required to close the chain  '
        write(0,*) 'label,nno,nnx= ',label,nno,nnx
        write(0,*) ' ==> Check the DG model or increase the DEF_NSTS ',
     ,                 'parameter in $SOLPSTOP/src/include/DIMENSIONS.F'
#ifdef FLUSH
        call FLUSH(0)
#endif
        nno=-100-nno
        goto 9999
      end if !}

      if(.not.ex) then !{
#ifdef FLUSH
        call FLUSH(6)
#endif
        write(0,*) 'uichkchn: non-default standard surfaces do not ',
     ,                                                 'close the chain'
        write(0,*) 'label,nno=',label,nno
        write(0,*) 'indnss:'
        write(0,'(1x,20i4)') (indnss(i),i=1,nno)
        write(0,*) 'lw:'
        write(0,'((12(1x,5l1)))') (lw(i,1),i=1,iztg)
        write(0,*)
        write(0,'((12(1x,5l1)))') (lw(i,2),i=1,iztg)
#ifdef FLUSH
        call FLUSH(0)
#endif
        nno=-6
        goto 9999
      end if !}
      goto 9999
c=======================================================================
c*** Error in the segment chains
 900  continue
#ifdef FLUSH
      call FLUSH(6)
#endif
      write(0,*) 'label,irt= ',label,irt
      l=0
      do m=1,irt !{
        l=l+1
        j=abs(ind(l))
        write(0,'(1x,i5)') ind(l)
        write(0,'(1x,20i5)') (ind(l+k),k=1,j)
      end do !}
      write(0,*) '  ==> Check the "Index" specification in ',
     ,                        '"TRIA-EIRENE parameters" in DG variables'
      write(0,*) 
     . 'The targets must be numbered according to the B2 convention:'
      write(0,*) 
     . 'going clockwise and starting from the bottom left corner.'
#ifdef FLUSH
      call FLUSH(0)
#endif
 9999 call subend()
      return
c=======================================================================
      end
