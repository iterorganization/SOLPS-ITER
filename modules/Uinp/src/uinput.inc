c  VERSION : 05.01.2005 00:01

#include "uinpcom.inc"

c*** 0: additional data for uinout control
c*** Temporary - max. number of reactions in cdenmodel section
      integer nrcdn
      parameter (nrcdn=1)


c*** 1
      integer nmach,nmode,ntcpu,nfile,niter0,niter,ntime0,ntim1,nfullrun 
      integer noptim,noptm1,ngeom_usr,ncoup_input,nsmstra,
     ,        nstoram,ngstal,nrtal1,nreac_add,lfrm15
      logical nlscl,nltest,nlana,nldrft,nlcrr,nlerg,nlident,nlone,
     ,        nlmovie,nldfst,nloldran,nlcascad,nloctree,nlwrmsh,
     ,        nexvs,nltrimesh 
      character txtrun*71

c*** 2

      integer indgrd(3),nr1st,nrsep,nrplg,npplg,nrknot,npoin1(2,nppart),
     ,  necke(3,n1st),nchbar(3,n1st),nseite(3,n1st),inmti(3,n1st),
     ,  np2nd,npsep,nppla,npper,nt3rd,ntsep,nttra,ntper,nbmlt,nradd
      real ria, ragrid, raa, rarefl, ep1in, ep1ot, ep1ch, exep1, ellin,
     ,  ellot, ellch, exell, triin, triot, trich, extri,
     ,  xpcor, ypcor, zpcor, plrefl, xpol(n1st,nplg), ypol(n1st,nplg),
     ,  xtrian(nntrian), ytrian(nntrian), yia, yagrid, yaa, yya, zia,
     ,  zagrid, zaa, zza, roa, volcor(nbmax), voladd(nadd)
      logical nlrad, nlslb, nlcrc, nlell, nltri, nlplg, nlfem, nltet,
     ,    nlgen, nlpol, nlply, nlpla, nlplp, nltor, nltrz, nltra,
     ,    nltrt, nlmlt, nladd

c*** 3a

      integer nstsi,    idimp(nsts),  inump(nsts),  irpta1(nsts),
     ,    irpte1(nsts), irpta2(nsts), irpte2(nsts), irpta3(nsts),
     ,    irpte3(nsts), iliin(nsts),  ilside(nsts), ilswch(nsts),
     ,    ilequi(nsts), iltor(nsts),  ilcol(nsts),  ilfit(nsts),
     ,    ilcell(nsts), ilbox(nsts),  ilplg(nsts),  ilref(nsts),
     ,    ilsptp(nsts), ilsptc(nsts), isrss(nsts),  isrc(nsts),
     ,    lchspnws(nsts),isrsg(nsts)
      real xmlim(nsts), ewall(nsts),  ewbin(nsts),  transp(nsts,2),
     ,    recycc(nsts), recycf(nsts), recyct(nsts), recprm(nsts),
     ,    recycs(nsts), exppl(nsts),  expel(nsts),  expil(nsts),
     ,    fsheat(nsts), echspts(nsts),fchspts(nsts),sptprm(nsts) 
      character txtsfl(nsts)*64

c*** 3b

      integer nlimi,    itend(nlim),  itini(nlim), jliin(nlim),
     ,    jlside(nlim), jlequi(nlim), jltor(nlim), jlcol(nlim),
     ,    jlfit(nlim),  jlbox(nlim),  jlref(nlim), jlsptp(nlim),
     ,    jlsptc(nlim), jsrss(nlim),  jsrc(nlim),  lchspnwa(nlim),
     ,    jsrsg(nlim),  jlplg(nlim)
      integer jadch0(nlim), jadch1(nlim,nlim), jadnsw(nlim),
     ,    jadmsw(nlim), jadlsw(nlim), jadksw(nlim), jadjsw(nlim),
     ,    jadisw(nlim), jlblck(nlim), jlacll(nlim)
      real rlb(nlim),  sarea(nlim),rlwmn(nlim),rlwmx(nlim),
     ,     a0lm(nlim), a1lm(nlim), a2lm(nlim), a3lm(nlim), a4lm(nlim),
     ,     a5lm(nlim), a6lm(nlim), a7lm(nlim), a8lm(nlim), a9lm(nlim),
     ,     p1(3,nlim), p2(3,nlim), p3(3,nlim), p4(3,nlim), p5(3,nlim),
     ,     p6(3,nlim), xlims1(nlim,9), ylims1(nlim,9), zlims1(nlim,9),
     ,     xlims2(nlim,9), ylims2(nlim,9), zlims2(nlim,9),
     ,     alims(nlim,9), xlims(nlim,9), ylims(nlim,9), zlims(nlim,9),
     ,     alims0(nlim,9), xlims3(nlim,9), ylims3(nlim,9),
     ,     zlims3(nlim,9), xmlma(nlim), ewala(nlim), ewbna(nlim),
     ,     trnspa(nlim,2), rcycca(nlim), rcycfa(nlim), rcycta(nlim),
     ,     rcycsa(nlim), exppla(nlim), expela(nlim), expila(nlim),
     ,     rcprma(nlim), sptpra(nlim), echspta(nlim),fchspta(nlim),
     ,     xlcor(nlim), ylcor(nlim), zlcor(nlim),
     ,     xlref(nlim), ylref(nlim), zlref(nlim), xlrot(nlim),
     ,     ylrot(nlim), zlrot(nlim), alrot(nlim), fsheata(nlim)
      character txtsfa(nlim)*64

