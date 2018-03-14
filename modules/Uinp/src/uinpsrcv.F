      subroutine uinpsrcv
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
c
c  version : 13.02.2005 20:02
c
c=======================================================================
c*** Prepare the recombination strata. If no data was specified through
c*** DG, then assume the default strata - unless the corresponding flag
c*** was set in DG
c=======================================================================
      implicit none
#include "uinput.inc"
      integer i,k,l,n,ka,ipl,ipt,irc,krc,nrc,istr,irce(nstra)
      character*12 hlp_frm
      logical ex,l_hlp,hlp_err
      external xerrab, xertst, subini, subend
      data irce / nstra*0 /
c=======================================================================
      call subini ('uinpsrcv')
c<<<
      print *,'uinpsrcv: nrcmstr,srcvdflt,nrcln=',nrcmstr,srcvdflt,nrcln
c>>>
c*** Find the recombination reactions

      nrc=0
      do i=1,nrcln !{
        if(crc(i).eq.'RC' .and. (h123(i).eq.'H.4' .or.
     .                                      h123(i).eq.'H.2')) then !{
          nrc=nrc+1
          irce(nrc)=ir(i)
        end if !}
      end do !}
c*** Now  nrc is the number of recombination reactions
c***      irce is a list of their reference numbers in Eirene

      if(nrc.eq.1) then
        write(*,*) nrc,' recombination reaction found'
      else
        write(*,*) nrc,' recombination reactions found'
      endif
      if(nrc.gt.0) then
        write(hlp_frm,'(a,i2,a)') '(1x,a,',nrc,'i5)'
        write(*,hlp_frm) 'reactions (Eir): ',(irce(i),i=1,nrc)
      end if

      hlp_err=.true.
      if(nrcmstr.le.0 .and. srcvdflt .and. nrc.gt.0) then !{

c*** Default recombination strata, different error handling
        hlp_err=.false.
        nrcmstr=natmi
        do i=1,natmi !{
          crcmstrs(i)=texta(i)
        end do !}
      end if !}

      if(nrcmstr.gt.0) then !{
c*** Recombination strata are requested

        n=0
        if(nrc.eq.0) then !{
          write(0,*) 'No recombination reactions found in the input ',
     ,      'data, but recombination strata are requested'
          call xerrab ('==> Check the DG and AMDS models')
        end if !}

        ex=.false.
        do istr=1,nrcmstr !{
          l_hlp=.true.

c*** Check the recombined particle kind - must be an atom
          call uinspcid(crcmstrs(istr),l,ipt)
          if(l.ne.1) then !{
            write(0,*) 'Wrong specification of recombined particle: ',
     ,                  crcmstrs(istr)
            write(0,*) ' - must be an atom present in the model. ',
     ,                                                    'istr =',istr
            write(0,*) '  ==> Check "Recombination" in the DG model'
            ex=.true.
          end if !}
          ka=100*ipt+11

c*** Find the corresponding reaction(s)

          do irc=1,nrc !{
            krc=irce(irc)
            do ipl=1,nplsi !{
              do k=1,nrcp(ipl) !{
                if(ireacp(ipl,k).eq.krc .and.
     .                            (iscd1p(ipl,k).eq.ka .or.
     .                             iscd1p(ipl,k).eq.ka)) then !{
                  nstrai=nstrai+1
                  indsrc(nstrai)=-1
                  if(nstrai.ge.nstra) then !{
                    write(0,*) 'Too many strata requested: ',nstrai
                    write(0,*) 'STOP ==> check the DG model and the ',
     ,                         'value of DEF_NSTRA in DIMENSIONS.F'
                    call xerrab ('Too many strata requested')
                  end if !}
                  n=n+1
                  l_hlp=.false.
                  npts(nstrai)=nrcmstrs(n)
                  ninitl(nstrai)=ircmstrs(n)
                  nspez(nstrai)=ipl
                  lsrcmstr(spcsrnp(ipl),n)=spcsrnp(ipl)
                  nlsrf(nstrai)=.false.
                  nlvol(nstrai)=.true.
                  indim(1,nstrai)=0
                  insor(1,nstrai)=0
                  ingrda(1,nstrai,1)=lrcmrb(n)
                  if(lrcmre(n).lt.0) lrcmre(n)=irwl
                  ingrde(1,nstrai,1)=lrcmre(n)
                  ingrda(1,nstrai,2)=lrcmpb(n)
                  if(lrcmpe(n).lt.0) lrcmpe(n)=iztg
                  ingrde(1,nstrai,2)=lrcmpe(n)
                  nrsor(1,nstrai)=0
                  sorind(1,nstrai)=irc
                  sorifl(1,nstrai)=0
                  sormax(nstrai)=0
                  sorcos(nstrai)=0
                  txtsou(nstrai)='Volumetric recombination '//texta(ipt)
                  write(*,*) 'Added volumetric recombination stratum ',
     ,                        nstrai,' : ',textp(ipl),'--> ',texta(ipt)
                end if !}
              end do !}
            end do !}
          end do !}
          if(l_hlp .and. hlp_err) then !{
            write(0,*) 'No recombination data found for ',crcmstrs(istr)
            write(0,*) '  ==> Check the DG and AMDS models'
            ex=.true.
          end if !}
        end do !}
        nrcmstr=n

        call xertst (.not.ex,
     .   'Errors detected in recombination specification')
      end if !}
c======================================================================
      call subend ()
      return
      end
