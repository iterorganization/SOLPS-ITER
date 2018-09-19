      subroutine uinprppt
      use b2mod_elements
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
      implicit none

c  version : 27.12.2004 23:24

c======================================================================
c*** Prepare the particle lists
c======================================================================
#include "uinput.inc"
      integer i,ii,iii,j,jj,jjj,k,l,m,mm,n,na,ni,nm,np,ipt
      integer find_matching_species, get_atomic_number, lnblnk
      logical ex,streql
      external streql, xerrab, subini, subend
      external find_matching_species, get_atomic_number, lnblnk
      character*8 c,cc,c0*1
      character*20 hlp_frm
c======================================================================
      call subini ('uinprppt')
      c0=char(0)

c*** Initialise the counters

      nspcncl=0
      nspcpls=0
      nspcatm=0
      nspcmol=0
      nspcion=0
      
c*** Check whether generic particles are specified, and make the lists
c*** We assume hereforth that there is a direct correspondence between
c*** the atoms and nuclei

      do l=1,nspigen  !{
        c=spcigen(l)
        if(.not.streql(c,' ') .and. c(1:1).ne.c0) then !{
          ex=.true.
          do i=1,nspcatm  !{
            if(streql(c,spcsatm(i))) ex=.false.
          end do      !}
          if(ex) then  !{
            k=find_matching_species(c)
            if(k.eq.0) then  !{
              write(hlp_frm,'(a,i2,a)') '(a,a8,a,a,',nspdgen,'(a1,a2))'
              write(*,hlp_frm) 'Generic species "',c,'" undefined. ',
     ,          'Available non-default species are:',
     ,           (' ',spcdgen(i),i=1,nspdgen-2)
              write(*,*) 'Otherwise should be an element name.'
              call xerrab ('  ==> Check the DivGeo species list')
            else  !}{
              j=lspdgen(k)
              na=nspcatm
              do m=0,nspdatm(k)-1 !{
                if (no_n2_model.and..not.no_n2(j+m)) cycle
                if (l_ammon(j+m).and..not.ammonx_used) cycle
                if (l_meta(j+m).and..not.meta_used) cycle
                if (k.le.nspdgen-2) c=spcdspc(j+m)
                ex=.false.
                do i=1,nspcatm !{
                  if(streql(c,spcsatm(i))) ex=.true.
                end do !}
                if(ex) then !{
                  write(0,*) 'Ambiguous atom name "',c,
     ,              '" - internal error in UINP!!!'
                  call xerrab ('Ambiguous atom name')
                end if  !}
                na=na+1
                if(na.gt.natm) then !{
                  write(0,*) 'The number of atomic species must ',
     ,              'not exceed ',natm
                  write(0,*) 'Current requested number of atomic ',
     ,              'species is ',na
                  write(0,*) 'STOP ==> Check the AMDS model - or ',
     ,              'increase DEF_NATM in DIMENSIONS.F'
                  call xerrab ('Too many atomic species')
                end if !}
                if(.not.l_meta(j+m)) then
                  nspcncl=nspcncl+1
                  if(nspcpls+nspcncl.gt.nsdb2) then !{
                    write(0,*) 'The total number of B2.5 species must ',
     ,               'not exceed ',nsdb2
                    write(0,*) 'Current requested number of B2.5 ',
     ,               'species is ',nspcpls+nspcncl
                    write(0,*) 'STOP ==> Check the AMDS model - ',
     ,               'or increase DEF_NSD in DIMENSIONS.F'
                    call xerrab ('Too many B2.5 species')
                  end if !}
                  spcsncl(nspcncl)=c
                end if
                spcsrna(na)=na
                spcsatm(na)=c
                is_meta(na)=l_meta(j+m)
                if (l_meta(j+m)) nmeta=nmeta+1
                if (k.le.nspdgen-2) then !{
                  spcsrfa(na)=spcdrfl(j+m)
                  spcsrta(na)=spcdrtl(j+m)
                  spcsmsa(na)=spcdms(j+m)
                  spcsnca(na)=spcdnc(j+m)
                  spcscga(na)=spcdcg(j+m)
                  spcsfua(na)=spcdfu(j+m)
                else if (k.eq.nspdgen-1) then !}{
                  spcsrfa(na)=c
                  spcsrta(na)=c
                  spcsmsa(na)=nuclear_mass(get_atomic_number(c))
                  spcsnca(na)=get_atomic_number(c)
                  spcscga(na)=0
                  spcsfua(na)=1
                else if (k.eq.nspdgen) then !}{
                  spcsrfa(na)=' '
                  spcsrta(na)=' '
                  spcsmsa(na)=nuclear_mass(get_atomic_number(c))
                  spcsnca(na)=get_atomic_number(c)
                  spcscga(na)=0
                  spcsfua(na)=1
                end if !}
                if(.not.streql(spcsrfa(na),' ') .and.
     &             .not.streql(spcsrfa(na),c0)) then !{
                  spcsrsa(na)=1
                else !}{
                  spcsrsa(na)=-1
                end if !}
                datm(na)=1
              end do !}
              j=j+nspdatm(k)-1

              nm=nspcmol
              do m=1,nspdmol(k) !{
                if (no_n2_model.and..not.no_n2(j+m)) cycle
                if (l_ammon(j+m).and..not.ammonx_used) cycle
                if (l_meta(j+m).and..not.meta_used) cycle
                c=spcdspc(j+m)
                ex=.false.
                do i=1,nspcmol !{
                  if(streql(c,spcsmol(i))) ex=.true.
                end do !}
                if(ex) then !{
                  write(0,*) 'Ambiguous molecule name "',c,
     ,              '" - internal error in UINP!!!'
                  call xerrab ('Ambiguous molecule name')
                end if  !}
                nm=nm+1
                if(nm.gt.nmol) then !{
                  write(0,*) 'The number of molecular species must ',
     ,              'not exceed ',nmol
                  write(0,*) 'Current requested number of molecular ',
     ,              'species is ',nm
                  write(0,*) 'STOP ==> Check the AMDS model - or ',
     ,              'increase DEF_NMOL in DIMENSIONS.F'
                  call xerrab ('Too many molecular species')
                end if !}
                spcscmm(nspcncl,nm)=spcdfu(j+m)
                ipt=0
                cc=c
                spcsrfm(nm)=spcdrfl(j+m)
                spcsrtm(nm)=spcdrtl(j+m)
                spcsmsm(nm)=spcdms(j+m)
                do ii=1,na !{
                  if(streql(spcsatm(ii),spcdspc(lspdgen(k)))) then !{
                    lkindm(nm)=ii
                  end if !}
                end do !}
                do ii=1,nspcatm !{
                  do jj=1,m_hlp_h !{
                    if(streql(spcsatm(ii),hlp_h(1,jj,1))) then !{
                      if (ipt.eq.0) ipt=jj
                    end if !}
                  end do !}
                end do !}
                if (ipt.gt.0) then !{
                  do ii=1,n_hlp_h !{
                    do jj=1,m_hlp_h !{
                      if(streql(c,hlp_h(ii,jj,2))) then !{
                        cc=hlp_h(ii,ipt,1)
                        spcsmsm(nm)=spcdms(j+m)+(ipt-1)*hlp_h_m(ii)
                        do iii=1,n_hlp_h !{
                          if(streql(spcdrfl(j+m),hlp_h(iii,1,2)))
     >                      spcsrfm(nm)=hlp_h(iii,ipt,1)
                          if(streql(spcdrtl(j+m),hlp_h(iii,1,2)))
     >                      spcsrtm(nm)=hlp_h(iii,ipt,1)
                        end do !}
                      end if !}
                    end do !}
                  end do !}
                end if !}
                spcsmol(nm)=cc
                spcsncm(nm)=spcdnc(j+m)
                spcscgm(nm)=spcdcg(j+m)
                spcsfum(nm)=spcdfu(j+m)
                spcsrsm(nm)=0
                dmol(nm)=1
              end do  !}
              j=j+nspdmol(k)

              ni=nspcion
              do m=1,nspdion(k) !{
                if (no_n2_model.and..not.no_n2(j+m)) cycle
                if (l_ammon(j+m).and..not.ammonx_used) cycle
                if (l_meta(j+m).and..not.meta_used) cycle
                c=spcdspc(j+m)
                ex=.false.
                do i=1,nspcion  !{
                  if(streql(c,spcsion(i))) ex=.true.
                end do  !}
                if(ex) then !{
                  write(0,*) 'Ambiguous test ion name "',c,
     ,              '" - internal error in UINP!!!'
                  call xerrab ('Ambiguous test ion name')
                end if  !}
                ni=ni+1
                if(ni.gt.nion) then !{
                  write(0,*) 'The number of test ion species must ',
     ,              'not exceed ',nion
                  write(0,*) 'Current requested number of test ion ',
     ,              'species is ',ni
                  write(0,*) 'STOP ==> Check the AMDS model - or ',
     ,              'increase DEF_NION in DIMENSIONS.F'
                  call xerrab ('Too many test ion species')
                end if !}
                spcscmi(nspcncl,ni)=spcdfu(j+m)
                ipt=0
                cc=c
                spcsrfi(ni)=spcdrfl(j+m)
                spcsrti(ni)=spcdrtl(j+m)
                spcsmsi(ni)=spcdms(j+m)
                do ii=1,na !{
                  if(streql(spcsatm(ii),spcdspc(lspdgen(k))))
     >             lkindi(ni)=ii
                end do !}
                do ii=1,nspcatm !{
                  do jj=1,m_hlp_h !{
                    if(streql(spcsatm(ii),hlp_h(1,jj,1))) then !{
                      if (ipt.eq.0) ipt=jj
                    end if !}
                  end do !}
                end do !}
                if (ipt.gt.0) then !{
                  do ii=1,n_hlp_h !{
                    do jj=1,m_hlp_h !{
                      if(streql(c,hlp_h(ii,jj,2))) then !{
                        cc=hlp_h(ii,ipt,1)
                        spcsmsi(ni)=spcdms(j+m)+(ipt-1)*hlp_h_m(ii)
                        do iii=1,n_hlp_h !{
                          do jjj=1,m_hlp_h !{
                            if(streql(spcdrfl(j+m),hlp_h(iii,jjj,2)))
     >                        spcsrfi(ni)=hlp_h(iii,ipt,1)
                            if(streql(spcdrtl(j+m),hlp_h(iii,jjj,2)))
     >                        spcsrti(ni)=hlp_h(iii,ipt,1)
                          end do !}
                        end do !}
                      end if !}
                    end do !}
                  end do !}
                end if !}
                spcsion(ni)=cc
                spcsnci(ni)=spcdnc(j+m)
                spcscgi(ni)=spcdcg(j+m)
                spcsfui(ni)=spcdfu(j+m)
                spcsrsi(ni)=0
                dion(ni)=1
              end do  !}
              j=j+nspdion(k)

              np=nspcpls
              if (k.le.nspdgen-2) then !{
                mm=nspdpls(k)
              else !}{
                mm=get_atomic_number(spcigen(l))
              end if !}
              do m=1,mm !{
                c=repeat(' ',8)
                if (k.le.nspdgen-2) then !{
                  c=spcdspc(j+m)
                else !}{
                  if (lnblnk(spcigen(l)).eq.1) then !{
                    if (m.eq.1) then !{
                      c=spcigen(l)(1:1)//'+'
                    else if (m.eq.2) then !}{
                      c=spcigen(l)(1:1)//'++'
                    else if (m.le.9) then !}{
                      write(c,'(a1,i1,a1)') spcigen(l),m,'+'
                    else !}{
                      write(c,'(a1,i2,a1)') spcigen(l),m,'+'
                    end if !}
                  else !}{
                    if (m.eq.1) then !{
                      c=spcigen(l)(1:2)//'+'
                    else if (m.eq.2) then !}{
                      c=spcigen(l)(1:2)//'++'
                    else if (m.le.9) then !}{
                      write(c,'(a2,i1,a1)') spcigen(l),m,'+'
                    else !}{
                      write(c,'(a2,i2,a1)') spcigen(l),m,'+'
                    end if !}
                  endif !}
                end if !}
                ex=.false.
                do i=1,nspcpls  !{
                  if(streql(c,spcspls(i))) ex=.true.
                end do  !}
                if(ex) then !{
                  write(0,*) 'Ambiguous plasma ion name "',c,
     ,              '" - internal error in UINP !!!'
                  call xerrab ('Ambiguous plasma ion name')
                end if  !}
                np=np+1
                if(np.gt.npls) then !{
                  write(0,*) 'The number of plasma species must ',
     ,              'not exceed ',npls
                  write(0,*) 'Current requested number of plasma ',
     ,              'species is ',np
                  write(0,*) 'STOP ==> Check the AMDS model - or ',
     ,              'increase DEF_NPLS in DIMENSIONS.F'
                  call xerrab ('Too many plasma species')
                end if !}
                spcsrnp(np)=nspcncl
                spcspls(np)=c
                if (k.le.nspdgen-2) then !{
                  spcsrfp(np)=spcdrfl(j+m)
                  spcsrtp(np)=spcdrtl(j+m)
                  spcsmsp(np)=spcdms(j+m)
                  spcsncp(np)=spcdnc(j+m)
                  spcscgp(np)=spcdcg(j+m)
                  spcsfup(np)=spcdfu(j+m)
                else if (k.eq.nspdgen-1) then !}{
                  spcsrfp(np)=spcigen(l)
                  spcsrtp(np)=spcigen(l)
                  spcsmsp(np)=nuclear_mass(mm)
                  spcsncp(np)=mm
                  spcscgp(np)=m
                  spcsfup(np)=1
                else if (k.eq.nspdgen) then !}{
                  spcsrfp(np)=' '
                  spcsrtp(np)=' '
                  spcsmsp(np)=nuclear_mass(mm)
                  spcsncp(np)=mm
                  spcscgp(np)=m
                  spcsfup(np)=1
                end if !}
                if(.not.streql(spcsrfp(np),' ') .and.
     &             .not.streql(spcsrfp(np),c0)) then !{
                  spcsrsp(np)=1
                else !}{
                  spcsrsp(np)=-1
                end if !}
                dpls(np)=1./mm
              end do  !}
              j=j+mm

              nspcatm=na
              nspcmol=nm
              nspcion=ni
              nspcpls=np

              spcscrk(na)=spcicrk(l)
              spcscrp(na)=spcicrp(l)
              spcscrf(na)=spcicrf(l)
              spcsscn(na)=spciscn(l)
#ifdef DBG
              print '(a,4i5,1p,2e12.5)',
     ,                 'uinprppt: l,na,scn,crk,crp,crf=',l,na,
     ,                  spcsscn(na),spcscrk(na),spcscrp(na),spcscrf(na)
#endif
            end if  !}
          else  !}{
            write(*,*) 'A generic species "',c,'" has already been ',
     ,        'added (skipping it)'
          end if  !}
        end if  !}
      end do  !}
