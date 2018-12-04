      subroutine uinpsrcg
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
c
c  version : 01.04.2005 00:51
c
c=======================================================================
c*** Prepare the gas puffing sources.
c=======================================================================
      implicit none
#include "uinput.inc"
      integer i,j,k,l,isg,istr,isf
      logical ex,uex,streql
      external streql, xerrab, subini, subend
c=======================================================================
      call subini ('uinpsrcg')
c<<<
      print *,'uinpsrcg: ngpfstr=',ngpfstr
c>>>
      isg=0
      do istr=1,ngpfstr !{

        nstrai=nstrai+1
        indsrc(nstrai)=-1
        ingpfstr(istr)=nstrai
c<<<
        print '(a,2i3,i6,i4,1p,1e12.4,1x,a)',
     ,   'istr,nstrai,npts,kgpfstr,tgpfstr,cgpfstrs:',
     ,    istr,nstrai,npts(nstrai),kgpfstr(istr),tgpfstr(istr),
     ,    cgpfstrs(istr)
c>>>
        if(nstrai.ge.nstra) then !{
          write(0,*) 'Too many strata requested (gas puff',istr,') : ',
     ,               nstrai
          write(0,*) 'STOP ==> check the DG model and the value of ',
     ,      'DEF_NSTRA in DIMENSIONS.F'
          call xerrab ('Too many gas puff strata requested')
        end if !}
        if(kgpfstr(istr).gt.nsrfs) then !{
          write(0,*) 'Too many segments requested (gas puff ',istr,
     ,               ') : ',kgpfstr(istr)
          write(0,*) 'A gas puffing source cannot span over more than ',
     ,               nsrfs,' wall segments'
          write(0,*) 'STOP ==> check the DG model and the value of ',
     ,         'DEF_NSRFS in DIMENSIONS.F'
          call xerrab ('Too many gas puff segments requested')
        end if !}
        if(kgpfstr(istr).le.0) then !{
          write(0,*) 'No segments specified (gas puff ',istr,
     ,               ') : ',kgpfstr(istr)
          write(0,*) 'A gas puffing source must span over at least ',
     ,               'one wall segment'
          call xerrab
     .     ('==> This should not be allowed in DG - wrong set-up?')
        end if !}
        nsrfsi(nstrai)=kgpfstr(istr)

        write(txtsou(nstrai),*)  'Gas puffing source ',istr,' : ',
     ,        cgpfstrs(istr)
        npts(nstrai)=npgpfstr(istr)
        nminpts(nstrai)=mpgpfstr(istr)
        if(npts(nstrai).lt.0) npts(nstrai)=10000
        ninitl(nstrai)=nigpfstr(istr)
        if(ninitl(nstrai).eq.0) ninitl(nstrai)=6001
        if(soreni(nstrai).eq.0) soreni(nstrai)=tgpfstr(istr)
        if(soreni(nstrai).eq.0) soreni(nstrai)=tgpfstd
        if(soreni(nstrai).gt.0) then !{
          nemods(nstrai)=1
        else !}{
          nemods(nstrai)=116
          soreni(nstrai)=-soreni(nstrai)
        end if !}
        namods(nstrai)=jgpfstr(istr)
        sorcos(nstrai)=pgpfstr(istr)

        call uinspcid(cgpfstrs(istr),l,k)
        if(l.le.0 .or. l.gt.2) then !{
          write(0,*) 'Wrong particle specification for gas puffing ',
     ,               'source ',istr,' : ',cgpfstrs(istr)
          write(0,*) '(must be either atom or molecule)'
          call xerrab ('==> Check the DG model')
        end if !}
        nlatm(nstrai)=l.eq.1
        nlmol(nstrai)=l.eq.2
        nlpls(nstrai)=.false.
        nspez(nstrai)=k

        do isf=1,nsrfsi(nstrai) !{
          isg=isg+1
          k=lgpfstr(isg)
          i=indasrfs(indasrfe(k))
          if(k.le.0) then !{
            write(0,*) 'Wrong segment specification for gas puffing ',
     ,                 'source ',istr,', segment',isf,' : ',k
            call xerrab
     .       ('==> This should not be allowed in DG - wrong set-up?')
          end if !}
          if(indasrfe(k).le.0) then !{
            write(0,*) 'Wrong segment specification for gas puffing ',
     ,             'source ',istr,' : ',isf,k
            write(0,*) 'The segment should not belong to the ',
     ,             '"Elements not for Eirene"'
            call xerrab ('==> Check the DG model')
          end if !}
          insor(isf,nstrai)=indasrfe(k)
          if (jlplg(i).ne.0) then !{ gas puff source on contour
            indim(isf,nstrai)=4
            ingrda(isf,nstrai,1)=1
            ingrde(isf,nstrai,1)=1
            ingrda(isf,nstrai,2)=1
            ingrde(isf,nstrai,2)=1
            nasor(isf,nstrai)=0
            sorlim(isf,nstrai)=4
            sorad1(isf,nstrai)=0
            sorad2(isf,nstrai)=0
            sorad3(isf,nstrai)=0
            sorad4(isf,nstrai)=0
          else !}{ gas puff source on free-floating surface
            indim(isf,nstrai)=0
            nrsor(isf,nstrai)=0
            ingrda(isf,nstrai,1)=0
            ingrde(isf,nstrai,1)=0
            ingrda(isf,nstrai,2)=0
            ingrde(isf,nstrai,2)=0
            if (p1(1,i).eq.p2(1,i)) then !{
              if (p1(2,i).le.p2(2,i)) then !{
                sorad1(isf,nstrai)=p1(1,i)
                sorad2(isf,nstrai)=p2(1,i)
                sorad3(isf,nstrai)=p1(2,i)
                sorad4(isf,nstrai)=p2(2,i)
              else !}{
                sorad1(isf,nstrai)=p2(1,i)
                sorad2(isf,nstrai)=p1(1,i)
                sorad3(isf,nstrai)=p2(2,i)
                sorad4(isf,nstrai)=p1(2,i)
              end if !}
              sorlim(isf,nstrai)=1
            else
              if (p1(1,i).le.p2(1,i)) then !{
                sorad1(isf,nstrai)=p1(1,i)
                sorad2(isf,nstrai)=p2(1,i)
                sorad3(isf,nstrai)=p1(2,i)
                sorad4(isf,nstrai)=p2(2,i)
              else !}{
                sorad1(isf,nstrai)=p2(1,i)
                sorad2(isf,nstrai)=p1(1,i)
                sorad3(isf,nstrai)=p2(2,i)
                sorad4(isf,nstrai)=p1(2,i)
              end if !}
              if (p1(2,i).eq.p2(2,i)) then !{
                sorlim(isf,nstrai)=2
              else !}{
                sorlim(isf,nstrai)=0
              end if !}
            end if !}  
            if (sorad3(isf,nstrai).eq.sorad4(isf,nstrai)) then !{
              sorlim(isf,nstrai)=sorlim(isf,nstrai)+10
            else !}{
              sorlim(isf,nstrai)=sorlim(isf,nstrai)+20
            end if !}
          end if !}
          if (nltrz) then !{
            sorlim(isf,nstrai)=sorlim(isf,nstrai)+100
          else !}{
            sorlim(isf,nstrai)=sorlim(isf,nstrai)+200
            sorad5(isf,nstrai)=0.0
            sorad6(isf,nstrai)=360.0
          end if !}
          sorifl(isf,nstrai)=1000
        end do !}
c*** Source composition - for gpfc
        do i=1,nspcncl !{
          if(nlmol(nstrai)) then !{
            k=nspez(nstrai)
            igpfstr(i,istr)=spcscmm(i,k)
          else !}{
            igpfstr(i,istr)=0
          end if !}
        end do !}
        if(nlatm(nstrai)) then !{
          k=spcsrna(nspez(nstrai))
          igpfstr(k,istr)=1
        end if !}
c*** lstrascl
        do i=1,nspcncl !{
          ex=.false.
          do j=1,natm !{
            if(streql(srcmstrs(j,istr),spcsncl(i))) then !{
              if(ex) then !{
                write(0,*)
     ,           'Ambiguous definition of source scaling for ',
     ,           'the gas puffing source ',istr
                call xerrab
     .           ('==> Check "Gas puff" variables in the DG model')
              end if !}
              do k=1,nspcncl !{
                if(streql(spcsncl(k),wrcmstrs(j,istr))) then !{
                  lsgpfstr(i,istr)=k*spcsscn(i)
#ifdef DBG
                  print *,'uinpsrcg: k,i,j,istr,lsgpfstr,spcsscn=',
     ,                               k,i,j,istr,lsgpfstr(i,istr),
     ,                                                   spcsscn(i)
#endif
                end if !}
              end do !}
            end if !}
          end do !}
          if(.not.ex) then !{
            uex=.false.
            do k=1,nspcncl !{
              if(igpfstr(k,istr).gt.0) then !{
                if(.not.ex) lsgpfstr(k,istr)=k*spcsscn(k)
                uex=ex
                ex=.true.
              else !}{
                lsgpfstr(k,istr)=0
              end if !}
            end do !}
            if(uex) then !{
              write(0,*) 'Default source scaling cannot be used for a ',
     ,          'compound puffing source ',istr
              write(0,*) ' ==> no source scaling for stratum/species ',
     ,          istr,i
              lsgpfstr(i,istr)=0
            end if !}
          end if !}
        end do !}

      end do  !} istr
c=======================================================================
      call subend ()
      return
      end
