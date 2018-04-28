      subroutine uinpscrd
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx

c  version : 04.02.2005 18:37

c=======================================================================
c  Produce surface interaction cards 
c=======================================================================
      implicit none
#include "uinput.inc"
      integer i,ii,j,k,kk,kkk,nn,ind 
cank      logical checknds,checkas
      integer chemindex(maxchmvar)
      logical streql
      external streql

c***  makes table of additional variables for 
c***  chemical sputtering
      call initchemspt

      k=0
c*** Non-Default Standard surfaces
      do 10 i=1,nstsi !{
        if (.NOT.(iliin(i).eq.1 .or. bliin(i))) then  !{
c** if we do not need surface card for this surface
          iscrd(i)=0 
          goto 10
        end if !}
        do 11 j=1,k !{
         if(checknds(j,i)) then !{
          iscrd(i)=j 
          goto 10
         end if !}
   11   continue !}
       k=k+1 
       call getnds(k,i)
       iscrd(i)=k
   10 continue !}
  
c*** Additional surfaces
        do 20 i=laddsrfs+1,nlimi !{
        ind=indasrfs(i)
        if (.NOT.jliin(ind).eq.1) then  !{
c** if we do not need surface card for this surface            
          jscrd(ind)=0 
          goto 20
        end if !}
        do 21 j=1,k !{
         if(checkas(j,ind)) then !{
          jscrd(ind)=j 
          goto 20
         end if !}
   21   continue !}
       k=k+1
       call getas(k,ind)
       jscrd(ind)=k
   20 continue !}   
      nscards=k

c*** the table of additional variables for chemical sputtering
      kk=0
      kkk=0
      do 30 i=1,nscards !{
       nn=0         
       do 31 j=1,nchemvar !{
        if(checkchm(j,i)) then !{
         nn=nn+1
         kk=kk+1 
         indchemvar(kk)=j
        end if !}
   31  continue !}
       kkk=kkk+1
       nnchemvar(kkk)=nn
   30 continue !}

c*** special treatment for C chemical sputtering by H
c      do 40 i=1,nscards !{
c       if(scxmlim(i).1206) call checkforcarbon(i)  
c   40 continue  !}     

      if (nscards.ne.1) then !{
        write(*,*) nscards,' surface interaction cards are prepared'
      else !}{
        write(*,*) nscards,' surface interaction card is prepared'
      endif !}

c=======================================================================
      contains
c***  internal subroutines      

c=======================================================================
c***  fill surface card number k for NDS number ists 
       subroutine getnds(k,ists) !{
c        character*(72) cardname
        integer k,ists

        scilref(k)=ilref(ists)
        ii=10*ilsptc(ists)+ilsptp(ists)
        scilspt(k)=ii
        scisrs(k)=isrss(ists)
        scisrc(k)=0
        sclchspnwl(k)=1

        scxmlim(k)=xmlim(ists)
        scewall(k)=ewall(ists)
        scewbin(k)=ewbin(ists)
        sctransp(k,1)=transp(ists,1)
        sctransp(k,2)=transp(ists,2)
        scfsheat(k)=FSHEAT(ists)
        screcycf(k)=recycf(ists)
        screcyct(k)=recyct(ists)
        scexppl(k)=exppl(ists)
        scexpel(k)=expel(ists)
        scexpil(k)=expil(ists)
        screcycs(k)=recycs(ists)
        scychsptg(k)=recycc(ists)
        scechsptg(k)=1.0
        scfchsptg(k)=0.0
       
        scard_name(k)=cardname(k)

        scisrsg(k)=isrsg(ists)
       end subroutine !}

