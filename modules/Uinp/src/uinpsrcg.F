      subroutine uinpsrcg
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
#include "uinput.inc"
      integer i,j,k,l,isg,istr,isf
      real*4 hlp,hlp1,hlp2,hlpeps,hlpeps2
      logical ex,uex
      parameter (hlpeps=1.e-6, hlpeps2=1.e-5)
c=======================================================================
c<<<
      print *,'uinpsrcg: ngpfstr=',ngpfstr
c>>>
      isg=0
      do istr=1,ngpfstr !{

      	nstrai=nstrai+1
        indsrc(nstrai)=-1
        ingpfstr(istr)=nstrai
c<<<
      	print *,'istr,nstrai,npts,kgpfstr,tgpfstr,cgpfstrs:',
     ,	  istr,nstrai,npts(nstrai),kgpfstr(istr),tgpfstr(istr),
     ,	  ' ',cgpfstrs(istr)
c>>>
        if(nstrai.ge.nstra) then !{
          write(0,*) 'Too many strata requested (gas puff',istr,') : ',
     ,        	     nstrai
          write(0,*) 'STOP ==> check the DG model and the value of ',
     ,  		'DEF_NSTRA in DIMENSIONS.F'
          stop
        end if !}
        if(kgpfstr(istr).gt.nsrfs) then !{
          write(0,*) 'Too many segments requested (gas puff',istr,
     ,        	     ') : ',kgpfstr(istr)
          write(0,*) 'A gas puffing source cannot span over more then ',
     ,        	     nsrfs,' wall segments'
          write(0,*) 'STOP ==> check the DG model and the value of ',
     ,  	     'DEF_NSRFS in DIMENSIONS.F'
          stop
        end if !}
        if(kgpfstr(istr).le.0) then !{
          write(0,*) 'No segments specified (gas puff',istr,
     ,        	     ') : ',kgpfstr(istr)
          write(0,*) 'A gas puffing source must span over at least ',
     ,        	     'one wall segment'
          stop '==> This should not be allowed in DG - wrong setup?'
        end if !}
	nsrfsi(nstrai)=kgpfstr(istr)

        write(txtsou(nstrai),*)  'Gas puffing source',istr,' : ',
     ,  			cgpfstrs(istr)
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
     ,        	     'source',istr,' : ',cgpfstrs(istr)
	  write(0,*) '(must be either atom or molecule)'
	  stop '==> Check the DG model'
	end if !}
	nlatm(nstrai)=l.eq.1
	nlmol(nstrai)=l.eq.2
	nlpls(nstrai)=.false.
	nspez(nstrai)=k

	do isf=1,nsrfsi(nstrai) !{
	  isg=isg+1
	  k=lgpfstr(isg)
	  if(k.le.0) then !{
	    write(0,*) 'Wrong segment specification for gas puffing ',
     ,        	       'source',istr,', segment',isf,' : ',k
            stop '==> This should not be allowed in DG - wrong setup?'
	  end if !}
	  if(indasrfe(k).le.0) then !{
	    write(0,*) 'Wrong segment specification for gas puffing ',
     ,    	       'source',istr,' : ',isf,k
	    write(0,*) 'The segment should not belong to the ',
     ,    	       '"Elements not for Eirene"'
	    stop '==> Check the DG model'
	  end if !}
	  indim(isf,nstrai)=4
	  insor(isf,nstrai)=indasrfe(k)
          ingrda(isf,nstrai,1)=1
          ingrde(isf,nstrai,1)=1
          ingrda(isf,nstrai,2)=1
          ingrde(isf,nstrai,2)=1
	  sorifl(isf,nstrai)=1000
	  nrsor(isf,nstrai)=-1
	  nasor(isf,nstrai)=0
          sorlim(isf,nstrai)=104
          sorad1(isf,nstrai)=0
          sorad2(isf,nstrai)=0
          sorad3(isf,nstrai)=0
          sorad4(isf,nstrai)=0
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
	    if(srcmstrs(j,istr).eq.spcsncl(i)) then !{
	      if(ex) then !{
	      	write(0,*) 'Ambigous definition of source scaling for ',
     ,		  'the gas puffing source ',istr
	      	stop '==> Check "Gas puff" variables in the DG model'
	      end if !}
	      do k=1,nspcncl !{
	     	if(spcsncl(k).eq.wrcmstrs(j,istr)) then !{
                  lsgpfstr(i,istr)=k*spcsscn(i)
#ifdef DBG
              print *,'uinpsrcg: k,i,j,istr,lsgpfstr,spcsscn=',k,i,j,
     ,                                 istr,lsgpfstr(i,istr),spcsscn(i)
#endif
	        end if !}
              end do !}
	    end if !}
	  end do !}
	  if(.not.ex) then !{
	    uex=.false.
	    do k=1,nspcncl !{
	      if(igpfstr(k,istr).gt.0) then !{
	      	if(.not.ex) lsgpfstr(i,istr)=k*spcsscn(i)
		uex=ex
		ex=.true.
	      end if !}
	    end do !}
	    if(uex) then !{
	      write(0,*) 'Default source scaling cannot be used for a ',
     ,	      	'compound puffing source ',istr
	      write(0,*) ' ==> no source scaling for stratum/species ',
     ,	      	istr,i
	      lsgpfstr(i,istr)=0
	    end if !}
	  end if !}
	end do !}
	
      end do  !} istr
c=======================================================================
      end
