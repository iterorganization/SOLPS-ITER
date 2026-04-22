      module uinput_mod
      use b2mod_types
#ifdef DIMENSIONS_MODULE
      use b2mod_dimensions
#endif
      use carre_dimensions
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_solps
      implicit none

      public

c*** The basic data for uinput
      integer, private :: i, j

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
      integer, parameter :: nnpr=6, nnptseg=6, ntrgts=4, namdfs=20
      integer, parameter :: nntrian=1
      integer mnpr,mnptseg,npr(nnpr),nptseg(nnptseg),ntrgdflt,namdf
      integer nppol(nregmx),nprad(nregmx),nnreg,
     .        cflags(5,npmamx,nrmamx,nregmx),
     .        fdegen(4,npmamx,nrmamx,nregmx)
      integer ncells,nicells,nbcells,nfaces,ndfaces
      integer carre_mode,grid_mode
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
      parameter (nreac=DEF_NREAC)
      parameter (nchor=250, lntsputx=4, nsrfclsx=12)
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
      integer nncut,nxcut1(nnptseg),nycut2(nnptseg),nx,ny,
     ,        nniso,nxiso1(nxd),nxiso2(nxd),nyiso1(nxd),nyiso2(nxd)
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
      integer nbnddvd,nbndknd,nbndrgn,nbndzon,nbndmrk
      parameter (nbnddvd=400, nbndknd=4, nbndrgn=12,
     ,  nbndzon=20, nbndmrk=100)

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
     ,        jnebnds(nbndzon,nbndknd), rfcbnds(nbndzon,nbndknd)
      real(kind=R4)
     ,        etfbnds(nbndzon,nbndknd), etbbnds(nbndzon,nbndknd),
     ,        easbnds(nbndzon,nbndknd), eewbnds(nbndzon,nbndknd),
     ,        efpbnds(nbndzon,nbndknd), efcbnds(nbndzon,nbndknd),
     ,        esibnds(nbndzon,nbndknd), esebnds(nbndzon,nbndknd),
     ,        rfpbnds(nbndzon,nbndknd)
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
     ,        leibnds(nbndzon,nbndknd), lenkbnds(nbndzon,nbndknd),
     ,        lmobnds(nsdb2,nbndzon,nbndknd),
     ,        lpobnds(nbndzon,nbndknd), lscbnds(natm,nbndzon,nbndknd)
      real(kind=R4)
     ,  beebnds(nbndzon,2,nbndknd),bcobnds(nsdb2,nbndzon,2,nbndknd),
     ,  beibnds(nbndzon,2,nbndknd),bmobnds(nsdb2,nbndzon,2,nbndknd),
     ,  bpobnds(nbndzon,2,nbndknd),benkbnds(nbndzon,2,nbndknd)
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
     ,        jnibndx(0:nbndzon,nbndknd), jnebndx(0:nbndzon,nbndknd),
     ,        rfcbndx(0:nbndzon,nbndknd)
      real(kind=R4)
     ,        etfbndx(0:nbndzon,nbndknd), etbbndx(0:nbndzon,nbndknd),
     ,        easbndx(0:nbndzon,nbndknd), eewbndx(0:nbndzon,nbndknd),
     ,        efpbndx(0:nbndzon,nbndknd), efcbndx(0:nbndzon,nbndknd),
     ,        esibndx(0:nbndzon,nbndknd), esebndx(0:nbndzon,nbndknd),
     ,        rfpbndx(0:nbndzon,nbndknd)
      character*2 ewmbndx(0:nbndzon,nbndknd)*8,
     ,  escbndx(natm,0:nbndzon,nbndknd), eswbndx(natm,0:nbndzon,nbndknd)
      logical dfrbndx(nbndknd)
      integer
     ,  leebndx(0:nbndzon,nbndknd), lcobndx(nsdb2,0:nbndzon,nbndknd),
     ,  leibndx(0:nbndzon,nbndknd), lmobndx(nsdb2,0:nbndzon,nbndknd),
     ,  lpobndx(0:nbndzon,nbndknd), lenkbndx(0:nbndzon,nbndknd)
      real(kind=R4)
     ,  beebndx(0:nbndzon,2,nbndknd),bcobndx(nsdb2,0:nbndzon,2,nbndknd),
     ,  beibndx(0:nbndzon,2,nbndknd),bmobndx(nsdb2,0:nbndzon,2,nbndknd),
     ,  bpobndx(0:nbndzon,2,nbndknd),benkbndx(0:nbndzon,2,nbndknd)
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
     ,  lzrbndt(nbndzon,nbndknd,2),lzpbndt(nbndzon,nbndknd),
     ,  lzrbndt_us(nbndzon,nbndknd,2)
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
     ,  tgnini(ntrgts),trefcell(ntrgts),tgfclbl(ntrgts)
      real(kind=R4)
     ,  tgsppff(ntrgts),tgspcff(ntrgts),tgewall(ntrgts),
     ,  tgabsrp(ntrgts),tgtrnsf(ntrgts),tgtrnsb(ntrgts),
     ,  trfpress(ntrgts)
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
      character*2 rctntyp(mreac),rctneln(mreac)
      character*4 rctnchp(mreac)
      character*6 rctndbs(mreac)
      character*8 rctnptpr(mreac),rctnptin(mreac),
     ,            rctnpto1(mreac),rctnpto2(mreac),rctnpto3(mreac)
      character*9 rctnrct(mreac)
      character*60 rctnbdl(mreac)
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
      character*2 rctdtyp(mreac,nsrctd),rctdeln(mreac,nsrctd)
      character*4 rctdchp(mreac,nsrctd)
      character*6 rctddbs(mreac,nsrctd)
      character*8 rctdptpr(mreac,nsrctd),rctdptin(mreac,nsrctd),
     ,            rctdpto1(mreac,nsrctd),rctdpto2(mreac,nsrctd),
     ,            rctdpto3(mreac,nsrctd)
      character*9 rctdrct(mreac,nsrctd)
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
       integer ntrimax, ntriplgmax, nsegtriplgmax
       parameter (ntrimax=100, ntriplgmax = 20, nsegtriplgmax = 20)
       integer ilplgu(nsts),jlplgu(nlim),ilplgdg(nlim)
       real(kind=R4)
     ,      trisize(0:ntrimax), trixmin(ntrimax), trixmax(ntrimax),
     ,      triymin(ntrimax), triymax(ntrimax)
       integer trirefel(2*nlim),trirefcn(ntrimax),ntriref
       integer ntriplg, nntriplg(ntriplgmax), nsegtriplg(ntriplgmax),
     ,      nnsstriplg(ntriplgmax),nfclbltriplg(ntriplgmax)
       integer triplg(nlim,ntriplgmax),
     ,      triplgnss(2*nsegtriplgmax,ntriplgmax),
     ,      triplgfclbl(2*nsegtriplgmax,ntriplgmax)

c-----------------------------------------------------------------------
c*** Data for pre-defined 'density models' in Eirene:
c*** number of these models and max. length of their names;
c*** names of the models
      integer ndnmdlp,ldnmdlp
      parameter (ndnmdlp=11,ldnmdlp=10)
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
     ,  ttcblp,ttcble,ttcblph,ttctal,ttcoct,ttccen,ttcrnf,ttcsrc,
     ,  ttcdbg2,ttcdbge,ttcdbgm,ttcdbgf,
     ,  ttcdbgl,ttcdbgs,ttcdbgg,ttcdbgmpi,ttcdbgc,ttchktim,ttcscl,
     ,  ttpl1st,ttpl2nd,ttpladd,ttplhst,ttplcut(3),ttplnums,tttest,
     ,  ttplspec,ttprspec,ttplargl,ttprargl,ttlsprcl

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
c*** Limiter and linear configurations - cheating:
      logical lm_cnfg, ln_cnfg
      integer lm_vhst, lm_whst

c-----------------------------------------------------------------------
c*** Wall material data
      character*8 umtrl(nlim)