c-----------------------------------------------------------------------
c*** Add particular species, if any, to the lists.
c*** Atoms:

      do l=1,nspiatm  !{
        c=spciatm(l)
        if(.not.streql(c,' ') .and. c(1:1).ne.c0) then !{
          ex=.true.
          do i=1,nspcatm  !{
            if(streql(c,spcsatm(i))) ex=.false.
          end do      !}
          if(ex) then  !{
            nspcatm=nspcatm+1
            if(nspcatm.gt.natm) then !{
              write(0,*) 'The number of atomic species must not ',
     ,          'exceed ',natm
              write(0,*) 'Current requested number of atomic ',
     ,          'species is ',nspcatm
              write(0,*) 'STOP ==> Check the AMDS model - or increase ',
     ,          'DEF_NATM in DIMENSIONS.F'
              call xerrab ('Too many atomic species')
            end if !}
            nspcncl=nspcatm
            spcsncl(nspcatm)=c
            spcsrna(nspcatm)=nspcncl
            spcsatm(nspcatm)=c
            spcsrfa(nspcatm)=spcirfa(l)
            spcsrta(nspcatm)=spcirta(l)
            spcsmsa(nspcatm)=spcimsa(l)
            spcsnca(nspcatm)=spcinca(l)
            spcscga(nspcatm)=spcicga(l)
c            spcsfua(nspcatm)=spcifua(l)
            spcsfua(nspcatm)=1
            spcsrsa(nspcatm)=spcirsa(l)
            datm(nspcatm)=spcidsa(l)
          else  !}{
            write(*,*) 'An atomic species "',c,'" has already been ',
     ,        'added - skipping it'
          end if  !}
        end if  !}
      end do  !}

