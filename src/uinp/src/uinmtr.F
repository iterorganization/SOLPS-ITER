      subroutine uinmtr(cmt,n)
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
      integer n
#include "uinput.inc"
      integer imtr,imtrl
      parameter (imtr=6, imtrl=8)
      character*(imtrl) cmt(*),ucm(imtr),ucr
      integer i,j,k
      logical ex
      real uz(imtr)
      data ucm /
     /        'c'   , 'ss' , 'be'  , 'mo'  , 'w'   , 'fe'  /
      data uz /
     /        1206. , 5626.,  904. , 9642. , 18474., 5626. /
c=======================================================================

      if(n.lt.0) then !{

c*** Return the result in parameter n

        call locase(cmt(1),ucr,imtrl)
	ex=.true.
        do j=1,imtr !{
          if(ex) then !{
	    if(ucr.eq.ucm(j)) then !{
	      ex=.false.
	      n=uz(j)
	    end if !}
	  end if !}
        end do !}

      else if(n.eq.0) then !}{

c*** Additional surfaces

        do i=1,nlimi !{
          call locase(cmt(i),ucr,imtrl)
          do j=1,imtr !{
            if(ucr.eq.ucm(j)) go to 10
          end do !}
          j=1
 10       xmlma(i)=uz(j)
        end do !}
      else !}{

c*** Non-default surface (target)

        call locase(cmt(1),ucr,imtrl)
        do j=1,imtr !{
          if(ucr.eq.ucm(j)) go to 20
        end do !}
        j=1
 20     xmlim(n)=uz(j)
      	
      end if !}
c=======================================================================
      end
