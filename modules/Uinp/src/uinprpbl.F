      subroutine uinprpbl
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
      implicit none

c======================================================================
c*** Modify the particle lists to take into account bundling
c======================================================================
#include "uinput.inc"
      integer i, j, l, ic, iquote, quote_count, nc, maxne, ncnct, iyear
      integer nplsb, ianf, iend, iplsb, ja, je, ichr, ireac, jreac, iss
      integer iknd, ipls
      integer, allocatable :: janf(:), jend(:), ipls1(:)
      integer, allocatable :: spcsrnb(:), nmsecb(:),
     .                        spcsmsb(:), spcsncb(:), spcscgb(:),
     .                        spcsfub(:), spcsrsb(:),
     .                        nprtb(:), nmassb(:), ncharb(:), nchrgb(:),
     .                        lkindb(:), iflbb(:), isrfb(:), isrtb(:),
     .                        nrcb(:), nreb(:), idnslmb(:),
     .                        nfolb(:), ngenb(:), nhstb(:),
     .                        ireacb(:,:), ibulkb(:,:), iscdeb(:,:),
     .                        iscd1b(:,:), iscd2b(:,:), iscd3b(:,:),
     .                        iscd4b(:,:)
      real (kind=R8), allocatable :: dplsb(:), bmasb(:), fctb(:),
     .                               eelecb(:,:), ebulkb(:,:),
     .                               escd1b(:,:), escd2b(:,:),
     .                               freacb(:,:)
      character*8, allocatable :: spcsrfb(:), spcsrtb(:), spcsplb(:),
     .                            textb(:)
      character*80 message, zeile
      logical lfirst
      logical, allocatable :: done(:)
      character*200 fnzav
c     filename of actual file opened
      character*256 adasfile, uidin
c     helpers for reading in data
      integer IZMAX,IZ1MIN,IZ1MAX
      integer isdimd,iddimd,itdimd
      parameter (isdimd=92+1,iddimd=100,itdimd=100)
      character dnr_ele*12
      integer nptnl,ndptnl,ndptn,ndptnc,ndcnct
      parameter (ndptnl=4,ndptn=128,ndptnc=256,ndcnct=100)
      integer nptn(ndptnl),nptnc(ndptnl,ndptn)
      integer iptnla(ndptnl),iptna(ndptnl,ndptn)
      integer iptnca(ndptnl,ndptn,ndptnc)
      integer icnctv(ndcnct)
      integer iblmx,ismax
      integer isppr(isdimd),ispbr(isdimd),isstgr(isdimd)
      integer IDMAXDzav,ITMAXDzav
      logical lres,lstan,lptn,ex
      real (kind=R8) :: dnr_ams
      integer, allocatable :: izpmin(:), izpmax(:)
c     log10 of densities (in 1/cm3), temperatures (in eV)
      real (kind=R8) ::
     *   DDENSDzav(iddimd),DTEVDzav(itdimd)
c     log10 of rate coefficients (in cm3/s)
c     effective coefficients
      real (kind=R8) :: DZAV(isdimd,itdimd,iddimd)
c     helpers for composing filenames
      character SUBDIRrec*4,SUBDIRion*4,SUBDIRcex*4
      character SUBDIRprb*4,SUBDIRplt*4,SUBDIRzav*4
      character SUBDIRpot*4
      character ES*2, EB*2, YEAR*2, Bdescr*8, filename*256
c     procedures
      integer get_atomic_number
      real (kind=R8) :: rratio
      logical silent_open, streql
      external silent_open, streql
      external get_atomic_number, lower_case, xxdata_11, rratio
      external subini, subend, xertst, xerrab
