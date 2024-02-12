      program uinput
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use b2mod_xerset
      use b2mod_version
      use eirmod_solps
      use helper
#ifdef DIMENSIONS_MODULE
      use b2mod_dimensions
#endif

c  version : 28.01.2003 18:08

c=======================================================================
      implicit none
#include "uinput.inc"
#include "impcon.inc"
      integer irt, is, iss, iatm, iloc
      integer ns, i, j, ireg, nreg, len
      real(kind=R8), allocatable :: na0(:)
      character tab
      character*5, allocatable :: specs(:)
      character*8, allocatable :: species_name(:)
      character*22 hlp_frm
      character*27 lbreg(0:cbnrmx-1)
      character*120 lblps
      character*80 column_header
      logical uex
      integer find_matching_species
      logical streql
      external find_matching_species, streql
      external prgini,prgend
c=======================================================================
      call prgini('uinput')
*   ..mark output unit for error messages
      call xerset (0)
      tab=char(9)
c*** Read the input data from various files
      call uininp
c*** Prepare the constants
      call uinprp

c*** Produce the input file for Eirene

      call uinout('input.eir')
      print *,'    ... input.eir created'

c*** Produce the input file for Eirene for the hybrid model

      call uinouth('input_hybrid.eir')
      print *,'    ... input_hybrid.eir created'

c*** Produce the input file for Eirene test run

      call uinprptt(.true.)
      call uinout('test.eir')
      call uinprptt(.false.)
      print *,'    ... test.eir created'

c*** Produce the input file for Eirene diagnostics run

      uex=.true.
      call uinprpdg(uex)
      if(uex) then !{
        call uinout('diag2.eir')
        call uinprpdg(.false.)
        print *,'    ... diag2.eir created'
      end if !}

c*** Produce the input file for Eirene for TRIA mesh generation
      uex=.true.
      call uinptridg(uex)
      if(uex) then !{
       call uinout('triang.eir')
       print *,'    ... triang.eir created'
       call triaout('triang.hed')
       call uinptridg(.false.)
      end if !}

