      subroutine ubpnam(unn)
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
      do i=1,lunm
        if(streql(uun,unm(i))) go to (1,2,3,4,5,6,7,8,9,10,11,12),i
      end do
      call skipit
      return
c======================================================================
c*** p1
  1   call rearre(pp1,3*DEF_NLIM,i)
      call vscale(pp1,0.001,pp1,i)
      nlimi=i/3
c      print *,'p1: nlimi = ',nlimi !###
      if(nlimi.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',nlimi
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      return
c*** p2
  2   call rearre(pp2,3*nlim,i)
      call vscale(pp2,0.001,pp2,i)
      nlimi=i/3
c      print *,'p2: nlimi = ',nlimi !###
      if(nlimi.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',nlimi
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      return
c*** vessel
  3   call rearri(nmvsle,nlim,nnvsle)
c      print *,'vessel: nnvsle = ',nnvsle !###
      if(maxval(nmvsle).gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',
     .   maxval(nmvsle)
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      return
c*** data_id
  4   call resima(uuc)
      if(uuc.eq.'lin_int') then
        luchrs=1
      else if(uuc.eq.'lin_prf') then
        luchrs=2
      else
        write (*,*) 'Unrecognisable chords switch: ',uuc
        luchrs=0
      end if
c      print *,'data_id : luchrs = ',luchrs !###
      return
c*** chords
  5   call rearre(ubchrds,4*nubchrdx,nubchrd)
      nubchrd=nubchrd/4
c      print *,'chords : nubchrd = ',nubchrd !###
      do j=1,nubchrd
        do i=1,4
          ubchrds(i,j)=0.001*ubchrds(i,j)
        end do
      end do
      return
c*** chr_lbl
  6   continue
c      print *,'chr_lbl : luchrs = ',luchrs !###
      if(luchrs.eq.1) then
        call rearri(lublbli,nubchrdx,i)
      else if(luchrs.eq.2) then
        call rearri(lublblp,nubchrdx,i)
      else
        call skipit
      end if
c      print *,'chr_lbl : i = ',i !###
      return
c*** linintg
  7   call resimi(luind)
      luchrs=1
      print *,'linintg : luchrs, luind = ',luchrs, luind !###
      return
c*** linprfs
  8   call resimi(luind)
      luchrs=2
      print *,'linprfs : luchrs, luind = ',luchrs, luind !###
      return
c*** set_id
  9   continue
c      print *,'set_id  : luchrs, luind = ',luchrs, luind !###
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
      return
c*** set_list
 10   continue
c      print *,'set_list: luchrs, luind = ',luchrs, luind !###
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
      return
c*** n_points
 11   continue
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
      return
c*** chr_angl
 12   continue
c      print *,'chr_angl : luchrs = ',luchrs !###
      if(luchrs.eq.1) then
        call rearre(angchrdi,nubchrdx,i)
      else if(luchrs.eq.2) then
        call rearre(angchrdp,nubchrdx,i)
      else
        call skipit
      end if
c      print *,'chr_angl : i = ',i !###
      return
c======================================================================
      end
