       block data uiblkd
       use b2mod_types
       use b2mod_layer
     , , only: ntrack, nalloys
       use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx

c  version : 01.04.2005 14:35

c=======================================================================
c*** Standard set of input data for eirene - and some other data
c=======================================================================
      implicit none
#include "uinput.inc"
      integer i,j
      common /uiblkd_local/ i,j
      integer, parameter :: lurpst=n1st*nplg, luznknd=nbndzon*nbndknd,
     ,  lulim2=nlim*nlim,
     ,  lu9=9*nlim,         lustsr=nsrfs*nstra, luatsr=natm*nstra,   
     ,  lunplt=nptal*nplt,  lu21pr=2*nppart,lvrctd=mreac*nsrctd,
     ,  lu3st=3*n1st,       lugwts=mgwtiesx*ngwtiesx, lusts3=3*lustsr,
     ,  lupw=nlimps*npwinx, lusg=nstep*ngitt,
     ,  lur9=9*mreac, lur6=6*mreac, luml=3*nmol,
     ,  lcbs=8*nsdb2*cbnrmx, lcbe=8*cbnrmx, lcfs=8*nsdb2
c=======================================================================
c*** General information

      data   topo, mnpr,mnptseg,mdvbndx,  ldvbndx  ,ntrgdflt,do_hepdt /
     /        ' ',  0  ,   0   ,   0   ,0,nbnddvd*0,    0   , .false. /,
     ,  namdf,amd_file ,nnrctn,n_spcsrf,npfrgrp,lm_cnfg,lm_vhst/
     /    0  ,namdfs*' ',   0  ,   0    ,   0  ,.false., 10000 /,
     , lm_whst,   niiso   , tiiso, teiso, zaator, roator,nttrator /
     /  50000 , nsdb2*1.e5,  0.1 ,  0.1 ,  360. ,  1.e-5,   60    /,
     , nwllmrk, nedgmrk  , ntrgmrk  ,   bliin    ,    bbliin      /
     /    0   ,nwllmrkd*0,nwllmrkd*0,nsts*.false.,luznknd*.false. /,
     , glb2read,usetmstr,pwrcrtte,pwrcrtti,pwrcrfri /
     /  .false., .true. ,  50.   ,    50. ,   0.25  /,
     , spcscrk,spcicrk,spcsscn,spciscn /
     /  natm*0, natm*0, natm*1, natm*1 /,
     , nstrao,natmo,nmolo,niono,nphto,nplso /
     /    0  ,  0  ,  0  ,  0  ,  0  ,  0   /  

c*** Default boundary conditions

      integer,parameter ::luznkn=nbndzon*nbndknd, lurgkn=nbndrgn*nbndknd
      data nlrbnds / luznkn*.false. /
      data lcmbndt, lrfbndt,   bxsbndt    ,   rxsbndt    ,    dfrbndx /
     /  lurgkn*0,luznkn*0,luznkn*.false.,luznkn*.false.,nbndknd*.true./,
     ,  (jskbndx(0,i),i=1,nbndknd), (jclbndx(0,i),i=1,nbndknd) /
     /    2, 1, -3, -3    ,     nbndknd*6        /,
     ,  (jrfbndx(0,i),i=1,nbndknd), (jcsbndx(0,i),i=1,nbndknd) /
     /     0,  3*1    ,    0, 1, 0, 0        /,
     ,  (jcgbndx(0,i),i=1,nbndknd), (jpsbndx(0,i),i=1,nbndknd) /
     /    nbndknd*0   ,    0, 2, 0, 0        /,
     ,  (jppbndx(0,i),i=1,nbndknd), (etfbndx(0,i),i=1,nbndknd) /
     /    nbndknd*0   ,     nbndknd*0.         /,
     ,  (etbbndx(0,i),i=1,nbndknd), (easbndx(0,i),i=1,nbndknd) /
     /    nbndknd*0.    ,     nbndknd*0.         /,
     ,  (eewbndx(0,i),i=1,nbndknd), (efpbndx(0,i),i=1,nbndknd) /
     /        nbndknd*-0.1    ,     nbndknd*1.         /,
     ,  (efcbndx(0,i),i=1,nbndknd), (ewmbndx(0,i),i=1,nbndknd) /
     /    nbndknd*1.    ,    nbndknd*'C'         /,
     ,  (nlrbndx(0,i),i=1,nbndknd),  (jnpbndx(0,i),i=1,nbndknd)/
     /      0, 3*1    ,       2000,25000,2*2000    /,
     ,  (jmpbndx(0,i),i=1,nbndknd)/
     /       nbndknd*0            /,
     ,  (jnibndx(0,i),i=1,nbndknd),  (jnebndx(0,i),i=1,nbndknd)/
     /      4*10001     ,         6, 7, 6, 6       /,
     ,  (leebndx(0,i),i=1,nbndknd), (leibndx(0,i),i=1,nbndknd) /
     /         8, 3, 9, 9   ,    8, 3, 9, 9        /,
     ,  (lpobndx(0,i),i=1,nbndknd)/
     /        12, 3,13,13         /,
     ,  ((lcobndx(j,0,i),j=1,nsdb2),i=1,nbndknd) /
     /    nsdb2*1, nsdb2*3, nsdb2*9, nsdb2*9        /,
     ,  ((lmobndx(j,0,i),j=1,nsdb2),i=1,nbndknd) /
     /    nsdb2*2, nsdb2*3, nsdb2*2, nsdb2*2        /,
     ,  (beebndx(0,1,i),i=1,nbndknd), (beibndx(0,1,i),i=1,nbndknd)  /
     /         1.e6, 1., 2*0.03     ,      1.e6, 1.5, 2*0.03      /,
     ,  (beebndx(0,2,i),i=1,nbndknd), (beibndx(0,2,i),i=1,nbndknd)  /
     /            4*0.              ,         4*0.              /,
     ,  (bpobndx(0,1,i),i=1,nbndknd), (bpobndx(0,2,i),i=1,nbndknd)  /
     /            4*0.              ,           4*0.                /,
     ,  ((bcobndx(j,0,1,i),j=1,nsdb2),i=1,nbndknd)   /
     /    nsdb2*1.e19, nsdb2*0., nsdb2*0.03, nsdb2*0.03 /,
     ,  ((bcobndx(j,0,2,i),j=1,nsdb2),i=1,nbndknd)   /
     /      nsdb2*0., nsdb2*0., nsdb2*0., nsdb2*0.      /,
     ,  ((bmobndx(j,0,1,i),j=1,nsdb2),i=1,nbndknd)   /
     /      nsdb2*0., nsdb2*1., nsdb2*0., nsdb2*0.      /,
     ,  ((bmobndx(j,0,2,i),j=1,nsdb2),i=1,nbndknd)   /
     /      nsdb2*0., nsdb2*0., nsdb2*0., nsdb2*0.      /

c*** Default boundary conditions for particular species

      data kcobndx /
     ,  4*1,    7*8, nspdgen*3, nspdgen*9, nspdgen*9,
     ,  4*1,8,1,5*8, nspdgen*3, nspdgen*9, nspdgen*9 /
      data kmobndx / nspdgen*2, nspdgen*3, nspdgen*2, nspdgen*2,
     ,               nspdgen*2, nspdgen*3, nspdgen*2, nspdgen*2 /
      data    ((dcobndx(j,1,i,1),j=1,nspdgen),i=1,nbndknd)   /
     /      3*3.e19,8*0., nspdgen*0., nspdgen*0.03,
     ,                                          nspdgen*0.03 /,
     ,        ((dcobndx(j,2,i,1),j=1,nspdgen),i=1,nbndknd) /
     /      nspdgen*0., nspdgen*0., nspdgen*0., nspdgen*0. /,
     ,        ((dmobndx(j,1,i,1),j=1,nspdgen),i=1,nbndknd) /
     /      nspdgen*0., nspdgen*1., nspdgen*0., nspdgen*0. /,
     ,        ((dmobndx(j,2,i,1),j=1,nspdgen),i=1,nbndknd) /
     /      nspdgen*0., nspdgen*0., nspdgen*0., nspdgen*0. /
      data    ((dcobndx(j,1,i,2),j=1,nspdgen),i=1,nbndknd) /
     /      3*3.e19,2.e18,7*0.,
     ,                nspdgen*0.,nspdgen*0.03,nspdgen*0.03 /,
     ,        ((dcobndx(j,2,i,2),j=1,nspdgen),i=1,nbndknd) /
     /      nspdgen*0., nspdgen*0., nspdgen*0., nspdgen*0. /,
     ,        ((dmobndx(j,1,i,2),j=1,nspdgen),i=1,nbndknd) /
     /      nspdgen*0., nspdgen*1., nspdgen*0., nspdgen*0. /,
     ,        ((dmobndx(j,2,i,2),j=1,nspdgen),i=1,nbndknd) /
     /      nspdgen*0., nspdgen*0., nspdgen*0., nspdgen*0. /
      data dscbndx / 4*'=', '-', 3*'=', '-', '=', '-' /
      data srcmstrs / luatsr*' ' /