c=======================================================================
c*** Standard set of input data for eirene - and some other data
c=======================================================================

      integer ngwtiesx
      parameter (ngwtiesx=2*n2nd)
      integer cbnrmx
      parameter (cbnrmx=6+2+1+1)
      integer, parameter :: lurpst=n1st*nplg, luznknd=nbndzon*nbndknd,
     ,  lulim2=nlim*nlim,
     ,  lu9=9*nlim,         lustsr=nsrfs*nstra, luatsr=natm*nstra,
     ,  lunplt=nptal*nplt,  lu21pr=2*nppart,lvrctd=mreac*nsrctd,
     ,  lu3st=3*n1st,       lugwts=mgwtiesx*ngwtiesx, lusts3=3*lustsr,
     ,  lupw=nlimps*npwinx, lusg=nstep*ngitt, nchor2=nchor*nchor,
     ,  lur9=9*mreac, lur6=6*mreac, luml=3*nmol,
     ,  lcbs=8*nsdb2*cbnrmx, lcbe=8*cbnrmx, lcfs=8*nsdb2

c=======================================================================
c*** General information

      data   topo, mnpr,mnptseg,mdvbndx,  ldvbndx  ,ntrgdflt,do_hepdt /
     /        ' ',  0  ,   0   ,   0   ,0,nbnddvd*0,    0   , .false. /,
     ,  namdf,amd_file ,nnrctn,n_spcsrf,npfrgrp,lm_cnfg,ln_cnfg /
     /    0  ,namdfs*' ',   0  ,   0    ,   0  ,.false.,.false. /,
     , lm_vhst,lm_whst,   niiso   , tiiso, teiso/
     /  10000 , 50000 , nsdb2*1.e5,  0.1 ,  0.1 /,
     , zaator, roator,nttrator /
     /  360. ,  1.e-5,   60    /,
     , nwllmrk, nedgmrk  , ntrgmrk  ,   bliin    ,    bbliin      /
     /    0   ,nwllmrkd*0,nwllmrkd*0,nsts*.false.,luznknd*.false. /,
     , glb2read,usetmstr,pwrcrtte,pwrcrtti,pwrcrfri /
     /  .false., .false.,  50.   ,    50. ,   0.25  /,
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
     /    2, 1, -3, -3    ,     nbndknd*6    /,
     ,  (jrfbndx(0,i),i=1,nbndknd), (jcsbndx(0,i),i=1,nbndknd) /
     /     0,  3*1    ,    0, 1, 0, 0        /,
     ,  (jcgbndx(0,i),i=1,nbndknd), (jpsbndx(0,i),i=1,nbndknd) /
     /    nbndknd*0   ,    0, 2, 0, 0        /,
     ,  (jppbndx(0,i),i=1,nbndknd), (etfbndx(0,i),i=1,nbndknd) /
     /    nbndknd*0   ,     nbndknd*0.       /,
     ,  (etbbndx(0,i),i=1,nbndknd), (easbndx(0,i),i=1,nbndknd) /
     /    nbndknd*0.    ,     nbndknd*0.     /,
     ,  (eewbndx(0,i),i=1,nbndknd), (efpbndx(0,i),i=1,nbndknd) /
     /    nbndknd*-0.1    ,   nbndknd*1.     /,
     ,  (efcbndx(0,i),i=1,nbndknd), (ewmbndx(0,i),i=1,nbndknd) /
     /    nbndknd*1.    ,    nbndknd*'C'     /,
     ,  (rfcbndx(0,i),i=1,nbndknd), (rfpbndx(0,i),i=1,nbndknd) /
     /    nbndknd*0     ,    nbndknd*0.      /,
     ,  (nlrbndx(0,i),i=1,nbndknd),  (jnpbndx(0,i),i=1,nbndknd)/
     /      0, 3*1    ,       2000,25000,2*2000    /,
     ,  (jmpbndx(0,i),i=1,nbndknd)/
     /       nbndknd*0            /,
     ,  (jnibndx(0,i),i=1,nbndknd),  (jnebndx(0,i),i=1,nbndknd)/
     /      4*10001     ,         6, 7, 6, 6       /,
     ,  (leebndx(0,i),i=1,nbndknd), (leibndx(0,i),i=1,nbndknd) /
     /         8,15, 9, 9   ,    8,15, 9, 9        /,
     ,  (lenkbndx(0,i),i=1,nbndknd), (lpobndx(0,i),i=1,nbndknd)/
     /        16,15,14,14   ,   12,11,13,13         /,
     ,  ((lcobndx(j,0,i),j=1,nsdb2),i=1,nbndknd) /
     /    nsdb2*1, nsdb2*3, nsdb2*9, nsdb2*9        /,
     ,  ((lmobndx(j,0,i),j=1,nsdb2),i=1,nbndknd) /
     /    nsdb2*2, nsdb2*3, nsdb2*2, nsdb2*2        /,
     ,  (beebndx(0,1,i),i=1,nbndknd), (beibndx(0,1,i),i=1,nbndknd)  /
     /         1.e6, 0., 2*0.03     ,      1.e6, 1.5, 2*0.03        /,
     ,  (beebndx(0,2,i),i=1,nbndknd), (beibndx(0,2,i),i=1,nbndknd)  /
     /            4*0.              ,           4*0.                /,
     ,  (bpobndx(0,1,i),i=1,nbndknd), (bpobndx(0,2,i),i=1,nbndknd)  /
     /            4*0.              ,           4*0.                /,
     ,  (benkbndx(0,1,i),i=1,nbndknd), (benkbndx(0,2,i),i=1,nbndknd) /
     /         0.1, 1.0, 2*-1.0e-3  ,           4*0.                /,
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
     ,  4*1,    7*8, nspdgen*14, nspdgen*9, nspdgen*9,
     ,  4*1,8,1,5*8, nspdgen*14, nspdgen*9, nspdgen*9 /
      data kmobndx / nspdgen*2, nspdgen*13, nspdgen*2, nspdgen*2,
     ,               nspdgen*2, nspdgen*13, nspdgen*2, nspdgen*2 /
      data    ((dcobndx(j,1,i,1),j=1,nspdgen),i=1,nbndknd)   /
     /      3*3.e19,8*0., nspdgen*1., nspdgen*0.03,
     ,                                          nspdgen*0.03 /,
     ,        ((dcobndx(j,2,i,1),j=1,nspdgen),i=1,nbndknd) /
     /      nspdgen*0., nspdgen*0., nspdgen*0., nspdgen*0. /,
     ,        ((dmobndx(j,1,i,1),j=1,nspdgen),i=1,nbndknd) /
     /      nspdgen*0., nspdgen*1., nspdgen*0., nspdgen*0. /,
     ,        ((dmobndx(j,2,i,1),j=1,nspdgen),i=1,nbndknd) /
     /      nspdgen*0., nspdgen*0., nspdgen*0., nspdgen*0. /
      data    ((dcobndx(j,1,i,2),j=1,nspdgen),i=1,nbndknd) /
     /      3*3.e19,2.e18,7*0.,
     ,                nspdgen*1.,nspdgen*0.03,nspdgen*0.03 /,
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
     /     0    ,   3*0  ,    0   ,  luml*0 /,
     ,  pwrhepdt,pmphepdt,nstclhep,nhetrgts/
     /    570.  ,   0.8  ,    0   ,   0    /

c*** Data for TRIA mesh
      data ilplgdg,ntriref /
     /      nlim*0,   0    /

c*** 0: additional data for uinout control
c*** Temporary - max. number of reactions in cdenmodel section
      integer nrcdn
      parameter (nrcdn=1)

