      subroutine uinprp
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
      use b2mod_constants

c  version : 16.03.2005 23:56

c=======================================================================
c*** Prepare the data for the B2-Eirene input files
c=======================================================================
      implicit none
#include "uinput.inc"
      integer i,j,k,l,m,lunplt,m_hlp(nlim,nlim),n_hlp
      parameter (n_hlp=nlim*nlim)
      logical uex,hlp_l
      real uzdim,rm_hlp,rx_hlp,zm_hlp,zx_hlp
      parameter (uzdim=1.e20)
      character utxsfa*44
      external xerrab, xertst, subini, subend
      data utxsfa / ' - target edge (to be modified by GEOUSR)' /
      data m_hlp / n_hlp*0 /
c=======================================================================
c*** Check some dimensions

      call subini ('uinprp')
      uex=.false.
      if(index(topo,'SN').eq.1) then !{
        if(mnpr.ne.3) then !{
          uex=.true.
          write(0,*) 'Inconsistent number of radial zones for ',topo,
     ,                '  (',mnpr,' )'
        end if !}
        if(mnptseg.ne.3) then !{
          uex=.true.
          write(0,*) 'Inconsistent number of poloidal zones for ',topo,
     ,                '  (',mnptseg,' )'
        end if !}
      else if(index(topo,'DN').eq.1) then !}{
        if(topo.eq.'DNS') then !{
          if(mnpr.ne.5) then !{
            uex=.true.
            write(0,*) 'Inconsistent number of radial zones for ',topo,
     ,                  '  (',mnpr,' )'
          end if !}
        else !}{
          if(mnpr.ne.6) then !{
            uex=.true.
            write(0,*) 'Inconsistent number of radial zones for ',topo,
     ,                  '  (',mnpr,' )'
          end if !}
        end if !}
        if(mnptseg.ne.6) then !{
          uex=.true.
          write(0,*) 'Inconsistent number of poloidal zones for ',topo,
     ,                '  (',mnptseg,' )'
        end if !}
      else !}{
        write(0,*) 'Unknown topology keyword "',topo,'".'
        write(0,*) '  ==> check the topology name in DG'
        call xerrab ('Unknown topology')
      end if !}
      call xertst(.not.uex, 'Topological inconsistency found in uinp')
      
c-----------------------------------------------------------------------
c*** Modify some defaults for limiter case, if necessary

      if(lm_cnfg) then !{
        jnpbndx(0,3)=lm_whst
        jnpbndx(0,4)=lm_whst
        do i=1,nstra !{
          nrcmstrs(i)=lm_vhst
        end do !}
        if(zaa.le.0.) then !{
          write(*,*) 'The major radius is not specified for a limiter ',
     ,                                                            'case'
          call xerrab
     .     ('==> Check the DG variable in "Global Eirene data"')
        end if !}
      end if !}


c*** Modify the toroidal dimension in p1, p2 arrays

      do i=1,nlimi !{
        p1(3,i)=-uzdim
        p2(3,i)=uzdim
      end do !}

      if(zaa.eq.0.) then !{
        zaa=0.2*pi*xlpcntr(1)
        write(*,'(1x,a,f11.4,a)')
     ,   'The O-point was taken for the major radius : ',
     ,                                       0.1*xlpcntr(1),' cm.'
      else if(zaa.lt.0.) then !}{

c*** Toroidal geometry

        nltrz=.false.
        nltra=.true.
        nttra=nttrator
        roa=roator
        zaa=zaator
      end if !}