c*** Additional data for strata

      data tgmhst  ,mpgpfstr /
     /    ntrgts*0.,nstra*0. /

c*** He pumping data

      data locphep,lpbihep,lpbohep,lptihep,lptohep/
     /        0   ,   0   ,   0   ,   0   ,   0   /,
     ,  j_he_at , j_h_at , j_ne_at, l_h_mol /
     /     0    ,   3*0   ,    0  ,  luml*0 /,
     ,  pwrhepdt,pmphepdt,nstclhep,nhetrgts/
     /    570.  ,   0.8  ,    0   ,   0    /

c*** Data for visualisation of the surface properties

      integer, parameter :: luvsp=nsrfclsx*nvspfls
      data nsrfclu  , nsrfcls, isrfclu, msrfclu,  msrfcls   /
     /    nvspfls*0 ,    0   , luvsp*0, luvsp*0, nsrfclsx*0 /

c*** Data for TRIA mesh
      data ilplgdg,ntriref /
     /      nlim*0,   0    /                
 
c*** 1

      data nmach, nmode , ntcpu, nfile, niter0, niter, ntime0, ntim1 /
     /       2  ,   1   ,  50  ,  356 ,   1   ,   1  ,   0   ,   1   /,
     ,  nfullrun, noptim,noptm1, ngeom_usr, ncoup_input, nsmstra /
     /     0    ,   1   ,   1  ,     0    ,     1      ,    1    /,
     ,   nstoram, ngstal,nrtal1,nreac_add /
     /      9   ,   1   ,   0  ,     1    /
      data nlscl , nltest, nlana ,nldrft, nlcrr , nlerg , nlident/
     /    .true. ,.false.,.false.,.true.,.false.,.false.,.false./,
     ,     nlone , nlmovie,nldfst,nloldran,nlcascad,nloctree/
     /    .false.,.false.,.false.,.true.,.false.,.false./,
     /    nlwrmsh, nexvs ,nltrimesh/
     ,    .true. ,.false.,.false./
      data  txtrun / ' EIRENE input file generated with uinp v. 2.2' /

c*** 2

      data indgrd, nr1st, nrsep, nrplg, npplg,nrknot, npoin1  /
     /    6, 1, 1,   0  ,   1  ,   0  ,   0  ,   0  ,lu21pr*1 /,
     ,    necke , nchbar, nseite, inmti ,np2nd, npsep,nppla,npper /
     /   lu3st*0,lu3st*0,lu3st*0,lu3st*0,  0  ,   0  ,  0  ,   0  /,
     ,    nt3rd, ntsep, nttra, ntper, nbmlt, nradd /
     /      0  ,   0  ,   0  ,   0  ,   1  ,   1   /
      data ria, ragrid, raa, rarefl, ep1in, ep1ot, ep1ch, exep1 /
     /      0.,   0.  ,  0.,   0.  ,   0. ,   0. ,   0. ,   0.  /,
     ,     ellin, ellot, ellch, exell, triin, triot, trich, extri /
     /       0. ,  0.  ,   0. ,   0. ,   0. ,  0.  ,   0. ,   0.  /,
     ,     xpcor, ypcor, zpcor,plrefl,    xpol     ,    ypol      /
     /       0. ,   0. ,   0. ,  0.  ,  lurpst*0.  ,  lurpst*0.   /,
     ,     xtrian  ,  ytrian  /
     /   nntrian*0.,nntrian*0./,
     ,     yia, yagrid, yaa, yya, zia, zagrid, zaa , zza , roa /
     /      0.,   1.  ,  0.,  0.,  0.,   0.  ,  0. ,  0. ,  0. /,
     ,     volcor , voladd  /
     /    nbmax*1., nadd*1. /
      data  nlrad , nlslb , nlcrc , nlell , nltri , nlplg /
     /      .true.,.false.,.false.,.false.,.false., .true./,
     ,      nlfem , nltet , nlgen /
     /     .false.,.false.,.false./,
     ,      nlpol , nlply , nlpla , nlplp , nltor /
     /      .true.,.false.,.false.,.false.,.false./,
     ,      nltrz , nltra , nltrt , nlmlt , nladd /
     /      .true.,.false.,.false.,.false., .true./

c*** 3a

      data  nstsi , idimp , inump , irpta1, irpte1,  iliin , ilside /
     /        0   , nsts*2, nsts*1, nsts*1, nsts*0, nsts*-1, nsts*0 /,
     ,      ilswch, ilequi, ilcol , irpta2, irpte2, irpta3, irpte3 /
     /      nsts*0, nsts*0, nsts*6, nsts*0, nsts*0, nsts*0, nsts*0 /,
     ,     iltor  , ilfit , ilplg , ilbox , ilcell/
     ,     nsts*0 , nsts*0, nsts*0, nsts*0, nsts*0/,
     ,     ilref  , ilsptp, ilsptc, isrss ,  isrc ,lchspnws, isrsg  /
     /     nsts*1 , nsts*0, nsts*0, nsts*0, nsts*0, nsts*0 , nsts*0 /
      data  xmlim   ,   ewall   ,  ewbin ,    transp     , fsheat /
     /    nsts*1206., nsts*0.087, nsts*0.,nsts*0.,nsts*0.,nsts*-1./,
     ,     recycf , recyct , recprm , recycs ,  exppl ,  expel  /
     /     nsts*1., nsts*1., nsts*0., nsts*0., nsts*1., nsts*0.5/,
     /      expil , recycc , echspts, fchspts, sptprm  /
     /     nsts*1.,nsts*0.01,nsts*0., nsts*0., nsts*0. /
      data  ctxbnds / 'Core side','Target','PFR side','Outer side'/
      data tgdtinpt / .false. /
     
c*** 3b

      data laddsrfs, indasrfs, indasrfe / 0, 0, nlim*0, 0, nlim*0 /
      data nlimi, jadch0,  jadch1 , jadnsw, jadmsw, jadlsw, jadksw /
     /       0  , nlim*0, lulim2*0, nlim*0, nlim*0, nlim*0, nlim*0 /,
     ,    jadjsw, jadisw, jlblck, jlacll,  jliin, jlside /
     /    nlim*0, nlim*0, nlim*0, nlim*0, nlim*1, nlim*0 /,
     ,    jlequi,  jltor,  jlcol, jlfit,   jlbox, jlplg /
     ,    nlim*0, nlim*0, nlim*0, nlim*0, nlim*0, nlim*0 /,
     ,     jlref, jlsptp, jlsptc,  jsrss,  jsrc, lchspnwa, jsrsg /
     /    nlim*1, nlim*0, nlim*0, nlim*0, nlim*0, nlim*0, nlim*0 /,
     ,     itini,  itend /
     /    nlim*-1, nlim*0 /
      data  rlb  , sarea , rlwmn ,   rlwmx  , a0lm  , a1lm  , a2lm  /
     /    nlim*2.,nlim*1.,nlim*1.,nlim*1.e-5,nlim*0.,nlim*0.,nlim*0./,
     ,     a3lm  , a4lm  , a5lm  , a6lm  , a7lm  , a8lm  , a9lm  /
     /    nlim*0.,nlim*0.,nlim*0.,nlim*0.,nlim*0.,nlim*0.,nlim*0./,
     ,              p1           ,          p2           /
     /    nlim*0.,nlim*0.,nlim*0.,nlim*0.,nlim*0.,nlim*0./,
     ,              p3           ,          p4           /
     /    nlim*0.,nlim*0.,nlim*0.,nlim*0.,nlim*0.,nlim*0./,
     ,              p5           ,          p6           /
     /    nlim*0.,nlim*0.,nlim*0.,nlim*0.,nlim*0.,nlim*0./,
     ,     xlims1, ylims1, zlims1, xlims2, ylims2, zlims2, alims /
     /     lu9*0., lu9*0., lu9*0., lu9*0., lu9*0., lu9*0., lu9*0./,
     ,      xlims, ylims , zlims , alims0, xlims3, ylims3, zlims3/
     /     lu9*0., lu9*0., lu9*0., lu9*0., lu9*0., lu9*0., lu9*0./,
     ,      xmlma   ,   ewala   , ewbna  ,     trnspa    ,   fsheata /
     /    nlim*1206., nlim*0.087, nlim*0., nlim*0., nlim*0., nlim*-1. /,
     ,    rcycca ,   rcycfa ,  rcycta  , rcycsa , exppla ,  expela  /
     /    nlim*0.01, nlim*1., nlim*0.99, nlim*0., nlim*1., nlim*0.5 /,
     ,    expila , rcprma , sptpra , echspta, fchspta /
     /    nlim*1., nlim*0., nlim*0., nlim*0., nlim*0. /,
     ,      xlcor ,  ylcor ,  zlcor  /
     /    nlim*0., nlim*0., nlim*0. /,
     ,     xlref , ylref , zlref , xlrot , ylrot , zlrot , alrot /
     /    nlim*0.,nlim*0.,nlim*0.,nlim*0.,nlim*0.,nlim*0.,nlim*0./
      data txtsfa / nlim*' ' /

