      subroutine uinprpnd
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
c
c  version : 14.03.2001 17:11
c
c=======================================================================
c*** Prepare the data for the cuts for the Eirene input file
c=======================================================================
      implicit none
#include "uinput.inc"
      integer i,k
      external xerrab, subini, subend
c=======================================================================
      RETURN !VK 

      call subini ('uinprpnd')
      k=nstsi

      if(lm_cnfg) then  !{
      
c*** 2 cuts for a limiter

        if(k+2.ge.nsts) then !{
          write(0,*) 'Too many "non-default surfaces" are specified',
     ,                                  '  (cuts).'
          write(0,*) '  ==> Check the boundary specification in ',
     ,                  'DG and parameter DEF_NSTS in DIMENSIONS.F'
          call xerrab ('Too many "non-default surfaces"')
        end if !}

        k=k+1
        inump(k)=1
        irpte1(k)=irsp
        ilequi(k)=iztg
        ilcol(k)=3

        k=k+1
        inump(k)=iztg
        irpte1(k)=irsp
        ilequi(k)=1
        ilcol(k)=3

      else if(index(topo,'SN').gt.0) then  !}{
      
c*** 2*2*2 cuts for a single null

        if(k+8.ge.nsts) then !{
          write(0,*) 'Too many "non-default surfaces" are specified.',
     ,                                  '  (cuts)'
          write(0,*) 'STOP ==> Check the boundary specification in ',
     ,                'DG and parameter DEF_NSTS in DIMENSIONS.F'
          call xerrab ('Too many "non-default surfaces"')
        end if !}

c***  inner left cut, private flux

        k=k+1
        inump(k)=izc1-1
        irpte1(k)=irsp
        ilequi(k)=izc1
        ilcol(k)=3

c***  inner right cut, central flux

        k=k+1
        inump(k)=izc1
        irpte1(k)=irsp
        ilequi(k)=izc2
        ilcol(k)=3

c***  11: outer right cut, private flux

        k=k+1
        inump(k)=izc2+1
        irpte1(k)=irsp
        ilequi(k)=izc1-1
        ilcol(k)=3

c***  12: outer left cut, central flux

        k=k+1
        inump(k)=izc2
        irpte1(k)=irsp
        ilequi(k)=izc2+1
        ilcol(k)=3

c***  13: inner left cut, SOL

        k=k+1
        inump(k)=izc1-1
        irpta1(k)=irsp
        irpte1(k)=irwl
        ilequi(k)=izc1
        ilcol(k)=3

c***  14: inner right cut, SOL

        k=k+1
        inump(k)=izc1
        irpta1(k)=irsp
        irpte1(k)=irwl
        ilequi(k)=izc2
        ilcol(k)=3

c***  15: outer right cut, SOL

        k=k+1
        inump(k)=izc2+1
        irpta1(k)=irsp
        irpte1(k)=irwl
        ilequi(k)=izc1-1
        ilcol(k)=3

c***  16: outer left cut, SOL

        k=k+1
        inump(k)=izc2
        irpta1(k)=irsp
        irpte1(k)=irwl
        ilequi(k)=izc2+1
        ilcol(k)=3

      else if(index(topo,'DN').gt.0) then !}{
      
c*** 4*2*2 cuts for a double-null

        if(k+16.ge.nsts) then !{
          write(0,*) 'Too many "non-default surfaces" are specified.',
     ,                                  '  (cuts)'
          write(0,*) 'STOP ==> Check the boundary specification in ',
     ,                   'DG and parameter DEF_NSTS in DIMENSIONS.F'
          call xerrab ('Too many "non-default surfaces"')
        end if !}

c***  11: lower left cut, PFR

        k=k+1
        inump(k)=izc1-1
        irpte1(k)=irsp
        ilequi(k)=izc1
        ilcol(k)=3

c***  12: lower left cut, core

        k=k+1
        inump(k)=izc1
        irpte1(k)=irsp
        ilequi(k)=izc2
        ilcol(k)=3

c***  13: lower right cut, PFR

        k=k+1
        inump(k)=izc2
        irpte1(k)=irsp
        ilequi(k)=izc2+1
        ilcol(k)=3

c***  14: lower right cut, core

        k=k+1
        inump(k)=izc2+1
        irpte1(k)=irsp
        ilequi(k)=izc1-1
        ilcol(k)=3

c***  15: lower left cut, SOL

        k=k+1
        inump(k)=izc1-1
        irpta1(k)=irsp
        irpte1(k)=irwl
        ilequi(k)=izc1
        ilcol(k)=3

c***  16: lower left cut, SOL

        k=k+1
        inump(k)=izc1
        irpta1(k)=irsp
        irpte1(k)=irwl
        ilequi(k)=izc2
        ilcol(k)=3

c***  17: lower right cut, SOL

        k=k+1
        inump(k)=izc2
        irpta1(k)=irsp
        irpte1(k)=irwl
        ilequi(k)=izc2+1
        ilcol(k)=3

c***  18: lower right cut, SOL

        k=k+1
        inump(k)=izc2+1
        irpta1(k)=irsp
        irpte1(k)=irwl
        ilequi(k)=izc1-1
        ilcol(k)=3

c***  19: upper left cut, PFR

        k=k+1
        inump(k)=izc3
        irpte1(k)=irsp2
        ilequi(k)=izc3+1
        ilcol(k)=3

c***  20: upper left cut, PFR

        k=k+1
        inump(k)=izc3+1
        irpte1(k)=irsp2
        ilequi(k)=izc4-1
        ilcol(k)=3

c***  21: upper left cut, PFR

        k=k+1
        inump(k)=izc4-1
        irpte1(k)=irsp2
        ilequi(k)=izc4
        ilcol(k)=3

c***  22: upper left cut, PFR

        k=k+1
        inump(k)=izc4
        irpte1(k)=irsp2
        ilequi(k)=izc3
        ilcol(k)=3

c***  23: upper left cut, SOL

        k=k+1
        inump(k)=izc3
        irpta1(k)=irsp2
        irpte1(k)=irwl
        ilequi(k)=izc3+1
        ilcol(k)=3

c***  24: upper left cut, SOL

        k=k+1
        inump(k)=izc3+1
        irpta1(k)=irsp2
        irpte1(k)=irwl
        ilequi(k)=izc4-1
        ilcol(k)=3

c***  25: upper left cut, SOL

        k=k+1
        inump(k)=izc4-1
        irpta1(k)=irsp2
        irpte1(k)=irwl
        ilequi(k)=izc4
        ilcol(k)=3

c***  26: upper left cut, SOL

        k=k+1
        inump(k)=izc4
        irpta1(k)=irsp2
        irpte1(k)=irwl
        ilequi(k)=izc3
        ilcol(k)=3

      end if  ! }

      do i=1,k-nstsi !{
        write(txtsfl(nstsi+i),'(a10,i4)') 'Cut',i
      end do !}

      nstsi=k

c=======================================================================
      call subend ()
      return
      end
