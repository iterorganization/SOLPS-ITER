
      Program vectors
*     ================================================================ *
      implicit none

*     Parameters: real array, vector
*     ================================================================ *
      integer mdr, ndr ! dimensions of 2-dimensional real array
      integer ldr      ! linear dimension of real array ldr = mdr*ndr
                       ! linear dimension of real vector
      integer lir      ! linear index real array ldr = i + mdr * j

      parameter (mdr = 9,  ndr = 5)
**    parameter (mdr = 555,  ndr = 99)
      parameter (ldr = mdr * ndr)

*     Parameters: integer array, vector
*     ================================================================ *
      integer mdi, ndi ! dimensions of 2-dimensional real array
      integer ldi      ! linear dimension of integer array ldi = mdi*ndi
                       ! linear dimension of integer vector
      integer lii      ! linear index real array lii = i + mdi * j

      parameter (mdi = 9,  ndi = 4)
****  parameter (mdi = 555,  ndi = 99)
      parameter (ldi = mdi * ndi)

      integer i, j
      integer use_vector


*     Arrays, vectors           
*     ================================================================ *
      real*8 real_array (mdr, ndr)      ! the real array
      real*8 real_vector (ldr)          ! the real vector
      integer integer_array(mdi, ndi) ! the integer array
      integer integer_vector(ldi)     ! the integer vector
      integer  increment
      character filename*80
      character  action*15

*     Externals
*     ================================================================ *
*     external xdr_open
      external xdr_real
      external xdr_integer
      external xdr_character
      external xdr_close

      filename = 'vector.xdr'
	  use_vector = 1
	  use_vector = 0

*     Part I: Writing
*     ================================================================ *
      action = 'write'
      call xdr_open(filename, action)
      print *, ' '
      print *, '   XDR file ', filename
      print *, ' opened for writing.'
      print *, ' '

*     Initialization and Encoding
*     ==================================================================
      do i = 1, mdr
          do j = 1, ndr
              lir = i + mdr * j
              real_array (i, j) = sin (real(lir))
              print *, '   real_array(', i, ',', j, ') = ', 
     .        real_array(i, j)
              if (use_vector.eq.0) then
                  call xdr_real(real_array(i, j), 1, 1)
			        endif
          enddo
      enddo 

      if (use_vector.eq.1) then
	      call xdr_real(real_array, ldr, 1)
      endif
      print *, ' ended writing.'

      do j = 1, ldi
        integer_vector(j) = exp(real(j)/2)
        print *, '   integer_vector(', j, ') = ', integer_vector(j)
        if (use_vector.eq.0) then
			     call xdr_integer(integer_vector(j), 1, 1)
		    endif
      enddo

      if (use_vector.eq.1) then
	      call xdr_integer(integer_vector, ldi, 1)
	    endif
      increment = 1 

      call xdr_close()

*     Part II: Clear all to zero 
*     ==================================================================
      do i = 1, mdr
          do j = 1, ndr
              real_array (i, j) = 0.0
***            print *, '   real_array(', i, ',', j, ') = ', 
***  .        real_array(i, j)
          enddo
      enddo 

      do j = 1, ldi
        integer_vector(j) = 0   
*       print *, '   integer_vector(', j, ') = ', integer_vector(j)
      enddo
      
*     Part III: Open file and decode
*     ================================================================ *
      action = 'read'
      call xdr_open(filename, action)
      print *, ' '
      print *, '   XDR file ', filename
      print *, ' opened for reading.'
      print *, ' '

*     Decoding
*     ==================================================================
      if (use_vector.eq.1) then
		      call xdr_real(real_array, ldr, 1)
	    endif

      do i = 1, mdr
          do j = 1, ndr
              if (use_vector.eq.0) then
                  call xdr_real(real_array(i, j), 1, 1)
				      endif
              print *, '   real_array(', i, ',', j, ') = ', 
     .        real_array(i, j)
          enddo
      enddo 

	  
      if (use_vector.eq.1) then
		      call xdr_integer(integer_vector, ldi, 1)
	    endif

      do j = 1, ldi
         if (use_vector.eq.0) then
		         call xdr_integer(integer_vector(j), 1, 1)
	       endif
         print *, '   integer_vector(', j, ') = ', integer_vector(j)
      enddo

      call xdr_close()

      stop ' Normal end'
      end


