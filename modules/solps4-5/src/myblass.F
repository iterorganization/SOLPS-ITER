      function sasum (n, sx, incx)
      use b2mod_types
      implicit none
      real (kind=R4) ::
     *   sasum
      integer n, incx
      real (kind=R4) ::
     *   sx(0:*)
*     ------------------------------------------------------------------
*     SASUM (BLAS routine) computes the L1-norm of a vector.
*     sasum(n,sx,incx) returns the sum of absolute values of the
*     elements in the s.p. real*8 vector described by (n,sx,incx).
*     BLAS storage conventions. Return with sasum.eq.0 if n.lt.1.
*     Undefined if incx.eq.0.
*     ------------------------------------------------------------------
      integer i, ix
      real (kind=R4) ::
     *   t
      intrinsic abs, max
      integer ibase
      ibase(n,incx) = max(0,(1-n)*incx)
*     ------------------------------------------------------------------
      if (incx.eq.0) then
       stop 'sasum--error, incx.eq.0'
      else if (incx.eq.1) then
       t = 0
       do i = 0, n-1
        t = t+abs(sx(i))
       enddo
       sasum = t
      else
       ix = ibase(n,incx)
       t = 0
       do i = 0, n-1
        t = t+abs(sx(ix))
        ix = ix+incx
       enddo
       sasum = t
      endif
      return
*     ------------------------------------------------------------------
      end function sasum
      subroutine sscal (n, sa, sx, incx)
      use b2mod_types
      implicit none
      integer n, incx
      real (kind=R4) ::
     *   sa, sx(0:*)
*     ------------------------------------------------------------------
*     SSCAL (BLAS routine) performs the vector operation x:=sa*x.
*     x is an s.p. real*8 vectors, described by (n,sx,incx). BLAS storage
*     conventions. Return without effects if sa.eq.1.
*     Undefined if incx.eq.0.
*     ------------------------------------------------------------------
      integer i, ix
      intrinsic max
      integer ibase
      ibase(n,incx) = max(0,(1-n)*incx)
*     ------------------------------------------------------------------
      if (incx.eq.0) then
       stop 'sscal--error, incx.eq.0'
      else if (sa.eq.1) then
      else if (incx.eq.1) then
       do i = 0, n-1
        sx(i) = sa*sx(i)
       enddo
      else
       ix = ibase(n,incx)
       do i = 0, n-1
        sx(ix) = sa*sx(ix)
        ix = ix+incx
       enddo
      endif
      return
*     ------------------------------------------------------------------
      end subroutine sscal
      subroutine scopy (n, sx, incx, sy, incy)
      use b2mod_types
      implicit none
      integer n, incx, incy
      real (kind=R4) ::
     *   sx(0:*), sy(0:*)
*     ------------------------------------------------------------------
*     SCOPY (BLAS routine) performs the vector operation y:=x.
*     x and y are s.p. real*8 vectors described by (n,sx,incx) and
*     (n,sy,incy). BLAS storage conventions.
*     Undefined if incy.eq.0.
*     ------------------------------------------------------------------
      integer i, ix, iy
      intrinsic max
      integer ibase
      ibase(n,incx) = max(0,(1-n)*incx)
*     ------------------------------------------------------------------
      if (incy.eq.0) then
       stop 'scopy--error, incy.eq.0'
      else if (incx.eq.1.and.incy.eq.1) then
       do i = 0, n-1
        sy(i) = sx(i)
       enddo
      else
       ix = ibase(n,incx)
       iy = ibase(n,incy)
       do i = 0, n-1
        sy(iy) = sx(ix)
        ix = ix+incx
        iy = iy+incy
       enddo
      endif
      return
*     ------------------------------------------------------------------
      end subroutine scopy
      subroutine saxpy (n, sa, sx, incx, sy, incy)
      use b2mod_types
      implicit none
      integer n, incx, incy
      real (kind=R4) ::
     *   sa, sx(0:*), sy(0:*)
*     ------------------------------------------------------------------
*     SAXPY (BLAS routine) performs the vector operation y:=y+sa*x.
*     x and y are s.p. real*8 vectors, described by (n,sx,incx) and
*     (n,sy,incy). BLAS storage conventions.
*     Return without effects if sa.eq.0.
*     Undefined if incy.eq.0.
*     ------------------------------------------------------------------
      integer i, ix, iy
      intrinsic max
      integer ibase
      ibase(n,incx) = max(0,(1-n)*incx)
*     ------------------------------------------------------------------
      if (incy.eq.0) then
       stop 'saxpy--error, incy.eq.0'
      else if (sa.eq.0) then
      else if (incx.eq.1.and.incy.eq.1) then
       do i = 0, n-1
        sy(i) = sy(i)+sa*sx(i)
       enddo
      else
       ix = ibase(n,incx)
       iy = ibase(n,incy)
       do i = 0, n-1
        sy(iy) = sy(iy)+sa*sx(ix)
        ix = ix+incx
        iy = iy+incy
       enddo
      endif
      return
*     ------------------------------------------------------------------
      end subroutine saxpy
