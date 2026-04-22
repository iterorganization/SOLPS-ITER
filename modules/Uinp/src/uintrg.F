      subroutine uintrg(nam)
      use uinput_mod
c
c  version : 25.03.99 21:27
c
c======================================================================
c*** Data input from the target file
c======================================================================
      implicit none
      character*8 nam
      integer nnms
      parameter (nnms=2)
      integer i
      character*8 name, unm(nnms)
      logical streql
      external streql
c*** List of the valid input keywords
      data unm /
     1    'npr     ','nptseg  '/
c======================================================================

      call locase(nam,name,8)
      do i=1,nnms
        if(streql(name,unm(i))) exit
      end do

      select case (i)
      case (1)
        call rearri(npr,nnpr,mnpr)
      case (2)
        call rearri(nptseg,nnptseg,mnptseg)
      case default
        call skipit
      end select
      return
      end subroutine uintrg

c======================================================================
      subroutine uintopo(lun)
      use uinput_mod
      implicit none
      integer, intent(in) :: lun
      integer i
      character*16 uline
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
      end subroutine uintopo