c*** 1
      integer nprll,nmode,ntcpu,nfile,niter0,niter,ntime0,ntim1,
     ,        nevntmax,nvnmxtr
      integer noptim,noptm1,ngeom_usr,ncoup_input,nsmstra,
     ,        nstoram,ngstal,nrtal1,nreac_add,lfrm15
      logical nlscl,nltest,nlana,nldrft,nlcrr,nlerg,nlident,nlone,
     ,        nlmovie,nldfst,nlranmar,nlcascad,nloctree,nlwrmsh,
     ,        nexvs,nltrimesh,nlsoledge,nlspcspt
      character txtrun*71

      data nprll, nmode , ntcpu, nfile, niter0, niter, ntime0, ntim1 /
     /      -1  ,   1   ,  50  , 5000 ,   1   ,   1  ,   0   ,   1   /,
     ,  nevntmax, noptim,noptm1, ngeom_usr, ncoup_input, nsmstra /
     /       0  ,   1   ,   1  ,     0    ,     1      ,    1    /,
     ,   nstoram, ngstal,nrtal1, nvnmxtr /
     /       9  ,   1   ,   0  ,     0   /
      data nlscl , nltest, nlana ,nldrft, nlcrr , nlerg , nlident/
     /    .true. ,.false.,.false.,.true.,.false.,.false.,.false./,
     ,     nlone ,nlmovie, nldfst,nlranmar,nlcascad,nloctree/
     /    .false.,.false.,.false., .true. , .false., .false./,
     /    nlwrmsh, nexvs ,nltrimesh,nlsoledge,nlspcspt/
     ,    .true. ,.false.,.false., .true. , .false./
      data  txtrun / ' EIRENE input file generated with uinp v. 2.2' /

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
     /      .true.,.false.,.false.,.false.,.false.,.false./,
     ,      nlfem , nltet , nlgen /
     /     .true. ,.false.,.false./,
     ,      nlpol , nlply , nlpla , nlplp , nltor /
     /      .true.,.false.,.false.,.false.,.false./,
     ,      nltrz , nltra , nltrt , nlmlt , nladd /
     /      .true.,.false.,.false.,.false., .true./

c*** 3a

      integer nstsi,    idimp(nsts),  inump(nsts),  irpta1(nsts),
     ,    irpte1(nsts), irpta2(nsts), irpte2(nsts), irpta3(nsts),
     ,    ifclbla(nsts),ifclble(nsts),
     ,    irpte3(nsts), iliin(nsts),  ilside(nsts), ilswch(nsts),
     ,    ilequi(nsts), iltor(nsts),  ilcol(nsts),  ilfit(nsts),
     ,    ilcell(nsts), ilbox(nsts),  ilplg(nsts),  ilref(nsts),
     ,    ilsptp(nsts), ilsptc(nsts), isrss(nsts),  isrc(nsts),
     ,    lchspnws(nsts),isrsg(nsts), arefcell(nsts)
      real xmlim(nsts), ewall(nsts),  ewbin(nsts),  transp(nsts,2),
     ,    recycc(nsts), recycf(nsts), recyct(nsts), recprm(nsts),
     ,    recycs(nsts), exppl(nsts),  expel(nsts),  expil(nsts),
     ,    fsheat(nsts), echspts(nsts),fchspts(nsts),sptprm(nsts),
     ,    arfpress(nsts)
      character txtsfl(nsts)*64

      data  nstsi , idimp , inump , irpta1, irpte1,  iliin , ilside /
     /        0   , nsts*2, nsts*1, nsts*1, nsts*1, nsts*-1, nsts*0 /,
     ,      ilswch, ilequi, ilcol , irpta2, irpte2, irpta3, irpte3 /
     /      nsts*0, nsts*0, nsts*6, nsts*0, nsts*0, nsts*0, nsts*0 /,
     ,      ifclbla, ifclble /
     /      nsts*0 , nsts*0  /,
     ,     iltor  , ilfit , ilplg , ilbox , ilcell/
     /     nsts*0 , nsts*0, nsts*0, nsts*0, nsts*0/,
     ,     ilref  , ilsptp, ilsptc, isrss ,  isrc ,lchspnws, isrsg  /
     /     nsts*1 , nsts*0, nsts*0, nsts*0, nsts*0, nsts*0 , nsts*0 /,
     ,    arefcell/
     /     nsts*0 /
      data  xmlim   ,   ewall   ,  ewbin ,    transp     , fsheat /
     /    nsts*1206., nsts*0.087, nsts*0.,nsts*0.,nsts*0.,nsts*-1./,
     ,     recycf , recyct , recprm , recycs ,  exppl ,  expel    /
     /     nsts*1., nsts*1., nsts*0., nsts*0., nsts*1., nsts*0.5  /,
     ,      expil , recycc , echspts, fchspts, sptprm , arfpress  /
     /     nsts*1.,nsts*0.01,nsts*0., nsts*0., nsts*0.,  nsts*0.  /
      data  ctxbnds / 'Core side','Target','PFR side','Outer side'/
      data tgdtinpt / .false. /

