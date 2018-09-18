      subroutine uinbndzn
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx
c
c  version : 15.03.2001 17:12
c
c=======================================================================
c*** Determine the boundary zones
c=======================================================================
      implicit none
#include "uinpcom.inc"
      integer i,j,k,l,m,n,ix,iy,iz,n1,n2
      integer, parameter :: n_hlp=3
      integer i_sw(0:nxd+1,nbndrgn,n_hlp),i_tg(0:nyd+1,ntrgts),
     ,  l_hlp(n_hlp),i_cr(0:nxd+1)
      character*10 hlp_txt(n_hlp)
      external xerrab, subini, subend
      data l_hlp /1,3,4/
      data hlp_txt / 'Core','PFR','Outer side' /
c=======================================================================
      call subini ('uinbndzn')
c      print '(a,10i6)','uinbndzn: nx,ny,nncut,mdvbndx,nrgbndt = ',       !###
c     ,                            nx,ny,nncut,mdvbndx,nrgbndt !###

      if(nx.gt.nxd) then !{
        write(0,*) 'Too many poloidal grid points: maximum ',nxd
        write(0,*)
     .   'Current number of requested poloidal grid points: ',nx
         call xerrab
     .    (' ==> Check the DG model and DEF_NXD in DIMENSIONS.F')
      end if !}
      if(ny.gt.nyd) then !{
        write(0,*) 'Too many radial grid points: maximum ',nyd
        write(0,*)
     .   'Current number of requested radial grid points: ',ny
        call xerrab
     .   (' ==> Check the DG model and DEF_NYD in DIMENSIONS.F')
      end if !}

c*** Find the divides positions for each kind of boundary.

      do i=0,nyd+1 !{
        do j=1,ntrgts !{
          i_tg(i,j)=0
        end do !}
      end do !}
      do i=0,nxd+1 !{
        i_cr(i)=0
        do j=1,nbndrgn !{
          do k=1,n_hlp !{
            i_sw(i,j,k)=0
          end do !}
        end do !}
      end do !}

c*** Radial divides (targets)
      n=ldvbndx(0)
      do i=1,n !{
        k=ldvbndx(i)
        if(k.ge.0) then !{
          ix=mod(k,nx+2)
          iy=(k-ix)/(nx+2)
        else !}{
          k=-k
          ix=mod(k,nx+2)
          iy=ny+2
        end if !}
        m=2
        do k=1,nrgbndt(m) !{
          if(lrpbndt(k,m,1).gt.nxd+1) then !{
            write(0,*) 'Too many poloidal grid points: maximum ',nxd+1
            write(0,*)
     .       'Current number of requested poloidal grid points: ',
     .        lrpbndt(k,m,1)
            call xerrab
     .       (' ==> Check the DG model and DEF_NXD in DIMENSIONS.F')
          end if !}
          if(lrpbndt(k,m,2).gt.nxd+1) then !{
            write(0,*) 'Too many poloidal grid points: maximum ',nxd+1
            write(0,*)
     .       'Current number of requested poloidal grid points: ',
     .        lrpbndt(k,m,2)
            call xerrab
     .       (' ==> Check the DG model and DEF_NXD in DIMENSIONS.F')
          end if !}
          if(lrrbndt(k,m,1).gt.nyd+1) then !{
            write(0,*) 'Too many radial grid points: maximum ',nyd+1
            write(0,*)
     .       'Current number of requested radial grid points: ',
     .        lrrbndt(k,m,1)
            call xerrab
     .       (' ==> Check the DG model and DEF_NYD in DIMENSIONS.F')
          end if !}
          if(lrrbndt(k,m,2).gt.nyd+1) then !{
            write(0,*) 'Too many radial grid points: maximum ',nyd+1
            write(0,*)
     .       'Current number of requested radial grid points: ',
     .        lrrbndt(k,m,2)
            call xerrab
     .       (' ==> Check the DG model and DEF_NYD in DIMENSIONS.F')
          end if !}
          if(ix.ge.lrpbndt(k,m,1) .and. ix.le.lrpbndt(k,m,2) .and.
     ,       iy.gt.lrrbndt(k,m,1) .and. iy.le.lrrbndt(k,m,2)) then !{
            i_tg(iy,k)=1
          end if !}
        end do !}
      end do !}
