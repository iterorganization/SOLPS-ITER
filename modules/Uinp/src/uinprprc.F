      subroutine uinprprc
      use b2mod_elements
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
c
c  version : 17.02.2002 21:52
c
c======================================================================
c*** Prepare the reaction data for Eirene
c======================================================================
      implicit none
#include "uinput.inc"
      integer i,j,k,l,m,n,ic,ii,jj,kk,k0,k1,k2,k3,k4,
     ,  iib,iie,iir,ii1,ii2,
     ,  ipt,irc,m_rct,m_rcn,n_ptc,l_hlp(mreac),igd,ngn,nrc,jrc,niso,
     ,  ic0,ic9,ig,jspc,lknd,npass,nnn,nisotopes,gpass,group_found,
     ,  iii,kkk,nc,z
      logical ex,e_hlp
      real hlp_ee,hlp_eb,hlp_e1,hlp_e2,hlp_fr
      character*8 c,cc,ccc,c0*1,f_hlp*12
      logical h_collision, todo
      logical hlp_amds(natm+nmol+nion+npls), need_dflt
c*** hlp_h shows the species equivalent to the default ones
      integer n_hlp_h,m_hlp_h
      integer maxne, quote_count, iquote, iyear, ibundling
      parameter (n_hlp_h=6, m_hlp_h=3)
      character*4 hlp_h(n_hlp_h,m_hlp_h,2)
      character*256 adasfile
      character SUBDIRrec*4,SUBDIRion*4,SUBDIRcex*4
      character SUBDIRprb*4,SUBDIRplt*4,SUBDIRzav*4
      character SUBDIRpot*4
      character NEWDIRrec*4,NEWDIRion*4,NEWDIRcex*4
      character NEWDIRprb*4,NEWDIRplt*4,NEWDIRzav*4
      character NEWDIRpot*4
      character ES*2, EB*2, Bdescr*8
      character ZEILE*80
      integer ign(mreac,1+m_hlp_h)
      logical h_iso_used(m_hlp_h)
      integer find_matching_reagent, find_matching_species,
     ,        get_atomic_number, lnblnk
      logical streql, silent_open, isadigit, isplusorminus
      external xerrab, streql, subini, subend
      external find_matching_reagent, find_matching_species,
     ,         get_atomic_number, lnblnk, isadigit, isplusorminus
      external silent_open
      data hlp_h /
     /  'H', 'H+', 'H2', 'H2+', '2H', '2H+',
     ,  'D', 'D+', 'D2', 'D2+', '2D', '2D+',
     ,  'T', 'T+', 'T2', 'T2+', '2T', '2T+',
     ,  'H', 'H+', 'H2', 'H2+', '2H', '2H+',
     ,  'H', 'H+', 'H2', 'H2+', '2H', '2H+',
     ,  'H', 'H+', 'H2', 'H2+', '2H', '2H+'/
c======================================================================
      call subini ('uinprprc')
      c0=char(0)
      n_ptc=nspcatm+nspcmol+nspcion+nspcpls

      nisotopes=0
      h_iso_used=.false.
      do ipt=1,nspcatm !{
        do i=1,m_hlp_h !{
          if(streql(spcsatm(ipt),hlp_h(1,i,1))) then !{
            nisotopes=nisotopes+1
            h_iso_used(i) = .true.
          end if !}
        end do !}
      end do !}
      if (nisotopes.ne.1) then !{
        write(6,'(a,i1,a)')
     .   'This problem contains ',nisotopes,' hydrogenic isotopes'
      else !}{
        write(6,'(a,i1,a)')
     .   'This problem contains ',nisotopes,' hydrogenic isotope'
      end if !}

c*** In order to avoid group duplication:
c***  ngn is the number of non-zero groups treated,
c***  igd is the last group ID used,
c***  ign is the list of correspondence of the group IDs: 1-default,
c***                                                    2:4-used for passes 1:3

      igd=0
      ign=0