c*** Molecules:

      do l=1,nspimol  !{
        c=spcimol(l)
        if(.not.streql(c,' ') .and. c(1:1).ne.c0) then !{
          ex=.true.
          do i=1,nspcmol  !{
            if(streql(c,spcsmol(i))) ex=.false.
          end do      !}
          if(ex) then  !{
            nspcmol=nspcmol+1
            if(nspcmol.gt.nmol) then !{
              write(0,*) 'The number of molecular species must ',
     ,          'not exceed ',nmol
              write(0,*) 'Current requested number of molecular ',
     ,          'species is ',nspcmol
              write(0,*) 'STOP ==> Check the AMDS model - or increase ',
     ,          'DEF_NMOL in DIMENSIONS.F'
              call xerrab ('Too many molecular species')
            end if !}
            n=0
            do k=1,spcinnm(l) !{
              cc=spcirnm(k,l)
              j=0
              do i=1,nspcncl !{
                if(j.eq.0) then !{
                  if(streql(cc,spcsncl(i))) j=i
                end if !}
              end do !}
              if(j.eq.0) then !{
                write(0,*) 'Nucleus ',cc,' specified for molecule ',c,
     ,            ' - not found'
              else !}{
                spcscmm(j,l)=spcicmm(k,l)
                n=n+spcicmm(k,l)
              end if !}
            end do !}
            spcsmol(nspcmol)=c
            spcsrfm(nspcmol)=spcirfm(l)
            spcsrtm(nspcmol)=spcirtm(l)
            spcsmsm(nspcmol)=spcimsm(l)
            spcsncm(nspcmol)=spcincm(l)
            spcscgm(nspcmol)=spcicgm(l)
c            spcsfum(nspcmol)=spcifum(l)
            spcsfum(nspcmol)=n
            spcsrsm(nspcmol)=spcirsm(l)
            dmol(nspcmol)=spcidsm(l)
          else  !}{
            write(*,*) 'A molecular species "',c,'" has already been ',
     ,        'added - skipping it'
          end if  !}
        end if  !}
      end do  !}