c*** 4

      data nreaci,nrcln,  ir   , massp , masst ,  iz    /
     /        0  ,  0  ,mreac*0,mreac*0,mreac*0,mreac*1 /
      data ifex1mn,ifex1mx,ifex2mn,ifex2mx /
     /     mreac*0,mreac*0,mreac*0,mreac*0 /
      data delpot,  rc1mn ,  rc1mx ,  rc2mn ,  rc2mx ,  fp1  ,  fp2   /
     /    mreac*0.,mreac*0.,mreac*0.,mreac*0.,mreac*0.,lur6*0.,lur6*0./
      data creac / lur9*0. /
      data lconst / mreac*.false. /
      data filnam ,    h123  ,   reac  ,   crc   , elname   /
     /    mreac*' ',mreac*' ',mreac*' ',mreac*' ',mreac*' ' /

      data rctndflt / .true. /, 
     ,  rctntyp , rctndbs , rctnchp , rctnrct , rctnptpr, rctnptin /
     / mreac*' ',mreac*' ',mreac*' ',mreac*' ',mreac*' ',mreac*' ' /,
     ,  rctnpto1, rctnpto2, rctnpto3 /
     / mreac*' ',mreac*' ',mreac*' ' /,
     ,  rctngrp , rctnmsp , rctnmst , rctnnmo1 /
     /  mreac*0 , mreac*0 , mreac*0 , mreac*0  /,
     ,  rctnnmo2, rctnnmo3 /
     /  mreac*0 , mreac*0  /,
     ,  rctndlte, rctntmin, rctntmax, rctnenr1, rctnenr2, rctneln  /
     /  mreac*0., mreac*0., mreac*0., mreac*0., mreac*0.,mreac*' ' /

      data spcdgen /
     ,  'H', 'D', 'T','He', 'C','Ne','Ar', 'N','Be','Xg','Xs' /
      data nspdpls /
     ,   1 ,  1 ,  1 ,  2 ,  6 , 10 , 18 ,  7 ,  4 , -1 , -1  /
      data nspdatm /
     ,   1 ,  1 ,  1 ,  1 ,  1 ,  1 ,  1 ,  3 ,  1 ,  1 ,  1  /
      data nspdmol /
     ,   1 ,  1 ,  1 ,  0 ,  0 ,  0 ,  0 ,  5 ,  0 ,  0 ,  0  /
      data nspdion /
     ,   2 ,  2 ,  2 ,  0 ,  0 ,  0 ,  0 ,  6 ,  0 ,  0 ,  0  /
      data lspdgen /
     ,   1 ,  6 , 11 , 16 , 19 , 26 , 37 , 56 , 77 , 82 , 83  /
      data spcdspc /
     ,  'H','H2','H2+','H3+','H+',
     ,  'D','D2','D2+','D3+','D+',
     ,  'T','T2','T2+','T3+','T+',
     ,  'He','He+','He++',
     ,  'C','C+','C++','C3+','C4+','C5+','C6+',
     ,  'Ne','Ne+','Ne++','Ne3+','Ne4+','Ne5+','Ne6+','Ne7+','Ne8+',
     ,  'Ne9+','Ne10+' ,
     ,  'Ar','Ar+','Ar++','Ar3+','Ar4+','Ar5+','Ar6+','Ar7+','Ar8+',
     ,  'Ar9+','Ar10+','Ar11+','Ar12+','Ar13+','Ar14+','Ar15+','Ar16+',
     ,  'Ar17+','Ar18+',
     ,  'N','N*(2P)','N*(2D)',
     ,  'N2','N2*(A)','NH','NH2','NH3',
     ,  'NH+','NH2+','NH3+','NH4+','N2+','N2H+',
     ,  'N+','N++','N3+','N4+','N5+','N6+','N7+',
     ,  'Be','Be+','Be++','Be3+','Be4+',
     ,  ' ', ' ' /
      data spcdrfl /
     , 'H',' ',' ',' ','H',
     , 'D',' ',' ',' ','D',
     , 'T',' ',' ',' ','T',
     ,  3*'He', 7*' ', 11*'Ne', 19*'Ar',
     ,  3*'N',11*' ',7*'N',
     ,  5*' ',
     ,  2*' ' /
      data spcdrtl /
     ,  'H2','H2','H2','H2','H2',
     ,  'D2','D2','D2','D2','D2',
     ,  'T2','T2','T2','T2','T2',
     ,  'He','He','He', 7*' ', 11*'Ne', 19*'Ar',
     ,   3*'N',2*'N2',' ',' ','NH3',
     ,   'N','NH','NH2','NH3','N2','N2',7*'N',
     ,   5*' ',
     ,   2*' ' /
      data spcdms /
     ,  1,2,2,3,1, 2,4,4,6,2, 3,6,6,9,3, 3*4, 7*12, 11*20, 19*40,
     ,  3*14,2*28,15,16,17,15,16,17,18,28,29,7*14, 5*9, 2*-1 /
      data spcdnc /
     ,  1,2,2,3,1, 1,2,2,3,1, 1,2,2,3,1, 3*2, 7*6, 11*10, 19*18,
     ,  3*7,2*14,8,9,10,8,9,10,11,14,15,7*7, 5*4, 2*-1 /
      data spcdcg /
     ,  0,0,1,1,1, 0,0,1,1,1, 0,0,1,1,1, 0,1,2, 0,1,2,3,4,5,6,
     ,  0,1,2,3,4,5,6,7,8,9,10, 
     ,  0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,
     ,  3*0,2*0,0,0,0,1,1,1,1,1,1,1,2,3,4,5,6,7, 0,1,2,3,4, 0,0 /
      data spcdfu / 1,2,2,3,1, 1,2,2,3,1, 1,2,2,3,1,
     ,  3*1, 7*1, 11*1, 19*1, 
     ,  3*1,2*2,2,3,4,2,3,4,5,2,3,7*1, 5*1, 1,1 /
      data spcdns / 1,2,2,3,1, 1,2,2,3,1, 1,2,2,3,1,
     ,  3*0, 7*0, 11*0, 19*0,
     ,  3*0,0,0,1,2,3,1,2,3,4,0,1,7*0, 5*0, 0,0 /
      data no_n2 /
     ,  3*.true.,.false.,.true.,
     ,  3*.true.,.false.,.true.,
     ,  3*.true.,.false.,.true.,
     ,  3*.true.,
     ,  7*.true.,
     , 11*.true.,
     , 19*.true.,
     ,    .true.,2*.false.,.true.,4*.false.,4*.false.,.true.,.false.,
     ,  7*.true.,
     ,  5*.true.,
     ,  2*.true. /
      data l_ammon /
     ,  3*.false.,.true.,.false.,
     ,  3*.false.,.true.,.false.,
     ,  3*.false.,.true.,.false.,
     ,  3*.false.,
     ,  7*.false.,
     , 11*.false.,
     , 19*.false.,
     ,    .false.,13*.true.,7*.false.,
     ,  5*.false.,
     ,  2*.false. /
      data l_meta /
     ,  3*.false.,.false.,.false.,
     ,  3*.false.,.false.,.false.,
     ,  3*.false.,.false.,.false.,
     ,  3*.false.,
     ,  7*.false.,
     , 11*.false.,
     , 19*.false.,
     ,    .false.,2*.true.,.false.,.true.,9*.false.,7*.false.,
     ,  5*.false.,
     ,  2*.false. /
      data is_meta / natm*.false. /

      data nspigen, (spcigen(i),i=1,3) / 3, 'D', 'He', 'C' /
      data nspipls, nspiatm, nspimol, nspiion /
     /        0   ,    0   ,    0   ,    0    /

      integer, parameter :: lucmm=natm*nmol, lucmi=natm*nion
      data spcscmm, spcscmi, spcinnm, spcinni /
     /     lucmm*0, lucmi*0,  nmol*0,  nion*0 /
     
      data spcrctd / 
     /      'H','H2','He', 'C','Ne','H+','Ar', 'N','Be','H2+',
     /     'N+','C+', 'X','X+' /
      integer, parameter ::
     ,  lurctdh=4, lurctdh2=7,lurctdhe=1,lurctdc=4, lurctdne=1,
     ,  lurctdhp=2,lurctdar=1,lurctdn=2, lurctdbe=2,lurctdh2p=4,
     ,  lurctdnp=2,lurctdcp=2,lurctdx=2, lurctdxp=2
      data  nnrctd / lurctdh, lurctdh2,lurctdhe,lurctdc, lurctdne,
     /               lurctdhp,lurctdar,lurctdn, lurctdbe,lurctdh2p,
     /               lurctdnp,lurctdcp,lurctdx, lurctdxp/
      data (rctdtyp(i,1),i=1,lurctdh)  / 2*'EI', 2*'CX' /
      data (rctdtyp(i,2),i=1,lurctdh2) / 'EI', 2*'DS', 3*'EL', 'CX' /
      data (rctdtyp(i,3),i=1,lurctdhe) / 'EI' /
      data (rctdtyp(i,4),i=1,lurctdc)  / 2*'EI', 2*'CX' /
      data (rctdtyp(i,5),i=1,lurctdne) / 'EI' /
      data (rctdtyp(i,6),i=1,lurctdhp) /  2*'RC' /
      data (rctdtyp(i,7),i=1,lurctdar) / 'EI' /
      data (rctdtyp(i,8),i=1,lurctdn)  / 2*'EI' /
      data (rctdtyp(i,9),i=1,lurctdbe) / 2*'EI' /
      data (rctdtyp(i,10),i=1,lurctdh2p) / 'DS','EI',2*'DS' /
      data (rctdtyp(i,11),i=1,lurctdnp) / 2*'RC' /
      data (rctdtyp(i,12),i=1,lurctdcp) / 2*'RC' /
      data (rctdtyp(i,13),i=1,lurctdx) / 2*'EI' /
      data (rctdtyp(i,14),i=1,lurctdxp) / 2*'RC' /
      data (rctddbs(i,1),i=1,lurctdh)  / 2*'AMJUEL', 2*'HYDHEL' /
      data (rctddbs(i,2),i=1,lurctdh2) / 7*'AMJUEL' /
      data (rctddbs(i,3),i=1,lurctdhe) / 'HYDHEL' /
      data (rctddbs(i,4),i=1,lurctdc)  / 2*'AMJUEL', 2*'METHAN' /
      data (rctddbs(i,5),i=1,lurctdne) / 'AMJUEL' /
      data (rctddbs(i,6),i=1,lurctdhp) / 2*'AMJUEL' /
      data (rctddbs(i,7),i=1,lurctdar) / 'AMJUEL' /
      data (rctddbs(i,8),i=1,lurctdn)  / 2*'AMJUEL' /
      data (rctddbs(i,9),i=1,lurctdbe) / 2*'AMJUEL' /
      data (rctddbs(i,10),i=1,lurctdh2p) / 4*'AMJUEL' /
      data (rctddbs(i,11),i=1,lurctdnp) / 2*'ADAS' /
      data (rctddbs(i,12),i=1,lurctdcp) / 2*'ADAS' /
      data (rctddbs(i,13),i=1,lurctdx) / 2*'ADAS' /
      data (rctddbs(i,14),i=1,lurctdxp) / 2*'ADAS' /
      data (rctdchp(i,1),i=1,lurctdh)  / 'H.4','H.10','H.1','H.3' /
      data (rctdchp(i,2),i=1,lurctdh2) 
     .                        / 3*'H.4', 'H.0', 'H.1', 'H.3', 'H.2' /
      data (rctdchp(i,3),i=1,lurctdhe) / 'H.2' /
      data (rctdchp(i,4),i=1,lurctdc)  / 'H.4','H.10','H.1','H.3' /
      data (rctdchp(i,5),i=1,lurctdne) / 'H.2' /
      data (rctdchp(i,6),i=1,lurctdhp) / 'H.4','H.10' /
      data (rctdchp(i,7),i=1,lurctdar) / 'H.2' /
      data (rctdchp(i,8),i=1,lurctdn)  / 'H.4','H.10' /
      data (rctdchp(i,9),i=1,lurctdbe) / 'H.2','H.8' /
      data (rctdchp(i,10),i=1,lurctdh2p)  / 3*'H.4', 'H.8' /
      data (rctdchp(i,11),i=1,lurctdnp)  / 'H.4','H.10' /
      data (rctdchp(i,12),i=1,lurctdcp)  / 'H.4','H.10' /
      data (rctdchp(i,13),i=1,lurctdx) / 'H.4','H.10' /
      data (rctdchp(i,14),i=1,lurctdxp) / 'H.4','H.10' /
      data (rctdrct(i,1),i=1,lurctdh)  / 2*'2.1.5', 2*'3.1.8' /
      data (rctdrct(i,2),i=1,lurctdh2) 
     .              / '2.2.9', '2.2.5g', '2.2.10', 3*'0.3T', '3.2.3' /
      data (rctdrct(i,3),i=1,lurctdhe) / '2.3.9' /
      data (rctdrct(i,4),i=1,lurctdc)  / 2*'2.6A0', 2*'3.2' /
      data (rctdrct(i,5),i=1,lurctdne) / '2.10B0' /
      data (rctdrct(i,6),i=1,lurctdhp) / 2*'2.1.8' /
      data (rctdrct(i,7),i=1,lurctdar) / '2.18B0' /
      data (rctdrct(i,8),i=1,lurctdn)  / 2*'2.7A0' /
      data (rctdrct(i,9),i=1,lurctdbe) / 2*'2.4B0' /
      data (rctdrct(i,10),i=1,lurctdh2p) 
     .                        / '2.2.12','2.2.11',2*'2.2.14' /
      data (rctdrct(i,11),i=1,lurctdnp) / 'acd', 'prb' /
      data (rctdrct(i,12),i=1,lurctdcp) / 'acd', 'prb' /
      data (rctdrct(i,13),i=1,lurctdx) / 'scd', 'plt' /
      data (rctdrct(i,14),i=1,lurctdxp) / 'acd', 'prb' /
      data (rctdptin(i,1),i=1,lurctdh)  / 2*' ', 2*'H+' /
      data (rctdptin(i,2),i=1,lurctdh2) / 3*' ', 4*'H+' /
      data (rctdptin(i,3),i=1,lurctdhe) / ' ' /
      data (rctdptin(i,4),i=1,lurctdc)  / 2*' ', 2*'H+' /
      data (rctdptin(i,5),i=1,lurctdne) / ' ' /
      data (rctdptin(i,6),i=1,lurctdhp) / 2*' ' /
      data (rctdptin(i,7),i=1,lurctdar) / ' ' /
      data (rctdptin(i,8),i=1,lurctdn)  / 2*' ' /
      data (rctdptin(i,9),i=1,lurctdbe) / 2*' ' /
      data (rctdptin(i,10),i=1,lurctdh2p) / 4*' ' /
      data (rctdptin(i,11),i=1,lurctdnp) / 2*' ' /
      data (rctdptin(i,12),i=1,lurctdcp) / 2*' ' /
      data (rctdptin(i,13),i=1,lurctdx) / 2*' ' /
      data (rctdptin(i,14),i=1,lurctdxp) / 2*' ' /
      data (rctdpto1(i,1),i=1,lurctdh)  / 2*'H+',2*'H' /
      data (rctdpto1(i,2),i=1,lurctdh2) 
     .                           / 'H2+', '2H', 'H', 3*'H+', 'H' /
      data (rctdpto1(i,3),i=1,lurctdhe) / 'He+' /
      data (rctdpto1(i,4),i=1,lurctdc)  / 2*'C+',2*'H' /
      data (rctdpto1(i,5),i=1,lurctdne) / 'Ne+' /
      data (rctdpto1(i,6),i=1,lurctdhp) / 2*'H' /
      data (rctdpto1(i,7),i=1,lurctdar) / 'Ar+' /
      data (rctdpto1(i,8),i=1,lurctdn)  / 2*'N+' /
      data (rctdpto1(i,9),i=1,lurctdbe) / 2*'Be+' /
      data (rctdpto1(i,10),i=1,lurctdh2p) / 'H', '2H+', '2H', '2H' /
      data (rctdpto1(i,11),i=1,lurctdnp) / 2*'N' /
      data (rctdpto1(i,12),i=1,lurctdcp) / 2*'C' /
      data (rctdpto1(i,13),i=1,lurctdx) / 2*'X+' /
      data (rctdpto1(i,14),i=1,lurctdxp) / 2*'X' /
      data (rctdpto2(i,1),i=1,lurctdh)  / 2*' ', 2*'H+' /
      data (rctdpto2(i,2),i=1,lurctdh2) / 2*' ', 'H+', 3*'H2', 'H2+' /
      data (rctdpto2(i,3),i=1,lurctdhe) / ' ' /
      data (rctdpto2(i,4),i=1,lurctdc)  / 2*' ', 2*'C+' /
      data (rctdpto2(i,5),i=1,lurctdne) / ' ' /
      data (rctdpto2(i,6),i=1,lurctdhp) / 2*' ' /
      data (rctdpto2(i,7),i=1,lurctdar) / ' ' /
      data (rctdpto2(i,8),i=1,lurctdn)  / 2*' ' /
      data (rctdpto2(i,9),i=1,lurctdbe) / 2*' ' /
      data (rctdpto2(i,10),i=1,lurctdh2p) / 'H+', 3*' ' /
      data (rctdpto2(i,11),i=1,lurctdnp) / 2*' ' /
      data (rctdpto2(i,12),i=1,lurctdcp) / 2*' ' /
      data (rctdpto2(i,13),i=1,lurctdx) / 2*' ' /
      data (rctdpto2(i,14),i=1,lurctdxp) / 2*' ' /
      data (rctdpto3(i,1),i=1,lurctdh) / lurctdh*' ' /
      data (rctdpto3(i,2),i=1,lurctdh2) / lurctdh2*' ' /
      data (rctdpto3(i,3),i=1,lurctdhe) / lurctdhe*' ' /
      data (rctdpto3(i,4),i=1,lurctdc) / lurctdc*' ' /
      data (rctdpto3(i,5),i=1,lurctdne) / lurctdne*' ' /
      data (rctdpto3(i,6),i=1,lurctdhp) / lurctdhp*' ' /
      data (rctdpto3(i,7),i=1,lurctdar) / lurctdar*' ' /
      data (rctdpto3(i,8),i=1,lurctdn) / lurctdn*' ' /
      data (rctdpto3(i,9),i=1,lurctdbe) / lurctdbe*' ' /
      data (rctdpto3(i,10),i=1,lurctdh2p) / lurctdh2p*' ' /
      data (rctdpto3(i,11),i=1,lurctdnp) / lurctdnp*' ' /
      data (rctdpto3(i,12),i=1,lurctdcp) / lurctdcp*' ' /
      data (rctdpto3(i,13),i=1,lurctdx) / lurctdx*' ' /
      data (rctdpto3(i,14),i=1,lurctdxp) / lurctdxp*' ' /
      data (rctdgrp(i,1),i=1,lurctdh)  / 2*-1, 2*-2 /
      data (rctdgrp(i,2),i=1,lurctdh2) / 3*0, 3*-5, 0 /
      data (rctdgrp(i,3),i=1,lurctdhe) / 0 /
      data (rctdgrp(i,4),i=1,lurctdc)  / 2*-10, 2*-11 /
      data (rctdgrp(i,5),i=1,lurctdne) / 0 /
      data (rctdgrp(i,6),i=1,lurctdhp) / 2*-3 /
      data (rctdgrp(i,7),i=1,lurctdar) / 0 /
      data (rctdgrp(i,8),i=1,lurctdn)  / 2*-12 /
      data (rctdgrp(i,9),i=1,lurctdbe) / 2*-7 /
      data (rctdgrp(i,10),i=1,lurctdh2p) / 2*0, 2*-4 /
      data (rctdgrp(i,11),i=1,lurctdnp) / 2*-14 /
      data (rctdgrp(i,12),i=1,lurctdcp) / 2*-13 /
      data (rctdgrp(i,13),i=1,lurctdx) / 2*-15 /
      data (rctdgrp(i,14),i=1,lurctdxp) / 2*-16 /
      data (rctdmsp(i,1),i=1,lurctdh)  / 2*0, 2*1 /
      data (rctdmsp(i,2),i=1,lurctdh2) / 3*0, 4*1 /
      data (rctdmsp(i,3),i=1,lurctdhe) / 0 /
      data (rctdmsp(i,4),i=1,lurctdc)  / 2*0, 2*1 /
      data (rctdmsp(i,5),i=1,lurctdne) / 0 /
      data (rctdmsp(i,6),i=1,lurctdhp) / 2*0 /
      data (rctdmsp(i,7),i=1,lurctdar) / 0 /
      data (rctdmsp(i,8),i=1,lurctdn)  / 2*0 /
      data (rctdmsp(i,9),i=1,lurctdbe) / 2*0 /
      data (rctdmsp(i,10),i=1,lurctdh2p) / 4*0 /
      data (rctdmsp(i,11),i=1,lurctdnp) / 2*0 /
      data (rctdmsp(i,12),i=1,lurctdcp) / 2*0 /
      data (rctdmsp(i,13),i=1,lurctdx) / 2*0 /
      data (rctdmsp(i,14),i=1,lurctdxp) / 2*0 /
      data (rctdmst(i,1),i=1,lurctdh)  / lurctdh*1 /
      data (rctdmst(i,2),i=1,lurctdh2) / lurctdh2*2 /
      data (rctdmst(i,3),i=1,lurctdhe) / lurctdhe*4 /
      data (rctdmst(i,4),i=1,lurctdc)  / lurctdc*12 /
      data (rctdmst(i,5),i=1,lurctdne) / lurctdne*20 /
      data (rctdmst(i,6),i=1,lurctdhp) / lurctdhp*1 /
      data (rctdmst(i,7),i=1,lurctdar) / lurctdar*40 /
      data (rctdmst(i,8),i=1,lurctdn)  / lurctdn*14 /
      data (rctdmst(i,9),i=1,lurctdbe) / lurctdbe*9 /
      data (rctdmst(i,10),i=1,lurctdh2p) / lurctdh2p*2 /
      data (rctdmst(i,11),i=1,lurctdnp) / lurctdnp*14 /
      data (rctdmst(i,12),i=1,lurctdcp) / lurctdcp*12 /
      data (rctdmst(i,13),i=1,lurctdx) / lurctdx*-1 /
      data (rctdmst(i,14),i=1,lurctdxp) / lurctdxp*-1 /
      data (rctddlte(i,1),i=1,lurctdh)  / 4*0.0 /
      data (rctddlte(i,2),i=1,lurctdh2) / 15.4, 10.5, 25.0, 4*0.0 /
      data (rctddlte(i,3),i=1,lurctdhe) / 24.55 /
      data (rctddlte(i,4),i=1,lurctdc)  / 4*0.0 /
      data (rctddlte(i,5),i=1,lurctdne) / 21.6 /
      data (rctddlte(i,6),i=1,lurctdhp) / 0.0, 13.6 /
      data (rctddlte(i,7),i=1,lurctdar) / 15.8 /
      data (rctddlte(i,8),i=1,lurctdn)  / 2*0.0 /
      data (rctddlte(i,9),i=1,lurctdbe) / 2*0.0 /
      data (rctddlte(i,10),i=1,lurctdh2p) / 10.4, 15.5, 0.0, 0.0 /
      data (rctddlte(i,11),i=1,lurctdnp) / 0.0, 14.5341 /
      data (rctddlte(i,12),i=1,lurctdcp) / 0.0, 11.2603 /
      data (rctddlte(i,13),i=1,lurctdx) / 2*0.0 /
      data (rctddlte(i,14),i=1,lurctdxp) / 0.0, -1.0 /
      data (rctdenr1(i,1),i=1,mreac)    / mreac*0 /
      data (rctdenr1(i,2),i=1,lurctdh2) / 1.0, 3.0, 5.0, 4*0 /
      data (rctdenr1(i,3),i=1,mreac)    / mreac*0 /
      data (rctdenr1(i,4),i=1,mreac)    / mreac*0 /
      data (rctdenr1(i,5),i=1,mreac)    / mreac*0 /
      data (rctdenr1(i,6),i=1,mreac)    / mreac*0 /
      data (rctdenr1(i,7),i=1,mreac)    / mreac*0 /
      data (rctdenr1(i,8),i=1,mreac)    / mreac*0 /
      data (rctdenr1(i,9),i=1,mreac)    / mreac*0 /
      data (rctdenr1(i,10),i=1,lurctdh2p) / 4.3, 0.25, 0.5, 0.0 /
      data (rctdenr1(i,11),i=1,mreac)   / mreac*0 /
      data (rctdenr1(i,12),i=1,mreac)   / mreac*0 /
      data (rctdenr1(i,13),i=1,mreac)   / mreac*0 /
      data (rctdenr1(i,14),i=1,mreac)   / mreac*0 /
      data (rctdenr2(i,1),i=1,mreac)    / mreac*0 /
      data (rctdenr2(i,2),i=1,lurctdh2) / 0.0, 3.0, 5.0, 4*0 /
      data (rctdenr2(i,3),i=1,mreac)    / mreac*0 /
      data (rctdenr2(i,4),i=1,mreac)    / mreac*0 /
      data (rctdenr2(i,5),i=1,mreac)    / mreac*0 /
      data (rctdenr2(i,6),i=1,mreac)    / mreac*0 /
      data (rctdenr2(i,7),i=1,mreac)    / mreac*0 /
      data (rctdenr2(i,8),i=1,mreac)    / mreac*0 /
      data (rctdenr2(i,9),i=1,mreac)    / mreac*0 /
      data (rctdenr2(i,10),i=1,lurctdh2p) / 4.3, 0.25, 0.5, 0.0 /
      data (rctdenr2(i,11),i=1,mreac)   / mreac*0 /
      data (rctdenr2(i,12),i=1,mreac)   / mreac*0 /
      data (rctdenr2(i,13),i=1,mreac)   / mreac*0 /
      data (rctdenr2(i,14),i=1,mreac)   / mreac*0 /
      data (rctdeln(i,1),i=1,lurctdh)   / lurctdh*'H' /
      data (rctdeln(i,2),i=1,lurctdh2)  / lurctdh2*'H' /
      data (rctdeln(i,3),i=1,lurctdhe)  / lurctdhe*'He' /
      data (rctdeln(i,4),i=1,lurctdc)   / lurctdc*'C' /
      data (rctdeln(i,5),i=1,lurctdne)  / lurctdne*'Ne' /
      data (rctdeln(i,6),i=1,lurctdhp)  / lurctdhp*'H' /
      data (rctdeln(i,7),i=1,lurctdar)  / lurctdar*'Ar' /
      data (rctdeln(i,8),i=1,lurctdn)   / lurctdn*'N' /
      data (rctdeln(i,9),i=1,lurctdbe)  / lurctdbe*'Be' /
      data (rctdeln(i,10),i=1,lurctdh2p) / lurctdh2p*'H' /
      data (rctdeln(i,11),i=1,lurctdnp) / lurctdnp*'N' /
      data (rctdeln(i,12),i=1,lurctdcp) / lurctdcp*'C' /
      data (rctdeln(i,13),i=1,lurctdx)  / lurctdx*'X' /
      data (rctdeln(i,14),i=1,lurctdxp) / lurctdxp*'X' /
      data rctdtmin, rctdtmax  / lvrctd*0.0, lvrctd*0.0 /