c*** Produce the input files for Eirene for averaging scheme runs
      uex=.true.
      call uinpavgdg(uex)
      if(uex) then !{
        call uinout('input_avg.eir')
        print *,'    ... input_avg.eir created'
        call uinpavgdg(.false.)
      end if !}
      uex=.true.
      call uinpfindg(uex)
      if(uex) then !{
        call uinout('input_fin.eir')
        print *,'    ... input_fin.eir created'
        call uinpfindg(.false.)
      end if !}

      ns = natmi-nmeta+nplsi
      allocate(specs(-1:ns-1))
      write(specs(-1),'(a)') ' ''-1'''
      do is = 0, ns-1
        if (is.lt.10) then
          write(specs(is),'(a,i1,a)') '  ''',is,''''
        else if (is.lt.100) then
          write(specs(is),'(a,i2,a)')  ' ''',is,''''
        else
          write(specs(is),'(a,i3,a)')   '''',is,''''
        end if
      end do
c*** Create the header for the b2ag.dat file
      inquire(file='b2ag.dat', exist=uex)
      if(uex) then !{
          print *,'    ... b2ag.dat file already present, not created'
      else !}{
          open(2,file='b2ag.dat')
          write(2,'(a)')
     .     '*dimens         (nx, ny, nx1, ny1; free format)'
          write(2,'(4(3x,i4))') nrplg-npplg, ndya, nrplg-npplg, ndya
          write(2,'(a)') '*param          (param(0:99); free format)'
          if (ln_cnfg) then
            write(2,'(a)') ' -3.0, 99*0.0'
          else
            write(2,'(a)') ' -1.0, 99*0.0'
          endif
          write(2,'(a)') '''b2agfs_min_pitch''    ''0.01'''
          if (lm_cnfg.and..not.ln_cnfg) write(2,'(a)')
     .                   '''b2agfs_periodic_bc''  ''1'''
          if (ln_cnfg) write(2,'(a)')
     .                   '''b2agfs_lineardevice'' ''linear.geometry'''
          ! temporary for target/vessel mode grids: disable redef_gmtry
          if (carre_mode.ge.2) write(2,'(a)')
     .                   '''b2agdr_redef_gmtry''  ''0'''
          close(2)
          print *,'    ... b2ag.dat created'
      endif !}

c*** Create the b2us.dat file for triangulation
      inquire(file='b2us.dat', exist=uex)
      if(uex) then !{
          print *,'    ... b2us.dat file already present, not created'
      else !}{
          open(2,file='b2us.dat')
          write(2,'(a)')
     .     '*label          (lblmn: character*60)'
          write(2,'(a)')
     .     'Input file for triangulation plasma region with b2us'
          write(2,'(a)') '*b2cmpa  basic parameters'
          write(2,'(a)') '*b2cmpb  boundary conditions'
          write(2,'(a)') '*b2cmpt  transport coefficients'
          write(2,'(a)') '*endphy'
          write(2,'(a)') '''b2mndr_eirene''    ''1'''
          write(2,'(a)') '''b2stbc_boundary_namelist''    ''1'''
          write(2,'(a)') '''b2stbr_neutrals_namelist''    ''1'''
          write(2,'(a)') '''b2us_write_b2fgmtry_us''    ''0'''
          write(2,'(a)') '''b2us_write_b2fstati_us''    ''0'''
          write(2,'(a)') '''b2us_tria_mode''   ''1'''
          close(2)
          print *,'    ... b2us.dat created'
      endif !}

c*** Create a b2ah.dat.stencil file
      inquire(file='b2ah.dat.stencil', exist=uex)
      if(uex) then
          print *,
     .     '    ... b2ah.dat.stencil file already present, not created'
      else
          open(2,file='b2ah.dat.stencil')
          len = 0
          do i = 0, 7
            column_header(len+1:len+6) = '     ('
            len=len+6
            write(column_header(len+1:len+1),'(i1)') i
            len=len+1
            column_header(len+1:len+3) = ')  '
            len=len+3
          end do
          write(2,'(a)') '*dimens         (ns; free format)'
          write(2,'(3x,i4)') natmi-nmeta+nplsi
          write(2,'(a)')
     .     '*label          (lblps, character*60; free format)'
          if (texta(1)(2:2).eq.' ') then
            lblps(1:35) = '''Default transport parameters for '//
     .       texta(1)(1:1)
            iloc = 35
          else
            lblps(1:36) = '''Default transport parameters for '//
     .       texta(1)(1:2)
            iloc = 36
          endif
          do is = 2, natmi
            if (is_meta(is)) cycle
            if (texta(is)(2:2).eq.' ') then
              lblps(iloc+1:iloc+3) = '+'//texta(is)(1:1)
              iloc = iloc+2
            else
              lblps(iloc+1:iloc+3) = '+'//texta(is)(1:2)
              iloc = iloc+3
            end if
          end do
          lblps(iloc+1:iloc+20) = ', all charge states'''
          write(2,'(2x,a)') lblps(1:iloc+20)
          write(2,'(a)') '*b2cmpa         basic parameters'
          write(2,'(a)') '*specs    zamin    zamax       zn      am'
          is=0
          do iatm = 1, natmi
            if (is_meta(iatm)) cycle
            j=find_matching_species(spcsncl(iatm))
            write(2,'(1x,a5,5x,a3,6x,a3,4x,i3,a2,4x,i3,a2)')
     .       specs(is),'0.0','0.0',nchara(iatm),'.0',
     .                             nmassa(iatm),'.0'
cxpb Default data for neutrals
            cfdf0(0,is) = 100.0
            cfdf0(2,is) = 1.0
            if (nchara(iatm).eq.1) then
              cfdf0(3,is) = 5.0e-20
              cfdf0(4,is) = 1.5e-18
            else if (nchara(iatm).eq.2) then
              cfdf0(3,is) = 2.0e-20
              cfdf0(4,is) = 5.0e-20
            else if (nchara(iatm).eq.6) then
              cfdf0(3,is) = 5.0e-20
              cfdf0(4,is) = 1.5e-18
            else if (nchara(iatm).eq.10) then
              cfdf0(3,is) = 1.0e-20
              cfdf0(4,is) = 7.0e-21
            else !!! dummy unknown numbers !!!
              cfdf0(3,is) = 3.33e-20
              cfdf0(4,is) = 3.33e-20
            end if
            cfdpa(2,is) = 1.0
            cfvsa(2,is) = 1.0
            cfhci(2,is) = 1.4
            is = is + 1
            do iss = 1, nbndl(iatm)-1
              write(2,
     .         '(1x,a5,4x,i2,a2,5x,i2,a2,4x,i3,a2,4x,i3,a2)')
     .            specs(is),izamin(is),'.0',izamax(is),'.0',
     .                    nchara(iatm),'.0',nmassa(iatm),'.0'
