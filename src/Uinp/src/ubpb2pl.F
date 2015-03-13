      subroutine ubpb2pl
c
c  version : 27.11.2003 21:10
c
c======================================================================
c*** Produces additional files specifying geometry for b2plot
c***
c*** Input:
c***  nmvsle  the list of elements to be included in mesh.extra
c***  nnvsle  the length of this list
c***          (specified through dg and input by ubpnam)
c***
c*** Toroidal angles are temporarily used for profiles only!!!
c======================================================================
#include "ubpcom.h"
      integer i,j,k,llm(nubchrdx),lli(nubchrdx)
      character c*(ufnlen+4)
c======================================================================

      pi45=atan(1.)/45.

c*** mesh.extra
c
      if(nnvsle.gt.0) then
        open(1,file='mesh.extra',err=10)
        do i=1,nnvsle
          j=nmvsle(i)
          write(1,*,err=10) pp1(1,j),pp1(2,j),pp2(1,j),pp2(2,j)
        end do
        close(1)
        write (*,*) '    ... mesh.extra created'
      end if
c----------------------------------------------------------------------
c*** Chords files for the line integrals
c
 10   continue
      do k=1,nubsli
        if(nubchrdi(k).gt.0) then
          c=cublbli(k)//'.chr'
          call lefta(c,ufnlen+4,m)
          open(iunoo,file=c,err=22)
          write(iunoo,700,err=20) cublbli(k),nubnpni(k)
  700     format(1h',a,1h',i7)
c
c*** Sort the chords according to their labels
c
          do i=1,nubchrdi(k)
            llm(i)=lublbli(lubchrdi(i,k))
          end do
          call sortia(llm,lli,nubchrdi(k))
          do i=1,nubchrdi(k)
            j=lubchrdi(lli(i),k)
            y2=ubchrds(3,j)*sin(angchrdi(j)*pi45)
            x2=ubchrds(3,j)*cos(angchrdi(j)*pi45)
            write(iunoo,'(1p,6e12.4,i5)',err=20) ubchrds(1,j), 0.,
     ,                    ubchrds(2,j), x2, y2, ubchrds(4,j), lublbli(j)
          end do
          write (*,*) 'Chords file created: ',c
 20       continue
          close(iunoo)
 22       continue
        end if
      end do
c----------------------------------------------------------------------
c*** Chords files for the line profiles
c
      do k=1,nubslp
        if(nubchrdp(k).gt.0) then
          do i=1,nubchrdp(k)
            j=lubchrdp(i,k)
            l=lublblp(j)
            write(c,'(a,1h.,i3.3)',err=32) cublblp(k),l
            call lefta(c,ufnlen+4,m)
            open(iunoo,file=c,err=32)
            write(iunoo,700,err=30) c,nubnpnt(k)
c
            r1=ubchrds(1,j)
            z1=ubchrds(2,j)
            r2=ubchrds(3,j)
            z2=ubchrds(4,j)
            fi=angchrdp(j)*pi45
            x1=r1
            x2=r2*cos(fi)
            y1=0.
            y2=r2*sin(fi)
            dd=sqrt((x1-x2)**2+(y1-y2)**2+(z1-z2)**2)
            d=1.0/nubnpnt(k)
            print '(a,4i3,1p,8e10.2)'
            w=0
            do m=0,nubnpnt(k)
              z=z1+w*(z2-z1)
              x=x1+w*(x2-x1)
              y=y1+w*(y2-y1)
              r=sqrt(x**2+y**2)
              write(iunoo,'(1p,6e12.4,i5)',err=30) r,0.,z,w*dd
              w=w+d
            end do
            write (*,*) 'Profile chord file created: ',c
 30         close(iunoo)
 32         continue
          end do
        end if
      end do
c======================================================================
      end
c
c
c======================================================================
      block data ubpblkd
#include "ubpcom.h"
      data nnvsle, nubchrd,  nubnpnt  ,  nubnpni  , nubchrdp, nubchrdi/

     /       0   ,    0   , nubslp*200, nubsli*400, nubslp*0, nubsli*0/,
     ,  angchrdp  , angchrdi  /
     / nubchrdx*0.,nubchrdx*0./
      end
