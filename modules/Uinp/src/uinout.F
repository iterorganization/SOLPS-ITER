      subroutine uinout(ufnm)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx

c  version : 05.02.2005 00:46

cvk input for block 1,3,4,9,13,14 is changed
cvk block 6 has to be changed (with reaction cards), 
cvk blocks 9,10,11,12 probably should be changed as well

c=======================================================================

c   produce "input.eir" file with input data for eirene

c=======================================================================
#include "uinput.inc"
#include "impcon.inc"
#include "git_version_Uinp.h"

      integer i,j,k,l,m,n,icont,istep,jsurpr
      logical handle,ulmlti,ex,carbon,nitrogen,streql
      logical, allocatable :: done(:)
      character utxthd(35)*71, utxtfl(7)*47, ufnm*(*)
      character utxtgt*71
      external streql, xerrab, subini, subend
      data utxthd /
     1        '** 1. Data for operating mode' ,
     2        '** 2. Data for standard mesh' ,
     3        '** 3a. Data for non-default standard surfaces' ,
     4        '** 3b. Data for additional surfaces' ,
     5        '** 4. Data for species and atomic physics module' ,
     6        '** 5. Data for plasma background' ,
     7        '** 6a. General data for reflection model' ,
     8        '** 7. Data for primary sources, nstrai strata' ,
     9        '** 8. Additional data for specific zones' ,
     o        '** 9. Data for statistic and nonanalog model' ,
     1        '** 10. Data for additional tallies' ,
     2        '* 10a. Volume tallies - tracklength estimator' ,
     3        '* 10b. Volume tallies - collisional estimator' ,
     4        '* 10c. Volume tallies - algebraic expressions' ,
     5        '* 10d. Surface tallies' ,
     6        '* 10e. Surface tallies - algebraic expressions' ,
     7        '** 11. Data for numerical and graphical output' ,
     8        '** 12. Data for diagnostic module' ,
     9        '** 14. Data for interfacing routine "infusr"' ,
     o        '* 4a. Neutral atom species' ,
     1        '* 4b. Neutral molecule species' ,
     2        '* 4c. Test ion species' ,
     3        '*  Standard deviation ' ,
     4        '*  Reactions ' ,
     5        '** 13. Data for nonlinear and time dep. option' ,
     6        '* 13a. Data for snapshot tallies' ,
     7        '** 15. Data for interfacing routine "geousr"' ,
     8        '* 6c. Data for chemical sputtering' ,
     9        '* 2d. Data for mesh multiplication' ,
     o        '* 2e. Data for additional cells outside standard mesh' ,
     1        '* 5b. Plasma background data' ,
     2        '* Data for source correction' ,
     3        '* 4d. Photon species' ,
     4        '* 5a. Bulk ion species' ,
     5        '* 10f. Data for energy spectra' /
      data utxtfl /
     1        'CFILE AMJUEL Database/AMdata/amjuel.tex        ',
     2        'CFILE HYDHEL Database/AMdata/hydhel.tex        ',
     3        'CFILE SPUTER Database/Surfacedata/SPUTER       ',
     4        'CFILE TRIM   Database/Surfacedata/TRIM/trim.dat',
     5        'CFILE METHAN Database/AMdata/methane.tex       ',
     6        'CFILE AMMONX Database/AMdata/ammoniaex.tex     ',
     7        'CFILE ADAS   modules/adas/adf11                '/
c=======================================================================

c*** 0. Prepare some constants
      call subini ('uinout')
      ex=.false.
      if(nstrao.le.0) then !{
        nstrao=nstrai
        if(ntim1.ge.1) nstrao=nstrao+1
        if(nstrao.gt.nstra) then !{
          write(0,*) '### uinout: nstrao > nstra. nstrao,nstra,nstrai,',
     ,                              'ntim1= ',nstrao,nstra,nstrai,ntim1
          ex=.true.
        end if !}
      end if !}
      if(natmo.le.0) then !{
        natmo=max(natmi,1)
        if(natmo.gt.natm) then !{
          write(0,*) '### uinout: natmo > natm. natmo,natm,natmi=',
     ,                                                  natmo,natm,natmi
          ex=.true.
        end if !}
      end if !}
      if(nmolo.le.0) then !{
        nmolo=max(nmoli,1)
        if(nmolo.gt.nmol) then !{
          write(0,*) '### uinout: nmolo > nmol. nmolo,nmol,nmoli=',
     ,                                                  nmolo,nmol,nmoli
          ex=.true.
        end if !}
      end if !}
      if(niono.le.0) then !{
        niono=max(nioni,1)
        if(niono.gt.nion) then !{
          write(0,*) '### uinout: niono > nion. niono,nion,nioni=',
     ,                                                  niono,nion,nioni
          ex=.true.
        end if !}
      end if !}
      if(nphto.le.0) then !{
        nphto=max(nphti,1)
        if(nphto.gt.npht) then !{
          write(0,*) '### uinout: nphto > npht. nphto,npht,nphti=',
     ,                                                  nphto,npht,nphti
          ex=.true.
        end if !}
      end if !}
      if(nplso.le.0) then !{
        nplso=max(nplsi+nbgk,1)
        if(nplso.gt.npls) then !{
          write(0,*) '### uinout: nplso > npls. nplso,npls,nplsi,nbgk=',
     ,                                             nplso,npls,nplsi,nbgk
          ex=.true.
        end if !}
      end if !}

c*** 1.  General data for the run

      open(iunoo,file=ufnm)
      write(iunoo,700) txtrun
      utxtgt =
     . " Created with SOLPS-ITER Uinp version "//git_version_Uinp
      write(iunoo,700) utxtgt
      write(iunoo,700) utxthd(1)
      if (nbgk.gt.0) then
        j=nfile/10000
        k=(nfile-j*10000)/1000
        l=(nfile-j*10000-k*1000)/100
        m=(nfile-j*10000-k*1000-l*100)/10
        n=mod(nfile,10)
        if (l.le.2) then
          l=4
        else if (l.eq.6.or.l.eq.7.or.l.eq.9) then
          l=4
        else if (l.eq.8) then
          l=3
        endif
        if (n.ne.1) n=6
        nfile=j*10000+k*1000+l*100+m*10+n
      end if
      write(iunoo,707) nmach,nmode,ntcpu,nfile,niter0,niter,
     .                 ntime0,ntim1,nfullrun
      write(iunoo,707) noptim,noptm1,ngeom_usr,ncoup_input,
     .                 nsmstra,nstoram,ngstal,nrtal1,nreac_add
      write(iunoo,706) nlscl,nltest,nlana,nldrft,nlcrr,
     .                 nlerg,nlident,nlone,nlmovie,nldfst,
     .                 nloldran,nlcascad,nloctree,nlwrmsh,nexvs,
     .                 nltrimesh
      write(iunoo,720) utxtfl(1) ! AMJUEL needed by default for H-alpha rates
      handle=.false.
      do i=1,nrcln
        handle=handle.or.streql(filnam(i),'HYDHEL')
      end do
      if (handle) write(iunoo,720) utxtfl(2)
      write(iunoo,720) utxtfl(3)
      write(iunoo,720) utxtfl(4)
      carbon = .false.
      do i=1,nspigen
        carbon=carbon.or.streql(spcigen(i),spcdgen(5))
      enddo
      if (carbon) write(iunoo,720) utxtfl(5)
      nitrogen = .false.
      do i=1,nspigen
        nitrogen=nitrogen.or.streql(spcigen(i),spcdgen(8))
      enddo
      if (nitrogen) write(iunoo,720) utxtfl(6)
      handle=.false.
      do i=1,nrcln
        handle=handle.or.streql(filnam(i),'ADAS')
      end do
      if (handle) write(iunoo,720) utxtfl(7)