c!###{
c      print *,'i_tg:'
c      do k=1,ntrgts !{
c       print '(1x,100i1)',(i_tg(i,k),i=0,ny+1)
c      end do !}
c!###}

c*** Poloidal divides (core and wall)     
      do i=n+1,mdvbndx !{
        k=ldvbndx(i)
        if(k.ge.0) then !{
          ix=mod(k,nx+2)
          iy=(k-ix)/(nx+2)
        else !}{
          k=-k
          ix=nx+2
          iy=(k-nx-1)/(nx+2)
        end if !}
        do j=1,n_hlp !{
          m=l_hlp(j)
          do k=1,nrgbndt(m) !{
            if(lrpbndt(k,m,1).gt.nxd+1) then !{
              write(0,*) 'Too many poloidal grid points: maximum ',nxd+1
              write(0,*)
     .         'Current number of requested poloidal grid points: ',
     .          lrpbndt(k,m,1)
              call xerrab
     .         (' ==> Check the DG model and DEF_NXD in DIMENSIONS.F')
            end if !}
            if(lrpbndt(k,m,2).gt.nxd+1) then !{
              write(0,*) 'Too many poloidal grid points: maximum ',nxd+1
              write(0,*)
     .         'Current number of requested poloidal grid points: ',
     .          lrpbndt(k,m,2)
              call xerrab
     .         (' ==> Check the DG model and DEF_NXD in DIMENSIONS.F')
            end if !}
            if(lrrbndt(k,m,1).gt.nyd+1) then !{
              write(0,*) 'Too many radial grid points: maximum ',nyd+1
              write(0,*)
     .         'Current number of requested radial grid points: ',
     .          lrrbndt(k,m,1)
              call xerrab
     .         (' ==> Check the DG model and DEF_NYD in DIMENSIONS.F')
            end if !}
            if(lrrbndt(k,m,2).gt.nyd+1) then !{
              write(0,*) 'Too many radial grid points: maximum ',nyd+1
              write(0,*)
     .         'Current number of requested radial grid points: ',
     .          lrrbndt(k,m,2)
              call xerrab
     .         (' ==> Check the DG model and DEF_NYD in DIMENSIONS.F')
            end if !}
            if(ix.gt.lrpbndt(k,m,1) .and. ix.le.lrpbndt(k,m,2) .and.
     ,         iy.ge.lrrbndt(k,m,1) .and. iy.le.lrrbndt(k,m,2)) then !{
              i_sw(ix,k,j)=1
            end if !}
          end do !}
        end do !}
      end do !}
