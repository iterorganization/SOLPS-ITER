      subroutine uinnam(unn)
      use b2mod_types
      use b2mod_constants
      use b2mod_layer
     , , only: ntrack, nalloys
      use b2mod_subsys
      use eirmod_solps
#ifdef DIMENSIONS_MODULE
      use b2mod_dimensions
#endif
c
c  version : 01.04.2005 01:23
c
c=======================================================================
c*** Data input from the DG file
c=======================================================================
      implicit none
      character*8 unn
#include "uinput.inc"
#include "impcon.inc"
      integer lunm,i,j,l,lusgm,lugpf,lugwt,luvsp,nprnl
      integer, save :: lupfr,luskel,luswch,lurefls,
     .  lchrdgrp,lchrdlint,lchrdlprf
      integer :: ichlst(nchor)
      real(kind=R4) :: u
      parameter(lunm=184)
      character*8 unm(lunm),uun
      character*8, save :: chtyp
      character ubs*1,uam*52
      logical, save :: hlp_spc,read_chr_angl
c...                                                  52=48+4
      integer luwrk(nlim),luind(nlim)
      logical streql
      external streql, xerrab, xertst
c*** lusgm : segment number for the list of invisibles;
c*** luswch: switch for the input of element lists (obsolete)
c***                1: jedgi1, 2: jedgo1, 3: jedgi2, 4: jedgo2
c***         or switch for the target data (clockwise from bottom left)
c*** luskel: counter for the segments to be skipped
c*** lugpf : counter for the puffing sources
c*** lugwt : counter for the grid-wall ties
      data lusgm, luswch, luskel, lugpf, lugwt, luvsp /6*0/
      data nprnl /999999/
      data hlp_spc / .true. /, read_chr_angl / .false. /
      data lurefls / 0 /, chtyp / ' ' /
      data lchrdgrp / 0 /, lchrdlint / 0 /, lchrdlprf / 0 /
      data unm /
     1    'p1'      ,'p2'      ,'misselem','srfinvsb','jliin'   ,
     2    'jlside'  ,'jadksw'  ,'jadjsw'  ,'jlcol   ','jlacll  ',
     3    'material','ewall   ','absorptn','trnsprnf','trnsprnb',
     4    'segment ','userdata','jedgi1  ','jedgo1  ','jedgi2  ',
     5    'jedgo2  ','elemlist','jlref   ','main    ','sources ',
     6    'sprtrs  ','vessel  ','b2plot  ','jlsptp  ','jlsptc'  ,
     7    'jsrss   ','jsrsg   ','rcycsa  ','rcycca  ','skipelem',
     8    'edge_trg','edge_sol','edge_pfr','trg_spcf','sol_edge',
     9    'pfr_edge','made_of ','tgabsrp ','tgewall ','tgtrnsf ',
     a    'tgtrnsb ','tgspcsw ','tgspcgr ','tgspcff ','tgsppsw ',
     1    'tgsppsp ','tgsppff ','tgrefsw ','divides ','species ',
     2    'spcs_gen','gas_puff','gpf_slot','gpf_cell','gpf_spcs',
     3    'gpf_flux','gpf_temp','gpf_angl','gpf_angp','gpf_nhst',
     4    'gpf_nini','jxi'     ,'jxa'     ,'laddsrfs','rmajor'  ,
     5    'nlscl'   ,'ntime'   ,'nfile'   ,'lfrm15'  ,'nprnli'  ,
     6    'dtimv'   ,'xlpcntr' ,'do_hepdt','locphep' ,'pwrhepdt',
     7    'pmphepdt','lstclhep','lhetrgts','tgnhst'  ,'tgnini'  ,
     8    'amd_file','ref_amds','chem_spt','chs_prj' ,'chs_yld' ,
     9    'chs_prd' ,'chs_tgc' ,'chs_enr' ,'chs_prc' ,'sps_srfs',
     b    'sps_absr','sps_trno','sps_trni','sps_mtrl','sps_tmpr',
     1    'sps_spph','sps_spch','sps_sgrp','sps_list','sps_id  ',
     2    'pfr_nflx','surfc_id','surfc_ll','lm_cnfg ','lm_vhst ',
     3    'lm_whst ','roator  ','nttrator','side_spc','ref_wall',
     4    'edgemark','trgtmark','nmcsptu ','emnspc  ','emxspc  ',
     5    'npspcen ','npspctt ','npspcfi ','listmtmp','ersmtaux',
     6    'dgntime ','dgnptsfc','listaddi','gwties  ','grdtie  ',
     7    'wlltie  ','vsp_inp ','run_rglr','run_test','run_diag',
     8    'c_xmlim ','c_isrsg ','c_ilspt ','c_ilref ','c_recycc',
     9    'c_recycs','c_iliin ','c_ilside','c_absrp ','c_trnspo',
     c    'c_trnspi','c_ewall ','trimark' ,'trisize' ,'trirect' ,
     1    'triref'  ,'trirflis','glb2dat ','glb_pwri','glb_pwre',
     2    'glb_pwrf','glb_tmst','spcs_crk','spcs_crp','spcs_crf',
     3    'spcs_scn','tgminhst','gpf_mhst','chords'  ,'linintg' ,
     4    'set_id'  ,'chr_lbl' ,'chr_angl','chrdsdat','data_id' ,
     5    'set_list','n_points','linprfs' ,'lm_equ'  ,'refcell' ,
     6    'refpress','trefcell','trfpress','crr_mode','grd_mode',
     7    'tgfclbl' ,'fclbl'   ,'omp_elm' ,'imp_elm' /
