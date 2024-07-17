      subroutine uininp
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use b2mod_subsys
      use b2mod_solpstop
      use eirmod_solps
#ifdef DIMENSIONS_MODULE
      use b2mod_dimensions
#endif
c
c  version : 23.04.99 14:36
c
c======================================================================
      implicit none
#include "uinput.inc"
#include "impcon.inc"
      integer i,j,iamd,ifile,imat,nmat,isp
      logical uex,open_file,streql,match_found,skip_wall
      character*2 listmat(nmtr)
      logical, allocatable :: trim_found(:)
      external open_file,uinnam,uintrg,uinaux,uiniamd,streql,
     .         xertst,xerrab
c======================================================================
c*** set up the input routine
c
      call subini ('uininp')
      immed=.false.
      keylen=8
      mimp=iunii
      lena=8
      jmess=2
      lfin=72
      finish = 'finish'
      promp(1) = repeat(' ',8)
      promp(2) = repeat(' ',8)
      fixkey=.false.
c
c*** Read the data from dg output
c
      write(*,*) '... opening uinput.trg'
      open(iunii,file='uinput.trg')
      call uintopo(iunii)
      call xertst (.not.(streql(topo,' ')),
     ,  'Old-style DG output. Please produce the new one -'//
     ,  ' or use uinp.1.42')
      call import(uintrg)
      write(*,*) '... opening uinput.dg'
      open(iunii,file='uinput.dg')
      call import(uinnam)
      if(ntrgte.ne.ntrgtm) then !{
        write(0,*) 'Something is wrong with target edge specification'
        write(0,*) '  ==> check the target edges in the DG model'
        call xerrab ('Wrong target edge specification')
      end if !}
      if(ntrgte.eq.0) then !{
        if(index(topo,'SN').eq.0) then !{
          write(0,*) 'Magnetic configuration inconsistent with old-',
     ,               'style specification of the target edges'
          write(0,*) '  ==> Add "Target specification" in the DG model'
          call xerrab ('Inconsistent magnetic configuration')
        end if !}
        jedgep(1)=jedgeo(2)
        jedgep(2)=jedgeo(3)
        jedgec(1)=jedgeo(1)
        jedgec(2)=jedgeo(4)
      end if !}