c*** 2.  data for standard mesh

      write(iunoo,700) utxthd(2)
      write(iunoo,707) (indgrd(j),j=1,3)

c**  radial mesh

      write(iunoo,706) nlrad
      if (nlrad) then !{
        write(iunoo,706) nlslb,nlcrc,nlell,nltri,nlplg,nlfem,nltet,
     ,                   nlgen
        write(iunoo,707) nr1st,nrsep,nrplg,npplg,nrknot
        if (indgrd(1).le.5) then !{
          if (nlslb.or.nlcrc.or.nlell.or.nltri) then !{
            write(iunoo,703) ria,ragrid,raa,rarefl
            if (nlell .or. nltri) then !{
              write(iunoo,703) ep1in,ep1ot,ep1ch,exep1
              write(iunoo,703) ellin,ellot,ellch,exell
              if (nltri) then !{
                write(iunoo,703) triin,triot,trich,extri
              end if !}
            end if !}
          end if !}
          if (nlplg) then !{
            write(iunoo,703) xpcor,ypcor,zpcor,plrefl
            write(iunoo,707) (npoin1(1,j),npoin1(2,j),j=1,npplg)
            do i=1,nr1st !{
              write(iunoo,703) (xpol(i,j),ypol(i,j),j=1,nrplg)
            end do !}
          end if !}
          if (nlfem) then !{
            write(iunoo,703) xpcor,ypcor,zpcor
            write(iunoo,707) nrknot
            write(iunoo,703) (xtrian(i),i=1,nrknot)
            write(iunoo,703) (ytrian(i),i=1,nrknot)
            do j=1,nr1st !{
              write(iunoo,707) j,necke(1,j),necke(2,j),necke(3,j)
              write(iunoo,707) nchbar(1,j),nseite(1,j),inmti(1,j)
              write(iunoo,707) nchbar(2,j),nseite(2,j),inmti(2,j)
              write(iunoo,707) nchbar(3,j),nseite(3,j),inmti(3,j)
            end do !}
          endif !}
        else if (indgrd(1).eq.6) then !}{
          if (nlslb.or.nlcrc.or.nlell.or.nltri) then !{
            write(iunoo,703) ria,ragrid,raa
          else if (nlplg.or.nlfem.or.nltet) then !}{
            write(iunoo,703) xpcor,ypcor,zpcor
          end if !}
        end if !}
      end if !}

c**  poloidal mesh

      write(iunoo,706) nlpol
      write(iunoo,706) nlply,nlpla,nlplp
      write(iunoo,707) np2nd,npsep,nppla,npper
      if (indgrd(2).le.5) then !{
        write(iunoo,703) yia,yagrid,yaa,yya
      end if !}

c**  toroidal mesh

      write(iunoo,706) nltor
      write(iunoo,706) nltrz,nltra,nltrt
      write(iunoo,707) nt3rd,ntsep,nttra,ntper
      if (indgrd(3).le.5) then !{
        write(iunoo,703) zia,zagrid,zaa,zza,roa
      end if !}

c**  mesh multiplication

      if (nlmlt) write(iunoo,700)  utxthd(29)
      write(iunoo,706) nlmlt
      if (nlmlt) then !{
        write(iunoo,707) nbmlt
        write(iunoo,703) (volcor(nm),nm=1,nbmlt)
      end if !}

c**  additional cells outside standard mesh

      if(nladd) write(iunoo,700) utxthd(30)
      write(iunoo,706) nladd
      icont = 0
      allocate (done(1:max(abs(minval(ilplg(1:nstsi))),
     .                     abs(minval(jlplg(1:nlimi))))))
      done = .false.
      do i = 1, nstsi
        if (ilplg(i).lt.0) then
          l = abs(ilplg(i))
          if (.not.done(l)) then
            icont = icont + 1
            done(l) = .true.
          end if
        end if
      end do
      do j = 1, nlimi
        if (jlplg(j).lt.0) then
          l = abs(jlplg(j))
          if (.not.done(l)) then
            icont = icont + 1
            done(l) = .true.
          end if
        end if
      end do
      nradd = max ( nradd, icont ) 

      if (nradd .gt. nadd) then !{
        print *, ' Too many additional zones : NRADD = ', nradd
        print *, ' Recompile Uinp with an incresaed value of NADD'
        call xerrab ('Too many additional zones')
      end if !}
      if (nladd) then !{
        write(iunoo,707) nradd
        write(iunoo,703) (voladd(nm),nm=1,nradd)
      end if !}

c*** 3a.  data for non-default surface models on standard surfaces

      write(iunoo,700) utxthd(3)
      write(iunoo,707) nstsi
      do ists=1,nstsi !{
        write(iunoo,709) ists,txtsfl(ists)
        write(iunoo,707) ists,idimp(ists),inump(ists),
     ,                   irpta1(ists),irpte1(ists),irpta2(ists),
     ,                   irpte2(ists),irpta3(ists),irpte3(ists)
        write(iunoo,707) iliin(ists),ilside(ists),ilswch(ists),
     .                   ilequi(ists),iltor(ists),ilcol(ists),
     .                   ilfit(ists),ilcell(ists),ilbox(ists),
     .                   ilplg(ists)
        if(iscrd(ists).gt.0) then !{
          write(iunoo,715) scard_name(iscrd(ists))
        else if (iliin(ists).eq.1 .or. bliin(ists)) then !}{
          ii=10*ilsptc(ists)+ilsptp(ists)
          write(iunoo,707) ilref(ists),ii,isrss(ists),isrc(ists),
     ,                                                    lchspnws(ists)
          write(iunoo,703) xmlim(ists),ewall(ists),ewbin(ists),
     ,                       transp(ists,1),transp(ists,2),fsheat(ists)
          write(iunoo,703) recycf(ists),recyct(ists),recprm(ists),
     ,                              exppl(ists),expel(ists),expil(ists)
          write(iunoo,703) recycs(ists),recycc(ists),echspts(ists),
     ,                                        fchspts(ists),sptprm(ists)
        end if !}
      end do !}

c*** 3b.  data for additional surfaces

      write(iunoo,700) utxthd(4)
      write(iunoo,707) nlimi
