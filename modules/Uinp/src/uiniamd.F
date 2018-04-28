      subroutine uiniamd(unn)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx
c
c  version : 30.06.2000 19:44
c
c=======================================================================
c*** Read the data from AMDS file
c=======================================================================
      implicit none
      character unn*8
#include "uinpcom.inc"
#include "impcon.inc"
      integer lunm,luns
      parameter (lunm=26, luns=72)
      integer i,j,k,l,m,iv,nn
      save nn
      logical uex, streql
      external streql, xerrab, subini, subend
      character*8 unm(lunm),uun,s*(luns)
      data unm /
     1  '#'       ,'filevers' ,'reactns'  ,'rctype'   ,'group'    ,
     2  'deltae'  ,'massp'    ,'masst'    ,'primpart' ,'intrpart' ,
     3  'product1','product2' ,'nprdct1'  ,'nprdct2'  ,'eprdct1'  ,
     4  'eprdct2' ,'tmin'     ,'tmax'     ,'extrimx'  ,'extrimn'  ,
     5  'exparl1' ,'exparl2'  ,'exparl3'  ,'exparr1'  ,'exparr2'  ,
     6  'exparr3'/
c=======================================================================
c
      call subini ('uiniamd')
c      print *,'== ',unn,nn,nnrctn
      call locase(unn,uun,8)
      do i=1,lunm !{
        if(streql(uun,unm(i))) 
     ,           go to (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
     ,                  16,17,18,19,20,21,22,23,24,25,26),i
      end do !}
      call subend ()
      return
c=======================================================================
  1   call skipit
      call subend ()
      return
  2   immed=.true.
      call resimi(iv)
      call subend ()
      return
  3   nn=nnrctn
      call resimi(nnrctn)
      print *,uun,' : ',nnrctn
      nnrctn=nn+nnrctn
      if(nnrctn.gt.nreac) then !{
        write(0,*) 'Too many reaction datasets requested:',nnrctn
        call xerrab
     .   ('==> Check the AMDS model and DEF_NREAC in DIMENSIONS.F')
      end if !}
      nn=nn+1
      do i=nn,nnrctn !{
        read(iunii,'(a)',end=9999) s
        uex=.true.
        l=1
        k=0
        do j=1,luns !{
          if(uex) then !{
            m=index(s(l:luns),' ')
            if(m.eq.1) then !{
              l=l+1
            else !}{
              if(m.eq.0) then !{
                m=luns+1
                uex=.false.
              end if !}
              m=m-1
              k=k+1
c             print *,'k,l,m= ',k,l,m
              if(k.eq.1) then !{
                rctndbs(i)=s(l:l+m-1)
              else if(k.eq.2) then !}{
                rctnchp(i)=s(l:l+m-1)
              else if(k.eq.3) then !}{
                rctnrct(i)=s(l:l+m-1)
                uex=.false.
              else !}{
                write(0,*) 'uiniamd: error parsing the reaction list'
                call xerrab ('-- internal error in UINP')
              end if !}
              l=l+m+1
            end if !}
          end if !}
        end do !}
        if(uex) then !{
          write(0,*) 'uiniamd: wrong structure of the reaction list'
          print *,s
          call xerrab ('==> Corrupted AMDS file')
        end if !}
        print '(i3,7a)',i,':',rctndbs(i),':',rctnchp(i),':',
     ,    rctnrct(i),':'
        if (streql(rctndbs(i),'AMMONX')) ammonx_used=.true.
      end do !}
      call subend ()
      return