c
c*** Read the auxiliary, user data
c
      inquire(file='uinput.aux', exist=uex)
      if(uex) then !{
        write(*,*) '... opening uinput.aux'
        open(iunii,file='uinput.aux')
        call import(uinaux)
      end if !}
      nmat=0
      do i=1,nlimi !{
        skip_wall=.false.
        j=0
        do while (.not.skip_wall.and.j.lt.nlimi.and.jadch0(j+1).ne.0)
          j=j+1
          skip_wall=jadch0(j).eq.i
        end do
        if (skip_wall) cycle
        match_found=.false.
        do imat=1,nmat !{
          match_found=match_found .or.
     .      streql(listmat(imat),umtrl(i)) .or.
     .     (streql(listmat(imat),'Fe') .and. streql(umtrl(i),'SS')) .or.
     .      streql(umtrl(i),'dummy')
        end do !}
        if (.not.match_found) then !{
          nmat=nmat+1
          if (streql(umtrl(i),'SS')) then !{
            listmat(nmat)='Fe'
          else !}{
            listmat(nmat)=umtrl(i)(1:2)
          end if !}
        end if !}
        if (trnspa(i,1).gt.0.0_R8 .and. trnspa(i,2).gt.0.0_R8) then !{
          if (jlside(i).ne.0) then !{
            write(0,*) '(Semi-)Transparent surfaces must allow '//
     ,                 'particles arriving from both sides (JLSIDE = 0)'
            write(0,*) 'STOP ==> Check your DG model for wall index ',i
            call xerrab ('Inconsistent surface data !')
          end if !}
        end if !}
        if (jlsptp(i).eq.9) then !{ Special Be re-sputtering model
          match_found = .false.
          do isp=1,nspigen !{
            if (match_found) cycle
            match_found = streql('Be',spcigen(isp))
            if (match_found) then !{ Only Be physical sputtering
              jsrss(i)=isp
              jsrc(i)=0
              jlsptc(i)=0
            end if !}
          end do !}
          if (.not.match_found) then !{
            write(0,*) 'Beryllium re-sputtering model requested, '//
     ,                 'but no Be species is declared !'
            write(0,*) 'STOP ==> Check your DG model for wall index ',i
            call xerrab ('Missing Be species declaration !')
          end if !}
          match_found=.false.
          do imat=1,nmat !{
            match_found=match_found.or.streql(listmat(imat),'Be')
          end do !}
          if (.not.match_found) then !{
            nmat=nmat+1
            listmat(nmat)='Be'
          end if !}
        else if (jlsptp(i).ne.0 .and. jsrss(i).eq.0) then !}{
          match_found = .false.
          do isp=1,nspigen !{
            if (match_found) cycle
            if (streql(umtrl(i),'SS')) then !{
              match_found = streql('Fe',spcigen(isp))
            else !}{
              match_found = streql(umtrl(i),spcigen(isp))
            end if !}
          end do !}
          if (.not.match_found) then !{
            write(0,*) 'Sputtering of wall material requested, '//
     ,                 'but no matching species is declared !'
            write(0,*) 'STOP ==> Check your DG model for wall index ',i
            call xerrab ('Sputtering of undeclared wall material !')
          end if !}
        end if !}
      end do !}
      do i=1,ntrgdflt !{
        match_found=.false.
        do imat=1,nmat !{
          match_found=match_found .or.
     .       streql(listmat(imat),made_of(i)) .or.
     .      (streql(listmat(imat),'Fe') .and. streql(made_of(i),'SS'))
        end do !}
        if (.not.match_found) then !{
          nmat=nmat+1
          if (streql(made_of(i),'SS')) then !{
            listmat(nmat)='Fe'
          else !}{
            listmat(nmat)=made_of(i)(1:2)
          end if !}
        end if !}
      end do !}
      do i=1,ntrgte !{
        if (tgsppsw(i).eq.9) then !{ Special Be re-sputtering model
          match_found = .false.
          do isp=1,nspigen !{
            if (match_found) cycle
            match_found = streql('Be',spcigen(isp))
            if (match_found) then !{ Only Be physical sputtering
              tgsppsp(i)=isp
              tgspcsw(i)=0
              tgspcgr(i)=0
            end if !}
          end do !}
          if (.not.match_found) then !{
            write(0,*) 'Beryllium re-sputtering model requested, '//
     ,                 'but no Be species is declared !'
            write(0,*) 'STOP ==> Check your DG model for target index ',
     ,                  i
            call xerrab ('Missing Be species declaration !')
          end if !}
          match_found=.false.
          do imat=1,nmat !{
            match_found=match_found.or.streql(listmat(imat),'Be')
          end do !}
          if (.not.match_found) then !{
            nmat=nmat+1
            listmat(nmat)='Be'
          end if !}
        end if !}
      end do !}
      do i=1,n_spcsrf !{
        match_found=.false.
        do imat=1,nmat !{
          match_found=match_found .or.
     .       streql(listmat(imat),sps_mtrl(i)) .or.
     .       streql(sps_mtrl(i),'-') .or.
     .      (streql(listmat(imat),'Fe') .and. streql(sps_mtrl(i),'SS'))
        end do !}
        if (.not.match_found) then !{
          nmat=nmat+1
          if (streql(sps_mtrl(i),'SS')) then !{
            listmat(nmat)="Fe"
          else !}{
            listmat(nmat)=sps_mtrl(i)(1:2)
          end if !}
        end if !}
      end do !}
      match_found=.false.
      do imat=1,nmat !{
        match_found=match_found .or. streql(listmat(imat),'C')
      end do !}
      if (.not.match_found) nnftrm=0
      match_found=.false.
      do isp=1,nspigen !{
        match_found=match_found .or. streql(spcigen(isp),'D')
      end do !}
      if (.not.match_found) nnftrm=0
      ifile = 0
      if (nspigen.gt.1 .or. .not.streql(spcigen(nspigen),'D') .or.
     .     nmat.gt.1   .or. .not.streql(listmat(nmat),'C')) then !{
        do isp=1,nspigen !{
          do imat=1,nmat !{
            if (.not.(streql(spcigen(isp),'D') .and.
     .                streql(listmat(imat),'C'))) then !{
              ifile = ifile + 1
              filtrm(nnftrm+ifile)=
     .          trim(spcigen(isp))
     .          //'_on_'//
     .          listmat(imat)
            end if !}
          end do !}
        end do !}
      end if !}
      nnftrm = nnftrm+ifile
      allocate(trim_found(nnftrm))
      do ifile=1,nnftrm
        inquire(file=filtrm(ifile),exist=trim_found(ifile))
        if(.not.trim_found(ifile)) inquire(file=trim(solpstop())
     .   //'/modules/Eirene/Database/Surfacedata/TRIM/'
     .   //trim(filtrm(ifile)),exist=trim_found(ifile))
        if(.not.trim_found(ifile)) inquire(file=trim(solpstop())
     .   //'/data.local/TRIM/'//trim(filtrm(ifile)),
     .   exist=trim_found(ifile))
      end do
      j=0
      do ifile=nnftrm,1,-1
        if (.not.trim_found(ifile)) then
          write(*,*) 'Did not find TRIM file ',trim(filtrm(ifile)),
     .               '. Removing from list...'
          do i = ifile+1, nnftrm-j
            filtrm(i-1)=filtrm(i)
          end do
          j=j+1
        end if
      end do
      nnftrm = nnftrm - j
      deallocate(trim_found)

      ammonx_used=.false.
      meta_used=.false.
      no_n2_model=.true.
      do iamd=1,namdf !{
        if(.not.streql(amd_file(iamd),' ')) then !{
c*** Read the AMDS file if it exists
          inquire(file=amd_file(iamd), exist=uex)
          if(uex) then !{
            write(*,*) '... opening ',amd_file(iamd)
            open(iunii,file=amd_file(iamd))
          else !}{
            uex=open_file(iunii,amd_file(iamd),
     .               'data.local/AMDS|data.local/amds|modules/amds')
          end if !}
          if(uex) then !{
            uex=immed
            call import(uiniamd)
            immed=uex
            rctndflt=.false.
          else !}{
            write(0,*) 'AMDS file not found: ',amd_file(iamd)
            write(0,*) 'STOP ==> Check the references to AMDS in the ',
     ,                 'DG model and make sure that the file exists '
            write(0,*) '   in either $SOLPSTOP/modules/amds or ',
     ,                          '$SOLPSTOP/data.local/(amds|AMDS) or ',
     ,                          'or the current directory'
            call xerrab ('AMDS file not found')
          end if !}
          close(iunii)
        end if !}
      end do !}
      if (.not.no_n2_model)
     > write(6,*) 'This case contains the N2 molecular model'
      if (meta_used)
     > write(6,*) 'This case includes metastable species'
c*** Add explicitly 3rd product in selected reactions
      do i=1,nnrctn !{
        if (streql(rctndbs(i),'AMMONX') .and.
     &      streql(rctnrct(i),'DD')) then !{
          rctnpto3(i)='H'
          rctnnmo3(i)=1
        end if !}
      end do !}
c======================================================================
      call subend ()
      return
      end subroutine uininp
