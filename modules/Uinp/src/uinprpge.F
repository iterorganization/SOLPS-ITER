      subroutine uinprpge
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
c
c  version : 03.04.2003 17:25
c
c=======================================================================
c*** Determine the material properties of the grid edges for Eirene
c***
c*** Input:
c***  nwllmrk   number of material templates as specified
c***  lwllmrk   list of these templates (that is, "additional surfaces")
c***  nedgmrk   number of grid edge markers specified for each template
c***  ledgmrk   list of these markers (i.e., grid cells)
c***  ledgdfl   reference to the default specification
c***
c*** Output:
c***  bbliin    flag "insert material data" for each non-def. surface
c***  material specification for the side grid edges:
c***    jrfbnds, jcsbnds, jpsbnds, jppbnds, jcgbnds, wlmbnds,
c***    eewbnds, etfbnds, etbbnds, efcbnds, easbnds, efpbnds
c=======================================================================
      implicit none
#include "uinput.inc"
      integer i,j,k,l,m,knd_hlp(nedgmrkd,nwllmrkd)
      external xerrab, subini, subend
c=======================================================================
      call subini ('uinprpge')

      write(*,*) 'Grid edge material markers:'
      write(*,*) '          nwllmrk=',nwllmrk

      if(nwllmrk.le.0) then !{
        call subend ()
        return   ! no material templates specified
      end if !}

      write(*,*) '          nedgmrk=',(nedgmrk(l),l=1,nwllmrk)
      write(*,*) '          ntrgmrk=',(ntrgmrk(l),l=1,nwllmrk)

c*** Check the default specification

      ledgdfl=0
      do l=1,nwllmrk !{
        if(nedgmrk(l).eq.0 .and. ntrgmrk(l).eq.0) then !{
          if(ledgdfl.le.0) then !{
            ledgdfl=l
          else !}{
            write(0,*) 'Multiple definition of default material of ',
     ,        'the grid edge (side_spc)',l
            call xerrab ('  ==> Check the DG model')
          end if !}
        end if !}
      end do !}