c*** Test ions:

      do l=1,nspiion  !{
        c=spciion(l)
        if(.not.streql(c,' ') .and. c(1:1).ne.c0) then !{
          ex=.true.
          do i=1,nspcion  !{
            if(streql(c,spcsion(i))) ex=.false.
          end do      !}
          if(ex) then  !{
            nspcion=nspcion+1
            if(nspcion.gt.nion) then !{
              write(0,*) 'The number of test ion species must ',
     ,          'not exceed ',nion
              write(0,*) 'Current requested number of test ion ',
     ,          'species is ',nspcion
              write(0,*) 'STOP ==> Check the AMDS model - or increase ',
     ,          'DEF_NION in DIMENSIONS.F'
              call xerrab ('Too many test ion species')
            end if !}
            n=0
            do k=1,spcinni(l) !{
              cc=spcirni(k,l)
              j=0
              do i=1,nspcncl !{
                if(j.eq.0) then !{
                  if(streql(cc,spcsncl(i))) j=i
                end if !}
              end do !}
              if(j.eq.0) then !{
                write(0,*) 'Nucleus ',cc,' specified for test ion ',c,
     ,            ' - not found'
              else !}{
                spcscmi(j,l)=spcicmi(k,l)
                n=n+spcicmi(k,l)
              end if !}
            end do !}
            spcsion(nspcion)=c
            spcsrfi(nspcion)=spcirfi(l)
            spcsrti(nspcion)=spcirti(l)
            spcsmsi(nspcion)=spcimsi(l)
            spcsnci(nspcion)=spcinci(l)
            spcscgi(nspcion)=spcicgi(l)
            spcsfui(nspcion)=n
            spcsrsi(nspcion)=spcirsi(l)
            dion(nspcion)=spcidsi(l)
          else  !}{
            write(*,*) 'A test ion species "',c,'" has already been ',
     ,        'added - skipping it'
          end if  !}
        end if  !}
      end do  !}