c***  "ch0-cards"
      call uichwr(iunoo,0,jadch0,nlimi)
      icopy=0
      jsurpr=nsurpr
      do 360 k=laddsrfs+1,nlimi !{
        i=indasrfs(k)
        if(i.eq.0) go to 360
        write(iunoo,714) k,i,txtsfa(k)

        icopy=icopy-1
        if (icopy.ge.1) goto 360

c   general surface data

c*** "ch1-cards"
c% This should be changed 
c        call uichwr(iunoo,1,jadch1(1,i),nlimi)
c*** "ch2-cards" here !

        write(iunoo,703) rlb(i),sarea(i),rlwmn(i),rlwmx(i)
        jlswch=jadnsw(i)+10*jadmsw(i)+100*jadlsw(i)+1000*jadksw(i)+
     +                               10000*jadjsw(i)+100000*jadisw(i)
        jlcell=jlacll(i)+1000*jlblck(i)
        write(iunoo,707) jliin(i),jlside(i),jlswch,jlequi(i),
     ,    jltor(i),jlcol(i),jlfit(i),jlcell,jlbox(i),jlplg(i)
        if(jliin(i).lt.0) then
          jsurpr=jsurpr+1
          nsrf(jsurpr)=k
        end if

c**  Surface coefficients

        if (rlb(i).lt.2.) then !{
          write(iunoo,703) a0lm(i),a1lm(i),a2lm(i),
     ,                                      a3lm(i),a4lm(i),a5lm(i)
          write(iunoo,703) a6lm(i),a7lm(i),a8lm(i),a9lm(i)
        else if (rlb(i).lt.3.) then !}{
          write(iunoo,703) p1(1,i),p1(2,i),p1(3,i),
     ,                                      p2(1,i),p2(2,i),p2(3,i)
        else if (rlb(i).lt.5.) then !}{
          write(iunoo,703) p1(1,i),p1(2,i),p1(3,i),
     ,                                      p2(1,i),p2(2,i),p2(3,i)
          write(iunoo,703) p3(1,i),p3(2,i),p3(3,i),
     ,                                      p4(1,i),p4(2,i),p4(3,i)
        else if (rlb(i).lt.7.) then !}{
          write(iunoo,703) p1(1,i),p1(2,i),p1(3,i),
     ,                                      p2(1,i),p2(2,i),p2(3,i)
          write(iunoo,703) p3(1,i),p3(2,i),p3(3,i),
     ,                                      p4(1,i),p4(2,i),p4(3,i)
          write(iunoo,703) p5(1,i),p5(2,i),p5(3,i),
     ,                                      p6(1,i),p6(2,i),p6(3,i)
        end if !}

c**  Boundary data

        if (rlb(i).gt.0..and.rlb(i).lt.2.) then !{
          write(iunoo,703) xlims1(i,1),ylims1(i,1),
     ,                zlims1(i,1),xlims2(i,1),ylims2(i,1),zlims2(i,1)
        else if (rlb(i).le.0.) then !}{
          imrlb=-rlb(i)
          ih=mod(imrlb,100)
          icopy=(imrlb-ih)/100
          iulin=idez(ih,1,2)
          iuscn=idez(ih,2,2)
          do j=1,iulin !{
            write(iunoo,703) alims(i,j),xlims(i,j),
     ,                                            ylims(i,j),zlims(i,j)
          end do !}
          do j=1,iuscn !{
            write(iunoo,703) alims0(i,j),xlims1(i,j),
     ,                ylims1(i,j),zlims1(i,j),xlims2(i,j),ylims2(i,j)
            write(iunoo,703) zlims2(i,j),xlims3(i,j),
     ,                                        ylims3(i,j),zlims3(i,j)
          end do !}
        end if !}

c**  Local reflection model ?

        if(jscrd(i).GT.0) then !{
          write(iunoo,715) scard_name(jscrd(i))
        else if (jliin(i).eq.1) then !}{
          ii=10*jlsptc(i)+jlsptp(i)
          write(iunoo,707) jlref(i),ii,jsrss(i),jsrc(i),lchspnwa(i)
          write(iunoo,703) xmlma(i),ewala(i),ewbna(i),
     ,                trnspa(i,1),trnspa(i,2),fsheata(i)
          write(iunoo,703) rcycfa(i),rcycta(i),rcprma(i),
     ,                exppla(i),expela(i),expila(i)
          write(iunoo,703) rcycsa(i),rcycca(i),
     ,                echspta(i),fchspta(i),sptpra(i)
        end if !}

c* Transform from convenient coordinate system to Eirene coordinate
c* system. This is possible for all surfaces written by now, i.e.
c* from itini=1 to itend=i

        if(itini(i).ge.0) then !{
          write(iunoo,'(a)') 'TRANSFORM'
          write(iunoo,707) itini(i),itend(i)
          write(iunoo,703) xlcor(i),ylcor(i),zlcor(i)
          write(iunoo,703) xlref(i),ylref(i),zlref(i)
          write(iunoo,703) xlrot(i),ylrot(i),zlrot(i),alrot(i)
        end if !}

  360 continue !}

c*** 4.  Data for species specification and atomic physics module

      write(iunoo,700) utxthd(5)

c**   atomic reaction cards, nreaci data fields

      write(iunoo,700) utxthd(24)
      write(iunoo,707) nreaci
      do j=1,nrcln !{
        iid=ir(j)
        write(iunoo,701) iid,filnam(j),h123(j),reac(j),crc(j),
     ,                   massp(j),masst(j),delpot(j),rc1mn(j),rc1mx(j),
     ,                                               rc2mn(j),rc2mx(j)
        if (streql(filnam(j),'ADAS')) then !{
          write(iunoo,'(4x,a2,1x,i3)') elname(j),iz(j)
        end if !}
        if (rc1mn(j).gt.0.) write(iunoo,704) ifex1mn(j),(fp1(j,i),i=1,3)
        if (rc1mx(j).gt.0.) write(iunoo,704) ifex1mx(j),(fp1(j,i),i=4,6)
        if (rc2mn(j).gt.0.) write(iunoo,704) ifex2mn(j),(fp2(j,i),i=1,3)
        if (rc2mx(j).gt.0.) write(iunoo,704) ifex2mx(j),(fp2(j,i),i=4,6)
        if (lconst(j)) write(iunoo,703) (creac(i,j),i=1,9)
      end do !}