c!###{
c      print *,'Poloidal divides: ',mdvbndx
c      if(mdvbndx.gt.0) then !{
c        print '(8x,9i10)',1,2,3,4,5,6,7,8,9
c        do j=1,n_hlp !{
c          m=l_hlp(j)
c          do k=1,nrgbndt(m) !{
c            print '(2i3,2h: ,100i1)',m,k,(i_sw(i,k,j),i=0,nx+1)
c         end do !}
c        end do !}
c      end if !}
c!###}
c*** Prepare the array which describes correspondence between the B2
c*** and Eirene numbering in poloidal directions (extra surfaces at the 
c*** cuts)
      m=0
      k=0
      j=0
      do l=1,nrgbndt(1) !{
        if(nrgbndt(3).gt.0) then !{
          if(lrpbndt(k+1,3,2).gt.nxd+1) then !{
            write(0,*) 'Too many poloidal grid points: maximum ',nxd+1
            write(0,*)
     .       'Current number of requested poloidal grid points: ',
     .        lrpbndt(k+1,3,2)
            call xerrab
     .       (' ==> Check the DG model and DEF_NXD in DIMENSIONS.F')
          end if !}
          do i=lrpbndt(k+1,3,1),lrpbndt(k+1,3,2) !{
            i_cr(i)=j
          end do !}
          j=j+1
        end if !}
        if(lrpbndt(l,1,2).gt.nxd+1) then !{
          write(0,*) 'Too many poloidal grid points: maximum ',nxd+1
          write(0,*)
     .     'Current number of requested poloidal grid points: ',
     .      lrpbndt(l,1,2)
          call xerrab
     .     (' ==> Check the DG model and DEF_NXD in DIMENSIONS.F')
        end if !}
        do i=lrpbndt(l,1,1),lrpbndt(l,1,2) !{
          i_cr(i)=j
        end do !}
        j=j+1
        if(nrgbndt(3).gt.0) then !{
          if(lrpbndt(k+2,3,2).gt.nxd+1) then !{
            write(0,*) 'Too many poloidal grid points: maximum ',nxd+1
            write(0,*)
     .       'Current number of requested poloidal grid points: ',
     .        lrpbndt(k+2,3,2)
            call xerrab
     .       (' ==> Check the DG model and DEF_NXD in DIMENSIONS.F')
          end if !}
          do i=lrpbndt(k+2,3,1),lrpbndt(k+2,3,2) !{
            i_cr(i)=j
          end do !}
          j=j+1
        end if !}
        k=k+2
      end do !}

c      print '(8h  i_cr: ,100i1)',(i_cr(i),i=0,nx+1) !###

      
c*** Plan boundary zones between the divides

