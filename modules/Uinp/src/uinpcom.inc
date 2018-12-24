c  VERSION : 01.04.2005 14:26

c*** The basic data for uinput

#include "COUPLE/KOPPLDIM.F"

c=======================================================================
c*** Temporary assignment - the max. number of photon species
      integer, parameter :: npht=1

c*** Unit numbers for output and input of the files
      integer, parameter :: iunoo=2, iunii=1

c*** Variable dimensions for the output data
      integer nstrao,natmo,nmolo,niono,nphto,nplso

c*** Grid segmentation, topology, and AMDS file.
c***  [nm]npr   : the maximum and actual numbers of radial grid regions,
c***      npr   : their segmentation (DG);
c***  [nm]nptseg: the maximum and actual numbers of poloidal grid zones,
c***      nptseg: their segmentation (DG);
c***  ntrgdflt  : default number of targets depending on the topology
c***  ntrgts    : maximum number of targets
c***  nntrian   : maximum number of triangular mesh nodes for input
      integer,parameter::nnpr=6,nnptseg=6,ntrgts=4,namdfs=20,nntrian=1
      integer mnpr,mnptseg,npr(nnpr),nptseg(nnptseg),ntrgdflt,namdf
      character*4 topo
      character*48 amd_file(namdfs)

c*** B2 dimensions
      integer, parameter :: nsdb2=DEF_NSD,
     & nxd=DEF_NXD+DEF_NCUT*5, nyd=DEF_NYD

c*** Eirene dimensions
c***  nchor     max. number of explicitly specified diagnostic chords
c***  nstep     the maximum number of surface sources
c***  lntsputx  max. number of material template surfaces
c***  nsrfclsx  max. number of views

      integer nplg, nppart, nstep
      parameter (nppart=max(1,DEF_NCUT*3))
      parameter (nplg=DEF_NXD+nppart)
      parameter (nstep=DEF_NSTRA)
      integer nreac, nchor, lntsputx, nsrfclsx
      parameter (nreac=DEF_NREAC, nchor=250, lntsputx=4, nsrfclsx=12)
      integer nrad, nadd, nplt, nsd, nsdw, ncv, nsnv
      integer nadv, nclv, nalv, nads, nals, nasp
      integer nhd6, nmtr, nain
      parameter (nadd=DEF_NADD)
      parameter (nrad=n1st*n2nd*n3rd+nadd+1)
      parameter (nplt=5, nsd=1, nsdw=1, ncv=1, nsnv=1)
      parameter (nadv=4*(DEF_NATM+DEF_NMOL))
      parameter (nads=1, nclv=1, nalv=1, nals=1, nasp=1)
      parameter (nmtr=6, nain=1)
      parameter (nhd6=DEF_NATM*nmtr)

c*** Uinp dimensions
      integer :: lugen
      parameter (lugen=max(3,DEF_NATM))

c*** The definitions below must match those found in eirmod_parmmod
      integer ntalv, nbmax, nptal
      parameter (ntalv=100, nbmax=10, nptal=30)

c*** Cuts and grid blocks: number of cuts, their location and length,
c***    the same for isolating cuts (B2 notation),
c***    number of grid blocks, and grid dimensions (B2);
c***    poloidal positions of the cuts, isolating cuts, 
c***    and the last target, the radial positions of
c***    the separatrices and the outer wall 
c***    (see uinprpgr.F for detail)
      integer nncut,nxcut1(nnptseg),nycut2(nnptseg),nniso,ntiso(nxd),
     ,  nxiso1(nxd),nxiso2(nxd),nyiso1(nxd),nyiso2(nxd),nx,ny
      integer izc1,izc2,izc3,izc4,izci,iztg,irsp,irsp2,irwl,
     ,  nrsol,nrsol1,nrpfl,nzidv,nzinn,nzodv,nzidv2,nzinn2,nzodv2
      real(kind=R4) niiso(nsdb2),tiiso,teiso
     
