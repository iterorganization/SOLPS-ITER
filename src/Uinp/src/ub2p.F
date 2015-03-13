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
#include "impcon.inc"
      logical uex
      external ubpnam
c======================================================================
c*** set up the input routine
c
      immed=.false.
      keylen=8
      mimp=iunii
      lena=ufnlen
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
      end
