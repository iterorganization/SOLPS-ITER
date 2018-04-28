      subroutine uinmtr(cmt,n,ncmt)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
c
c  version : 01.06.99 16:35
c
c=======================================================================
c*** Wall material specification
c=======================================================================
      implicit none
      integer n, ncmt
#include "uinput.inc"
      integer imtrl
      parameter (imtrl=2)
      character*(imtrl) ucm(0:nmtr),ucr
      character*(*) cmt(ncmt)
      integer i,j
      logical ex
      logical streql
      external streql
      real uz(0:nmtr)
      data ucm /
     /        '  ', 'c'   , 'ss' , 'be'  , 'mo'  , 'w'   , 'fe'  /
      data uz /
     /          0., 1206. , 5626.,  904. , 9642. , 18474., 5626. /
c=======================================================================

      if(n.lt.0) then !{

c*** Return the result in parameter n

        call locase(cmt(1)(1:2),ucr,imtrl)
        ex=.true.
        do j=1,nmtr !{
          if(ex) then !{
            if(streql(ucr,ucm(j))) then !{
              ex=.false.
              n=uz(j)
            end if !}
          end if !}
        end do !}

      else if(n.eq.0) then !}{

c*** Additional surfaces

        do i=1,nlimi !{
          call locase(cmt(i)(1:2),ucr,imtrl)
          do j=1,nmtr !{
            if(streql(ucr,ucm(j))) go to 10
          end do !}
          j=0
 10       xmlma(i)=uz(j)
        end do !}
      else !}{

c*** Non-default surface (target)

        call locase(cmt(1)(1:2),ucr,imtrl)
        do j=1,nmtr !{
          if(streql(ucr,ucm(j))) go to 20
        end do !}
        j=0
 20     xmlim(n)=uz(j)

      end if !}
c=======================================================================
      end