c*** Targets
      
      m=2
      iz=0
      do k=1,nrgbndt(m) !{
        iy=lrrbndt(k,2,1)
        do j=1,ny+1 !{
          if(i_tg(j,k).gt.0) then !{
c*** divide found
            iz=iz+1
            if(iz.gt.nbndzon) then !{
              write(0,*) 'Too many boundary zones specified for targets'
              write(0,*) 'STOP ==> check "Boundary divides" in the DG ',
     ,                   'model and parameter "nbndzon" in uinpcom.inc'
              call xerrab 
     .         ('Too many boundary zones specified for targets')
            end if !}
            lzpbndt(iz,m)=lrsbndt(k,m)
            lzrbndt(iz,m,1)=iy
            lzrbndt(iz,m,2)=j-1
            lrfbndt(iz,m)=k
            cznbndt(iz,m)=crgbndt(k,m)
            iy=j

c*** Specify the position-related data for B2 and Eirene input files
            n=lzpbndt(iz,m)
            jcpbnds(iz,m)=n+i_cr(n)
            jc1bnds(iz,m)=max(lzrbndt(iz,m,1),1)
            jc2bnds(iz,m)=min(lzrbndt(iz,m,2)+1,ny+1)
            if(cznbndt(iz,m).eq.'W') then !{
              jdrbnds(iz,m)=-1
              jcpbnds(iz,m)=jcpbnds(iz,m)+1
            else if(cznbndt(iz,m).eq.'E') then !}{
              jdrbnds(iz,m)=1
            else !}{
              write(0,*) 'Internal error in uinbndzn: wrong boundary ',
     ,          'code ',cznbndt(iz,m),' for target',k,'  zone',iz
              call xerrab ('Wrong boundary code')
            end if !}
            cskbnds(iz,m)=cznbndt(iz,m)
            lcpbnds(iz,m)=lzpbndt(iz,m)
            lc1bnds(iz,m)=lzrbndt(iz,m,1)
            lc2bnds(iz,m)=lzrbndt(iz,m,2)
            ls1bnds(iz,m)=max(1,lc1bnds(iz,m))
            ls2bnds(iz,m)=min(ny,lc2bnds(iz,m))

            if(jc1bnds(iz,m).ge.jc2bnds(iz,m)) then !{
c*** Boundary zone consists of a single guard cell - reject it
              write(0,*) 'A target zone consists of a single guard ',
     ,              'cell - skipped. Target',k,'  cell',lc2bnds(iz,m)
              iz=iz-1

c           print *,'k,iz,iy =',k,iz,iy !###

            else !}{
              iy=j
            end if !}
          end if !}
        end do !}
        if(iy.le.ny+1) then !{
          iz=iz+1
          if(iz.gt.nbndzon) then !{
            write(0,*) 'Too many boundary zones specified for targets'
            write(0,*) 'STOP ==> check "Boundary divides" in the DG ',
     ,        'model and parameter "nbndzon" in uinpcom.inc'
            call xerrab
     .       ('Too many boundary zones specified for targets')
          end if !}
          lzpbndt(iz,m)=lrsbndt(k,m)
          lzrbndt(iz,m,1)=iy
          lzrbndt(iz,m,2)=ny+1
          lrfbndt(iz,m)=k
          cznbndt(iz,m)=crgbndt(k,m)

c*** Specify the position-related data for B2 and Eirene input files
          n=lzpbndt(iz,m)
          jcpbnds(iz,m)=n+i_cr(n)
          jc1bnds(iz,m)=max(lzrbndt(iz,m,1),1)
          jc2bnds(iz,m)=min(lzrbndt(iz,m,2)+1,ny+1)
          if(cznbndt(iz,m).eq.'W') then !{
            jdrbnds(iz,m)=-1
            jcpbnds(iz,m)=jcpbnds(iz,m)+1
          else if(cznbndt(iz,m).eq.'E') then !}{
            jdrbnds(iz,m)=1
          else !}{
            write(0,*) 'Internal error in uinbndzn: wrong boundary ',
     ,                 'code ',cznbndt(iz,m),' for target',k,'  zone',iz
            call xerrab ('Wrong boundary code')
          end if !}
          cskbnds(iz,m)=cznbndt(iz,m)
          lcpbnds(iz,m)=lzpbndt(iz,m)
          lc1bnds(iz,m)=lzrbndt(iz,m,1)
          lc2bnds(iz,m)=lzrbndt(iz,m,2)
          ls1bnds(iz,m)=max(1,lc1bnds(iz,m))
          ls2bnds(iz,m)=min(ny,lc2bnds(iz,m))

          if(jc1bnds(iz,m).ge.jc2bnds(iz,m)) then !{
c*** Boundary zone consists of a single guard cell - reject it
            write(0,*) 'A target zone consists of a single guard cell ',
     ,                      '- skipped. Target',k,'  cell',lc2bnds(iz,m)

c           print *,'k,iz,iy =',k,iz,iy !###

            iz=iz-1
            lzrbndt(iz,m,2)=lzrbndt(iz,m,2)+1
          end if !}
        end if !}
      end do !}
      nznbndt(m)=iz