c*** 3b

      integer nlimi,    itend(nlim),  itini(nlim), jliin(nlim),
     ,    jlside(nlim), jlequi(nlim), jltor(nlim), jlcol(nlim),
     ,    jlfit(nlim),  jlbox(nlim),  jlref(nlim), jlsptp(nlim),
     ,    jlsptc(nlim), jsrss(nlim),  jsrc(nlim),  lchspnwa(nlim),
     ,    jsrsg(nlim),  jlplg(nlim),  fclbl(nlim), omp_elm, imp_elm
      integer jadch0(nlim), jadch1(nlim,nlim), jadnsw(nlim),
     ,    jadmsw(nlim), jadlsw(nlim), jadksw(nlim), jadjsw(nlim),
     ,    jadisw(nlim), jlblck(nlim), jlacll(nlim), refcell(nlim)
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
     ,     ylrot(nlim), zlrot(nlim), alrot(nlim), fsheata(nlim),
     ,     refpress(nlim)
      character txtsfa(nlim)*64

      data laddsrfs, indasrfs, indasrfe / 0, 0, nlim*0, 0, nlim*0 /
      data nlimi, jadch0,  jadch1 , jadnsw, jadmsw, jadlsw, jadksw /
     /       0  , nlim*0, lulim2*0, nlim*0, nlim*0, nlim*0, nlim*0 /,
     ,    jadjsw, jadisw, jlblck, jlacll,  jliin, jlside /
     /    nlim*0, nlim*0, nlim*0, nlim*0, nlim*1, nlim*0 /,
     ,    jlequi,  jltor,  jlcol, jlfit,   jlbox, jlplg /
     ,    nlim*0, nlim*0, nlim*0, nlim*0, nlim*0, nlim*0 /,
     ,     jlref, jlsptp, jlsptc,  jsrss,  jsrc, lchspnwa, jsrsg /
     /    nlim*1, nlim*0, nlim*0, nlim*0, nlim*0, nlim*0, nlim*0 /,
     ,     itini,  itend,refcell,  fclbl /
     /   nlim*-1, nlim*0, nlim*0, nlim*0 /
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
     /    nlim*0.,nlim*0.,nlim*0.,nlim*0.,nlim*0.,nlim*0.,nlim*0./,
     ,   refpress /
     /    nlim*0. /
      data txtsfa / nlim*' ' /

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
     ,    crc(mreac)*3,elname(mreac)*2,bundling(mreac)*60

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

      data nreaci,nrcln,  ir   , massp , masst ,  iz    /
     /        0  ,  0  ,mreac*0,mreac*0,mreac*0,mreac*1 /
      data ifex1mn,ifex1mx,ifex2mn,ifex2mx /
     /     mreac*0,mreac*0,mreac*0,mreac*0 /
      data delpot,  rc1mn ,  rc1mx ,  rc2mn ,  rc2mx ,  fp1  ,  fp2   /
     /    mreac*0.,mreac*0.,mreac*0.,mreac*0.,mreac*0.,lur6*0.,lur6*0./
      data creac / lur9*0. /
      data lconst / mreac*.false. /
      data filnam ,    h123  ,   reac  ,   crc   , elname  , bundling /
     /    mreac*' ',mreac*' ',mreac*' ',mreac*' ',mreac*' ', mreac*' '/

      data rctndflt / .true. /,
     ,  rctntyp , rctndbs , rctnchp , rctnrct , rctnptpr, rctnptin /
     / mreac*' ',mreac*' ',mreac*' ',mreac*' ',mreac*' ',mreac*' ' /,
     ,  rctnpto1, rctnpto2, rctnpto3, rctnbdl /
     / mreac*' ',mreac*' ',mreac*' ',mreac*' '/,
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
     ,  lurctdh=4, lurctdh2=7,lurctdhe=6,lurctdc=4, lurctdne=2,
     ,  lurctdhp=2,lurctdar=2,lurctdn=2, lurctdbe=2,lurctdh2p=4,
     ,  lurctdnp=2,lurctdcp=2,lurctdx=2, lurctdxp=2
      data  nnrctd / lurctdh, lurctdh2,lurctdhe,lurctdc, lurctdne,
     /               lurctdhp,lurctdar,lurctdn, lurctdbe,lurctdh2p,
     /               lurctdnp,lurctdcp,lurctdx, lurctdxp/
      data (rctdtyp(i,1),i=1,lurctdh)  / 2*'EI', 2*'CX' /
      data (rctdtyp(i,2),i=1,lurctdh2) / 'EI', 2*'DS', 3*'EL', 'CX' /
      data (rctdtyp(i,3),i=1,lurctdhe) / 2*'EI', 4*'CX' /
      data (rctdtyp(i,4),i=1,lurctdc)  / 2*'EI', 2*'CX' /
      data (rctdtyp(i,5),i=1,lurctdne) / 2*'EI' /
      data (rctdtyp(i,6),i=1,lurctdhp) / 2*'RC' /
      data (rctdtyp(i,7),i=1,lurctdar) / 2*'EI' /
      data (rctdtyp(i,8),i=1,lurctdn)  / 2*'EI' /
      data (rctdtyp(i,9),i=1,lurctdbe) / 2*'EI' /
      data (rctdtyp(i,10),i=1,lurctdh2p) / 'DS','EI',2*'DS' /
      data (rctdtyp(i,11),i=1,lurctdnp) / 2*'RC' /
      data (rctdtyp(i,12),i=1,lurctdcp) / 2*'RC' /
      data (rctdtyp(i,13),i=1,lurctdx) / 2*'EI' /
      data (rctdtyp(i,14),i=1,lurctdxp) / 2*'RC' /
      data (rctddbs(i,1),i=1,lurctdh)  / 2*'AMJUEL', 2*'HYDHEL' /
      data (rctddbs(i,2),i=1,lurctdh2) / 7*'AMJUEL' /
      data (rctddbs(i,3),i=1,lurctdhe) / 2*'ADAS', 4*'HYDHEL' /
      data (rctddbs(i,4),i=1,lurctdc)  / 2*'AMJUEL', 2*'METHAN' /
      data (rctddbs(i,5),i=1,lurctdne) / 2*'ADAS' /
      data (rctddbs(i,6),i=1,lurctdhp) / 2*'AMJUEL' /
      data (rctddbs(i,7),i=1,lurctdar) / 2*'ADAS' /
      data (rctddbs(i,8),i=1,lurctdn)  / 2*'AMJUEL' /
      data (rctddbs(i,9),i=1,lurctdbe) / 2*'AMJUEL' /
      data (rctddbs(i,10),i=1,lurctdh2p) / 4*'AMJUEL' /
      data (rctddbs(i,11),i=1,lurctdnp) / 2*'ADAS' /
      data (rctddbs(i,12),i=1,lurctdcp) / 2*'ADAS' /
      data (rctddbs(i,13),i=1,lurctdx)  / 2*'ADAS' /
      data (rctddbs(i,14),i=1,lurctdxp) / 2*'ADAS' /
      data (rctdchp(i,1),i=1,lurctdh)  / 'H.4','H.10', 'H.1', 'H.3' /
      data (rctdchp(i,2),i=1,lurctdh2)
     .                        / 3*'H.4', 'H.0', 'H.1', 'H.3', 'H.2' /
      data (rctdchp(i,3),i=1,lurctdhe)
     .                  / 'H.4', 'H.10', 'H.1', 'H.3', 'H.1', 'H.3' /
      data (rctdchp(i,4),i=1,lurctdc)  / 'H.4','H.10', 'H.1', 'H.3' /
      data (rctdchp(i,5),i=1,lurctdne) / 'H.4','H.10' /
      data (rctdchp(i,6),i=1,lurctdhp) / 'H.4','H.10' /
      data (rctdchp(i,7),i=1,lurctdar) / 'H.4','H.10' /
      data (rctdchp(i,8),i=1,lurctdn)  / 'H.4','H.10' /
      data (rctdchp(i,9),i=1,lurctdbe) / 'H.2','H.8' /
      data (rctdchp(i,10),i=1,lurctdh2p) / 3*'H.4', 'H.8' /
      data (rctdchp(i,11),i=1,lurctdnp) / 'H.4','H.10' /
      data (rctdchp(i,12),i=1,lurctdcp) / 'H.4','H.10' /
      data (rctdchp(i,13),i=1,lurctdx)  / 'H.4','H.10' /
      data (rctdchp(i,14),i=1,lurctdxp) / 'H.4','H.10' /
      data (rctdrct(i,1),i=1,lurctdh)  / 2*'2.1.5', 2*'3.1.8' /
      data (rctdrct(i,2),i=1,lurctdh2)
     .              / '2.2.9', '2.2.5g', '2.2.10', 3*'0.3T', '3.2.3' /
      data (rctdrct(i,3),i=1,lurctdhe)
     .              / 'scd', 'plt', 2*'5.3.1', 2*'6.3.1' /
      data (rctdrct(i,4),i=1,lurctdc)  / 2*'2.6A0', 2*'3.2' /
      data (rctdrct(i,5),i=1,lurctdne) / 'scd', 'plt' /
      data (rctdrct(i,6),i=1,lurctdhp) / 2*'2.1.8' /
      data (rctdrct(i,7),i=1,lurctdar) / 'scd', 'plt' /
      data (rctdrct(i,8),i=1,lurctdn)  / 2*'2.7A0' /
      data (rctdrct(i,9),i=1,lurctdbe) / 2*'2.4B0' /
      data (rctdrct(i,10),i=1,lurctdh2p)
     .                        / '2.2.12', '2.2.11', 2*'2.2.14' /
      data (rctdrct(i,11),i=1,lurctdnp) / 'acd', 'prb' /
      data (rctdrct(i,12),i=1,lurctdcp) / 'acd', 'prb' /
      data (rctdrct(i,13),i=1,lurctdx)  / 'scd', 'plt' /
      data (rctdrct(i,14),i=1,lurctdxp) / 'acd', 'prb' /
      data (rctdptin(i,1),i=1,lurctdh)  / 2*' ', 2*'H+' /
      data (rctdptin(i,2),i=1,lurctdh2) / 3*' ', 4*'H+' /
      data (rctdptin(i,3),i=1,lurctdhe) / 2*' ', 2*'He+', 2*'He++' /
      data (rctdptin(i,4),i=1,lurctdc)  / 2*' ', 2*'H+' /
      data (rctdptin(i,5),i=1,lurctdne) / 2*' ' /
      data (rctdptin(i,6),i=1,lurctdhp) / 2*' ' /
      data (rctdptin(i,7),i=1,lurctdar) / 2*' ' /
      data (rctdptin(i,8),i=1,lurctdn)  / 2*' ' /
      data (rctdptin(i,9),i=1,lurctdbe) / 2*' ' /
      data (rctdptin(i,10),i=1,lurctdh2p) / 4*' ' /
      data (rctdptin(i,11),i=1,lurctdnp) / 2*' ' /
      data (rctdptin(i,12),i=1,lurctdcp) / 2*' ' /
      data (rctdptin(i,13),i=1,lurctdx)  / 2*' ' /
      data (rctdptin(i,14),i=1,lurctdxp) / 2*' ' /
      data (rctdpto1(i,1),i=1,lurctdh)  / 2*'H+', 2*'H' /
      data (rctdpto1(i,2),i=1,lurctdh2)
     .                           / 'H2+', '2H', 'H', 3*'H+', 'H' /
      data (rctdpto1(i,3),i=1,lurctdhe) / 2*'He+', 4*'He' /
      data (rctdpto1(i,4),i=1,lurctdc)  / 2*'C+', 2*'H' /
      data (rctdpto1(i,5),i=1,lurctdne) / 2*'Ne+' /
      data (rctdpto1(i,6),i=1,lurctdhp) / 2*'H' /
      data (rctdpto1(i,7),i=1,lurctdar) / 2*'Ar+' /
      data (rctdpto1(i,8),i=1,lurctdn)  / 2*'N+' /
      data (rctdpto1(i,9),i=1,lurctdbe) / 2*'Be+' /
      data (rctdpto1(i,10),i=1,lurctdh2p) / 'H', '2H+', '2H', '2H' /
      data (rctdpto1(i,11),i=1,lurctdnp) / 2*'N' /
      data (rctdpto1(i,12),i=1,lurctdcp) / 2*'C' /
      data (rctdpto1(i,13),i=1,lurctdx)  / 2*'X+' /
      data (rctdpto1(i,14),i=1,lurctdxp) / 2*'X' /
      data (rctdpto2(i,1),i=1,lurctdh)  / 2*' ', 2*'H+' /
      data (rctdpto2(i,2),i=1,lurctdh2) / 2*' ', 'H+', 3*'H2', 'H2+' /
      data (rctdpto2(i,3),i=1,lurctdhe) / 2*' ', 2*'He+', 2*'He++' /
      data (rctdpto2(i,4),i=1,lurctdc)  / 2*' ', 2*'C+' /
      data (rctdpto2(i,5),i=1,lurctdne) / 2*' ' /
      data (rctdpto2(i,6),i=1,lurctdhp) / 2*' ' /
      data (rctdpto2(i,7),i=1,lurctdar) / 2*' ' /
      data (rctdpto2(i,8),i=1,lurctdn)  / 2*' ' /
      data (rctdpto2(i,9),i=1,lurctdbe) / 2*' ' /
      data (rctdpto2(i,10),i=1,lurctdh2p) / 'H+', 3*' ' /
      data (rctdpto2(i,11),i=1,lurctdnp) / 2*' ' /
      data (rctdpto2(i,12),i=1,lurctdcp) / 2*' ' /
      data (rctdpto2(i,13),i=1,lurctdx)  / 2*' ' /
      data (rctdpto2(i,14),i=1,lurctdxp) / 2*' ' /
      data (rctdpto3(i,1),i=1,lurctdh)  / lurctdh*' ' /
      data (rctdpto3(i,2),i=1,lurctdh2) / lurctdh2*' ' /
      data (rctdpto3(i,3),i=1,lurctdhe) / lurctdhe*' ' /
      data (rctdpto3(i,4),i=1,lurctdc)  / lurctdc*' ' /
      data (rctdpto3(i,5),i=1,lurctdne) / lurctdne*' ' /
      data (rctdpto3(i,6),i=1,lurctdhp) / lurctdhp*' ' /
      data (rctdpto3(i,7),i=1,lurctdar) / lurctdar*' ' /
      data (rctdpto3(i,8),i=1,lurctdn)  / lurctdn*' ' /
      data (rctdpto3(i,9),i=1,lurctdbe) / lurctdbe*' ' /
      data (rctdpto3(i,10),i=1,lurctdh2p) / lurctdh2p*' ' /
      data (rctdpto3(i,11),i=1,lurctdnp) / lurctdnp*' ' /
      data (rctdpto3(i,12),i=1,lurctdcp) / lurctdcp*' ' /
      data (rctdpto3(i,13),i=1,lurctdx)  / lurctdx*' ' /
      data (rctdpto3(i,14),i=1,lurctdxp) / lurctdxp*' ' /
      data (rctdgrp(i,1),i=1,lurctdh)  / 2*-1, 2*-2 /
      data (rctdgrp(i,2),i=1,lurctdh2) / 3*0, 3*-5, 0 /
      data (rctdgrp(i,3),i=1,lurctdhe) / 2*-9, 2*-6, 2*-8 /
      data (rctdgrp(i,4),i=1,lurctdc)  / 2*-10, 2*-11 /
      data (rctdgrp(i,5),i=1,lurctdne) / 2*-17 /
      data (rctdgrp(i,6),i=1,lurctdhp) / 2*-3 /
      data (rctdgrp(i,7),i=1,lurctdar) / 2*-18 /
      data (rctdgrp(i,8),i=1,lurctdn)  / 2*-12 /
      data (rctdgrp(i,9),i=1,lurctdbe) / 2*-7 /
      data (rctdgrp(i,10),i=1,lurctdh2p) / 2*0, 2*-4 /
      data (rctdgrp(i,11),i=1,lurctdnp) / 2*-14 /
      data (rctdgrp(i,12),i=1,lurctdcp) / 2*-13 /
      data (rctdgrp(i,13),i=1,lurctdx)  / 2*-15 /
      data (rctdgrp(i,14),i=1,lurctdxp) / 2*-16 /
      data (rctdmsp(i,1),i=1,lurctdh)  / 2*0, 2*1 /
      data (rctdmsp(i,2),i=1,lurctdh2) / 3*0, 4*1 /
      data (rctdmsp(i,3),i=1,lurctdhe) / 2*0, 4*4 /
      data (rctdmsp(i,4),i=1,lurctdc)  / 2*0, 2*1 /
      data (rctdmsp(i,5),i=1,lurctdne) / 2*0 /
      data (rctdmsp(i,6),i=1,lurctdhp) / 2*0 /
      data (rctdmsp(i,7),i=1,lurctdar) / 2*0 /
      data (rctdmsp(i,8),i=1,lurctdn)  / 2*0 /
      data (rctdmsp(i,9),i=1,lurctdbe) / 2*0 /
      data (rctdmsp(i,10),i=1,lurctdh2p) / 4*0 /
      data (rctdmsp(i,11),i=1,lurctdnp) / 2*0 /
      data (rctdmsp(i,12),i=1,lurctdcp) / 2*0 /
      data (rctdmsp(i,13),i=1,lurctdx)  / 2*0 /
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
      data (rctdmst(i,13),i=1,lurctdx)  / lurctdx*-1 /
      data (rctdmst(i,14),i=1,lurctdxp) / lurctdxp*-1 /
      data (rctddlte(i,1),i=1,lurctdh)  / 4*0.0 /
      data (rctddlte(i,2),i=1,lurctdh2) / 15.4, 10.5, 25.0, 4*0.0 /
      data (rctddlte(i,3),i=1,lurctdhe) / 0.0,-24.5874, 4*0.0 /
      data (rctddlte(i,4),i=1,lurctdc)  / 4*0.0 /
      data (rctddlte(i,5),i=1,lurctdne) / 0.0,-21.5645 /
      data (rctddlte(i,6),i=1,lurctdhp) / 0.0, 13.6 /
      data (rctddlte(i,7),i=1,lurctdar) / 0.0,-15.7596 /
      data (rctddlte(i,8),i=1,lurctdn)  / 2*0.0 /
      data (rctddlte(i,9),i=1,lurctdbe) / 2*0.0 /
      data (rctddlte(i,10),i=1,lurctdh2p) / 10.4, 15.5, 0.0, 0.0 /
      data (rctddlte(i,11),i=1,lurctdnp) / 0.0, 14.5341 /
      data (rctddlte(i,12),i=1,lurctdcp) / 0.0, 11.2603 /
      data (rctddlte(i,13),i=1,lurctdx) / 2*0.0 /
      data (rctddlte(i,14),i=1,lurctdxp) / 0.0, -1.0 /
      data (rctdenr1(i,1),i=1,mreac)    / mreac*0 /
      data (rctdenr1(i,2),i=1,lurctdh2) / 0.0, 3.0, 5.0, 4*0 /
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

      integer nplsi,nplsh,nbgk,
     ,  nmassp(npls),ncharp(npls),nprtp(npls),nchrgp(npls),
     ,  isrfp(npls),isrtp(npls),nmsecp(npls),nrcp(npls),idnslmp(npls),
     ,  nmassph(npls),isrfph(npls),isrtph(npls),
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
     ,     zi0(npls), zi1(npls), zi2(npls), zi3(npls), zi4(npls),
     ,     zi5(npls),
     ,     b0, b1, b2, b3, b4, b5, vl0, vl1, vl2, vl3, vl4, vl5
      character textp(npls)*8, textph(npls)*8

      integer lurp,lurc,lup5,lup6
      parameter (lurp=nreac*npls, lurc=nrcdn*npls)
      parameter (lup5=5*npls, lup6=6*npls)
      data nplsi / 0 /
      data nplsh / 0 / !nh neutral background species for the hybrid model
      data nbgk / 0 /
      data nmassp,ncharp, nprtp,nchrgp, isrfp, isrtp,nmsecp, nrcp  /
     /     npls*0,npls*0,npls*0,npls*0,npls*0,npls*0,npls*0,npls*0 /,
     ,    idnslmp, nfolp, ngenp,nhstp /
     /     npls*0,npls*0,npls*0,npls*0 /,
     ,     ireacp,ibulkp,iscd1p,iscd2p,iscd3p,iscd4p,iscdep /
     /     lurp*0,lurp*0,lurp*0,lurp*0,lurp*0,lurp*0,lurp*0 /
      data nmassph, isrfph, isrtph /
     /     npls*0 ,npls*0 , npls*0 /
      data eelecp, ebulkp, escd1p, escd2p, freacp /
     /    lurp*0.,lurp*0.,lurp*0.,lurp*0.,lurp*0. /
      data textp / npls*' ' /
      data textph / npls*' ' /
      data cdnmdlp_sel/
     /   'FORT.13', 'FTN13', 'FORT.10', 'FTN10',
     /   'CONSTANT','PLANCK','MULTIPLY','SAHA','BOLTZMANN','CORONA',
     /   'COLRAD'/
      data cdnmdlp / npls*' ' /
      data nrep, ispcdn, itpcdn, istrcdn /
     /    npls*0, lurc*0, lurc*4, lurc*0 /
      data valcdn,bltzcdn,dltecdn,acrncdn/
     /    lup5*0.,npls*0.,npls*0.,npls*0./
      data fnamcdn, h2cdn  , reaccdn, crcdn   /
     /    lurc*' ',lurc*' ',lurc*' ',lurc*' ' /

      data indpro / 6*6, 4*0, 9, 0 /
      data te0,te1,te2,te3,te4,te5 / 6*0./
      data ti0,ti1,ti2,ti3,ti4,ti5 / lup6*0./
      data di0,di1,di2,di3,di4,di5 / lup6*0./
      data vx0,vx1,vx2,vx3,vx4,vx5 / lup6*0./
      data vy0,vy1,vy2,vy3,vy4,vy5 / lup6*0./
      data vz0,vz1,vz2,vz3,vz4,vz5 / lup6*0./
      data zi0,zi1,zi2,zi3,zi4,zi5 / lup6*0./
      data b0,b1,b2,b3,b4,b5       / 6*0./
      data vl0,vl1,vl2,vl3,vl4,vl5 / 6*0./