c-----------------------------------------------------------------------
c*** Species lists: number of different nuclei, plasma ions, atoms,
c***                molecules, and test ions; notations for them,
c***                reflected fast and thermal particles (AMDS);
c***                atomic mass, nuclear charge, ion charge, number of
c***                nuclei, and sputtering flag for each species,
c***                reference nucleus for plasma ions and atoms,
c***                CEI boundary condition kind for each nucleus, 
c***                source scaling trigger for each nucleus,
c***                density cut-off for plasma ions (log2!!),
c***                history following flag (atoms, molecules, and ions),
c***                flag for 3 secondary particles for each species,
c***                max. number of MC generations (0 - unlimited) for
c***                atoms, molecules, and test ions,
c***                nuclear composition for molecules and test ions;
c***                CEI boundary condition parameter and
c***                inboard flux fraction for each nucleus,
c*** spcscrk - CEI boundary condition kind:
c***  0 - default for this nucleus
c***  1 - density for the highest ion, zero flux for the rest
c***  2 - density for the highest ion, zero density for the rest 
c***  3 - flux for the highest ion, zero flux for the rest 
c*** spcscrp - the value of flux or density for the highest ion
c*** spcscrf - flux fraction across the inboard CEI (DN only)

      integer nspcncl,nspcpls,nspcatm,nspcmol,nspcion
      character*8 spcsncl(natm),spcspls(npls),spcsatm(natm),
     ,  spcsmol(nmol),spcsion(nion),
     ,  spcsrfp(npls),spcsrfa(natm),spcsrfm(nmol),spcsrfi(nion),
     ,  spcsrtp(npls),spcsrta(natm),spcsrtm(nmol),spcsrti(nion)
      integer spcsmsp(npls),spcsmsa(natm),spcsmsm(nmol),spcsmsi(nion),
     ,  spcsncp(npls),spcsnca(natm),spcsncm(nmol),spcsnci(nion),
     ,  spcscgp(npls),spcscga(natm),spcscgm(nmol),spcscgi(nion),
     ,  spcsfup(npls),spcsfua(natm),spcsfum(nmol),spcsfui(nion),
     ,  spcsrsp(npls),spcsrsa(natm),spcsrsm(nmol),spcsrsi(nion),
     ,  spcsrnp(npls),spcsrna(natm),spcscrk(natm),spcsscn(natm),
     ,  spcsdlp(npls),spcsfla(natm),spcsflm(nmol),spcsfli(nion),
     ,  spcsnsp(npls),spcsnsa(natm),spcsnsm(nmol),spcsnsi(nion),
     ,  spcsnga(natm),spcsngm(nmol),spcsngi(nion),
     ,  spcscmm(natm,nmol),spcscmi(natm,nion)
      real(kind=R4) spcscrp(natm),spcscrf(natm)

c*** Input species lists: the same + generic species (the whole chain
c***                      related to the same atom)
c***                      nspignp gives the number of molecules, test
c***                      ions, and plasma ions for each selected GS;
c***                spcids[amip] is the sampling frequency,
c***                spcinn[mi] is the number of nuclei kinds and
c***                spcicm[mi] the nuclear composition for
c***                each molecule or test ion.
      integer nspipls,nspiatm,nspimol,nspiion,nspigen,nspignp(3,natm)
      character*8 spcincl(natm)*2,spcipls(npls)*6,spciatm(natm)*2,
     ,  spcimol(nmol),spciion(nion),spcigen(lugen)*2,
     ,  spcirfp(npls),spcirfa(natm),spcirfm(nmol),spcirfi(nion),
     ,  spcirtp(npls),spcirta(natm),spcirtm(nmol),spcirti(nion),
     ,  spcirnp(npls),spcirna(natm),
     ,  spcirnm(natm,nmol),spcirni(natm,nion)
      integer spcimsp(npls),spcimsa(natm),spcimsm(nmol),spcimsi(nion),
     ,  spcincp(npls),spcinca(natm),spcincm(nmol),spcinci(nion),
     ,  spcicgp(npls),spcicga(natm),spcicgm(nmol),spcicgi(nion),
c     ,  spcifup(npls),spcifua(natm),spcifum(nmol),spcifui(nion),
     ,  spcirsp(npls),spcirsa(natm),spcirsm(nmol),spcirsi(nion),
     ,  spcinnm(nmol),spcinni(nion),spcicrk(natm),spciscn(natm),
     ,  spcidlp(npls),spcifla(natm),spciflm(nmol),spcifli(nion),
     ,  spcinsp(npls),spcinsa(natm),spcinsm(nmol),spcinsi(nion),
     ,  spcinga(natm),spcingm(nmol),spcingi(nion),
     ,  spcicmm(natm,nmol),spcicmi(natm,nion)
      real(kind=R4)
     ,  spcidsp(npls),spcidsa(natm),spcidsm(nmol),spcidsi(nion),
     ,  spcicrp(natm),spcicrf(natm)

c*** Default particle chains for the generic species
c***    Number of entries, storage size; default GS list;
c***    species notation, reflected particle, and desorbed particle;
c***    species start index, numbers of plasma ions, molecules, and 
c***    test ions for each entry (always one atom for a GS);
c***    atomic mass, nuclear charge, charge state, flux units (nuclei),
c***    and '3 secondaries' flag for each entry 
      integer nspdgen,nspdlen
      parameter (nspdgen=11, nspdlen=83)
      character*8 spcdgen(nspdgen)*2,spcdspc(nspdlen),
     ,  spcdrfl(nspdlen),spcdrtl(nspdlen)
      integer lspdgen(nspdgen),nspdpls(nspdgen),
     ,  nspdatm(nspdgen),nspdmol(nspdgen),
     ,  nspdion(nspdgen),spcdms(nspdlen),spcdnc(nspdlen),
     ,  spcdcg(nspdlen),spcdfu(nspdlen),spcdns(nspdlen)
      logical no_n2(nspdlen), no_n2_model, l_ammon(nspdlen), ammonx_used
      logical l_meta(nspdlen), meta_used, is_meta(natm)
      
c-----------------------------------------------------------------------
c*** Boundary conditions at the grid edge.

c***  Maximum numbers of divides, kinds of boundaries (core, target, 
c***     PFR side, outer side), boundary regions of each type, 
c***     boundary zones of each kind, markers for each zone
      integer nbnddvd,nbndknd,nbndrgn,nbndzon
      parameter (nbnddvd=400, nbndknd=4, nbndrgn=12, nbndzon=20)