c*** Check whether reactions were specified. If not, take the defaults

      hlp_amds = .false.
      is_bundled = .false.
      do i = 1, nnrctn !{
        c=rctnptpr(i)
        l=get_atomic_number(c)
        cc=c
        do ii=1,n_hlp_h !{
          do jj=1,m_hlp_h !{
            if(streql(c,hlp_h(ii,jj,1))) cc=hlp_h(ii,jj,2)
          end do !}
        end do !}
        do ipt = 1, n_ptc !{
          if(ipt.le.nspcatm) then !{
            ccc=spcsatm(ipt)
          else if(ipt.le.nspcatm+nspcmol) then !}{
            ccc=spcsmol(ipt-nspcatm)
          else if(ipt.le.nspcatm+nspcmol+nspcion) then !}{
            ccc=spcsion(ipt-nspcatm-nspcmol)
          else !}{
            ccc=spcspls(ipt-nspcatm-nspcmol-nspcion)
          end if !}
          do ii=1,n_hlp_h !{
            do jj=1,m_hlp_h !{
              if(streql(ccc,hlp_h(ii,jj,1))) ccc=hlp_h(ii,jj,2)
            end do !}
          end do !}
          if (streql(cc,ccc)) hlp_amds(ipt)=.true.
        end do !}
      end do !}
      do ipt = 1, n_ptc
        if(ipt.le.nspcatm) then !{
          c=spcsatm(ipt)
        else if(ipt.le.nspcatm+nspcmol) then !}{
          c=spcsmol(ipt-nspcatm)
        else if(ipt.le.nspcatm+nspcmol+nspcion) then !}{
          c=spcsion(ipt-nspcatm-nspcmol)
        else !}{
          c=spcspls(ipt-nspcatm-nspcmol-nspcion)
        end if !}
      end do

      if(rctndflt.or..not.(all(hlp_amds))) then !{

        if (rctndflt) nnrctn=0

        do ipt=1,n_ptc !{
          ngn=0
          if(ipt.le.nspcatm) then !{
            c=spcsatm(ipt)
            z=0
          else if(ipt.le.nspcatm+nspcmol) then !}{
            c=spcsmol(ipt-nspcatm)
            z=0
          else if(ipt.le.nspcatm+nspcmol+nspcion) then !}{
            c=spcsion(ipt-nspcatm-nspcmol)
            z=spcscgi(ipt-nspcatm-nspcmol)
          else !}{
            c=spcspls(ipt-nspcatm-nspcmol-nspcion)
            z=spcscgp(ipt-nspcatm-nspcmol-nspcion)
          end if !}
          cc=' '
          ic=0
          do i=1,n_hlp_h !{
            do j=1,m_hlp_h !{
              if(streql(c,hlp_h(i,j,1))) then !{
                cc=hlp_h(i,j,2)
                ic=j
              end if !}
            end do !}
          end do !}
          if(streql(cc,' ')) cc=c
          l=find_matching_reagent(cc)
cxpb Add default reactions for missing atoms and singly charged species
cxpb from AMDS model
          need_dflt = .not.hlp_amds(ipt).and.l.ne.0.and.z.le.1
          if(l.gt.0.and.need_dflt) then !{
            do j=1,nnrctd(l) !{
cxpb We must do this for each isotope of the collision partner
              h_collision = .false.
              do i = 1, n_hlp_h
                h_collision = h_collision .or.
     .           streql(rctdptin(j,l),hlp_h(i,1,2))
              end do
cxpb Find out the number of passes to do
              if (.not.h_collision) then !{
                npass = 1
              else !}{
                npass = m_hlp_h
              end if !}
              gpass=0
              do nnn=1,npass !{
                if (.not.h_iso_used(nnn) .and. h_collision) cycle
                nnrctn=nnrctn+1
                gpass=gpass+1
                if(nnrctn.gt.mreac) then !{
                  write(0,*) 'Too many reaction datasets specified:',
     .                                                           nnrctn
                  call xerrab
     .             ('==> Check the AMDS model and NREAC in KOPPLDIM.F')
                end if !}
                ii=rctdgrp(j,l)
                if(ii.ne.0) then !{
                  k=0
                  group_found=0
                  i=1
                  do while (group_found.lt.gpass .and. i.le.ngn) !{
                    if(ii.eq.ign(i,1)) then !{
                      k=ign(i,1+gpass)
                      group_found=group_found+1
                    end if !}
                    i = i+1
                  end do !}
                  if(k.eq.0) then !{
                    ngn=ngn+1
                    igd=igd-1
                    ign(ngn,1)=ii
                    ii=igd
                    ign(ngn,1+gpass)=ii
                  else !}{
                    ii=k
                  end if !}
                end if !}

                rctngrp(nnrctn)=ii
                rctnmsp(nnrctn)=rctdmsp(j,l)
                rctntyp(nnrctn)=rctdtyp(j,l)
                rctndbs(nnrctn)=rctddbs(j,l)
                rctnchp(nnrctn)=rctdchp(j,l)
                rctniz(nnrctn)=1
                if (l.le.nsrctd-2) then !{
                  rctnrct(nnrctn)=rctdrct(j,l)
                  rctnpto1(nnrctn)=rctdpto1(j,l)
                  rctnmst(nnrctn)=rctdmst(j,l)
                  rctneln(nnrctn)=rctdeln(j,l)
                else !}{
                  nc = get_atomic_number(cc)
                  if (l.eq.nsrctd-1) then !{
                    rctnpto1(nnrctn)=
     .               elements(nc)(1:lnblnk(elements(nc)))//'+'
                  else if (l.eq.nsrctd) then !}{
                    rctnpto1(nnrctn)=elements(nc)
                  end if !}
                  rctnmst(nnrctn)=nuclear_mass(nc)
                  rctneln(nnrctn)=elements(nc)
                  if(silent_open(99,'ratadas.filelist',
     .             'data.local|modules/B2.5/Database',adasfile)) then !{
                    read(99,1028)
                    read(99,*) maxne
                    if (nc.gt.maxne) then !{
                       write(*,*) 'ADAStables: element number',nc,
     .                            'not supported!'
                       call xerrab ('Unsupported ADAS element')
                    endif !}
c     jump over the preceding lines
                    do i=1,nc-1 !{
                      read(99,*) SUBDIRrec,SUBDIRion,
     &                           SUBDIRcex,SUBDIRprb,
     &                           SUBDIRplt,SUBDIRzav,SUBDIRpot,ES
                    enddo !}
c     now read the relevant line
                    read(99,'(a80)') ZEILE
                    quote_count = 0
                    iquote = index(ZEILE,'''')
                    do while (iquote.gt.0) !{
                      quote_count=quote_count+1
                      if (index(ZEILE(iquote+1:80),'''').ne.0) then !{
                        iquote = index(ZEILE(iquote+1:80),'''') + iquote
                      else !}{
                        iquote = 0
                      endif !}
                    enddo !}
                    if (quote_count.eq.16) then !{
                      read(ZEILE,*) SUBDIRrec,SUBDIRion,
     &                              SUBDIRcex,SUBDIRprb,
     &                              SUBDIRplt,SUBDIRzav,SUBDIRpot,ES
                    else if (quote_count.eq.18) then !}{
                      read(ZEILE,*) SUBDIRrec,SUBDIRion,
     &                              SUBDIRcex,SUBDIRprb,
     &                              SUBDIRplt,SUBDIRzav,
     &                              SUBDIRpot,ES,Bdescr
                    else !}{
                      call xerrab
     .                 ('Incomplete line found in ratadas.filelist!')
                    endif !}
                    close(99)
                    if((SUBDIRrec.ne.'none') .and.
     &   (SUBDIRrec.eq.SUBDIRion .or. SUBDIRion.eq.'none') .and.
     &   (SUBDIRrec.eq.SUBDIRcex .or. SUBDIRcex.eq.'none') .and.
     &   (SUBDIRrec.eq.SUBDIRprb .or. SUBDIRprb.eq.'none') .and.
     &   (SUBDIRrec.eq.SUBDIRplt .or. SUBDIRplt.eq.'none') .and.
     &   (SUBDIRrec.eq.SUBDIRzav .or. SUBDIRzav.eq.'none') .and.
     &   (SUBDIRrec.eq.SUBDIRpot .or. SUBDIRpot.eq.'none') ) then !{
                      read(SUBDIRrec,*) iyear
                      if (iyear.gt.100) then !}
                        ibundling = mod(iyear,100)
                        iyear = iyear/100
                        if (ibundling.le.9) then !{
                          write(EB,'(a1,i1)') '0',ibundling
                        else !}{
                          write(EB,'(i2)') ibundling
                        endif !}
                      else !}{
                        ibundling = 0
                      endif !}
                      write(NEWDIRrec,'(i2,2x)') iyear
                      write(NEWDIRion,'(i2,2x)') iyear
                      write(NEWDIRcex,'(i2,2x)') iyear
                      write(NEWDIRprb,'(i2,2x)') iyear
                      write(NEWDIRplt,'(i2,2x)') iyear
                      write(NEWDIRzav,'(i2,2x)') iyear
                      write(NEWDIRpot,'(i2,2x)') iyear
                    else !}{
                      ibundling = 0
                      iyear = -1
                      NEWDIRrec = SUBDIRrec
                      NEWDIRion = SUBDIRion
                      NEWDIRcex = SUBDIRcex
                      NEWDIRprb = SUBDIRprb
                      NEWDIRplt = SUBDIRplt
                      NEWDIRzav = SUBDIRzav
                      NEWDIRpot = SUBDIRpot
                    endif !}
                    if (streql(rctdrct(j,l),'acd')) then !{
                      call xertst(.not.streql(NEWDIRrec,'none'),
     .                 'No ADAS recombination data!')
                      rctnrct(nnrctn)=trim(rctdrct(j,l))//NEWDIRrec
                    else if (streql(rctdrct(j,l),'scd')) then !}{
                      call xertst(.not.streql(NEWDIRion,'none'),
     .                 'No ADAS ionization data!')
                      rctnrct(nnrctn)=trim(rctdrct(j,l))//NEWDIRion
                    else if (streql(rctdrct(j,l),'plt')) then !}{
                      call xertst(.not.streql(NEWDIRplt,'none'),
     .                 'No ADAS energy loss per ionization data!')
                      rctnrct(nnrctn)=trim(rctdrct(j,l))//NEWDIRplt
                    else if (streql(rctdrct(j,l),'prb')) then !}{
                      call xertst(.not.streql(NEWDIRprb,'none'),
     .                 'No ADAS energy loss per recombination data!')
                      rctnrct(nnrctn)=trim(rctdrct(j,l))//NEWDIRprb
                    end if !}
                    call strip_spaces(rctnrct(nnrctn))
                    if (ibundling.gt.0) then
                      call xertst(.not.streql(NEWDIRzav,'none'),
     .                 'No ADAS bundling data!')
                      if (ipt.le.nspcatm) then
                        is_bundled(ipt) = .true.
                      else if (ipt.gt.nspcatm+nspcmol+nspcion .and.
     .                         ipt.le.nspcatm+nspcmol+nspcion+nspcpls)
     >                 then
                        do i = 1, nspcatm
                          if (nmassp(ipt-nspcatm-nspcmol-nspcion).eq.
     .                        nmassa(i) .and. nchara(i).eq.
     .                        ncharp(ipt-nspcatm-nspcmol-nspcion)) then
                            is_bundled(i) = .true.
                          end if
                        end do
                      end if
                    end if
                  else !}{
                    write(*,*) 'Could not find ADAS file list file!'
                    write(*,*) '=> Check the ADAS and AMDS models'
                    call xerrab ('File "ratadas.filelist" not found')
                  end if !}
                end if !}
                rctnptpr(nnrctn)=c
                rctnptin(nnrctn)=rctdptin(j,l)
                rctnpto2(nnrctn)=rctdpto2(j,l)
                if (nnn.gt.1) then !}{ D or T isotope reaction partners
                  do i=1,n_hlp_h !{
                    if(streql(rctdptin(j,l),hlp_h(i,nnn,2)))
     ,                        rctnptin(nnrctn)=hlp_h(i,nnn,1)
                    if(streql(rctdpto1(j,l),hlp_h(i,nnn,2)))
     ,                        rctnpto1(nnrctn)=hlp_h(i,nnn,1)
                  end do !}
                end if !}
                if(.not.streql(c,cc)) then !{ D or T isotope reactants
                  do i=1,n_hlp_h !{
                    if(streql(rctdpto2(j,l),hlp_h(i,ic,2)))
     ,                        rctnpto2(nnrctn)=hlp_h(i,ic,1)
                    if(streql(rctdpto1(j,l),hlp_h(i,ic,2)))
     ,                        rctnpto1(nnrctn)=hlp_h(i,ic,1)
                  end do !}
                end if !}
                if(streql(rctntyp(nnrctn),'CX').or.
     .             streql(rctntyp(nnrctn),'EL')) then !{
                  do i = 1,n_hlp_h !{
                    do kk = 1,m_hlp_h !{
                      if(streql(rctnptin(nnrctn),hlp_h(i,kk,1))) then !{
                        do ii = 1,n_hlp_h !{
                          do k = 1,m_hlp_h !{
                            if(streql(rctnpto1(nnrctn),hlp_h(ii,k,1)))
     ,                                rctnpto1(nnrctn)=hlp_h(ii,kk,1)
                          end do !}
                        end do !}
                      end if !}
                    end do !}
                  end do !}
                end if !}
                if (l.le.nsrctd-1 .or. j.eq.1) then !{
                  rctndlte(nnrctn)=rctddlte(j,l)
                else !}{
                  if(silent_open(99,'ionization_potentials',
     .               'data.local|modules/B2.5/Database',adasfile)) then !{
                    do i = 1, nc-1 !{
                      read(99,1028)
                    end do !}
                    read(99,*) rctndlte(nnrctn)
                    close(99)
                  else !}{
                    call xerrab
     .               ('Could not find ionization_potentials file!')
                  end if !}
                end if !}
                rctntmin(nnrctn)=rctdtmin(j,l)
                rctntmax(nnrctn)=rctdtmax(j,l)
                rctnenr1(nnrctn)=rctdenr1(j,l)
                rctnenr2(nnrctn)=rctdenr2(j,l)
              end do !} (npass)
            end do !} (j)
          end if !} (l)
        end do !}
      end if  !}
c<<<
c      print *
c      print *,'Draft reaction list:'
c      if(nnrctn.gt.0) print '(a9,a7,a5,a9,a3,3a9,3i3,1p,3e9.2)',
c     ,  (rctnptpr(i),rctndbs(i),rctnchp(i),rctnrct(i),rctntyp(i),
c     ,   rctnptin(i),rctnpto1(i),rctnpto2(i),rctngrp(i),rctnmsp(i),
c     ,    rctnmst(i),rctndlte(i),rctnenr1(i),rctnenr2(i),i=1,nnrctn)
c>>>
c*** Check the reaction type - must be assigned to each reaction
      do i=1,nnrctn !{
        if(streql(rctntyp(i),' ')) then !{
          write(0,*) 'Undefined reaction type found.'
          write(0,*) 'Error occurred treating reaction ',i
          write(0,*) 'STOP ==> check the AMDS model. If OK, then the ',
     ,      'AMDS file is corrupted - or an internal error in UINP'
          call xerrab ('Undefined reaction type')
        end if !}
      end do !}
c-----------------------------------------------------------------------
c*** Parse the multiple output particles, if any (e.g., 2H)

      ic0=ichar('0')
      ic9=ichar('9')
      ex=.false.
      do irc=1,nnrctn !{
        m=0
        do j=1,len(rctnpto1) !{
          k=ichar(rctnpto1(irc)(j:j))
          if((k.lt.ic0 .or. k.gt.ic9)
     ,      .and. rctnpto1(irc)(j:j).ne.' ' .and. m.eq.0) m=j
        end do !}
        if(m.eq.0) then !{
          if(streql(rctnpto1(irc),' ')) then !{
            rctnnmo1(irc)=0
          else !}{
            write(0,*) 'Wrong 1st output particle specification: ',
     ,                                                     rctnpto1(irc)
            write(0,*) 'Error occurred treating reaction ',irc
            ex=.true.
          end if !}
        else !}{
          if(m.gt.1) then !{
            write(f_hlp,'(2h(i,i1,1h))') m-1
            read(rctnpto1(irc),f_hlp) k
            rctnnmo1(irc)=max(1,k)
            rctnpto1(irc)=rctnpto1(irc)(m:len(rctnpto1))
          else !}{
            if(rctnnmo1(irc).le.0) rctnnmo1(irc)=1
          end if !}
        end if !} (m)
        if(rctnnmo1(irc).gt.9) then !{
          write(0,*) 'A repetition counter for an output particle in ',
     ,      'a reaction can only be one digit. Reaction ',irc
          ex=.true.
        end if !}

        m=0
        do j=1,len(rctnpto2) !{
          k=ichar(rctnpto2(irc)(j:j))
          if((k.lt.ic0 .or. k.gt.ic9)
     ,      .and. rctnpto2(irc)(j:j).ne.' ' .and. m.eq.0) m=j
        end do !}
        if(m.eq.0) then !{
          if(streql(rctnpto2(irc),' ')) then !{
            rctnnmo2(irc)=0
          else !}{
            write(0,*) 'Wrong 2nd output particle specification: ',
     ,                                                     rctnpto2(irc)
            write(0,*) 'Error occurred treating reaction ',irc
            ex=.true.
          end if !}
        else !}{
          if(m.gt.1) then !{
            write(f_hlp,'(2h(i,i1,1h))') m-1
            read(rctnpto2(irc),f_hlp) k
            rctnnmo2(irc)=max(1,k)
            rctnpto2(irc)=rctnpto2(irc)(m:len(rctnpto2))
          else !}{
            if(rctnnmo2(irc).le.0) rctnnmo2(irc)=1
          end if !}
        end if !} (m)
        if(rctnnmo2(irc).gt.9) then !{
          write(0,*) 'A repetition counter for an output particle in ',
     ,      'a reaction can only be one digit. Reaction ',irc
          ex=.true.
        end if !}

cxpb Now check if we need to rename some isotopes for AMDS reactions
        if(.not.rctndflt .and. nisotopes.eq.1) then !{

          do k=1,m_hlp_h !{
            if (h_iso_used(k)) ii=k
          end do
          call uinspcid(rctnptpr(irc),l,j)
          if(l.eq.-1) then !{
            do i=1,n_hlp_h !{
              do k=1,m_hlp_h !{
                if(streql(rctnptpr(irc),hlp_h(i,k,1))) then !{
                   rctnptpr(irc)=hlp_h(i,ii,1)
                end if !}
              end do !}
            end do !}
          end if !}
          call uinspcid(rctnptin(irc),l,j)
          if(l.eq.-1) then !{
            do i=1,n_hlp_h !{
              do k=1,m_hlp_h !{
                if(streql(rctnptin(irc),hlp_h(i,k,1))) then !{
                   rctnptin(irc)=hlp_h(i,ii,1)
                end if !}
              end do !}
            end do !}
          end if !}
          call uinspcid(rctnpto1(irc),l,j)
          if(l.eq.-1) then !{
            do i=1,n_hlp_h !{
              do k=1,m_hlp_h !{
                if(streql(rctnpto1(irc),hlp_h(i,k,1)))
     ,                    rctnpto1(irc)=hlp_h(i,ii,1)
              end do !}
            end do !}
          end if !}
          call uinspcid(rctnpto2(irc),l,j)
          if(l.eq.-1) then !{
            do i=1,n_hlp_h !{
              do k=1,m_hlp_h !{
                if(streql(rctnpto2(irc),hlp_h(i,k,1)))
     ,                    rctnpto2(irc)=hlp_h(i,ii,1)
              end do !}
            end do !}
          end if !}

        end if !}

      end do !} (irc)

c<<<
c      print *
c      print *,'Draft reaction list after parsing and renaming:'
c      if(nnrctn.gt.0) print '(a9,a7,a5,a9,a3,3a9,3i3,1p,3e9.2)',
c     ,  (rctnptpr(i),rctndbs(i),rctnchp(i),rctnrct(i),rctntyp(i),
c     ,   rctnptin(i),rctnpto1(i),rctnpto2(i),rctngrp(i),rctnmsp(i),
c     ,    rctnmst(i),rctndlte(i),rctnenr1(i),rctnenr2(i),i=1,nnrctn)
c>>>

      if(.not.rctndflt .and. nisotopes.gt.1) then !{ duplicate reactions

        ngn=maxval(rctngrp)

        nrc=nnrctn
        do irc=1,nnrctn !{ reactions with first partner an H isotope
          h_collision = .false.
          do i = 1, n_hlp_h !{
            do k = 1, m_hlp_h !{
              h_collision = h_collision .or.
     .         streql(rctnptpr(irc),hlp_h(i,k,1))
            end do !}
          end do !}
          if (.not.h_collision) cycle
          call uinspcid(rctnptpr(irc),l,j)
          if (l.eq.1) then !{
            todo = hlp_amds(j)
          else if (l.eq.2) then !}{
            todo = hlp_amds(nspcatm+j)
          else if (l.eq.3) then !}{
            todo = hlp_amds(nspcatm+nspcmol+j)
          else if (l.eq.4) then !}{
            todo = hlp_amds(nspcatm+nspcmol+nspcion+j)
          else if (l.eq.-1) then !}{
            todo = .true.
          else if (l.eq.0) then !}{
            todo = .false.
          end if !}
          if (.not.todo) cycle
          ccc=rctnptpr(irc)
          do i = 1, n_hlp_h !{
            niso = 0
            do k = 1, m_hlp_h !{
              if (streql(ccc,hlp_h(i,k,1))) then !{
                do j = 1, m_hlp_h !{
                  if (.not.h_iso_used(j)) cycle
                  niso = niso + 1
                  if (niso.gt.1) then !{
                    nrc = nrc+1
                    jrc = nrc
                  else !}{
                    jrc = irc
                  endif !}
                  if(nrc.gt.mreac) then !{
                    write(0,*) 'Too many reaction datasets specified:',
     .                                                           nrc
                    call xerrab
     .             ('==> Check the AMDS model and NREAC in KOPPLDIM.F')
                  end if !}
                  rctnptpr(jrc)=hlp_h(i,j,1)
                  if (jrc.ne.irc) then !{
                    rctndbs(jrc)=rctndbs(irc)
                    rctnchp(jrc)=rctnchp(irc)
                    rctnrct(jrc)=rctnrct(irc)
                    rctntyp(jrc)=rctntyp(irc)
                    rctngrp(jrc)=rctngrp(irc)
                    rctnmst(jrc)=rctnmst(irc)
                    rctnmsp(jrc)=rctnmsp(irc)
                    rctneln(jrc)=rctneln(irc)
                    rctniz(jrc)=rctniz(irc)
                  end if !}
                  do ii = 1, n_hlp_h !{
                    do kk = 1, m_hlp_h !{
                      if (streql(rctnpto1(irc),hlp_h(ii,kk,1))) then !{
                        rctnpto1(jrc)=hlp_h(ii,j,1)
                      end if !}
                      if (streql(rctnptin(irc),hlp_h(ii,kk,1))) then !{
                        rctnptin(jrc)=hlp_h(ii,j,1)
                      end if !}
                      if (streql(rctnpto2(irc),hlp_h(ii,kk,1)))
     .                  rctnpto2(jrc)=hlp_h(ii,j,1)
                    end do !}
                  end do !}
                  if (rctngrp(jrc).ne.0) then !{
                    ign(jrc,1)=rctngrp(jrc)
                    ign(jrc,1+k)=rctngrp(jrc)
                    do kk = 1, nrc !{
                      if (kk.eq.nrc .and. jrc.eq.irc) cycle
                      if (rctngrp(jrc).eq.ign(kk,1+k) .and.
     .                    rctnptpr(jrc).eq.rctnptpr(kk)) then !{
                        ign(jrc,1+j)=ign(kk,1+j)
                      end if !}
                    end do !}
                    if (ign(jrc,1+j).eq.0) then !{
                      ngn=ngn+1
                      ign(jrc,1+j)=ngn
                    end if !}
                    rctngrp(jrc)=ign(jrc,1+j)
                  end if !}
                  if (jrc.ne.irc) then !{
                    rctnnmo1(jrc)=rctnnmo1(irc)
                    rctnnmo2(jrc)=rctnnmo2(irc)
                    rctndlte(jrc)=rctndlte(irc)
                    rctnenr1(jrc)=rctnenr2(irc)
                    rctnenr2(jrc)=rctnenr2(irc)
                  end if !}
                end do !} j
              end if !}
            end do !} k
          end do !} i
        end do !} (irc)
        nnrctn=nrc

c<<<
c        print *
c        print *,
c     ,   'Draft reaction list after duplicating H-isotope primaries:'
c        if(nnrctn.gt.0) print '(a9,a7,a5,a9,a3,3a9,3i3,1p,3e9.2)',
c     ,    (rctnptpr(i),rctndbs(i),rctnchp(i),rctnrct(i),rctntyp(i),
c     ,     rctnptin(i),rctnpto1(i),rctnpto2(i),rctngrp(i),rctnmsp(i),
c     ,      rctnmst(i),rctndlte(i),rctnenr1(i),rctnenr2(i),i=1,nnrctn)
c>>>

        do irc=1,nnrctn !{ reactions with second partner an H isotope
          h_collision = .false.
          do i = 1, n_hlp_h !{
            do k = 1, m_hlp_h !{
              h_collision = h_collision .or.
     .         streql(rctnptin(irc),hlp_h(i,k,1))
            end do !}
          end do !}
          if (.not.h_collision) cycle
          ccc=rctnptin(irc)
          do i = 1, n_hlp_h !{
            niso = 0
            do k = 1, m_hlp_h !{
              if (streql(ccc,hlp_h(i,k,1))) then !{
                do j = 1, m_hlp_h !{
                  if (.not.h_iso_used(j)) cycle
                  niso = niso + 1
                  if (niso.gt.1) then !{
                    nrc = nrc+1
                    jrc = nrc
                  else !}{
                    jrc = irc
                  endif !}
                  if(nrc.gt.mreac) then !{
                    write(0,*) 'Too many reaction datasets specified:',
     .                                                           nrc
                    call xerrab
     .             ('==> Check the AMDS model and NREAC in KOPPLDIM.F')
                  end if !}
                  rctnptin(jrc)=hlp_h(i,j,1)
                  if (jrc.ne.irc) then !{
                    rctnptpr(jrc)=rctnptpr(irc)
                    rctndbs(jrc)=rctndbs(irc)
                    rctnchp(jrc)=rctnchp(irc)
                    rctnrct(jrc)=rctnrct(irc)
                    rctntyp(jrc)=rctntyp(irc)
                    rctnpto1(jrc)=rctnpto1(irc)
                    rctnpto2(jrc)=rctnpto2(irc)
                    rctngrp(jrc)=rctngrp(irc)
                    rctnmst(jrc)=rctnmst(irc)
                    rctnmsp(jrc)=rctnmsp(irc)
                    rctneln(jrc)=rctneln(irc)
                    rctniz(jrc)=rctniz(irc)
                  end if !}
                  do ii = 1, n_hlp_h !{
                    do kk = 1, m_hlp_h !{
                      if (streql(rctnpto2(irc),hlp_h(ii,kk,1)))
     .                  rctnpto2(jrc)=hlp_h(ii,j,1)
                    end do !}
                  end do !}
                  do ii = 1, n_hlp_h !{
                    do kk = 1, m_hlp_h !{
                      if (streql(rctnptin(jrc),hlp_h(ii,kk,1))) then !{
                        do iii = 1, n_hlp_h !{
                          do kkk = 1, m_hlp_h !{
                            if (streql(rctnpto1(jrc),hlp_h(iii,kkk,1)))
     .                                 rctnpto1(jrc)=hlp_h(iii,kk,1)
                          end do !}
                        end do !}
                      end if !}
                      if (streql(rctnptpr(jrc),hlp_h(ii,kk,1))) then !{
                        do iii = 1, n_hlp_h !{
                          do kkk = 1, m_hlp_h !{
                            if (streql(rctnpto2(jrc),hlp_h(iii,kkk,1)))
     .                                 rctnpto2(jrc)=hlp_h(iii,kk,1)
                          end do !}
                        end do !}
                      end if !}
                    end do !}
                  end do !}
                  if (rctngrp(irc).ne.0) then !{
                    if (irc.eq.jrc) then !{
                      do ii = 1, n_hlp_h !{
                        do kk = 1, m_hlp_h !{
                          if (streql(rctnptin(irc),hlp_h(ii,kk,1))) then !{
                            ign(irc,1)=rctngrp(irc)
                            ign(irc,1+kk)=rctngrp(irc)
                          end if !}
                        end do !}
                      end do !}
                    else !}{
                      do ii = 1, n_hlp_h !{
                        do kk = 1, m_hlp_h !{
                          if (streql(rctnptin(irc),hlp_h(ii,kk,1))) then !{
                            ign(jrc,1)=ign(irc,1)
                            ign(jrc,1+kk)=ign(irc,1+kk)
                          end if !}
                        end do !}
                      end do !}
                      do kk = 1, nrc !{
                        if (kk.eq.nrc .and. jrc.eq.irc) cycle
                        if (ign(jrc,1).eq.ign(kk,1) .and.
     .                      streql(rctnptin(jrc),rctnptin(kk)) .and.
     .                      streql(rctnptpr(jrc),rctnptpr(kk))) then !{
                          ign(jrc,1+j)=ign(kk,1+j)
                        end if !}
                      end do !}
                      if (ign(jrc,1+j).eq.0) then !{
                        ngn=ngn+1
                        ign(jrc,1+j)=ngn
                      end if !}
                      rctngrp(jrc)=ign(jrc,1+j)
                    end if !}
                  end if !}
                  rctnnmo1(jrc)=rctnnmo1(irc)
                  rctnnmo2(jrc)=rctnnmo2(irc)
                  rctndlte(jrc)=rctndlte(irc)
                  rctnenr1(jrc)=rctnenr2(irc)
                  rctnenr2(jrc)=rctnenr2(irc)
                end do !} j
              end if !}
            end do !} k
          end do !} i
        end do !} (irc)
        nnrctn=nrc

      end if !}

      write(*,*)
      write(*,*) 'Raw reaction list:',nnrctn
      write(*,*)
      if(nnrctn.gt.0) then !{
        write(*,'(4x,a7,22x,3a9,4x,5a3,a7,2a9)') 'species','bulk',
     ,    'out1','out2','ig','mp','mt','N1','N2','dlte','enr1','enr2'
        write(*,'(1x,i3,a9,a7,a5,a9,a3,3a9,5i3,1p,3e9.2)')
     -    (i,rctnptpr(i),rctndbs(i),rctnchp(i),rctnrct(i),rctntyp(i),
     ,     rctnptin(i),rctnpto1(i),rctnpto2(i),rctngrp(i),rctnmsp(i),
     ,      rctnmst(i),rctnnmo1(i),rctnnmo2(i),
     ,     rctndlte(i),rctnenr1(i),rctnenr2(i),i=1,nnrctn)
        write(*,*)
      end if !}

      if(ex) then !{
        write(0,*) 'Errors found in secondary particle specification'
        call xerrab ('==> Check the AMDS model')
      end if !}
c-----------------------------------------------------------------------
c*** Analyse the reaction data and prepare the data for Eirene

c***  nrcln : number of reaction lines in the Eirene input file
c***  nreaci: number of different reactions

      nrcln=0
      nreaci=0

c*** For each particle, find all reactions where it is the primary one,
c*** and add corresponding entries to the lists

c      n_ptc=nspcatm+nspcmol+nspcion+nspcpls
      do ipt=1,n_ptc !{ #0

c*** l_hlp.ne.0 flags the reactions treated already to avoid duplications
c*** m_rcn counts the reaction blocks for the current particle

        do i=1,nnrctn !{
          l_hlp(i)=0
        end do !}
        m_rcn=0

        if(ipt.le.nspcatm) then !{
          lknd=1
          jspc=ipt
          c=spcsatm(jspc)
        else if(ipt.le.nspcatm+nspcmol) then !}{
          lknd=2
          jspc=ipt-nspcatm
          c=spcsmol(jspc)
        else if(ipt.le.nspcatm+nspcmol+nspcion) then !}{
          lknd=3
          jspc=ipt-nspcatm-nspcmol
          c=spcsion(jspc)
        else !}{
          lknd=4
          jspc=ipt-nspcatm-nspcmol-nspcion
          c=spcspls(jspc)
        end if !}

c*** Now lknd   marks the particle kind (a, m, i, p),
c*** and jspc   is the species index within the kind
c***    m_rct   counts the number of reactions for this species,

        m_rct=0
        do irc=1,nnrctn !{  #1
          if(streql(c,rctnptpr(irc))) then !{ #2
            m_rct=m_rct+1
            if(l_hlp(irc).eq.0) then !{ #3
c*** The reaction is not yet tackled.
              k0=irc
c*** Check whether the same reaction is already on the list
cxpb Here we must keep the first match!
              kk=0
              ii=1
              do while (kk.eq.0 .and. ii.le.nrcln) !{
                if(streql(filnam(ii),rctndbs(irc)) .and.
     ,             streql(  h123(ii),rctnchp(irc)) .and.
     ,             streql(  reac(ii),rctnrct(irc)) .and.
     ,                     massp(ii).eq.rctnmsp(irc) .and.
     ,                     masst(ii).eq.rctnmst(irc) .and.
     ,                      rcmn(ii).eq.rctntmin(irc) .and.
     ,                      rcmx(ii).eq.rctntmax(irc)) kk=ii
                ii=ii+1
              end do !}

c***  check the group and find the related reaction - if any

              k1=0
              k2=0
              k3=0
              k4=0
              ig=rctngrp(irc)
              if(ig.ne.0) then !{ #4
                do ii=1,nnrctn !{
                  if(ii.ne.irc .and. ig.eq.rctngrp(ii)) then !{
                    k2=k2+1
                    if (k1.eq.0) then !{
                      k1=ii
                    else if (k3.eq.0) then !}{
                      k3=ii
                    end if !}
                  end if !}
                end do !}
                if(k2.gt.2) then !{
                  write(0,'(a,i2,a,i3)')
     ,             'Wrong number of reactions (',k2+1,
     ,                                      ') in the group ',ig
                  call xerrab
     ,             ('--- error found in reaction specification')
                end if !}

                k2=0
                if(k1.gt.0) then !{ #5
cxpb Here we must keep the last match!
                  do ii=1,nrcln !{
                    if(streql(filnam(ii),rctndbs(k1)) .and.
     ,                 streql(  h123(ii),rctnchp(k1)) .and.
     ,                 streql(  reac(ii),rctnrct(k1)) .and.
     ,                      massp(ii).eq.rctnmsp(irc) .and.
     ,                      masst(ii).eq.rctnmst(irc) .and.
     ,                       rcmn(ii).eq.rctntmin(k1) .and.
     ,                       rcmx(ii).eq.rctntmin(k1) .and.
     ,                     delpot(ii).eq.rctndlte(k1)) k2=ii
                  end do !}

c*** At this point, we have:

c***  nrcln     number of entries already in the final reaction list
c***  k0        current position in the raw reaction list
c***  kk        position of the same reaction in the final list
c***  ig        group identifier
c***  k1        position of the secondary reaction in the raw list
c***  k2        position of the secondary reaction in the final list

c*** Check the reaction group for consistency
c*** The order of the cards is flipped so that the H.1 and H.4 cards
c*** appear first
                  if(.not.streql(rctntyp(irc),rctntyp(k1))) then !{
                    write(0,*) 'Different reaction types for the ',
     ,               'group ',ig
                    write(0,*) 'Comparing reactions ',irc,' and ',k1
                    call xerrab ('==> Check the AMDS model')
                  end if !}
                  ex=.false.
                  if(streql(rctntyp(irc),'CX') .or.
     ,               streql(rctntyp(irc),'II') .or.
     ,               streql(rctntyp(irc),'EL')) then !{ #6
                    e_hlp=.false.
                    if(streql(rctnchp(irc),'H.0')) then !{
                      if(.not.(streql(rctnchp(k1),'H.1').or.
     .                         streql(rctnchp(k1),'H.3'))) then !{
                        ex=.true.
                      end if !}
                    elseif(streql(rctnchp(irc),'H.1')) then !}{
                      if(.not.(streql(rctnchp(k1),'H.3').or.
     .                         streql(rctnchp(k1),'H.0'))) then !{
                        ex=.true.
                      end if !}
                    else if(streql(rctnchp(irc),'H.3')) then !}{
                      if(.not.(streql(rctnchp(k1),'H.1').or.
     .                         streql(rctnchp(k1),'H.0'))) then !{
                        ex=.true.
                      else !}{
                        ii=k0
                        k0=k1
                        k1=ii
                        ii=kk
                        kk=k2
                        k2=ii
                      end if !}
                    else !}{
                      ex=.true.
                    end if !}
                    if(ex) then !{
                      write(0,*) 'Inconsistent reaction data. ',
     ,                  '"H.0", "H.1" and "H.3" should be grouped for ',
     ,                  rctntyp(irc), ' type'
                      write(0,*)
     ,                 'Error occured when treating reaction ',irc
                      call xerrab ('==> Check the AMDS model')
                    end if !}
                  else if(streql(rctntyp(irc),'EI') .or.
     ,                    streql(rctntyp(irc),'RC') .or.
     ,                    streql(rctntyp(irc),'DS')) then !}{
                    e_hlp=.true.
                    if(streql(rctnchp(irc),'H.4')) then !{
                      if(streql(rctnchp(k1),'H.4') .or.
     ,                   streql(rctnchp(k1),'H.10')) then !{
                        ex=.false.
!cxpb temporary test waiting for better A&M data
                      else if(streql(rctnchp(k1),'H.8') .and.
     ,                        (lknd.eq.2 .or. lknd.eq.3)) then
                        ex=.false.
!cxpb end
                      else !}{
                        ex=.true.
                      end if !}
                    else if (streql(rctnchp(irc),'H.2')) then !}{
                      if((streql(rctnchp(k1),'H.10')).or.
     ,                   (streql(rctnchp(k1),'H.8'))) then !{
                        ex=.false.
                      else !}{
                        ex=.true.
                      end if !}
                    else if(streql(rctnchp(irc),'H.10')) then !}{
                      if(streql(rctnchp(k1),'H.4') .and.
     ,                   streql(rctnchp(k1),'H.2')) then !{
                        ex=.true.
                      else !}{
                        ii=k0
                        k0=k1
                        k1=ii
                        ii=kk
                        kk=k2
                        k2=ii
                      end if !}
                    else !}{
                      ex=.true.
                    end if !}
                    if(ex) then !{
                      write(0,*) 'Inconsistent reaction data. H.4 ',
     ,                  'or H.2 should be grouped with',
!cxpb     ,                  ', correspondingly,',
     ,                  ' H.10 or H.8 for a ',
     ,                  rctntyp(irc), ' reaction'
                      write(0,*)
     ,                 'Error occured when treating reaction ',irc
                      call xerrab ('==> Check the AMDS model')
                    end if !}
                  else !}{
                    write(0,*) 'Wrong grouping of the reaction data. ',
     ,                'Right options are:'
                    write(0,*) '  H.4 or H.2 with H.8 or H.10 for ',
     ,                'EI, RC, or DS reaction, or'
                    write(0,*) '  H.0 and H.1 with H.3 for ',
     ,                'CX, II, or EL reaction'
                    write(0,*)
     ,               'Error occured when treating reaction ',irc
                    call xerrab ('==> Check the AMDS model')
                  end if !} #6
                end if !} #5 (k1)

                k4=0
                if(k3.gt.0) then !{ #5
cxpb Here we must keep the last match!
                  do ii=1,nrcln !{
                    if(streql(filnam(ii),rctndbs(k3)) .and.
     ,                 streql(  h123(ii),rctnchp(k3)) .and.
     ,                 streql(  reac(ii),rctnrct(k3)) .and.
     ,                      massp(ii).eq.rctnmsp(irc) .and.
     ,                      masst(ii).eq.rctnmst(irc) .and.
     ,                       rcmn(ii).eq.rctntmin(k3) .and.
     ,                       rcmx(ii).eq.rctntmin(k3) .and.
     ,                     delpot(ii).eq.rctndlte(k3)) k4=ii
                  end do !}

c*** At this point, we have:

c***  nrcln     number of entries already in the final reaction list
c***  k0        current position in the raw reaction list
c***  kk        position of the same reaction in the final list
c***  ig        group identifier
c***  k3        position of the tertiary reaction in the raw list
c***  k4        position of the tertiary reaction in the final list

c*** Check the reaction group for consistency
c*** The order of the cards is flipped so that the H.1 and H.4 cards
c*** appear first
                  if(.not.streql(rctntyp(irc),rctntyp(k3))) then !{
                    write(0,*) 'Different reaction types for the ',
     ,                         'group ',ig
                    write(0,*) 'Comparing reactions ',irc,' and ',k3
                    call xerrab ('==> Check the AMDS model')
                  end if !}
                  ex=.false.
                  if(streql(rctntyp(irc),'CX') .or.
     ,               streql(rctntyp(irc),'II') .or.
     ,               streql(rctntyp(irc),'EL')) then !{ #6
                    e_hlp=.false.
                    if(streql(rctnchp(irc),'H.0')) then !{
                      if(.not.(streql(rctnchp(k3),'H.1').or.
     .                         streql(rctnchp(k3),'H.3'))) then !{
                        ex=.true.
                      end if !}
                    elseif(streql(rctnchp(irc),'H.1')) then !}{
                      if(.not.(streql(rctnchp(k3),'H.3').or.
     .                         streql(rctnchp(k3),'H.0'))) then !{
                        ex=.true.
                      end if !}
                    else if(streql(rctnchp(irc),'H.3')) then !}{
                      if(.not.(streql(rctnchp(k3),'H.1').or.
     .                         streql(rctnchp(k3),'H.0'))) then !{
                        ex=.true.
                      else !}{
                        ii=k0
                        k0=k3
                        k3=ii
                        ii=kk
                        kk=k4
                        k4=ii
                      end if !}
                    else !}{
                      ex=.true.
                    end if !}
                    if(ex) then !{
                      write(0,*) 'Inconsistent reaction data. ',
     ,                  '"H.0", "H.1" and "H.3" should be grouped for ',
     ,                  rctntyp(irc), ' type'
                      write(0,*)
     ,                 'Error occured when treating reaction ', irc
                      call xerrab ('==> Check the AMDS model')
                    end if !}
                  else if(streql(rctntyp(irc),'EI') .or.
     ,                    streql(rctntyp(irc),'RC') .or.
     ,                    streql(rctntyp(irc),'DS')) then !}{ #6
                    e_hlp=.true.
                    if(streql(rctnchp(irc),'H.4')) then !{
                      if(.not.streql(rctnchp(k3),'H.4') .and.
     ,                   .not.streql(rctnchp(k3),'H.10')) then !{
                        ex=.true.
                      end if !}
                    else if (streql(rctnchp(irc),'H.2')) then !}{
                      if(.not.streql(rctnchp(k3),'H.10')) then !{
                        ex=.true.
                      end if !}
                    else if(streql(rctnchp(irc),'H.10')) then !}{
                      if(.not.streql(rctnchp(k3),'H.4') .and.
     .                   .not.streql(rctnchp(k3),'H.2')) then !{
                        ex=.true.
                      else if (streql(rctnchp(k3),'H.10')) then !}{
                        ii=k0
                        k0=k3
                        k3=ii
                        ii=kk
                        kk=k4
                        k4=ii
                      end if !}
                    else !}{
                      ex=.true.
                    end if !}
                    if(ex) then !{
                      write(0,*) 'Inconsistent reaction data. H.4 ',
     ,                  'or H.2 should be grouped with H.10 for a ',
     ,                  rctntyp(irc), ' reaction'
                      write(0,*)
     ,                 'Error occured when treating reaction ', irc
                      call xerrab ('==> Check the AMDS model')
                    end if !}
                  else !}{
                    write(0,*) 'Wrong grouping of the reaction data. ',
     ,                'Right options are:'
                    write(0,*) '  H.4 or H.2 with H.10 for ',
     ,                'EI, RC, or DS reaction, or'
                    write(0,*) '  H.0 and H.1 with H.3 for ',
     ,                'CX, II, or EL reaction'
                    write(0,*)
     ,               'Error occured when treating reaction ', irc
                    call xerrab ('==> Check the AMDS model')
                  end if !} #6
                end if !} #5 (k3)
              end if !} #4 (ig)

c*** At this point, we have:

c***  nrcln     number of entries already in the final reaction list
c***  k0        primary reaction position in the raw reaction list
c***  kk        position of the same reaction in the final list
c***  k1        position of the secondary reaction in the raw list
c***  k2        position of the secondary reaction in the final list

              if(kk.eq.0) then !{
c*** Add the primary reaction to the final list
                nrcln=nrcln+1
                nreaci=nreaci+1
                if(nreaci.gt.nreac) then !{
                  write(0,*) 'Too many different reactions specified:',
     ,                                                      nreaci
                  call xerrab
     .             ('==> Check the AMDS model and NREAC in KOPPLDIM.F')
                end if !}
                ir(nrcln)=nreaci
                filnam(nrcln)=rctndbs(k0)
                h123(nrcln)=rctnchp(k0)
                reac(nrcln)=rctnrct(k0)
                crc(nrcln)=rctntyp(k0)
                massp(nrcln)=rctnmsp(k0)
                masst(nrcln)=rctnmst(k0)
                delpot(nrcln)=0.0
                elname(nrcln)=rctneln(k0)
                iz(nrcln)=rctniz(k0)
c*** Temporary solution: no rcmn,rcmx
                rcmn(nrcln)=0.0
                rcmx(nrcln)=0.0
                ifexmn(nrcln)=0
                ifexmx(nrcln)=0
                do ii=1,6 !{
                  fparm(nrcln,ii)=0.0
                end do !}
                l_hlp(k0)=nrcln
                kk=nrcln
              end if !} (kk)

              if(k1.gt.0) then !{
                if(k2.eq.0) then !{
c*** Add the secondary reaction to the final list
                  nrcln=nrcln+1
                  if(e_hlp) nreaci=nreaci+1
                  ir(nrcln)=nreaci
                  filnam(nrcln)=rctndbs(k1)
                  h123(nrcln)=rctnchp(k1)
                  reac(nrcln)=rctnrct(k1)
                  crc(nrcln)=rctntyp(k1)
                  massp(nrcln)=rctnmsp(k1)
                  masst(nrcln)=rctnmst(k1)
                  if(e_hlp) then !{
                    delpot(nrcln)=rctndlte(k1)
                  else !}{
                    delpot(nrcln)=0.0
                  end if !}
                  elname(nrcln)=rctneln(k1)
                  iz(nrcln)=rctniz(k1)

c*** Temporary solution: no rcmn,rcmx

                  rcmn(nrcln)=0.0
                  rcmx(nrcln)=0.0
                  ifexmn(nrcln)=0
                  ifexmx(nrcln)=0
                  do ii=1,6 !{
                    fparm(nrcln,ii)=0.0
                  end do !}
                  l_hlp(k1)=nrcln
                  k2=nrcln
                else !}{
                  l_hlp(k1)=k2
                end if !} (k2)
c<<<
c               print *,'k1,k2,l_hlp = ',k1,k2,l_hlp(k1)
c>>>
              end if !} (k1)

              if(k3.gt.0) then !{
                if(k4.eq.0) then !{
c*** Add the tertiary reaction to the final list
                  nrcln=nrcln+1
                  if(e_hlp) nreaci=nreaci+1
                  ir(nrcln)=nreaci
                  filnam(nrcln)=rctndbs(k3)
                  h123(nrcln)=rctnchp(k3)
                  reac(nrcln)=rctnrct(k3)
                  crc(nrcln)=rctntyp(k3)
                  massp(nrcln)=rctnmsp(k3)
                  masst(nrcln)=rctnmst(k3)
                  if(e_hlp) then !{
                    delpot(nrcln)=rctndlte(k3)
                  else !}{
                    delpot(nrcln)=0.0
                  end if !}
                  elname(nrcln)=rctneln(k3)
                  iz(nrcln)=rctniz(k3)

c*** Temporary solution: no rcmn,rcmx

                  rcmn(nrcln)=0.0
                  rcmx(nrcln)=0.0
                  ifexmn(nrcln)=0
                  ifexmx(nrcln)=0
                  do ii=1,6 !{
                    fparm(nrcln,ii)=0.0
                  end do !}
                  l_hlp(k3)=nrcln
                  k4=nrcln
                else !}{
                  l_hlp(k3)=k4
                end if !} (k4)
c<<<
c               print *,'k3,k4,l_hlp = ',k3,k4,l_hlp(k3)
c>>>
              end if !} (k3)

c*** Update the particle-related reaction specification
c<<<
c              print '(a,10i3)',
c     ,                 'lknd,jspc,m_rct,m_rcn,k0,kk,k1,k2,k3,k4 = ',
c     ,                  lknd,jspc,m_rct,m_rcn,k0,kk,k1,k2,k3,k4
c>>>

              iir=ir(kk)
              cc=crc(kk)
              if(streql(cc,'CX') .or. streql(cc,'II') .or.
     ,           streql(cc,'EL')) then !{
                call uinspcid(rctnptin(k0),l,k)
                if(l.ne.4) then !{
                  write(0,*) 'The bulk particle must be a plasma ',
     ,              'ion: ',l,k0,'  ',rctnptin(k0)
                  call xerrab ('==> Check the AMDS model')
                end if !}
                if(k.le.0) then !{
                  write(0,*) 'Wrong specification of a bulk ',
     ,              'particle: ',k0,'  ',rctnptin(k0)
                  call xerrab ('==> Check the AMDS model')
                end if !}
                iib=100*k+14
              else !}{
                iib=115
              end if !}

              call uinspcid(rctnpto1(k0),l,k)
              if(l.lt.0) then !{
                write(0,*) 'Output particle 1 not on the list: ',
     ,            l,k0,'  ',rctnpto1(k0)
                call xerrab ('==> Check the AMDS model')
              else if(l.gt.0) then !}{
                ii1=100*k+10*rctnnmo1(k0)+l
              else !}{
                ii1=0
              end if !}

              call uinspcid(rctnpto2(k0),l,k)
              if(l.lt.0) then !{
                write(0,*) 'Output particle 2 not on the list: ',
     ,            l,k0,'  ',rctnpto2(k0)
                call xerrab ('==> Check the AMDS model')
              else if(l.gt.0) then !}{
                ii2=100*k+10*rctnnmo2(k0)+l
              else !}{
                ii2=0
              end if !}

              iie=0
              hlp_ee=0.0
              hlp_e1=0.0
              hlp_e2=0.0
              hlp_eb=0.0
              hlp_fr=1.0
              if(streql(cc,'CX') .or. streql(cc,'EL')) then !{
                iie=1001
              else if(streql(cc,'EI') .or. streql(cc,'RC') .or.
     .                streql(cc,'DS')) then !}{
                if(k1.gt.0) then !{
                  if (lknd.ne.3) then
                    iie=30000
                  else
                    iie=30300
                  endif
                  if(k2.le.0 .or. k2.gt.nrcln) then !{
                    write(0,*) 'k2 outside the range - internal error ',
     ,                'in uinp.'
                    write(0,'(a,6i4)') 'ipt,irc,k0,kk,k1,k2 = ',
     ,                ipt,irc,k0,kk,k1,k2
                    call xerrab ('==> Check the AMDS model')
                  end if !}
                  hlp_ee=ir(k2)
                else if(k3.gt.0) then !}{
                  if (lknd.ne.3) then
                    iie=30000
                  else
                    iie=30300
                  endif
                  if(k4.le.0 .or. k4.gt.nrcln) then !{
                    write(0,*) 'k4 outside the range - internal error ',
     ,                'in uinp.'
                    write(0,'(a,6i4)') 'ipt,irc,k0,kk,k3,k4 = ',
     ,                ipt,irc,k0,kk,k3,k4
                    call xerrab ('==> Check the AMDS model')
                  end if !}
                  hlp_ee=ir(k4)
                else !}{
                  iie=0
                  hlp_ee=-rctndlte(k0)
                end if !}
                if(streql(cc,'DS')) then !{
                  hlp_e1=rctnenr1(k0)
                  hlp_e2=rctnenr2(k0)
                else if (lknd.eq.3.and.streql(cc,'EI')) then !}{
                  if (k3.gt.0) hlp_e1=ir(k4)
                end if !}
              else !}{
                iie=0
              end if !}

              m_rcn=m_rcn+1
              if(lknd.eq.1) then !{
                ireaca(jspc,m_rcn)=iir
                ibulka(jspc,m_rcn)=iib
                iscd1a(jspc,m_rcn)=ii1
                iscd2a(jspc,m_rcn)=ii2
                iscdea(jspc,m_rcn)=iie
                eeleca(jspc,m_rcn)=hlp_ee
                ebulka(jspc,m_rcn)=hlp_eb
                escd1a(jspc,m_rcn)=hlp_e1
                escd2a(jspc,m_rcn)=hlp_e2
                freaca(jspc,m_rcn)=hlp_fr
              else if(lknd.eq.2) then !}{
                ireacm(jspc,m_rcn)=iir
                ibulkm(jspc,m_rcn)=iib
                iscd1m(jspc,m_rcn)=ii1
                iscd2m(jspc,m_rcn)=ii2
                iscdem(jspc,m_rcn)=iie
                eelecm(jspc,m_rcn)=hlp_ee
                ebulkm(jspc,m_rcn)=hlp_eb
                escd1m(jspc,m_rcn)=hlp_e1
                escd2m(jspc,m_rcn)=hlp_e2
                freacm(jspc,m_rcn)=hlp_fr
              else if(lknd.eq.3) then !}{
                ireaci(jspc,m_rcn)=iir
                ibulki(jspc,m_rcn)=iib
                iscd1i(jspc,m_rcn)=ii1
                iscd2i(jspc,m_rcn)=ii2
                iscdei(jspc,m_rcn)=iie
                eeleci(jspc,m_rcn)=hlp_ee
                ebulki(jspc,m_rcn)=hlp_eb
                escd1i(jspc,m_rcn)=hlp_e1
                escd2i(jspc,m_rcn)=hlp_e2
                freaci(jspc,m_rcn)=hlp_fr
              else if(lknd.eq.4) then !}{
                ireacp(jspc,m_rcn)=iir
                ibulkp(jspc,m_rcn)=iib
                iscd1p(jspc,m_rcn)=ii1
                iscd2p(jspc,m_rcn)=ii2
                iscdep(jspc,m_rcn)=iie
                eelecp(jspc,m_rcn)=hlp_ee
                ebulkp(jspc,m_rcn)=hlp_eb
                escd1p(jspc,m_rcn)=hlp_e1
                escd2p(jspc,m_rcn)=hlp_e2
                freacp(jspc,m_rcn)=hlp_fr
              else  !}{
                write(0,*) 'Wrong value of lknd : ',lknd,
     ,                     '  -- internal error in uinp!'
                call xerrab ('Wrong lknd value')
              end if !}

            end if !} #3 (l_hlp)
          end if !} #2 (rctnptpr)
        end do !} #1 (irc: reactions)

        if(lknd.eq.1) then !{
          nrca(jspc)=m_rcn
        else if(lknd.eq.2) then !}{
          nrcm(jspc)=m_rcn
        else if(lknd.eq.3) then !}{
          nrci(jspc)=m_rcn
        else if(lknd.eq.4) then !}{
          nrcp(jspc)=m_rcn
        else  !}{
          write(0,*) 'Wrong value of lknd : ',lknd,
     ,                                    '  -- internal error in uinp!'
          call xerrab ('Wrong lknd value')
        end if !}
      end do !} #0  (ipt: particles)

c*** Check the number of reactions of certain kinds

      l=0
      m=0
      n=0
      do i=1,nrcln !{
        if(streql(crc(i),'EL') .or. streql(crc(i),'DS') .or.
     .     streql(crc(i),'RC')) then !{
          e_hlp= .not.streql(h123(i),'H.10')
          if(e_hlp) then !{
            do j=1,i-1 !{
              e_hlp = e_hlp .and. ir(j).ne.ir(i)
            end do !}
          end if !}
c<<<
          print '(a3,1x,30i3/(4x,30i3))',crc(i),ir(i),(ir(j),j=1,i)
c>>>
          if(e_hlp) then !{
            if(streql(crc(i),'EL')) then !{
              l=l+1
            else if(streql(crc(i),'DS')) then !}{
              m=m+1
            else !}{
              n=n+1
            end if !}
          end if !}
        end if !}
      end do !}
c<<<
      print *,'el,dis,rec=',l,m,n
c>>>
      if(l.gt.DEF_NREL .or. m.gt.DEF_NREI .or. n.gt.DEF_NREC) then !{
        write(0,*) 'Too many reactions of at least one of the ',
     ,    'following types are specified:'
        write(0,'(/3x,a4,4x,a1,4x,a5)') 'Type','N','Limit'
        write(0,'(4x,a2,1x,i5,i8)') 'EL',l,DEF_NREL
        write(0,'(4x,a2,1x,i5,i8)') 'EI',m,DEF_NREI
        write(0,'(4x,a2,1x,i5,i8)') 'RC',n,DEF_NREC
        write(0,*) '==> Check the AMDS model '//
     ,   'and NREL, NREI, or NREC in DIMENSIONS.F'
        call xerrab ('Too many reactions')
      end if !}
c=======================================================================
      call subend ()
      return
 1028 format()
      end