c=======================================================================
c***  check if surface card for NDS k is already present in the list  
       logical function checknds(k,ists) !{
        integer k,ists

        checknds=.TRUE.
        ii=10*ilsptc(ists)+ilsptp(ists)
        if(scilref(k).NE.ilref(ists)
     .    .OR.scilspt(k).NE.ii
     .    .OR.scisrs(k).NE.isrss(ists)
     .    .OR.scxmlim(k).NE.xmlim(ists)
     .    .OR.scewall(k).NE.ewall(ists)
     .    .OR.scewbin(k).NE.ewbin(ists)
     .    .OR.sctransp(k,1).NE.transp(ists,1)
     .    .OR.sctransp(k,2).NE.transp(ists,2)
     .    .OR.scfsheat(k).NE.FSHEAT(ists)
     .    .OR.screcycf(k).NE.recycf(ists)
     .    .OR.screcyct(k).NE.recyct(ists)
     .    .OR.scexppl(k).NE.exppl(ists)
     .    .OR.scexpel(k).NE.expel(ists)
     .    .OR.scexpil(k).NE.expil(ists)
     .    .OR.scychsptg(k).NE.recycc(ists)
     .    .OR.screcycs(k).NE.recycs(ists)
     .    .OR.scisrsg(k).NE.isrsg(ists))
     .     checknds=.FALSE.
       end function checknds !}

c***  fill surface card number k for AS number i
       subroutine getas(k,i) !{
c        character*(72) cardname
        integer k,i

        scilref(k)=jlref(i)
        ii=10*jlsptc(i)+jlsptp(i)
        scilspt(k)=ii
        scisrs(k)=jsrss(i)
        scisrc(k)=0
        sclchspnwl(k)=1

        scxmlim(k)=xmlma(i)
        scewall(k)=ewala(i)
        scewbin(k)=ewbna(i)
        sctransp(k,1)=trnspa(i,1)
        sctransp(k,2)=trnspa(i,2)
        scfsheat(k)=FSHEATA(i)
        screcycf(k)=rcycfa(i)
        screcyct(k)=rcycta(i)
        scexppl(k)=exppla(i)
        scexpel(k)=expela(i)
        scexpil(k)=expila(i)
        screcycs(k)=rcycsa(i)
        scychsptg(k)=rcycca(i)
        scechsptg(k)=1.0
        scfchsptg(k)=0.

        scard_name(k)=cardname(k)

        scisrsg(k)=jsrsg(i)
       end subroutine getas !}

c=======================================================================
c***  check if surface card for AS k is already present in the list   
       logical function checkas(k,i) !{
        integer k,i

        checkas=.TRUE.
        ii=10*jlsptc(i)+jlsptp(i)
        if(scilref(k).NE.jlref(i)
     .    .OR.scilspt(k).NE.ii
     .    .OR.scisrs(k).NE.jsrss(i)
     .    .OR.scxmlim(k).NE.xmlma(i)
     .    .OR.scewall(k).NE.ewala(i)
     .    .OR.scewbin(k).NE.ewbna(i)
     .    .OR.sctransp(k,1).NE.trnspa(i,1)
     .    .OR.sctransp(k,2).NE.trnspa(i,2)
     .    .OR.scfsheat(k).NE.FSHEATA(I)
     .    .OR.screcycf(k).NE.rcycfa(i)
     .    .OR.screcyct(k).NE.rcycta(i)
     .    .OR.scexppl(k).NE.exppla(i)
     .    .OR.scexpel(k).NE.expela(i)
     .    .OR.scexpil(k).NE.expila(i)
     .    .OR.scychsptg(k).NE.rcycca(i)
     .    .OR.screcycs(k).NE.rcycsa(i)
     .    .OR.scisrsg(k).NE.jsrsg(i))
     .     checkas=.FALSE.
       end function checkas !}

c=======================================================================
c***  function to generate surface card name for reaction k
c***  name format:
C***  SURFMOD_k_<MATERIAL>_<SPUTER>_<PUMP>_<SEMYTRANSP>_<TEMPERATURE K>
       character*(72) function cardname(k) !{
        integer k 
        character*(72) cnam,txtbuf
        real znml
        integer twll
        integer len_of_digits
        external len_of_digits
        if(k.LT.10) then
           write(cnam,'(A8,I1)') 'SURFMOD_',k
        else
           write(cnam,'(A8,I2)') 'SURFMOD_',k
        end if 
        znml=scxmlim(k)
        txtbuf='_'
        if(znml.EQ.5626.) then
         txtbuf='_IRON'
        else if(znml.EQ.18474.) then
         txtbuf='_TUNGSTEN'
        else if(znml.EQ.904.) then
         txtbuf='_BERYLLIUM'
        else if(znml.EQ.1206.) then
         txtbuf='_CARBON'
        else if(znml.EQ.9642.) then
         txtbuf='_MOLYBDENUM'
        end if
        cnam=cnam(1:len_trim(cnam))//txtbuf(1:len_trim(txtbuf))
        if(scilspt(k).NE.0) cnam=cnam(1:len_trim(cnam))//'_SPT'
        if(screcycf(k).LT.1.0.OR.screcyct(k).LT.1.0) 
     .                   cnam=cnam(1:len_trim(cnam))//'_PUMP'
        if(sctransp(k,1).GT.0.OR.sctransp(k,2).GT.0) 
     .                   cnam=cnam(1:len_trim(cnam))//'_SMTRANS'
        if(scewall(k).LT.0) then
          twll=nint(abs(scewall(k))*11600) !wall temperature in K 
          write(txtbuf,'(i6,a1)') twll,'K'
          txtbuf=adjustl(txtbuf)
          cnam=cnam(1:len_trim(cnam))//'_'//
     .         txtbuf(1:len_of_digits(twll)+1)
        end if
        cardname=cnam
       end function cardname !} 