c*** Eirene data: surface type, position, start, end, plotting color,
c***    direction (W,S: -1; E,N: 1), reflection model
c***    switch and group for chemical sputtering,
c***    switch and species for physical sputtering, max. and min. number
c***    of histories, random number initialisator, energy distribution;
c***    transparences forth and back, absorption, wall temperature, 
c***    fudge factors for physical and chemical sputtering,
c***    Eirene parameters SORENI and SORENE;
c***    flag "recycling surface"; surface material 
      integer jskbnds(nbndzon,nbndknd), jcpbnds(nbndzon,nbndknd),
     ,        jc1bnds(nbndzon,nbndknd), jc2bnds(nbndzon,nbndknd),
     ,        jclbnds(nbndzon,nbndknd), jdrbnds(nbndzon,nbndknd),
     ,        jrfbnds(nbndzon,nbndknd), jcsbnds(nbndzon,nbndknd),
     ,        jcgbnds(nbndzon,nbndknd), jpsbnds(nbndzon,nbndknd),
     ,        jppbnds(nbndzon,nbndknd), jnpbnds(nbndzon,nbndknd),
     ,        jmpbnds(nbndzon,nbndknd), jnibnds(nbndzon,nbndknd),
     ,        jnebnds(nbndzon,nbndknd)
      real(kind=R4)
     ,        etfbnds(nbndzon,nbndknd), etbbnds(nbndzon,nbndknd),
     ,        easbnds(nbndzon,nbndknd), eewbnds(nbndzon,nbndknd),
     ,        efpbnds(nbndzon,nbndknd), efcbnds(nbndzon,nbndknd),
     ,        esibnds(nbndzon,nbndknd), esebnds(nbndzon,nbndknd)
      logical nlrbnds(nbndzon,nbndknd)
      character*8 ewmbnds(nbndzon,nbndknd)

c*** Material properties of the grid edges:
c***    dimensions for the number of material templates and grid markers
c***    specified numbers of material templates and grid and target
c***    markers for each template; lists of grid markers, target
c***    markers, and template references; index of default template in
c***    the above list; temporary storage for selected wall materials
c***    flags "insert material specification" for each non-def. surface
      integer nwllmrkd,nedgmrkd
      parameter (nwllmrkd=8, nedgmrkd=20)
      integer nwllmrk,nedgmrk(nwllmrkd),ntrgmrk(nwllmrkd),
     ,  ledgmrk(nedgmrkd,nwllmrkd),ltrgmrk(nedgmrkd,nwllmrkd),
     ,  lwllmrk(nwllmrkd),ledgdfl
      real(kind=R4) wlmbnds(nbndzon,nbndknd)
      logical bliin(nsts),bbliin(nbndzon,nbndknd)

c*** B2 data: position, start, end, neutral penetration range, 
c***         start and end of recycling sources,
c***         types of boundary conditions for Te, n, Ti, and v,
c***         reference to a nuclei species to scale the source with;
c***         parameters for boundary conditions for Te, Ti, n, and v
      integer lcpbnds(nbndzon,nbndknd), lc1bnds(nbndzon,nbndknd),
     ,        lc2bnds(nbndzon,nbndknd), lrrbnds(nbndzon,nbndknd),
     ,        ls1bnds(nbndzon,nbndknd), ls2bnds(nbndzon,nbndknd),
     ,        leebnds(nbndzon,nbndknd), lcobnds(nsdb2,nbndzon,nbndknd), 
     ,        leibnds(nbndzon,nbndknd), lmobnds(nsdb2,nbndzon,nbndknd),
     ,        lpobnds(nbndzon,nbndknd), lscbnds(natm,nbndzon,nbndknd)
      real(kind=R4)  
     ,  beebnds(nbndzon,2,nbndknd),bcobnds(nsdb2,nbndzon,2,nbndknd),
     ,  beibnds(nbndzon,2,nbndknd),bmobnds(nsdb2,nbndzon,2,nbndknd),
     ,  bpobnds(nbndzon,2,nbndknd)
      character cskbnds(nbndzon,nbndknd), ctxbnds(nbndknd)*10

c*** DG data: number and list of divides, numbers and lists of
c***      explicitly specified zones of each type and markers there;
c***      surface type, plotting color, reflection model,
c***      switch and group for chemical sputtering, switch and species 
c***      for physical sputtering, flag "recycling surface", max. and
c***      min. number of histories, random number initialisator,
c***      energy distribution;
c***      transparences forth and back, absorption, wall temperature,
c***      fudge factors for physical and chemical sputtering,
c***      Eirene parameters SORENI and SORENE;
c***      material, species to scale and with which to scale;
c***      flags "use default recycling"; 
c***      types of boundary conditions for Te, n, Ti, and v;
c***      parameters for boundary conditions for Te, Ti, n, and v.
c*** ldvbndx(0) is the number of radial markers
      integer mdvbndx,ldvbndx(0:nbnddvd),
     ,  mznbndx(nbndknd),lznbndx(nbndzon,nbndknd),
     ,  mmkbndx(nbndknd),lmkbndx(nbndzon,nbndknd)