c*** 4

      integer nreaci, ir(mreac), massp(mreac), iz(mreac),
     ,    masst(mreac),
     ,    ifex1mn(mreac), ifex1mx(mreac),
     ,    ifex2mn(mreac), ifex2mx(mreac), nrcln
      real delpot(mreac),
     ,  rc1mn(mreac),rc1mx(mreac),rc2mn(mreac),rc2mx(mreac),
     ,  fp1(mreac,6),fp2(mreac,6),
     ,  creac(9,mreac)
      logical lconst(mreac)
      character filnam(mreac)*8, h123(mreac)*4, reac(mreac)*9,
     ,    crc(mreac)*3,elname(mreac)*2

c*** 4a

      integer natmi,nmeta,
     ,  nmassa(natm),nchara(natm),isrfa(natm),isrta(natm),
     ,  nmseca(natm),nrca(natm),nfola(natm),ngena(natm),nhsta(natm),
     ,  ireaca(natm,nreac),ibulka(natm,nreac),iscd1a(natm,nreac),
     ,  iscd2a(natm,nreac),iscd3a(natm,nreac),iscd4a(natm,nreac),
     ,  iscdea(natm,nreac),iestma(natm,nreac),ibgka(natm,nreac)
      real eeleca(natm,nreac), ebulka(natm,nreac), escd1a(natm,nreac),
     ,     escd2a(natm,nreac), freaca(natm,nreac), edpota(natm,nreac)
      character texta(natm)*8

c*** 4b

      integer nmoli,nmassm(nmol),ncharm(nmol),nprtm(nmol),isrfm(nmol),
     ,  isrtm(nmol),nmsecm(nmol),nrcm(nmol),
     ,  nfolm(nmol),ngenm(nmol),nhstm(nmol),lkindm(nmol),
     ,  ireacm(nmol,nreac),ibulkm(nmol,nreac),iscd1m(nmol,nreac),
     ,  iscd2m(nmol,nreac),iscd3m(nmol,nreac),iscd4m(nmol,nreac),
     ,  iscdem(nmol,nreac),iestmm(nmol,nreac),ibgkm(nmol,nreac)
      real eelecm(nmol,nreac), ebulkm(nmol,nreac), escd1m(nmol,nreac),
     ,     escd2m(nmol,nreac), freacm(nmol,nreac)
      character textm(nmol)*8

c*** 4c

      integer nioni,nmassi(nion),nchari(nion),nprti(nion),nchrgi(nion),
     ,  isrfi(nion),isrti(nion),nmseci(nion),nrci(nion),nfoli(nion),
     ,  ngeni(nion),nhsti(nion),lkindi(nion),
     ,  ireaci(nion,nreac),ibulki(nion,nreac),
     ,  iscd1i(nion,nreac),iscd2i(nion,nreac),iscd3i(nion,nreac),
     ,  iscd4i(nion,nreac),
     ,  iscdei(nion,nreac),iestmi(nion,nreac),ibgki(nion,nreac)
      real eeleci(nion,nreac), ebulki(nion,nreac), escd1i(nion,nreac),
     ,     escd2i(nion,nreac), freaci(nion,nreac)
      character texti(nion)*8

c*** 4d

      integer nphti,isrff(npht),isrtf(npht),nmsecf(npht),
     ,  nrcf(npht),nfolf(npht),ngenf(npht),nhstf(npht),
     ,  ireacf(npht,nreac),ibulkf(npht,nreac),
     ,  iscd1f(npht,nreac),iscd2f(npht,nreac),iscd3f(npht,nreac),
     ,  iscd4f(npht,nreac),
     ,  iscdef(npht,nreac),iestmf(npht,nreac),ibgkf(npht,nreac)
      real eelecf(npht,nreac),ebulkf(npht,nreac),escd1f(npht,nreac),
     ,     escd2f(npht,nreac),freacf(npht,nreac),edpotf(npht,nreac)
      character textf(npht)*8