c=======================================================================
c***   makes table of additional variables for 
c***   chemical sputtering
       subroutine initchemspt !{
       integer i,k,itp,spz
       character*(8) speciename
       k=0 
       do 10 i=1,nchsppri !{
        itp=lchspprt(i) 
        spz=lchspprp(i)  
        if(itp.EQ.1) then !{
         speciename=texta(spz)
        else if(itp.EQ.2) then 
         speciename=textm(spz)
        else if(itp.LE.3) then
         speciename=texti(spz)
        else if(itp.LE.4) then
         speciename=textp(spz)
        else !}{
         write(0,*) 
     ,   'WARNING: indefinite species type in chemical sputtering data'
         goto 10 
        end if !}
        k=k+1 
        chvarname(k)='ISRC'
        chmspname(k)=speciename
        itp=lchsptgt(i)
        if(itp.EQ.1) then !{
         chmvar(k)=lchsptgp(i)
        else if(itp.EQ.2) then !}{
         chmvar(k)=lchsptgp(i)+natmi
        else !}{
          write(0,*) 
     ,    'WARNING: indefinite species type in chemical sputtering data'      
        end if !}
        chemindex(k)=i
        k=k+1
        chvarname(k)='LCHSPNWL'
        chmspname(k)=speciename
        chmvar(k)=lchspnwl(i)
        chemindex(k)=i
        k=k+1        
        chvarname(k)='RECYCC'
        chmspname(k)=speciename
        chmvar(k)=ychsptg(i)
        chemindex(k)=i
        k=k+1
        chvarname(k)='ESPUTC'
        chmspname(k)=speciename
        chmvar(k)=echsptg(i)
        chemindex(k)=i
   10  continue !}
       nchemvar=k
       write(0,*) 
     .  'The number of additional variables, nchemvar ', nchemvar    
       end subroutine initchemspt !}

c=======================================================================
c***  checks if additional chemical sputtering variable 
c***  number ch is suitable for surface card number i
       logical function checkchm(ch,i) !{
        integer ch,i,j
        j=chemindex(ch)                    
        if(scxmlim(i).EQ.lchsptrg(j).AND.
     .     scisrsg(i).EQ.lchspgrp(j)) then !{
          checkchm=.TRUE.  
          if(streql(chvarname(ch),'RECYCC')
     .       .AND.chmvar(ch).EQ.scychsptg(i))
     .     checkchm=.FALSE.                                 
        else !}{
          checkchm=.FALSE.
        end if !}
       end function checkchm !}

c=======================================================================
c*** special treatment for chemical sputtering variables with carbon surface      
c       subroutine checkforcarbon(i) !{ 
c       if(scxmlim(i).NE.1206) return
       
c       do j=1,nnchemvar(i) !{
c         k=k+1 
c         ich=indchemvar(k)
c         if(streql(chvarname(ich),'ISRC').OR.
c     .      streql(chvarname(ich),'LCHSPNWL')) then !{
c            write(iunoo,717) chvarname(ich),chmspname(ich),
c     ,                       nint(chmvar(ich))
c         else !}{
c            write(iunoo,716) chvarname(ich),chmspname(ich),chmvar(ich)   
c         end if  !}
c       end do !}

c       end subroutine checkforcarbon !}

c=======================================================================
      end subroutine uinpscrd