c***                    Below, index "0" corresponds to a group default
      integer jskbndx(0:nbndzon,nbndknd), jclbndx(0:nbndzon,nbndknd),
     ,        jrfbndx(0:nbndzon,nbndknd), jcsbndx(0:nbndzon,nbndknd),
     ,        jcgbndx(0:nbndzon,nbndknd), jpsbndx(0:nbndzon,nbndknd),
     ,        jppbndx(0:nbndzon,nbndknd), nlrbndx(0:nbndzon,nbndknd),
     ,        jnpbndx(0:nbndzon,nbndknd), jmpbndx(0:nbndzon,nbndknd),
     ,        jnibndx(0:nbndzon,nbndknd), jnebndx(0:nbndzon,nbndknd)
      real(kind=R4)
     ,        etfbndx(0:nbndzon,nbndknd), etbbndx(0:nbndzon,nbndknd),
     ,        easbndx(0:nbndzon,nbndknd), eewbndx(0:nbndzon,nbndknd),
     ,        efpbndx(0:nbndzon,nbndknd), efcbndx(0:nbndzon,nbndknd),
     ,        esibndx(0:nbndzon,nbndknd), esebndx(0:nbndzon,nbndknd)
      character*2 ewmbndx(0:nbndzon,nbndknd)*8,
     ,  escbndx(natm,0:nbndzon,nbndknd), eswbndx(natm,0:nbndzon,nbndknd)
      logical dfrbndx(nbndknd)
      integer 
     ,  leebndx(0:nbndzon,nbndknd), lcobndx(nsdb2,0:nbndzon,nbndknd), 
     ,  leibndx(0:nbndzon,nbndknd), lmobndx(nsdb2,0:nbndzon,nbndknd),
     ,  lpobndx(0:nbndzon,nbndknd)
      real(kind=R4)  
     ,  beebndx(0:nbndzon,2,nbndknd),bcobndx(nsdb2,0:nbndzon,2,nbndknd),
     ,  beibndx(0:nbndzon,2,nbndknd),bmobndx(nsdb2,0:nbndzon,2,nbndknd),
     ,  bpobndx(0:nbndzon,2,nbndknd)
c*** Default boundary conditions for generic species. Index order:
c*** species, [parameter], boundary kind, ion(2-the highest, 1-the rest)
      integer kcobndx(nspdgen,nbndknd,2),   kmobndx(nspdgen,nbndknd,2)
      real(kind=R4)
     ,  dcobndx(nspdgen,2,nbndknd,2), dmobndx(nspdgen,2,nbndknd,2)
      character*2 dscbndx(nspdgen)
c*** Flags "B2 global data read" and "use time stratum";
c*** total power influx [MW] with electrons and ions, its fraction 
c*** across the inner CEI (DN only).
      logical glb2read,usetmstr
      real(kind=R4) pwrcrtte,pwrcrtti,pwrcrfri

c*** Technical data: numbers of regions and zones of each kind,
c***             region which can be combined with each region,
c***             zone reference to the boundary regions,
c***             radial and poloidal range of B2 cells for each region,
c***             their positions, zone range and position ;
c***             flags "explicit boundary specified" and 
c***             "explicit recycling specified" for each zone;
c***             boundary code (E, W, S, N) for each region and zone;
      integer nrgbndt(nbndknd),nznbndt(nbndknd),
     ,  lcmbndt(nbndrgn,nbndknd),lrfbndt(nbndzon,nbndknd),
     ,  lrrbndt(nbndrgn,nbndknd,2),lrpbndt(nbndrgn,nbndknd,2),
     ,  lrsbndt(nbndrgn,nbndknd),
     ,  lzrbndt(nbndzon,nbndknd,2),lzpbndt(nbndzon,nbndknd)
      logical bxsbndt(nbndzon,nbndknd),rxsbndt(nbndzon,nbndknd)
      character crgbndt(nbndrgn,nbndknd),cznbndt(nbndzon,nbndknd)
      
c-----------------------------------------------------------------------
c*** Whole targets: number of targets, PFR edges, CFR edges,
c***           old-style specification, target counters;
c***           switches for reflection, phys. and chem. sputtering,
c***           phys. sputtered particle, chem. surface group, max. and
c***           min. number of histories, RNG initialisator;
c***           multipliers for phys. and chem. sput., wall temperature,
c***           absorption, transparence forth and back;
c***           material; flag "target data was read"
      integer ntrgte,jedgep(ntrgts),jedgec(ntrgts),jedgeo(ntrgts),
     ,  ntrgto,ntrgtm
      integer tgrefsw(ntrgts),tgsppsw(ntrgts),tgspcsw(ntrgts),
     ,  tgsppsp(ntrgts),tgspcgr(ntrgts),tgnhst(ntrgts),tgmhst(ntrgts),
     ,  tgnini(ntrgts)
      real(kind=R4)
     ,  tgsppff(ntrgts),tgspcff(ntrgts),tgewall(ntrgts),
     ,  tgabsrp(ntrgts),tgtrnsf(ntrgts),tgtrnsb(ntrgts)
      character*8 made_of(ntrgts)
      logical tgdtinpt

c-----------------------------------------------------------------------
      integer mreac
      parameter (mreac=2*nreac)