c
c*** hlp_h shows the species equivalent to the default ones
      data hlp_h /
     /  'H', 'H+', 'H2', 'H2+', '2H', '2H+', 'H3+', '3H', 'NH', 'NH2',
     ,  'NH3', 'NH+', 'NH2+', 'NH3+', 'NH4+', 'N2H+',
     ,  'D', 'D+', 'D2', 'D2+', '2D', '2D+', 'D3+', '3D', 'ND', 'ND2',
     ,  'ND3', 'ND+', 'ND2+', 'ND3+', 'ND4+', 'N2D+',
     ,  'T', 'T+', 'T2', 'T2+', '2T', '2T+', 'T3+', '3T', 'NT', 'NT2',
     ,  'NT3', 'NT+', 'NT2+', 'NT3+', 'NT4+', 'N2T+',
     ,  'H', 'H+', 'H2', 'H2+', '2H', '2H+', 'H3+', '3H', 'NH', 'NH2',
     ,  'NH3', 'NH+', 'NH2+', 'NH3+', 'NH4+', 'N2H+',
     ,  'H', 'H+', 'H2', 'H2+', '2H', '2H+', 'H3+', '3H', 'NH', 'NH2',
     ,  'NH3', 'NH+', 'NH2+', 'NH3+', 'NH4+', 'N2H+',
     ,  'H', 'H+', 'H2', 'H2+', '2H', '2H+', 'H3+', '3H', 'NH', 'NH2',
     ,  'NH3', 'NH+', 'NH2+', 'NH3+', 'NH4+', 'N2H+'/
      data hlp_h_m / 1, 1, 2, 2, 1, 1, 3, 1, 1, 2, 3, 1, 2, 3, 4, 1/
      