c======================================================================
      call subini ('uinprpbl')

      lfirst = .true.
      nplsb = nspcpls
      allocate(janf(nspigen),jend(nspigen))
      allocate(spcsrnb(nplsi),spcsrfb(nplsi),spcsrtb(nplsi),
     .         spcsmsb(nplsi),spcsncb(nplsi),spcscgb(nplsi),
     .         spcsfub(nplsi),spcsrsb(nplsi),spcsplb(nplsi))
      allocate(nprtb(nplsi),nmassb(nplsi),ncharb(nplsi),nchrgb(nplsi),
     .         iflbb(nplsi),lkindb(nplsi),textb(nplsi),
     .         isrfb(nplsi),isrtb(nplsi),ipls1(nplsi+nbgk),
     .         dplsb(nplsi),bmasb(nplsi),fctb(nplsi),nmsecb(nplsi))
      allocate(nrcb(nplsi),nreb(nplsi),idnslmb(nplsi),
     .         nfolb(nplsi),ngenb(nplsi),nhstb(nplsi),
     .         ireacb(nplsi,nreac), ibulkb(nplsi,nreac),
     .         iscd1b(nplsi,nreac), iscd2b(nplsi,nreac),
     .         iscd3b(nplsi,nreac), iscd4b(nplsi,nreac),
     .         iscdeb(nplsi,nreac),
     .         eelecb(nplsi,nreac), ebulkb(nplsi,nreac),
     .         escd1b(nplsi,nreac), escd2b(nplsi,nreac),
     .         freacb(nplsi,nreac))
      iss = 0
      ianf = 1
      janf(1) = 1
      jend(1) = 0
      spcsrnb = 0
      ipls1 = 0
      nrcb = 0
      nreb = 0
      ireacb = 0
      ibulkb = 0
      iscd1b = 0
      iscd2b = 0
      iscd3b = 0
      iscd4b = 0
      iscdeb = 0
      izamin = 0
      izamax = 0
      eelecb = 0.0_R8
      ebulkb = 0.0_R8
      escd1b = 0.0_R8
      escd2b = 0.0_R8
      freacb = 0.0_R8
      do l=1,nbgk !{
        ipls1(nplsi+l)=nplsi+l
      end do !}
      do l=1,nspigen !{
        if (l.gt.1) then !{
          nc = get_atomic_number(spcigen(l-1))
          ianf = ianf + nc
          janf(l) = jend(l-1) + 1
        end if !}
        nc = get_atomic_number(spcigen(l))
        iend = ianf + (nc-1)
        if (.not.is_bundled(l)) then !{
          nbndl(l) = nc+1
          do j = 0, nc !{
            izamin(iss) = j
            izamax(iss) = j
            iss = iss + 1
          end do !} 
          if (l.gt.1) then !{
            do j = ianf, iend !{
              ipls1(j) = jend(l-1) + j - ianf + 1
            end do !}
            jend(l) = jend(l-1) + nc
          else !}{
            do j = ianf, iend !{
              ipls1(j) = j - ianf + 1
            end do !}
            jend(1) = nc
          end if !}
          cycle
        end if !}
        if (lfirst) write(6,1028)
        write(6,*) 'Bundling ',spcigen(l)
        write(6,*) spcigen(l), ianf, iend
        allocate(izpmin(0:nc), izpmax(0:nc))
        filename='ratadas.filelist'
        call find_file(filename,ex)
        if(silent_open(99,filename,
     .             'data.local|modules/B2.5/Database',adasfile)) then !{
          read(99,*) uidin
          read(99,*) maxne
          if (nc.gt.maxne) then !{
            write(*,*) 'ADAStables: element number',nc,
     .                            'not supported!'
            call xerrab ('Unsupported ADAS element')
          endif !}
c     jump over the preceding lines
          do i=1,nc-1 !{
            read(99,*) SUBDIRrec,SUBDIRion,
     &                 SUBDIRcex,SUBDIRprb,
     &                 SUBDIRplt,SUBDIRzav,SUBDIRpot,ES
          enddo !}
c     now read the relevant line
          read(99,'(a80)') ZEILE
          quote_count = 0
          iquote = index(ZEILE,'''')
          do while (iquote.gt.0) !{
            quote_count=quote_count+1
            if (index(ZEILE(iquote+1:80),'''').ne.0) then !{
              iquote = index(ZEILE(iquote+1:80),'''') + iquote
            else !}{
              iquote = 0
            endif !}
          enddo !}
          if (quote_count.eq.16) then !{
            read(ZEILE,*) SUBDIRrec,SUBDIRion,
     &                    SUBDIRcex,SUBDIRprb,
     &                    SUBDIRplt,SUBDIRzav,SUBDIRpot,ES
          else if (quote_count.eq.18) then !}{
            read(ZEILE,*) SUBDIRrec,SUBDIRion,
     &                    SUBDIRcex,SUBDIRprb,
     &                    SUBDIRplt,SUBDIRzav,
     &                    SUBDIRpot,ES,Bdescr
          else !}{
            call xerrab
     .       ('Incomplete line found in ratadas.filelist!')
          endif !}
          close(99)
          if(SUBDIRzav.ne.'none') then !{
            read(SUBDIRzav,*) iyear
          else !}{
            message = 'Could not find Zav data for '//spcigen(l)
            call xerrab (message)
          end if !}
          if (iyear.gt.100) then !{
            write(EB,'(i2.2)') mod(iyear,100)
            iyear = iyear/100
          end if !}
          write(YEAR,'(i2.2)') iyear
          call lower_case(ES)
          if (trim(ES).eq.'d'.or.trim(ES).eq.'t') ES = 'h'
          if (.not.streql(EB,' ')) then !{
            if (quote_count.eq.16) then !{
              fnzav='/adf11/zcd'//YEAR//'/zcd'//YEAR//
     &         '_'//ES//'_'//EB//'.dat'
            else if (quote_count.eq.18) then !}{
              fnzav='/adf11/zcd'//YEAR//'/zcd'//YEAR//
     &         '_'//ES//'_'//EB//'_'//Bdescr//'.dat'
            end if !}
          else !}{
            fnzav='/adf11/zcd'//YEAR//'/zcd'//YEAR//
     &       '_'//ES//'.dat'
          endif !}
          call strip_spaces(fnzav)
          fnzav=trim(UIDIN)//fnzav
          if (SUBDIRzav.ne.'none') then !{
            write(*,'(a,a)') 'Using ADAS file: ',trim(fnzav)
          else !}{
            write(*,*) 'Skipping effective charge data'
            cycle
          endif !}
          if(silent_open(99,fnzav,'data.local|modules',adasfile)) then !{
            write(*,'(a,a,a)') 'Used ',trim(adasfile),
     .       ' for effective charge'
            call xxdata_11(99,10,
     *           isdimd,iddimd,itdimd,ndptnl,ndptn,ndptnc,ndcnct,
     *           IZMAX,IZ1MIN,IZ1MAX,
     *           nptnl,nptn,nptnc,iptnla,iptna,iptnca,
     *           ncnct,icnctv,iblmx,ismax,dnr_ele,dnr_ams,
     *           isppr,ispbr,isstgr,
     *           IDMAXDzav,ITMAXDzav,DDENSDzav,DTEVDzav,DZAV,
     *           lres,lstan,lptn)
            if (IZMAX.ne.nc) then
              write(*,*) 'ADAS tables: wrong element.'
              write(*,*) 'reading file: ',fnzav
              return
            endif
            if ((IDMAXDzav.gt.iddimd).or.(ITMAXDzav.gt.itdimd)) then
              write(*,*) 'ADAS tables: dimensions too big.'
              write(*,*) 'Change iddimd and itdimd in source code.'
              write(*,*) 'reading file: ',fnzav
              return
            endif
            close(99)
            do ic = 1, ncnct !{
              izpmin(ic-1) = iptnca(1,ic,1)
              izpmax(ic-1) = iptnca(1,ic,nptnc(1,ic))
            enddo !}
            write(6,*) spcigen(l)
            write(6,*) (izpmin(ic-1),ic=1,ncnct)
            write(6,*) (izpmax(ic-1),ic=1,ncnct)
            write(6,1028)
          else !}{
            call xerrab ('Could not open ADAS partition file!')
          end if !}
          call xertst(izpmin(0).eq.0 .and. izpmax(0).eq.0,
     .     'Neutral should not be bundled with ions!')
          nplsb = nplsb - izpmax(ncnct-1) + (ncnct-1)
          nbndl(l) = ncnct
          do ic = 0, ncnct-1 !{
            izamin(iss) = izpmin(ic)
            izamax(iss) = izpmax(ic)
            iss = iss + 1
          end do !}
          if (l.gt.1) then !{
            jend(l) = jend(l-1) + ncnct-1
          else !}{
            jend(1) = ncnct-1
          end if !}
cxpb   i     is the bundle index for this sequence
cxpb   iplsb is the number of the bundled ion in the new list
cxpb   j     is the number of the unbundled ion in the old list
cxpb   ja    is the number of the first unbundled ion in the old list belonging to the bundle
cxpb   je    is the number of the last unbundled ion in the old list belonging to the bundle
cxpb   ianf  is the number of the first unbundled ion of that sequence in the old list
cxpb   iend  is the number of the last unbundled ion of that sequence in the old list
cxpb   janf(l) is the number of the first bundled ion of sequence l in the new list
cxpb   jend(l) is the number of the last bundled ion of sequence l in the new list
          do i = 1, ncnct-1 !{
            iplsb = janf(l) + i-1
            ja = ianf + izpmin(i)-1
            je = ianf + izpmax(i)-1
            spcsrnb(iplsb) = l
            ichr = len_trim(spcigen(l))
            write(spcsplb(iplsb)(1:ichr+1),'(a,a1)')
     .       trim(spcigen(l)),'+'
            if (izpmin(i).lt.10) then !{
              write(spcsplb(iplsb)(ichr+2:ichr+2),'(i1)') izpmin(i)
              ichr = ichr+2
            else !}{
              write(spcsplb(iplsb)(ichr+2:ichr+3),'(i2)') izpmin(i)
              ichr = ichr+3
            endif
            if (izpmax(i).gt.izpmin(i)) then !{
              write(spcsplb(iplsb)(ichr+1:ichr+1),'(a1)') '-'
              if (izpmax(i).lt.10) then !{
                write(spcsplb(iplsb)(ichr+2:ichr+2),'(i1)') izpmax(i)
                ichr = ichr+2
              else !}{
                write(spcsplb(iplsb)(ichr+2:ichr+3),'(i2)') izpmax(i)
                ichr = ichr+3
              endif !}
            endif !}
            if (ichr.lt.8) spcsplb(iplsb)(ichr+1:8)=repeat(' ',8-ichr)
            spcsrfb(iplsb) = spcsrfp(ja)
            spcsrtb(iplsb) = spcsrtp(ja)
            spcsmsb(iplsb) = spcsmsp(ja)
            spcsncb(iplsb) = spcsncp(ja)
            spcscgb(iplsb) =(spcscgp(ja)+spcscgp(je))/2
            spcsfub(iplsb) = spcsfup(ja)
            spcsrsb(iplsb) = spcsrsp(ja)
            dplsb(iplsb) = rratio(izpmax(i)-izpmin(i)+1,nc)
            textb(iplsb) = spcsplb(iplsb)
            nprtb(iplsb) = spcsfub(iplsb)
            bmasb(iplsb) = spcsmsb(iplsb)
            nmassb(iplsb) = spcsmsb(iplsb)
            ncharb(iplsb) = spcsncb(iplsb)
            nchrgb(iplsb) = spcscgb(iplsb)
            lkindb(iplsb) = lkindp(ja)
            fctb(iplsb) = fcte(ja)
            iflbb(iplsb) = iplsb
            isrfb(iplsb) = isrfp(ja)
            isrtb(iplsb) = isrtp(ja)
            nmsecb(iplsb) = maxval(nmsecp(ja:je))
            idnslmb(iplsb) = idnslmp(ja)
            nfolb(iplsb) = nfolp(ja)
            ngenb(iplsb) = ngenp(ja)
            nhstb(iplsb) = nhstp(ja)
            ireac = 0
            jreac = 0
            do j = ja, je  !{
              ipls1(j) = iplsb
              nrcb(iplsb) = nrcb(iplsb)+nrcp(j)
              nreb(iplsb) = nreb(iplsb)+nrep(j)
              do ireac = 1, nrcp(j) !{
                jreac = jreac + 1
                ireacb(iplsb,jreac) = ireacp(j,ireac)
                ibulkb(iplsb,jreac) = ibulkp(j,ireac)
                iscd1b(iplsb,jreac) = iscd1p(j,ireac)
                iscd2b(iplsb,jreac) = iscd2p(j,ireac)
                iscd3b(iplsb,jreac) = iscd3p(j,ireac)
                iscd4b(iplsb,jreac) = iscd4p(j,ireac)
                iscdeb(iplsb,jreac) = iscdep(j,ireac)
                eelecb(iplsb,jreac) = eelecp(j,ireac)
                ebulkb(iplsb,jreac) = ebulkp(j,ireac)
                escd1b(iplsb,jreac) = escd1p(j,ireac)
                escd2b(iplsb,jreac) = escd2p(j,ireac)
                freacb(iplsb,jreac) = freacp(j,ireac)
              end do !}
            end do !}
          end do !}
        else !}{
          call xerrab ('Could not open ratadas.filelist !')
        end if !}
        deallocate(izpmin, izpmax)
        lfirst = .false.
      end do !}

cxpb Now we remap the arrays
      if (nplsb.ne.nspcpls.and.nplsb.gt.0) then !{
        write(6,*) 'New ion list after bundling to be mapped: '
        write(*,'(1x,a12,9a8)') 'plasma ions','nmassb','ncharb','nprtb',
     ,    'nchrgb','isrfb','isrtb','nmsecb','spcsrnb'
        do i=1,nplsb !{
          if (spcsrnb(i).eq.0) cycle
          if (is_bundled(spcsrnb(i))) then !{
            write(*,'(4x,a8,i7,8i8)') textb(i),
     ,       nmassb(i),ncharb(i),nprtb(i),
     ,       nchrgb(i),isrfb(i),isrtb(i),nmsecb(i),spcsrnb(i)
          end if !}
        end do !}
        write(6,1028)
        ianf = 0
        iend = 0
cxpb   ianf  is the number of the first unbundled ion of that sequence in the old list
cxpb   iend  is the number of the last unbundled ion of that sequence in the old list
cxpb   janf(l) is the number of the first bundled ion of sequence l in the new list
cxpb   jend(l) is the number of the last bundled ion of sequence l in the new list
        allocate(done(nplsi))
        done = .false.
        do l = 1, nspigen !{
          ianf = iend + 1
          nc = get_atomic_number(spcigen(l))
          iend = iend + nc
          if (.not.is_bundled(l)) then !{
            do j = janf(l), jend(l) !{
              done(j) = .true.
            end do !}
          end if !}
          do j = ianf, iend !{
            call xertst(ipls1(j).gt.0,'Bundling map incomplete!')
            i = ipls1(j)
            if (done(i)) cycle
            spcsrnp(i) = spcsrnb(i)
            spcspls(nspcatm+nspcmol+nspcion+i) = spcsplb(i)
            spcsrfp(i) = spcsrfb(i)
            spcsrtp(i) = spcsrtb(i)
            spcsmsp(i) = spcsmsb(i)
            spcsncp(i) = spcsncb(i)
            spcscgp(i) = spcscgb(i)
            spcsfup(i) = spcsfub(i)
            spcsrsp(i) = spcsrsb(i)
            fcte(i) = fctb(i)
            dpls(i) = dplsb(i)
            iflb(i) = iflbb(i)
            textp(i) = textb(i)
            nprtp(i) = nprtb(i)
            bmass(i) = bmasb(i)
            isrfp(i) = isrfb(i)
            isrtp(i) = isrtb(i)
            nmsecp(i) = nmsecb(i)
            nmassp(i) = nmassb(i)
            ncharp(i) = ncharb(i)
            nchrgp(i) = nchrgb(i)
            lkindp(i) = lkindb(i)
            nrcp(i) = nrcb(i)
            nrep(i) = nreb(i)
            idnslmp(i) = idnslmb(i)
            nfolp(i) = nfolb(i)
            ngenp(i) = ngenb(i)
            nhstp(i) = nhstb(i)
            ireacp(i,1:nreac) = ireacb(i,1:nreac)
            ibulkp(i,1:nreac) = ibulkb(i,1:nreac)
            iscd1p(i,1:nreac) = iscd1b(i,1:nreac)
            iscd2p(i,1:nreac) = iscd2b(i,1:nreac)
            iscd3p(i,1:nreac) = iscd3b(i,1:nreac)
            iscd4p(i,1:nreac) = iscd4b(i,1:nreac)
            iscdep(i,1:nreac) = iscdeb(i,1:nreac)
            eelecp(i,1:nreac) = eelecb(i,1:nreac)
            ebulkp(i,1:nreac) = ebulkb(i,1:nreac)
            escd1p(i,1:nreac) = escd1b(i,1:nreac)
            escd2p(i,1:nreac) = escd2b(i,1:nreac)
            freacp(i,1:nreac) = freacb(i,1:nreac)
            done(i) = .true.
          end do !}
          do i = iend+1, nplsi+nbgk !{ Shift up whatever follows
            j = jend(l) + i - iend
            spcsrnp(j) = spcsrnp(i)
            spcspls(nspcatm+nspcmol+nspcion+j) =
     .       spcspls(nspcatm+nspcmol+nspcion+i)
            spcsrfp(j) = spcsrfp(i)
            spcsrtp(j) = spcsrtp(i)
            spcsmsp(j) = spcsmsp(i)
            spcsncp(j) = spcsncp(i)
            spcscgp(j) = spcscgp(i)
            spcsfup(j) = spcsfup(i)
            spcsrsp(j) = spcsrsp(i)
            fcte(j) = fcte(i)
            dpls(j) = dpls(i)
            iflb(j) = iflb(i)
            textp(j) = textp(i)
            nprtp(j) = nprtp(i)
            bmass(j) = bmass(i)
            isrfp(j) = isrfp(i)
            isrtp(j) = isrtp(i)
            nmsecp(j) = nmsecp(i)
            nmassp(j) = nmassp(i)
            ncharp(j) = ncharp(i)
            nchrgp(j) = nchrgp(i)
            lkindp(j) = lkindp(i)
            nrcp(j) = nrcp(i)
            nrep(j) = nrep(i)
            idnslmp(j) = idnslmp(i)
            nfolp(j) = nfolp(i)
            ngenp(j) = ngenp(i)
            nhstp(j) = nhstp(i)
            ireacp(j,1:nreac) = ireacp(i,1:nreac)
            ibulkp(j,1:nreac) = ibulkp(i,1:nreac)
            iscd1p(j,1:nreac) = iscd1p(i,1:nreac)
            iscd2p(j,1:nreac) = iscd2p(i,1:nreac)
            iscd3p(j,1:nreac) = iscd3p(i,1:nreac)
            iscd4p(j,1:nreac) = iscd4p(i,1:nreac)
            iscdep(j,1:nreac) = iscdep(i,1:nreac)
            eelecp(j,1:nreac) = eelecp(i,1:nreac)
            ebulkp(j,1:nreac) = ebulkp(i,1:nreac)
            escd1p(j,1:nreac) = escd1p(i,1:nreac)
            escd2p(j,1:nreac) = escd2p(i,1:nreac)
            freacp(j,1:nreac) = freacp(i,1:nreac)
          end do !}
          nplsi = nplsi - nc + jend(l) - janf(l) + 1
          nfla = nplsi
        end do !}
        deallocate(done)
        write(6,*) 'New ion list after mapping: '
        write(*,'(1x,a12,9a8)') 'plasma ions','nmassp','ncharp','nprtp',
     ,    'nchrgp','isrfp','isrtp','nmsecp','spcsrnp'
        do i=1,nplsi+nbgk !{
          write(*,'(a12,i7,8i8)') textp(i),nmassp(i),ncharp(i),nprtp(i),
     ,      nchrgp(i),isrfp(i),isrtp(i),nmsecp(i),spcsrnp(i)
        end do !}
        nspcpls=nplsi
        write(*,1028)
      end if !}
      deallocate(janf,jend)
      deallocate(spcsrnb,spcsrfb,spcsrtb,spcsmsb,spcsncb,spcscgb,
     .           spcsfub,spcsrsb,spcsplb)
      deallocate(nprtb,nmassb,ncharb,nchrgb,iflbb,lkindb,textb,
     .           isrfb,isrtb,dplsb,bmasb,fctb)
      deallocate(nrcb,nreb,idnslmb,nfolb,ngenb,nhstb,
     .           ireacb, ibulkb, iscd1b, iscd2b, iscd3b, iscd4b, iscdeb,
     .           eelecb, ebulkb, escd1b, escd2b, freacb)

cxpb Now we renumber the reaction particles if needed
      do i = 1, nspcatm !{
        do ireac = 1, nrca(i) !{
          iknd = mod(ibulka(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = ibulka(i,ireac)/100
            if (ipls1(ipls).gt.0) ibulka(i,ireac) =
     .       mod(ibulka(i,ireac),100) + ipls1(ipls)*100
          end if !}
          iknd = mod(iscd1a(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = iscd1a(i,ireac)/100
            if (ipls1(ipls).gt.0) iscd1a(i,ireac) =
     .       mod(iscd1a(i,ireac),100) + ipls1(ipls)*100
          end if !}
          iknd = mod(iscd2a(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = iscd2a(i,ireac)/100
            if (ipls1(ipls).gt.0) iscd2a(i,ireac) =
     .       mod(iscd2a(i,ireac),100) + ipls1(ipls)*100
          end if !}
          iknd = mod(iscd3a(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = iscd3a(i,ireac)/100
            if (ipls1(ipls).gt.0) iscd3a(i,ireac) =
     .       mod(iscd3a(i,ireac),100) + ipls1(ipls)*100
          end if !}
          iknd = mod(iscd4a(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = iscd4a(i,ireac)/100
            if (ipls1(ipls).gt.0) iscd4a(i,ireac) =
     .       mod(iscd4a(i,ireac),100) + ipls1(ipls)*100
          end if !}
        end do !}
      end do !}
      do i = 1, nspcmol !{
        do ireac = 1, nrcm(i) !{
          iknd = mod(ibulkm(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = ibulkm(i,ireac)/100
            if (ipls1(ipls).gt.0) ibulkm(i,ireac) =
     .       mod(ibulkm(i,ireac),100) + ipls1(ipls)*100
          end if !}
          iknd = mod(iscd1m(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = iscd1m(i,ireac)/100
            if (ipls1(ipls).gt.0) iscd1m(i,ireac) =
     .       mod(iscd1m(i,ireac),100) + ipls1(ipls)*100
          end if !}
          iknd = mod(iscd2m(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = iscd2m(i,ireac)/100
            if (ipls1(ipls).gt.0) iscd2m(i,ireac) =
     .       mod(iscd2m(i,ireac),100) + ipls1(ipls)*100
          end if !}
          iknd = mod(iscd3m(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = iscd3m(i,ireac)/100
            if (ipls1(ipls).gt.0) iscd3m(i,ireac) =
     .       mod(iscd3m(i,ireac),100) + ipls1(ipls)*100
          end if !}
          iknd = mod(iscd4m(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = iscd4m(i,ireac)/100
            if (ipls1(ipls).gt.0) iscd4m(i,ireac) =
     .       mod(iscd4m(i,ireac),100) + ipls1(ipls)*100
          end if !}
        end do !}
      end do !}
      do i = 1, nspcion !{
        do ireac = 1, nrci(i) !{
          iknd = mod(ibulki(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = ibulki(i,ireac)/100
            if (ipls1(ipls).gt.0) ibulki(i,ireac) =
     .       mod(ibulki(i,ireac),100) + ipls1(ipls)*100
          end if !}
          iknd = mod(iscd1i(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = iscd1i(i,ireac)/100
            if (ipls1(ipls).gt.0) iscd1i(i,ireac) =
     .       mod(iscd1i(i,ireac),100) + ipls1(ipls)*100
          end if !}
          iknd = mod(iscd2i(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = iscd2i(i,ireac)/100
            if (ipls1(ipls).gt.0) iscd2i(i,ireac) =
     .       mod(iscd2i(i,ireac),100) + ipls1(ipls)*100
          end if !}
          iknd = mod(iscd3i(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = iscd3i(i,ireac)/100
            if (ipls1(ipls).gt.0) iscd3i(i,ireac) =
     .       mod(iscd3i(i,ireac),100) + ipls1(ipls)*100
          end if !}
          iknd = mod(iscd4i(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = iscd4i(i,ireac)/100
            if (ipls1(ipls).gt.0) iscd4i(i,ireac) =
     .       mod(iscd4i(i,ireac),100) + ipls1(ipls)*100
          end if !}
        end do !}
      end do !}
      do i = 1, nspcpls !{
        do ireac = 1, nrcp(i) !{
          iknd = mod(ibulkp(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = ibulkp(i,ireac)/100
            if (ipls1(ipls).gt.0) ibulkp(i,ireac) =
     .       mod(ibulkp(i,ireac),100) + ipls1(ipls)*100
          end if !}
          iknd = mod(iscd1p(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = iscd1p(i,ireac)/100
            if (ipls1(ipls).gt.0) iscd1p(i,ireac) =
     .       mod(iscd1p(i,ireac),100) + ipls1(ipls)*100
          end if !}
          iknd = mod(iscd2p(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = iscd2p(i,ireac)/100
            if (ipls1(ipls).gt.0) iscd2p(i,ireac) =
     .       mod(iscd2p(i,ireac),100) + ipls1(ipls)*100
          end if !}
          iknd = mod(iscd3p(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = iscd3p(i,ireac)/100
            if (ipls1(ipls).gt.0) iscd3p(i,ireac) =
     .       mod(iscd3p(i,ireac),100) + ipls1(ipls)*100
          end if !}
          iknd = mod(iscd4p(i,ireac),10)
          if (iknd.eq.4) then !{
            ipls = iscd4p(i,ireac)/100
            if (ipls1(ipls).gt.0) iscd4p(i,ireac) =
     .       mod(iscd4p(i,ireac),100) + ipls1(ipls)*100
          end if !}
        end do !}
      end do !}
c======================================================================
      call subend ()
      return
 1028 format()
      end
