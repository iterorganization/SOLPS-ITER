      subroutine uinprphe
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
c
c  version : 30.06.2000 19:47
c
c=======================================================================
c*** Prepare the data for evaluation of He pumping in B2
c=======================================================================
      implicit none
#include "uinput.inc"
#include "uib2pprm.inc"
      integer i,j,k,l,n,luind(nxd),luwrk(nxd)
      logical streql
      external xerrab, streql, subini, subend
c=======================================================================
      call subini ('uinprphe')

c*** Find the species indices
      do i=1,nspigen
        if (streql(spcigen(i),'He')) j_he_at = i
        if (streql(spcigen(i),'Ne')) j_ne_at = i
        if (streql(spcigen(i),'H')) j_h_at(1) = i
        if (streql(spcigen(i),'D')) j_h_at(2) = i
        if (streql(spcigen(i),'T')) j_h_at(3) = i
      end do

      if(.not.do_hepdt) then !{
        call subend ()
        return
      end if !}

c*** Check the pump location

      if(locphep.eq.1) then !{
        write(*,*) 'Pumping from lower PFR'
      else if(locphep.eq.2) then !}{
        write(*,*) 'Pumping from outer side'
      else !}{
        write(*,*) 'No pumping specified: locphep=',locphep
        locphep=0
        call subend ()
        return
      end if !}

c*** Find the range of boundary cells where to average the gas pressure 

      do i=1,nstclhep !{
        lstclhep(i)=mod(lstclhep(i),nx+2)
      end do !}
      call sortia(lstclhep,luind,nstclhep)
      k=0
      l=-1
      do i=1,nstclhep !{
        j=luind(i)
        if(lstclhep(j).gt.l) then !{
          k=k+1
          l=lstclhep(j)
          luwrk(k)=l
        end if !}
      end do !}
      nstclhep=k
c<<<
      print *,'Gas pressure in cells: ',nstclhep
      if(nstclhep.gt.0) print '(1x,30i4)',(luwrk(i),i=1,nstclhep)
c<<<
      if(locphep.eq.1) then !{
        n=2
      else !}{
        n=1
      end if !}
      k=0
      l=-5
      do i=1,nstclhep !{
        if(luwrk(i).ne.l+1) then !{
          if(k.gt.0) luwrk(k)=luwrk(i-1)
          k=k+1
          luind(k)=luwrk(i)
        end if !}
        l=luwrk(i)
      end do !}
      if(k.gt.0) luwrk(k)=l
c<<<
      print *,'Edge ranges: ',k
      if(k.gt.0) print '(1x,30i4)',(luind(i),luwrk(i),i=1,k)
c<<<
      if(k.eq.0) then !{
        write(*,*) 'No cell range specified - the data from ',
     ,    'b2.neutrals.parameters are used'
        do i=4,7 !{
          chrpl(i,7)=' '
        end do !}
      end if !}
      if(k.gt.n) then !{
        write(0,*) 'Too many cell ranges are specified for ',
     ,    'evaluation of He pumping: ',k
        write(0,*) 'This number should be consistent with the "pump ',
     ,    'location" in DG: no more than 2 for PFR or 1 for outer side'
        write(0,*) 'STOP ==> Check the DG model - make sure that ',
     ,    'continuous cell ranges are marked'
        call xerrab ('Too many cell ranges specified')
      end if !}
      if(k.gt.0) then !{
        if(locphep.eq.1) then !{
          if((luwrk(1).gt.nxcut1(1).and.luwrk(1).le.nxcut1(nncut)) .or.
     .      (luind(1).gt.nxcut1(1).and.luind(1).le.nxcut1(nncut)) .or.
     .      (luind(k).gt.nxcut1(1).and.luind(k).le.nxcut1(nncut)) .or.
     .      (luwrk(k).gt.nxcut1(1).and.luwrk(k).le.nxcut1(nncut))) then !{
            write(0,*) 'Wrong cell range specified for PFR pumping: ',
     ,        'must not extend beyond the cuts'
            call xerrab ('==> Check the DG model')
          end if !}
          if(luwrk(1).gt.nxcut1(nncut)) then !{
            if(k.eq.1) then !{
              luwrk(2)=luwrk(1)
              luind(2)=luind(1)
              luwrk(1)=1
              luind(1)=nx
            else !}{
              write(0,*) 'Both cell ranges for evaluation of He ',
     ,          'pumping belong to the outer divertor'
              write(0,*) 'STOP ==> Check the DG model - make sure ',
     ,          'that continuous cell ranges are marked'
              call xerrab ('Both He pumping ranges in outer divertor')
            end if !}
          else !}{
            if(k.eq.2) then !{
              if(luwrk(2).le.nxcut1(1)) then !{
                write(0,*) 'Both cell ranges for evaluation of He ',
     ,            'pumping belong to the outer divertor'
                write(0,*) 'STOP ==> Check the DG model - make sure ',
     ,            'that continuous cell ranges are marked'
                call xerrab ('Both He pumping ranges in outer divertor')
              end if !}
            else !}{
              luwrk(2)=1
              luind(2)=nx
            end if !}
          end if !}
        else !}{
          luwrk(2)=luwrk(1)
          luind(2)=luind(1)
        end if !}
        lstclhep(1)=luind(1)
        lstclhep(2)=luwrk(1)
        lstclhep(3)=luind(2)
        lstclhep(4)=luwrk(2)
c<<<
        print *,'Final cell ranges: ',(lstclhep(i),i=1,4)
c>>>
      end if !}
c=======================================================================
      call subend ()
      return
      end