c-----------------------------------------------------------------------
  4   do i=nn,nnrctn !{
        read(iunii,'(a)',end=9999) rctntyp(i)
      end do !}
      go to 9990

  5   do i=nn,nnrctn !{
        read(iunii,'(i20)',err=9999,end=9999) rctngrp(i)
      end do !}
      go to 9990

  6   do i=nn,nnrctn !{
        read(iunii,'(e20.0)',err=9999,end=9999) rctndlte(i)
      end do !}
      go to 9990

  7   do i=nn,nnrctn !{
        read(iunii,'(i20)',err=9999,end=9999) rctnmsp(i)
      end do !}
      go to 9990

  8   do i=nn,nnrctn !{
        read(iunii,'(i20)',err=9999,end=9999) rctnmst(i)
      end do !}
      go to 9990

  9   do i=nn,nnrctn !{
        read(iunii,'(a)',end=9999) rctnptpr(i)
        do j = 1, nspdlen !{
          if (streql(rctnptpr(i),spcdspc(j))) then !{
            no_n2_model = no_n2_model .and. no_n2(j)
            if (.not.meta_used .and. l_meta(j)) meta_used = .true.
          end if !}
        end do !}
      end do !}
      go to 9990

 10   do i=nn,nnrctn !{
        read(iunii,'(a)',end=9999) rctnptin(i)
        do j = 1, nspdlen !{
          if (streql(rctnptin(i),spcdspc(j))) then !{
            no_n2_model = no_n2_model .and. no_n2(j)
            if (.not.meta_used .and. l_meta(j)) meta_used = .true.
          end if !}
        end do !}
      end do !}
      go to 9990

 11   do i=nn,nnrctn !{
        read(iunii,'(a)',end=9999) rctnpto1(i)
        do j = 1, nspdlen !{
          if (streql(rctnpto1(i),spcdspc(j))) then !{
            no_n2_model = no_n2_model .and. no_n2(j)
            if (.not.meta_used .and. l_meta(j)) meta_used = .true.
          end if !}
        end do !}
      end do !}
      go to 9990

 12   do i=nn,nnrctn !{
        read(iunii,'(a)',end=9999) rctnpto2(i)
        do j = 1, nspdlen !{
          if (streql(rctnpto2(i),spcdspc(j))) then !{
            no_n2_model = no_n2_model .and. no_n2(j)
            if (.not.meta_used .and. l_meta(j)) meta_used = .true.
          end if !}
        end do !}
      end do !}
      go to 9990

 13   do i=nn,nnrctn !{
        read(iunii,'(i20)',err=9999,end=9999) rctnnmo1(i)
      end do !}
      go to 9990

 14   do i=nn,nnrctn !{
        read(iunii,'(i20)',err=9999,end=9999) rctnnmo2(i)
      end do !}
      go to 9990

 15   do i=nn,nnrctn !{
        read(iunii,'(e20.0)',err=9999,end=9999) rctnenr1(i)
      end do !}
      go to 9990

 16   do i=nn,nnrctn !{
        read(iunii,'(e20.0)',err=9999,end=9999) rctnenr2(i)
      end do !}
      go to 9990

 17   do i=nn,nnrctn !{
        read(iunii,'(e20.0)',err=9999,end=9999) rctntmin(i)
      end do !}
      go to 9990

 18   do i=nn,nnrctn !{
        read(iunii,'(e20.0)',err=9999,end=9999) rctntmax(i)
      end do !}
      go to 9990

 19   do i=nn,nnrctn !{
        read(iunii,'(i20)',err=9999,end=9999) rctnimx(i)
      end do !}
      go to 9990

 20   do i=nn,nnrctn !{
        read(iunii,'(i20)',err=9999,end=9999) rctnimn(i)
      end do !}
      go to 9990

 21   do i=nn,nnrctn !{
        read(iunii,'(e20.0)',err=9999,end=9999) rctnexcf(i,1)
      end do !}
      go to 9990

 22   do i=nn,nnrctn !{
        read(iunii,'(e20.0)',err=9999,end=9999) rctnexcf(i,2)
      end do !}
      go to 9990

 23   do i=nn,nnrctn !{
        read(iunii,'(e20.0)',err=9999,end=9999) rctnexcf(i,3)
      end do !}
      go to 9990

 24   do i=nn,nnrctn !{
        read(iunii,'(e20.0)',err=9999,end=9999) rctnexcf(i,4)
      end do !}
      go to 9990

 25   do i=nn,nnrctn !{
        read(iunii,'(e20.0)',err=9999,end=9999) rctnexcf(i,5)
      end do !}
      go to 9990

 26   do i=nn,nnrctn !{
        read(iunii,'(e20.0)',err=9999,end=9999) rctnexcf(i,6)
      end do !}
      go to 9990
c=======================================================================
 9990 call skipit
      call subend ()
      return
c=======================================================================
 9999 write(0,*) 'Error encountered while reading ',uun
      call xerrab ('==> Corrupted AMDS file')
c=======================================================================
      call subend ()
      return
      end