c*** Prepare index of valid additional surfaces

      k=laddsrfs
      l=1
      do i=1,nlimi !{
        uex=.false.
        if(jadch0(l).eq.i) then !{
          l=l+1
          indasrfe(i)=0
        else !}{
          k=k+1
          if(k.gt.nlim) then !{
            write(0,*) 'Insufficient space for "additional surfaces" ',
     ,        'in Eirene.'
            write(0,*) 'Maximum ',nlim,',  DG model ',nlimi,
     ,        '  reserved ',laddsrfs
            call xerrab
     .       ('==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
          end if !}
          indasrfe(i)=k
          indasrfs(k)=i
        end if !}
      end do !}
c!###{
c      print *,'indasrfs:', k
c      if(k.gt.0) print '(1x,30i4)',(indasrfs(i),i=1,k)
c      print *,'indasrfe:',nlimi
c      if(k.gt.0) print '(1x,30i4)',(indasrfe(i),i=1,nlimi)
c!###}
      jadch0(1)=0
      nlimi=k

c*** Check for zero length additional surfaces

      uex=.false.
      do k=1,nlimi !{
        i=indasrfs(k)
        if(p1(1,i).eq.p2(1,i) .and. p1(2,i).eq.p2(2,i)) then !{
          uex=.true.
          write(*,'(1x,a,i5,a,1p,4(e15.6,a))') 'zero length: ',i,
     ,         '  (',p1(1,i),',',p1(2,i),') - (',p2(1,i),',',p2(2,i),')'
        end if !}
      end do !}
      if(uex) then !{
        write(0,*) 'Zero-length segment(s) found in DG data'
        call xerrab ('==> Check the geometry in the DG model')
      end if !}

c*** Correct jadch1 (not tested yet!!!)

      do j=1,nlim !{
        if(indasrfe(j).gt.0) then !{
          l=indasrfe(j)
          if(jadch1(1,j).gt.0) then !{
            k=0
            uex=.true.
            do i=1,nlim !{
              if(uex) then !{
                m=jadch1(i,j)
                if(m.le.0) then !{
                  uex=.false.
                else !}{
                  m=indasrfe(m)
                  if(m.gt.0) then !{
                    k=k+1
                    m_hlp(k,l)=m
                  end if !}
                end if !}
              end if !}
            end do !}
          end if !}
        end if !}
      end do !}
      do j=1,nlim !{
        do i=1,nlim !{
          jadch1(i,j)=m_hlp(i,j)
        end do !}
      end do !}

c*** Prepare index of additional surfaces to be modified in geousr

      if(ntrgte.gt.0) then
        k=0
        l=2
        do i=1,ntrgte
          l=3-l
          j=l
          jedge(1,k+1)=j
          jedge(2,k+1)=indasrfe(jedgep(i))
          jedge(1,k+2)=3-j
          jedge(2,k+2)=indasrfe(jedgec(i))
          j=3-j
          k=k+2
        end do
        ntrgte=k
      else if(ntrgto.gt.0) then
        k=0
        l=2
        do i=1,2
          l=3-l
          j=l
          jedge(1,k+1)=j
          jedge(1,k+2)=3-j
          j=3-j
          k=k+2
        end do
        do i=1,k
          jedge(2,i)=indasrfe(jedgeo(i))
        end do
        ntrgte=k
      end if
      if(ntrgte.le.0) then !{
        write(0,*) 'Undefined target edges'
        call xerrab ('==> Check the specification in the DG model')
      end if !}
      uex=.false.
      do i=1,k !{
        if(jedge(2,i).le.0) then !{
          uex = .true.
          write(0,*) '"Target edge"',i,'  is specified as "Not for ',
     ,                                                        'Eirene"'
        end if !}
      end do !}
      call xertst (.not.uex,
     . '==> Check the specification in the DG model')

c*** Specify some comments to appear in the output file

      do i=1,ntrgte
        j=jedge(2,i)
        txtsfa(j)=utxsfa
      end do

c*** Re-arrange specification of the time allocation: through B2

      ntcpub2=ntcpu
      NTIM1=1
      NTCPU=ttntcpu

      NOPTIM=-1
    
c-----------------------------------------------------------------------
c*** Particle and reaction data (sect. 4 and 5)
     
      call uinprppt
      call uinprprc
      call uinprpbl
c-----------------------------------------------------------------------
c*** Grid dimensions and topology (cuts, targets)
      call uinprpgr

c*** Boundary conditions at the grid edges (including recycling)
      call uinprpbn

c*** Prepare the data for triangular mesh
c***                               - needed also for regular input files
      call uinptriang(uex)
c      if(uex) then !{
        do i=1,nstsi
          ilplg(i)=ilplgu(i)
        end do !}
        do i=1,nlim
          jlplg(i)=jlplgu(i)
        end do !}
