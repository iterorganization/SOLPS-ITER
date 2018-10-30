      subroutine uinnam(unn)
      use b2mod_types
      use b2mod_constants
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
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
      integer, save :: lupfr,luskel,luswch,lurefls
      real (kind=R4) :: u
      parameter (lunm=163)
      character*8 unm(lunm),uun,ubs*1,uam*52
c...                                                  52=48+4
      integer luwrk(nlim),luind(nlim)
      logical hlp_spc,streql
      external streql, xerrab, xertst, subini, subend
c*** lusgm: segment number for the list of invisibles;
c*** luswch: switch for the input of element lists (obsolete)
c***                1: jedgi1, 2: jedgo1, 3: jedgi2, 4: jedgo2
c***         or switch for the target data (clockwise from bottom left)
c*** luskel: counter for the segments to be skipped
c*** lugpf:  counter for the puffing sources
c*** lugwt:  counter for the grid-wall ties
      data lusgm, luswch, luskel, lugpf, lugwt, luvsp, nprnl /7*0/
      data hlp_spc / .true. /
      data lurefls / 0 /  
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
     3    'spcs_scn','tgminhst','gpf_mhst'/
c=======================================================================
      call subini ('uinnam')
c*** Backslash:
      ubs=char(93)

      call locase(unn,uun,8)
      do i=1,lunm !{
        if(streql(uun,unm(i))) then !{
          go to (1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,
     ,          16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,
     ,          31,32,33,34, 3,36,37,38,39,40,41,42,43,44,45,
     ,          46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,
     ,          61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,
     ,          76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,
     ,          91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,
     ,   106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,
     ,   121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,
     ,   147,147,147,147,147,147,147,147,147,147,147,147,148,149,150,
     ,   151,152,153,154,155,156,157,158,159,160,161,162,163),i
#ifdef FLUSH
            call FLUSH(6)
#endif
          write(0,*) 'Switch overflow in uinnam - check the go to(',
     ,                                    'label list) construct there'
          call xerrab ('Switch overflow')
        end if !}
      end do !}
      call skipit
      goto 9999