c*** 6

      integer luftrm
      parameter (luftrm=1)
      integer nnftrm, nchsppri,
     ,     lchsptrg(nchsppr), lchspgrp(nchsppr),
     ,     lchspprt(nchsppr), lchspprp(nchsppr), lchsptgt(nchsppr),
     ,     lchsptgp(nchsppr), lchspnwl(nchsppr), lchspaux(5,nchsppr)
      real datm(natm), dmol(nmol), dion(nion), dpls(npls), dplsh(npls),
     ,     ermin, ercut, rprob0, rinteg, einteg, ainteg,
     ,     ychsptg(nchsppr), echsptg(nchsppr), fchsptg(nchsppr),
     ,     achsptg(3,nchsppr)
      logical nltrim
      character*8 filtrm(nhd6),path*60

c*** Surface Cards
      integer maxsc,nscards
      parameter (maxsc=100)
      character*(72) scard_name(maxsc)
      integer scilref(maxsc),scilspt(maxsc),scisrs(maxsc),
     ,       scisrc(maxsc),sclchspnwl(maxsc),scisrsg(maxsc),
     ,       screfcell(maxsc)
      real scxmlim(maxsc),scewall(maxsc),scewbin(maxsc),
     ,  sctransp(maxsc,2),scfsheat(maxsc),screcycf(maxsc),
     ,  screcyct(maxsc),scrcprm(maxsc),scexppl(maxsc),scexpel(maxsc),
     ,  scexpil(maxsc),screcycs(maxsc),scychsptg(maxsc),
     ,  scechsptg(maxsc),scfchsptg(maxsc),scstprm(maxsc),
     ,  screfpress(maxsc)
      integer iscrd(nsts),jscrd(nlim)
      integer maxchmvar,maxchsc,nchemvar
      parameter (maxchmvar=nlim,maxchsc=nlim*(natm+nmol+nion+npht+npls))
      integer nnchemvar(maxsc),indchemvar(maxchsc)
      character*8 chvarname(maxchsc),chmspname(maxchsc)
      real chmvar(maxchsc)

      integer luchsi,luchsr,lvchsi,lvchsr
      parameter (luchsi=5, luchsr=3)
      parameter (lvchsi=luchsi*nchsppr, lvchsr=luchsr*nchsppr)
      data nltrim / .true. /
      data path / 'modules/Eirene/Database/Surfacedata/TRIM/' /
      data (filtrm(i),i=1,luftrm) / 'D_on_C' /
      data nnftrm / luftrm /, nchsppri / 0 /
      data lchspgrp, lchsptgt, lchspnwl, lchspaux /
     /    nchsppr*0,nchsppr*1,nchsppr*0, lvchsi*0 /
      data datm    ,  dmol   ,  dion   ,  dpls  ,   ermin  ,  ercut   /
     /     natm*0. , nmol*0. , nion*0. , npls*0.,    1.    ,   50.    /,
     ,      rprob0 , rinteg  , einteg  , ainteg , achsptg  /
     /        0.1  ,   0.    ,   0.    ,   0.   , lvchsr*0./
      data scard_name /maxsc*' ' /
      data scilref,scilspt, scisrs, scisrc,sclchspnwl,screfcell /
     /     maxsc*1,maxsc*0,maxsc*0,maxsc*0, maxsc*1  ,maxsc*0   /,
     ,     screfpress /
     ,     maxsc*0.   /
      data scxmlim, scewall, scewbin,    sctransp     ,scfsheat /
     /    maxsc*0.,maxsc*0.,maxsc*0.,maxsc*0.,maxsc*0.,maxsc*-1. /,
     ,    screcycf,screcyct, scrcprm, scexppl, scexpel ,scexpil /
     /    maxsc*1.,maxsc*1.,maxsc*1.,maxsc*1.,maxsc*0.5,maxsc*1. /,
     ,    screcycs,scychsptg,scechsptg,scfchsptg,scstprm  /
     /    maxsc*0., maxsc*0., maxsc*0., maxsc*0.,maxsc*0. /
      data nnchemvar,indchemvar, chvarname , chmspname , chmvar    /
     /      maxsc*0 , maxchsc*0,maxchsc*' ',maxchsc*' ',maxchsc*0. /
      data dplsh  /
     /    npls*0 /