c      print *,'ledgdfl=',ledgdfl  !###

      do l=1,nwllmrk !{
c        print *,'l,nedgmrk(l)=',l,nedgmrk(l)  !###
        if(nedgmrk(l).le.0 .and. ntrgmrk(l).le.0) then !{
          if(ledgdfl.ne.l) then !{
            write(0,*) 'uinprpge: inconsistent default ',
     ,         'specification. nwllmrk,l,ledgdfl,nedgmrk(l) =',
     ,                                     nwllmrk,l,ledgdfl,nedgmrk(l)
            call xerrab ('==> Internal error in uinp?')
          end if !}
        end if !}

c*** Determine the boundary zones where the markers point to.
c*** First, the side edges

        if(nedgmrk(l).gt.0) then !{
#ifdef DBG
  !###{ 
          print *,'before uinprpdz. nedgmrk(l)=',nedgmrk(l)
          if(nedgmrk(l).gt.0) then !{
            print *,'ledgmrk:'
            print *,(ledgmrk(i,l),i=1,nedgmrk(l))
          end if !}
  !###}
#endif 
          call uinprpdz(ledgmrk(1,l),nedgmrk(l),knd_hlp(1,l))
#ifdef DBG
  !###{ 
          print *,'after uinprpdz. nedgmrk(l)=',nedgmrk(l)
          if(nedgmrk(l).gt.0) then !{
            print *,'ledgmrk:'
            print *,(ledgmrk(i,l),i=1,nedgmrk(l))
            print *,'knd_hlp:'
            print *,(knd_hlp(i,l),i=1,nedgmrk(l))
          end if !}
  !###} 
#endif 
          if(nedgmrk(l).le.0) then !{
            write(0,*) 'uinprpge: error in grid edge markers - no ',
     ,        'zone specified. nwllmrk,l =',nwllmrk,l
            write(0,*) '==> Check the DG model - markers must be ',
     /                   'outside the corresponding separatrix branches'
            call xerrab ('No grid edge zone markers specified')
          end if !}
          do k=1,l-1 !{
            do j=1,nedgmrk(l) !{
              do i=1,nedgmrk(k) !{
                if(ledgmrk(j,l).eq.ledgmrk(i,k) .and. 
     .                             knd_hlp(j,l).eq.knd_hlp(i,k)) then !{
                  write(0,*) 'uinprpge: multiple specification of ',
     ,              'boundary zone ',knd_hlp(j,l),ledgmrk(j,l),
     ,              ' for templates ',k,' and ',l
                  call xerrab ('==> Check the DG model')
                end if !}
              end do !}
            end do !}
          end do !}
          m=lwllmrk(l)
          do i=1,nedgmrk(l) !{
            j=ledgmrk(i,l)
            k=knd_hlp(i,l)
            bbliin(j,k)=.true.
            jrfbnds(j,k)=jlref(m)
            jcsbnds(j,k)=jlsptc(m)
            jpsbnds(j,k)=jlsptp(m)
            jppbnds(j,k)=jsrss(m)
            jcgbnds(j,k)=jsrsg(m)
            wlmbnds(j,k)=xmlma(m)
            eewbnds(j,k)=ewala(m)
            etfbnds(j,k)=trnspa(m,1)
            etbbnds(j,k)=trnspa(m,2)
            efcbnds(j,k)=rcycca(m)
            easbnds(j,k)=1-rcycta(m)
            efpbnds(j,k)=rcycsa(m)
          end do !}
        end if !}

c*** Then, the targets

        if(ntrgmrk(l).gt.0) then !{
#ifdef DBG
  !###{ 
          print *,'before uinprpdz. ntrgmrk(l)=',ntrgmrk(l)
          if(ntrgmrk(l).gt.0) then !{
            print *,'ltrgmrk:'
            print *,(ltrgmrk(i,l),i=1,ntrgmrk(l))
          end if !}
  !###}
#endif 
          ntrgmrk(l)=-abs(ntrgmrk(l))
          call uinprpdz(ltrgmrk(1,l),ntrgmrk(l),knd_hlp(1,l))
#ifdef DBG
  !###{ 
          print *,'after uinprpdz. ntrgmrk(l)=',ntrgmrk(l)
          if(ntrgmrk(l).gt.0) then !{
            print *,'ltrgmrk:'
            print *,(ltrgmrk(i,l),i=1,ntrgmrk(l))
            print *,'knd_hlp:'
            print *,(knd_hlp(i,l),i=1,ntrgmrk(l))
          end if !}
  !###}
#endif 
          if(ntrgmrk(l).le.0) then !{
            write(0,*) 'uinprpge: error in target markers - no ',
     ,        'zone specified. nwllmrk,l =',nwllmrk,l
            write(0,*) '==> Check the DG model - markers must be ',
     /                   'inside the corresponding divertor volumes'
            call xerrab ('No zone specified for target markers')
          end if !}
          do k=1,l-1 !{
            do j=1,ntrgmrk(l) !{
              do i=1,ntrgmrk(k) !{
                if(ltrgmrk(j,l).eq.ltrgmrk(i,k) .and. 
     .                             knd_hlp(j,l).eq.knd_hlp(i,k)) then !{
                  write(0,*) 'uinprpge: multiple specification of ',
     ,              'target zone ',knd_hlp(j,l),ltrgmrk(j,l),
     ,              ' for templates ',k,' and ',l
                  call xerrab ('==> Check the DG model')
                end if !}
              end do !}
            end do !}
          end do !}
          m=lwllmrk(l)
          do i=1,ntrgmrk(l) !{
            j=ltrgmrk(i,l)
            k=knd_hlp(i,l)
            bbliin(j,k)=.true.
            jrfbnds(j,k)=jlref(m)
            jcsbnds(j,k)=jlsptc(m)
            jpsbnds(j,k)=jlsptp(m)
            jppbnds(j,k)=jsrss(m)
            jcgbnds(j,k)=jsrsg(m)
            wlmbnds(j,k)=xmlma(m)
            eewbnds(j,k)=ewala(m)
            etfbnds(j,k)=trnspa(m,1)
            etbbnds(j,k)=trnspa(m,2)
            efcbnds(j,k)=rcycca(m)
            easbnds(j,k)=1-rcycta(m)
            efpbnds(j,k)=rcycsa(m)
          end do !}
        end if !}
      end do !}

      if(ledgdfl.gt.0) then !{
c*** Set the default values
        m=lwllmrk(ledgdfl)
c        print *,'uinprpge: defaults. m=',m  !###
        do k=3,4 !{
          do j=1,nznbndt(k) !{
c            print *,'j,k,bbliin(j,k)=',j,k,bbliin(j,k)  !###
            if(.not.bbliin(j,k)) then !{
              bbliin(j,k)=.true.
              jrfbnds(j,k)=jlref(m)
              jcsbnds(j,k)=jlsptc(m)
              jpsbnds(j,k)=jlsptp(m)
              jppbnds(j,k)=jsrss(m)
              jcgbnds(j,k)=jsrsg(m)
              wlmbnds(j,k)=xmlma(m)
              eewbnds(j,k)=ewala(m)
              etfbnds(j,k)=trnspa(m,1)
              etbbnds(j,k)=trnspa(m,2)
              efcbnds(j,k)=rcycca(m)
              easbnds(j,k)=1-rcycta(m)
              efpbnds(j,k)=rcycsa(m)
            end if !}
          end do !}
        end do !}
      end if !}
c=======================================================================
      call subend ()
      return
      end
