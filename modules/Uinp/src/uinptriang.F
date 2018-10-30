      subroutine uinptriang(TriMesh)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx

c  version : 01.04.2005 00:51

c***  prepares the data for TRIA grid 
c***  returns .TRUE. if successful and .FALSE. otherwise 
      implicit none
#include "uinput.inc"
    
      logical TriMesh  
      integer attrib(nlim),nattr,nchain,chain(nlim)
      integer NSS(nsts),nn,i,j,k,l
      logical ex 
      real txmin,txmax,tymin,tymax
      external subini, subend
    
      call subini ('uinptriang')
      print *
      print *,'==== Starting uinptriang'
      TriMesh=.TRUE.
c*** makes list of polygon indices present in the input data
      attrib(1)=ilplgdg(1)
      k=1
      do 10 i=2,nlim  
       ex=.true.
       do 15 j=1,k
        if(attrib(j).eq.ilplgdg(i)) ex=.false.
   15  continue 
       if(ex) then
        k=k+1
        attrib(k)=ilplgdg(i)
       end if
   10 continue    
      nattr=k
c***  makes sets of elements with certain attribute
c***  and check if they are closed
      write(*,*) 'nattr ',nattr
      IF(nattr.GT.0) write(*,*) 'attrib', (attrib(l),l=1,nattr)
      if(nattr.EQ.1.AND.attrib(1).EQ.0) then
       TriMesh=.FALSE.
       write(0,*) 'no TRIA polygons specified'  
       goto 9999
      end if 
      do 20 i=1,nattr
       write(*,*) 'chain number, attrib', i, attrib(i)
       if(attrib(i).EQ.0) goto 20
       k=0
       do 25 j=1,nlim
        if(attrib(i).EQ.ilplgdg(j) ) then
         k=k+1
         chain(k)=j
        end if     
   25  continue
       nchain=k
       write(*,*) 'nchain',nchain
       IF(nchain.GT.0) then
         write(*,'(1x,a)') 'chain:'
         write(*,'(20i5)') (chain(l),l=1,nchain)
       ENDIF
c***   makes checking and outputs NSS indices if necessary
       call uichkchn(chain,nchain,nsts,NSS,nn,attrib(i))
       write(*,*) 'nn ',nn
       IF(nn.GT.0)  write(*,*) 'NSS', (NSS(l),l=1,nn)
       if(nn.LT.0) then 
        write(0,*) 'ERROR in uichkchn, nn', nn
        TriMesh=.FALSE.
        call xerrab('Contours did not close. Stopping.')
       end if
c***   write intermediate arrays for output
       do 26 j=1,nchain
        jlplgu(chain(j))=attrib(i)
   26  continue
       do 27 j=1,nn
        ilplgu(NSS(j))=attrib(i)
   27  continue
   20 continue   

c  Prepare data for TRIA input file (header with refinement zones data)
      k=0
      do 30 i=1,ntriref
       k=k+1
       txmin=min(p1(1,trirefel(k)),p2(1,trirefel(k)))
       txmax=max(p1(1,trirefel(k)),p2(1,trirefel(k)))
       tymin=min(p1(2,trirefel(k)),p2(2,trirefel(k)))
       tymax=max(p1(2,trirefel(k)),p2(2,trirefel(k)))
       do 35 j=2,trirefcn(i)
        k=k+1
        txmin=min(txmin,p1(1,trirefel(k)),p2(1,trirefel(k)))
        txmax=max(txmax,p1(1,trirefel(k)),p2(1,trirefel(k)))
        tymin=min(tymin,p1(2,trirefel(k)),p2(2,trirefel(k)))
        tymax=max(tymax,p1(2,trirefel(k)),p2(2,trirefel(k)))
   35  continue   
       trixmin(i)=txmin
       trixmax(i)=txmax
       triymin(i)=tymin
       triymax(i)=tymax
   30 continue
 9999 call subend()
      return
      end subroutine uinptriang