cxpb Default data for ions
              cfdf0(0,is) = 0.5
              cfdna(2,is) = 1.0
              cfvsa(2,is) = 0.4
              cfhci(2,is) = 1.4
              is = is + 1
            end do
          end do
          cfhce(0) = 0.7
          cfsig(0) = 1.0e-7
          cflim(0) = 0.15
          cflim(1) = 0.15
          cflim(2) = 0.5
          cflim(3) = 0.5
          cflim(4) = 0.5
          write(2,'(a)') '*b2cmpt  transport coefficients'
          write(2,'(a)') '*cfdf0'//column_header
          do is = 0, ns-1
            write(2,'(1x,a5,1p,8(1x,e9.2))') specs(is),
     .       (cfdf0(i,is),i=0,7)
          end do
          write(2,'(a)') '*cfdna'//column_header
          do is = 0, ns-1
            write(2,'(1x,a5,1p,8(1x,e9.2))') specs(is),
     .       (cfdna(i,is),i=0,7)
          end do
          write(2,'(a)') '*cfdpa'//column_header
          do is = 0, ns-1
            write(2,'(1x,a5,1p,8(1x,e9.2))') specs(is),
     .       (cfdpa(i,is),i=0,7)
          end do
          write(2,'(a)') '*cfvla'//column_header
          do is = 0, ns-1
            write(2,'(1x,a5,1p,8(1x,e9.2))') specs(is),
     .       (cfvla(i,is),i=0,7)
          end do
          write(2,'(a)') '*cfvsa'//column_header
          do is = 0, ns-1
            write(2,'(1x,a5,1p,8(1x,e9.2))') specs(is),
     .       (cfvsa(i,is),i=0,7)
          end do
          write(2,'(a)') '*cfhci'//column_header
          do is = 0, ns-1
            write(2,'(1x,a5,1p,8(1x,e9.2))') specs(is),
     .       (cfhci(i,is),i=0,7)
          end do
          write(2,'(a)') '*cfhce'//column_header
          write(2,'(1x,a5,1p,8(1x,e9.2))') specs(-1),
     .     (cfhce(i),i=0,7)
          write(2,'(a)') '*cfsig'//column_header
          write(2,'(1x,a5,1p,8(1x,e9.2))') specs(-1),
     .     (cfsig(i),i=0,7)
          write(2,'(a)') '*cfalf'//column_header
          write(2,'(1x,a5,1p,8(1x,e9.2))') specs(-1),
     .     (cfalf(i),i=0,7)
          write(2,'(a)') '*cflim'//
     .     '    cflme     cflmi     cflmv     cflal     cflab     ...'
          write(2,'(1x,a5,1p,8(1x,e9.2))') specs(-1),
     .     (cflim(i),i=0,7)
          write(2,'(a)') '*endphy'
          close(2)
          print *,'    ... b2ah.dat.stencil created'
      endif