c      integer lura,lurm,luri,lurf
      integer, parameter :: lura=nreac*natm, lurm=nreac*nmol,
     ,   luri=nreac*nion,lurf=nreac*npht
      data natmi,nmoli,nioni,nphti,nmeta / 5*0 /
      data nmassa,nchara, isrfa, isrta,nmseca, nrca , nfola /
     /     natm*0,natm*0,natm*0,natm*0,natm*0,natm*0,natm*0 /,
     ,  ngena,nhsta /
     / natm*0,natm*0/,
     ,  ireaca,ibulka,iscd1a,iscd2a,iscd3a,iscd4a,iscdea,iestma,ibgka /
     /  lura*0,lura*0,lura*0,lura*0,lura*0,lura*0,lura*0,lura*0,lura*0/
      data eeleca, ebulka, escd1a, escd2a, freaca, edpota /
     /    lura*0.,lura*0.,lura*0.,lura*0.,lura*0.,lura*0. /
      data nmassm,ncharm, nprtm, isrfm, isrtm,nmsecm, nrcm , nfolm /
     /     nmol*0,nmol*0,nmol*0,nmol*0,nmol*0,nmol*0,nmol*0,nmol*0 /,
     ,  ngenm,nhstm,lkindm /
     / nmol*0,nmol*0,nmol*0 /,
     , ireacm,ibulkm,iscd1m,iscd2m,iscd3m,iscd4m,iscdem,iestmm,ibgkm /
     / lurm*0,lurm*0,lurm*0,lurm*0,lurm*0,lurm*0,lurm*0,lurm*0,lurm*0/
      data eelecm, ebulkm, escd1m, escd2m, freacm /
     /    lurm*0.,lurm*0.,lurm*0.,lurm*0.,lurm*0. /
      data nmassi,nchari, nprti, isrfi, isrti,nmseci, nrci , nfoli /
     /     nion*0,nion*0,nion*0,nion*0,nion*1,nion*0,nion*0,nion*0 /,
     ,  nchrgi,ngeni, nhsti,lkindi /
     /  nion*0,nion*0,nion*0,nion*0 /,
     ,  ireaci,ibulki,iscd1i,iscd2i,iscd3i,iscd4i,iscdei,iestmi,ibgki /
     /  luri*0,luri*0,luri*0,luri*0,luri*0,luri*0,luri*0,luri*0,luri*0/
      data eeleci, ebulki, escd1i, escd2i, freaci /
     /    luri*0.,luri*0.,luri*0.,luri*0.,luri*0. /
      data  isrff, isrtf,nmsecf, nrcf , nfolf, ngenf, nhstf  /
     /     npht*0,npht*1,npht*0,npht*0,npht*0,npht*0,npht*0 /,
     ,  ireacf,ibulkf,iscd1f,iscd2f,iscd3f,iscd4f,iscdef,iestmf,ibgkf /
     /  lurf*0,lurf*0,lurf*0,lurf*0,lurf*0,lurf*0,lurf*0,lurf*0,lurf*0/
      data eelecf, ebulkf, escd1f, escd2f, freacf /
     /    lurf*0.,lurf*0.,lurf*0.,lurf*0.,lurf*0. /
      data  texta  , textm  , texti  , textf   /
     /     natm*' ',nmol*' ',nion*' ',npht*' ' /

