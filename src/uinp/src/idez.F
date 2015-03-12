      function idez(i,j,izif)
c
c   i is an integer with  n decimals, the function returns
c   idez, the j-th decimal
c   j must be .le. izif
c      if n .lt. izif and j .gt. n  , idez=0
c      if n .gt. izif and j .eq. izif  , idez=part of i on the left of
c      the decimal j, including the j-th decimal
c      e.g.: i=1234,izif=3, j=1: idez=4
c                           j=2: idez=3
c                           j=3: idez=12
c                           j=4: error ,j gt izif
      idif=izif-j+1
      if (idif.le.0) then
        call masage ('error in function idez                         ')
        call exit(0)
      endif
      iz=i
      do 1 k=1,idif
        it=10**(izif-k)
        iq=iz/it
        iz=iz-iq*it
1     continue
      idez=iq
      return
      end
      subroutine masage (a)
      character*(*) a
      write (6,60) a
 60   format (1x,a)
      return
      end
