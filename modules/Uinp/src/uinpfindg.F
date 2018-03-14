      subroutine uinpfindg(lc)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx

c  version : 16.03.2005 23:54

c=======================================================================
c*** Prepare the data for the final stage of Eirene averaging
c=======================================================================
      implicit none
      logical lc
#include "uinput.inc"
      integer, save :: nprnli_save, ntcpu_save, nfile_save
      integer, save :: npts_save(nstra)
      external subini, subend
c=======================================================================
      call subini ('uinpfindg')
      if(lc) then !{
       ntcpu_save=ntcpu
       ntcpu=ntcpu*10
       npts_save=npts
       npts=npts*10
       nprnli_save=nprnli
       nprnli=nprnli*10
       nfile_save=nfile
       nfile=30000+mod(nfile_save,10000)
      else !}{
       ntcpu=ntcpu_save
       npts=npts_save
       nprnli=nprnli_save
       nfile=nfile_save
      end if !}
      call subend ()
      return
c=======================================================================
      end