c**  atomic species cards

      write(iunoo,700) utxthd(20)
      write(iunoo,707) natmi
      do iatm=1,natmi !{
        write(iunoo,708) iatm,texta(iatm),nmassa(iatm),nchara(iatm),
     ,    1,0,isrfa(iatm),isrta(iatm),nmseca(iatm),nrca(iatm),
     ,    nfola(iatm),ngena(iatm),nhsta(iatm)
        do k=1,nrca(iatm) !{
          if(nmseca(iatm).le.2) then !{
            write(iunoo,707) ireaca(iatm,k),ibulka(iatm,k),
     ,                 iscd1a(iatm,k),iscd2a(iatm,k),
     ,                 iscdea(iatm,k),iestma(iatm,k),ibgka(iatm,k)
          else if (nmseca(iatm).eq.3) then !}{
            write(iunoo,707) ireaca(iatm,k),ibulka(iatm,k),
     ,                     iscd1a(iatm,k),iscd2a(iatm,k),iscd3a(iatm,k),
     ,                     iscdea(iatm,k),iestma(iatm,k),ibgka(iatm,k)
          else if (nmseca(iatm).eq.4) then !}{
            write(iunoo,707) ireaca(iatm,k),ibulka(iatm,k),
     ,                     iscd1a(iatm,k),iscd2a(iatm,k),
     ,                     iscd3a(iatm,k),iscd4a(iatm,k),
     ,                     iscdea(iatm,k),iestma(iatm,k),ibgka(iatm,k)
          end if !}
          write(iunoo,703) eeleca(iatm,k),ebulka(iatm,k),escd1a(iatm,k),
     ,                     escd2a(iatm,k),freaca(iatm,k),edpota(iatm,k)
        end do !}
      end do !}

c**  neutral molecules species cards

      write(iunoo,700) utxthd(21)
      write(iunoo,707) nmoli
      do imol=1,nmoli !{
        write(iunoo,708) imol,textm(imol),nmassm(imol),ncharm(imol),
     ,              nprtm(imol),0,isrfm(imol),isrtm(imol),nmsecm(imol),
     ,              nrcm(imol),nfolm(imol),ngenm(imol),nhstm(imol),
     ,              lkindm(imol)
        do k=1,nrcm(imol) !{
          if(nmsecm(imol).le.2) then !{
            write(iunoo,707) ireacm(imol,k),ibulkm(imol,k),
     ,                 iscd1m(imol,k),iscd2m(imol,k),
     ,                 iscdem(imol,k),iestmm(imol,k),ibgkm(imol,k)
          else if(nmsecm(imol).eq.3) then!}{
            write(iunoo,707) ireacm(imol,k),ibulkm(imol,k),
     ,                 iscd1m(imol,k),iscd2m(imol,k),iscd3m(imol,k),
     ,                 iscdem(imol,k),iestmm(imol,k),ibgkm(imol,k)
          else if(nmsecm(imol).eq.4) then!}{
            write(iunoo,707) ireacm(imol,k),ibulkm(imol,k),
     ,                 iscd1m(imol,k),iscd2m(imol,k),
     ,                 iscd3m(imol,k),iscd4m(imol,k),
     ,                 iscdem(imol,k),iestmm(imol,k),ibgkm(imol,k)
          end if !}
          write(iunoo,703) eelecm(imol,k),ebulkm(imol,k),
     ,                     escd1m(imol,k),escd2m(imol,k),freacm(imol,k)
        end do !}
      end do !}

c**  test particle ions species cards

      write(iunoo,700) utxthd(22)
      write(iunoo,707) nioni
      do iion=1,nioni !{
        write(iunoo,708) iion,texti(iion),nmassi(iion),nchari(iion),
     ,    nprti(iion),nchrgi(iion),isrfi(iion),isrti(iion),nmseci(iion),
     ,    nrci(iion),nfoli(iion),ngeni(iion),nhsti(iion),lkindi(iion)
        do k=1,nrci(iion) !{
          if(nmseci(iion).le.2) then !{
            write(iunoo,707) ireaci(iion,k),ibulki(iion,k),
     ,                 iscd1i(iion,k),iscd2i(iion,k),
     ,                 iscdei(iion,k),iestmi(iion,k),ibgki(iion,k)
          else if(nmseci(iion).eq.3) then !}{
            write(iunoo,707) ireaci(iion,k),ibulki(iion,k),
     ,                 iscd1i(iion,k),iscd2i(iion,k),iscd3i(iion,k),
     ,                 iscdei(iion,k),iestmi(iion,k),ibgki(iion,k)
          else if(nmseci(iion).eq.4) then !}{
            write(iunoo,707) ireaci(iion,k),ibulki(iion,k),
     ,                 iscd1i(iion,k),iscd2i(iion,k),
     ,                 iscd3i(iion,k),iscd4i(iion,k),
     ,                 iscdei(iion,k),iestmi(iion,k),ibgki(iion,k)
          end if !}
          write(iunoo,703) eeleci(iion,k),ebulki(iion,k),
     ,                      escd1i(iion,k),escd2i(iion,k),freaci(iion,k)
        end do !}
      end do !}

c**  photon species cards

      if(nphti.gt.0) then !{
        write(iunoo,700) utxthd(33)
        write(iunoo,707) nphti
        do ipht=1,nphti !{
          write(iunoo,708) ipht,textf(ipht),0,0,0,0,isrff(ipht),
     ,      isrtf(ipht),nmsecf(ipht),nrcf(ipht),nfolf(ipht),
     ,      ngenf(ipht),nhstf(ipht)
          do k=1,nrcf(ipht) !{
            if(nmsecf(ipht).le.2) then !{
              write(iunoo,707) ireacf(ipht,k),ibulkf(ipht,k),
     ,                 iscd1f(ipht,k),iscd2f(ipht,k),
     ,                 iscdef(ipht,k),iestmf(ipht,k),ibgkf(ipht,k)
            else if(nmsecf(ipht).eq.3) then !}{
              write(iunoo,707) ireacf(ipht,k),ibulkf(ipht,k),
     ,                 iscd1f(ipht,k),iscd2f(ipht,k),iscd3f(ipht,k),
     ,                 iscdef(ipht,k),iestmf(ipht,k),ibgkf(ipht,k)
            else if(nmsecf(ipht).eq.4) then !}{
              write(iunoo,707) ireacf(ipht,k),ibulkf(ipht,k),
     ,                 iscd1f(ipht,k),iscd2f(ipht,k),
     ,                 iscd3f(ipht,k),iscd4f(ipht,k),
     ,                 iscdef(ipht,k),iestmf(ipht,k),ibgkf(ipht,k)
            end if !}
            write(iunoo,703) eelecf(ipht,k),ebulkf(ipht,k),
     ,       escd1f(ipht,k),escd2f(ipht,k),freacf(ipht,k),edpotf(ipht,k)
          end do !}
        end do !}
      end if !}

c*** 5.  data for plasma background

      do i=1,ndnmdlp !{
        call upcase(cdnmdlp_sel(i),cdnmdlp_sel(i),ldnmdlp)
      end do !}

      write(iunoo,700) utxthd(6)
      write(iunoo,700) utxthd(34)

