      subroutine uinptridg(lc)

c  version : 16.03.2005 23:54

c=======================================================================
c*** Prepare the data for the TRIA Eirene run
c=======================================================================
      logical lc
#include "uinput.inc"
      integer,save :: ntcpu_save, nfile_save, nprnli_save
      integer,save :: npts_save(nstra)
c=======================================================================
      if(lc) then 
c       call uinptriang(lc)
       if(.not.lc) return 
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
       nlwrmsh=.false.
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
       nlwrmsh=.true.
       nltrimesh=.false.
      end if !}
c=======================================================================
      end