c*** Plasma ions:

      do l=1,nspipls  !{
        c=spcipls(l)
        if(.not.streql(c,' ') .and. c(1:1).ne.c0) then !{
          ex=.true.
          do i=1,nspcpls  !{
            if(streql(c,spcspls(i))) ex=.false.
          end do      !}
          if(ex) then  !{
            nspcpls=nspcpls+1
            if(nspcpls.gt.npls) then !{
              write(0,*) 'The number of plasma ion species must ',
     ,          'not exceed ',npls
              write(0,*) 'Current requested number of atomic ',
     ,          'species is ',nspcpls
              write(0,*) 'STOP ==> Check the AMDS model - or increase ',
     ,          'DEF_NPLS in DIMENSIONS.F'
              call xerrab ('Too many plasma ion species')
            end if !}
            if(nspcpls+nspcncl.gt.nsdb2) then !{
              write(0,*) 'The total number of B2.5 species must ',
     ,          'not exceed ',nsdb2
              write(0,*) 'Current requested number of B2.5 ',
     ,          'species is ',nspcpls+nspcncl
              write(0,*) 'STOP ==> Check the AMDS model - or increase ',
     ,          'DEF_NSD in DIMENSIONS.F'
              call xerrab ('Too many B2.5 species')
            end if !}
            cc=spcirnp(l)
            j=0
            do i=1,nspcncl !{
              if(j.eq.0) then !{
                if(streql(cc,spcsncl(i))) j=i
              end if !}
            end do !}
            if(j.eq.0) then !{
              write(0,*) 'Nucleus ',cc,' specified for plasma ion ',c,
     ,          ' - not found'
            end if !}
            spcsrnp(nspcpls)=j
            spcspls(nspcpls)=c
            spcsrfp(nspcpls)=spcirfp(l)
            spcsrtp(nspcpls)=spcirtp(l)
            spcsmsp(nspcpls)=spcimsp(l)
            spcsncp(nspcpls)=spcincp(l)
            spcscgp(nspcpls)=spcicgp(l)
            spcsfup(nspcpls)=1
            spcsrsp(nspcpls)=spcirsp(l)
            dpls(nspcpls)=spcidsp(l)
          else  !}{
            write(*,*) 'A plasma ion species "',c,'" has already been ',
     ,        'added - skipping it'
          end if  !}
        end if  !}
      end do  !}