c**  bulk ions species cards

      write(iunoo,707) nplsi+nbgk
      do ipls=1,nplsi+nbgk !{
        if (ipls.lt.100) then !{
         write(iunoo,708) ipls,textp(ipls),nmassp(ipls),
     ,    ncharp(ipls),nprtp(ipls),nchrgp(ipls),isrfp(ipls),
     ,    isrtp(ipls),nmsecp(ipls),nrcp(ipls),idnslmp(ipls),
     ,    0,nhstp(ipls),0,cdnmdlp(ipls),nrep(ipls)
        else !}{
         write(iunoo,7080) mod(ipls,100),textp(ipls),nmassp(ipls),
     ,    ncharp(ipls),nprtp(ipls),nchrgp(ipls),isrfp(ipls),
     ,    isrtp(ipls),nmsecp(ipls),nrcp(ipls),idnslmp(ipls),
     ,    0,nhstp(ipls),0,cdnmdlp(ipls),nrep(ipls)
        end if !}
        do k=1,nrcp(ipls) !{
          if(nmsecp(ipls).le.2) then !{
            write(iunoo,707) ireacp(ipls,k),ibulkp(ipls,k),
     ,        iscd1p(ipls,k),iscd2p(ipls,k),iscdep(ipls,k)
          else if(nmsecp(ipls).eq.3) then !}{
            write(iunoo,707) ireacp(ipls,k),ibulkp(ipls,k),
     ,        iscd1p(ipls,k),iscd2p(ipls,k),iscd3p(ipls,k),
     ,        iscdep(ipls,k)
          else if(nmsecp(ipls).eq.4) then !}{
            write(iunoo,707) ireacp(ipls,k),ibulkp(ipls,k),
     ,        iscd1p(ipls,k),iscd2p(ipls,k),iscd3p(ipls,k),
     ,        iscd4p(ipls,k),iscdep(ipls,k)
          end if !}
          write(iunoo,703) eelecp(ipls,k),ebulkp(ipls,k),
     .                     escd1p(ipls,k),escd2p(ipls,k),freacp(ipls,k)
        end do !}
        if (len_trim(cdnmdlp(ipls)).gt.0) then !{
          call upcase(cdnmdlp(ipls),cdnmdlp(ipls),ldnmdlp)
          if(streql(cdnmdlp(ipls),cdnmdlp_sel(1)).or.
     &       streql(cdnmdlp(ipls),cdnmdlp_sel(2))) then !{ 'FORT.13', 'FTN13'
            write(iunoo,707) ispcdn(ipls,1)
          else if(streql(cdnmdlp(ipls),cdnmdlp_sel(3)).or.
     &            streql(cdnmdlp(ipls),cdnmdlp_sel(4))) then !}{ 'FORT.10', 'FTN10'
            write(iunoo,707) ispcdn(ipls,1),
     ,                       itpcdn(ipls,1),istrcdn(ipls,1)
          else if(streql(cdnmdlp(ipls),cdnmdlp_sel(5))) then !}{ 'CONSTANT'
            write(iunoo,703) valcdn(ipls,1),
     ,                       valcdn(ipls,2),valcdn(ipls,3),
     ,                       valcdn(ipls,4),valcdn(ipls,5)
          else if(streql(cdnmdlp(ipls),cdnmdlp_sel(6))) then !}{ 'MULTIPLY'
            write(iunoo,'(3i6,6x,1p,3e12.4)') ispcdn(ipls,1),
     ,                        itpcdn(ipls,1),istrcdn(ipls,1),
     ,                        valcdn(ipls,2),valcdn(ipls,1),
     ,                        valcdn(ipls,3)
          else if(streql(cdnmdlp(ipls),cdnmdlp_sel(7))) then !}{ 'SAHA'
c** To be done (in Eirene first)
            write(0,*) '### Density model ',cdnmdlp_sel(7),
     ,        ' not realised in Eirene. ipls=',ipls
          else if(streql(cdnmdlp(ipls),cdnmdlp_sel(8))) then !}{ 'BOLTZMANN'
            write(iunoo,'(3i6,6x,1p,2e12.4)') ispcdn(ipls,1),
     ,                        itpcdn(ipls,1),istrcdn(ipls,1),
     ,                        bltzcdn(ipls),dltecdn(ipls)
          else if(streql(cdnmdlp(ipls),cdnmdlp_sel(9))) then !}{ 'CORONA'
            write(iunoo,'(3i6,1x,a6,1x,a4,a9,a3,1p,e12.4)') 
     ,                     ispcdn(ipls,1),
     ,                     itpcdn(ipls,1),istrcdn(ipls,1),
     ,                     fnamcdn(ipls,1),h2cdn(ipls,1),
     ,                     reaccdn(ipls,1),crcdn(ipls,1),acrncdn(ipls)
          else if(streql(cdnmdlp(ipls),cdnmdlp_sel(10))) then !}{ 'COLRAD'
            do i=1,nrep(npls) !{
              write(iunoo,'(3i6,1x,a6,1x,a4,a9,a3)') 
     ,                     ispcdn(ipls,i),
     ,                     itpcdn(ipls,i),istrcdn(ipls,i),
     ,                     fnamcdn(ipls,i),h2cdn(ipls,i),
     ,                     reaccdn(ipls,i),crcdn(ipls,i)
            end do !}
          else !}{
            write(0,*) '### Density model ',cdnmdlp(ipls),
     ,        ' not realised in uinp. ipls=',ipls
          end if !}
        end if !}
      end do !}

      write(iunoo,700) utxthd(31)
      write(iunoo,707) indpro
      if (indpro(1).le.5 .and. nplsi.gt.0)
     -                        write(iunoo,703) te0,te1,te2,te3,te4,te5
      ulmlti=indpro(2).lt.0
      if (iabs(indpro(2)).le.5 .and. nplsi.gt.0) then !{
        if (ulmlti) then !{
          write(iunoo,703) (ti0(i),ti1(i),ti2(i),ti3(i),ti4(i),ti5(i),
     ,                                                        i=1,nplsi)
        else !}{
          write(iunoo,703) ti0(1),ti1(1),ti2(1),ti3(1),ti4(1),ti5(1)
        end if !}
      end if !}
      if (indpro(3).le.5) write(iunoo,703) (di0(i),di1(i),di2(i),
     ,                                   di3(i),di4(i),di5(i),i=1,nplsi)
      if (abs(indpro(4)).le.5) then !{
        write(iunoo,703) (vx0(i),vx1(i),vx2(i),vx3(i),vx4(i),vx5(i),
     ,                                                        i=1,nplsi)
        write(iunoo,703) (vy0(i),vy1(i),vy2(i),vy3(i),vy4(i),vy5(i),
     ,                                                        i=1,nplsi)
        write(iunoo,703) (vz0(i),vz1(i),vz2(i),vz3(i),vz4(i),vz5(i),
     ,                                                        i=1,nplsi)
      end if !}
      if (indpro(5).le.5) write(iunoo,703) b0,b1,b2,b3,b4,b5
      if (indpro(12).le.5) write(iunoo,703) vl0,vl1,vl2,vl3,vl4,vl5

