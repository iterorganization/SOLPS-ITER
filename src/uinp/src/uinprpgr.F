      subroutine uinprpgr

c  version : 15.03.2001 17:03

c=======================================================================
c*** Prepare the grid data - dimensions and cuts
c=======================================================================
#include "uinput.inc"
      logical ex
c=======================================================================
c*** Now, unlike the previous version, nrsol, nrpfl, nz[io]dv, nzinn,
c*** together with nrsol1, nz[io]dv2, and nzinn2, are the numbers of
c*** regular cells in the corresponding region of the grid.
c*** izc?, iztg, irsp, irsp2, and irwl are the numbers of grid surfaces
c***
c***  	      	      	      	     DNL
c***   irwl -------------------------------------------------------
c***  	    |                 	      |           	      	  |
c***  nrsol |                 	      |           	      	  |
c***  	    |                 	      |           	      	  |
c***  irsp2 |.........................|...........................|
c***  	    | 	      	     :	      |       :   	      	  |
c*** nrsol1 | 	      	     :	      |       :   	      	  |
c***  	    | 	      	     :	      |       :   	      	  |
c***   irsp |................:	      |       :...................|
c***  	    | 	   :  	     :	      |       :   	 :    	  |
c***  nrpfl | 	   :  	     :	      |       :   	 :    	  |
c***  	    | 	   :  	     :	      |       :   	 :    	  |
c***  	    -------------------------------------------------------
c***  	      nzidv \ nzinn /  nzodv /	nzidv2 \ nzinn2 / nzodv2 /
c***  	      	    izc1 izc3 	  izci	      izc4   izc2     iztg
c***
c***  	      	      	      	     DNU
c***   irwl -------------------------------------------------------
c***  	    |                 	      |           	      	  |
c***  nrsol |                 	      |           	      	  |
c***  	    |                 	      |           	      	  |
c***   irsp |.........................|...........................| 	    
c***  	    |	   :		      |         	 :	  |
c*** nrsol1 |	   :		      |         	 :	  |
c***  	    |	   :		      |         	 :	  |
c***  irsp2 |	   :..................|..................:        |
c***  	    |	   :	    :	      |       : 	 :	  |
c***  nrpfl |	   :	    :	      |       : 	 :	  |
c***  	    |	   :	    :	      |       : 	 :	  |
c***  	    -------------------------------------------------------
c***  	      nzidv \ nzinn /  nzodv /	nzidv2 \ nzinn2 / nzodv2 /
c***  	      	    izc1 izc3 	  izci	      izc4   izc2     iztg
c***
c***  	      	      	      	     DNS
c***   irwl -------------------------------------------------------
c***  	    |                 	      |           	      	  |
c***  nrsol |                 	      |           	      	  |
c***  	    |                 	      |           	      	  |
c***   irsp |.........................|...........................| 	    
c***  	    |	   :	    :	      |       : 	 :	  |
c***  nrpfl |	   :	    :	      |       : 	 :	  |
c***  	    |	   :	    :	      |       : 	 :	  |
c***  	    -------------------------------------------------------
c***  	      nzidv \ nzinn /  nzodv /	nzidv2 \ nzinn2 / nzodv2 /
c***  	      	    izc1 izc3 	  izci	      izc4   izc2     iztg
c***
c***  	      	     SNL, SNU
c***   irwl ---------------------------
c***        |                 	      |
c***  nrsol |                 	      |
c***        |                 	      |
c***   irsp |.........................|
c***        |	   :	    :	      |
c***  nrpfl |	   :	    :	      |
c***        |	   :	    :	      |
c***        ---------------------------
c***          nzidv \ nzinn /  nzodv /
c***  	      	    izc1 izc2 	  iztg
c***  
c***             SNL, SNU - Limiter
c***   irwl ------------------------------
c***        |G|                        |G|
c***  nrsol |G|                        |G| Limiter, usual guard cell
c***        |G|                        |G|
c***   irsp |G|........................|G|
c***        |X:                        :X|
c***  nrpfl |X:                        :X| Core, isolated cell
c***        |X:                        :X|
c***        ------------------------------
c***         0 \         nzinn         / \
c***  	       izc1                 izc2 iztg
c=======================================================================
c*** Grig dimensions and cut locations

      ex=.false.
      if(lm_cnfg) then	!{
c*** Limiter configuration - a temporary, clumsy solution
        if(index(topo,'SN').eq.0) then !{
          write(*,*) 'A single-null topology should be used for a ',
     ,      'limiter configuration'
          write(*,*) '==> Check the DG model'
          stop
        end if !}
        ex=.true.
      	ntrgdflt=2
	nzidv=0
	nzodv=0
	nrsol1=0
	nrpfl=npr(3)-1
	nrsol=npr(1)-1
	nzinn=nptseg(3)-1
	nzidv2=0
	nzodv2=0
	nzinn2=0
	irsp=nrpfl+1
	irsp2=0
	irwl=irsp+nrsol
	izc1=1
	izc2=izc1+nzinn
	iztg=izc2
	izc3=0
	izc4=0
	izci=0
        nncut=2
        nycut2(1)=nrpfl
        nycut2(2)=nycut2(1)
        ny=nrpfl+nrsol
        nxcut1(1)=nzidv
        nxcut1(2)=nxcut1(1)+nzinn
        nx=nxcut1(2)+nzodv
        nniso=2
        ntiso(1)=0
        ntiso(2)=0
        nxiso1(1)=0
        nxiso1(2)=nx+1
        nxiso2(1)=nxiso1(1)
        nxiso2(2)=nxiso1(2)
        nyiso1(1)=0
        nyiso2(1)=nycut2(1)
        nyiso1(2)=nyiso1(1)
        nyiso2(2)=nyiso2(1)
      else if(index(topo,'DN').gt.0) then  !}{
      	ntrgdflt=4
	if(topo.eq.'DNS') then	!{
	  nrsol1=0
	  nrpfl=npr(5)-1
	  nrsol=npr(1)-1
	  irsp=nrpfl+1
	  irsp2=irsp
	  ex=.true.
      	else if(topo.eq.'DNL') then !}{
	  nrsol1=npr(1)-1
	  nrpfl=npr(6)-1
	  nrsol=npr(2)-1
	  irsp=nrpfl+1
	  irsp2=irsp+nrsol1
	  ex=.true.
      	else if(topo.eq.'DNU') then !}{
	  nrsol1=npr(1)-1
	  nrpfl=npr(6)-1
	  nrsol=npr(2)-1
	  irsp2=nrpfl+1
	  irsp=irsp2+nrsol1
	  ex=.true.
	end if	!}
	if(ex) then !{
	  nzidv=nptseg(6)-1
	  nzinn=nptseg(4)-1
	  nzodv=nptseg(2)-1
	  nzidv2=nptseg(1)-1
	  nzinn2=nptseg(3)-1
	  nzodv2=nptseg(5)-1
	  izc1=nzidv+2
	  izc3=izc1+nzinn
	  izci=izc3+1+nzodv
	  izc4=izci+3+nzidv2+1
	  izc2=izc4+nzinn2
	  iztg=izc2+1+nzodv2
	  irwl=nrpfl+nrsol1+nrsol+1
	  nncut=4
	  nniso=1
          ntiso(1)=1
	  nycut2(1)=irsp-1
	  nycut2(2)=irsp2-1
	  nycut2(3)=nycut2(2)
	  nycut2(4)=nycut2(1)
	  ny=nrpfl+nrsol1+nrsol
	  nxcut1(1)=nzidv
	  nxcut1(2)=nxcut1(1)+nzinn
	  nxiso1(1)=nxcut1(2)+nzodv+1
	  nxcut1(3)=nxiso1(1)+1+nzidv2
	  nxcut1(4)=nxcut1(3)+nzinn2
	  nx=nxcut1(4)+nzodv2
          nxiso2(1)=nxiso1(1)
          nyiso1(1)=0
          nyiso2(1)=ny+1
	end if	!}
      else if(index(topo,'SN').gt.0) then !}{
      	ntrgdflt=2
      	if(topo.eq.'SNL') then	!{
	  nzidv=nptseg(2)-1
	  nzodv=nptseg(1)-1
	  ex=.true.
      	else if(topo.eq.'SNU') then !}{
	  nzidv=nptseg(1)-1
	  nzodv=nptseg(2)-1
	  ex=.true.
	end if	!}
	if(ex) then !{
	  nrsol1=0
	  nrpfl=npr(3)-1
	  nrsol=npr(1)-1
	  nzinn=nptseg(3)-1
	  nzidv2=0
	  nzodv2=0
	  nzinn2=0
	  irsp=nrpfl+1
	  irsp2=0
	  irwl=irsp+nrsol
	  izc1=nzidv+2
	  izc2=izc1+nzinn
	  iztg=izc2+1+nzodv
	  izc3=0
	  izc4=0
	  izci=0
          nncut=2
          nniso=0
          nycut2(1)=nrpfl
          nycut2(2)=nycut2(1)
          ny=nrpfl+nrsol
          nxcut1(1)=nzidv
          nxcut1(2)=nxcut1(1)+nzinn
          nx=nxcut1(2)+nzodv
        end if  !}
      end if  !}
      if(.not.ex) then	!{
      	write(*,*) 'Non-recognisable topology option : ',topo
	write(*,*) '  ==> Check the topology name in the DG model'
	write(*,*) '  	  (should be one of SNL SNU DNL DNU DNS)'
	stop
      end if  !}

      nr1st=irwl
      nrplg=iztg
      np2nd=nrplg
      ndxa=nrplg-1
      ndya=nr1st-1
      npplg = max((nncut/2)*3,1)
      if(lm_cnfg) npplg=1
c!###{
c      print *,'uinprpgr: nx,ny,nncut,nxcut{4},nycut{4},nniso,nxiso = ',
c     , nx,ny,nncut,nxcut1,nycut2,nniso,nxiso1(1)
c      print *,'nzidv,nzinn,nzodv,nzidv2,nzinn2,nzodv2 = ',
c     , nzidv,nzinn,nzodv,nzidv2,nzinn2,nzodv2
c      print *,'izc1,izc3,izci,izc4,izc2,iztg = ',
c     , izc1,izc3,izci,izc4,izc2,iztg
c      print *,'nrpfl,nrsol,nrsol1,irwl,irsp,irsp2 = ',
c     , nrpfl,nrsol,nrsol1,irwl,irsp,irsp2
c!###}
c=======================================================================
      end