c*** 7

      integer nstrai,indsrc(nstra),npts(nstra),ninitl(nstra),
     ,  nptsh(nstra),
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
     / nstra*0,nstra*0,nstra*0,nstra*0,nstra*0,nstra*0,nstra*0,nstra*0/,
     , nptsh /
     / nstra*-1 /
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

      integer nzadd, ini(nrad), ine(nrad)

      data nzadd,  ini  ,  ine   /
     /       0  , nrad*0, nrad*0 /

c*** 9

      integer nprcsf,iprcsf(nlimps),maxlev,maxrad,maxpol,maxtor,maxadd,
     ,  nssplr(n1st),nssplp(n2nd),nssplt(n3rd),nsspla(nlim),
     ,  nsigvi,nsigsi,nsigci,nsigi_spc,
     ,  igh(nsd),iih(nsd),ighw(nsdw),iihw(nsdw),ighc(2,ncv),iihc(2,ncv)
      real prmrspl(n1st),prmpspl(n2nd),prmtspl(n3rd),prmaspl(nlim),
     ,  wminv,wmins,wminc,splpar
      logical nlprca(natm),nlprcm(nmol),nlprci(nion),nlprcph(npht),
     ,  llpbls,nlpbls(natm,nstra)

      data nprcsf, iprcsf ,maxlev,maxrad,maxpol,maxtor,maxadd /
     /       0   ,nlimps*0,   0  ,   0  ,   0  ,   0  ,   0   /,
     ,     nssplr,nssplp,nssplt,nsspla, nsigvi, nsigsi, nsigci /
     /     n1st*0,n2nd*0,n3rd*0,nlim*0,    0  ,    0  ,   0    /,
     ,     nsigi_spc, llpbls /
     /         0    ,.false. /,
     ,       igh ,  iih  ,  ighw ,  iihw ,    ighc     ,    iihc     /
     /      nsd*1, nsd*1 , nsdw*1, nsdw*1, ncv*1,ncv*1 , ncv*1,ncv*1 /
      data prmrspl,prmpspl,prmtspl,prmaspl,wminv,wmins,wminc,splpar  /
     /     n1st*0.,n2nd*0.,n3rd*0.,nlim*0.,1.e+3,1.e-2, 0.  ,  2.    /
      data    nlprca   ,    nlprcm   ,    nlprci   ,    nlpbls       /
     /     natm*.false., nmol*.false., nion*.false.,luatsr*.false.   /
      data    nlprcph   /
     /     npht*.false./