c*** 5

      integer lurp,lurc,lup5,lup6
      parameter (lurp=nreac*npls, lurc=nrcdn*npls)
      parameter (lup5=5*npls, lup6=6*npls)
      data nplsi / 0 /
      data nbgk / 0 /
      data nmassp,ncharp, nprtp,nchrgp, isrfp, isrtp,nmsecp, nrcp  /
     /     npls*0,npls*0,npls*0,npls*0,npls*0,npls*0,npls*0,npls*0 /,
     , idnslmp, nfolp, ngenp,nhstp /
     /  npls*0,npls*0,npls*0,npls*0 /,
     ,  ireacp,ibulkp,iscd1p,iscd2p,iscd3p,iscd4p,iscdep /
     /  lurp*0,lurp*0,lurp*0,lurp*0,lurp*0,lurp*0,lurp*0 /
      data eelecp, ebulkp, escd1p, escd2p, freacp /
     /    lurp*0.,lurp*0.,lurp*0.,lurp*0.,lurp*0. /
      data textp / npls*' ' /
      data cdnmdlp_sel/
     /   'FORT.13', 'FORT.10', 'FTN13', 'FTN10',
     /   'CONSTANT','MULTIPLY','SAHA','BOLTZMANN','CORONA','COLRAD'/
      data cdnmdlp / npls*' ' /
      data nrep, ispcdn, itpcdn, istrcdn /
     /   npls*0, lurc*0, lurc*4, lurc*0 /
      data valcdn,bltzcdn,dltecdn,acrncdn/
     /    lup5*0.,npls*0.,npls*0.,npls*0./
      data fnamcdn, h2cdn  , reaccdn, crcdn   /
     /    lurc*' ',lurc*' ',lurc*' ',lurc*' ' /
      
      data indpro / 6*6, 6*0  /
      data te0,te1,te2,te3,te4,te5 / 6*0./
      data ti0,ti1,ti2,ti3,ti4,ti5 / lup6*0./
      data di0,di1,di2,di3,di4,di5 / lup6*0./
      data vx0,vx1,vx2,vx3,vx4,vx5 / lup6*0./
      data vy0,vy1,vy2,vy3,vy4,vy5 / lup6*0./
      data vz0,vz1,vz2,vz3,vz4,vz5 / lup6*0./
      data b0,b1,b2,b3,b4,b5       / 6*0./
      data vl0,vl1,vl2,vl3,vl4,vl5 / 6*0./

c*** 6

      integer luchsi,luchsr,lvchsi,lvchsr
      parameter (luchsi=5, luchsr=3)
      parameter (lvchsi=luchsi*nchsppr, lvchsr=luchsr*nchsppr)
      data nltrim / .true. /
      data path,(filtrm(i),i=1,luftrm)     /
     /      ' ',         'D_on_C'          /
      data nnftrm / luftrm /, nchsppri / 0 /
      data lchspgrp, lchsptgt, lchspnwl, lchspaux /
     /    nchsppr*0,nchsppr*1,nchsppr*0, lvchsi*0 /
      data datm    ,  dmol   ,  dion   ,  dpls  ,   ermin  ,  ercut   /
     /     natm*0. , nmol*0. , nion*0. , npls*0.,    1.    ,   50.    /,
     ,      rprob0 , rinteg  , einteg  , ainteg , achsptg  /
     /        0.1  ,   0.    ,   0.    ,   0.   , lvchsr*0./
      data scard_name /maxsc*' ' /
      data scilref,scilspt, scisrs, scisrc,sclchspnwl /
     /     maxsc*1,maxsc*0,maxsc*3,maxsc*3, maxsc*1   /
      data scxmlim, scewall, scewbin,    sctransp     ,scfsheat /
     /    maxsc*0.,maxsc*0.,maxsc*0.,maxsc*0.,maxsc*0.,maxsc*-1. /,
     ,    screcycf,screcyct, scrcprm, scexppl, scexpel ,scexpil /
     /    maxsc*1.,maxsc*1.,maxsc*1.,maxsc*1.,maxsc*0.5,maxsc*1. /,
     ,    screcycs,scychsptg,scechsptg,scfchsptg,scstprm  /
     /    maxsc*0., maxsc*0., maxsc*0., maxsc*0.,maxsc*0. /
      data nnchemvar,indchemvar, chvarname , chmspname , chmvar    /
     /      maxsc*0 , maxchsc*0,maxchsc*' ',maxchsc*' ',maxchsc*0. /

