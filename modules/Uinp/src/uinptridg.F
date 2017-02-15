      subroutine uinptridg(lc)
       use b2mod_layer
     , , only: ntrack, nalloys
       use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx

c  version : 16.03.2005 23:54

c=======================================================================
c*** Prepare the data for the TRIA Eirene run
c=======================================================================
      logical lc
#include "uinput.inc"
      integer,save :: ntcpu_save, nfile_save, nprnli_save
      integer,save :: npts_save(nstra)
      external subini, subend
c=======================================================================
      call subini ('uinptridg')
      if(lc) then 
c       call uinptriang(lc)
       if(.not.lc) goto 9999
c       do i=1,nstsi
c       ilplg(i)=ilplgu(i)      
c       end do
c       do i=1,nlim
c        jlplg(i)=jlplgu(i)
c       end do
       ntcpu_save=ntcpu
       ntcpu=10
       nfile_save=nfile
       nfile=0
       nltrimesh=.true.
       npts_save=npts
       npts=0
       nprnli_save=nprnli
       nprnli=0
      else !}{
c       do i=1,nstsi
c       ilplg(i)=0      
c       end do
c       do i=1,nlim
c        jlplg(i)=0
c       end do 
       ntcpu=ntcpu_save
       nfile=nfile_save
       npts=npts_save
       nprnli=nprnli_save
       nltrimesh=.false.
      end if !}
 9999 call subend ()
      return
c=======================================================================
      end