c*** 10

      integer nadvi, nclvi, nalvi, nadsi, nalsi, nadspc

      data nadvi, nclvi, nalvi, nadsi, nalsi, nadspc /
     /       0  ,   0  ,   0  ,   0  ,   0  ,   0    /

c*** 10a

      integer iadve(nadv), iadvs(nadv), iadvt(nadv), iadrc(nadv)
      character txttla(nadv)*72, txtspa(nadv)*24, txtuna(nadv)*24

      data iadve , iadvs , iadvt , iadrc , txttla , txtspa , txtuna  /
     /     nadv*0, nadv*0, nadv*0, nadv*0,nadv*' ',nadv*' ',nadv*' ' /

c*** 10b

      integer iclve(nclv), iclvs(nclv), iclvt(nclv), iclrc(nclv)
      character txttlc(nclv)*72, txtspc(nclv)*24, txtunc(nclv)*24

      data iclve,  iclvs,  iclvt,  iclrc /
     /    nclv*1, nclv*1, nclv*0, nclv*0 /

c*** 10c

      character chrtal(nalv)*70
      character txttlr(nalv)*72, txtspr(nalv)*24, txtunr(nalv)*24

      data txttlc , txtspc , txtunc  /
     ,    nclv*' ',nclv*' ',nclv*' ' /
      data chrtal , txttlr , txtspr , txtunr  /
     ,    nalv*' ',nalv*' ',nalv*' ',nalv*' ' /

c*** 10d

      integer iadse(nads), iadss(nads), iadst(nads), iadsc(nads)
      character txttld(nads)*72, txtspd(nads)*24, txtund(nads)*24

      data iadse,  iadss,  iadst,  iadsc /
     /    nads*1, nads*1, nads*0, nads*0 /
      data txttld , txtspd , txtund  /
     ,    nads*' ',nads*' ',nads*' ' /

c*** 10e

      character chrtls(nals)*70, txtsps(nals)*24, txttls(nals)*72,
     ,    txtuns(nals)*24

      data chrtls ,  txtsps ,  txttls ,  txtuns  /
     /    nals*' ', nals*' ', nals*' ', nals*' ' /

c*** 10f

      integer ispsrf(nads), iptyp(nads), ipspz(nads), isptyp(nads),
     ,        nsps(nads), isrfcl(nads), idirec(nads), ispopt(nads)
      real spcmn(nads), spcmx(nads), spcsh(nads), spcpx(nads),
     ,     spcpy(nads), spcps(nads), spcvx(nads), spcvy(nads),
     ,     spcvz(nads)

      data ispsrf, iptyp , ipspz , isptyp,  nsps , isrfcl, idirec /
     /     nasp*0, nasp*0, nasp*0, nasp*0, nasp*0, nasp*0, nasp*0 /,
     ,     ispopt /
     /     nasp*0 /
      data spcmn , spcmx , spcsh , spcpx , spcpy , spcps /
     /    nasp*0.,nasp*0.,nasp*0.,nasp*0.,nasp*0.,nasp*0./
      data spcvx , spcvy , spcvz /
     /    nasp*0.,nasp*0.,nasp*0./

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
     ,  trcblph,trctal, trcoct, trccen, trcrnf, trchktim, trcscl,
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
     ,     trctal, trcoct, trccen, trcrnf,trchktim,trcscl /
     /    .false.,.false.,.false.,.false.,.false.,.false. /,
     ,     trcdbg2,trcdbge,trcdbgm,trcdbgf,trcdbgl /
     /    .false.,.false.,.false.,.false.,.false. /,
     ,     trcdbgs,trcdbgg,trcdbgmpi,trcdbgc /
     /    .false. ,.false.,.false.  ,.false. /,
     ,           trcsrc        /
     /    .true.,nstra*.false. /,
     ,     pl1st , pl2nd , pl3rd , pladd , plhst /
     /    .false.,.false.,.false.,.false.,.false./,
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

c*** Data for visualisation of the surface properties

      integer, parameter :: luvsp=nsrfclsx*nvspfls
      data nsrfclu  , nsrfcls, isrfclu, msrfclu,  msrfcls   /
     /    nvspfls*0 ,    0   , luvsp*0, luvsp*0, nsrfclsx*0 /

c*** 12

      integer numlines,modaddv
      integer nchori,ncheni,lntspec,lntsput,nmcsput,
     ,  nchrdgrp,nchrdlint,nchrdlprf,
     ,  jchlst(nchor,nchor),nchtal(nchor),chr_lbl(nchor),
     ,  nspscl(nchor),nspnew(nchor),nspstr(nchor),nspspz(nchor),
     ,  nspini(nchor),nspend(nchor),nspblc(nchor),nspadd(nchor),
     ,  ipivot(nchor),ichord(nchor),npspcen,iatspec,
     ,  npspctt,npspcfi,listmtmp(lntsputx),listmtra(lntsputx),
     ,  nlstadds,mtreadds,listadds(nlimps),listaddg(nlimps),
     ,  ngwties,kgwties(ngwtiesx),mgwties(ngwtiesx),
     ,  lgwties(mgwtiesx,ngwtiesx),
     ,  npwin,npwsurf(npwinx),npwtally(npwinx),pwsurf(nlimps,npwinx),
     ,  pwtally(nlimps,npwinx),pwspecy(nlimps,npwinx),
     ,  pwtally_d(nlimps,npwinx),pwspecy_d(nlimps,npwinx)
      real emin1(nchor), emax1(nchor), eshift(nchor),
     ,     xpivot(nchor), ypivot(nchor), zpivot(nchor),
     ,     xchord(nchor), ychord(nchor), zchord(nchor),
     ,     emnspc, emxspc, chpts(4,nchor)
      logical plchor,plspec,prspec,plargl,prargl,lpw_d(npwinx)
      character chrdfile(nchor)*24,
     ,     txtmtmp(lntsputx)*2,txtmtra(lntsputx)*2

      data numlines, modaddv /
     /       0     ,    1    /
      data nchori, ncheni,lntspec,lntsput,nmcsput,npspcen,iatspec /
     /       0   ,   0   ,   0   ,   0   ,   0   ,  29   ,   1    /,
     ,  npspctt,npspcfi,nlstadds,mtreadds,ngwties,ngwtiesi /
     /       8   ,   4   ,   0    ,   0    ,   0   ,    0  /,
     ,   nchtal, nspscl, nspnew, nspstr, nspspz, nspini, nspend /
     /  nchor*0,nchor*0,nchor*0,nchor*0,nchor*0,nchor*0,nchor*0 /,
     ,   nspblc, nspadd, ipivot, ichord, jchlst ,chr_lbl /
     /  nchor*1,nchor*0,nchor*0,nchor*0,nchor2*0,nchor*0 /,
     ,   nchrdlint,nchrdlprf, listmtmp , listmtra  /
     /       0    ,   0     ,lntsputx*0,lntsputx*0 /,
     ,  listadds,listaddg, kgwties  , mgwties  ,lgwties ,npwin /
     /  nlimps*0,nlimps*0,ngwtiesx*0,ngwtiesx*0,lugwts*0,  0   /,
     ,  npwsurf,npwtally,pwsurf,pwtally,pwspecy,pwtally_d,pwspecy_d /
     / npwinx*0,npwinx*0,lupw*0, lupw*0, lupw*0,  lupw*0 ,  lupw*0  /
      data emin1  , emax1  , eshift /
     /    nchor*0.,nchor*0.,nchor*0./,
     ,     xpivot , ypivot , emnspc , emxspc /
     ,    nchor*0.,nchor*0.,  0.5   , 5000.  /,
     ,     zpivot , xchord , ychord , zchord  /
     /    nchor*0.,nchor*0.,nchor*0.,nchor*0. /
      data plchor, plspec, prspec, plargl, prargl,    lpw_d     /
     /     .true.,.false.,.false.,.false.,.false.,npwinx*.false./
      data txtmtmp    ,  txtmtra    /
     /    lntsputx*' ',lntsputx*' ' /,
     ,     chrdfile /
     /    nchor*' ' /

