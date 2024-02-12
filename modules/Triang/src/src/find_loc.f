      integer function find_loc(array,ndim,value)
!! Function that looks for the location of the integer value in array with dimensions ndim

      implicit none
      integer, intent (in) :: ndim
      integer, intent (in) :: array(1:ndim), value
      integer :: i

      find_loc = 0
      do i = 1, ndim
        if (array(i).eq.value) then
          find_loc = i
          exit
        endif
      enddo

      return
      end function find_loc
