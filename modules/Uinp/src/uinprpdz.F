      subroutine uinprpdz(lmrk,nmrk,kmrk)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx

c  version : 24.01.2003 17:55

c=======================================================================
c*** Find correspondence of the specified marker cells to boundary zones
c***
c*** Input:
c***  lmrk  array of markers (cell centers in DG numeration)
c***  nmrk: abs(nmrk) is the number of these markers, and the sign
c***        determines the boundary kind (<0 - target)
c*** 
c*** Output:
c***  lmrk  boundary zone indices
c***  kmrk  corresponding boundary kinds
c***  nmrk  number of marked boundary zones
c=======================================================================
      implicit none
      integer nmrk,lmrk(*),kmrk(*)
#include "uinpcom.inc"
      integer i,j,k,l,m,n,ir,iz,it,l_pfr,l_wll
      logical ex,hlp_trg
      integer mesh_cell_ind
      external mesh_cell_ind

c*** Here we use the data on grid cell numbers between the separatrices
c*** and grid edges (nrpfl, nrsol1 - see uinprpgr for detail),
c*** together with the data on the boundary zone assignment (lzrbndt)
c*** All are counted in B2 cells, not in Eirene surfaces
c=======================================================================
c*** Ranges for the markers pointing to either a PFR edge (ir.le.l_pfr)
c*** either a wall edge (ir.gt.l_wll)

      l_pfr=nrpfl
      l_wll=nrpfl+nrsol1
      if(lm_cnfg) l_pfr=-1
      n=abs(nmrk)
      hlp_trg=nmrk.lt.0
c      print *,'uinprpdz: hlp_trg,nmrk,n=',hlp_trg,nmrk,n  !###
      k=0
      do l=1,n !{
        if(mesh_cell_ind(lmrk(l),ir,iz).eq.0) then !{
          m=0
          it=0
          if(hlp_trg) then !{
            m=2
            if(iz.lt.izc1) then !{
              it=1
            else if(iz.lt.iztg .and. iz.ge.izc2) then !}{
              it=nrgbndt(2)
            else if(iz.lt.izci .and. iz.ge.izc3) then !}{
              it=2
            else if(iz.lt.izc4 .and. iz.ge.izci+1) then !}{
              it=3
            end if !}
            if(lm_cnfg .and. ir.le.l_pfr) m=0
c            print *,'target zone: ir,iz,it,m =',ir,iz,it,m  !###
          else !}{
            if(ir.le.l_pfr) m=3
            if(ir.gt.l_wll) m=4
          end if !}
c          print *,'uinprpdz: l,lmrk(l),ir,iz,m,it,k=',             !###
c     ,                                     l,lmrk(l),ir,iz,m,it,k  !###
          if(m.gt.2) then !{
            do j=1,nznbndt(m) !{
              if(iz.ge.lzrbndt(j,m,1) .and. iz.le.lzrbndt(j,m,2)) then!{
                ex=.false.
                do i=1,k !{
                  ex=ex .or. (m.eq.kmrk(i) .and. j.eq.lmrk(i))
                end do !}
                if(.not.ex) then !{
                  k=k+1
                  kmrk(k)=m
                  lmrk(k)=j
                end if !}
              end if !}
            end do !}
          else if(m.eq.2) then !}{
            do j=1,nznbndt(m) !{
              if(it.eq.lrfbndt(j,m) .and. ir.ge.lzrbndt(j,m,1) .and.
     .                                      ir.le.lzrbndt(j,m,2)) then!{
                ex=.false.
                do i=1,k !{
                  ex=ex .or. (m.eq.kmrk(i) .and. j.eq.lmrk(i))
                end do !}
                if(.not.ex) then !{
                  k=k+1
                  kmrk(k)=m
                  lmrk(k)=j
                end if !}
              end if !}
            end do !}
          end if !}
        end if !}
      end do !}
      nmrk=k
c=======================================================================
      end
