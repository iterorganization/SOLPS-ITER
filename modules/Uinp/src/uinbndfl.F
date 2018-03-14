      subroutine uinbndfl
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx
c
c  version : 01.04.2005 14:27
c
c=======================================================================
c*** Fill in the default boundary data
c=======================================================================
      implicit none
#include "uinpcom.inc"
      integer i,j,k,l,n,isp,iknd,izn,igs_hlp(nspdgen)
      logical ex,uex,hlp_fl1,hlp_fl2
      real hlp_f1
      character hlp_c*2
      integer find_matching_species
      logical streql
      external streql, xertst, subini, subend, find_matching_species
c=======================================================================
      call subini ('uinbndfl')
c*** Determine the default source scaling relations
#ifdef DBG
      print *,'uinbndfl: nspcncl =',nspcncl
#endif
      do l=1,nspcncl !{
        j=0
        j=find_matching_species(spcsncl(l))
c        print *,'l,j,spcsncl =',l,j,'  ',spcsncl(l)
        ex=.false.
        uex=.false.
        if(j.gt.0) then !{
c          print *,'j.gt.0. dscbndx = ',dscbndx(j)
          if(streql(dscbndx(j),'-')) then !{
            igs_hlp(l)=0
          else if(streql(dscbndx(j),'?')) then !}{
            igs_hlp(l)=-1
          else if(streql(dscbndx(j),'*')) then !}{
c*** Hydrogen species
            do k=1,3 !{
              do i=1,nspcncl !{
                if(streql(spcsncl(i),spcdgen(k))) then !{
                  if(ex) then !{
                    write(*,*) 'Ambiguous hydrogen species - no ',
     ,                'scaling with generic hydrogen !!!'
                    igs_hlp(l)=0
                  else !}{
                    igs_hlp(l)=i
                    ex=.true.
                  end if !}
                end if !}
              end do !}
            end do !}
          else !}{
            uex=.true.
          end if !}
        end if !}
c       print *,'l,ex,igs_hlp =',l,ex,igs_hlp(l)
        if(uex) then !{
          if(j.eq.0) then !{
            igs_hlp(l)=l
          else if(streql(dscbndx(j),'=')) then !}{
            igs_hlp(l)=l
          else !}{
            hlp_c=dscbndx(j)
            ex=.false.
            do i=1,nspcncl !{
              if(streql(spcsncl(i),hlp_c)) then !{
                igs_hlp(l)=i
                ex=.true.
              end if !}
            end do !}
            if(.not.ex) then !{
              do i=1,nspcncl !{
                if(streql(spcsncl(i),hlp_c)) ex=.true.
              end do !}
              if(ex) write(*,*) 'No species ',hlp_c,' found - ',
     ,          'no scaling for ',spcsncl(j)
              igs_hlp(l)=0
              spcsscn(i)=0
            end if !}
          end if !}
        end if !}
      end do !}
      print '(1x,a,20i5)','Finally, igs_hlp =',(igs_hlp(i),i=1,nspcncl)