c*** 7

      data srcvdflt,tgpfstd /
     /      .true. ,  0.03  /
      data ngpfstr,jgpfstr,pgpfstr , fgpfstr,tgpfstr ,cgpfstrs  /
     /        0   ,nstra*1,nstra*1.,nstra*1.,nstra*0.,nstra*'-' /
      data lrcmrb , lrcmre , lrcmpb , lrcmpe , nrcmstrs /
     /     nstra*0, nstra*0, nstra*0, nstra*0,nstra*7000/,
     ,    crcmstrs, nrcmstr, ircmstrs  /
     /   nstra*' ',    0   ,nstra*4001 /

      data  nstrai,alloc,indsrc ,  npts  , ninitl, nemods , namods  /
     /         0  , 0.5 ,nstra*6,nstra*-1,nstra*-1, nstra*6, nstra*1 /,
     , nminpts, ivlsf , iscls , isclt , iscl1 , iscl2 , iscl3 , isclb /
     / nstra*0,nstra*0,nstra*0,nstra*0,nstra*0,nstra*0,nstra*0,nstra*0/
      data iscla , nspez  , nsrfsi,  indim ,  insor ,  nrsor  , npsor  /
     /    nstra*0,nstra*-1,nstra*1,lustsr*1,lustsr*1,lustsr*-1,lustsr*0/
      data ntsor ,  nbsor ,  nasor ,  nisor , istor,  ingrda , ingrde /
     /   lustsr*0,lustsr*0,lustsr*0,lustsr*0,lustsr*0,lusts3*0,lusts3*0/
      data  flux   , scalv  , sorwgt  ,  sorlim   , sorind  , sorexp  /
     /     nstra*1.,nstra*0.,lustsr*1.,lustsr*140.,lustsr*0.,lustsr*0./,
     ,    sorifl   , sorad1  ,  sorad2   , sorad3  , sorad4  /
     / lustsr*1111.,lustsr*0., lustsr*0. ,lustsr*0.,lustsr*0./,
     ,     sorad5  , sorad6  ,  soreni   , sorene  , sorvdx  ,sorvdy  /
     /    lustsr*0.,lustsr*0.,  nstra*0. , nstra*0., nstra*0.,nstra*0./,
     ,     sorvdz  , sorcos  , sormax   , sorctx  , sorcty  , sorctz /
     ,     nstra*0., nstra*1., nstra*90. , nstra*0., nstra*0.,nstra*0./

      data   nlavrp    ,    nlavrt    ,      nlsymp  ,    nlsymt     /
     /    nstra*.false., nstra*.false., nstra*.false., nstra*.false. /,
     ,         nlatm    ,    nlmol     ,    nlion     ,    nlpls     /
     /     nstra*.false., nstra*.false., nstra*.false., nstra*.true. /,
     ,        nlpnt     ,    nllne     ,    nlsrf     ,    nlvol     /
     /     nstra*.false., nstra*.false., nstra*.true. , nstra*.false./,
     ,        nlcns     ,    nlray     ,    nlphot    /
     /     nstra*.false., nstra*.false., nstra*.false./
      data  txtsou / nstra*' ' /
      
c*** 8

      data nzadd,  ini  ,  ine   /
     /       0  , nrad*0, nrad*0 /

c*** 9

      data nprcsf, iprcsf ,maxlev,maxrad,maxpol,maxtor,maxadd /
     /       0   ,nlimps*0,   0  ,   0  ,   0  ,   0  ,   0   /,
     ,     nssplr,nssplp,nssplt,nsspla, nsigvi, nsigsi, nsigci /
     /     n1st*0,n2nd*0,n3rd*0,nlim*0,    0  ,    0  ,   0    /,
     ,     nsigi_bgk,nsigi_cop, llpbls /
     /         0    ,    0    ,.false. /,
     ,       igh ,  iih  ,  ighw ,  iihw ,    ighc     ,    iihc     /
     /      nsd*1, nsd*1 , nsdw*1, nsdw*1, ncv*1,ncv*1 , ncv*1,ncv*1 /
      data prmrspl,prmpspl,prmtspl,prmaspl,wminv,wmins,wminc,splpar  /
     /     n1st*0.,n2nd*0.,n3rd*0.,nlim*0.,1.e+3,1.e-2, 0.  ,  2.    /
      data    nlprca   ,    nlprcm   ,    nlprci   ,    nlpbls       /
     /     natm*.false., nmol*.false., nion*.false.,luatsr*.false.   /
      data    nlprcph   /
     /     npht*.false./

c*** 10

      data nadvi, nclvi, nalvi, nadsi, nalsi, nadspc /
     /       0  ,   0  ,   0  ,   0  ,   0  ,   0    /
c*** 10a
      data iadve , iadvs , iadvt , iadrc , txttla , txtspa , txtuna  /
     /     nadv*0, nadv*0, nadv*0, nadv*0,nadv*' ',nadv*' ',nadv*' ' /
c*** 10b
      data iclve,  iclvs,  iclvt,  iclrc /
     /    nclv*1, nclv*1, nclv*0, nclv*0 /
c*** 10c
      data  txttlc , txtspc , txtunc  /
     ,     nclv*' ',nclv*' ',nclv*' ' /
      data  chrtal , txttlr , txtspr , txtunr  /
     ,     nalv*' ',nalv*' ',nalv*' ',nalv*' ' /
c*** 10d
      data iadse,  iadss,  iadst,  iadsc /
     /    nads*1, nads*1, nads*0, nads*0 /
      data  txttld , txtspd , txtund  /
     ,     nads*' ',nads*' ',nads*' ' /
c*** 10e
      data   chrtls ,  txtsps ,  txttls ,  txtuns  /
     /      nals*' ', nals*' ', nals*' ', nals*' ' /
c*** 10f
      data  ispsrf, iptyp , ipspz , isptyp,  nsps , isrfcl, idirec /
     /      nasp*0, nasp*0, nasp*0, nasp*0, nasp*0, nasp*0, nasp*0 /
      data  spcmn , spcmx , spcsh , spcpx , spcpy , spcps /
     /     nasp*0.,nasp*0.,nasp*0.,nasp*0.,nasp*0.,nasp*0./
      data  spcvx , spcvy , spcvz /
     /     nasp*0.,nasp*0.,nasp*0./

