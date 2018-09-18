      subroutine uib2pl
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
c
c  version : 14.04.97 19:05
c
c=====================================================
c*** Produces additional files specifying geometry for b2plot
c*** At present, only mesh.extra is created - provided that
c*** corresponding data has been specified in dg.
c***
c*** Input:
c***  nmvsle  the list of elements to be included in mesh.extra
c***  nnvsle  the length of this list
c***          (specified through dg and input by uinnam)
c=====================================================
#include "uinput.inc"
c=====================================================
c
      if(nnvsle.gt.0) then
        open(1,file='mesh.extra',err=10)
        do i=1,nnvsle
          j=nmvsle(i)
          write(1,*) 0.01*p1(1,j),0.01*p1(2,j),
     ,                                        0.01*p2(1,j),0.01*p2(2,j)
        end do
        close(1)
        print *,'    ... mesh.extra created'
      end if
 10   continue
c=====================================================
      end
