      program ub2p
      use b2mod_types
      use b2mod_impcon
      use b2mod_xerset
#ifdef DIMENSIONS_MODULE
      use b2mod_dimensions
#endif
      implicit none
c======================================================================
c*** Creates the additional input files for b2plot, provided that the
c*** corresponding data is present in the dg output files.
c***
c*** The files are:
c***
c***  mesh.extra        data for "vesl" option
c***  <set_id>.<label>  lines for "chvl" option
c***  <set_id>.chr      chords files
c***
c*** The DG "dgo" file must be linked (or copied) to "param.dg"
c======================================================================
c  version : 25.08.97 15:04
c
#include "ubpcom.h"
      external prgini,prgend,ubpnam
c======================================================================
c*** set up the input routine
      call prgini('ub2p')
      call xerset(0)
c
      immed=.false.
      keylen=8
      mimp=iunii
      lena=ufnlen
      jmess=2
      lfin=72
      finish = 'finish'
      promp(1) = repeat(' ',8)
      promp(2) = repeat(' ',8)
      fixkey=.false.
c
c*** Read the data from DG output
c
      open(iunii,file='param.dg')
      call import(ubpnam)
c
c*** Create additional files for b2plot
c
      call ubpb2pl
c======================================================================
      call prgend ()
      stop 'ub2p'
      end program ub2p
