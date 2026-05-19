      subroutine uib2pl
      use b2mod_constants
      use uinput_mod
c
c  version : 14.04.97 19:05
c
c=====================================================
c*** Produces additional files specifying geometry for b2plot
c*** At present, only mesh.extra and chord files are created - provided that
c*** corresponding data has been specified in dg.
c***
c*** Input:
c***  nmvsle  the list of elements to be included in mesh.extra
c***  nnvsle  the length of this list
c***          (specified through dg and input by uinnam)
c=====================================================
      implicit none
      integer i, j, k
      character*28 filename
c=====================================================
c
      if(nnvsle.gt.0) then
        open(1,file='mesh.extra',err=10)
        do i=1,nnvsle
          j=nmvsle(i)
          write(1,*) 0.01*p1(1,j),0.01*p1(2,j),
     ,                                        0.01*p2(1,j),0.01*p2(2,j)
        end do
        close(1)
        print *,'    ... mesh.extra created'
      end if
   10 continue

      if(nchrdlint.gt.0) then
        do i = 1, nchrdlint
          filename=trim(chrdfile(i))//'.chr'
          open(2,file=filename,err=20)
          j = jchlst(1,i)
          k = count(jchlst(:,i).gt.0)
          write(2,*) trim(chrdfile(i)), k
          do j = 1, k
            write(2,'(1p,6(1e12.4,1x),i4)')
     ,               0.01*xpivot(jchlst(j,i)),
     ,               0.01*ypivot(jchlst(j,i)),
     ,               0.01*zpivot(jchlst(j,i)),
     ,               0.01*xchord(jchlst(j,i)),
     ,               0.01*ychord(jchlst(j,i)),
     ,               0.01*xchord(jchlst(j,i))*
     ,                cos(zchord(jchlst(j,i))*pi/180._R8),
     ,               chr_lbl(jchlst(j,i))
          end do
          close(2)
          print *,'    ... '//trim(filename)//' created'
        end do
      end if
   20 continue

      return
c=====================================================
      end subroutine uib2pl
