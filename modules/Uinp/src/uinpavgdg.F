      subroutine uinpavgdg(lc)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use b2mod_subsys
      use eirmod_solps
#ifdef DIMENSIONS_MODULE
      use b2mod_dimensions
#endif
c  version : 16.03.2005 23:54

c=======================================================================
c*** Prepare the data for the averaged Eirene run
c=======================================================================
      implicit none
      logical lc
#include "uinput.inc"
      integer, save :: nprnli_save, nfile_save
      integer, save :: npts_save(nstra)
c=======================================================================
      call subini ('uinpavgdg')
      if(lc) then !{
       npts_save=npts
       npts=npts/100
       nprnli_save=nprnli
       nprnli=nprnli/100
       nfile_save=nfile
       nfile=30000+mod(nfile_save,10000)
      else !}{
       npts=npts_save
       nprnli=nprnli_save
       nfile=nfile_save
      end if !}
      call subend ()
      return
c=======================================================================
      end subroutine uinpavgdg