c*** 5

      integer nplsi,nbgk,
     ,  nmassp(npls),ncharp(npls),nprtp(npls),nchrgp(npls),
     ,  isrfp(npls),isrtp(npls),nmsecp(npls),nrcp(npls),idnslmp(npls),
     ,  nfolp(npls),ngenp(npls),nhstp(npls),
     ,  ireacp(npls,nreac),ibulkp(npls,nreac),
     ,  iscd1p(npls,nreac),iscd2p(npls,nreac),iscd3p(npls,nreac),
     ,  iscd4p(npls,nreac),iscdep(npls,nreac),nrep(npls)
      real eelecp(npls,nreac), ebulkp(npls,nreac), escd1p(npls,nreac),
     ,     escd2p(npls,nreac), freacp(npls,nreac)
      integer ispcdn(npls,nrcdn),itpcdn(npls,nrcdn),istrcdn(npls,nrcdn)
      real valcdn(npls,5),bltzcdn(npls),dltecdn(npls),acrncdn(npls)
      character cdnmdlp(npls)*(ldnmdlp),fnamcdn(npls,nrcdn)*6,
     ,    h2cdn(npls,nrcdn)*4,reaccdn(npls,nrcdn)*9,crcdn(npls,nrcdn)*3
      integer indpro(12)
      real te0, te1, te2, te3, te4, te5,
     ,     ti0(npls), ti1(npls), ti2(npls), ti3(npls), ti4(npls),
     ,     ti5(npls), di0(npls), di1(npls), di2(npls), di3(npls),
     ,     di4(npls), di5(npls), vx0(npls), vx1(npls), vx2(npls),
     ,     vx3(npls), vx4(npls), vx5(npls), vy0(npls), vy1(npls),
     ,     vy2(npls), vy3(npls), vy4(npls), vy5(npls), vz0(npls),
     ,     vz1(npls), vz2(npls), vz3(npls), vz4(npls), vz5(npls),
     ,     b0, b1, b2, b3, b4, b5, vl0, vl1, vl2, vl3, vl4, vl5
      character textp(npls)*8

c*** 6

      integer luftrm
      parameter (luftrm=1)
      integer nnftrm, nchsppri,
     ,     lchsptrg(nchsppr), lchspgrp(nchsppr),
     ,     lchspprt(nchsppr), lchspprp(nchsppr), lchsptgt(nchsppr),
     ,     lchsptgp(nchsppr), lchspnwl(nchsppr), lchspaux(5,nchsppr)
      real datm(natm), dmol(nmol), dion(nion), dpls(npls), ermin,
     ,     ercut, rprob0, rinteg, einteg, ainteg,
     ,     ychsptg(nchsppr), echsptg(nchsppr), fchsptg(nchsppr),
     ,     achsptg(3,nchsppr)
      logical nltrim
      character*8 filtrm(nhd6),path*60

c*** Surface Cards
      integer maxsc,nscards
      parameter (maxsc=100)
      character*(72) scard_name(maxsc)
      integer scilref(maxsc),scilspt(maxsc),scisrs(maxsc),
     ,       scisrc(maxsc),sclchspnwl(maxsc),scisrsg(maxsc)
      real scxmlim(maxsc),scewall(maxsc),scewbin(maxsc),
     ,  sctransp(maxsc,2),scfsheat(maxsc),screcycf(maxsc),
     ,  screcyct(maxsc),scrcprm(maxsc),scexppl(maxsc),scexpel(maxsc),
     ,  scexpil(maxsc),screcycs(maxsc),scychsptg(maxsc),
     ,  scechsptg(maxsc),scfchsptg(maxsc),scstprm(maxsc)  
      integer iscrd(nsts),jscrd(nlim)
      integer maxchmvar,maxchsc,nchemvar
      parameter (maxchmvar=nlim,maxchsc=nlim*(natm+nmol+nion+npht+npls))
      integer nnchemvar(maxsc),indchemvar(maxchsc)
      character*8 chvarname(maxchsc),chmspname(maxchsc)
      real chmvar(maxchsc) 

c*** 7

      integer nstrai,indsrc(nstra),npts(nstra),ninitl(nstra),
     ,  nemods(nstra),namods(nstra),nminpts(nstra),nspez(nstra),
     ,  ivlsf(nstra),iscls(nstra),isclt(nstra),iscl1(nstra),
     ,  iscl2(nstra),iscl3(nstra),isclb(nstra),iscla(nstra),
     ,  nsrfsi(nstra),indim(nsrfs,nstra), insor(nsrfs,nstra),
     ,  ingrda(nsrfs,nstra,3),ingrde(nsrfs,nstra,3),nrsor(nsrfs,nstra), 
     ,  npsor(nsrfs,nstra),ntsor(nsrfs,nstra),nbsor(nsrfs,nstra), 
     ,  nasor(nsrfs,nstra),nisor(nsrfs,nstra),     istor(nsrfs,nstra)
      real alloc, flux(nstra), scalv(nstra),       sorwgt(nsrfs,nstra),
     ,     sorlim(nsrfs,nstra),sorind(nsrfs,nstra),sorexp(nsrfs,nstra),
     ,     sorifl(nsrfs,nstra),sorad1(nsrfs,nstra),
     ,     sorad2(nsrfs,nstra),sorad3(nsrfs,nstra),
     ,     sorad4(nsrfs,nstra),sorad5(nsrfs,nstra),
     ,     sorad6(nsrfs,nstra),soreni(nstra), sorene(nstra),
     ,     sorvdx(nstra), sorvdy(nstra), sorvdz(nstra), sorcos(nstra),
     ,     sormax(nstra), sorctx(nstra), sorcty(nstra), sorctz(nstra)
      logical nlavrp(nstra), nlavrt(nstra), nlsymp(nstra),
     ,    nlsymt(nstra), nlatm(nstra), nlmol(nstra), nlion(nstra),
     ,    nlpls(nstra), nlpnt(nstra), nllne(nstra), nlsrf(nstra),
     ,    nlvol(nstra), nlcns(nstra), nlray(nstra), nlphot(nstra)
      character txtsou(nstra)*64