c*** Reaction lists: number of datasets, groups, massp, masst,
c***    number of the output particles, extrapolation modes;
c***    reaction type, database, chapter and reaction;
c***    input and output particles (AMDS notation);  
c***    deltae, tmin, and tmax from AMDS, energies of the 
c***    reaction products (for DS), extrapolation coefficients;
c***    flag "Use the default model" 
      integer nnrctn,rctngrp(mreac),rctnmsp(mreac),rctnmst(mreac),
     ,  rctnnmo1(mreac),rctnnmo2(mreac),rctnnmo3(mreac),
     ,  rctnimn(mreac),rctnimx(mreac),rctniz(mreac)
      character*8 rctntyp(mreac)*2,rctndbs(mreac)*6,rctnchp(mreac)*4,
     ,  rctnrct(mreac)*9,rctnptpr(mreac),rctnptin(mreac),
     ,  rctnpto1(mreac),rctnpto2(mreac),rctnpto3(mreac),
     ,  rctneln(mreac)*2
      real(kind=R4)
     ,  rctndlte(mreac),rctntmin(mreac),rctntmax(mreac),
     ,  rctnenr1(mreac),rctnenr2(mreac),rctnexcf(mreac,6)
      logical rctndflt

c*** Default reaction lists: the same for each species (nsrctd and 
c***    spcrctd are the number and the list of default species;
c***    primary particle is determined from spcrctd)
      integer nsrctd
      parameter (nsrctd=14)
      character*8 spcrctd(nsrctd)
      integer nnrctd(nsrctd),rctdgrp(mreac,nsrctd),
     ,  rctdmsp(mreac,nsrctd),rctdmst(mreac,nsrctd)
      character*6 rctdtyp(mreac,nsrctd)*2,rctddbs(mreac,nsrctd),
     ,  rctdchp(mreac,nsrctd)*4,rctdrct(mreac,nsrctd)*9,
     ,  rctdptpr(mreac,nsrctd),rctdptin(mreac,nsrctd),
     ,  rctdpto1(mreac,nsrctd),rctdpto2(mreac,nsrctd),
     ,  rctdpto3(mreac,nsrctd),rctdeln(mreac,nsrctd)
      real(kind=R4) 
     ,  rctddlte(mreac,nsrctd),rctdtmin(mreac,nsrctd),
     ,  rctdtmax(mreac,nsrctd),
     ,  rctdenr1(mreac,nsrctd),rctdenr2(mreac,nsrctd)
      integer n_hlp_h,m_hlp_h
      parameter (n_hlp_h=16, m_hlp_h=3)
      integer hlp_h_m(n_hlp_h)
      character*4 hlp_h(n_hlp_h,m_hlp_h,2)

c-----------------------------------------------------------------------
c*** Chemical sputtering: pairs projectile-wall and sputtered particle 
c***                      as input from DG
      integer nchsppr
      parameter (nchsppr=DEF_NATM*(ntrack+nalloys))
      character chsptgt(nchsppr)*24,chspspt(nchsppr)*8
      
c-----------------------------------------------------------------------
c*** Gas puffing strata: number, corresponding strata, number of surface
c***    segments and their lists, angular distribution (namods in 
c***    Eirene), first additional cells (NASOR), max. and min. number of
c***    histories, RNG initialisation, nuclear composition 
c***    of the source, species to scale with (B2); 
c***    species (AMDS), species to scale with (AMDS);
c***    gas temperature, its default value, parameter for
c***    angular distribution, and source strength
      integer ngpfstr,ingpfstr(nstra),kgpfstr(nstra),lgpfstr(nlim),
     ,  jgpfstr(nstra),mgpfstr(nstra),npgpfstr(nstra),mpgpfstr(nstra),
     ,  nigpfstr(nstra),igpfstr(natm,nstra),lsgpfstr(natm,nstra)
      character*12 cgpfstrs(nstra),sgpfstrs(natm,nstra)*2
      real(kind=R4) tgpfstr(nstra),tgpfstd,pgpfstr(nstra),fgpfstr(nstra)

c*** Recombination strata: number of strata, starting/ending cells in
c***    radial and poloidal directions, number of
c***    histories, RNG initialisation, species to scale 
c***    with (B2); recombined atom (AMDS), 
c***    species to scale and to scale with (AMDS);
c***    flag "use defaults if no sources specified"
      integer nrcmstr,lrcmrb(nstra),lrcmre(nstra),lrcmpb(nstra),
     ,  lrcmpe(nstra),nrcmstrs(nstra),ircmstrs(nstra),
     ,  lsrcmstr(natm,nstra)
      character*6 crcmstrs(nstra),srcmstrs(natm,nstra)*2,
     ,  wrcmstrs(natm,nstra)*2
      logical srcvdflt
          
c-----------------------------------------------------------------------
c*** Data for wall erosion calculation in Eirene - to be used for a
c*** separate Eirene input file called "diag2.eir"
c***    lntspcu   becomes lntspec
c***    lntsptu   becomes lntsput
c***    nmcsptu   becomes nmcsput
c***    nlstadu   becomes nlstadds
c***    ngwtiesi  becomes ngwties
      integer lntspcu,lntsptu,nmcsptu,nlstadu,dgntcpu,dgnptsfc,
     ,  dgnfile,listaddi(nlim),ngwtiesi
      real(kind=R4) dgalloc
          
