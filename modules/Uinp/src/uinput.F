      program uinput
       use b2mod_layer
     , , only: ntrack, nalloys
       use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx

c  version : 28.01.2003 18:08

c=======================================================================
      implicit none
#include "uinput.inc"
#include "impcon.inc"
      integer irt, is, iss, iatm, iloc
      real*8, allocatable :: na0(:)
      character*20 hlp_frm
      character*60 lblps
      logical uex
      external uinnam,uintrg,uinaux
c=======================================================================
c*** Read the input data from various files
      call uininp
c*** Prepare the constants
      call uinprp

c*** Produce the input file for Eirene

      call uinout('input.eir')
      print *,'    ... input.eir created'

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
      if(uex) then
       call uinout('triang.eir')
       print *,'    ... triang.eir created'
       call triaout('triang.hed')
       call uinptridg(.FALSE.)
      end if 

c*** Create the header for the b2ag.dat file
      inquire(file='b2ag.dat', exist=uex)
      if(uex) then
          print *,'    ... b2ag.dat file already present, not created'
      else
          open(2,file='b2ag.dat')
          write(2,'(a)') '*dimens         (nx, ny; free format)'
          write(2,'(4(3x,i4))') nrplg-npplg, ndya, nrplg-npplg, ndya
          write(2,'(a)') '*param          (param(0:99); free format)'
          write(2,'(a)') ' -1.0, 99*0.0'
          write(2,'(a)') '''b2agfs_min_pitch''    ''0.01'''
          close(2)
          print *,'    ... b2ag.dat created'
      endif

c*** Create the b2ai.dat file
      inquire(file='b2ai.dat', exist=uex)
      if(uex) then
          print *,'    ... b2ai.dat file already present, not created'
      else
          allocate(na0(0:natmi+nplsi-1))
          open(2,file='b2ai.dat')
          write(2,'(a)') '*dimens         (ns; free format)'
          write(2,'(4(3x,i4))') natmi+nplsi
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
          write(2,'(a)') '*specs      za       zn       am      za2'
          is=0
          do iatm = 1, natmi
            write(2,'(2x,a1,i3,a1,5x,a3,5x,i2,a2,4x,i3,a2,6x,a3)') 
     .       '''',is,'''','0.0',nchara(iatm),'.0',
     .                          nmassa(iatm),'.0','0.0'
            na0(is) = 1.0e12
            is = is + 1
            do iss = 1, nchara(iatm)
              write(2,
     .         '(2x,a1,i3,a1,4x,i2,a2,5x,i2,a2,4x,i3,a2,3x,i4,a2)') 
     .         '''',is,'''',iss,'.0',nchara(iatm),'.0',
     .                               nmassa(iatm),'.0',iss*iss,'.0'
              na0(is) = 1.0e19
              is = is + 1
            end do
          end do
          write(2,'(a)') '*naini          (na0(0:ns-1); free format)'
          write(hlp_frm,'(a,i3,a)') '(1p,',natmi+nplsi,'(2x,e8.1))'
          write(2,hlp_frm) (na0(is),is=0,natmi+nplsi-1)
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
          write(2,'(1p,2(2x,e8.1))') 1.0e17, 1.0e22
          write(2,'(a)') '*numnuc         (nnuc; integer, free format)'
          write(2,'(2x,i2)') natmi
          write(2,'(a)') '*nucspec        '//
     .     '(nz, izlo, izhi; integers, one triplet per line)'
          do iatm = 1, natmi
            write(2,'(2x,3i3)') nchara(iatm), 0, nchara(iatm)
          end do
          write(2,'(a)') '*flag           '//
     .     '(''adpak'', ''strahl'', ''adas'' or ''amds'', free format)'
          write(2,'(2x,a)') '''adas'''
          write(2,'(a)') '*tailep         (real, free format)'
          write(2,'(2x,f5.2)') 0.08
          close(2)
          print *,'    ... b2ar.dat created'
      endif

c*** Create the header for the b2yt.dat file
      inquire(file='b2yt.dat', exist=uex)
      if(uex) then
          print *,'    ... b2yt.dat file already present, not created'
      else
          open(2,file='b2yt.dat')
          write(2,'(a)') '*dimens         (nx1, ny1; free format)'
          write(2,'(2(3x,i4))') nrplg-npplg, ndya
          close(2)
          print *,'    ... b2yt.dat created'
      endif


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
          Write(*,*) 'No b2.neutrals.parameters found'
          Write(*,*) 'Writing b2.neutrals.parameters.stencil'
          Open(99,status='SCRATCH')
          Write(99,*) '&NEUTRALS'
          Write(99,*) '/'
          Rewind(99)
          open(2,file='b2.neutrals.parameters.stencil',err=20)
          call uicrb2(99,2,irt)
          Close(99)
          if(irt.eq.0) then
            print *,'    ... b2.neutrals.parameters.stencil created'
            close(2,err=22)
          else
            print *, 
     .      '    Error while creating b2.neutrals.parameters.stencil:'
     .      ,irt
          end if
      end if
   20 close(1,err=22)
   22 continue
c-----------------------------------------------------------------------
c*** Create additional files with geometry for b2plot
      
      call uib2pl
c=======================================================================
      end
