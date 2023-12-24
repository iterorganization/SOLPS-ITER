      subroutine uinbnddt
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use b2mod_subsys
      use eirmod_solps
#ifdef DIMENSIONS_MODULE
      use b2mod_dimensions
#endif
c
c  version : 01.04.2005 00:12
c
c=======================================================================
c*** Prepare the boundary data ("non-default surfaces" and recycling
c*** sources) for the Eirene input file
c=======================================================================
      implicit none
#include "uinput.inc"
      integer ibk,isf,iatm,ispe,ispi,ndt,i,k
      external xerrab
c=======================================================================
      call subini ('uinbnddt')

      nstsi=0
      nstrai=0
      ntargi=0

c*** Follow the boundary kinds: core, targets, PFR, outer edge
      ndt = 0 !nh initialization of ndt for the wg format
      do ibk=1,nbndknd !{
        do isf=1,nznbndt(ibk) !{
c*** First, non-default surface...
          nstsi=nstsi+1
          ndt = ndt-1
          if(nstsi.ge.nsts) then !{
            write(0,*) 'Too many "non-default surfaces" are specified.',
     ,                                 '  ',ctxbnds(ibk),',  zone',isf
            write(0,*) 'STOP ==> Check the boundary specification in ',
     ,                           'DG and parameter NSTSI in KOPPLDIM.F'
            call xerrab ('Too many non-default surfaces')
          end if !}
          write(txtsfl(nstsi),'(a10,i4)') ctxbnds(ibk),isf
          bliin(nstsi)=bbliin(isf,ibk)
          inump(nstsi)=jcpbnds(isf,ibk)
!nh          irpta1(nstsi)=jc1bnds(isf,ibk)
!nh          irpte1(nstsi)=jc2bnds(isf,ibk)
          ifclbla(nstsi)=lc1bnds(isf,ibk)  !nh face label needed for triangulation
          ifclble(nstsi)=lc2bnds(isf,ibk)
          iliin(nstsi)=jskbnds(isf,ibk)
          ilcol(nstsi)=jclbnds(isf,ibk)
          if(iliin(nstsi).eq.2) then !{
            ilside(nstsi)=jdrbnds(isf,ibk)
          else !}{
            ilside(nstsi)=0
          end if !}
c          print *,'uinbnddt: isf,ibk,nstsi,cskbnds,iliin,ilside =',!###
c     ,      isf,ibk,nstsi,' ',cskbnds(isf,ibk),' ',                !###
c     ,      iliin(nstsi),ilside(nstsi)                             !###
          if(cskbnds(isf,ibk).eq.'W' .or.
     ,                                  cskbnds(isf,ibk).eq.'E') then !{
            idimp(nstsi)=1 !nh always 1 for unstructured version
            ilswch(nstsi)=0
          else if(cskbnds(isf,ibk).eq.'S' .or.
     ,                                 cskbnds(isf,ibk).eq.'N') then !}{
            idimp(nstsi)=1
            if(cskbnds(isf,ibk).eq.'S') then !{
              ilswch(nstsi)=0
            else !}{
              ilswch(nstsi)=0
            end if !}
          else !}{
            write(0,*) 'Wrong boundary letter ',cskbnds(isf,ibk),'.  ',
     ,                                        ctxbnds(ibk),',  zone',isf
            call xerrab ('*** Internal error in Uinp !!!')
          end if !}
          if((iliin(nstsi).gt.0 .and. iliin(nstsi).lt.10) .or.
     .                                             bliin(nstsi)) then !{
            if(iliin(nstsi).gt.0) then !{
              ilswch(nstsi)=0
              if(cskbnds(isf,ibk).eq.'W' .or.
     .                                  cskbnds(isf,ibk).eq.'S') then !{
                ilside(nstsi)=2
              else !}{
                ilside(nstsi)=2
              end if !}
            end if !}
            if(iliin(nstsi).eq.1 .or. bliin(nstsi)) then !{
c*** ... set up the material properties
              if(bliin(nstsi)) then !{
                xmlim(nstsi)= wlmbnds(isf,ibk)
              else !}{
                call uinmtr(ewmbnds(isf,ibk),nstsi,1)
              end if !}
              ewall(nstsi)= eewbnds(isf,ibk)
              ilsptc(nstsi)= jcsbnds(isf,ibk)
              isrsg(nstsi)= jcgbnds(isf,ibk)
              ilsptp(nstsi)= jpsbnds(isf,ibk)
              isrss(nstsi)= jppbnds(isf,ibk)
              recycc(nstsi)= efcbnds(isf,ibk)
              recycs(nstsi)= efpbnds(isf,ibk)
              ilref(nstsi)= jrfbnds(isf,ibk)
              recyct(nstsi)= 1-easbnds(isf,ibk)
              transp(nstsi,1)= etfbnds(isf,ibk)
              transp(nstsi,2)= etbbnds(isf,ibk)
              arefcell(nstsi) = rfcbnds(isf,ibk)
              arfpress(nstsi) = rfpbnds(isf,ibk)
            end if !}
          end if !}
c*** ... and then the recycling source if specified
          if(nlrbnds(isf,ibk)) then !{
           ispe=0
           do iatm=1,natmi !{ Split the strata per species
            if(is_meta(iatm)) cycle
            nstrai=nstrai+1
            ispi=ispe+1
            ispe=ispi
            do while (lkindp(min(ispe+1,nplsi)).eq.lkindp(ispi)) !{
              ispe=ispe+1
              if (ispe.gt.nplsi) then !{
                ispe=nplsi
                exit
              end if !}
            end do !}
            if(nstrai.ge.nstra) then !{
              write(0,*) 'Too many strata requested: ',nstrai
              write(0,*) 'STOP ==> check the DG model and the value ',
     ,                            'of DEF_NSTRA in b2mod_dimensions.F'
              call xerrab ('Too many strata requested')
            end if !}

            ntargi=ntargi+1
            if(ntargi.gt.nstep) then !{
              write(0,*) 'Too many recycling strata requested: ',ntargi
              write(0,*) 'STOP  ==> check the DG model and the value ',
     ,                               'of NSTEP in KOPPLDIM.F:'
              write(0,*) '          NSTEP must not be less than ',
     ,                                'the number of recycling sources'
              call xerrab ('Too many recycling strata requested')
            end if !}

            write(txtsou(nstrai),'(a,a,a10,i4)')
     ,       trim(spcsatm(iatm)),' recycling - ',ctxbnds(ibk),isf
            nspez(nstrai)=iatm
            nspzi(ntargi,1)=ispi
            nspze(ntargi,1)=ispe
            insor(1,nstrai)=jcpbnds(isf,ibk)
            ndt2(ntargi,1)=ndt
            ntin2(ntargi,1)=jc1bnds(isf,ibk)
            nten2(ntargi,1)=jc2bnds(isf,ibk)
            npts(nstrai)=jnpbnds(isf,ibk)
            nptc(ntargi,1)=jnpbnds(isf,ibk)
            nminpts(nstrai)=jmpbnds(isf,ibk)
            nptcm(ntargi,1)=jmpbnds(isf,ibk)
            ninitl(nstrai)=jnibnds(isf,ibk)
            nemods(nstrai)=jnebnds(isf,ibk)
            sorind(1,nstrai)=nstrai
            soreni(nstrai)=esibnds(isf,ibk)
            sorene(nstrai)=esebnds(isf,ibk)
            nrsor(1,nstrai)=-1
            if(cskbnds(isf,ibk).eq.'W' .or.
     .                                  cskbnds(isf,ibk).eq.'E') then !{
              nixy2(ntargi,1)=1
              nemod(ntargi,1)=7
              indim(1,nstrai)=2
              sorlim(1,nstrai)=104
              ingrda(1,nstrai,1)=ntin2(ntargi,1)
              ingrde(1,nstrai,1)=nten2(ntargi,1)
              ingrda(1,nstrai,2)=insor(1,nstrai)
              ingrde(1,nstrai,2)=insor(1,nstrai)
              if(cskbnds(isf,ibk).eq.'W') then !{
                sorifl(1,nstrai)=1000
              else !}{
                sorifl(1,nstrai)=1000
              end if !}
            else if(cskbnds(isf,ibk).eq.'S' .or.
     .                                 cskbnds(isf,ibk).eq.'N') then !}{
              nixy2(ntargi,1)=2
              nemod(ntargi,1)=6
              indim(1,nstrai)=1
              sorlim(1,nstrai)=140
              ingrda(1,nstrai,1)=insor(1,nstrai)
              ingrde(1,nstrai,1)=insor(1,nstrai)
              ingrda(1,nstrai,2)=ntin2(ntargi,1)
              ingrde(1,nstrai,2)=nten2(ntargi,1)
              if(cskbnds(isf,ibk).eq.'S') then !{
                sorifl(1,nstrai)=1000
              else !}{
                sorifl(1,nstrai)=1000
              end if !}
            end if !}
            if(cskbnds(isf,ibk).eq.'W' .or.
     .                                  cskbnds(isf,ibk).eq.'S') then !{
              ninct2(ntargi,1)=-1
            else !}{
              ninct2(ntargi,1)=1
            end if !}
           end do !}
          end if !}
        end do !}
      end do !}

cnh   adapt some variables of block 14 for vessel mode
      if (grid_mode.eq.2) then
        k=0
        do i=1,maxval(fclbl)
          ispe=0
          do iatm=1,natmi
            if (is_meta(iatm)) cycle
            k=k+1
            ndt2(k,1)=-i
            ispi=ispe+1
            ispe=ispi
            do while (lkindp(min(ispe+1,nplsi)).eq.lkindp(ispi)) !{
              ispe=ispe+1
              if (ispe.gt.nplsi) then !{
                ispe=nplsi
                exit
              end if !}
            end do !}
            nspzi(k,1)=ispi
            nspze(k,1)=ispe
          end do
        end do
       end if

c=======================================================================
      call subend ()
      return
      end subroutine uinbnddt