c      end if !}

c*** Neutral sources due to gas puffing
      call uinpsrcg

c*** Neutral sources due to recombination
      call uinpsrcv

c*** Cuts specification for Eirene (sect. 3a)
      call uinprpnd

c-----------------------------------------------------------------------
c*** Surface-particle data (sect. 6C)
      call uinprpsf
c*** Surface interaction cards
      call uinpscrd
c-----------------------------------------------------------------------
c*** Midplane location

      jxi=mod(jxi,nx+2)
      jxa=mod(jxa,nx+2)

c-----------------------------------------------------------------------
c*** Helium pumping data (B2/user)

      call uinprphe
      
c-----------------------------------------------------------------------
c*** Output control

      nplotr=nr1st
      nplotp=np2nd
      lunplt=nptal*nplt
      call vfill(nplot2,lunplt,irwl)
      if(ch2mx.le.0. .or. ch2my.le.0.) then !{
        rm_hlp=uzdim
        zm_hlp=uzdim
        rx_hlp=-uzdim
        zx_hlp=-uzdim
        do i=1,nlimi !{
          j=indasrfs(i)
          rm_hlp=min(rm_hlp,p1(1,j),p2(1,j))
          zm_hlp=min(zm_hlp,p1(2,j),p2(2,j))
          rx_hlp=max(rx_hlp,p1(1,j),p2(1,j))
          zx_hlp=max(zx_hlp,p1(2,j),p2(2,j))
        end do !}
        ch2x0=0.5*(rm_hlp+rx_hlp)
        ch2y0=0.5*(zm_hlp+zx_hlp)
        ch2mx=0.5*(rx_hlp-rm_hlp)*1.05
        ch2my=0.5*(zx_hlp-zm_hlp)*1.05
        ch2mx=max(ch2mx,ch2my)
        ch2my=ch2mx
      end if !}

c-----------------------------------------------------------------------
c*** Additional tallies

      nadvi = 4*(natmi+nmoli)
      do j=1,natmi !{
        iadve(j)=1
        iadvs(j)=0
        iadvt(j)=0
        iadrc(j)=1
        txttla(j)='RADIAL PARTICLE FLUXES, VOLUME AVERAGED'
        txtspa(j)=trim(spcsatm(j))//' ATOMS'
        txtuna(j)='#/CM**2/S'
        iadve(natmi+nmoli+j)=1
        iadvs(natmi+nmoli+j)=0
        iadvt(natmi+nmoli+j)=0
        iadrc(natmi+nmoli+j)=1
        txttla(natmi+nmoli+j)='RADIAL ENERGY FLUXES, VOLUME AVERAGED'
        txtspa(natmi+nmoli+j)=trim(spcsatm(j))//' ATOMS'
        txtuna(natmi+nmoli+j)='EV/CM**2/S'
        iadve(2*(natmi+nmoli)+j)=1
        iadvs(2*(natmi+nmoli)+j)=0
        iadvt(2*(natmi+nmoli)+j)=0
        iadrc(2*(natmi+nmoli)+j)=1
        txttla(2*(natmi+nmoli)+j)=
     .   'PARALLEL PARTICLE FLUXES, VOLUME AVERAGED'
        txtspa(2*(natmi+nmoli)+j)=trim(spcsatm(j))//' ATOMS'
        txtuna(2*(natmi+nmoli)+j)='#/CM**2/S'
        iadve(3*(natmi+nmoli)+j)=1
        iadvs(3*(natmi+nmoli)+j)=0
        iadvt(3*(natmi+nmoli)+j)=0
        iadrc(3*(natmi+nmoli)+j)=1
        txttla(3*(natmi+nmoli)+j)=
     .   'PARALLEL ENERGY FLUXES, VOLUME AVERAGED'
        txtspa(3*(natmi+nmoli)+j)=trim(spcsatm(j))//' ATOMS'
        txtuna(3*(natmi+nmoli)+j)='EV/CM**2/S'
      end do !}
      do j=1,nmoli !{
        iadve(natmi+j)=1
        iadvs(natmi+j)=0
        iadvt(natmi+j)=0
        iadrc(natmi+j)=2
        txttla(natmi+j)='RADIAL PARTICLE FLUXES, VOLUME AVERAGED'
        txtspa(natmi+j)=trim(spcsmol(j))//' MOLECULES'
        txtuna(natmi+j)='#/CM**2/S'
        iadve(2*natmi+nmoli+j)=1
        iadvs(2*natmi+nmoli+j)=0
        iadvt(2*natmi+nmoli+j)=0
        iadrc(2*natmi+nmoli+j)=2
        txttla(2*natmi+nmoli+j)='RADIAL ENERGY FLUXES, VOLUME AVERAGED'
        txtspa(2*natmi+nmoli+j)=trim(spcsmol(j))//' MOLECULES'
        txtuna(2*natmi+nmoli+j)='EV/CM**2/S'
        iadve(3*natmi+2*nmoli+j)=1
        iadvs(3*natmi+2*nmoli+j)=0
        iadvt(3*natmi+2*nmoli+j)=0
        iadrc(3*natmi+2*nmoli+j)=2
        txttla(3*natmi+2*nmoli+j)=
     .   'PARALLEL PARTICLE FLUXES, VOLUME AVERAGED'
        txtspa(3*natmi+2*nmoli+j)=trim(spcsmol(j))//' MOLECULES'
        txtuna(3*natmi+j)='#/CM**2/S'
        iadve(4*natmi+3*nmoli+j)=1
        iadvs(4*natmi+3*nmoli+j)=0
        iadvt(4*natmi+3*nmoli+j)=0
        iadrc(4*natmi+3*nmoli+j)=2
        txttla(4*natmi+3*nmoli+j)=
     .   'PARALLEL ENERGY FLUXES, VOLUME AVERAGED'
        txtspa(4*natmi+3*nmoli+j)=trim(spcsmol(j))//' MOLECULES'
        txtuna(4*natmi+3*nmoli+j)='EV/CM**2/S'
      end do !}