c=======================================================================
      call subini ('uinnam')
c*** Backslash:
      ubs=char(93)

      call locase(unn,uun,8)
      do i=1,lunm !{
        if(streql(uun,unm(i))) exit
      end do !}
c=======================================================================
      select case (i)
      case (1)
        call rearre(p1,3*nlim,i)
        call vscale(p1,0.1,p1,i)
        nlimi=i/3
        if(nlimi.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',nlimi
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (2)
        call rearre(p2,3*nlim,i)
        call vscale(p2,0.1,p2,i)
        nlimi=i/3
        if(nlimi.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',nlimi
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (3,35)
        call vsend(jadch0,luwrk,luskel)
        if(luskel+1.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',luskel+1
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
        if(maxval(jadch0).gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',
     .     maxval(jadch0)
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
        call rearri(luwrk(luskel+1),nlim-luskel,i)
        luskel=i+luskel
        call sortia(luwrk,luind,luskel)
        call rshffl(luwrk,luind,jadch0,luskel)
        if(luskel.lt.nlim) jadch0(luskel+1)=0
      case (4)
        call rearri(luwrk,nlim,i)
        if(lusgm.le.0) then
          print *,'*** Segment undefined, so the data are skipped ***'
          goto 9999
        end if
        call sortia(luwrk,luind,i)
        call rshffl(luwrk,luind,jadch1(1,lusgm),i)
        if(i+1.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',i+i
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
        if(i.lt.nlim) jadch1(i+1,lusgm)=0
      case (5)
        call rearri(jliin,nlim,i)
        nlimi=i
        if(nlimi.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',nlimi
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (6)
        call rearri(jlside,nlim,i)
        nlimi=i
        if(nlimi.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',nlimi
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (7)
        call rearri(jadksw,nlim,i)
        nlimi=i
        if(nlimi.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',nlimi
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (8)
        call rearri(jadjsw,nlim,i)
        nlimi=i
        if(nlimi.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',nlimi
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (9)
        call rearri(jlcol,nlim,i)
        nlimi=i
        if(nlimi.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',nlimi
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (10)
        call rearri(jlacll,nlim,i)
        nlimi=i
        if(nlimi.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',nlimi
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (11)
        umtrl(1:nlim) = 'dummy'
        call rearra(umtrl,nlim,i)
        nlimi=i
        if(nlimi.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',nlimi
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
        i=0
        call uinmtr(umtrl,i,nlimi)
      case (12)
        call rearre(ewala,nlim,i)
        nlimi=i
        if(nlimi.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',nlimi
          call xerrab
     .  (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (13)
        call rearre(rcycta,nlim,i)
        call vscale(rcycta,-1.,rcycta,i)
        call vbias(rcycta,1.,rcycta,i)
        nlimi=i
        if(nlimi.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',nlimi
          call xerrab
     .  (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (14)
        call rearre(trnspa(1,1),nlim,i)
        nlimi=i
        if(nlimi.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',nlimi
          call xerrab
     .  (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (15)
        call rearre(trnspa(1,2),nlim,i)
        nlimi=i
        if(nlimi.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',nlimi
          call xerrab
     .  (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (16)
        call resimi(lusgm)
      case (17)
        call resimi(luwrk(1))
      case (18)
        call resimi(luwrk(1))
        luswch=1
      case (19)
        call resimi(luwrk(1))
        luswch=2
      case (20)
        call resimi(luwrk(1))
        luswch=3
      case (21)
        call resimi(luwrk(1))
        luswch=4
      case (22)
        call rearri(luwrk,nlim,i)
        if(luswch.ge.1 .and. luswch.le.4) then !{
          if(luwrk(1).gt.nlim) then !{
            write(0,*) 'Too many wall elements: maximum ',nlim
            write(0,*) 'Current number of requested elements: ',luwrk(1)
            call xerrab
     .    (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
          end if !}
          jedgeo(luswch)=luwrk(1)
        end if !}
      case (23)
        call rearri(jlref,nlim,i)
        if(i.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',i
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (24)
        call resimi(i)
      case (25)
        call skipit
      case (26)
        call skipit
      case (27)
        call rearri(nmvsle,nlim,nnvsle)
        if(nnvsle.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',nnvsle
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
        if(maxval(nmvsle).gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',
     .     maxval(nmvsle)
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (28)
        call skipit
      case (29)
        call rearri(jlsptp,nlim,i)
        if(i.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',i
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (30)
        call rearri(jlsptc,nlim,i)
        if(i.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',i
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (31)
        call rearri(jsrss,nlim,i)
        if(i.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',i
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (32)
        call rearri(jsrsg,nlim,i)
        if(i.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',i
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (33)
        call rearre(rcycsa,nlim,i)
        if(i.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',i
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (34)
        call rearre(rcycca,nlim,i)
        if(i.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',i
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (36)
        call resimi(luswch)
        if(.not.tgdtinpt) then
          ntrgte=ntrgte+1
          ntrgtm=max(ntrgtm,luswch)
        end if
      case (37)
        if(.not.tgdtinpt) then !{
          call resimi(jedgec(luswch))
          if(jedgec(luswch).gt.nlim) then !{
            write(0,*) 'Too many wall elements: maximum ',nlim
            write(0,*) 'Current number of requested elements: ',
     .       jedgec(luswch)
            call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
          end if !}
        end if !}
      case (38)
        if(.not.tgdtinpt) then !{
          call resimi(jedgep(luswch))
          if(jedgep(luswch).gt.nlim) then !{
            write(0,*) 'Too many wall elements: maximum ',nlim
            write(0,*) 'Current number of requested elements: ',
     .       jedgep(luswch)
            call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
          end if !}
         end if !}
      case (39)
        call resimi(luswch)
        if(.not.tgdtinpt) then
          ntrgte=1
          ntrgtm=luswch
        else
          ntrgte=ntrgte+1
          ntrgtm=max(ntrgtm,luswch)
        end if
        tgdtinpt=.true.
      case (40)
        call resimi(jedgec(luswch))
        if(jedgec(luswch).gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',
     .     jedgec(luswch)
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (41)
        call resimi(jedgep(luswch))
        if(jedgep(luswch).gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',
     .     jedgep(luswch)
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (42)
        i=lena
        lena=8
        call resima(made_of(luswch))
        lena=i
      case (43)
        call resime(tgabsrp(luswch))
      case (44)
        call resime(tgewall(luswch))
      case (45)
        call resime(tgtrnsf(luswch))
      case (46)
        call resime(tgtrnsb(luswch))
      case (47)
        call resimi(tgspcsw(luswch))
      case (48)
        call resimi(tgspcgr(luswch))
      case (49)
        call resime(tgspcff(luswch))
      case (50)
        call resimi(tgsppsw(luswch))
      case (51)
        call resimi(tgsppsp(luswch))
      case (52)
        call resime(tgsppff(luswch))
      case (53)
        call resimi(tgrefsw(luswch))
      case (54)
        call rearri(ldvbndx,nbnddvd+1,i)
        mdvbndx=i-1
      case (55)
        if(hlp_spc) nspigen=0
        hlp_spc=.false.
        nspigen=nspigen+1
        if(nspigen.gt.natm) then !{
          write(0,*) 'Too many species: maximum ',natm
          call xerrab
     .   (' ==> Check the DG model and DEF_NATM in b2mod_dimensions.F')
        end if !}
        call resimi(i)
        print *,'uinnam: species ',i,nspigen
        if(nspigen.ne.i) then !{
          write(0,*) '*** uinnam: wrong species order.  nspigen,i = ',
     ,      nspigen,i
          call xerrab (' ==> Corrupted DG output?')
        end if !}
      case (56)
        if(nspigen.le.0 .or. hlp_spc) then !{
          write(0,*) 'uinnam: species index undefined'
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        l=lena
        lena=2
        call resima(spcigen(nspigen))
        lena=l
        print *,'                          ==> ',spcigen(nspigen)
      case (57)
        call resimi(i)
        ngpfstr=ngpfstr+1
        if(ngpfstr.gt.nstra) then !{
          write(0,*) 'Too many gas puffing strata specified'
          call xerrab
     .   (' ==> Check the DG model and DEF_NSTRA in b2mod_dimensions.F')
        end if !}
      case (58)
        if(ngpfstr.le.0) then !{
          write(0,*) 'uinnam: gas puffing strata index undefined'
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        if(lugpf.gt.nlim) then !{
          write(0,*) 'uinnam: too many slot surfaces for gas puff'
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
        call rearri(lgpfstr(lugpf+1),nlim-lugpf,i)
        if(i.eq.0) then !{
          write(0,*) 'The slot specification is missing for ',
     ,      'gas puffing stratum',ngpfstr
          call xerrab
     .     (' ==> Check the "Gas puff" variables in the DG model')
        end if !}
        if(i.gt.nsrfs) then !{
          write(0,*) 'uinnam: too many segments for gas puff'
          call xerrab
     .   (' ==> Check the DG model and DEF_NSRFS in b2mod_dimensions.F')
        end if !}
        if(maxval(lgpfstr).gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',
     .     maxval(lgpfstr)
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
        kgpfstr(ngpfstr)=i
        lugpf=lugpf+i
      case (59)
        call resimi(mgpfstr(ngpfstr))
      case (60)
        l=lena
        lena=12
        call resima(cgpfstrs(ngpfstr))
        lena=l
      case (61)
        call resime(fgpfstr(ngpfstr))
      case (62)
        call resime(tgpfstr(ngpfstr))
      case (63)
        call resimi(jgpfstr(ngpfstr))
      case (64)
        call resime(pgpfstr(ngpfstr))
      case (65)
        call resimi(npgpfstr(ngpfstr))
      case (66)
        call resimi(nigpfstr(ngpfstr))
      case (67)
        call resimi(jxi)
      case (68)
        call resimi(jxa)
      case (69)
        call resimi(laddsrfs)
      case (70)
        call resime(u)
        zaa=2.0_R8*pi*u
      case (71)
        call resimi(i)
        nlscl=i.ne.0
      case (72)
        call resimi(ntcpu)
      case (73)
        call resimi(nfile)
      case (74)
        call resimi(lfrm15)
      case (75)
        call resimi(nprnli)
        if (nprnli.gt.nprnl) then
          nprmul=(nprnli/nprnl)+1
          nprnli=nprnli/nprmul
        end if
        usetmstr=usetmstr.or.nprnli.gt.0
      case (76)
        call resime(dtimv)
      case (77)
        call rearre(xlpcntr,3,i)
      case (78)
        call resimi(i)
        do_hepdt= i.ne.0
      case (79)
        call resimi(locphep)
      case (80)
        call resime(pwrhepdt)
      case (81)
        call resime(pmphepdt)
      case (82)
        call rearri(lstclhep,nxd,nstclhep)
      case (83)
        call rearri(lhetrgts,nlim,nhetrgts)
      case (84)
        call resimi(tgnhst(luswch))
      case (85)
        call resimi(tgnini(luswch))
      case (86)
        if(namdf.le.0) then !{
          write(0,*) 'uinnam: AMDS reference index undefined'
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        l=lena
        lena=48
        call resima(amd_file(namdf))
        j=index(amd_file(namdf),' ')
        if(j.gt.0.and.j.lt.48) then
          amd_file(namdf)(j+1:48) = repeat(' ',48-j)
        endif
        lena=l
        if(index(amd_file(namdf),'.').eq.0) then !{
          i=index(amd_file(namdf),ubs)
          if(i.eq.0) then !{
            uam=amd_file(namdf)
            uam(49:52)='.amo' ! xpb: was .amds extension
            call lefta(uam,52,i)
            if(i.gt.48) then !{
              write(0,*) 'Too long name for AMDS reference after ',
     ,         'expansion: ',uam
              call xerrab ('==> Check the DG model')
            end if !}
            amd_file(namdf)=uam
            write(*,*) 'Filename for AMDS reference expanded: ',uam
          else !}{
            amd_file(namdf)(i:i)=' '
            call lefta(amd_file(namdf),48,i)
            write(*,*) 'Filename for AMDS reference quoted: ',
     ,                                           trim(amd_file(namdf))
          end if !}
        else
          i=index(amd_file(namdf),'.')
          uam=amd_file(namdf)
          uam(i:i+4)='.amo ' ! xpb: was .amds extension
          call lefta(uam,52,i+4)
          amd_file(namdf)=uam
          write(*,*) 'Filename for AMDS reference quoted: ',
     ,                                           trim(amd_file(namdf))
        end if !}
      case (87)
        call resimi(namdf)
        if(namdf.gt.namdfs) then !{
          write(0,*) 'Too many AMDS models specified - ',
     ,      'must be no more than ',namdfs
          call xerrab
     .     ('==> Check the DG model or increase NAMDFS in uinpcom.inc')
        end if !}
      case (88)
c*** Chemical sputtering
        call resimi(i)
        nchsppri=nchsppri+1
        if(nchsppri.gt.nchsppr) then !{
          write(0,*) 'Too many chemical reactions specified.'
          write(0,*) 'STOP ==> check the DG model and the value of ',
     ,                                        'nchsppr in KOPPLDIM.F'
          call xerrab ('Too many chemical reactions specified')
        end if !}
      case (89)
        if(nchsppri.le.0) then !{
          write(0,*) 'Chemical sputtering data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        l=lena
        lena=24
        call resima(chsptgt(nchsppri))
        lena=l
      case (90)
        if(nchsppri.le.0) then !{
          write(0,*) 'Chemical sputtering data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resime(ychsptg(nchsppri))
      case (91)
        l=lena
        if(nchsppri.le.0) then !{
          write(0,*) 'Chemical sputtering data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        lena=16
        call resima(chspspt(nchsppri))
        lena=l
      case (92)
        if(nchsppri.le.0) then !{
          write(0,*) 'Chemical sputtering data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resimi(lchspnwl(nchsppri))
      case (93)
        if(nchsppri.le.0) then !{
          write(0,*) 'Chemical sputtering data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resime(echsptg(nchsppri))
      case (94)
        if(nchsppri.le.0) then !{
          write(0,*) 'Chemical sputtering data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resime(fchsptg(nchsppri))
      case (95)
c*** Surface data transfer from B2 to Eirene
        call resimi(i)
        n_spcsrf=n_spcsrf+1
        if(n_spcsrf.gt.DEF_NSPCSRFG) then !{
          write(0,*) 'Too many "Surface special" groups specified'
          write(0,*) 'STOP ==> check the DG model and the value of ',
     ,                        'DEF_NSPCSRFG in b2mod_dimensions.F'
          call xerrab ('Too many "Surface special" groups specified')
        end if !}
        if(n_spcsrf.ne.i) then !{
          write(0,*) '### Wrong order of "Surface special" groups - ',
     ,                                            'corrupted DG model?'
        end if !}
      case (96)
        if(n_spcsrf.le.0) then !{
          write(0,*) '"Surface special" data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resime(sps_absr(n_spcsrf))
      case (97)
        if(n_spcsrf.le.0) then !{
          write(0,*) '"Surface special" data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resime(sps_trno(n_spcsrf))
      case (98)
        if(n_spcsrf.le.0) then !{
          write(0,*) '"Surface special" data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resime(sps_trni(n_spcsrf))
      case (99)
        if(n_spcsrf.le.0) then !{ ####
          write(0,*) '"Surface special" data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resima(sps_mtrl(n_spcsrf))
        sps_mtri(n_spcsrf)=-1.0
        if(.not.streql(sps_mtrl(n_spcsrf),'-'))
     >   call uinmtr(sps_mtrl(n_spcsrf),nint(sps_mtri(n_spcsrf)),1)
      case (100)
        if(n_spcsrf.le.0) then !{
          write(0,*) '"Surface special" data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resime(sps_tmpr(n_spcsrf))
      case (101)
        if(n_spcsrf.le.0) then !{
          write(0,*) '"Surface special" data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resime(sps_spph(n_spcsrf))
      case (102)
        if(n_spcsrf.le.0) then !{
          write(0,*) '"Surface special" data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resime(sps_spch(n_spcsrf))
      case (103)
        if(n_spcsrf.le.0) then !{
          write(0,*) '"Surface special" data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resimi(sps_sgrp(n_spcsrf))
      case (104)
        if(n_spcsrf.le.0) then !{
          write(0,*) '"Surface special" data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call rearri(ll_spcsrf(1,n_spcsrf),nlimps,k_spcsrf(n_spcsrf))
        if(maxval(ll_spcsrf).gt.(nlim+nsts)) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Or non-standard surfaces: maximum ',nsts
          write(0,*) 'Current number of requested elements: ',
     .     maxval(ll_spcsrf)
          call xerrab
     .     (' ==> Check the DG model and '//
     .      'DEF_NLIM and DEF_NSTS in b2mod_dimensions.F')
        end if !}
        if(minval(ll_spcsrf).lt.(-nsts)) then !{
          write(0,*) 'Too many non-standard surfaces: maximum ',nsts
          write(0,*) 'Current number of requested surfaces: ',
     .     abs(minval(ll_spcsrf))
          call xerrab
     .   (' ==> Check the DG model and DEF_NSTS in b2mod_dimensions.F')
        end if !}
      case (105)
        if(n_spcsrf.le.0) then !{
          write(0,*) '"Surface special" data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resima(sps_id(n_spcsrf))
      case (106)
        call resimi(i)
        if(npfrgrp.eq.0) lupfr=0
        npfrgrp=npfrgrp+1
        if(npfrgrp.gt.npfrgrpd) then !{
          write(0,*) 'Too many "PFR surface groups" specified'
          write(0,*) 'STOP ==> check the DG model and the value of ',
     ,                          'npfrgrpd in uinpcom.inc and COMUSER.F'
          call xerrab ('Too many "PFR surface groups" specified')
        end if !}
        if(npfrgrp.ne.i) then !{
          write(0,*) '### Wrong order of "PFR surface groups" - ',
     ,                                            'corrupted DG model?'
        end if !}
      case (107)
        if(npfrgrp.le.0) then !{
          write(0,*) '"PFR surface group" data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resima(gpfrgrp(npfrgrp))
      case (108)
        if(npfrgrp.le.0) then !{
          write(0,*) '"PFR surface group" data outside the block - ',unn
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        j=DEF_NLIM-lupfr
        if(j.le.0) then !{
          write(0,*) 'Too many elements in "PFR surface groups"'
          call xerrab (' ==> check the DG model')
        end if !}
        call rearri(lpfrgrp(lupfr+1),j,i)
        ipfrgrp(npfrgrp)=lupfr+1
        jpfrgrp(npfrgrp)=lupfr+i
        lupfr=lupfr+i
c*** Limiter configuration (code cheating)
      case (109)
        lm_cnfg=.true.
        call skipit
      case (110)
        call resimi(lm_vhst)
      case (111)
        call resimi(lm_whst)
c*** Toroidal geometry
      case (112)
        call resime(roator)
      case (113)
        call resimi(nttrator)
c*** Material properties of the grid edges
      case (114)
        nwllmrk=nwllmrk+1
        call skipit
        if(nwllmrk.gt.nwllmrkd) then !{
          write(0,*) 'Too many reference wall segments (spc_side)'
          call xerrab
     .     (' ==> Check the DG model or increase nwllmrkd in uinpcom')
        end if !}
      case (115)
        if(nwllmrk.le.0) then !{
          write(0,*) 'Grid edge material data outside block (ref_wall)'
          call xerrab (' ==> Corrupted DG output?')
        else if(nwllmrk.le.nwllmrkd) then !}{
          call resimi(lwllmrk(nwllmrk))
        else !}{
          write(0,*) 'Too many reference wall segments (spc_side)'
          call xerrab
     .     (' ==> Check the DG model or increase nwllmrkd in uinpcom')
        end if !}
      case (116)
        if(nwllmrk.le.0) then !{
          write(0,*) 'Grid edge material data outside block (edgemark)'
          call xerrab (' ==> Corrupted DG output?')
        else if(nwllmrk.le.nwllmrkd) then !}{
          call rearri(ledgmrk(1,nwllmrk),nedgmrkd,nedgmrk(nwllmrk))
        else !}{
          write(0,*) 'Too many reference wall segments (spc_side)'
          call xerrab
     .     (' ==> Check the DG model or increase nwllmrkd in uinpcom')
        end if !}
      case (117)
        if(nwllmrk.le.0) then !{
          write(0,*) 'Grid edge material data outside block (trgtmark)'
          call xerrab (' ==> Corrupted DG output?')
        else if(nwllmrk.le.nwllmrkd) then !}{
          call rearri(ltrgmrk(1,nwllmrk),nedgmrkd,ntrgmrk(nwllmrk))
        else !}{
          write(0,*) 'Too many reference wall segments (spc_side)'
          call xerrab
     .     (' ==> Check the DG model or increase nwllmrkd in uinpcom')
        end if !}
c*** Data for diagnostics of wall erosion
      case (118)
        call resimi(nmcsptu)
      case (119)
        call resime(emnspc)
      case (120)
        call resime(emxspc)
      case (121)
        call resimi(npspcen)
      case (122)
        call resimi(npspctt)
      case (123)
        call resimi(npspcfi)
      case (124)
        call rearri(listmtmp,lntsputx,lntsptu)
      case (125)
        l=lena
        lena=2
        call resima(txtmtra(1))
        lena=l
      case (126)
        call resimi(dgntcpu)
      case (127)
        call resimi(dgnptsfc)
      case (128)
        call rearri(listaddi,nlim,nlstadu)
      case (129)
        call resimi(lugwt)
        ngwtiesi=ngwtiesi+1
        if(ngwtiesi.gt.ngwtiesx) then !{
          write(0,*) 'uinnam: too many ties specified ( > ',
     .                                               ngwtiesx,' )'
          write(0,*) '  ==> Check the DG model'
          call xerrab ('Too many ties specified')
        end if !}
      case (130)
        call resimi(kgwties(ngwtiesi))
      case (131)
        call rearri(lgwties(1,ngwtiesi),mgwtiesx,mgwties(ngwtiesi))
c*** Data for visualisation of the surface properties
      case (132)
        call resimi(luvsp)
        if(luvsp.lt.0) then !{
          write(0,*) 'uinnam: negative view identifier - ',
     ,                        'corrupted DG output???'
          call xerrab ('Negative view identifier')
        else if(luvsp.gt.nsrfclsx) then !}{
          write(0,*)
     ,     'uinnam: too many views for surface coloring ',luvsp
          write(0,*) '  ==> Check the DG model or increase the ',
     ,      'nsrfclsx parameter in uinpcom.inc'
          call xerrab ('Too many views for surface coloring')
        end if !}
        nsrfcls=max(luvsp,nsrfcls)
      case (133)
        call xertst (luvsp.gt.0 .and. luvsp.le.nsrfclsx,
     ,   'uinnam: undefined view identifier - corrupted DG output???')
        call resimi(isrfclu(luvsp,1))
      case (134)
        call xertst (luvsp.gt.0 .and. luvsp.le.nsrfclsx,
     ,   'uinnam: undefined view identifier - corrupted DG output???')
        call resimi(isrfclu(luvsp,2))
      case (135)
        call xertst (luvsp.gt.0 .and. luvsp.le.nsrfclsx,
     ,   'uinnam: undefined view identifier - corrupted DG output???')
        call resimi(isrfclu(luvsp,3))
      case (136:147)
        l=i-135
 1147   call xertst (luvsp.gt.0 .and. luvsp.le.nsrfclsx,
     ,    'uinnam: undefined view identifier - corrupted DG output???')
        call resimi(i)
        if(i.gt.0) then !{
          msrfcls(luvsp)=msrfcls(luvsp)+1
          lsrfcls(msrfcls(luvsp),luvsp)=l
        end if !}
c***  input trimark is the marker for TRIA mesh
      case (148)
        call rearri(ilplgdg,nlim,i)
c***  input global mesh size
      case (149)
        call resime(trisize(0))
c***  input index of rectangle
      case (150)
        call resimi(ntriref)
c***  input mesh size for current rectangle
      case (151)
        call xertst (ntriref.gt.0,
     ,   'uinnam: wrong index of TRIA regions - corrupted DG output???')
        if(ntriref.gt.ntrimax) then !{
          write(0,*) 'Too many TRIA regions: maximum ',ntrimax
          write(0,*) 'Current number of requested regions: ',ntriref
          call xerrab
     .     (' ==> Check the DG model and ntrimax in uinpcom.inc')
        end if !}
        call resime(trisize(ntriref))
c***  input elements indices for current rectangle
      case (152)
        call rearri(trirefel(lurefls+1),ntrimax-lurefls,
     .              trirefcn(ntriref))
        if(maxval(trirefel).gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',
     .     maxval(trirefel)
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
        lurefls=lurefls+trirefcn(ntriref)
      case (153)
        glb2read=.true.
        call skipit
      case (154)
        call resime(pwrcrtti)
      case (155)
        call resime(pwrcrtte)
      case (156)
        call resime(pwrcrfri)
        pwrcrfri=max(0.,min(1.,pwrcrfri))
      case (157)
        call resimi(i)
        usetmstr=usetmstr.or.i.ne.0
      case (158)
        if(nspigen.le.0 .or. hlp_spc) then !{
          write(0,*) 'uinnam: species index undefined'
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resimi(spcicrk(nspigen))
      case (159)
        if(nspigen.le.0 .or. hlp_spc) then !{
          write(0,*) 'uinnam: species index undefined'
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resime(spcicrp(nspigen))
      case (160)
        if(nspigen.le.0 .or. hlp_spc) then !{
          write(0,*) 'uinnam: species index undefined'
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resime(spcicrf(nspigen))
      case (161)
        if(nspigen.le.0 .or. hlp_spc) then !{
          write(0,*) 'uinnam: species index undefined'
          call xerrab (' ==> Corrupted DG output?')
        end if !}
        call resimi(spciscn(nspigen))
        if(spciscn(nspigen).ne.0) spciscn(nspigen)=1
      case (162)
        call resimi(tgmhst(luswch))
      case (163)
        call resimi(mpgpfstr(ngpfstr))
      case (164) ! chords
        call rearre(chpts,4*nchor,i)
        call vscale(chpts,0.1,chpts,i)
        nchori=i/4
        do i=1,nchori
          xpivot(i) = chpts(1,i)
          ypivot(i) = chpts(2,i)
          zpivot(i) = 0.
          xchord(i) = chpts(3,i)
          ychord(i) = chpts(4,i)
          if (.not.read_chr_angl) zchord(i) = 0.
        end do
      case (165) ! linintg
        chtyp = 'lin_int'
        call resimi(lchrdlint)
        nchrdlint=nchrdlint+1
        if(nchrdlint.gt.nchor) then !{
          write(0,*)
     .     'uinnam: too many line integral groups specified ( > ',
     .                                               nchor,' )'
          write(0,*) '  ==> Check the DG model'
          call xerrab ('Too many line integral groups specified')
        end if !}
      case (166) ! set_id
        i=lena
        lena=24
        if (streql(chtyp,'lin_prf')) then
          call skipit
        else if (streql(chtyp,'lin_int')) then
          call resima(chrdfile(lchrdlint))
          call strip_spaces(chrdfile(lchrdlint))
        end if
        lena=i
      case (167) ! chr_lbl
        call rearri(chr_lbl,nchor,i)
        do j = 1, i !{
          if (chr_lbl(j).lt.0 .or. chr_lbl(j).gt.999) then !{
            write (0,*) 'uinnam: invalid chord label number'
            write (0,*) '  Must be between 0 and 999'
            write (0,*) '  ==> Check the DG model'
            call xerrab ('Invalid chord label number')
          end if !}
        end do !}
      case (168) ! chr_angl
        call rearre(zchord,nchor,i)
        read_chr_angl = .true.
      case (169) ! chrdsdat
        call resimi(lchrdgrp)
        nchrdgrp=nchrdgrp+1
        if(nchrdgrp.gt.nchor) then !{
          write(0,*)
     .     'uinnam: too many chord groups specified ( > ',
     .                                               nchor,' )'
          write(0,*) '  ==> Check the DG model'
          call xerrab ('Too many chord groups specified')
        end if !}
        call resima(chtyp)
        if (.not.streql(chtyp,'lin_prf') .and.
     .      .not.streql(chtyp,'lin_int')) then !{
          write(0,*) 'uinnam: unrecognized chord group type ',
     .      chtyp
          write(0,*) '  ==> Check the DG model'
          call xerrab ('Unrecognized chord group type')
        end if !}
      case (170) ! data_id
        i=lena
        lena=24
        call resima(chrdfile(lchrdgrp))
        call strip_spaces(chrdfile(lchrdgrp))
        lena=i
      case (171) ! set_list
        ichlst = 0
        call rearri(ichlst,nchor,i)
        if (streql(chtyp,'lin_int')) then
          jchlst(1:i,lchrdlint)=ichlst(1:i)
        else if (streql(chtyp,'lin_prf')) then
          continue
        end if
      case (172) ! n_points
        call skipit
      case (173) ! linprfs
        chtyp = 'lin_prf'
        call resimi(lchrdlprf)
        nchrdlprf=nchrdlprf+1
        if(nchrdlprf.gt.nchor) then !{
          write(0,*)
     .     'uinnam: too many line profiles groups specified ( > ',
     .                                               nchor,' )'
          write(0,*) '  ==> Check the DG model'
          call xerrab ('Too many line profiles groups specified')
        end if !}
      case (174) ! lm_equ
        i=lena
        lena=52
        call resima(uam)
        lena=i
        ln_cnfg = uam(1:1).eq.'-'.and.lm_cnfg
      case (175) ! refcell
        call rearri(refcell,nlim,i)
        if(i.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',i
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (176) ! refpress
        call rearre(refpress,nlim,i)
        if(i.gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',i
          call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in b2mod_dimensions.F')
        end if !}
      case (177) ! trefcell
        call resimi(trefcell(luswch))
      case (178) ! trfpress
        call resime(trfpress(luswch))
      case (179) ! crr_mode
        call resimi(carre_mode)
      case (180) ! grd_mode
        call resimi(grid_mode)
      case (181) ! tgfclbl
        call resimi(tgfclbl(luswch))
      case (182) ! fclbl
        call rearri(fclbl,nlim,i)
      case (183) ! omp_elm
        call resimi(omp_elm)
      case (184) ! imp_elm
        call resimi(imp_elm)
      case default
        call skipit
      end select
c=======================================================================
 9999 call subend ()
      return
      end subroutine uinnam