c*** Set the data

      do iknd=1,nbndknd !{
        do izn=1,nznbndt(iknd) !{
          if(.not.bxsbndt(izn,iknd)) then !{
            if(iknd.eq.2 .and. tgdtinpt) then !{
c*** Take the neutral data from the "whole target" specification
              k=lrfbndt(izn,iknd)
              ewmbnds(izn,iknd)=made_of(k)
              jskbnds(izn,iknd)=1
              jrfbnds(izn,iknd)=tgrefsw(k)
              jcsbnds(izn,iknd)=tgspcsw(k)
              jcgbnds(izn,iknd)=tgspcgr(k)
              jpsbnds(izn,iknd)=tgsppsw(k)
              jppbnds(izn,iknd)=tgsppsp(k)
              jnpbnds(izn,iknd)=tgnhst(k)
              jmpbnds(izn,iknd)=tgmhst(k)
              jnibnds(izn,iknd)=tgnini(k)
              etfbnds(izn,iknd)=tgtrnsf(k)
              etbbnds(izn,iknd)=tgtrnsb(k)
              easbnds(izn,iknd)=tgabsrp(k)
              eewbnds(izn,iknd)=tgewall(k)
              efpbnds(izn,iknd)=tgsppff(k)
              efcbnds(izn,iknd)=tgspcff(k)
            else !}{
c*** Take the data from the boundary default
              ewmbnds(izn,iknd)=ewmbndx(0,iknd)
              jskbnds(izn,iknd)=jskbndx(0,iknd)
              jrfbnds(izn,iknd)=jrfbndx(0,iknd)
              jcsbnds(izn,iknd)=jcsbndx(0,iknd)
              jcgbnds(izn,iknd)=jcgbndx(0,iknd)
              jpsbnds(izn,iknd)=jpsbndx(0,iknd)
              jnpbnds(izn,iknd)=jnpbndx(0,iknd)
              jmpbnds(izn,iknd)=jmpbndx(0,iknd)
              jnibnds(izn,iknd)=jnibndx(0,iknd)
              etfbnds(izn,iknd)=etfbndx(0,iknd)
              etbbnds(izn,iknd)=etbbndx(0,iknd)
              easbnds(izn,iknd)=easbndx(0,iknd)
              eewbnds(izn,iknd)=eewbndx(0,iknd)
              efpbnds(izn,iknd)=efpbndx(0,iknd)
              efcbnds(izn,iknd)=efcbndx(0,iknd)
            end if !}
            jclbnds(izn,iknd)=jclbndx(0,iknd)
            jnebnds(izn,iknd)=jnebndx(0,iknd)
            esibnds(izn,iknd)=esibndx(0,iknd)
            esebnds(izn,iknd)=esebndx(0,iknd)
            leebnds(izn,iknd)=leebndx(0,iknd)
            leibnds(izn,iknd)=leibndx(0,iknd)
            lpobnds(izn,iknd)=lpobndx(0,iknd)
            beebnds(izn,1,iknd)=beebndx(0,1,iknd)
            beibnds(izn,1,iknd)=beibndx(0,1,iknd)
            bpobnds(izn,1,iknd)=bpobndx(0,1,iknd)
            beebnds(izn,2,iknd)=beebndx(0,2,iknd)
            beibnds(izn,2,iknd)=beibndx(0,2,iknd)
            bpobnds(izn,2,iknd)=bpobndx(0,2,iknd)
            do isp=1,nspcpls !{
              l=spcsrnp(isp)
              ex=.true.
              k=find_matching_species(spcsncl(l))
              if(k.gt.0) then !{
                if(ex) then !{
c*** Take the default for the generic species
                  j=1
                  if(isp.eq.nspcpls) then  ! to avoid array bound overflow
                    j=2
                  else if (l.ne.spcsrnp(isp+1)) then
                    j=2
                  endif
                  lcobnds(isp,izn,iknd)=kcobndx(k,iknd,j)
                  lmobnds(isp,izn,iknd)=kmobndx(k,iknd,j)
                  bcobnds(isp,izn,1,iknd)=dcobndx(k,1,iknd,j)
                  bmobnds(isp,izn,1,iknd)=dmobndx(k,1,iknd,j)
                  bcobnds(isp,izn,2,iknd)=dcobndx(k,2,iknd,j)
                  bmobnds(isp,izn,2,iknd)=dmobndx(k,2,iknd,j)
                  ex=.false.
                end if !}
              end if !}
              if(ex) then !{
                lcobnds(isp,izn,iknd)=lcobndx(isp,0,iknd)
                lmobnds(isp,izn,iknd)=lmobndx(isp,0,iknd)
                bcobnds(isp,izn,1,iknd)=bcobndx(isp,0,1,iknd)
                bmobnds(isp,izn,1,iknd)=bmobndx(isp,0,1,iknd)
                bcobnds(isp,izn,2,iknd)=bcobndx(isp,0,2,iknd)
                bmobnds(isp,izn,2,iknd)=bmobndx(isp,0,2,iknd)
              end if !}
            end do !}
            nlrbnds(izn,iknd)=nlrbndx(0,iknd).ne.0
            do i=1,nspcncl !{
              lscbnds(i,izn,iknd)=igs_hlp(i)*spcsscn(i)
            end do !}
          end if !}
        end do !}
      end do !}
c*** Check for input data for generic species
      iknd=1
      n=nznbndt(iknd)
#ifdef DBG
      print *,'uinbndfl: nspcpls,n =',nspcpls,n
#endif
      ex=.true.
      do isp=1,nspcpls !{
        l=spcsrnp(isp)
#ifdef DBG
        print *,'ex,isp,l,spcscrk,spcscrf',ex,isp,l,
     ,                                            spcscrk(l),spcscrf(l)
#endif
        if(spcscrk(l).ne.0) then !{
          if(spcscrk(l).lt.0 .or. spcscrk(l).gt.3) then !{
            print *,'uinbndfl: wrong value of the core BC kind for ',
     ,          spcsatm(l),'.  Should be between 0 and 3, is',spcscrk(l)
            ex=.false.
          else if(ex) then !}{
            hlp_fl1=spcscrk(l).eq.3
            hlp_fl2=spcscrk(l).ne.2
#ifdef DBG
            print *,'spcscrk,hlp_fl1,hlp_fl2',spcscrk(l),hlp_fl1,hlp_fl2
#endif
            if((hlp_fl1 .or. hlp_fl2) .and. n.gt.1 .and. 
     .                                 (n.gt.2 .or. nncut.ne.4)) then !{
              print*,'uinbndfl: CEI partitioning is not foreseen yet.'
              ex=.false.
            end if !}
            if(ex) then !{
c*** uex: the highest ionisation state for this species
              uex=isp.eq.nspcpls  ! to avoid array bound overflow
              if (.not.uex) uex=spcsrnp(isp+1).ne.l
#ifdef DBG
              print *,'uex,isp,l,spcsrnp',uex,isp,l,spcsrnp(isp+1)
#endif
              if(n.eq.1) then !{
                hlp_f1=1
              else !}{
                hlp_f1=spcscrf(l)
              end if !}
              do izn=1,nznbndt(iknd) !{
                if(uex) then !{
                  if(hlp_fl1) then !{
                    lcobnds(isp,izn,iknd)=8
                    bcobnds(isp,izn,1,iknd)=hlp_f1*spcscrp(l)
                  else !}{
                    lcobnds(isp,izn,iknd)=1
                    bcobnds(isp,izn,1,iknd)=spcscrp(l)
                  end if !}
                else !}{
                  if(hlp_fl2) then !{
                    lcobnds(isp,izn,iknd)=8
                    bcobnds(isp,izn,1,iknd)=0
                  else !}{
                    lcobnds(isp,izn,iknd)=1
                    bcobnds(isp,izn,1,iknd)=0
                  end if !}
                end if !}
                bcobnds(isp,izn,2,iknd)=0
                hlp_f1=1-hlp_f1
              end do !}
            end if !}
          end if !}
        end if !}
      end do !}
      call xertst (ex, 
     . '== Error(s) found in uinbndfl - check the DG model')