c*** Prepare the data for visualisation of the surface properties

#ifdef DBG
      print '(a,20i4)','uinprp: nsrfcls,msrfcls=',nsrfcls,msrfcls
      print *,'isrfclu'
      do j=1,nsrfclsx !{
        print '(8x,20i4)',(isrfclu(j,i),i=1,nvspfls)
      end do !}
      print *,'msrfcls,lsrfcls'
      do j=1,nsrfclsx !{
        print '(i6,2x,20i4)',msrfcls(j),(lsrfcls(i,j),i=1,msrfclsx)
      end do !}
      print *
#endif
      nsrfclu=0
      do k=1,nsrfcls !{
        do j=1,nvspfls !{
          if(isrfclu(k,j).ne.0) then !{
            nsrfclu(j)=nsrfclu(j)+1
            msrfclu(nsrfclu(j),j)=msrfcls(k)
            do i=1,msrfcls(k) !{
              lsrfclu(i,nsrfclu(j),j)=lsrfcls(i,k)
            end do !}
          end if !}
        end do !}
      end do !}
      hlp_l=.false.
      do j=1,nsrfclu(2) !{
        hlp_l=hlp_l .or. isrfclu(j,2).lt.0
      end do !}
      if(hlp_l) nsrfclu(2)=-nsrfclu(2)
#ifdef DBG
      print *,'nsrfclu=',nsrfclu
      print *,'file,view,msrfclu,lsrfclu'
      do k=1,nsrfcls !{
        do j=1,nvspfls !{
          print '(2x,3i4,2x,20i4)',j,k,msrfclu(k,j),
     ,                                   (lsrfclu(i,k,j),i=1,msrfclsx)
        end do !}
      end do !}
#endif

c*** Set the VSP data for input.eir

      nsrfcls=nsrfclu(1)
      do k=1,abs(nsrfcls) !{
        msrfcls(k)=msrfclu(k,1)
        do i=1,msrfcls(k) !{
          lsrfcls(i,k)=lsrfclu(i,k,1)
        end do !}
      end do !}

c=======================================================================
      call subend ()
      return
      end
