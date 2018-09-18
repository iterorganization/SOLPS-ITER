      subroutine uinprpla
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
c
c  version : 19.02.2003 18:23
c
c=======================================================================
c*** Prepare the additional surface lists for the diagnostic Eirene run
c=======================================================================
      implicit none
#include "uinput.inc"
      integer i,j,k,m,nchn,iprv(nlim),inxt(nlim),istrt(nlim),ilen(nlim),
     ,  iambg(2,nlim),nambg
      real x1,y1,x2,y2,tol
      logical notyet(nlim),joint
      external xerrab, subini, subend
      data tol / 1.e-2/ ! tolerance for a search for chains
c=======================================================================
      joint(x1,y1,x2,y2)=abs(x1-x2).le.tol .and. abs(y1-y2).le.tol .and.
     .                                sqrt((x1-x2)**2+(y1-y2)**2).le.tol
c=======================================================================
c*** Initialize the counters and pointers. Here
c***  iprv    points to the previous segment
c***  inxt    points to the next segment
c***  nchn    is the number of identified chains
c***  istrt   list of starting points of the chains
c***  ilen    list of lengths of the chains
c***  notyet  this segment is not yet in a chain

      call subini ('uinprpla')
      do i=1,nlim !{
        iprv(i)=0
        inxt(i)=0
        istrt(i)=0
        ilen(i)=0
        notyet(i)=.true.
      end do !}

c*** Filter out "Elements not for Eirene"

      do i=1,nlstadu !{
        k=listaddi(i)
        notyet(i)=indasrfe(k).gt.0
      end do !}

c*** Find the connections

      nambg=0
      do j=1,nlstadu !{
        if(notyet(j)) then !{
         m=listaddi(j)
          do i=j+1,nlstadu !{
            if(notyet(i)) then !{
              k=listaddi(i)
              if(joint(p2(1,m),p2(2,m),p1(1,k),p1(2,k))) then !{
                if(inxt(j).eq.0 .and. iprv(i).eq.0) then !{
                  inxt(j)=i
                  iprv(i)=j
                else !}{
                  nambg=nambg+1
                  if(nambg.le.nlim) then !{
                    iambg(1,nambg)=j
                    iambg(2,nambg)=i
                  else !}{
                  end if !}
                end if !}
              else if(joint(p1(1,m),p1(2,m),p2(1,k),p2(2,k))) then !}{
                if(inxt(i).eq.0 .and. iprv(j).eq.0) then !{
                  inxt(i)=j
                  iprv(j)=i
                else !}{
                  nambg=nambg+1
                  if(nambg.le.nlim) then !{
                    iambg(1,nambg)=i
                    iambg(2,nambg)=j
                  else !}{
                    write(0,*) 'uinprpla: too many alternative ways'
                    call xerrab ('==> Check the DG model')
                  end if !}
                end if !}
               end if !}
            end if !}
          end do !}
        end if !}
      end do !}

c*** Save the chains

      nchn=0
      k=0

c*** Open chains

      do j=1,nlstadu !{
        if(notyet(j)) then !{
          if(iprv(j).eq.0) then !{
            nchn=nchn+1
            ilen(nchn)=0
            istrt(nchn)=k+1
            m=j
            do while(m.gt.0 .and. notyet(m)) !{
              k=k+1
              listaddg(k)=listaddi(m)
              ilen(nchn)=ilen(nchn)+1
              notyet(m)=.false.
              m=inxt(m)
            end do !}
          end if !}
        end if !}
      end do !}

c*** Check for closed chains

      do j=1,nlstadu !{
        if(notyet(j)) then !{
          nchn=nchn+1
          ilen(nchn)=0
          istrt(nchn)=k+1
          m=j
          do while(m.gt.0 .and. notyet(m)) !{
            k=k+1
            listaddg(k)=listaddi(m)
            ilen(nchn)=ilen(nchn)+1
            notyet(m)=.false.
            m=inxt(m)
          end do !}
        end if !}
      end do !}

c*** Error check

      do j=1,nlstadu !{
        if(notyet(j)) then !{
          write(*,*) 'uinprpla: unexpected error in chain ordering'
          write(*,*) 'nlstadu,k,nchn,nambg =',nlstadu,k,nchn,nambg
          write(*,'(1x,a/(20i5))') 'listaddi:',(listaddi(i),i=1,nlstadu)
          write(*,'(1x,a/(20l5))') 'notyet:',(notyet(i),i=1,nlstadu)
          write(*,'(1x,a/(20i5))') 'iprv:',(iprv(i),i=1,nlstadu)
          write(*,'(1x,a/(20i5))') 'inxt:',(inxt(i),i=1,nlstadu)
          if(nchn.gt.0) then !{
            write(*,'(1x,a/(20i5))') 'istrt:',(istrt(i),i=1,nchn)
            write(*,'(1x,a/(20i5))') 'ilen:',(ilen(i),i=1,nchn)
          end if !}
          if(k.gt.0) then !{
            write(*,'(1x,a/(20i5))') 'listaddg:',(listaddg(i),i=1,k)
          end if !}
          if(nambg.gt.0) then !{
            write(*,'(1x,a/(2i5))') 'iambg:',
     ,                                 (iambg(1,i),iambg(2,i),i=1,nambg)
          end if !}
          call xerrab ('== INTERNAL ERROR IN UINP !!!')
        end if !}
      end do !}

c*** Optimize the chains for maximum length - to be done later

      nlstadu=k
      do j=1,nlstadu !{
        listadds(j)=listaddg(j)
      end do !}

c*** Sort the chains and put them in descending order in length

      call sortia(ilen,iprv,nchn)
      k=0
      do j=nchn,1,-1 !{
        m=iprv(j)
c        print *,'j,m,k,ilen(m)=',j,m,k  !###
        do i=1,ilen(m) !{
          k=k+1
          listaddg(k)=listadds(istrt(m)+i-1)
        end do !}
        k=k+1
        listaddg(k)=0
      end do !}
      nlstadu=k-1

c*** Create the list in Eirene numbering

      do i=1,nlstadu !{
        k=listaddg(i)
        if(k.gt.0) k=indasrfe(k)
        listadds(i)=k
      end do !}
c=======================================================================
      call subend ()
      return
      end