c-----------------------------------------------------------------------
c*** Data for visualisation of the surface properties in Eirene for all
c*** nvspfls Eirene input files (input.eir, test.eir, and diag2.eir)
c***    nsrfclu   becomes nsrfcls
c***    msrfclu   becomes msrfcls
c***    lsrfclu   becomes lsrfcls
c***    isrfclu(i,j).ne.0 : specify view i in the file j
      integer nvspfls
      parameter (nvspfls=3)
      integer nsrfclu(nvspfls),msrfclu(nsrfclsx,nvspfls),
     ,  lsrfclu(msrfclsx,nsrfclsx,nvspfls),isrfclu(nsrfclsx,nvspfls)
          
c-----------------------------------------------------------------------
c*** Numbering offset for "additional surfaces" and surface indices:
c***    indasrfe(i) is the new number for an old number i,
c***    indasrfs(i) is the old number for a new number i
      integer laddsrfs, indasrfe(0:nlim), indasrfs(0:nlim)

c*** Coordinates of the O-point
      real(kind=R4) xlpcntr(3)

c*** Data for toroidal geometry specification 
      real(kind=R4) zaator,roator
      integer nttrator

c*** Midplane position in the B2 grid, Eirene time allocation in B2
      integer jxi,jxa,ntcpub2

c*** Vessel specification for b2plot: number of segments, index
      integer nnvsle, nmvsle(nlim)

c-----------------------------------------------------------------------
c*** Data for triangular mesh: maximum number of mesh refinment zones;
c*** temporary arrays for ILPLG parameter;
c*** mesh size and coordinates of refinment zone (rectangle);
c*** refinment zone markers from DG, and actual number of zones 
       integer ntrimax
       parameter (ntrimax=100) 
       integer ilplgu(nsts),jlplgu(nlim),ilplgdg(nlim) 
       real trisize(0:ntrimax), trixmin(ntrimax), trixmax(ntrimax),
     ,      triymin(ntrimax), triymax(ntrimax)
       integer trirefel(2*nlim),trirefcn(ntrimax),ntriref     

c-----------------------------------------------------------------------
c*** Data for pre-defined 'density models' in Eirene:
c*** number of these models and max. length of their names;
c*** names of the models
      integer ndnmdlp,ldnmdlp
      parameter (ndnmdlp=10,ldnmdlp=10)
      character*(ldnmdlp) cdnmdlp_sel(ndnmdlp)
      

c-----------------------------------------------------------------------
c*** Data for postprocessing windows: max. number of them
      integer npwinx
      parameter (npwinx=16)

c-----------------------------------------------------------------------
c*** Helium pumping data: flag "Do this section";
c***    fusion power, ratio of He to D pumping speeds;
c***    pump location (1 - lower PFR, 2 - outer side, other - no pump),
c***    bottom and top of the cell ranges, inner and outer, where the
c***    neutral pressure is to be averaged, indices of the D and He
c***    atoms in the list, amount of hydrogenic nuclei in the molecules,
c***    list of cell numbers indicating the pump and their number,
c***    list of wall segments indicating the pump and their number
      logical do_hepdt
      real(kind=R4) pwrhepdt,pmphepdt
      integer locphep,lpbihep,lpbohep,lptihep,lptohep,
     ,  j_he_at,j_h_at(3),j_ne_at,
     ,  l_h_mol(nmol,3),lstclhep(nxd),nstclhep,lhetrgts(nlim),nhetrgts

c-----------------------------------------------------------------------
c*** Data substitution for the Eirene test run
      integer ttntcpu,ttnfile,ttnpts(nstra)
      real(kind=R4) ttalloc
      logical
     ,  ttchst,ttcref,ttcint,ttcamd,ttcsou,ttcsur,ttcbla,ttcblm,ttcbli,
     ,  ttcblp,ttcble,ttcblph,ttctal,ttcdbg2,ttcdbge,ttcdbgm,ttcdbgf,
     ,  ttcdbgl,ttcdbgs,ttcdbgg,ttcdbgmpi,ttcdbgc,ttcsrc,
     ,  ttpl1st,ttpl2nd,ttpladd,ttplhst,ttplcut(3),ttplnums,tttest
      
c-----------------------------------------------------------------------
c*** Eirene surface data through B2:
c***      number of groups, number of surfaces in the groups, wall group
c***      for chem. sputtering, the first and last positions of the 
c***      group in the common list, the common list of affected 
c***      segments, the input list of affected segments;
c***      absorption, transparency out, transparency in, surface 
c***      material in Eirene notation, surface temperature, physical
c***      sputtering factor, chemical sputtering factor;
c***      surface material in human notation, group identifier
      integer n_spcsrf, k_spcsrf(DEF_NSPCSRFG), sps_sgrp(DEF_NSPCSRFG),
     ,  i_spcsrf(DEF_NSPCSRFG), j_spcsrf(DEF_NSPCSRFG),
     ,  l_spcsrf(DEF_NSPCSRFG), ll_spcsrf(nlimps,DEF_NSPCSRFG)
      real(kind=R4)
     ,  sps_absr(DEF_NSPCSRFG), sps_trno(DEF_NSPCSRFG), 
     ,  sps_trni(DEF_NSPCSRFG), sps_mtri(DEF_NSPCSRFG),
     ,  sps_tmpr(DEF_NSPCSRFG), sps_spph(DEF_NSPCSRFG),
     ,  sps_spch(DEF_NSPCSRFG)
      character*4 sps_mtrl(DEF_NSPCSRFG), sps_id(DEF_NSPCSRFG)*16
      