c*** 13

      integer nprnli, ntmstp, nptst, nsnvi, ninitl_read, nprmul,
     ,  isnve(nsnv), isnvs(nsnv), isnvt(nsnv), isnrc(nsnv)
      real dtimv, time0
      character txttlv(nsnv)*70, txtspv(nsnv)*24, txtunv(nsnv)*24

      data nprnli, ntmstp , nptst  , ninitl_read, nprmul /
     /        0  ,    1   ,   0    ,   -1       ,    0   /,
     ,      nsnvi,  isnve ,  isnvs ,  isnvt ,  isnrc /
     ,        0  , nsnv*0 , nsnv*0 , nsnv*0 , nsnv*0 /
      data dtimv , time0 /
     /     1.e+2 ,   0.  /
      data  txttlv ,  txtspv ,  txtunv  /
     /     nsnv*' ', nsnv*' ', nsnv*' ' /

c*** 14

      integer nclmi,nblcki,nprnvi,nprtvi,nprdvi,nfla,ncutb,ncutl,
     ,  imf,ntrfrm,nfull,ibrad,ibpol,ibtor,
     ,  iflb(npls),iflbh(npls),ndxa,ndya,ncvp,ncip,nfcp,ntargi,
     ,  ntgprt(nstep),ndt2(nstep,ngitt),
     ,  ninct2(nstep,ngitt),nixy2(nstep,ngitt),ntin2(nstep,ngitt),
     ,  nten2(nstep,ngitt),niflg(nstep,ngitt),nptc(nstep,ngitt),
     ,  nptcm(nstep,ngitt),nspzi(nstep,ngitt),nspze(nstep,ngitt),
     ,  nemod(nstep,ngitt),istramin,istramax,
     ,  nainb,ncopib,ncopeb,nains(nain),naint(nain),
     ,  naotb,naots(nlimps),naott(nlimps),
     ,  lkindp(npls),lkindph(npls)
      real fcte(npls),fcteh(npls),bmass(npls),bmassh(npls),chgsp(nstra),
     ,  chgsee(nstra),chgsei(nstra),chgsmom(nstra)
      logical lsymet,lbalan,lcoarse,lfchgs,lsprcl
      character txtpls(nain)*72, txtpsp(nain)*24, txtpun(nain)*24

      data nclmi,nblcki,nprnvi,nprtvi,nprdvi, nfla , ncutb, lkindp  /
     /        5 , -25  ,  1   , 350  ,  1   ,   0  ,   0  , npls*0  /,
     ,     ncutl, imf  ,ntrfrm, nfull, ibrad, ibpol, ibtor /
     /       1  ,   0  ,  1   ,   0  ,  0   ,    1 ,   1   /,
     ,     iflb , ndxa , ndya , ncvp , ncip , nfcp ,ntargi, ntgprt /
     /    npls*1,  0   ,  0   ,  0   ,  0   ,  0   ,  0   ,nstep*1 /,
     ,    ndt2   /
     /    lusg*0 /,
     ,    ninct2, nixy2, ntin2, nten2, niflg,  nptc , nptcm, nspzi /
     /    lusg*0,lusg*0,lusg*0,lusg*0,lusg*0, lusg*0,lusg*0,lusg*0 /,
     ,     nspze, nemod, nainb, naotb,istramin,istramax,ncopib,ncopeb /
     /    lusg*0,lusg*7,   0  ,   0  ,    1   ,    1   ,   0  ,   0   /,
     ,     iflbh /
     /    npls*1 /
      data fcte , bmass ,  chgsp ,  chgsee ,  chgsei , chgsmom /
     /   npls*1.,npls*0.,nstra*60.,nstra*60.,nstra*100.,nstra*50. /,
     ,   fcteh  , bmassh  , lkindph /
     /   npls*1., npls*0. , npls*0  /
      data lsymet,lbalan,lcoarse, lfchgs,lsprcl /
     /    .false.,.true.,.false.,.false.,.true. /

c*** 15

      integer nnadmod
      parameter (nnadmod=1)
      integer nadmod,nasmod,nrs(nnadmod),ipunkt(nnadmod),jedge(2,8),
     ,  nssir(8)
      real xcoor(nnadmod),ycoor(nnadmod),zcoor(nnadmod),
     ,  xpolpos(8),ypolpos(8)

      data ntrgte, ntrgto, ntrgtm /
     /        0  ,    0  ,    0   /
      data nadmod,   nrs   , ipunkt  , jedge /
     /        0  ,nnadmod*0,nnadmod*0,  16*0 /
      data xcoor   ,  ycoor   ,  zcoor   ,xpolpos,ypolpos /
     /   nnadmod*0.,nnadmod*0.,nnadmod*0.,  8*0. ,  8*0.  /
      data nssir /    !nh 07.07.23
     /   8*0 /

c*** Data for Eirene test run

      data
     , ttntcpu,ttnfile, ttnpts, ttalloc,tttest,ttcsrc,ttcsur,ttcint /
     /    50  , 10600 , nstra*5,   0.  ,.true.,.true.,.true.,.true. /,
     , ttchst,ttcref,ttcamd,ttcsou,ttcbla,ttcblm,ttcbli,ttcblp,ttcble /
     / .true.,.true.,.true.,.true.,.true.,.true.,.true.,.true.,.true. /,
     , ttcblph,ttctal,ttcoct,ttccen,ttcrnf /
     / .true.,.true. ,.true.,.true.,.true. /,
     , ttcdbg2,ttcdbge,ttcdbgm,ttcdbgf,ttcdbgl,ttcdbgs /
     / .true. ,.true. ,.true. ,.true. ,.true. ,.true.  /,
     , ttcdbgg,ttcdbgmpi,ttcdbgc,ttchktim,ttcscl /
     / .true. ,.true.   ,.true. , .false.,.true. /,
     , ttpl1st,ttpl2nd,ttpladd,ttplhst,        ttplcut       ,ttplnums/
     / .true. ,.true. ,.true. ,.true. ,.false.,.false.,.true.,.true.  /,
     , ttplspec,ttprspec,ttplargl,ttprargl,ttlsprcl /
     / .true.  ,.true.  ,.true.  ,.true.  ,.false.  /

c*** Data for diagnostic run

      data lntspcu,lntsptu,nmcsptu,dgntcpu,dgnptsfc,dgnfile,dgalloc /
     /        1   ,   0   ,   0   ,  1200 ,   10   , 10606 ,  0.5   /

c*** b2ah.dat

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

c*** Data for b2ah.dat.stencil file

      data cbsna , cbsmo , cbshi , cbmsb , cbrec /
     /    lcbs*0.,lcbs*0.,lcbs*0.,lcbs*0.,lcbs*0./,
     ,     cbshe , cbsch , cbmsa /
     /    lcbe*0.,lcbe*0.,lcbe*0./,
     ,     cfdf0 , cfdna , cfdpa , cfvla , cfvsa , cfhci /
     /    lcfs*0.,lcfs*0.,lcfs*0.,lcfs*0.,lcfs*0.,lcfs*0./,
     ,     cfhce , cfsig , cfalf , cflim /
     /      8*0. ,  8*0. ,  8*0. ,  8*0. /

      end module uinput_mod