c=======================================================================
    1 call rearre(p1,3*nlim,i)
      call vscale(p1,0.1,p1,i)
      nlimi=i/3
      if(nlimi.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',nlimi
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
    2 call rearre(p2,3*nlim,i)
      call vscale(p2,0.1,p2,i)
      nlimi=i/3
      if(nlimi.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',nlimi
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
    3 call vsend(jadch0,luwrk,luskel)
      if(luskel+1.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',luskel+1
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      if(maxval(jadch0).gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',
     .   maxval(jadch0)
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      call rearri(luwrk(luskel+1),nlim-luskel,i)
      luskel=i+luskel
      call sortia(luwrk,luind,luskel)
      call rshffl(luwrk,luind,jadch0,luskel)
      if(luskel.lt.nlim) jadch0(luskel+1)=0
      goto 9999
    4 call rearri(luwrk,nlim,i)
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
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      if(i.lt.nlim) jadch1(i+1,lusgm)=0
      goto 9999
    5 call rearri(jliin,nlim,i)
      nlimi=i
      if(nlimi.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',nlimi
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
    6 call rearri(jlside,nlim,i)
      nlimi=i
      if(nlimi.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',nlimi
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
    7 call rearri(jadksw,nlim,i)
      nlimi=i
      if(nlimi.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',nlimi
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
    8 call rearri(jadjsw,nlim,i)
      nlimi=i
      if(nlimi.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',nlimi
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
    9 call rearri(jlcol,nlim,i)
      nlimi=i
      if(nlimi.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',nlimi
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
   10 call rearri(jlacll,nlim,i)
      nlimi=i
      if(nlimi.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',nlimi
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
   11 umtrl(1:nlim) = 'dummy'
      call rearra(umtrl,nlim,i)
      nlimi=i
      if(nlimi.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',nlimi
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      i=0
      call uinmtr(umtrl,i,nlimi)
      goto 9999
   12 call rearre(ewala,nlim,i)
      nlimi=i
      if(nlimi.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',nlimi
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
   13 call rearre(rcycta,nlim,i)
      call vscale(rcycta,-1.,rcycta,i)
      call vbias(rcycta,1.,rcycta,i)
      nlimi=i
      if(nlimi.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',nlimi
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
   14 call rearre(trnspa(1,1),nlim,i)
      nlimi=i
      if(nlimi.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',nlimi
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
   15 call rearre(trnspa(1,2),nlim,i)
      nlimi=i
      if(nlimi.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',nlimi
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
   16 call resimi(lusgm)
      goto 9999
   17 call resimi(luwrk(1))
      goto 9999
   18 call resimi(luwrk(1))
      luswch=1
      goto 9999
   19 call resimi(luwrk(1))
      luswch=2
      goto 9999
   20 call resimi(luwrk(1))
      luswch=3
      goto 9999
   21 call resimi(luwrk(1))
      luswch=4
      goto 9999
   22 call rearri(luwrk,nlim,i)
      if(luswch.ge.1 .and. luswch.le.4) then !{
        if(luwrk(1).gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',luwrk(1)
          call xerrab
     .     (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
        end if !}
        jedgeo(luswch)=luwrk(1)
      end if !}
      goto 9999
   23 call rearri(jlref,nlim,i)
      if(i.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',i
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
   24 call resimi(i)
      goto 9999
   25 call skipit
      goto 9999
   26 call skipit
      goto 9999
   27 call rearri(nmvsle,nlim,nnvsle)
      if(nnvsle.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',nnvsle
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      if(maxval(nmvsle).gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',
     .   maxval(nmvsle)
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
   28 call skipit
      goto 9999
   29 call rearri(jlsptp,nlim,i)
      if(i.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',i
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
   30 call rearri(jlsptc,nlim,i)
      if(i.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',i
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
   31 call rearri(jsrss,nlim,i)
      if(i.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',i
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
   32 call rearri(jsrsg,nlim,i)
      if(i.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',i
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
   33 call rearre(rcycsa,nlim,i)
      if(i.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',i
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
   34 call rearre(rcycca,nlim,i)
      if(i.gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',i
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
   36 call resimi(luswch)
      if(.not.tgdtinpt) then
        ntrgte=ntrgte+1
        ntrgtm=max(ntrgtm,luswch)
      end if
      goto 9999
   37 if(.not.tgdtinpt) then !{
        call resimi(jedgec(luswch))
        if(jedgec(luswch).gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',
     .     jedgec(luswch)
          call xerrab
     .     (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
        end if !}
      end if !}
      goto 9999
   38 if(.not.tgdtinpt) then !{
        call resimi(jedgep(luswch))
        if(jedgep(luswch).gt.nlim) then !{
          write(0,*) 'Too many wall elements: maximum ',nlim
          write(0,*) 'Current number of requested elements: ',
     .     jedgep(luswch)
          call xerrab
     .     (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
        end if !}
       end if !}
      goto 9999
   39 call resimi(luswch)
      if(.not.tgdtinpt) then
        ntrgte=1
        ntrgtm=luswch
      else
        ntrgte=ntrgte+1
        ntrgtm=max(ntrgtm,luswch)
      end if
      tgdtinpt=.true.
      goto 9999
   40 call resimi(jedgec(luswch))
      if(jedgec(luswch).gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',
     .   jedgec(luswch)
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
   41 call resimi(jedgep(luswch))
      if(jedgep(luswch).gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',
     .   jedgep(luswch)
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
   42 i=lena
      lena=8
      call resima(made_of(luswch))
      lena=i
      goto 9999
   43 call resime(tgabsrp(luswch))
      goto 9999
   44 call resime(tgewall(luswch))
      goto 9999
   45 call resime(tgtrnsf(luswch))
      goto 9999
   46 call resime(tgtrnsb(luswch))
      goto 9999
   47 call resimi(tgspcsw(luswch))
      goto 9999
   48 call resimi(tgspcgr(luswch))
      goto 9999
   49 call resime(tgspcff(luswch))
      goto 9999
   50 call resimi(tgsppsw(luswch))
      goto 9999
   51 call resimi(tgsppsp(luswch))
      goto 9999
   52 call resime(tgsppff(luswch))
      goto 9999
   53 call resimi(tgrefsw(luswch))
      goto 9999
   54 call rearri(ldvbndx,nbnddvd+1,i)
      mdvbndx=i-1
      goto 9999
   55 if(hlp_spc) nspigen=0
      hlp_spc=.false.
      nspigen=nspigen+1
      if(nspigen.gt.natm) then !{
        write(0,*) 'Too many species: maximum ',natm
        call xerrab
     .   (' ==> Check the DG model and DEF_NATM in DIMENSIONS.F')
      end if !}
      call resimi(i)
      print *,'uinnam: species ',i,nspigen
      if(nspigen.ne.i) then !{
        write(0,*) '*** uinnam: wrong species order.  nspigen,i = ',
     ,    nspigen,i
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      goto 9999
   56 if(nspigen.le.0 .or. hlp_spc) then !{
        write(0,*) 'uinnam: species index undefined'
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      l=lena
      lena=2
      call resima(spcigen(nspigen))
      lena=l
      print *,'                          ==> ',spcigen(nspigen)
      goto 9999
   57 call resimi(i)
      ngpfstr=ngpfstr+1
      if(ngpfstr.ge.nstra) then !{
        write(0,*) 'Too many gas puffing strata specified'
        call xerrab
     .   (' ==> Check the DG model and DEF_NSTRA in DIMENSIONS.F')
      end if !}
      goto 9999
   58 if(ngpfstr.le.0) then !{
        write(0,*) 'uinnam: gas puffing strata index undefined'
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      if(lugpf.ge.nlim) then !{
        write(0,*) 'uinnam: too many slot surfaces for gas puff'
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      call rearri(lgpfstr(lugpf+1),nlim-lugpf,i)
      if(i.eq.0) then !{
        write(0,*) 'The slot specification is missing for gas puffing',
     ,    ' stratum',ngpfstr
        call xerrab
     .   (' ==> Check the "Gas puff" variables in the DG model')
      end if !}
      if(i.ge.nsrfs) then !{
        write(0,*) 'uinnam: too many segments for gas puff'
        call xerrab
     .   (' ==> Check the DG model and DEF_NSRFS in DIMENSIONS.F')
      end if !}
      if(maxval(lgpfstr).gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',
     .   maxval(lgpfstr)
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      kgpfstr(ngpfstr)=i
      lugpf=lugpf+i
      goto 9999
   59 call resimi(mgpfstr(ngpfstr))
      goto 9999
   60 l=lena
      lena=12
      call resima(cgpfstrs(ngpfstr))
      lena=l
      goto 9999
   61 call resime(fgpfstr(ngpfstr))
      goto 9999
   62 call resime(tgpfstr(ngpfstr))
      goto 9999
   63 call resimi(jgpfstr(ngpfstr))
      goto 9999
   64 call resime(pgpfstr(ngpfstr))
      goto 9999
   65 call resimi(npgpfstr(ngpfstr))
      goto 9999
   66 call resimi(nigpfstr(ngpfstr))
      goto 9999
   67 call resimi(jxi)
      goto 9999
   68 call resimi(jxa)
      goto 9999
   69 call resimi(laddsrfs)
      goto 9999
   70 call resime(u)
      zaa=2.0_R8*pi*u
      goto 9999
   71 call resimi(i)
      nlscl=i.ne.0
      goto 9999
   72 call resimi(ntcpu)
      goto 9999
   73 call resimi(nfile)
      goto 9999
   74 call resimi(lfrm15)
      goto 9999
   75 call resimi(nprnli)
      nprnli=min(nprnli,nprnl)
      goto 9999
   76 call resime(dtimv)
      goto 9999
   77 call rearre(xlpcntr,3,i)
      goto 9999
   78 call resimi(i)
      do_hepdt= i.ne.0
      goto 9999
   79 call resimi(locphep)
      goto 9999
   80 call resime(pwrhepdt)
      goto 9999
   81 call resime(pmphepdt)
      goto 9999
   82 call rearri(lstclhep,nxd,nstclhep)
      goto 9999
   83 call rearri(lhetrgts,nlim,nhetrgts)
      goto 9999
   84 call resimi(tgnhst(luswch))
      goto 9999
   85 call resimi(tgnini(luswch))
      goto 9999
   86 if(namdf.le.0) then !{
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
     ,        'expansion: ',uam
            call xerrab ('==> Check the DG model')
          end if !}
          amd_file(namdf)=uam
          write(*,*) 'Filename for AMDS reference expanded: ',uam
        else !}{
          amd_file(namdf)(i:i)=' '
          call lefta(amd_file(namdf),48,i)
          write(*,*) 'Filename for AMDS reference quoted: ',
     ,                                                  amd_file(namdf)
        end if !}
      else
        i=index(amd_file(namdf),'.')
        uam=amd_file(namdf)
        uam(i:i+4)='.amo ' ! xpb: was .amds extension
        call lefta(uam,52,i+4)
        amd_file(namdf)=uam
        write(*,*) 'Filename for AMDS reference quoted: ',
     ,                                                  amd_file(namdf)
      end if !}
      goto 9999
   87 call resimi(namdf)
      if(namdf.gt.namdfs) then !{
        write(0,*) 'Too many AMDS models specified - must be no more ',
     ,    'than',namdfs
        call xerrab
     .   ('==> Check the DG model or increase NAMDFS in uimpcon.inc')
      end if !}
      goto 9999
c-----------------------------------------------------------------------
c*** Chemical sputtering
   88 call resimi(i)
      nchsppri=nchsppri+1
      if(nchsppri.gt.nchsppr) then !{
        write(0,*) 'Too many chemical reactions specified.'
        write(0,*) 'STOP ==> check the DG model and the value of ',
     ,                                        'nchsppr in KOPPLDIM.F'
        call xerrab ('Too many chemical reactions specified')
      end if !}
      goto 9999
   89 if(nchsppri.le.0) then !{
        write(0,*) 'Chemical sputtering data outside the block - ',unn
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      l=lena
      lena=24
      call resima(chsptgt(nchsppri))
      lena=l
      goto 9999
c 9989 write(0,*) 'Unexpected end-of-file encountered in uinnam'
c      call xerrab (' ==> Corrupted DG output?')
   90 if(nchsppri.le.0) then !{
        write(0,*) 'Chemical sputtering data outside the block - ',unn
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resime(ychsptg(nchsppri))
      goto 9999
   91 l=lena
      if(nchsppri.le.0) then !{
        write(0,*) 'Chemical sputtering data outside the block - ',unn
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      lena=16
      call resima(chspspt(nchsppri))
      lena=l
      goto 9999
   92 if(nchsppri.le.0) then !{
        write(0,*) 'Chemical sputtering data outside the block - ',unn
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resimi(lchspnwl(nchsppri))
      goto 9999
   93 if(nchsppri.le.0) then !{
        write(0,*) 'Chemical sputtering data outside the block - ',unn
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resime(echsptg(nchsppri))
      goto 9999
   94 if(nchsppri.le.0) then !{
        write(0,*) 'Chemical sputtering data outside the block - ',unn
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resime(fchsptg(nchsppri))
      goto 9999
c-----------------------------------------------------------------------
c*** Surface data transfer from B2 to Eirene
   95 call resimi(i)
      n_spcsrf=n_spcsrf+1
      if(n_spcsrf.gt.DEF_NSPCSRFG) then !{
        write(0,*) 'Too many "Surface special" groups specified'
        write(0,*) 'STOP ==> check the DG model and the value of ',
     ,                                    'DEF_NSPCSRFG in DIMENSIONS.F'
        call xerrab ('Too many "Surface special" groups specified')
      end if !}
      if(n_spcsrf.ne.i) then !{
        write(0,*) '### Wrong order of "Surface special" groups - ',
     ,                                            'corrupted DG model?'
      end if !}
      goto 9999
   96 if(n_spcsrf.le.0) then !{
        write(0,*) '"Surface special" data outside the block - ',unn
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resime(sps_absr(n_spcsrf))
      goto 9999
   97 if(n_spcsrf.le.0) then !{
        write(0,*) '"Surface special" data outside the block - ',unn
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resime(sps_trno(n_spcsrf))
      goto 9999
   98 if(n_spcsrf.le.0) then !{
        write(0,*) '"Surface special" data outside the block - ',unn
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resime(sps_trni(n_spcsrf))
      goto 9999
   99 if(n_spcsrf.le.0) then !{ ####
        write(0,*) '"Surface special" data outside the block - ',unn
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resima(sps_mtrl(n_spcsrf))
      sps_mtri(n_spcsrf)=-1.0
      if(.not.streql(sps_mtrl(n_spcsrf),'-')) 
     -  call uinmtr(sps_mtrl(n_spcsrf),nint(sps_mtri(n_spcsrf)),1)
      goto 9999
  100 if(n_spcsrf.le.0) then !{
        write(0,*) '"Surface special" data outside the block - ',unn
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resime(sps_tmpr(n_spcsrf))
      goto 9999
  101 if(n_spcsrf.le.0) then !{
        write(0,*) '"Surface special" data outside the block - ',unn
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resime(sps_spph(n_spcsrf))
      goto 9999
  102 if(n_spcsrf.le.0) then !{
        write(0,*) '"Surface special" data outside the block - ',unn
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resime(sps_spch(n_spcsrf))
      goto 9999
  103 if(n_spcsrf.le.0) then !{
        write(0,*) '"Surface special" data outside the block - ',unn
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resimi(sps_sgrp(n_spcsrf))
      goto 9999
  104 if(n_spcsrf.le.0) then !{
        write(0,*) '"Surface special" data outside the block - ',unn
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call rearri(ll_spcsrf(1,n_spcsrf),nlimps,k_spcsrf(n_spcsrf))
      if(maxval(ll_spcsrf).gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',
     .   maxval(ll_spcsrf)
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      goto 9999
  105 if(n_spcsrf.le.0) then !{
        write(0,*) '"Surface special" data outside the block - ',unn
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resima(sps_id(n_spcsrf))
      goto 9999
  106 call resimi(i)
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
      goto 9999
  107 if(npfrgrp.le.0) then !{
        write(0,*) '"PFR surface group" data outside the block - ',unn
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resima(gpfrgrp(npfrgrp))
      goto 9999
  108 if(npfrgrp.le.0) then !{
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
      goto 9999
c-----------------------------------------------------------------------
c*** Limiter configuration (code cheating)
  109 lm_cnfg=.true.
      call skipit
      goto 9999
  110 call resimi(lm_vhst)
      goto 9999
  111 call resimi(lm_whst)
      goto 9999
c-----------------------------------------------------------------------
c*** Toroidal geometry
  112 call resime(roator)
      goto 9999
  113 call resimi(nttrator)
      goto 9999
c-----------------------------------------------------------------------
c*** Material properties of the grid edges
  114 nwllmrk=nwllmrk+1
      call skipit
      if(nwllmrk.gt.nwllmrkd) then !{
        write(0,*) 'Too many reference wall segments (spc_side)'
        call xerrab
     .   (' ==> Check the DG model or increase nwllmrkd in uinpcom')
      end if !}
      goto 9999
  115 if(nwllmrk.le.0) then !{
        write(0,*) 'Grid edge material data outside block (ref_wall)'
        call xerrab (' ==> Corrupted DG output?')
      else if(nwllmrk.le.nwllmrkd) then !}{
        call resimi(lwllmrk(nwllmrk))
      else !}{
        write(0,*) 'Too many reference wall segments (spc_side)'
        call xerrab
     .   (' ==> Check the DG model or increase nwllmrkd in uinpcom')
      end if !}
      goto 9999
  116 if(nwllmrk.le.0) then !{
        write(0,*) 'Grid edge material data outside block (edgemark)'
        call xerrab (' ==> Corrupted DG output?')
      else if(nwllmrk.le.nwllmrkd) then !}{
        call rearri(ledgmrk(1,nwllmrk),nedgmrkd,nedgmrk(nwllmrk))
      else !}{
        write(0,*) 'Too many reference wall segments (spc_side)'
        call xerrab
     .   (' ==> Check the DG model or increase nwllmrkd in uinpcom')
      end if !}
      goto 9999
  117 if(nwllmrk.le.0) then !{
        write(0,*) 'Grid edge material data outside block (trgtmark)'
        call xerrab (' ==> Corrupted DG output?')
      else if(nwllmrk.le.nwllmrkd) then !}{
        call rearri(ltrgmrk(1,nwllmrk),nedgmrkd,ntrgmrk(nwllmrk))
      else !}{
        write(0,*) 'Too many reference wall segments (spc_side)'
        call xerrab
     .   (' ==> Check the DG model or increase nwllmrkd in uinpcom')
      end if !}
      goto 9999
c-----------------------------------------------------------------------
c*** Data for diagnostics of wall erosion
  118 call resimi(nmcsptu)
      goto 9999
  119 call resime(emnspc)
      goto 9999
  120 call resime(emxspc)
      goto 9999
  121 call resimi(npspcen)
      goto 9999
  122 call resimi(npspctt)
      goto 9999
  123 call resimi(npspcfi)
      goto 9999
  124 call rearri(listmtmp,lntsputx,lntsptu)
      goto 9999
  125 l=lena
      lena=2
      call resima(txtmtra(1))
      lena=l
      goto 9999
  126 call resimi(dgntcpu)
      goto 9999
  127 call resimi(dgnptsfc)
      goto 9999
  128 call rearri(listaddi,nlim,nlstadu)
      goto 9999
  129 call resimi(lugwt)
      ngwtiesi=ngwtiesi+1
      if(ngwtiesi.gt.ngwtiesx) then !{
        write(0,*) 'uinnam: too many ties specified ( > ',ngwtiesx,' )'
        write(0,*) '  ==> Check the DG model'
        call xerrab ('Too many ties specified')
      end if !}
      goto 9999
  130 call resimi(kgwties(ngwtiesi))
      goto 9999
  131 call rearri(lgwties(1,ngwtiesi),mgwtiesx,mgwties(ngwtiesi))
      goto 9999
c-----------------------------------------------------------------------
c*** Data for visualisation of the surface properties
  132 call resimi(luvsp)
      if(luvsp.lt.0) then !{
        write(0,*) 'uinnam: negative view identifier - corrupted DG ',
     ,                                                       'output???'
        call xerrab ('Negative view identifier')
      else if(luvsp.gt.nsrfclsx) then !}{
        write(0,*) 'uinnam: too many views for surface coloring ',luvsp
        write(0,*) '  ==> Check the DG model or increase the nsrfclsx ',
     ,    'parameter in uinpcom.inc'
        call xerrab ('Too many views for surface coloring')
      end if !}
      nsrfcls=max(luvsp,nsrfcls)
      goto 9999
  133 call xertst (luvsp.gt.0 .and. luvsp.le.nsrfclsx,
     ,  'uinnam: undefined view identifier - corrupted DG output???')
      call resimi(isrfclu(luvsp,1))
      goto 9999
  134 call xertst (luvsp.gt.0 .and. luvsp.le.nsrfclsx,
     ,  'uinnam: undefined view identifier - corrupted DG output???')
      call resimi(isrfclu(luvsp,2))
      goto 9999
  135 call xertst (luvsp.gt.0 .and. luvsp.le.nsrfclsx,
     ,  'uinnam: undefined view identifier - corrupted DG output???')
      call resimi(isrfclu(luvsp,3))
      goto 9999
  147 l=i-135
 1147 call xertst (luvsp.gt.0 .and. luvsp.le.nsrfclsx,
     ,  'uinnam: undefined view identifier - corrupted DG output???')
      call resimi(i)
      if(i.gt.0) then !{
        msrfcls(luvsp)=msrfcls(luvsp)+1
        lsrfcls(msrfcls(luvsp),luvsp)=l
      end if !}
      goto 9999
c***  input trimark is the marker for TRIA mesh
  148 call rearri(ilplgdg,nlim,i)
      goto 9999
c***  input global mesh size
  149 call resime(trisize(0))
      goto 9999
c***  input index of rectangle 
  150 call resimi(ntriref)
      goto 9999
c***  input mesh size for current rectangle
  151 call xertst (ntriref.gt.0,
     ,  'uinnam: wrong index of TRIA regions - corrupted DG output???')
      if(ntriref.gt.ntrimax) then !{
        write(0,*) 'Too many TRIA regions: maximum ',ntrimax
        write(0,*) 'Current number of requested regions: ',ntriref
        call xerrab
     .   (' ==> Check the DG model and ntrimax in uinpcom.inc')
      end if !}
      call resime(trisize(ntriref))
      goto 9999
c***  input elements indices for current rectangle
  152 call rearri(trirefel(lurefls+1),ntrimax-lurefls,trirefcn(ntriref))
      if(maxval(trirefel).gt.nlim) then !{
        write(0,*) 'Too many wall elements: maximum ',nlim
        write(0,*) 'Current number of requested elements: ',
     .   maxval(trirefel)
        call xerrab
     .   (' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F')
      end if !}
      lurefls=lurefls+trirefcn(ntriref)
      goto 9999
  153 glb2read=.true.
      call skipit
      goto 9999
  154 call resime(pwrcrtti)
      goto 9999
  155 call resime(pwrcrtte)
      goto 9999
  156 call resime(pwrcrfri)
      pwrcrfri=max(0.,min(1.,pwrcrfri))
      goto 9999
  157 call resimi(i)
      usetmstr=i.ne.0
      goto 9999
  158 if(nspigen.le.0 .or. hlp_spc) then !{
        write(0,*) 'uinnam: species index undefined'
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resimi(spcicrk(nspigen))
      goto 9999
  159 if(nspigen.le.0 .or. hlp_spc) then !{
        write(0,*) 'uinnam: species index undefined'
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resime(spcicrp(nspigen))
      goto 9999
  160 if(nspigen.le.0 .or. hlp_spc) then !{
        write(0,*) 'uinnam: species index undefined'
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resime(spcicrf(nspigen))
      goto 9999
  161 if(nspigen.le.0 .or. hlp_spc) then !{
        write(0,*) 'uinnam: species index undefined'
        call xerrab (' ==> Corrupted DG output?')
      end if !}
      call resimi(spciscn(nspigen))
      if(spciscn(nspigen).ne.0) spciscn(nspigen)=1
      goto 9999
  162 call resimi(tgmhst(luswch))
      goto 9999
  163 call resimi(mpgpfstr(ngpfstr))
      goto 9999
c=======================================================================
 9999 call subend ()
      return
      end