c-----------------------------------------------------------------------
c*** Gas flows in PFR:
      integer npfrgrp,npfrgrpd
      parameter (npfrgrpd=12)
      integer lpfrgrp(DEF_NLIM),ipfrgrp(npfrgrpd),jpfrgrp(npfrgrpd)
      character gpfrgrp(npfrgrpd)*8
      
c-----------------------------------------------------------------------
c*** Limiter configuration - cheating:
      logical lm_cnfg
      integer lm_vhst, lm_whst

c-----------------------------------------------------------------------
c*** Wall material data
      character*8 umtrl(nlim)

c=======================================================================
      common/uinpcom/niiso,tiiso,teiso,spcscrp,spcscrf,
     ,  spcidsp,spcidsa,spcidsm,spcidsi,spcicrp,spcicrf,
     ,  etfbnds,etbbnds,easbnds,eewbnds,efpbnds,efcbnds,
     ,  esibnds,esebnds,beebnds,bcobnds,beibnds,bmobnds,bpobnds,
     ,  etfbndx,etbbndx,easbndx,eewbndx,efpbndx,efcbndx,esibndx,esebndx,
     ,  wlmbnds,beebndx,bcobndx,beibndx,bmobndx,bpobndx,
     ,  dcobndx,dmobndx,
     ,  pwrcrtte,pwrcrtti,pwrcrfri,
     ,  rctndlte,rctntmin,rctntmax,rctnenr1,rctnenr2,rctnexcf,
     ,  rctddlte,rctdtmin,rctdtmax,rctdenr1,rctdenr2,
     ,  tgpfstr,tgpfstd,fgpfstr,pgpfstr,dgalloc,
     ,  tgsppff,tgspcff,tgewall,tgabsrp,tgtrnsf,tgtrnsb,ttalloc,
     ,  xlpcntr,zaator,roator,
     ,  trisize,trixmin,trixmax,triymin,triymax,pwrhepdt,pmphepdt,
     ,  sps_absr,sps_trno,sps_trni,sps_mtri,sps_tmpr,sps_spph,sps_spch,
     i  nstrao,natmo,nmolo,niono,nphto,nplso,
     ,  mnpr,mnptseg,npr,nptseg,laddsrfs,indasrfe,indasrfs,
     ,  nttrator,jxi,jxa,ntcpub2,nnvsle,nmvsle,ttntcpu,ttnfile,ttnpts,
     ,  ntrgdflt,namdf,nncut,nxcut1,nycut2,nniso,ntiso,nxiso1,nxiso2,
     ,  nyiso1,nyiso2,nx,ny,
     ,  izc1,izc2,izc3,izc4,izci,iztg,irsp,irsp2,irwl,hlp_h_m,
     ,  nrsol,nrsol1,nrpfl,nzidv,nzinn,nzodv,nzidv2,nzinn2,nzodv2,
     ,  nspipls,nspiatm,nspimol,nspiion,nspigen,nspignp,spcimsp,spcimsa,
     ,  spcimsm,spcimsi,spcincp,spcinca,spcincm,spcinci,spcicgp,spcicga,
     ,  spcicgm,spcicgi,
