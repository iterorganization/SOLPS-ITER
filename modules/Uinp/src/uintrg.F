      subroutine uintrg(nam)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
c
c  version : 25.03.99 21:27
c
c======================================================================
c*** Data input from the target file
c======================================================================
      implicit none
      character*8 nam
      integer lun
      
#include "uinput.inc"

      integer nnms
      parameter (nnms=2)
      integer i
      character*8 name, unm(nnms), uline*16
      logical streql
      external streql
c*** List of the valid input keywords
      data unm /
     1    'npr     ','nptseg  '/
c======================================================================

      call locase(nam,name,8)
      do i=1,nnms
        if(streql(name,unm(i))) go to (10,20),i
      end do
      call skipit
      return

 10   call rearri(npr,nnpr,mnpr)
      return

 20   call rearri(nptseg,nnptseg,mnptseg)
      return

c======================================================================
      entry uintopo(lun)
c*** Read the topology keyword from the file header
c======================================================================

      rewind(lun)
      topo=' '
 9000 continue
      read(lun,'(a)',end=9900) uline
      if(index(uline,'#').eq.0) go to 9900
      i=index(uline,'# topo ')
      if(i.eq.0) go to 9000
      topo=uline(i+7:i+10)
 9900 rewind(lun)
      return
      
c======================================================================
      end