c*** 6a.  data for reflection model

      write(iunoo,700) utxthd(7)

      write(iunoo,706) nltrim
      if(path.ne.' ') write(iunoo,'(a6,a60)') 'cpath ',path
      write(iunoo,'(a8)') (filtrm(i),i=1,nnftrm)
      write(iunoo,703) (datm(iatm),iatm=1,natmi)
      write(iunoo,703) (dmol(imol),imol=1,nmoli)
      write(iunoo,703) (dion(iion),iion=1,nioni)
      write(iunoo,703) (dpls(ipls),ipls=1,nplsi+nbgk)
      write(iunoo,703) ermin,ercut,rprob0,rinteg,einteg,ainteg
c*** surface cards
      k=0
      do i=1,nscards
        write(iunoo,715) scard_name(i)
        write(iunoo,707) scilref(i),scilspt(i),scisrs(i),
     ,                   scisrc(i),sclchspnwl(i)
        write(iunoo,703) scxmlim(i),scewall(i),scewbin(i),
     ,                   sctransp(i,1),sctransp(i,2),scfsheat(i)
        write(iunoo,703) screcycf(i),screcyct(i),scrcprm(i),
     ,                   scexppl(i),scexpel(i),scexpil(i)
        write(iunoo,703) screcycs(i),scychsptg(i),scstprm(i),0.0,
     ,                              scechsptg(i)
        do j=1,nnchemvar(i) !{
          k=k+1 
          ich=indchemvar(k)
          if(streql(chvarname(ich),'ISRC').OR.
     .                      streql(chvarname(ich),'LCHSPNWL')) then !{
            write(iunoo,717) chvarname(ich),chmspname(ich),
     ,                                                nint(chmvar(ich))
          else !}{
            write(iunoo,716) chvarname(ich),chmspname(ich),chmvar(ich)
          end if !} 
        end do !}
      end do !}

c*** 7.  data for primary source

      write(iunoo,700) utxthd(8)
      write(iunoo,707) nstrai
      write(iunoo,707) (indsrc(i),i=1,nstrai)
      write(iunoo,703) alloc
      inum=0
      istep=0
      do i=1,nstrai !{
        inum=inum+1
        istep=istep+1
        if(indsrc(i).eq.6) cycle

        write(iunoo,709) i,txtsou(i)
        write(iunoo,706) nlavrp(i),nlavrt(i),nlsymp(i),nlsymt(i),
     ,                      nlray(i)
        write(iunoo,707) npts(i),ninitl(i),nemods(i),namods(i),
     ,                                                        nminpts(i)
        write(iunoo,718) flux(i),scalv(i),ivlsf(i),iscls(i),isclt(i),
     ,                      iscl1(i),iscl2(i),iscl3(i),isclb(i),iscla(i)
        write(iunoo,706) nlatm(i),nlmol(i),nlion(i),nlpls(i),nlphot(i)
        write(iunoo,707) nspez(i)
        write(iunoo,706) nlpnt(i),nllne(i),nlsrf(i),nlvol(i),nlcns(i)

c**  same for point-, line-, surface- and volume sources

        write(iunoo,707) nsrfsi(i)
        do j=1,nsrfsi(i) !{
          if (j.ne.1) inum=inum+1
          if (insor(j,i).ne.0) k=indasrfs(insor(j,i))
          if (nlsrf(i) .and. insor(j,i).ne.0) then !{
            if (jlplg(k).ne.0) then !{
              if (j.ne.1) istep=istep+1
              sorind(j,i)=istep
            else !}{
              if (j.eq.1) istep=istep-1
              sorind(j,i)=0
            end if !}
          end if !}
          write(iunoo,707) inum,indim(j,i),insor(j,i),ingrda(j,i,1),
     ,      ingrde(j,i,1),ingrda(j,i,2),ingrde(j,i,2),ingrda(j,i,3),
     ,      ingrde(j,i,3)
          write(iunoo,703) sorwgt(j,i),sorlim(j,i),
     ,                     sorind(j,i),sorexp(j,i),sorifl(j,i)
          write(iunoo,707) nrsor(j,i),npsor(j,i),ntsor(j,i),
     ,                     nbsor(j,i),nasor(j,i),nisor(j,i),istor(j,i)
          write(iunoo,703) sorad1(j,i),sorad2(j,i),sorad3(j,i),
     ,                     sorad4(j,i),sorad5(j,i),sorad6(j,i)
        end do !}

c**  velocity space distribution

        write(iunoo,703) soreni(i),sorene(i),sorvdx(i),sorvdy(i),
     ,                                                 sorvdz(i)
        write(iunoo,703) sorcos(i),sormax(i),sorctx(i),sorcty(i),
     ,                                                sorctz(i)

      end do !}

c*** 8.  additional data for some specific zones

      write(iunoo,700) utxthd(9)
      write(iunoo,707) nzadd
      do i=1,nzadd !{
        write(iunoo,'(a)') '*'
        write(iunoo,707) ini(i),ine(i)

c*** "ch3-", "t-", "d-", "v-", "vl-", and "m-cards" here!

      end do !}

c*** 9.  data for statistics and nonanalog model

      write(iunoo,700) utxthd(10)
      write(iunoo,706) (nlprca(j),j=1,natm),(nlprcm(j),j=1,nmol),
     .                 (nlprci(j),j=1,nion),(nlprcph(j),j=1,npht)
      write(iunoo,707) nprcsf
      if(nprcsf.gt.0) write(iunoo,707) (iprcsf(i),i=1,nprcsf)
      write(iunoo,707) maxlev,maxrad,maxpol,maxtor,maxadd
      k=0
      do j=1,maxrad !{
        k=k+1
        write(iunoo,719) k,nssplr(j),prmrspl(j)
      end do !}
      do j=1,maxpol !{
        k=k+1
        write(iunoo,719) k,nssplp(j),prmpspl(j)
      end do !}
      do j=1,maxtor !{
        k=k+1
        write(iunoo,719) k,nssplt(j),prmtspl(j)
      end do !}
      do j=1,maxadd !{
        k=k+1
        write(iunoo,719) k,nsspla(j),prmaspl(j)
      end do !}
      write(iunoo,703) wminv,wmins,wminc
      write(iunoo,703) splpar
      write(iunoo,700) utxthd(23)
      write(iunoo,707) nsigvi,nsigsi,nsigci,nsigi_bgk,nsigi_cop
      do j=1,nsigvi !{
          write(iunoo,707) igh(j),iih(j)
      end do !}
      do j=1,nsigsi !{
        write(iunoo,707) ighw(j),iihw(j)
      end do !}
      do j=1,nsigci !{
        write(iunoo,707) ighc(1,j),iihc(1,j),ighc(2,j),iihc(2,j)
      end do !}
      if(llpbls) then !{
        write(iunoo,700) utxthd(32)
        write(iunoo,706) ((nlpbls(i,j),i=1,natmo),j=1,nstrao)
      end if !}

c*** 10. data for additional and surface-averaged tallies

      write(iunoo,700) utxthd(11)
      write(iunoo,707) nadvi,nclvi,nalvi,nadsi,nalsi,nadspc