c*** Create the b2ai.dat file
      inquire(file='b2ai.dat', exist=uex)
      if(uex) then
          print *,'    ... b2ai.dat file already present, not created'
      else
          allocate(na0(0:natmi-nmeta+nplsi-1))
          open(2,file='b2ai.dat')
          write(2,'(a)') '*dimens         (ns; free format)'
          write(2,'(3x,i4)') natmi-nmeta+nplsi
          write(2,'(a)')
     .     '*label          (lblps, character*60; free format)'
          if (texta(1)(2:2).eq.' ') then
            lblps(1:25) = '''Flat initial state for '//texta(1)(1:1)
            iloc = 25
          else
            lblps(1:26) = '''Flat initial state for '//texta(1)(1:2)
            iloc = 26
          endif
          do is = 2, natmi
            if (is_meta(is)) cycle
            if (texta(is)(2:2).eq.' ') then
              lblps(iloc+1:iloc+3) = '+'//texta(is)(1:1)
              iloc = iloc+2
            else
              lblps(iloc+1:iloc+3) = '+'//texta(is)(1:2)
              iloc = iloc+3
            end if
          end do
          lblps(iloc+1:iloc+20) = ', all charge states'''
          write(2,'(2x,a)') lblps(1:iloc+20)
          write(2,'(a)') '*specs    zamin    zamax       zn      am'
          is=0
          do iatm = 1, natmi
            if (is_meta(iatm)) cycle
            write(2,'(1x,a5,5x,a3,6x,a3,4x,i3,a2,4x,i3,a2)')
     .       specs(is),'0.0','0.0',nchara(iatm),'.0',
     .                             nmassa(iatm),'.0'
            if (nchara(iatm).le.18) then
              na0(is) = 1.0e12
            else
              na0(is) = 1.0e8
            end if
            is = is + 1
            do iss = 1, nbndl(iatm)-1
              write(2,
     .         '(1x,a5,4x,i2,a2,5x,i2,a2,4x,i3,a2,4x,i3,a2)')
     .            specs(is),izamin(is),'.0',izamax(is),'.0',
     .                    nchara(iatm),'.0',nmassa(iatm),'.0'
              if (nchara(iatm).eq.1) then
                na0(is) = 1.0e19
              else if (nchara(iatm).le.18) then
                na0(is) = 1.0e16
              else
                na0(is) = 1.0e8
              end if
              is = is + 1
            end do
          end do
          write(2,'(a)') '*naini          (na0(0:ns-1); free format)'
          write(hlp_frm,'(a,i3,a)')
     .                   '(1p,',natmi-nmeta+nplsi,'(2x,e8.1))'
          write(2,hlp_frm) (na0(is),is=0,natmi-nmeta+nplsi-1)
          write(2,'(a)') '*ttini          (tt0; free format)'
          write(2,'(3x,a)') '1.0e2'
          close(2)
          print *,'    ... b2ai.dat created'
          deallocate(na0)
      endif

c*** Create the b2ar.dat file
      inquire(file='b2ar.dat', exist=uex)
      if(uex) then
          print *,'    ... b2ar.dat file already present, not created'
      else
          open(2,file='b2ar.dat')
          write(2,'(a)') '*tlohi          (tlo, thi; real, free format)'
          write(2,'(1p,2(2x,e8.1))') 0.1, 1.0e4
          write(2,'(a)') '*nlohi          (nlo, nhi; real, free format)'
          write(2,'(1p,2(2x,e8.1))') 1.0e14, 1.0e22
          write(2,'(a)') '*numnuc         (nnuc; integer, free format)'
          write(2,'(2x,i2)') natmi-nmeta
          write(2,'(a)') '*nucspec        '//
     .     '(nz, izlo, izhi; integers, one triplet per line)'
          do iatm = 1, natmi
            if (.not.is_meta(iatm))
     >       write(2,'(2x,3i3)') nchara(iatm), 0, nchara(iatm)
          end do
          write(2,'(a)') '*flag           '//
     .     '(''adpak'', ''strahl'', ''adas'' or ''amns'', free format)'
          write(2,'(2x,a)') '''adas'''
          write(2,'(a)') '*tailep         (real, free format)'
          write(2,'(2x,f5.2)') 0.08
cnh       AFN-specific inputs
c          write(2,'(a)') '''b2ardr_no_smoothing''     ''1'''//
c     .      '       # Eliminate smoothing for benchmark with EIRENE'
          write(2,'(a)') '''b2ardr_rtnt''             ''100'''//
     .      '     # Use finer discretization for AFN (default 40)'
          write(2,'(a)') '''b2ardr_rtnn''             ''100'''//
     .      '     # Use finer discretization for AFN (default 32)'
          write(2,'(a)') '''b2ardr_no_weisheit''      ''1'''//
     .      '       # No correction for hydrogen neutrals'
          write(2,'(a)') '''b2ardr_amjhydhel''        ''1'''//
     .      '       # Take AMJUEL/HYDHEL for hydrogen neutrals'
          write(2,'(a)') '''b2ardr_t_min''            ''1.0E-01'''//
     .      ' # Minimum temperature [eV] for which AMJUEL rates '//
     .      'are evaluated'
          write(2,'(a)') '''b2ardr_nn_min''           ''1.0E+14'''//
     .      ' # Minimum density [m^-3] for which AMJUEL rates '//
     .      'are evaluated'
          write(2,'(a)') '''b2ardr_fix_recomb''       ''1'''
          close(2)
          print *,'    ... b2ar.dat created'
      endif