c*** 8

      integer nzadd, ini(nrad), ine(nrad)

c*** 9

      integer nprcsf,iprcsf(nlimps),maxlev,maxrad,maxpol,maxtor,maxadd,
     ,  nssplr(n1st),nssplp(n2nd),nssplt(n3rd),nsspla(nlim),
     ,  nsigvi,nsigsi,nsigci,nsigi_bgk,nsigi_cop,
     ,  igh(nsd),iih(nsd),ighw(nsdw),iihw(nsdw),ighc(2,ncv),iihc(2,ncv)
      real prmrspl(n1st),prmpspl(n2nd),prmtspl(n3rd),prmaspl(nlim),
     ,  wminv,wmins,wminc,splpar
      logical nlprca(natm),nlprcm(nmol),nlprci(nion),nlprcph(npht),
     ,  llpbls,nlpbls(natm,nstra)

c*** 10

      integer nadvi, nclvi, nalvi, nadsi, nalsi, nadspc

c*** 10a

      integer iadve(nadv), iadvs(nadv), iadvt(nadv), iadrc(nadv)
      character txttla(nadv)*72, txtspa(nadv)*24, txtuna(nadv)*24

c*** 10b

      integer iclve(nclv), iclvs(nclv), iclvt(nclv), iclrc(nclv)
      character txttlc(nclv)*72, txtspc(nclv)*24, txtunc(nclv)*24

c*** 10c

      character chrtal(nalv)*71
      character txttlr(nalv)*72, txtspr(nalv)*24, txtunr(nalv)*24

c*** 10d

      integer iadse(nads), iadss(nads), iadst(nads), iadsc(nads)
      character txttld(nads)*72, txtspd(nads)*24, txtund(nads)*24

c*** 10e

      character chrtls(nals)*71, txtsps(nals)*24, txttls(nals)*72,
     ,    txtuns(nals)*24

c*** 10f

      integer ispsrf(nads), iptyp(nads), ipspz(nads), isptyp(nads),
     ,        nsps(nads), isrfcl(nads), idirec(nads)
      real spcmn(nads), spcmx(nads), spcsh(nads), spcpx(nads),
     ,     spcpy(nads), spcps(nads), spcvx(nads), spcvy(nads),
     ,     spcvz(nads)

c*** 11

      integer nvolpr,ntlv(ntalv),nflgv(ntalv),nspzv1(ntalv),
     ,  nspzv2(ntalv),ntlvf(ntalv),nsurpr,nsrf(nlimps),ntls(nlimps),
     ,  nflgs(nlimps),nspzs1(nlimps),nspzs2(nlimps),nsptal(nptal),
     ,  nplinr,nplotr,npldlr,nplinp,nplotp,npldlp,nplint,nplott,npldlt,
     ,  iplta(5),iplaa(5,4),iplea(5,4),iplts(3),iplas(3,4),iples(3,4),
     ,  i1trc,i2trc,isyplt(8),ilinie,nvolpl,nptal2(nptal,nplt),
     ,  nptal3(nptal,nplt),nsp(nptal),ispzt2(nptal,nplt),
     ,  ispzt3(nptal,nplt),nplin2(nptal,nplt),nplot2(nptal,nplt),
     ,  npldl2(nptal,nplt),iproj3(nptal,nplt),npli13(nptal,nplt),
     ,  nplo13(nptal,nplt),npli23(nptal,nplt),nplo23(nptal,nplt),
     ,  ipln(nptal,nplt),
     ,  nsrfcls,msrfcls(nsrfclsx),lsrfcls(msrfclsx,nsrfclsx)
      real ch2mx,ch2my,ch2x0,ch2y0,ch2z0,ch3mx,ch3my,ch3mz,ch3x0,ch3y0,
     ,  ch3z0,angle1,angle2,angle3,cutplane(4),talzmi(nptal),
     ,  talzma(nptal),talxmi(nptal),talxma(nptal),talymi(nptal),
     ,  talyma(nptal),talw1(nptal),talw2(nptal),fcabs1(nptal),
     ,  fcabs2(nptal),rpsdl(nptal)
      logical trcplt, trchst, trcnal, trcmod, trcsig, trcgrd, trcsur,
     ,  trcref, trcfle, trcamd, trcint, trctim, trcsou, trcrec,
     ,  trclst, trcbla, trcblm, trcbli, trcblp, trcble, 
     ,  trcblph,trctal, trcoct, trccen, trcrnf,
     ,  trcdbg2,trcdbge,trcdbgm,trcdbgf,trcdbgl,
     ,  trcdbgs,trcdbgg,trcdbgmpi,trcdbgc,
     ,  trcsrc(0:nstra),pl1st,pl2nd,pl3rd,pladd,plhst,plcut(3),plbox,
     ,  plstor,plnumv,plnums,plarr,lrpscut,pltsrc(0:nstra),pl3a(5),
     ,  pl3s(3),pltl2d(nptal),pltl3d(nptal),pltllg(nptal),pltler(nptal),
     ,  lhist2(nptal),lsmot2(nptal),lhist3(nptal),lcntr3(nptal),
     ,  lsmot3(nptal),lraps(nptal),lvect3(nptal),lrpvc3(nptal),
     ,  lrps3d(nptal),lrpscn(nptal),lprad(nptal),lppol(nptal),
     ,  lptor(nptal),plidl,plvtk
      character textla(5)*24, textls(3)*24

