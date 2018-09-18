      subroutine uinspcid(s,l,k)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx
c
c  version : 26.05.99 20:38
c
c======================================================================
c*** Prepare the reaction data.
c***  Input:  s is the particle identifier
c***  Output: l the particle kind (0-e, 1-a, 2-m, 3-i, 4-p; <0 - err)
c***          k the species index
c======================================================================
      implicit none
      integer l,k
      character*(*) s
#include "uinpcom.inc"
      integer i
      logical streql
      external streql
c======================================================================

      if(s.eq.' ' .or. s.eq.'e') then
c*** Electron
        l=0
        k=0
        return
      end if

      do i=1,nspcatm
        if(streql(s,spcsatm(i))) go to 10
      end do

      do i=1,nspcmol
        if(streql(s,spcsmol(i))) go to 20
      end do

      do i=1,nspcion
        if(streql(s,spcsion(i))) go to 30
      end do

      do i=1,nspcpls
        if(streql(s,spcspls(i))) go to 40
      end do
      l=-1
      k=0
      return
c-----------------------------------------------------------------------
c*** Atom
 10   l=1
      k=i
      return

c*** Molecule
 20   l=2
      k=i
      return

c*** Test ion
 30   l=3
      k=i
      return

c*** Plasma ion
 40   l=4
      k=i
      return

c======================================================================
      end

