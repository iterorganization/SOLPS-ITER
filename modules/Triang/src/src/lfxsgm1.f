      logical function lfxsgm1(x0,y0,x1,y1,xs,ys)

c  version : 02.11.2005 22:12

c=======================================================================
c** This function returns .true. if the segments (x0,y0) and (x1,y1)
c** intersect each other. (xs,ys) is the intersection point.
c=======================================================================
      implicit none
      double precision x0(2),y0(2),x1(2),y1(2),xs,ys
      double precision a11,a12,a21,a22,b1,b2,d,t1,t2
      double precision tol,tol2
      parameter (tol=1.e-30, tol2=1.e-12)
      integer inx,iny,ixx,ixy,jnx,jny,jxx,jxy
c=======================================================================

      lfxsgm1=.false.
      if(x0(1).le.x0(2)) then !{
        inx=1
      else !}{
        inx=2
      end if !}
      if(x1(1).le.x1(2)) then !{
        jnx=1
      else !}{
        jnx=2
      end if !}
      ixx=3-inx
      jxx=3-jnx
      if(x0(ixx).lt.x1(jnx) .or. x1(jxx).lt.x0(inx)) return

      if(y0(1).le.y0(2)) then !{
        iny=1
      else !}{
        iny=2
      end if !}
      if(y1(1).le.y1(2)) then !{
        jny=1
      else !}{
        jny=2
      end if !}
      ixy=3-iny
      jxy=3-jny
      if(y0(ixy).lt.y1(jny) .or. y1(jxy).lt.y0(iny)) return

      a11=x0(2)-x0(1)
      a12=x1(1)-x1(2)
      a21=y0(2)-y0(1)
      a22=y1(1)-y1(2)
      b1=x1(1)-x0(1)
      b2=y1(1)-y0(1)
      d=a11*a22-a21*a12
      if(abs(d).le.tol) return

      t1=(b1*a22-b2*a12)/d
      if(t1.le.0. .or. t1.ge.1.) return

      t2=(b2*a11-b1*a21)/d
      if(t2.le.tol2 .or. t2.ge.1.-tol2) return

      xs=x0(1)+a11*t1
      ys=y0(1)+a21*t1
      lfxsgm1=.true.
      
c=======================================================================
      end
