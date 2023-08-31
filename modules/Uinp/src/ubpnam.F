      subroutine ubpnam(unn)
#ifdef DIMENSIONS_MODULE
      use b2mod_dimensions
#endif
c
c  version : 17.11.2003 17:38
c
c======================================================================
c*** Data input from the DG file
c======================================================================
#include "ubpcom.h"
      integer lunm
      parameter (lunm=12)
      character*8 unm(lunm),unn,uun,uuc*(ufnlen)
c*** luchrs: chord type switch.
c***          1   line integrals
c***          2   line profiles
c***
      integer i,j,luchrs
      logical streql
      external streql
      data luchrs / 0 /
      data unm /
     1    'p1      ','p2      ','vessel  ','data_id ','chords  ',
     2    'chr_lbl ','linintg ','linprfs ','set_id  ','set_list',
     3    'n_points','chr_angl'/
c======================================================================
c
c      print *,'ubpnam : ',unn !###
      call locase(unn,uun,8)
      i = 0
      do i=1,lunm
        if(streql(uun,unm(i))) exit
      end do
c======================================================================
      select case (i)
      case (1)
c*** p1
        call rearre(pp1,3*DEF_NLIM,i)
        call vscale(pp1,0.001,pp1,i)
        nlimi=i/3
c       print *,'p1: nlimi = ',nlimi !###
        if(nlimi.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',nlimi
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (2)
c*** p2
        call rearre(pp2,3*nlim,i)
        call vscale(pp2,0.001,pp2,i)
        nlimi=i/3
c       print *,'p2: nlimi = ',nlimi !###
        if(nlimi.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',nlimi
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (3)
c*** vessel
        call rearri(nmvsle,nlim,nnvsle)
c       print *,'vessel: nnvsle = ',nnvsle !###
        if(maxval(nmvsle).gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',
     .     maxval(nmvsle)
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (4)
c*** data_id
        call resima(uuc)
        if(uuc.eq.'lin_int') then
          luchrs=1
        else if(uuc.eq.'lin_prf') then
          luchrs=2
        else
          write (*,*) 'Unrecognisable chords switch: ',uuc
          luchrs=0
        end if
c       print *,'data_id : luchrs = ',luchrs !###
      case (5)
c*** chords
        call rearre(ubchrds,4*nubchrdx,nubchrd)
        nubchrd=nubchrd/4
c       print *,'chords : nubchrd = ',nubchrd !###
        do j=1,nubchrd
          do i=1,4
            ubchrds(i,j)=0.001*ubchrds(i,j)
          end do
        end do
      case (6)
c*** chr_lbl
c       print *,'chr_lbl : luchrs = ',luchrs !###
        if(luchrs.eq.1) then
          call rearri(lublbli,nubchrdx,i)
        else if(luchrs.eq.2) then
          call rearri(lublblp,nubchrdx,i)
        else
          call skipit
        end if
c       print *,'chr_lbl : i = ',i !###
      case (7)
c*** linintg
        call resimi(luind)
        luchrs=1
        print *,'linintg : luchrs, luind = ',luchrs, luind !###
      case (8)
c*** linprfs
        call resimi(luind)
        luchrs=2
        print *,'linprfs : luchrs, luind = ',luchrs, luind !###
      case (9)
c*** set_id
c       print *,'set_id  : luchrs, luind = ',luchrs, luind !###
        if(luchrs.eq.1) then
          if(luind.gt.0 .and. luind.le.nubsli) then
            call resima(cublbli(luind))
          else
            write(*,*) 'ubpnam *9 : luind, nubsli = ', luind, nubsli
            if(luind.gt.0) then
              write(*,*) '==> Check nubsli in ubpcom.h'
            end if
            call skipit
          end if
        else if(luchrs.eq.2) then
          if(luind.gt.0 .and. luind.le.nubslp) then
            call resima(cublblp(luind))
          else
            write(*,*) 'ubpnam *9 : luind, nubslp = ', luind, nubslp
            if(luind.gt.0) then
              write(*,*) '==> Check nubslp in ubpcom.h'
            end if
            call skipit
          end if
        else
          call skipit
        end if
      case (10)
c*** set_list
c       print *,'set_list: luchrs, luind = ',luchrs, luind !###
        if(luchrs.eq.1) then
          if(luind.gt.0 .and. luind.le.nubsli) then
            call rearri(lubchrdi(1,luind),nubchrdx,nubchrdi(luind))
          else
            write(*,*) 'ubpnam *10: luind, nubsli = ', luind, nubsli
            if(luind.gt.0) then
              write(*,*) '==> Check nubsli in ubpcom.h'
            end if
            call skipit
          end if
        else if(luchrs.eq.2) then
          if(luind.gt.0 .and. luind.le.nubslp) then
            call rearri(lubchrdp(1,luind),nubchrdx,nubchrdp(luind))
          else
            write(*,*) 'ubpnam *10: luind, nubslp = ', luind, nubslp
            if(luind.gt.0) then
              write(*,*) '==> Check nubslp in ubpcom.h'
            end if
            call skipit
          end if
        else
          call skipit
        end if
      case (11)
c*** n_points
        print *,'n_points: luchrs, luind = ',luchrs, luind !###
        if(luchrs.eq.2) then
          if(luind.gt.0 .and. luind.le.nubslp) then
            call resimi(nubnpnt(luind))
          else
            write(*,*) 'ubpnam *11: luind, nubslp = ', luind, nubslp
            if(luind.gt.0) then
              write(*,*) '==> Check nubslp in ubpcom.h'
            end if
            call skipit
          end if
        else
          if(luind.gt.0 .and. luind.le.nubsli) then
            call resimi(nubnpni(luind))
          else
            write(*,*) 'ubpnam *11: luind, nubsli = ', luind, nubsli
            if(luind.gt.0) then
              write(*,*) '==> Check nubsli in ubpcom.h'
            end if
            call skipit
          end if
        end if
      case (12)
c*** chr_angl
c       print *,'chr_angl : luchrs = ',luchrs !###
        if(luchrs.eq.1) then
          call rearre(angchrdi,nubchrdx,i)
        else if(luchrs.eq.2) then
          call rearre(angchrdp,nubchrdx,i)
        else
          call skipit
        end if
c       print *,'chr_angl : i = ',i !###
      case default
        call skipit
      end select
      return
c======================================================================
      end subroutine ubpnam
