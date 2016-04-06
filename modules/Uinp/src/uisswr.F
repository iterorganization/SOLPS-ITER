      subroutine uisswr(lout,s,ss,n,ff)
c
c  version : 26.11.95 20:20
c
c*** Print out a line
      implicit none
      integer :: lout,n,k,i
      character s(n), ss*(*),ff*(*)
c=====================================================
c
      if(ss.eq.' ') then
          write(lout,*)
      else
          do 560 k=n,1,-1
              if(s(k).ne.' ') then
                  write(lout,ff) (s(i),i=1,k)
                  return
              end if
c          end do
 560      continue
      end if
c=====================================================
      end