c!#{
c      print *
c      print *,'nspcatm nspcmol nspcion nspcpls'
c      print '(1x,i4,3i8)',nspcatm,nspcmol,nspcion,nspcpls
c      if(nspcatm.gt.0) then !{
c        print '(1x,a12,2(1x,a2,10x),5(2x,a2,2x),4x,a2,4x)',
c     ,    'Atoms:','rf','rt','ms','nc','cg','fu','rs','ds'
c        do i=1,nspcatm !{
c          print '(3a13,i4,4i6,1p,e10.2)',spcsatm(i),spcsrfa(i),
c     ,      spcsrta(i),spcsmsa(i),spcsnca(i),spcscga(i),spcsfua(i),
c     ,      spcsrsa(i),datm(i)
c        end do !}
c      end if  !}        
c      if(nspcmol.gt.0) then !{
c        print '(1x,a12,2(1x,a2,10x),5(2x,a2,2x),4x,a2,4x)',
c     ,    'Molecules:  ','rf','rt','ms','nc','cg','fu','rs','ds'
c        do i=1,nspcmol !{
c          print '(3a13,i4,4i6,1p,e10.2)',spcsmol(i),spcsrfm(i),
c     ,      spcsrtm(i),spcsmsm(i),spcsncm(i),spcscgm(i),spcsfum(i),
c     ,      spcsrsm(i),dmol(i)
c        end do !}
c      end if  !}        
c      if(nspcion.gt.0) then !{
c        print '(1x,a12,2(1x,a2,10x),5(2x,a2,2x),4x,a2,4x)',
c     ,    'Test ions:  ','rf','rt','ms','nc','cg','fu','rs','ds'
c        do i=1,nspcion !{
c          print '(3a13,i4,4i6,1p,e10.2)',spcsion(i),spcsrfi(i),
c     ,      spcsrti(i),spcsmsi(i),spcsnci(i),spcscgi(i),spcsfui(i),
c     ,      spcsrsi(i),dion(i)
c        end do !}
c      end if  !}        
c      if(nspcpls.gt.0) then !{
c        print '(1x,a12,4x,a2,11x,a2,7x,5(2x,a2,2x),4x,a2,4x)',
c     ,    'Plasma ions:','rf','rt','ms','nc','cg','fu','rs','ds'
c        do i=1,nspcpls !{
c          print '(3a13,i4,4i6,1p,e10.2)',spcspls(i),spcsrfp(i),
c     ,      spcsrtp(i),spcsmsp(i),spcsncp(i),spcscgp(i),spcsfup(i),
c     ,      spcsrsp(i),dpls(i)
c        end do !}
c      end if !}
c      print *        
c!#}
c-----------------------------------------------------------------------
c*** Produce the Eirene-style data for the species (except reactions)

      natmi=nspcatm
      do l=1,nspcatm !{
        texta(l)=spcsatm(l)
        nmassa(l)=spcsmsa(l)
        nchara(l)=spcsnca(l)
cank        nprta(l)=spcsfua(l)
cank        isrsa(l)=spcsrsa(l)

        k=0
        c=spcsrfa(l)
        if(.not.streql(c,' ')) then !{
          do i=1,nspcatm !{
            if(streql(c,spcsatm(i))) k=i
          end do !}
          if(k.eq.0) then !{
            do i=1,nspcion !{
              if(streql(c,spcsion(i))) k=-i
            end do !}
          end if !}
          if(k.eq.0) then !{
            write(0,*) 'Reflected fast particle not found: ',c,
     ,        ' for ',spcsatm(l)
          end if !}
          isrfa(l)=k
        else !}{
          isrfa(l)=0
        end if !}

        k=0
        c=spcsrta(l)
        if(.not.streql(c,' ')) then !{
          do i=1,nspcatm !{
            if(streql(c,spcsatm(i))) k=i
          end do !}
          if(k.eq.0) then !{
            do i=1,nspcmol !{
              if(streql(c,spcsmol(i))) k=-i
            end do !}
          end if !}
          if(k.eq.0) then !{
            write(0,*) 'Re-emitted thermal particle not found: ',c,
     ,        ' for ',spcsatm(l)
          end if !}
          isrta(l)=k
        else !}{
          isrta(l)=0
        end if !}
      end do !}

      nmoli=nspcmol
      do l=1,nspcmol !{
        textm(l)=spcsmol(l)
        nmassm(l)=spcsmsm(l)
        ncharm(l)=spcsncm(l)
        nprtm(l)=spcsfum(l)

        k=0
        c=spcsrtm(l)
        if(.not.streql(c,' ')) then !{
          do i=1,nspcmol !{
            if(streql(c,spcsmol(i))) k=i
          end do !}
          write(6,*) 'Molecule ',l,textm(l),spcsrtm(l),k
          if(k.eq.0) then !{
            write(0,*) 'Re-emitted thermal particle not found: ',c,
     ,        ' for ',spcsmol(l)
          end if !}
          isrtm(l)=k
        else !}{
          isrtm(l)=0
        end if !}
      end do !}

      nioni=nspcion
      do l=1,nspcion !{
        texti(l)=spcsion(l)
        nmassi(l)=spcsmsi(l)
        nchari(l)=spcsnci(l)
        nprti(l)=spcsfui(l)
        nchrgi(l)=spcscgi(l)
cank        isrsi(l)=spcsrsi(l)
        nfoli(l)=-1

        k=0
        c=spcsrfi(l)
        if(.not.streql(c,' ')) then !{
          do i=1,nspcatm !{
            if(streql(c,spcsatm(i))) k=i
          end do !}
          if(k.eq.0) then !{
            do i=1,nspcion !{
              if(streql(c,spcsion(i))) k=-i
            end do !}
          end if !}
          if(k.eq.0) then !{
            write(0,*) 'Reflected fast particle not found: ',c,
     ,        ' for ',spcsion(l)
          end if !}
          isrfi(l)=k
        else !}{
          isrfi(l)=0
        end if !}

        k=0
        c=spcsrti(l)
        if(.not.streql(c,' ')) then !{
          do i=1,nspcatm !{
            if(streql(c,spcsatm(i))) then !{
              k=i
            end if !}
          end do !}
          if(k.eq.0) then !{
            do i=1,nspcmol !{
              if(streql(c,spcsmol(i))) k=-i
            end do !}
          end if !}
          if(k.eq.0) then !{
            write(0,*) 'Re-emitted thermal particle not found: ',c,
     ,        ' for ',spcsion(l)
          end if !}
          isrti(l)=k
        else !}{
          isrti(l)=0
        end if !}
      end do !}

      nplsi=nspcpls
      nfla=nplsi
      do l=1,nspcpls !{
        textp(l)=spcspls(l)
        nmassp(l)=spcsmsp(l)
        ncharp(l)=spcsncp(l)
        nprtp(l)=spcsfup(l)
        nchrgp(l)=spcscgp(l)
cank        isrsp(l)=spcsrsp(l)
        bmass(l)=nmassp(l)
        if (l.eq.1) then !{
          lkindp(l)=1
        else if (bmass(l).eq.bmass(l-1) .and. 
     &           ncharp(l).eq.ncharp(l-1)) then !}{
          lkindp(l)=lkindp(l-1)
        else
          lkindp(l)=lkindp(l-1)+1
        endif !}
        iflb(l)=l

        k=0
        c=spcsrfp(l)
        if(.not.streql(c,' ')) then !{
          do i=1,nspcatm !{
            if(streql(c,spcsatm(i))) k=i
          end do !}
          if(k.eq.0) then !{
            do i=1,nspcion !{
              if(streql(c,spcsion(i))) k=-i
            end do !}
          end if !}
          if(k.eq.0) then !{
            write(0,*) 'Reflected fast particle not found: ',c,
     ,        ' for ',spcspls(l)
          end if !}
          isrfp(l)=k
        else !}{
          isrfp(l)=0
        end if !}

        k=0
        c=spcsrtp(l)
        if(.not.streql(c,' ')) then !{
          do i=1,nspcatm !{
            if(streql(c,spcsatm(i))) k=i
          end do !}
          if(k.eq.0) then !{
            do i=1,nspcmol !{
              if(streql(c,spcsmol(i))) k=-i
            end do !}
          end if !}
          if(k.eq.0) then !{
            write(0,*) 'Re-emitted thermal particle not found: ',c,
     ,        ' for ',spcspls(l)
          end if !}
          isrtp(l)=k
        else !}{
          isrtp(l)=0
        end if !}
      end do !}

      write(*,*)
      write(*,'(a,4i5)') 'Particle list: natmi,nmoli,nioni,nplsi =',
     ,                                   natmi,nmoli,nioni,nplsi
      write(*,*)
      if(natmi.gt.0) then !{
        write(*,'(1x,a12,10a8)') 'atoms      ','nmassa','nchara',' ',
     ,    ' ','isrfa','isrta','nmseca','nfola','ngena','spcsrna'
        do i=1,natmi !{
          write(*,'(a12,i7,9i8)') texta(i),nmassa(i),nchara(i),
     ,      1,0,isrfa(i),isrta(i),nmseca(i),nfola(i),ngena(i),spcsrna(i)
        end do !}
      end if !}
      if(nmoli.gt.0) then !{
        write(*,'(1x,a12,9a8)') 'molecules  ','nmassm','ncharm','nprtm',
     ,    'nchrgm','isrfm','isrtm','nmsecm','lkindm'
        do i=1,nmoli !{
          write(*,'(a12,i7,7i8)') textm(i),nmassm(i),ncharm(i),nprtm(i),
     ,      0,0,isrtm(i),nmsecm(i),lkindm(i)
        end do !}
      end if !}
      if(nioni.gt.0) then !{
        write(*,'(1x,a12,9a8)') 'test ions  ','nmassi','nchari','nprti',
     ,    'nchrgi','isrfi','isrti','nmseci','nfoli','lkindi'
        do i=1,nioni !{
          write(*,'(a12,i7,8i8)') texti(i),nmassi(i),nchari(i),nprti(i),
     ,      nchrgi(i),isrfi(i),isrti(i),nmseci(i),nfoli(i),lkindi(i)
        end do !}
      end if !}
      if(nplsi.gt.0) then !{
        write(*,'(1x,a12,9a8)') 'plasma ions','nmassp','ncharp','nprtp',
     ,    'nchrgp','isrfp','isrtp','nmsecp','spcsrnp'
        do i=1,nplsi !{
          write(*,'(a12,i7,8i8)') textp(i),nmassp(i),ncharp(i),nprtp(i),
     ,      nchrgp(i),isrfp(i),isrtp(i),nmsecp(i),spcsrnp(i)
        end do !}
      end if !}
      write(*,*)
c======================================================================
      call subend ()
      return
      end