c*** 10a.

      write(iunoo,700) utxthd(12)
      do j=1,nadvi !{
        write(iunoo,707) iadve(j),iadvs(j),iadvt(j),iadrc(j)
        write(iunoo,711) txttla(j)
        write(iunoo,712) txtspa(j),txtuna(j)
      end do !}

c*** 10b.

      write(iunoo,700) utxthd(13)
      do j=1,nclvi !{
        write(iunoo,707) iclve(j),iclvs(j),iclvt(j),iclrc(j)
        write(iunoo,711) txttlc(j)
        write(iunoo,712) txtspc(j),txtunc(j)
      end do !}

c*** 10c.

      write(iunoo,700) utxthd(14)
      do j=1,nalvi !{
        write(iunoo,700) chrtal(j)
        write(iunoo,711) txttlr(j)
        write(iunoo,712) txtspr(j),txtunr(j)
      end do !}

c*** 10d.

      write(iunoo,700) utxthd(15)
      do j=1,nadsi !{
        write(iunoo,707) iadse(j),iadss(j),iadst(j),iadsc(j)
        write(iunoo,711) txttld(j)
        write(iunoo,712) txtspd(j),txtund(j)
      end do !}

c*** 10e.

      write(iunoo,700) utxthd(16)
      do j=1,nalsi !{
        write(iunoo,700) chrtls(j)
        write(iunoo,711) txttls(j)
        write(iunoo,712) txtsps(j),txtuns(j)
      end do !}

c*** 10f.

      write(iunoo,700) utxthd(35)
      do j=1,nadspc !{
        write(iunoo,707) ispsrf(j), iptyp(j), ipspz(j),
     .                   isptyp(j), nsps(j), isrfcl(j), idirec(j)
        write(iunoo,703) spcmn(j), spcmx(j), spcsh(j),
     .                   spcpx(j), spcpy(j), spcps(j)
        if (idirec(j).ne.0)
     >   write(iunoo,703) spcvx(j), spcvy(j), spcvz(j)
      end do !}

c*** 11.   data for numerical and graphical output

      write(iunoo,700) utxthd(17)
      write(iunoo,706) trcplt,trchst,trcnal,trcmod,trcsig,
     ,                 trcgrd,trcsur,trcref,trcfle,trcamd,
     ,                 trcint,trclst,trcsou,trcrec,trctim,
     ,                 trcbla,trcblm,trcbli,trcblp,trcble,
     ,                 trcblph,trctal,trcoct,trccen,trcrnf,
     ,                 trcdbg2,trcdbge,trcdbgm,trcdbgf,trcdbgl,
     ,                 trcdbgs,trcdbgg,trcdbgmpi,trcdbgc
      write(iunoo,706) (trcsrc(j),j=0,nstrao)
      write(iunoo,707) nvolpr
      do j=1,nvolpr !{
        write(iunoo,707) ntlv(j),nflgv(j),nspzv1(j),nspzv2(j),ntlvf(j)
      end do !}
      write(iunoo,707) jsurpr
      do j=1,jsurpr !{
        write(iunoo,707) nsrf(j),ntls(j),nflgs(j),nspzs1(j),nspzs2(j)
      end do !}

c**  2d geometry plot

      write(iunoo,706) pl1st,pl2nd,pl3rd,pladd,plhst,
     ,                 plcut(1),plcut(2),plcut(3),plbox,plstor,
     ,                 plnumv,plnums,plarr,lrpscut,plidl,
     ,                 plvtk
      write(iunoo,707) nplinr,nplotr,npldlr,nplinp,nplotp,npldlp,
     ,                                      nplint,nplott,npldlt,nsrfcls
      do j=1,abs(nsrfcls) !{
        write(iunoo,707) msrfcls(j)
        if(msrfcls(j).gt.0) then !{
          write(iunoo,707) (lsrfcls(i,j),i=1,msrfcls(j))
        end if !}
      end do !}

c**  3d geometry plot

      do j=1,5 !{
        write(iunoo,702) pl3a(j),textla(j),iplta(j),
     .                   (iplaa(j,i),iplea(j,i),i=1,iplta(j))
      end do !}
      do j=1,3 !{
        write(iunoo,702) pl3s(j),textls(j),iplts(j),
     .                   (iplas(j,i),iples(j,i),i=1,iplts(j))
      end do !}

      write(iunoo,703) ch2mx,ch2my,      ch2x0,ch2y0,ch2z0
      write(iunoo,703) ch3mx,ch3my,ch3mz,ch3x0,ch3y0,ch3z0
      write(iunoo,703) angle1,angle2,angle3

c**  particle history plots in 2d or 3d geometry plots
      write(iunoo,707) i1trc,i2trc,(isyplt(j),j=1,8),ilinie

      write(iunoo,707) nvolpl
      if(nvolpl.gt.0) then !{

        write(iunoo,706) (pltsrc(j),j=0,nstrao)
        if (lrpscut) then !{
          write(iunoo,703) cutplane
        end if !}
        do j=1,nvolpl !{
          write(iunoo,707) nsptal(j)
          write(iunoo,706) pltl2d(j),pltl3d(j),pltllg(j),pltler(j)
          write(iunoo,703) talzmi(j),talzma(j),talxmi(j),talxma(j),
     ,                     talymi(j),talyma(j)
          if(pltl2d(j)) then !{
            write(iunoo,706) lhist2(j),lsmot2(j)
            do i=1,nsptal(j) !{
              write(iunoo,707) ispzt2(j,i),nptal2(j,i),
     ,                         nplin2(j,i),nplot2(j,i),npldl2(j,i)
            end do !}
          end if !}
          if (pltl3d(j)) then !{
            write(iunoo,706) lhist3(j),lcntr3(j),lsmot3(j),lraps(j),
     ,                       lvect3(j),lrpvc3(j),lrps3d(j),lrpscn(j)
            write(iunoo,706) lprad(j),lppol(j),lptor(j)
            do i=1,nsp(j) !{
              write(iunoo,707) ispzt3(j,i),nptal3(j,i),iproj3(j,i),
     ,         npli13(j,i),nplo13(j,i),npli23(j,i),nplo23(j,i),
     ,         ipln(j,i)
            end do !}
            write(iunoo,703) talw1(j),talw2(j),
     ,                                     fcabs1(j),fcabs2(j),rpsdl(j)
          end if !}
        end do !}
      end if !}