c*** 12

      integer ngwtiesx
      parameter (ngwtiesx=2*n2nd)
      integer nchori,ncheni,lntspec,lntsput,nmcsput,nchtal(nchor),
     ,  nspscl(nchor),nspnew(nchor),nspstr(nchor),nspspz(nchor),
     ,  nspini(nchor),nspend(nchor),nspblc(nchor),nspadd(nchor),
     ,  masloc(nchor),ipivot(nchor),ichord(nchor),npspcen,iatspec,
     ,  npspctt,npspcfi,listmtmp(lntsputx),listmtra(lntsputx),
     ,  nlstadds,mtreadds,listadds(nlimps),listaddg(nlimps),
     ,  ngwties,kgwties(ngwtiesx),mgwties(ngwtiesx),
     ,  lgwties(mgwtiesx,ngwtiesx),
     ,  npwin,npwsurf(npwinx),npwtally(npwinx),pwsurf(nlimps,npwinx),
     ,  pwtally(nlimps,npwinx),pwspecy(nlimps,npwinx),
     ,  pwtally_d(nlimps,npwinx),pwspecy_d(nlimps,npwinx)
      real emin1(nchor), emax1(nchor), xpivot(nchor), ypivot(nchor),
     ,     zpivot(nchor), xchord(nchor), ychord(nchor), zchord(nchor),
     ,     emnspc, emxspc
      logical plchor,plspec,prspec,plargl,prargl,lpw_d(npwinx)
      character txtsig(nchor)*71,txtmtmp(lntsputx)*2,txtmtra(lntsputx)*2

c*** 13

      integer nprnli, ntmstp, nptst, nsnvi, ninitl_read,
     ,  isnve(nsnv), isnvs(nsnv), isnvt(nsnv), isnrc(nsnv)
      real dtimv, time0
      character txttlv(nsnv)*71, txtspv(nsnv)*24, txtunv(nsnv)*24

c*** 14

      integer nclmi,nblcki,nprnvi,nprtvi,nprdvi,nfla,ncutb,ncutl,
     ,  imf,ntrfrm,nfull,ibrad,ibpol,ibtor,
     ,  iflb(npls),ndxa,ndya,ntargi,ntgprt(nstep),ndt2(nstep,ngitt),
     ,  ninct2(nstep,ngitt),nixy2(nstep,ngitt),ntin2(nstep,ngitt),
     ,  nten2(nstep,ngitt),niflg(nstep,ngitt),nptc(nstep,ngitt),
     ,  nptcm(nstep,ngitt),nspzi(nstep,ngitt),nspze(nstep,ngitt),
     ,  nemod(nstep,ngitt),istramin,istramax,
     ,  nainb,ncopib,ncopeb,nains(nain),naint(nain),
     ,  naotb,naots(nlimps),naott(nlimps),
     ,  lkindp(npls)
      real fcte(npls),bmass(npls),chgsp(nstra),chgsee(nstra),
     ,  chgsei(nstra),chgsmom(nstra)
      logical lsymet,lbalan,lcoarse,lfchgs
      character txtpls(nain)*72, txtpsp(nain)*24, txtpun(nain)*24

c*** 15

      integer nnadmod
      parameter (nnadmod=1)
      integer nadmod,nasmod,nrs(nnadmod),ipunkt(nnadmod),jedge(2,8)
      real xcoor(nnadmod),ycoor(nnadmod),zcoor(nnadmod),
     ,  xpolpos(8),ypolpos(8)