#ifdef DBG
      print *,' ... leaving uinbndfl'
#endif
c=======================================================================
      call subend ()
      return
      end

      integer function find_matching_species(name)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx
      use b2mod_elements
      implicit none
#     include "uinpcom.inc"
      character*2 name, str_name
      integer i
      logical streql, isadigit, isplusorminus
      external streql, isadigit, isplusorminus

      find_matching_species = 0
      str_name = name
      if (name(2:2).eq.'*'.or.isadigit(name(2:2)).or.
     &    isplusorminus(name(2:2))) str_name(2:2)=' '
      do i = 1, nspdgen-2
        if(streql(str_name,spcdgen(i))) then
          find_matching_species = i
          return
        end if
      end do
      do i = 1, 92
        if(streql(str_name,elements(i))) then
          if (i.eq. 8 .or. i.eq.16 .or. i.eq.17 .or.
     &        i.eq.36 .or. i.eq.54 .or. i.eq.88) then ! gases: O, Cl, Ar, Kr, Xe, Ra
            find_matching_species = nspdgen-1
          else
            find_matching_species = nspdgen
          end if
        end if
      end do

      return
      end function find_matching_species

      integer function find_matching_reagent(name)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx
      use b2mod_elements
      implicit none
#     include "uinpcom.inc"
      character*8 name, species_name
      integer i
      integer nplus
      integer lnblnk
      logical streql, isplusorminus
      external streql, lnblnk, isplusorminus, strip_spaces

      find_matching_reagent = 0
      do i = 1, nsrctd
        if(streql(name,spcrctd(i))) then
          find_matching_reagent = i
          return
        end if
      end do
      nplus=0
      if (index(name,'+').eq.0) then
        do i = 1, 92
          if(streql(name,elements(i))) then
            find_matching_reagent = nsrctd-1
          end if
        end do
      else if (index(name,'+').gt.0) then
        species_name=repeat(' ',8)
        do i = 1, lnblnk(name)
          if (isplusorminus(name(i:i))) then
            if (nplus.eq.0) species_name(i:i) = ' '
            nplus=nplus+1
          else
            species_name(i:i) = name(i:i)
          end if
        end do
        call strip_spaces(species_name)
        do i = 1, 92
          if(streql(species_name(1:2),elements(i)).and.nplus.eq.1) then
            find_matching_reagent = nsrctd
          end if
        end do
      end if

      return
      end function find_matching_reagent

      integer function get_atomic_number(name)
      use b2mod_elements
      implicit none
      character*(*) name
      character*8 species_name
      integer i
      logical skip, openp
      integer lnblnk
      logical streql, isadigit, isplusorminus
      external streql, lnblnk, isadigit, isplusorminus, strip_spaces

      get_atomic_number = 0
      species_name = repeat(' ',8)
      openp = .false.
      do i = 1, lnblnk(name)
        if (.not.openp) then
          skip = .false.
          skip = skip .or. isadigit(name(i:i))
          skip = skip .or. isplusorminus(name(i:i))
          skip = skip .or. name(i:i).eq.'*'
          openp = name(i:i).eq.'('
        else
          openp = name(i:i).ne.')'
          skip = .true.
        endif
        skip = skip .or. openp
        if (.not.skip) species_name(i:i) = name(i:i)
      end do
      call strip_spaces(species_name)
      do i = 1, 92
        if(streql(species_name(1:2),elements(i))) then
          get_atomic_number = i
          return
        end if
      end do
      if (streql(species_name,'D').or.
     &    streql(species_name,'T')) get_atomic_number=1

      return
      end function get_atomic_number
