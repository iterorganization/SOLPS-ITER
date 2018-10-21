      subroutine uimdvr(lout,jblk,jvrb,ufs)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx
c
c  version : 18.08.2003 17:31
c
c======================================================================
c*** Writes the line with modified values for the specified variable
c*** into b2.parameters file connected to the unit lout
c***
c*** Input:
c***  jblk    the block ID
c***  jvrb    the variable ID
c***  ufs     the format used to write the line (???)
c======================================================================
      implicit none
      integer lout,jblk,jvrb
      character ufs*(*)
#include "uinpcom.inc"
#include "uib2pprm.inc"
      logical ufirst
c      integer nniprm(nmxprm,nkwrd,nblck)
      integer i,j,k,l,m,n,ll,nn,len
      character ss*(mxslen),s(mxslen),us*(mxslen-mxkwln-1),
     ,  sss*(mxslen-1),ufi*24,ufc*24,ufa*20,ufg*24,s0
      character hlp_frm*30
      integer len_of_digits, lnblnk
      external len_of_digits, lnblnk
      equivalence (ss,s),(s(mxkwln+3),us),(s(2),sss)
      data ss / ' ' /
#ifdef DBG
      real r
      character c*8
#endif
c*** Flag of the first call
      data ufirst / .true. /
      save
c======================================================================
c
      if(ufirst) then !{
          write(hlp_frm,'(a,i1,a)')
     .     '(1h(,i',len_of_digits(nmxprm),',9h(i3,1h,)))'
          write(ufi,hlp_frm) nmxprm
          write(hlp_frm,'(a,i1,a)')
     .     '(4h(1p,,i',len_of_digits(nmxprm),',12h(g10.3,1h,)))'
          write(ufg,hlp_frm) nmxprm
          write(hlp_frm,'(a,i1,a)')
     .     '(2h(a,i',len_of_digits(mxkwln),',1h))'
          write(ufa,hlp_frm) mxkwln
          call lefta(ufa,16,i)
cc<<<
c         print *,'uimdvr: formats'
c         print *,'  ',ufi
c         print *,'  ',ufg
c         print *,'  ',ufa
cc>>>
          ufirst=.false.
      end if !}

      if(lbmdf(jvrb,jblk)) then !{
c*** Not the first appearance of the same keyword. Skip it.
        lbv=.false.
cc<<<
c       print *,'uimdvr: skipping ',chrpl(jvrb,jblk)
cc>>>
        return
      end if !}

      ss=' '
      m=nmdpr(jvrb,jblk)
cc<<<
c      print *,'=> uimdvr: ',chrpl(jvrb,jblk),m
cc>>>
      if(m.gt.0) then !{
c        write(sss,ufa) chrpl(jvrb,jblk)
        ll=max(1,nmdlr(jvrb,jblk))
        nn=max(1,nmdbr(jvrb,jblk))
cc<<<
c       print *,' ll,nn = ',ll,nn
cc>>>
        do n=1,nn !{
          do l=1,ll !{
            if(lprdckw(l,n,jvrb,jblk)) then !{
#ifdef DBG
c            r=0
c            i=0
c            c=' '
c            if(ltrvr(jvrb,jblk)) then !{
c              c=cniprm(1,l,n,jvrb,jblk)
c            else if(lt8rvr(jvrb,jblk)) then !}{
c              c=c8niprm(1,l,n,jvrb,jblk)
c            else if(lrrvr(jvrb,jblk)) then !}{
c              r=rniprm(1,l,n,jvrb,jblk)
c            else !}{
c              i=iniprm(1,l,n,jvrb,jblk)
c            end if !}
c            write(6,'(a,4i4,1x,l1,a,a,i4,e12.5)')
c     ,        'l,n,jvrb,jblk,lprdckw:parm(1) = ',
c     ,         l,n,jvrb,jblk,lprdckw(l,n,jvrb,jblk),' : ',c,i,r !###
#endif
              sss=chrpl(jvrb,jblk)
              if(nmdlr(jvrb,jblk).gt.0) then !{
                if(lspvr(jvrb,jblk)) then !{
                  s0='0'
                else !}{
                  s0='1'
                end if !}
                if(nmdbr(jvrb,jblk).gt.0) then !{
                  write(us,'(a1,a1,a1,i3,a1,i1,a1)')  
     .                     '(',s0,',',l,',',n,')'
                else !}{
                  write(us,'(a1,a1,a1,i3,a1)') '(',s0,',',l,')'
                end if !}
              end if !}
              call lefta(sss,mxslen,j)
              s(j+2)='='
              k=j+3
              if(ltrvr(jvrb,jblk)) then !{
                write(ufc,700) '(',nmdpr(jvrb,jblk)
  700           format(a1,i3,15h(2h ',a1,2h',)))
                write(ss(k:mxslen),ufc) (cniprm(i,l,n,jvrb,jblk),i=1,m)
              else if(lt8rvr(jvrb,jblk)) then !}{
                write(ufc,710) '(',nmdpr(jvrb,jblk)
  710           format(a1,i3,17h(1x,1h',a8,2h',)))
                do i=1,m
                  len=lnblnk(c8niprm(i,l,n,jvrb,jblk))
                  if (len.lt.8) then
                    c8niprm(i,l,n,jvrb,jblk)(len+1:8)=repeat(' ',8-len)
                  endif
                enddo
                write(ss(k:mxslen),ufc) (c8niprm(i,l,n,jvrb,jblk),i=1,m)
              else if(lrrvr(jvrb,jblk)) then !}{
                write(ss(k:mxslen),ufg) (rniprm(i,l,n,jvrb,jblk),i=1,m)
              else !}{
                write(ss(k:mxslen),ufi) (iniprm(i,l,n,jvrb,jblk),i=1,m)
              end if !}
              call uisswr(lout,s,ss,mxslen,ufs)
            end if !}
          end do !}
        end do            !}
      end if !}
      lbmdf(jvrb,jblk)=.true.
c
c*** Check whether the whole block is over
c
      lbb=.true.
      do i=1,nkwrd !{
        lbb = lbb .and. (lbmdf(i,jblk) .or. chrpl(i,jblk).eq.' ')
      end do !}
c
      lbv=.false.
c======================================================================
      end