c*** 12.  data for diagnostic module

      write(iunoo,700) utxthd(18)
      write(iunoo,707) nchori,ncheni,lntspec,lntsput,nmcsput,
     ,                                         nlstadds,mtreadds,ngwties
      if (nchori.gt.0) then !{
        do ichori=1,nchori !{
          write(iunoo,700) txtsig(ichori)
          write(iunoo,707) nchtal(ichori),nspscl(ichori),nspnew(ichori)
          write(iunoo,707) nspstr(ichori),nspspz(ichori),
     ,                      nspini(ichori),nspend(ichori),
     ,                      nspblc(ichori),nspadd(ichori),masloc(ichori)
          write(iunoo,703) emin1(ichori),emax1(ichori)
          write(iunoo,704) ipivot(ichori),xpivot(ichori),
     ,                                    ypivot(ichori),zpivot(ichori)
          write(iunoo,704) ichord(ichori),xchord(ichori),
     ,                                    ychord(ichori),zchord(ichori)
        end do !}
        write(iunoo,706) plchor,plspec,prspec,plargl,prargl
      end if !}
      if(lntspec.gt.0) write(iunoo,'(1p,2e12.5,4i6)') emnspc,emxspc,
     ,                                   npspcen,iatspec,npspctt,npspcfi
      do i=1,lntsput !{
        write(iunoo,'(2(i6,2x,a2,2x))') listmtmp(i),txtmtmp(i),
     ,                                            listmtra(i),txtmtra(i)
      end do !}
      if(nlstadds.gt.0) then !{
        write(iunoo,707) (listadds(i),i=1,nlstadds)
        write(iunoo,707) (listaddg(i),i=1,nlstadds)
      end if !}
      
      do j=1,ngwties !{
        write(iunoo,707) kgwties(j),mgwties(j)
        if(mgwties(j).gt.0)
     -                    write(iunoo,707) (lgwties(i,j),i=1,mgwties(j))
      end do !}

c*** CH4 - lines go here - TBD !

c*** Postprocessing windows

      if(npwin.gt.0) then !{
        write(iunoo,707) npwin
        do i=1,npwin !{
          write(iunoo,707) i,npwsurf(i)
          write(iunoo,707) (pwsurf(j,i),j=1,npwsurf(i))
          write(iunoo,707) i,npwtally(i)
          write(iunoo,707) (100*pwtally(j,i)+pwspecy(j,i),
     ,                                                  j=1,npwtally(i))
          if(lpw_d(i)) then !{
            write(iunoo,'(a3)') '///'
            write(iunoo,707) (100*pwtally_d(j,i)+pwspecy_d(j,i),
     ,                                                  j=1,npwtally(i))
          end if !}
        end do !}
      end if !}

c*** 13.  data for nonlinear and time dep. option

      write(iunoo,700) utxthd(25)

c*** the number of histories to be saved

      write(iunoo,707) nprnli, ninitl_read
      if(nprnli.gt.0) then !{

c*** the number of timesteps in Eirene, the timestep, and starting time

        write(iunoo,707) nptst,ntmstp
        write(iunoo,703) dtimv,time0

        write(iunoo,700) utxthd(26)
        write(iunoo,707) nsnvi
        do j=1,nsnvi !{
          write(iunoo,707) isnve(j),isnvs(j),isnvt(j),isnrc(j)
          write(iunoo,711) txttlv(j)
          write(iunoo,712) txtspv(j),txtunv(j)
             end do !}
      end if !}

c*** 14.  data for interfacing subroutine infcop

      write(iunoo,700) utxthd(19)
      if (nmode.ne.0) then !{
        write(iunoo,706) lsymet,lbalan,lcoarse,nltrimesh
        write(iunoo,707) nfla,ncutb,ncutl,imf,
     .                   ntrfrm,nfull,ibrad,ibpol,ibtor
        do i=1,nplsi+nbgk !{
          write(iunoo,710) i,iflb(i),fcte(i),bmass(i),lkindp(i)
        end do !}
        write(iunoo,707) ndxa,ndya
        write(iunoo,707) ntargi
        write(iunoo,707) (ntgprt(i),i=1,ntargi)
        l=maxval(ntgprt)
        k=1
        m=0
        if(l.gt.1) then !{
          m=1
          k=10
        end if !}
        if(l.ge.10) k=100
        if(l.ge.100) k=1000
        do i=1,ntargi !{
          do j=1,ntgprt(i) !{
            write(iunoo,707) k*i+j*m,ndt2(i,j),ninct2(i,j),nixy2(i,j),
     ,          ntin2(i,j),nten2(i,j),niflg(i,j),nptc(i,j),nptcm(i,j),
     ,                                  nspzi(i,j),nspze(i,j),nemod(i,j)
          end do !}
        end do !}
        if(lfchgs) then !{
          x=istramin
          y=istramax
          write(iunoo,703) 0.,x,y,0.
          do i=istramin,istramax !{
            write(iunoo,'(i3,1p,4e12.5)') i,
     ,                           chgsp(i),chgsee(i),chgsei(i),chgsmom(i)
          end do !}
        else !}{
          write(iunoo,703) chgsp(1),chgsee(1),chgsei(1),chgsmom(1)
        end if !}
      end if !}

c*** B2 tallies for Eirene

      write(iunoo,707) nainb,ncopib,ncopeb
      do i=1,nainb !{
        write(iunoo,707) i,nains(i),naint(i)
        write(iunoo,711) txtpls(i)
        write(iunoo,712) txtpsp(i),txtpun(i)
      end do !}
c*** Eirene  tallies for B2
      write(iunoo,707) naotb
      do i=1,naotb !{
          write(iunoo,707) i,naots(i),naott(i)
      end do !}

c*** 15. additional information for geousr

c*** segment numbers for the target edges to be modified by geousr

      write(iunoo,700) utxthd(27)
      if(lm_cnfg) then
        write(iunoo,707) nadmod,ntrgte/2
      else
        write(iunoo,707) nadmod,ntrgte
      endif
      do i=1,nadmod !{
        write (iunoo,'(2i6,1p,3e12.5)') nrs(i),ipunkt(i),
     ,                                        xcoor(i),ycoor(i),zcoor(i)
      end do !}
      if(ntrgte.gt.0) then !{
        do i=1,ntrgte !{
          if (lm_cnfg.and.mod(i,2).eq.1) cycle
          write(iunoo,'(2i6,1p,2e12.5)') jedge(2,i),jedge(1,i),
     ,                                             xpolpos(i),ypolpos(i)
        end do !}
      end if !}

      call subend ()
      return
c=======================================================================
  700 format ('*',a71)
  701 format (1p,i3,1x,a6,1x,a4,a9,a3,2i3,5e12.5)
  702 format (l1,1x,a24,1x,i1,1x,4(2i3,1x))
  703 format (1p,6e12.5)
  704 format (1p,i6,6x,5e12.5)
  705 format (1p,2(i6,6x),4e12.5)
  706 format (12(5l1,1x))
  707 format (12i6)
  708 format (i2,1x,a8,12i3,1x,a10,1x,i2)
 7080 format (i2.2,1x,a8,12i3,1x,a10,1x,i2)
  709 format ('* ',i3,' : ',a64)
  710 format (1p,2i6,2e12.5,i6)
  711 format (a72)
  712 format (2a24)
  713 format (1p,6i6,3e12.5)
  714 format ('* ',i3,' : ',i3,' ',a64)
  715 format (a72)
  716 format (a8,1x,a8,1p,e12.5)
  717 format (a8,1x,a8,i6)
  718 format (1p,2e12.5,8i6)
  719 format (1p,2i6,5e12.5)
  720 format (a47)
c=======================================================================
      end
