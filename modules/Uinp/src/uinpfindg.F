      subroutine uinpfindg(lc)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use b2mod_subsys
      use eirmod_solps

c  version : 16.03.2005 23:54

c=======================================================================
c*** Prepare the data for the final stage of Eirene averaging
c=======================================================================
      implicit none
      logical lc
#include "uinput.inc"
      integer, save :: ntcpu_save, nfile_save, nprmul_save
      integer, save :: npts_save(nstra)
      integer :: jk
c=======================================================================
      call subini ('uinpfindg')
      if(lc) then !{
       ntcpu_save=ntcpu
       ntcpu=ntcpu*10
       npts_save=npts
       npts(:)=min(npts(:)*10,999999)
       nprmul_save=nprmul
       nprmul=max(1,nprmul)*10
       nfile_save=nfile
       jk=nfile/1000
       nfile=jk*1000+800+mod(nfile_save,100)
       nfile=30000+mod(nfile,10000)
      else !}{
       ntcpu=ntcpu_save
       npts=npts_save
       nprmul=nprmul_save
       nfile=nfile_save
      end if !}
      call subend ()
      return
c=======================================================================
      end subroutine uinpfindg