c*** Create the header for the b2yr.dat file
      inquire(file='b2yr.dat', exist=uex)
      if(uex) then
          print *,'    ... b2yr.dat file already present, not created'
      else
          open(2,file='b2yr.dat')
          write(2,'(a)') '*nijdis        (integer, free format)'
          write(2,'(2i4)') 4, 4
          write(2,'(a)') '*idis          (nidis*integer, free format)'
          write(2,'(4i4)') 8, 16, 24, 32
          write(2,'(a)') '*jdis          (njdis*integer, free format)'
          write(2,'(4i4)') 4, 12, 20, 28
          close(2)
          print *,'    ... b2yr.dat created'
      endif

c*** Create the header for the b2yt.dat file
      inquire(file='b2yt.dat', exist=uex)
      if(uex) then
          print *,'    ... b2yt.dat file already present, not created'
      else
          open(2,file='b2yt.dat')
          write(2,'(a)') '*dimens         (nx1, ny1; free format)'
          write(2,'(2(3x,i4))') nrplg-npplg, ndya
          write(2,'(a)') '''solps_version'''//tab//'''iter'''
          write(2,'(a)') '''eirene_format'''//tab//'''iter'''
          close(2)
          print *,'    ... b2yt.dat created'
      endif

      deallocate(specs)

c-----------------------------------------------------------------------
c*** Modify the input file for B2, if possible

      inquire(file='b2.neutrals.parameters', exist=uex)
      if(uex) then
          open(1,file='b2.neutrals.parameters',status='old',err=22)
          open(2,file='b2.neutrals.parameters.2',err=20)
          call uicrb2(1,2,irt)
          if(irt.eq.0) then
            print *,'    ... b2.neutrals.parameters.2 created'
            close(2,err=22)
          else
            print *,
     .       '    Error while creating b2.neutrals.parameters.2: ',irt
          end if
       else
          write(*,*) 'No b2.neutrals.parameters found'
          write(*,*) 'Writing b2.neutrals.parameters.stencil'
          open(99,status='SCRATCH')
          write(99,'(a)') 'VERSION'//newversion
          write(99,*) '&NEUTRALS'
          write(99,*) '/'
          rewind(99)
          open(2,file='b2.neutrals.parameters.stencil',err=20)
          call uicrb2(99,2,irt)
          close(99)
          if(irt.eq.0) then
            print *,'    ... b2.neutrals.parameters.stencil created'
            close(2,err=22)
          else
            print *,
     .      '    Error while creating b2.neutrals.parameters.stencil:'
     .      ,irt
          end if
      end if