c*** 11

      data nvolpr,  ntlv  , nflgv , nspzv1, nspzv2, ntlvf ,nsurpr/
     /       0   , ntalv*0,ntalv*0,ntalv*0,ntalv*0,ntalv*0,  0    /,
     ,     nsrf  ,  ntls  , nflgs  , nspzs1 , nspzs2 , nsptal,nplinr /
     /   nlimps*0,nlimps*0,nlimps*0,nlimps*0,nlimps*0,nptal*0,   1   /,
     ,   nplotr,npldlr,nplinp, nplotp,npldlp,nplint, nplott, npldlt/
     /     0   ,   1  ,  1   ,   0   ,  1   ,  0   ,   0   ,   0   /,
     ,    iplta, iplaa, iplea, iplts, iplas, iples, i1trc, i2trc /
     /     5*0 ,  20*0,  20*0,  3*0 ,  12*0,  12*0,   0  ,   0   /,
     ,   isyplt, ilinie, nvolpl, nptal2 , nptal3 ,  nsp  /
     /    8*0  ,   2   ,   0   ,lunplt*0,lunplt*0,nptal*1/,
     ,  ispzt2 , ispzt3 , nplin2 ,  nplot2 ,  npldl2 /
     / lunplt*1,lunplt*1,lunplt*1,lunplt*24, lunplt*1 /
     ,  iproj3 , npli13 ,  nplo13 , npli23 , nplo23 ,  ipln   /
     / lunplt*1,lunplt*1, lunplt*1,lunplt*0,lunplt*0,lunplt*0 /
      data ch2mx, ch2my, ch2x0, ch2y0, ch2z0, ch3mx, ch3my, ch3mz /
     /       0. ,   0. ,   0. ,   0. ,   0. ,  10.,   10. ,   0.  /,
     ,     ch3x0, ch3y0, ch3z0, angle1, angle2, angle3,cutplane /
     /       0. ,  10. ,  10. ,   10. ,   10. ,    0. ,   4*0.  /,
     ,   talzmi , talzma , talxmi , talxma , talymi , talyma /
     /  nptal*0.,nptal*0.,nptal*0.,nptal*0.,nptal*0.,nptal*0./,
     ,   talw1  , talw2   , fcabs1 , fcabs2 , rpsdl   /
     / nptal*45.,nptal*45.,nptal*0.,nptal*0.,nptal*0. /
      data trcplt,  trchst, trcnal, trcmod, trcsig, trcgrd, trcsur /
     /    .false., .false.,.false.,.false.,.false.,.false.,.false. /,
     ,     trcref, trcfle, trcamd, trcint, trctim, trcsou, trcrec /
     /    .false.,.false.,.false.,.false.,.false.,.false.,.false. /,
     ,     trclst, trcbla, trcblm, trcbli, trcblp, trcble,trcblph /
     /    .false.,.false.,.false.,.false.,.false.,.false.,.false. /,
     ,     trctal, trcoct, trccen, trcrnf/
     /    .false.,.false.,.false.,.false./,
     ,     trcdbg2,trcdbge,trcdbgm,trcdbgf,trcdbgl /
     /    .false.,.false.,.false.,.false.,.false. /,
     ,     trcdbgs,trcdbgg,trcdbgmpi,trcdbgc,     trcsrc           /
     /    .false. ,.false.,.false.  ,.false.,.true.,nstra*.false. /,
     ,     pl1st , pl2nd , pl3rd , pladd , plhst /
     ,    .false.,.false.,.false.,.false.,.false./,
     ,             plcut         , plbox , plstor, plnumv, plnums /
     /    .false.,.false.,.false.,.false.,.false.,.false.,.false. /,
     ,   plarr ,lrpscut,       pltsrc          ,   pl3a   ,  pl3s    /
     /  .false.,.false., .false.,nstra*.false. , 5*.false.,3*.false. /,
     ,     pltl2d    ,   pltl3d   , pltllg      , plidl  , plvtk /
     ,  nptal*.false.,nptal*.true.,nptal*.false., .false.,.false./,
     ,     pltler    ,    lhist2    ,    lhist3   ,    lcntr3    /
     /  nptal*.false., nptal*.false., nptal*.true., nptal*.false./,
     ,      lsmot3   ,     lraps   ,   lvect3    ,   lrpvc3    /
     /  nptal*.false.,nptal*.false.,nptal*.false.,nptal*.false./,
     ,     lrps3d    ,   lrpscn    ,   lprad     ,   lppol     /
     /  nptal*.false.,nptal*.false.,nptal*.false.,nptal*.false./,
     ,       lptor     ,    lsmot2   /
     /   nptal*.false., nptal*.false./
      data textla / 5*' ' /, textls / 3*' ' /

c*** 12

      data nchori, ncheni,lntspec,lntsput,nmcsput,npspcen,iatspec /
     /       0   ,   0   ,   0   ,   0   ,   0   ,  29   ,   1    /,
     ,  npspctt,npspcfi,nlstadds,mtreadds,ngwties,ngwtiesi /
     /     8   ,   4   ,   0    ,   0    ,   0   ,    0    /,
     ,   nchtal, nspscl, nspnew, nspstr, nspspz, nspini, nspend /
     /  nchor*0,nchor*0,nchor*0,nchor*0,nchor*0,nchor*0,nchor*0 /,
     ,   nspblc, nspadd, masloc, ipivot, ichord, listmtmp , listmtra  /
     /  nchor*0,nchor*0,nchor*0,nchor*0,nchor*0,lntsputx*0,lntsputx*0 /,
     ,  listadds,listaddg, kgwties  , mgwties  ,lgwties ,npwin /
     /  nlimps*0,nlimps*0,ngwtiesx*0,ngwtiesx*0,lugwts*0,  0   /,
     ,  npwsurf,npwtally,pwsurf,pwtally,pwspecy,pwtally_d,pwspecy_d /
     / npwinx*0,npwinx*0,lupw*0, lupw*0, lupw*0,  lupw*0 ,  lupw*0  /
      data emin1  , emax1  , xpivot , ypivot ,emnspc,emxspc /
     /    nchor*0.,nchor*0.,nchor*0.,nchor*0.,  0.5 , 5000. /,
     ,     zpivot , xchord , ychord , zchord  /
     /    nchor*0.,nchor*0.,nchor*0.,nchor*0. /
      data plchor, plspec, prspec, plargl, prargl,    lpw_d     /
     /    .false.,.false.,.false.,.false.,.false.,npwinx*.false./
      data txtsig  ,   txtmtmp  ,   txtmtra   /
     /    nchor*' ',lntsputx*' ',lntsputx*' ' /

c*** 13

      data nprnli, ntmstp , nptst  , ninitl_read /
     /        0  ,    1   ,   0    ,   -1        /,
     ,      nsnvi,  isnve ,  isnvs ,  isnvt ,  isnrc /
     ,        0  , nsnv*0 , nsnv*0 , nsnv*0 , nsnv*0 /
      data dtimv , time0 /
     /     1.e+2 ,   0.  /
      data  txttlv ,  txtspv ,  txtunv  /
     /     nsnv*' ', nsnv*' ', nsnv*' ' /

c*** 14

      data nclmi,nblcki,nprnvi,nprtvi,nprdvi, nfla , ncutb, lkindp  /
     /        5 , -25  ,  1   , 350  ,  1   ,   0  ,   0  , npls*0  /,
     ,     ncutl, imf  ,ntrfrm, nfull, ibrad, ibpol, ibtor / 
     /       1  ,   0  ,  0   ,   0  ,  1   ,    1 ,   1   /,
     ,     iflb , ndxa , ndya ,ntargi, ntgprt, ndt2  /
     /    npls*1,  0   ,  0   ,  0   ,nstep*1,lusg*0 /,
     ,    ninct2, nixy2, ntin2, nten2, niflg,  nptc , nptcm, nspzi /
     /    lusg*0,lusg*0,lusg*0,lusg*0,lusg*0, lusg*0,lusg*0,lusg*0 /,
     ,     nspze, nemod, nainb, naotb,istramin,istramax,ncopib,ncopeb /
     /    lusg*0,lusg*7,   0  ,   0  ,    1   ,    1   ,   0  ,   0   /
      data fcte , bmass ,  chgsp ,  chgsee ,  chgsei , chgsmom /
     /   npls*1.,npls*0.,nstra*60.,nstra*60.,nstra*100.,nstra*50. /
      data lsymet,lbalan,lcoarse, lfchgs /
     /    .false.,.true.,.false.,.false. /
    
c*** 15

      data ntrgte, ntrgto, ntrgtm /
     /        0  ,    0  ,    0   /
      data nadmod,   nrs   , ipunkt  , jedge /
     /        0  ,nnadmod*0,nnadmod*0,  16*0 /
      data xcoor   ,  ycoor   ,  zcoor   ,xpolpos,ypolpos /
     /   nnadmod*0.,nnadmod*0.,nnadmod*0.,  8*0. ,  8*0.  /

c*** Data for Eirene test run

      data
     , ttntcpu,ttnfile, ttnpts, ttalloc,tttest,ttcsrc,ttcsur,ttcint /
     /    50  , 10100 , nstra*5,   0.  ,.true.,.true.,.true.,.true. /,
     , ttchst,ttcref,ttcamd,ttcsou,ttcbla,ttcblm,ttcbli,ttcblp,ttcble /
     / .true.,.true.,.true.,.true.,.true.,.true.,.true.,.true.,.true. /,
     , ttcblph,ttctal,ttcdbg2,ttcdbge,ttcdbgm,ttcdbgf,ttcdbgl,ttcdbgs/
     / .true.,.true. ,.true. ,.true. ,.true. ,.true. ,.true. ,.true. /,
     , ttcdbgg,ttcdbgmpi,ttcdbgc/
     / .true. ,.true.   ,.true. /,
     , ttpl1st,ttpl2nd,ttpladd,ttplhst,        ttplcut       ,ttplnums/
     / .true. ,.true. ,.true. ,.true. ,.false.,.false.,.true.,.true.  /

c*** Data for diagnostic run

      data lntspcu,lntsptu,nmcsptu,dgntcpu,dgnptsfc,dgnfile,dgalloc /
     /        1   ,   0   ,   0   ,  1200 ,   10   , 00100 ,  0.5   /

c*** Data for b2ah.dat.stencil file

      data  cbsna , cbsmo , cbshi , cbmsb , cbrec /
     /     lcbs*0.,lcbs*0.,lcbs*0.,lcbs*0.,lcbs*0./,
     ,      cbshe , cbsch , cbmsa /
     /     lcbe*0.,lcbe*0.,lcbe*0./,
     ,      cfdf0 , cfdna , cfdpa , cfvla , cfvsa , cfhci /
     /     lcfs*0.,lcfs*0.,lcfs*0.,lcfs*0.,lcfs*0.,lcfs*0./,
     ,      cfhce , cfsig , cfalf , cflim /
     /       8*0. ,  8*0. ,  8*0. ,  8*0. /

c======================================================================
      end
