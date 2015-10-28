      function sdot(n,sx,incx,sy,incy)
      use b2mod_types
      implicit none
      real (kind=R4) ::
     *   sdot
c
c     forms the dot product of two vectors.
c     uses unrolled loops for increments equal one.
c     jack dongarra, linpack, 3/11/78.
c
      real (kind=R4) ::
     * sx(1),sy(1),stemp
      integer i,incx,incy,ix,iy,m,mp1,n
c
      stemp = 0.0e0_R4
      sdot = 0.0e0_R4
      if(n.le.0) return
      if(incx.eq.1.and.incy.eq.1) goto 20
c
c       code for unequal increments or equal increments
c       not equal to 1
c
      ix = 1
      iy = 1
      if(incx.lt.0)ix = (-n+1)*incx + 1
      if(incy.lt.0)iy = (-n+1)*incy + 1
      do 10 i = 1,n
        stemp = stemp + sx(ix)*sy(iy)
        ix = ix + incx
        iy = iy + incy
   10 continue
      sdot = stemp
      return
c
c       code for both increments equal to 1
c
c
c       clean-up loop
c
   20 m = mod(n,5)
      if( m .eq. 0 ) goto 40
      do 30 i = 1,m
        stemp = stemp + sx(i)*sy(i)
   30 continue
      if( n .lt. 5 ) goto 60
   40 mp1 = m + 1
      do 50 i = mp1,n,5
      stemp=stemp+sx(i)*sy(i)+sx(i+1)*sy(i+1)+
     *        sx(i+2)*sy(i+2)+sx(i+3)*sy(i+3)+sx(i+4)*sy(i+4)
   50 continue
   60 sdot = stemp
      return
      end

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