c*** b2ah.dat

      integer cbnrmx
      parameter (cbnrmx=6+2+1+1)
      integer cbnrso,cbnrno,cbnrwe,cbnrea,
     ,        cbirso,cbirno,cbirwe,cbirea,
     ,        izamin(0:natm+npls-1),izamax(0:natm+npls-1),nbndl(natm)
      real cbrbrk(0:cbnrmx-1),
     ,     cbsna(0:7,0:nsdb2-1,0:cbnrmx-1),
     ,     cbsmo(0:7,0:nsdb2-1,0:cbnrmx-1),
     ,     cbshi(0:7,0:nsdb2-1,0:cbnrmx-1),
     ,     cbrec(0:7,0:nsdb2-1,0:cbnrmx-1),
     ,     cbmsb(0:7,0:nsdb2-1,0:cbnrmx-1),
     ,     cbshe(0:7,0:cbnrmx-1),
     ,     cbsch(0:7,0:cbnrmx-1),
     ,     cbmsa(0:7,0:cbnrmx-1),
     ,     cfdf0(0:7,0:nsdb2-1),
     ,     cfdna(0:7,0:nsdb2-1),
     ,     cfdpa(0:7,0:nsdb2-1),
     ,     cfvla(0:7,0:nsdb2-1),
     ,     cfvsa(0:7,0:nsdb2-1),
     ,     cfhci(0:7,0:nsdb2-1),
     ,     cfhce(0:7),
     ,     cfsig(0:7),
     ,     cfalf(0:7),
     ,     cflim(0:7)
      logical is_bundled(natm)

      common/uinint/
     ,  nmach,nmode,ntcpu,nfile,niter0,niter,ntime0,ntim1,nfullrun,
     ,  noptim,noptm1,ngeom_usr,ncoup_input,nsmstra,
     ,  nstoram,ngstal,nrtal1,nreac_add,nscards,lfrm15,
     ,  indgrd,nr1st,nrsep,
     ,  nrplg,npplg,nrknot,npoin1,necke,nchbar,nseite,inmti,
     ,  np2nd,npsep,nppla,npper,nt3rd,ntsep,nttra,ntper,nbmlt,
     ,  nradd,nstsi,idimp,inump,irpta1,irpte1,irpta2,irpte2,irpta3,
     ,  irpte3,iliin,ilside,ilswch,ilequi,iltor,ilcol,ilfit,ilcell,
     ,  ilbox,ilplg,ilref,ilsptp,ilsptc,isrss,isrc,lchspnws,isrsg,
     ,  nlimi,itend,
     ,  itini,jliin,jlside,jlequi,jltor,jlcol,jlfit,jlbox,jlplg,jlref,
     ,  jsrss,jsrc,lchspnwa,jsrsg,
     ,  jlsptp,jlsptc,nreaci,ir,massp,masst,
     ,  ifex1mn,ifex1mx,ifex2mn,ifex2mx,iz,nrcln,
     ,  natmi,nmeta,
     ,  nmassa,nchara,isrfa,isrta,nmseca,nrca,nfola,ngena,nhsta,
     ,  ireaca,ibulka,iscd1a,iscd2a,iscd3a,iscd4a,iscdea,iestma,ibgka,
     ,  nmoli,nmassm,ncharm,nprtm,isrfm,isrtm,
     ,  nmsecm,nrcm,nfolm,ngenm,nhstm,
     ,  ireacm,ibulkm,iscd1m,iscd2m,iscd3m,iscd4m,iscdem,iestmm,ibgkm,
     ,  nioni,nmassi,nchari,nprti,nchrgi,isrfi,isrti,nmseci,nrci,nfoli,
     ,  ngeni,nhsti,
     ,  ireaci,ibulki,iscd1i,iscd2i,iscd3i,iscd4i,iscdei,iestmi,ibgki,
     ,  nphti,isrff,isrtf,nmsecf,nrcf,nfolf,
     ,  ngenf,nhstf,
     ,  ireacf,ibulkf,iscd1f,iscd2f,iscd3f,iscd4f,iscdef,iestmf,ibgkf,
     ,  nplsi,nbgk,nmassp,ncharp,nprtp,nchrgp,isrfp,
     ,  isrtp,nmsecp,nrcp,idnslmp,nfolp,ngenp,nhstp,ireacp,ibulkp,
     ,  iscd1p,iscd2p,iscd3p,iscd4p,iscdep,nrep,ispcdn,itpcdn,istrcdn,
     ,  indpro,nnftrm,nchsppri,
     ,  lchsptrg,lchspgrp,lchspprt,lchspprp,lchsptgt,
     ,  lchsptgp,lchspnwl,lchspaux,nchemvar,indchemvar,nnchemvar,
     ,  nstrai,indsrc,npts,ninitl,nemods,namods,nminpts,nspez,ivlsf,
     ,  iscls,isclt,iscl1,iscl2,iscl3,isclb,iscla,nsrfsi,
     ,  indim,insor,ingrda,ingrde,nrsor,npsor,ntsor,nbsor,nasor,nisor,
     ,  istor,nzadd,ini,ine,
     ,  nprcsf,iprcsf,maxlev,maxrad,maxpol,maxtor,maxadd,nssplr,nssplp,
     ,  nssplt,nsspla,nsigvi,nsigsi,nsigci,nsigi_bgk,nsigi_cop,igh,iih,
     ,  ighw,iihw,ighc,iihc,nadvi,nclvi,nalvi,nadsi,nalsi,nadspc,
     ,  iadve,iadvs,iadvt,iadrc,iclve,iclvs,iclvt,iclrc,iadse,
     ,  iadss,iadst,iadsc,
     ,  ispsrf,iptyp,ipspz,isptyp,nsps,isrfcl,idirec,
     ,  nvolpr,ntlv,nflgv,nspzv1,nspzv2,ntlvf,nsurpr,
     ,  nsrf,nflgs,nspzs1,nspzs2,nsptal,ntls,nplinr,nplotr,npldlr,
     ,  nplinp,nplotp,npldlp,
     ,  nplint,nplott,npldlt,iplta,iplaa,iplea,iplts,iplas,
     ,  iples,i1trc,i2trc,isyplt,ilinie,nvolpl,nptal2,nptal3,nsp,ispzt2,
     ,  ispzt3,nplin2,nplot2,npldl2,iproj3,npli13,nplo13,npli23,nplo23,
     ,  ipln,nsrfcls,msrfcls,lsrfcls,
     ,  nchori,ncheni,lntspec,lntsput,nmcsput,nchtal,nspscl,
     ,  nspnew,nspstr,nspspz,nspini,nspend,nspblc,nspadd,masloc,ipivot,
     ,  ichord,npspcen,iatspec,npspctt,npspcfi,listmtmp,listmtra,
     ,  nlstadds,mtreadds,listadds,listaddg,ngwties,kgwties,mgwties,
     ,  lgwties,npwin,npwsurf,npwtally,pwsurf,pwtally,pwspecy,
     ,  pwtally_d,pwspecy_d,
     ,  nprnli,ntmstp,nptst,ninitl_read,
     ,  nsnvi,isnve,isnvs,isnvt,isnrc,
     ,  jadch0,jadch1,jadnsw,jadmsw,jadlsw,jadksw,jadjsw,jadisw,
     ,  jlblck,jlacll,nclmi,nblcki,nprnvi,nprtvi,nprdvi,nfla,
     ,  ncutb,ncutl,imf,ntrfrm,nfull,ibrad,ibpol,ibtor,
     ,  iflb,ndxa,ndya,ntargi,ntgprt,ndt2,ninct2,nixy2,
     ,  ntin2,nten2,niflg,nptc,nptcm,nspzi,nspze,nemod,istramin,
     ,  istramax,nainb,ncopib,ncopeb,nains,naint,naotb,naots,naott,
     ,  lkindm,lkindi,lkindp,
     ,  nadmod,nasmod,nrs,ipunkt,jedge,
     ,  scilref,scilspt,scisrs,scisrc,sclchspnwl,scisrsg,
     ,  iscrd,jscrd,
     ,  cbnrso,cbnrno,cbnrwe,cbnrea,
     ,  cbirso,cbirno,cbirwe,cbirea,
     ,  izamin,izamax,nbndl
  
      common/uinrl/ ria,ragrid,raa,rarefl,ep1in,ep1ot,ep1ch,exep1,
     ,  ellin,ellot,ellch,exell,triin,triot,trich,extri,
     ,  xpcor,ypcor,zpcor,
     ,  plrefl,xpol,ypol,xtrian,ytrian,yia,yagrid,yaa,yya,zia,zagrid,
     ,  zaa,zza,roa,volcor,voladd,
     ,  xmlim,ewall,ewbin,transp,recycc,recycf,recyct,recprm,recycs,
     ,  exppl,expel,expil,fsheat,echspts,fchspts,sptprm,
     ,  rlb,sarea,rlwmn,rlwmx,
     ,  a0lm,a1lm,a2lm,a3lm,a4lm,a5lm,a6lm,a7lm,a8lm,a9lm,p1,p2,p3,
     ,  p4,p5,p6,xlims1,ylims1,zlims1,xlims2,ylims2,zlims2,
     ,  alims,xlims,ylims,zlims,alims0,xlims3,ylims3,zlims3,
     ,  xmlma,ewala,ewbna,trnspa,rcycca,rcycfa,rcycta,
     ,  rcycsa,exppla,expela,expila,rcprma,sptpra,echspta,fchspta,
     ,  xlcor,ylcor,zlcor,xlref,ylref,zlref,xlrot,ylrot,zlrot,alrot,
     ,  delpot,rc1mn,rc1mx,rc2mn,rc2mx,fp1,fp2,creac,
     ,  eeleca,ebulka,escd1a,escd2a,freaca,edpota,
     ,  eelecm,ebulkm,escd1m,escd2m,freacm,
     ,  eeleci,ebulki,escd1i,escd2i,freaci,
     ,  eelecf,ebulkf,escd1f,escd2f,freacf,edpotf,
     ,  eelecp,ebulkp,escd1p,escd2p,freacp,
     ,  valcdn,bltzcdn,dltecdn,acrncdn,
     ,  te0,te1,te2,te3,te4,te5,ti0,ti1,ti2,ti3,ti4,ti5,di0,di1,di2,di3,
     ,  di4,di5,vx0,vx1,vx2,vx3,vx4,vx5,vy0,vy1,vy2,vy3,vy4,vy5,vz0,vz1,
     ,  vz2,vz3,vz4,vz5,b0,b1,b2,b3,b4,b5,vl0,vl1,vl2,vl3,vl4,vl5,
     ,  datm,dmol,dion,dpls,ermin,
     ,  ercut,rprob0,rinteg,einteg,ainteg,ychsptg,echsptg,fchsptg,
     ,  achsptg,fsheata,
     ,  alloc,flux,scalv,sorwgt,sorlim,sorind,sorexp,sorifl,sorad1,
     ,  sorad2,sorad3,sorad4,sorad5,sorad6,soreni,sorene,sorvdx,
     ,  sorvdy,sorvdz,sorcos,sormax,sorctx,sorcty,sorctz,
     ,  prmrspl,prmpspl,prmtspl,prmaspl,wminv,wmins,wminc,splpar,
     ,  spcmn,spcmx,spcsh,spcpx,spcpy,spcps,spcvx,spcvy,spcvz,
     ,  ch2mx,ch2my,ch2x0,ch2y0,ch2z0,ch3mx,
     ,  ch3my,ch3mz,ch3x0,ch3y0,ch3z0,angle1,angle2,angle3,cutplane,
     ,  talzmi,talzma,talxmi,talxma,talymi,talyma,talw1,talw2,fcabs1,
     ,  fcabs2,rpsdl,emin1,
     ,  emax1,xpivot,ypivot,zpivot,xchord,ychord,zchord,emnspc,emxspc,
     ,  dtimv,time0,fcte,bmass,chgsp,chgsee,chgsei,chgsmom,
     ,  scxmlim,scewall,scewbin,sctransp,screcycf,screcyct,scrcprm,
     ,  scfsheat,scexppl,scexpel,scexpil,screcycs,scychsptg,
     ,  scechsptg,scfchsptg,scstprm,chmvar,
     ,  xcoor,ycoor,zcoor,xpolpos,ypolpos,
     ,  cbrbrk,cbsna,cbsmo,cbshi,cbrec,cbmsb,cbshe,cbsch,cbmsa,
     ,  cfdf0,cfdna,cfdpa,cfvla,cfvsa,cfhci,cfhce,cfsig,cfalf,cflim

      common/uinlog/ 
     ,  nlscl,nltest,nlana,nldrft,nlcrr,nlerg,nlident,nlone,
     ,  nlmovie,nldfst,nloldran,nlcascad,nloctree,
     ,  nlwrmsh,nexvs,nltrimesh, 
     ,  nlrad,nlslb,nlcrc,nlell,nltri,nlplg,nlfem,nltet,nlgen,
     ,  nlpol,nlply,nlpla,nlplp,nltor,nltrz,nltra,nltrt,
     ,  nlmlt,nladd,lconst,nltrim,nlavrp,nlavrt,nlsymp,nlsymt,
     ,  nlatm,nlmol,nlion,nlpls,nlpnt,nllne,nlsrf,nlvol,nlcns,nlray,
     ,  nlprca,nlprcm,nlprci,nlprcph,llpbls,nlpbls,nlphot,
     ,  trcplt,trchst,trcnal,trcmod,
     ,  trcsig,trcgrd,trcsur,trcref,trcfle,trcamd,trcint,trctim,
     ,  trcsou,trcrec,trclst,trcbla,trcblm,trcbli,trcblp,trcble,
     ,  trcblph,trctal,trcoct,trccen,trcrnf,
     ,  trcdbg2,trcdbge,trcdbgm,trcdbgf,trcdbgl,
     ,  trcdbgs,trcdbgg,trcdbgmpi,trcdbgc,
     ,  trcsrc,pl1st,pl2nd,pl3rd,pladd,plhst,plcut,plbox,plstor,plnumv,
     ,  plnums,plarr,lrpscut,pltsrc,pl3a,pl3s,pltl2d,pltl3d,pltllg,
     ,  pltler,lhist2,lsmot2,lhist3,lcntr3,lsmot3,lraps,lvect3,lrpvc3,
     ,  lrps3d,lrpscn,lprad,lppol,lptor,plidl,plvtk,
     ,  plchor,plspec,prspec,plargl,prargl,lpw_d,
     ,  lsymet,lbalan,lcoarse,lfchgs,
     ,  is_bundled

      common/uinchr/ txtrun,txtsfl,txtsfa,
     ,  filnam,h123,reac,crc,elname,
     ,  texta,textm,texti,textf,textp,
     ,  cdnmdlp,fnamcdn,h2cdn,reaccdn,crcdn,path,filtrm,
     ,  txtsou,txttla,txtspa,txtuna,txttlc,txtspc,txtunc,
     ,  txttlr,txtspr,txtunr,txttld,txtspd,txtund,chrtal,chrtls,
     ,  txtsps,txttls,txtuns,textla,textls,txtsig,txtmtmp,txtmtra,
     ,  txtpls,txtpsp,txtpun,txtspv,txttlv,txtunv,scard_name,
     ,  chvarname,chmspname

