      subroutine chkinp
c
c  version : 18.11.95 18:19
c
c=====================================================
c*** checks the input data for consistency, sorts the arrays, and
c*** makes minor adjustments (e.g., add the guard cells)
c
#include "sonparm.inc"
      integer ind(nlvl+narc)
      real uum(nlvl+narc)
      logical ubmx
c=====================================================
c
c*** First, sort and renormalize the flux data
c
      write(6,*) 'Flux difference between axis and separatrix: ',flxnr
      uflnr=1./flxnr
      ubmx=flvl(1,1).gt.0.
      do 100 j=1,nnreg
          n=nmlvl(j)
          if(n.gt.0) then
              call sortra(flvl(1,j),ind,n)
              do 105 i=1,n
                  if(ubmx) then
                      k=ind(n-i+1)
                  else
                      k=ind(i)
                  end if
                  uum(i)=flvl(k,j)
 105          continue
              call vscale(uum,uflnr,flvl(1,j),n)
          end if
 100  continue
c
c*** sort the arclength data
c
      do 110 j=1,nnzon
          n=nmarc(j)
          if(n.gt.0) then
              call sortra(arcln(1,j),ind,n)
              do 115 i=1,n
                  k=ind(i)
                  uum(i)=arcln(k,j)
 115          continue
              call vsend(uum,arcln(1,j),n)
          end if
 110  continue
c
c*** check the numbers of radial points in the main plasma and
c*** in the private flux region - must be the same
c
      l=nmlvl(3)-nmlvl(1)
      if(l.gt.0) then
          nmlvl(3)=nmlvl(1)
          call vsend(flvl(l+1,3),flvl(1,3),nmlvl(3))
          print *,'*** Radial grid correction: ',l,'  points are ',
     ,            'removed from the private flux region  ***'
      else if(l.lt.0) then
          l=-l
          nmlvl(1)=nmlvl(3)
          call vsend(flvl(l+1,1),flvl(1,1),nmlvl(1))
          print *,'*** Radial grid correction: ',l,'  points are ',
     ,            'removed from the main plasma region  ***'
      end if
c
c*** and, finally, add the guard cells
c
      print *,'Guard cells:'
c
      h=delgs*(flvl(1,1)-flvl(2,1))
      call rvsend(flvl(1,1),flvl(2,1),nmlvl(1))
      flvl(2,1)=flvl(2,1)-h
      nmlvl(1)=nmlvl(1)+1
      print *,'        South - mp  ',h
c
      n=nmlvl(2)
      h=delgs*(flvl(n-1,2)-flvl(n,2))
      flvl(n+1,2)=flvl(n,2)
      flvl(n,2)=flvl(n,2)+h
      nmlvl(2)=nmlvl(2)+1
      print *,'        North       ',h
c
      h=delgs*(flvl(1,3)-flvl(2,3))
      call rvsend(flvl(1,3),flvl(2,3),nmlvl(3))
      flvl(2,3)=flvl(2,3)-h
      nmlvl(3)=nmlvl(3)+1
      print *,'        South - pfl ',h
c
      h=delgs*arcln(1,2)
      call rvsend(arcln(1,2),arcln(2,2),nmarc(2))
      arcln(1,2)=h
      nmarc(2)=nmarc(2)+1
      print *,'        West        ',h
c
      n=nmarc(3)
      h=delgs*(1.-arcln(n,3))
      arcln(n+1,3)=1.-h
      nmarc(3)=nmarc(3)+1
      print *,'        East        ',h
c=====================================================
      end