c*** Sides. 

      do l=1,n_hlp !{
        m=l_hlp(l)
        iz=0
        do k=1,nrgbndt(m) !{
          if(m.eq.3) then !{
            if(k.eq.nrgbndt(m) .or. k.eq.2) then !{
              n2=lrpbndt(k,m,2)-1
              n1=lrpbndt(k,m,1)
            else !}{
              n2=nx
              n1=lrpbndt(k,m,1)+1
            end if !}
          else if(m.eq.4) then !}{
            n2=lrpbndt(k,m,2)-1
            n1=lrpbndt(k,m,1)+1
            if(lm_cnfg) then !{
              n2=n2+1
              n1=n1-1
            end if !}
          else !}{
            n1=1
            n2=nx+1
          end if !}

c         print *,'m,k,n1,n2 = ',m,k,n1,n2  !###

          ix=lrpbndt(k,m,1)
          do j=lrpbndt(k,m,1),lrpbndt(k,m,2) !{
            if(i_sw(j,k,l).gt.0) then !{
c*** divide found
              iz=iz+1
              if(iz.gt.nbndzon) then !{
                write(0,*) 'Too many boundary zones specified for ',
     ,                          hlp_txt(l)
                write(0,*) 'STOP ==> check "Boundary divides" in the ',
     ,                'DG model and parameter "nbndzon" in uinpcom.inc'
                call xerrab ('Too many boundary zones')
              end if !}
              lzpbndt(iz,m)=lrsbndt(k,m)
              lzrbndt(iz,m,1)=ix
              lzrbndt(iz,m,2)=j-1
              lrfbndt(iz,m)=k
              cznbndt(iz,m)=crgbndt(k,m)

c*** Specify the position-related data for B2 and Eirene input files
c!###{
c      print '(a,10i6)','j,iz,m,n1,n2,lzp,lzr,i_cr [1] = ',j,iz,m,n1,n2,
c     ,  lzpbndt(iz,m),lzrbndt(iz,m,1),lzrbndt(iz,m,2),
c     ,  i_cr(max(lzrbndt(iz,m,1),n1)),i_cr(min(lzrbndt(iz,m,2),n2))
c!###}
              jcpbnds(iz,m)=max(1,lzpbndt(iz,m))
              n=max(lzrbndt(iz,m,1),n1)
              jc1bnds(iz,m)=n+i_cr(n)
              n=min(lzrbndt(iz,m,2),n2)
              jc2bnds(iz,m)=n+i_cr(n)+1
              if(cznbndt(iz,m).eq.'S') then !{
                jdrbnds(iz,m)=-1
              else if(cznbndt(iz,m).eq.'N') then !}{
                jdrbnds(iz,m)=1
              else !}{
                write(0,*) 'Internal error in uinbndzn: wrong ',
     ,            'boundary code ',cznbndt(iz,m),' for side',m,
     ,                                          '  region',k,'  zone',iz
                call xerrab ('Wrong boundary code')
              end if !}
              cskbnds(iz,m)=cznbndt(iz,m)
              lcpbnds(iz,m)=lzpbndt(iz,m)
              lc1bnds(iz,m)=lzrbndt(iz,m,1)
              lc2bnds(iz,m)=lzrbndt(iz,m,2)
              ls1bnds(iz,m)=lc1bnds(iz,m)
              ls2bnds(iz,m)=lc2bnds(iz,m)
              if(ls1bnds(iz,m).eq.0 .or. (nncut.eq.4 .and.
     .           ls1bnds(iz,m).eq.nxcut1(2)+nzodv+1+1)) then !{
                ls1bnds(iz,m)=ls1bnds(iz,m)+1
              end if !}
              if(ls2bnds(iz,m).eq.nx+1 .or.
     .            (nncut.eq.4 .and.
     .             ls2bnds(iz,m).eq.nxcut1(2)+nzodv+1)) then !{
                ls2bnds(iz,m)=ls2bnds(iz,m)-1
              end if !}

              if(jc1bnds(iz,m).ge.jc2bnds(iz,m)) then !{
c*** Boundary zone consists of a single guard cell - reject it
                write(0,*) 'A boundary zone consists of a single ',
     ,                     'guard cell - skipped. Side',m,'  region',k,
     ,                     '  cell',lc2bnds(iz,m)

c             print *,'m,k,iz,ix,jc1,jc2 = ',m,k,iz,ix,         !###
c     ,                             jc1bnds(iz,m),jc2bnds(iz,m) !###

                iz=iz-1
              else !}{
                ix=j
              end if !}
            end if !}
          end do !}
          if(ix.le.lrpbndt(k,m,2)) then !{
            iz=iz+1
            if(iz.gt.nbndzon) then !{
              write(0,*) 'Too many boundary zones specified for ',
     ,                                                        hlp_txt(l)
              write(0,*) 'STOP ==> check "Boundary divides" in the DG ',
     ,                   'model and parameter "nbndzon" in uinpcom.inc'
              call xerrab ('Too many boundary zones')
            end if !}
            lzpbndt(iz,m)=lrsbndt(k,m)
            lzrbndt(iz,m,1)=ix
            lzrbndt(iz,m,2)=lrpbndt(k,m,2)
            lrfbndt(iz,m)=k
            cznbndt(iz,m)=crgbndt(k,m)

c*** Specify the position-related data for B2 and Eirene input files
c!###{
c      print '(a,10i6)','j,iz,m,n1,n2,lzp,lzr,i_cr [2] = ',j,iz,m,n1,n2,
c     ,  lzpbndt(iz,m),lzrbndt(iz,m,1),lzrbndt(iz,m,2),
c     ,  i_cr(max(lzrbndt(iz,m,1),n1)),i_cr(min(lzrbndt(iz,m,2),n2))
c!###}
            jcpbnds(iz,m)=max(1,lzpbndt(iz,m))
            n=max(lzrbndt(iz,m,1),n1)
            jc1bnds(iz,m)=n+i_cr(n)
            n=min(lzrbndt(iz,m,2),n2)
            jc2bnds(iz,m)=n+i_cr(n)+1
            if(cznbndt(iz,m).eq.'S') then !{
              jdrbnds(iz,m)=-1
            else if(cznbndt(iz,m).eq.'N') then !}{
              jdrbnds(iz,m)=1
            else !}{
              write(0,*) 'Internal error in uinbndzn: wrong boundary ',
     ,          'code ',cznbndt(iz,m),' for side',m,'region',k,
     ,                      ' zone',iz
              call xerrab ('Wrong boundary code')
            end if !}
            cskbnds(iz,m)=cznbndt(iz,m)
            lcpbnds(iz,m)=lzpbndt(iz,m)
            lc1bnds(iz,m)=lzrbndt(iz,m,1)
            lc2bnds(iz,m)=lzrbndt(iz,m,2)
            ls1bnds(iz,m)=lc1bnds(iz,m)
            ls2bnds(iz,m)=lc2bnds(iz,m)
            if(ls1bnds(iz,m).eq.0 .or. (nncut.eq.4 .and.
     .         ls1bnds(iz,m).eq.nxcut1(2)+nzodv+1+1)) then !{
              ls1bnds(iz,m)=ls1bnds(iz,m)+1
            end if !}
            if(ls2bnds(iz,m).eq.nx+1 .or.
     .          (nncut.eq.4 .and.
     .             ls2bnds(iz,m).eq.nxcut1(2)+nzodv+1)) then !{
              ls2bnds(iz,m)=ls2bnds(iz,m)-1
            end if !}

            if(jc1bnds(iz,m).ge.jc2bnds(iz,m)) then !{
c*** Boundary zone consists of a single guard cell - reject it
              write(0,*) 'A boundary zone consists of a single guard ',
     ,          'cell - skipped. Side',m,'  region',k,
     ,          '  cell',lc2bnds(iz,m)

c             print *,'m,k,iz,ix = ',m,k,iz,ix  !###

              iz=iz-1
              lzrbndt(iz,m,2)=lzrbndt(iz,m,2)+1
            end if !}
          end if !}
        end do !}
        nznbndt(m)=iz
      end do !}
c!###{
      print *,'Boundary zones: ',nznbndt
      print *
      print *,'knd  zone  ref pos  range  jdr jcp jc1 jc2 lcp lc1 lc2',
     ,  ' ls1 ls2'
      do k=1,nbndknd !{
        if (nznbndt(k).eq.0) cycle
        print *
        do j=1,nznbndt(k) !{
          print '(2i4,1x,a1,1x,13i4)',k,j,cznbndt(j,k),lrfbndt(j,k),
     ,      lzpbndt(j,k),lzrbndt(j,k,1),lzrbndt(j,k,2),jdrbnds(j,k),
     ,      jcpbnds(j,k),jc1bnds(j,k),jc2bnds(j,k),lcpbnds(j,k),
     ,      lc1bnds(j,k),lc2bnds(j,k),ls1bnds(j,k),ls2bnds(j,k)
        end do !}
      end do !}
      print *
c!###}
c=======================================================================
      call subend ()
      return
      end
