      subroutine uinbndrg
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx
c
c  version : 15.03.2001 00:57
c
c=======================================================================
c*** Determine the gross boundary regions
c=======================================================================
      implicit none
#include "uinpcom.inc"
      integer i,j,k,l,nt_hlp
      logical ex
      parameter (nt_hlp=5)
      character*4 topo_hlp(nt_hlp)
      external xerrab
c*** List of topologies valid for this routine
      data topo_hlp / 'DNL','DNS','DNU','SNL','SNU' /
c*** Boundary kinds: 1-core, 2-target, 3-PFR side, 4-outer side
c=======================================================================
      call subini ('uinbndrg')
c*** Check the topology
      ex=.false.
      do i=1,nt_hlp !{
        ex= ex .or. topo.eq.topo_hlp(i)
      end do !}
      if(.not.ex) then !{
        write(0,*) 'Invalid topology name ( ',topo,') found in ',
     ,        'uinbndrg - must be one of: ',(' ',topo_hlp(i),i=1,nt_hlp)
        call xerrab ('==> Check the topology name in the DG model')
      end if !}
      if(lm_cnfg) then  !{
c*** Core
        crgbndt(1,1)='S'
        lrsbndt(1,1)=0
        lrpbndt(1,1,1)=1
        lrpbndt(1,1,2)=nx
        lrrbndt(1,1,1)=0
        lrrbndt(1,1,2)=nrpfl
c*** Target 1
        crgbndt(1,2)='W'
        lrsbndt(1,2)=0
        lrpbndt(1,2,1)=0
        lrpbndt(1,2,2)=nx/2
        lrrbndt(1,2,1)=nrpfl+1
        lrrbndt(1,2,2)=irwl
c*** Target 2
        crgbndt(2,2)='E'
        lrsbndt(2,2)=nx+1
        lrpbndt(2,2,1)=nx/2
        lrpbndt(2,2,2)=nx+1
        lrrbndt(2,2,1)=nrpfl+1
        lrrbndt(2,2,2)=irwl
c*** Wall
        crgbndt(1,4)='N'
        lrsbndt(1,4)=irwl
        lrpbndt(1,4,1)=1
        lrpbndt(1,4,2)=nx
        lrrbndt(1,4,1)=nrpfl+1
        lrrbndt(1,4,2)=irwl

        ntrgdflt=2
        nrgbndt(1)=1
        nrgbndt(2)=2
        nrgbndt(3)=0
        nrgbndt(4)=1

      else !}{
c*** Target 1
        crgbndt(1,2)='W'
        lrsbndt(1,2)=0
        lrpbndt(1,2,1)=0
        k=nzidv
        lrpbndt(1,2,2)=k
        lrrbndt(1,2,1)=0
        lrrbndt(1,2,2)=irwl
c*** PFR 1
        crgbndt(1,3)='S'
        lrsbndt(1,3)=0
        lrpbndt(1,3,1)=0
        lrpbndt(1,3,2)=k
        lrrbndt(1,3,1)=0
        lrrbndt(1,3,2)=nrpfl
c*** Core 1
        crgbndt(1,1)='S'
        lrsbndt(1,1)=0
        lrpbndt(1,1,1)=k+1
        k=k+nzinn
        lrpbndt(1,1,2)=k
        lrrbndt(1,1,1)=0
        lrrbndt(1,1,2)=nrpfl
c*** Target 2
        crgbndt(2,2)='E'
        j=k+1
        lrpbndt(2,2,1)=j
        k=k+nzodv+1
        lrpbndt(2,2,2)=k
        lrsbndt(2,2)=k
        lrrbndt(2,2,1)=0
        lrrbndt(2,2,2)=irwl
c*** PFR 2
        crgbndt(2,3)='S'
        lrsbndt(2,3)=0
        lrpbndt(2,3,1)=j
        lrpbndt(2,3,2)=k
        lrrbndt(2,3,1)=0
        lrrbndt(2,3,2)=nrpfl+nrsol1
c*** Wall 1
        crgbndt(1,4)='N'
        lrsbndt(1,4)=irwl
        lrpbndt(1,4,1)=0
        lrpbndt(1,4,2)=k
        lrrbndt(1,4,1)=nrpfl+nrsol1+1
        lrrbndt(1,4,2)=irwl

        ex=.false.
        if(index(topo,'DN').gt.0) then  !{

          ntrgdflt=4
          nrgbndt(1)=2
          nrgbndt(2)=4
          nrgbndt(3)=4
          nrgbndt(4)=2
          lcmbndt(2,3)=3
          lcmbndt(3,3)=2
          lcmbndt(1,4)=2
          lcmbndt(2,4)=1
c*** Target 3
          crgbndt(3,2)='W'
          k=k+1
          l=k
          j=l
          lrpbndt(3,2,1)=k
          lrsbndt(3,2)=k
          k=k+nzidv2
          lrpbndt(3,2,2)=k
          lrrbndt(3,2,1)=0
          lrrbndt(3,2,2)=irwl
c*** PFR 3
          crgbndt(3,3)='S'
          lrsbndt(3,3)=0
          lrpbndt(3,3,1)=j
          lrpbndt(3,3,2)=k
          lrrbndt(3,3,1)=0
          lrrbndt(3,3,2)=nrpfl+nrsol1
c*** Core 2
          crgbndt(2,1)='S'
          lrsbndt(2,1)=0
          lrpbndt(2,1,1)=k+1
          k=k+nzinn2
          lrpbndt(2,1,2)=k
          lrrbndt(2,1,1)=0
          lrrbndt(2,1,2)=nrpfl
c*** Target 4
          crgbndt(4,2)='E'
          j=k+1
          lrpbndt(4,2,1)=j
          k=k+nzodv2+1
          lrpbndt(4,2,2)=k
          lrsbndt(4,2)=k
          lrrbndt(4,2,1)=0
          lrrbndt(4,2,2)=irwl
c*** PFR 4
          crgbndt(4,3)='S'
          lrsbndt(4,3)=0
          lrpbndt(4,3,1)=j
          lrpbndt(4,3,2)=k
          lrrbndt(4,3,1)=0
          lrrbndt(4,3,2)=nrpfl
c*** Wall 2
          crgbndt(2,4)='N'
          lrsbndt(2,4)=irwl
          lrpbndt(2,4,1)=l
          lrpbndt(2,4,2)=k
          lrrbndt(2,4,1)=nrpfl+nrsol1+1
          lrrbndt(2,4,2)=irwl

          if(topo.eq.'DNU') then        !{
            lrrbndt(1,3,2)=nrpfl
            lrrbndt(2,3,2)=nrpfl+nrsol1
            lrrbndt(3,3,2)=nrpfl
            lrrbndt(4,3,2)=nrpfl+nrsol1
          end if        !}

        else if(index(topo,'SN').gt.0) then !}{

          ntrgdflt=2
          nrgbndt(1)=1
          nrgbndt(2)=2
          nrgbndt(3)=2
          nrgbndt(4)=1
        end if  !}
      end if  !}
c!###{
      print *,'Boundary regions: ',nrgbndt
      print *
      print *,'knd reg    pos loc_pol loc_rad cmb'
      do k=1,nbndknd !{
        if (nrgbndt(k).eq.0) cycle
        print *
        do j=1,nrgbndt(k) !{
          print '(2i4,1x,a1,1x,6i4)',k,j,crgbndt(j,k),lrsbndt(j,k),
     ,      lrpbndt(j,k,1),lrpbndt(j,k,2),lrrbndt(j,k,1),lrrbndt(j,k,2),
     ,      lcmbndt(j,k)
        end do !}
      end do !}
      print *
c!###}
c=======================================================================
      call subend ()
      return
      end
