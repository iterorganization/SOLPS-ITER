      subroutine uinprpsf
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
c
c  version : 01.06.99 18:08
c
c=======================================================================
c*** Prepare the chemical sputtering data for the Eirene input file
c=======================================================================
      implicit none
#include "uinput.inc"
      integer i,j,k,l
      logical ex
      integer nlpw_hlp
      parameter (nlpw_hlp=16)
      character hlp_prj*8,hlp_wll*(nlpw_hlp),hlp_prw*(nlpw_hlp+8)
      external xerrab, subini, subend
c=======================================================================
      call subini ('uinprpsf')

      do j=1,nchsppri !{

c*** Parse the projectile-wall pairs from DG specification

        hlp_prw=chsptgt(j)
        call lefta(hlp_prw,nlpw_hlp,i)
        l=index(hlp_prw,':')
        if(l.gt.0) then !{
          ex=.true.
          hlp_prj=hlp_prw(1:l-1)
          hlp_wll=hlp_prw(l+1:nlpw_hlp+8)
          l=index(hlp_wll,':')
          if(l.gt.0) then !{
            read(hlp_wll(l+1:nlpw_hlp),'(i6)',err=10) lchspgrp(j)
            ex=.false.
 10         if(ex) then !{
              write(0,*) 'Wrong surface group specification ',chsptgt(j)
              call xerrab ('==> Check the DG model')
            end if !}
            hlp_wll=hlp_wll(1:l-1)
          else !}{
            lchspgrp(j)=0
          end if !}
        else !}{
          hlp_prj=' '
        end if !}

c*** Assign the Eirene-style projectile identifiers

        call uinspcid(hlp_prj,lchspprt(j),lchspprp(j))
        if(lchspprt(j).le.0) then !{
          write(0,*) 'Non-recognised projectile for chemical ',
     ,      'sputtering - ',chsptgt(j),' ==> reaction ignored'
          lchspprt(j)=0
        end if !}

c*** Assign the Eirene-style wall identifiers

        if(lchspprt(j).gt.0) then !{
          l=-1
          call uinmtr(hlp_wll,l,1)
          if(l.le.0) then !{
            write(0,*) 'Non-recognised wall material for chemical ',
     ,      'sputtering - ',chsptgt(j),' ==> reaction ignored'
            lchspprt(j)=0
          else !}{
            lchsptrg(j)=l
          end if !}
        end if !}

c*** Assign the Eirene-style reaction product identifiers

        call uinspcid(chspspt(j),lchsptgt(j),lchsptgp(j))
        if(lchsptgt(j).le.0) then !{
          write(0,*) 'Non-recognised reaction product for chemical ',
     ,      'sputtering - ',chspspt(j),' ==> reaction ignored'
          lchspprt(j)=0
        end if !}

      end do !}

c*** Re-arrange the data removing inconsistent items, if any

      k=0
      do j=1,nchsppri !{
        if(lchspprt(j).gt.0) k=k+1
        if(k.ne.j) then !{
          lchsptrg(k)=lchsptrg(j)
          lchspgrp(k)=lchspgrp(j)
          lchspprt(k)=lchspprt(j)
          lchspprp(k)=lchspprp(j)
          lchsptgt(k)=lchsptgt(j)
          lchsptgp(k)=lchsptgp(j)
          lchspnwl(k)=lchspnwl(j)
          ychsptg(k)=ychsptg(j)
          echsptg(k)=echsptg(j)
          fchsptg(k)=fchsptg(j)
          do i=1,5 !{
            lchspaux(i,k)=lchspaux(i,j)
          end do !}
          do i=1,3 !{
            achsptg(i,k)=achsptg(i,j)
          end do !}
        end if !}
      end do !}
      nchsppri=k
c<<<
      print *,'After uinprpsf ',nchsppri
      if(nchsppri.gt.0) print '(4x,7(2x,a3),3(5x,a3,4x))','trg','grp',
     ,                   'prt','prp','tgt','tgp','nwl','ych','ech','fch'
      do j=1,nchsppri !{
        print '(1x,i3,7i5,1x,1p,3e12.4)',j,lchsptrg(j),lchspgrp(j),
     ,    lchspprt(j),lchspprp(j),lchsptgt(j),lchsptgp(j),lchspnwl(j),
     ,    ychsptg(j),echsptg(j),fchsptg(j)
c>>>
      end do !}     
c=======================================================================
      call subend ()
      return
      end
