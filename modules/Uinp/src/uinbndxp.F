      subroutine uinbndxp
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_solps
#ifdef DIMENSIONS_MODULE
      use b2mod_dimensions
#endif
      use carre_dimensions
c
c  version : 24.03.99 23:20
c
c======================================================================
c*** Fill in the data for explicitly specified zones
c=======================================================================
      implicit none
#include "uinpcom.inc"
c=======================================================================
      return
c=======================================================================
      end subroutine uinbndxp
