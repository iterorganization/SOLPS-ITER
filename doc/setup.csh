setup.csh is used to setup
  (1) $SOLPSMASTER, a variable giving the root of the master
    distribution, usually either /afs/ipp-garching.mpg.de/u/dpc or
    /afs/pppl.gov/u/dcoster.  It can also be set to the local copy of
    the master distribution;
  (2) $NAG, the appropriate loader instruction to find NAG
  (3) $NCARG_ROOT, the root of the NCAR tree, and $NCARG, the
    appropriate loader instruction to load NCAR
  (4) $OBJECTCODE, a variable indicating the machine architecture
  (5) $nOBJECTCODE, a similar variable used by HPZ derived from
    $OBJECTCODE
  (6) the PATH variable by prepending some directories
  (7) MANPATH by adding some directories
  (8) some aliases to move around the tree (sbb, sei, etc)
  (9) some aliases for plotting (xyplot etc)
 (10) two aliases to swap between the debug and no debug versions of
    the code (set_debug and set_nodebug)

The original version of the script assumed everybody had AFS --- since
this proved not to be true various ad hoc hacks have had to be
introduced, though, over time, it is hoped that the code will become
cleaner. 

For setting up the SOLPSMASTER, OBJECTCODE, NAG and NCARG variables, an attempt is
made to source
    setup.csh.SOLPSMASTER
    setup.csh.SOLPSMASTER.local
    setup.csh.OBJECTCODE
    setup.csh.OBJECTCODE.local
    setup.csh.NAG
    setup.csh.NAG.$OBJECTCODE
    setup.csh.NAG.local
    setup.csh.NAG.local.$OBJECTCODE
    setup.csh.NCARG
    setup.csh.NCARG.$OBJECTCODE
    setup.csh.NCARG.local
    setup.csh.NCARG.local.$OBJECTCODE
in that order.  If the respective variable have not been set, they are
set to some default value.  In the master tree in Garching none of
these are supplied.
At the end of setup.csh an attempt is made tp source
    setup.csh.$OBJECTCODE
    setup.csh.local
    setup.csh.local.$OBJECTCODE
    setup.csh.$USER
    setup.csh.$USER.$OBJECTCODE
if any of these exist.