c     ,  spcifup,spcifua,spcifum,spcifui,
     ,  spcirsp,spcirsa,
     ,  spcirsm,spcirsi,spcinnm,spcinni,spcicrk,spciscn,spcidlp,spcifla,
     ,  spciflm,spcifli,spcinsp,spcinsa,spcinsm,spcinsi,spcinga,spcingm,
     ,  spcingi,spcicmm,spcicmi,lspdgen,
     ,  nspdpls,nspdatm,nspdmol,nspdion,
     ,  spcdms,spcdnc,spcdcg,spcdfu,spcdns,
     ,  jskbnds,jcpbnds,jc1bnds,jc2bnds,jclbnds,jdrbnds,jrfbnds,jcsbnds,
     ,  jcgbnds,jpsbnds,jppbnds,jnpbnds,jmpbnds,jnibnds,jnebnds,
     ,  nwllmrk,nedgmrk,ntrgmrk,ledgmrk,ltrgmrk,lwllmrk,ledgdfl,
     ,  lcpbnds,lc1bnds,lc2bnds,lrrbnds,ls1bnds,ls2bnds,leebnds,lcobnds,
     ,  leibnds,lmobnds,lscbnds,lpobnds,
     ,  mdvbndx,ldvbndx,mznbndx,lznbndx,mmkbndx,lmkbndx,
     ,  jskbndx,jclbndx,jrfbndx,jcsbndx,jcgbndx,jpsbndx,jppbndx,nlrbndx,
     ,  jnpbndx,jmpbndx,jnibndx,jnebndx,
     ,  leebndx,lcobndx,leibndx,lmobndx,lpobndx,kcobndx,kmobndx,
     ,  nrgbndt,nznbndt,lcmbndt,lrfbndt,lrrbndt,lrpbndt,lrsbndt,lzrbndt,
     ,  lzpbndt,
     ,  nnrctn,rctngrp,rctnmsp,rctnmst,rctnnmo1,rctnnmo2,rctnnmo3,
     ,  rctnimn,rctniz,rctnimx,nnrctd,rctdgrp,rctdmsp,rctdmst,
     ,  nspcncl,nspcpls,nspcatm,nspcmol,nspcion,spcsmsp,spcsmsa,spcsmsm,
     ,  spcsmsi,spcsncp,spcsnca,spcsncm,spcsnci,spcscgp,spcscga,spcscgm,
     ,  spcscgi,spcsfup,spcsfua,spcsfum,spcsfui,spcsrsp,spcsrsa,spcsrsm,
     ,  spcsrsi,spcsrnp,spcsrna,spcscrk,spcsscn,spcsdlp,spcsfla,spcsflm,
     ,  spcsfli,spcsnsp,spcsnsa,spcsnsm,spcsnsi,spcsnga,spcsngm,spcsngi,
     ,  spcscmm,spcscmi,
     ,  ngpfstr,ingpfstr,kgpfstr,lgpfstr,jgpfstr,mgpfstr,npgpfstr,
     ,  mpgpfstr,nigpfstr,igpfstr,lsgpfstr,
     ,  nrcmstr,lrcmrb,lrcmre,lrcmpb,lrcmpe,nrcmstrs,ircmstrs,lsrcmstr,
     ,  lntspcu,lntsptu,nmcsptu,nlstadu,dgntcpu,dgnptsfc,dgnfile,
     ,  listaddi,ngwtiesi,nsrfclu,msrfclu,lsrfclu,isrfclu,
     ,  ntrgte,jedgep,jedgec,jedgeo,ntrgto,ntrgtm,
     ,  tgrefsw,tgsppsw,tgspcsw,tgsppsp,tgspcgr,tgnhst,tgmhst,tgnini,
     ,  ilplgu,jlplgu,ilplgdg,trirefel,trirefcn,ntriref,
     ,  locphep,lpbihep,lpbohep,lptihep,lptohep,
     ,  j_he_at,j_h_at,j_ne_at,l_h_mol,
     ,  lstclhep,nstclhep,lhetrgts,nhetrgts,
     ,  n_spcsrf,k_spcsrf,sps_sgrp,i_spcsrf,j_spcsrf,l_spcsrf,ll_spcsrf,
     ,  npfrgrp,lpfrgrp,ipfrgrp,jpfrgrp,lm_vhst,lm_whst,
     l  nlrbnds,bliin,bbliin,dfrbndx,glb2read,usetmstr,bxsbndt,rxsbndt,
     ,  rctndflt,tgdtinpt,srcvdflt,do_hepdt,ttcsrc,ttcint,ttchst,ttcref,
     ,  ttcamd,ttcsou,ttcsur,ttcbla,ttcblm,ttcbli,ttcblp,ttcble,
     ,  ttcblph,ttctal,ttcdbg2,ttcdbge,ttcdbgm,ttcdbgf,ttcdbgl,ttcdbgs,
     ,  ttcdbgg,ttcdbgmpi,ttcdbgc,
     ,  ttpl1st,ttpl2nd,ttpladd,ttplhst,ttplcut,ttplnums,tttest,
     ,  lm_cnfg,no_n2,l_ammon,l_meta,
     ,  no_n2_model,ammonx_used,meta_used,is_meta

      common/uinptxt/topo,amd_file,
     ,  spcsncl,spcspls,spcsatm,spcsmol,spcsion,spcsrfp,spcsrfa,spcsrfm,
     ,  spcsrfi,spcsrtp,spcsrta,spcsrtm,spcsrti,
     ,  spcincl,spcipls,spciatm,spcimol,spciion,spcigen,spcirfp,spcirfa,
     ,  spcirfm,spcirfi,spcirtp,spcirta,spcirtm,spcirti,
     ,  spcirnp,spcirna,spcirnm,spcirni,
     ,  spcdgen,spcdspc,spcdrfl,spcdrtl,
     ,  crgbndt,cznbndt,ewmbnds,cskbnds,ctxbnds,ewmbndx,escbndx,eswbndx,
     ,  dscbndx,
     ,  rctntyp,rctndbs,rctnchp,rctnrct,rctnptpr,rctnptin,rctnpto1,
     ,  rctnpto2,rctnpto3,rctneln,
     ,  spcrctd,rctdtyp,rctddbs,rctdchp,rctdrct,rctdptpr,
     ,  rctdptin,rctdpto1,rctdpto2,rctdpto3,rctdeln,
     ,  hlp_h,
     ,  chsptgt,chspspt,made_of,
     ,  crcmstrs,srcmstrs,wrcmstrs,cgpfstrs,sgpfstrs,
     ,  sps_mtrl,sps_id,gpfrgrp,cdnmdlp_sel,
     ,  umtrl
