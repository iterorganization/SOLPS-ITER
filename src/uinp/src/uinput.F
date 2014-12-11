      program uinput

c  version : 28.01.2003 18:08

c=======================================================================
#include "uinput.inc"
#include "impcon.inc"
      integer irt
      logical uex
      external uinnam,uintrg,uinaux
c=======================================================================
c*** Read the input data from various files
      call uininp
c*** Prepare the constants
      call uinprp

c*** Produce the input file for Eirene

      call uinout('input.eir')
      print *,'    ... input.eir created'

c*** Produce the input file for Eirene test run

      call uinprptt(.true.)
      call uinout('test.eir')
      call uinprptt(.false.)
      print *,'    ... test.eir created'

c*** Produce the input file for Eirene diagnostics run

      uex=.true.
      call uinprpdg(uex)
      if(uex) then !{
        call uinout('diag2.eir')
        call uinprpdg(.false.)
        print *,'    ... diag2.eir created'
      end if !}

c*** Produce the input file for Eirene for TRIA mesh generation
#ifdef TRIANG
      uex=.true.
      call uinptridg(uex)
      if(uex) then
       call uinout('triang.eir')
       print *,'    ... triang.eir created'
       call triaout('triang.hed')
       call uinptridg(.FALSE.)
      end if 
#else
      print *,'    ... Code compiled without TRIANG option:'//
     .               ' no triang.eir file created'
#endif
c-----------------------------------------------------------------------
c*** Modify the input file for B2, if possible

      inquire(file='b2.neutrals.parameters', exist=uex)
      if(uex) then
          open(1,file='b2.neutrals.parameters',status='old',err=22)
          open(2,file='b2.neutrals.parameters.2',err=20)
          call uicrb2(1,2,irt)
          if(irt.eq.0) then
            print *,'    ... b2.neutrals.parameters.2 created'
          else
            print *, 
     .       '    Error while creating b2.neutrals.parameters.2: ',irt
          end if
      end if
      close(2,err=22)
   20 close(1,err=22)
   22 continue
c-----------------------------------------------------------------------
c*** Create additional files with geometry for b2plot
      
      call uib2pl
c=======================================================================
      end