cnh b2.neutrals.parameters for the hybrid model
      inquire(file='b2.neutrals.parameters_hybrid', exist=uex)
      if(uex) then
          open(1,file='b2.neutrals.parameters_hybrid',status='old',
     .      err=22)
          open(2,file='b2.neutrals.parameters_hybrid.2',err=20)
          call uicrb2(1,2,irt)
          if(irt.eq.0) then
            print *,'    ... b2.neutrals.parameters_hybrid.2 created'
            close(2,err=22)
          else
            print *,
     .       '    Error while creating ',
     .       'b2.neutrals.parameters_hybrid.2: ',irt
          end if
       else
          write(*,*) 'No b2.neutrals.parameters_hybrid found'
          write(*,*) 'Writing b2.neutrals.parameters_hybrid.stencil'
          open(99,status='SCRATCH')
          write(99,*) '&NEUTRALS_HYBRID'
          write(99,*) '/'
          rewind(99)
          open(2,file='b2.neutrals.parameters_hybrid.stencil',err=20)
          call uicrb2(99,2,irt)
          close(99)
          if(irt.eq.0) then
            print *,'    ... b2.neutrals.parameters_hybrid.stencil ',
     .        'created'
            close(2,err=22)
          else
            print *,
     .      '    Error while creating ',
     .      'b2.neutrals.parameters_hybrid.stencil:',irt
          end if
      end if
   20 close(1,err=22)
   22 continue

      inquire(file='b2.boundary.parameters', exist=uex)
      if(uex) then
          open(1,file='b2.boundary.parameters',status='old',err=32)
          open(2,file='b2.boundary.parameters.2',err=30)
          call uicrb2(1,2,irt)
          if(irt.eq.0) then
            print *,'    ... b2.boundary.parameters.2 created'
            close(2,err=32)
          else
            print *,
     .       '    Error while creating b2.boundary.parameters.2: ',irt
          end if
       else
          write(*,*) 'No b2.boundary.parameters found'
          write(*,*) 'Writing b2.boundary.parameters.stencil'
          open(99,status='SCRATCH')
          write(99,'(a)') 'VERSION'//newversion
          write(99,*) '&BOUNDARY'
          write(99,*) '/'
          rewind(99)
          open(2,file='b2.boundary.parameters.stencil',err=30)
          call uicrb2(99,2,irt)
          close(99)
          if(irt.eq.0) then
            print *,'    ... b2.boundary.parameters.stencil created'
            close(2,err=32)
          else
            print *,
     .      '    Error while creating b2.boundary.parameters.stencil:'
     .      ,irt
          end if
      end if
   30 close(1,err=32)
   32 continue

      inquire(file='b2.user.parameters', exist=uex)
      if(uex) then
          open(1,file='b2.user.parameters',status='old',err=42)
          open(2,file='b2.user.parameters.2',err=40)
          call uicrb2(1,2,irt)
          if(irt.eq.0) then
            print *,'    ... b2.user.parameters.2 created'
            close(2,err=42)
          else
            print *,
     .       '    Error while creating b2.user.parameters.2: ',irt
          end if
       else
          write(*,*) 'No b2.user.parameters found'
          write(*,*) 'Writing b2.user.parameters'
          open(99,status='SCRATCH')
          write(99,*) '&USER'
          write(99,*) '/'
          rewind(99)
          open(2,file='b2.user.parameters',err=40)
          call uicrb2(99,2,irt)
          close(99)
          if(irt.eq.0) then
            print *,'    ... b2.user.parameters created'
            close(2,err=42)
          else
            print *,
     .      '    Error while creating b2.user.parameters:'
     .      ,irt
          end if
      end if
   40 close(1,err=42)
   42 continue

      inquire(file='../SOLPS_FLUIDS',exist=uex)
      if(.not.uex) then
        write(*,*) 'No SOLPS_FLUIDS file found'
        write(*,*) 'Writing ../SOLPS_FLUIDS'
        allocate(species_name(0:ns-1))
        is = 0
        do iatm = 1, natmi
          if (is_meta(iatm)) cycle
          species_name(is)=trim(spcsncl(iatm))//'0'
          is = is + 1
          do iss = 1, nbndl(iatm)-1
            if (izamin(is).eq.izamax(is)) then
              species_name(is)=
     .         trim(spcsncl(iatm))//'+'//int2str(izamin(is))
            else
              species_name(is)=
     .         trim(spcsncl(iatm))//'+'//int2str(izamin(is))
     .                           //'-+'//int2str(izamax(is))
            end if
            is = is + 1
          end do
        end do
        write(hlp_frm,'(a1,i3,a7)') '(',ns,'(a,1x))'
        open(unit=2,file='../SOLPS_FLUIDS')
        write(2,hlp_frm) (trim(species_name(is)),is=0,ns-1)
        close(2)
        deallocate(species_name)
      end if

      inquire(file='../NREG',exist=uex)
      if(.not.uex) then
        write(*,*) 'No NREG file found'
        write(*,*) 'Writing ../NREG'
        open(unit=2,file='../NREG')
        if (ln_cnfg) then
          write(2,'(i1,1x,i1)') 1,4
        else if (lm_cnfg) then
          write(2,'(i1,1x,i1)') 2,6
        else if (nncut.eq.1) then
          write(2,'(i1,1x,i2)') 4,13
        else if (nncut.eq.2.and.streql(topo,'DNS')) then
          write(2,'(i1,1x,i2)') 8,26
        else if (nncut.eq.2) then
          write(2,'(i1,1x,i2)') 8,27
        end if
        close(2)
      end if

c-----------------------------------------------------------------------
c*** Create additional files with geometry for b2plot

cxpb Skip this step, use ub2p program instead
cxpb      call uib2pl
c=======================================================================
      call prgend ()
      stop 'uinp'
      end program uinput
