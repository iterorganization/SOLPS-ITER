      subroutine uinprpdg(lc)
      use b2mod_constants
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
c
c  version : 28.04.2003 23:32
c
c=======================================================================
c*** Prepare the data for the diagnostic Eirene run
c=======================================================================
      implicit none
      logical lc
#include "uinput.inc"
      integer i,j,k,l,m,iy,ix,ntcpu_b,nfile_b,npts_b(nstra),lntspec_b,
     ,  lntsput_b,nmcsput_b,ngwties_b,
     ,  nlstadds_b,nlstadu_b,mtreadds_b,
     ,  l_pfr,l_wll
      integer mesh_cell_ind
      logical ex,streql
      external streql, subini, subend, mesh_cell_ind
      real alloc_b,flux_b(nstra)
      save alloc_b,flux_b,
     ,  ntcpu_b,nfile_b,npts_b,lntspec_b,lntsput_b,nmcsput_b,ngwties_b,
     ,  nlstadds_b,nlstadu_b,mtreadds_b
c=======================================================================
      call subini ('uinprpdg')
      if(lc) then !{

        if(lntsptu.le.0) then !{
          lc=.false.
          call subend ()
          return
        end if !}

c*** Change to the new numeration and exclude "Elements not for Eirene"

        k=0
        do i=1,lntsptu !{
          j=indasrfe(listmtmp(i))
          if(j.gt.0) then !{
            k=k+1
            listmtmp(k)=j
          end if !}
        end do !}
        lntsptu=k

        if(lntsptu.le.0) then !{
          write(*,*) 'uinprpdg: no valid reference for material ',
     ,                             'template found - skipping diag2.eir'
          write(*,*) '==> Check the DG model: "Material templates" ',
     ,                   'cannot point to the "Elements not for Eirene"'
          lc=.false.
          call subend ()
          return
        end if !}
        
        iatspec=0
        do i=1,nspigen !{
          if(streql(spcigen(i),'H') .or. streql(spcigen(i),'D') .or.
     .       streql(spcigen(i),'T')) iatspec=i
        end do !}

        write(*,*) 'uinprpdg: ',lntsptu,' material templates'

c*** Save the variables to be changed

        ntcpu_b=ntcpu
        nfile_b=nfile
        alloc_b=alloc
        lntspec_b=lntspec
        lntsput_b=lntsput
        nmcsput_b=nmcsput
        nlstadds_b=nlstadds
        nlstadu_b=nlstadu
        mtreadds_b=mtreadds
        do i=1,nstrai !{
      	  npts_b(i)=npts(i)
      	  flux_b(i)=flux(i)
        end do !}

        ntcpu=dgntcpu
        nfile=dgnfile
        alloc=dgalloc
        lntspec=lntspcu
        lntsput=lntsptu
        nmcsput=nmcsptu
        do i=1,nstrai !{
      	  npts(i)=min(npts(i)*dgnptsfc,999999)
        end do !}
        do i=1,ngpfstr !{
          j=ingpfstr(i)
          flux(j)=qe*fgpfstr(i)
        end do !}
        if(txtmtra(1).ne.' ') then !{
          ex=.true.
          do i=1,natmi !{
            if (is_meta(i)) cycle
            if(ex) then !{
              if(streql(txtmtra(1),texta(i))) then !{
                ex=.false.
                j=nmassa(i)*100+nchara(i)
              end if !}
            end if !}
          end do !}
          if(ex) then !{
            write(*,*) 'uinprpdg: "Extra material" must belong to the ',
     ,                                         'species list - ignored!'
            write(*,*) '  Specified: ',txtmtra(1)
            write(*,*) '  List: ',(' ',texta(i),i=1,natmi)
            write(*,*) '  ==> Check the DG model'
            txtmtra(1)=' '
          else !}{
            do i=1,lntsput !{
              txtmtra(i)=txtmtra(1)
              listmtra(i)=j
            end do !}
          end if !}
        end if !}

c*** Prepare the lists of additional surfaces for output, if specified

        if(nlstadu.gt.0) then !{
          call uinprpla
          nlstadds=nlstadu
          mtreadds=listmtra(1)
        end if !}

c*** Prepare the data on grid-wall ties, if specified

        if(ngwtiesi.gt.0) then !{
          ngwties_b=ngwties
          l_pfr=nrpfl
          l_wll=nrpfl+nrsol1
          if(lm_cnfg) l_pfr=-1
#ifdef DBG
  !###{ 
          print *
          print *,'Grid-wall ties'
          print *,'l_pfr,l_wll,nrpfl,nrsol1=',
     ,                                    l_pfr,l_wll,nrpfl,nrsol1
          print *,'izc1,izc2,izc3,izc4,izci,iztg=',
     ,                                    izc1,izc2,izc3,izc4,izci,iztg
          print *,'nzidv,nzodv,nzidv2,nzodv2,nx,ny=',
     ,                                  nzidv,nzodv,nzidv2,nzodv2,nx,ny
          print '(/1x,4a6)','k','iy','iz','kgwt' 
  !###}
#endif 
          do k=1,ngwtiesi !{
            if(mesh_cell_ind(kgwties(k),iy,ix).ne.0) then !{
              write(0,*) 'uinprpdg: incomprehencible cell index ',
     ,                                            kgwties(k),' for k=',k
              write(0,*) ' ==> could be an internal error in uinp - ',
     ,                                        'no ties specification!!!'
              ngwtiesi=0
            else !}{
              if(iy.le.l_pfr) then !{                             PFR?
                if(ix.gt.0 .and. ix.lt.izc1-1) then !{
                  kgwties(k)=nzidv+1-ix
                else if(izci.gt.0) then !}{
                  if(ix.ge.izc3 .and. ix.lt.izci) then !{
                    kgwties(k)=(izci-1)+2*ny+nzidv+nzodv+1-ix
                  else if(ix.ge.izci+3 .and. ix.lt.izc4) then !}{
                    kgwties(k)=(izci-1)+2*ny+nzidv+nzodv+nzidv2+1-ix
                  else if(ix.ge.izc2 .and. ix.lt.iztg) then !}{
                    kgwties(k)=nx+4*ny+nzidv+nzodv+nzidv2+nx-3+1-ix
                  else !}{
                    kgwties(k)=0
                  end if !}
                else !}{
                  if(ix.ge.izc2-1 .and. ix.lt.iztg-2) then !{
                    kgwties(k)=nx+2*ny+nzidv+nx+1-ix
                  else !}{
                    kgwties(k)=0
                  end if !}
                end if !}
              else if(iy.gt.l_wll) then !}{                 outer wall?
                if(izci.gt.0) then !{
                  if(ix.ge.izci+3) then !{
                    kgwties(k)=nx+nzidv+nzodv+nzidv2+3*ny+ix
                  else if(ix.gt.0 .and. ix.lt.izci) then !}{
                    kgwties(k)=nzidv+ny+ix
                  else !}{
                    kgwties(k)=0
                  end if !}
                else !}{
                  kgwties(k)=nzidv+ny+ix
                end if !}
              else !}{
                kgwties(k)=0
              end if !}
              if(kgwties(k).eq.0) write(0,*) 'uinprpdg: wrong ',
     ,          'position of a grid marker for a grid-wall tie. ',
     ,          'ix,iy= ',ix,iy
            end if !}
#ifdef DBG
            print '(1x,4i6)', k,iy,ix,kgwties(k)  !###
#endif 
          end do !}
        end if !}
        if(ngwtiesi.gt.0) then !{
          k=0
          do j=1,ngwtiesi !{
            if(kgwties(j).gt.0) then !{
              k=k+1
              l=0
              do i=1,mgwties(j) !{
                m=indasrfe(lgwties(i,j))
                if(m.gt.0) then !{
                  l=l+1
                  lgwties(l,k)=m
                end if !}
              end do !}
              if(l.gt.0) then !{
                kgwties(k)=kgwties(j)
                mgwties(k)=l
              else !}{
                k=k-1
              end if !}
            end if !}
          end do !}
          ngwties=k
        end if !}

c*** Set the VSP data for diag2.eir

        nsrfcls=nsrfclu(3)
        do k=1,abs(nsrfcls) !{
          msrfcls(k)=msrfclu(k,3)
          do i=1,msrfcls(k) !{
            lsrfcls(i,k)=lsrfclu(i,k,3)
          end do !}
        end do !}

      else !}{
        nsrfcls=0
        ntcpu=ntcpu_b
        nfile=nfile_b
        alloc=alloc_b
        lntspec=lntspec_b
        lntsput=lntsput_b
        nmcsput=nmcsput_b
        nlstadds=nlstadds_b
        nlstadu=nlstadu_b
        mtreadds=mtreadds_b
        ngwties=ngwties_b
        do i=1,nstrai !{
      	  npts(i)=npts_b(i)
      	  flux(i)=flux_b(i)
        end do !}
      end if !}
c=======================================================================
      call subend ()
      return
      end
