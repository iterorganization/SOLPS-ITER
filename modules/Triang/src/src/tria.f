      PROGRAM TRIANGLE
#ifdef NAGFOR
      use f90_unix_io ! IGNORE
#endif

c  version : 01.10.2016 21:09

cank-20041209{
c*** File opening with the standard names is added to avoid fort.NN
c*** which may interfere with other files used by B2 and Eirene - this
c*** routine is normally called from a B2-Eirene working directory
c*** The names are:
c***  tria.in       for fort.2  (input file)
c***  tria.dbg      for fort.3  (trap set file)
c***  triaplt.dat   for fort.22 
c***  tria.nodes    for fort.23
c***  tria.elemente for fort.24
c***  tria.neighbor for fort.25
cank}

      use cpoin
      use cfront
      use ccandi
      use creg
      use celm
      use cdelta
      IMPLICIT NONE

C---- DECLARATIONS
C---- VARIABLES FOR SORTING
C---- BOUND,IND1,IND2,IREG : LOOP VARIABLES
C---- IHELP : VARIABLE FOR EXCHANGE
C---- HELP  : VARIABLE FOR EXCHANGE
      INTEGER BOUND,IND1,IND2,IREG,IHELP
      DOUBLE PRECISION HELP

C---- VARIABLES FOR GRAPHICS
C---- XMIN,XMAX,YMIN,YMAX : MINIMA AND MAXIMA OF COORDINATES
C---- DELTAX,DELTAY : RANGE IN X- OR Y-DIRECTION
C---- DELTA : MAXIMUM OF DELTAX AND DELTAY
C---- XCM,YCM : SIZE OF PLOT REGION IN CM
      DOUBLE PRECISION XMIN,XMAX,YMIN,YMAX,DELTAX,DELTAY,DELTA,XCM,YCM

C---- FRAD   : SEARCH RADIUS
C---- EPSANG : MINIMAL INNER ANGLE TO AVOID TRIANGLES DEGENERATED TO A
C----          LINE
C---- NBOUN  : TOTAL NUMBER OF POINTS PER BLOCK TO BE READ
C---- NFR    : AUXILARY VARIABLE
C---- I,J,K  : LOOP INDICES
C---- FOUND  : INDICATES IF THE THIRD TRIANGLE POINT WAS FOUND
      DOUBLE PRECISION FRAD, EPSANG
      INTEGER NBOUN,NFR
      INTEGER I,J,K
      CHARACTER*80 LINE
      LOGICAL FOUND
cank-20051101{
      integer npn_hlp,ihlp200,jhlp200,khlp200,mhlp200,nhlp200,
     ,  kchn_hlp,mchn_hlp,nchn_hlp
      logical lhlp200,ex
      integer, allocatable :: ichn_hlp(:),jchn_hlp(:,:)
      logical, allocatable :: lchn_hlp(:)
      character*4 hhlp200
      double precision dx,dy,d,dxmn,dxmx,dymn,dymx,sx,sy
      character*10 hs(6)
#ifdef NAGFOR
      integer errno
#endif

      ihlp200=0
      jhlp200=0
      khlp200=0
      mhlp200=0
      nhlp200=10
      lhlp200=.false.
cank}

C---- INITIALISATION

      NELM  = 0
      NPOIN = 0
      allocate(x(100))
      x = 0.
      allocate(y(100))
      y = 0.
      NPARTFR = 0
      NFRONT = 0
      allocate(ikont(100))
      ikont = 0
      allocate(delfro(100))
      delfro = 0.
      allocate(ifront(2,100))
      ifront = 0
      allocate(ielm(3,100))
      ielm = 0

      XMIN = 1E+6
      XMAX = -1E+6
      YMIN = 1E+6
      YMAX = -1E+6
      NREG = 0
cank{
      inquire(file='tria.dbg',exist=ex)
      if(ex) then !{
        hhlp200='open'
        open(3,file='tria.dbg',status='old',action='read',err=50)
        rewind(3)
        hhlp200='read'
        read (3,*,end=50,err=50) mhlp200
                            ! step after which the code stops
                            ! and the plot data are output for debugging
        print *,'tria: a trap is set after step ',mhlp200 
        close(3)
        go to 51
 50     print *,'error ',hhlp200,
     ,    'in tria.dbg - no debugging data to be used'
 51     continue
      end if !}
      open(2,file='tria.in',status='old',action='read')
      open(23,file='tria.nodes',status='replace',action='write')
      open(24,file='tria.elemente',status='replace',action='write')
      open(25,file='tria.neighbor',status='replace',action='write')
cank}
C---- INPUT OF DELTA0
      READ(2,*,END=99) DELTA0

      print *,' delta0=',delta0 !###

C---- INPUT OF REGIONS (for grid refinement - ank)
      allocate(region(5,10))
      region = 0.
      READ(2,'(A)',END=99) LINE
      DO WHILE (LINE .NE. ' ')  !{
        NREG = NREG + 1
        IF (NREG .GT. size(region,2)) THEN !{
           call realloc_creg('region',10)
        ENDIF !}
        READ (LINE,*) (REGION(I,NREG),I=1,5)
        READ(2,'(A)') LINE
      ENDDO !} OF DO WHILE (LINE .NE. ' ')

      print *,' before bubble sort. nreg=',nreg !###

C---- BUBBLE_SORT - BUBBLE_SORT - BUBBLE_SORT
C---- SORTS THE REGIONS FROM GREATEST TO SMALLEST REGION(5,IREG)
      BOUND = NREG
      DO WHILE (BOUND .GT. 1) !{
        IND1 = 1
        IND2 = 1
        DO WHILE (BOUND .GT. IND2) !{
          IF (REGION(5,IND2) .LT. REGION(5,IND2+1)) THEN !{
            HELP             = REGION(1,IND2)
            REGION(1,IND2)   = REGION(1,IND2+1)
            REGION(1,IND2+1) = HELP
            HELP             = REGION(2,IND2)
            REGION(2,IND2)   = REGION(2,IND2+1)
            REGION(2,IND2+1) = HELP
            HELP             = REGION(3,IND2)
            REGION(3,IND2)   = REGION(3,IND2+1)
            REGION(3,IND2+1) = HELP
            HELP             = REGION(4,IND2)
            REGION(4,IND2)   = REGION(4,IND2+1)
            REGION(4,IND2+1) = HELP
            HELP             = REGION(5,IND2)
            REGION(5,IND2)   = REGION(5,IND2+1)
            REGION(5,IND2+1) = HELP
          ENDIF !}
          IND1=IND2
          IND2=IND2+1
        ENDDO !} OF DO WHILE (BOUND .GT. IND2)
        BOUND=IND1
      ENDDO !} OF DO WHILE (BOUND .GT. 1)

!###{
      print *,' after bubble sort. bound=',bound
      if(nreg.gt.0) print '(1p,5e12.4)',((region(i,j),i=1,5),j=1,nreg)
!###}

C---- INPUT OF TOTAL NUMBER OF BOUNDARIES
      READ(2,*,END=99) NBOUN
      DO WHILE (NBOUN .NE. 0) !{
        NFRONT = NFRONT + 1

        print *,' nboun,nfront=',nboun,nfront !###

        IF (NFRONT .GT. size(ikont)) THEN !{
           call realloc_cpoin('ikont',nfront-size(ikont))
        ENDIF !}

        DO I=1,NBOUN !{
C---- INPUT OF X- AND Y-COORDINATES OF ONE BOUNDARY
          IF (NPOIN+I .GT. size(x)) THEN !{
             call realloc_cpoin('xy',100)
          ENDIF !}
          READ(2,*,END=99) X(NPOIN+I),Y(NPOIN+I)
C---- CHANGES OF MINIMA AND MAXIMA DEPENDING OF INPUT
          IF (X(NPOIN+I) .LT. XMIN) XMIN = X(NPOIN+I)
          IF (X(NPOIN+I) .GT. XMAX) XMAX = X(NPOIN+I)
          IF (Y(NPOIN+I) .LT. YMIN) YMIN = Y(NPOIN+I)
          IF (Y(NPOIN+I) .GT. YMAX) YMAX = Y(NPOIN+I)
        ENDDO !} OF DO I=1,NBOUN
        
        write (6,'(a,1p,4e12.4)') ' xmin,xmax,ymin,ymax=',
     .                              xmin,xmax,ymin,ymax !###

C---- ADD ACTUAL BOUNDARY TO FRONTIER
        IF (NPARTFR+NBOUN-1 .GT. size(ifront,2)) THEN !{
           call realloc_cfront('ifront',
     .                         npartfr+nboun-1-size(ifront,2)+100)
        ENDIF !}
        DO I=1,NBOUN-1 !{
          IFRONT(1,NPARTFR+I) = NPOIN+I
          IFRONT(2,NPARTFR+I) = NPOIN+I+1
        ENDDO !}
        IFRONT(2,NPARTFR+NBOUN-1) = IFRONT(1,NPARTFR+1)
        NFR = NPARTFR
        NPARTFR = NPARTFR + NBOUN - 1
        npn_hlp=npoin
        NPOIN = NPOIN + NBOUN - 1
        IF (NPOIN .GT. size(x)) THEN !{
             call realloc_cpoin('xy',npoin-size(x))
        ENDIF !}
C---- FIRST AND LAST POINT MUST BE EQUAL
        IF ((ABS(X(npn_hlp+1)-X(npn_hlp+NBOUN)) .GT. 1.E-6) .OR.
     .      (ABS(Y(npn_hlp+1)-Y(npn_hlp+NBOUN)) .GT. 1.E-6)) THEN !{
          WRITE(6,*) 'STOP IN MAIN, FIRST AND LAST POINT OF EACH',
     .         ' BOUNDARY MUST BE EQUAL'
          call filepltd(1,0)
          STOP 'ERROR'
        ENDIF !}

C---- CALCULATE THE LENGTH OF FRONTIER PARTS
        IF (NPARTFR .GT. size(delfro)) THEN !{
           call realloc_cfront('delfro',npartfr-size(delfro)+100)
        ENDIF !}
        DO I=1+NFR,NPARTFR !{
          DELFRO(I) = SQRT((X(IFRONT(1,I))-X(IFRONT(2,I)))**2 +
     >                     (Y(IFRONT(1,I))-Y(IFRONT(2,I)))**2)
        ENDDO !}

        print *,' nfr,npartfr=',nfr,npartfr !###

        I = 1+NFR
        DO WHILE (I .LE. NPARTFR) !{
C---- COMPUTING OF DELPOIN FOR INTERMEDIATE POINTS ON FRONTIER PARTS

c          print *,' i,npartfr=',i,npartfr !###

          DELPOIN = 0.
          XADEL = X(IFRONT(1,I))
          YADEL = Y(IFRONT(1,I))
          XEDEL = X(IFRONT(2,I))
          YEDEL = Y(IFRONT(2,I))
          DO IREG = 1,NREG !{
            DELX = ABS(REGION(1,IREG)-REGION(3,IREG))
            DELY = ABS(REGION(2,IREG)-REGION(4,IREG))
            IF (((ABS(XADEL-REGION(1,IREG)) .LE. DELX) .AND.
     .           (ABS(XADEL-REGION(3,IREG)) .LE. DELX) .AND.
     .           (ABS(YADEL-REGION(2,IREG)) .LE. DELY) .AND.
     .           (ABS(YADEL-REGION(4,IREG)) .LE. DELY)) .OR.
     .          ((ABS(XEDEL-REGION(1,IREG)) .LE. DELX) .AND.
     .           (ABS(XEDEL-REGION(3,IREG)) .LE. DELX) .AND.
     .           (ABS(YEDEL-REGION(2,IREG)) .LE. DELY) .AND.
     .           (ABS(YEDEL-REGION(4,IREG)) .LE. DELY))) THEN !{
              DELPOIN = REGION(5,IREG)
            ENDIF !}
          ENDDO !}
          IF (ABS(DELPOIN) .LT. 1.E-6) DELPOIN = DELTA0

C---- SPLIT FRONTIER PART IF IT IS LONGER THAN DELPOIN
          IF (DELFRO(I) .GT. DELPOIN) THEN !{
            NPOIN = NPOIN + 1
            IF (NPOIN .GT. size(x)) THEN !{
               call realloc_cpoin('xy',1)
            ENDIF !}
            X(NPOIN) = (X(IFRONT(1,I))+X(IFRONT(2,I)))*0.5
            Y(NPOIN) = (Y(IFRONT(1,I))+Y(IFRONT(2,I)))*0.5
            NPARTFR = NPARTFR + 1
            IF (NPARTFR .GT. size(ifront,2)) THEN !{
               call realloc_cfront('ifront',1)
            ENDIF !}
            IFRONT(1,NPARTFR) = NPOIN
            IFRONT(2,NPARTFR) = IFRONT(2,I)
            IF (NPARTFR .GT. size(delfro)) THEN !{
               call realloc_cfront('delfro',1)
            ENDIF !}
            DELFRO(NPARTFR) = DELFRO(I)*0.5
            IFRONT(2,I) = NPOIN
            DELFRO(I) = DELFRO(I)*0.5
          ELSE !}{
            I = I + 1
          ENDIF !}
        ENDDO !}
        IKONT(NFRONT) = NPOIN

        READ(2,*,END=99) NBOUN
      ENDDO !} OF DO WHILE (NBOUN .NE. 0)
99    CONTINUE
      close(2)

      print *,'*99: finished reading.'
      print *,'     npartfr,npoin,nfront=',npartfr,npoin,nfront

      if (npartfr .eq. 0) then !{
c---- empty input
        WRITE(6,*) 'STOP IN MAIN, EMPTY INPUT'
        STOP 'ERROR'
      endif !}
!###{
      print *
      print *,'   i   ik'
      print '(2i5)',(i,ikont(i),i=1,nfront)
      print *
      print *,'   i       x          y'
      print '(i5,1p,2e12.4)',(i,x(i),y(i),i=1,npoin)
      print *
      print *,'   i   i1   i2      dl'
      print '(3i5,1p,e12.4)',
     ,                (i,ifront(1,i),ifront(2,i),delfro(i),i=1,npartfr)
      print *
c*** Check the chains - must correspond to the boundary sections
c*** Here ichn_hlp counts number of connections for every point
c***      jchn_hlp marks the segments connected to every point
c***                (1 starting from, 2 ending at)
c***      lchn_hlp means "the segment is not checked yet"
c***      mchn_hlp counts the number of found boundary chains
c***      kchn_hlp counts the number of segments in the current chain
      allocate(ichn_hlp(npoin))
      allocate(jchn_hlp(2,npoin))
      allocate(lchn_hlp(npartfr))
      ichn_hlp=0
      jchn_hlp=0
      do j=1,npartfr !{
        do i=1,2 !{
          k=ifront(i,j)
          ichn_hlp(k)=ichn_hlp(k)+1
          if(ichn_hlp(k).le.2) then !{
            jchn_hlp(i,k)=j
          end if !}
        end do !}
      end do !}
      k=0
      do i=1,npoin !{
        if(ichn_hlp(i).ne.2) k=k+1
      end do !}
      if(k.gt.0) then !{
        print *,'** Chain check: ',k,' irregular points found'
        print *,' point links'
        do i=1,npoin !{
          if(ichn_hlp(i).ne.2) print '(2i6)',i,ichn_hlp(i)
        end do !}  
      end if !}
      print *
      print *,'Point connections'
      print *,'   i   i1   i2'
      print '(3i5)',(i,jchn_hlp(1,i),jchn_hlp(2,i),i=1,npartfr)
      lchn_hlp=.true.
      mchn_hlp=0
      kchn_hlp=0
      do j=1,npartfr !{
c        print *,'j,lchn_hlp=',j,lchn_hlp(j) !###
        if(lchn_hlp(j)) then !{
          lchn_hlp(j)=.false.
          ichn_hlp=0
          mchn_hlp=mchn_hlp+1
          print *
          print *,'Frontier',mchn_hlp
          print *,'   i    k      x          y        ich  jch1 jch2'
          kchn_hlp=1
          k=ifront(1,j)
          print '(2i5,1p,2e12.4)',kchn_hlp,k,x(k),y(k)
          ichn_hlp(k)=1
          k=ifront(2,j)
          do i=1,npartfr !{
            kchn_hlp=kchn_hlp+1
            print '(2i5,1p,2e12.4,3i5)',kchn_hlp,k,x(k),y(k),
     ,         ichn_hlp(k),jchn_hlp(1,k),jchn_hlp(2,k)
            if(ichn_hlp(k).eq.1) exit
            ichn_hlp(k)=1
            k=jchn_hlp(1,k)
            if(.not.lchn_hlp(k)) exit
            lchn_hlp(k)=.false.
            k=ifront(2,k)
          end do !}
          if(ichn_hlp(k).ne.1) then !{
            print '(2i5,1p,2e12.4)',kchn_hlp,k,x(k),y(k)
            print *,'Chain not closed - strange!'
          end if !}
          if(mchn_hlp.le.nfront) then !{
          print *
          nchn_hlp=0
          nchn_hlp=ikont(mchn_hlp)
          if(mchn_hlp.gt.1) nchn_hlp=nchn_hlp-ikont(mchn_hlp-1)
          print *,'kchn_hlp,ikont=',kchn_hlp,nchn_hlp+1
          end if !}
        end if !}
      end do !}
      print *
      deallocate(lchn_hlp)
      deallocate(jchn_hlp)
      deallocate(ichn_hlp)
!###}
c** Prepare and output the axis dimensions for plot_set (gnuplot)
      open(22,file='triplt.dat')
      dx=(xmax-xmin)*1.1/2.
      dy=(ymax-ymin)*1.1/2.
      dxmn=(xmax+xmin)/2.-dx
      dxmx=(xmax+xmin)/2.+dx
      dymn=(ymax+ymin)/2.-dy
      dymx=(ymax+ymin)/2.+dy
      sx=1
      sy=1
      if(dy.gt.0.) then !{
        d=max(0.25d0,min(4.d0,0.75d0*dx/dy))
        if(d.le.1.) then !{
          sx=d
        else !}
          sy=1./d
        end if !}
      end if !}
      write(hs(1),'(1p,g10.3)') sx
      write(hs(2),'(1p,g10.3)') sy
      write(hs(3),'(1p,g10.3)') dxmn
      write(hs(4),'(1p,g10.3)') dxmx
      write(hs(5),'(1p,g10.3)') dymn
      write(hs(6),'(1p,g10.3)') dymx
      do i=1,6 !{
        hs(i)=adjustl(hs(i))
      end do !}
      write(22,*) 'size=',trim(hs(1)),',',trim(hs(2)),
     ,                  ' xrange=[',trim(hs(3)),':',trim(hs(4)),']',
     ,                  ' yrange=[',trim(hs(5)),':',trim(hs(6)),']'
      close(22)

c** Check for self-intersections of the boundary polygons

      call chkslfxs(found)

c** Output the boundary data for plotting (self-intersections marked)

      call filepltd(1,0)

      if(found) stop 'self-intersecting structure'

!##1      

98    CONTINUE

      print *,'*98: npartfr=',npartfr !###


C---- BUBBLE_SORT - BUBBLE_SORT - BUBBLE_SORT
C---- SORTS THE FRONTIER PARTS FROM LONGEST TO SHORTEST
      BOUND = NPARTFR
      DO WHILE (BOUND .GT. 1) !{
        IND1 = 1
        IND2 = 1

        DO WHILE (BOUND .GT. IND2) !{
          IF (DELFRO(IND2) .LT. DELFRO(IND2+1)) THEN !{
            HELP           = DELFRO(IND2)
            DELFRO(IND2)   = DELFRO(IND2+1)
            DELFRO(IND2+1) = HELP
            IHELP          = IFRONT(1,IND2)
            IFRONT(1,IND2) = IFRONT(1,IND2+1)
            IFRONT(1,IND2+1) = IHELP
            IHELP          = IFRONT(2,IND2)
            IFRONT(2,IND2) = IFRONT(2,IND2+1)
            IFRONT(2,IND2+1) = IHELP
          ENDIF !}
          IND1=IND2
          IND2=IND2+1
        ENDDO !} OF DO WHILE (BOUND .GT. IND2)
        BOUND=IND1
      ENDDO !} OF DO WHILE (BOUND .GT. 1)

      FOUND = .FALSE.
      FRAD = 3.0
      EPSANG = 0.1

!###{
      ihlp200=ihlp200+1
      khlp200=max(khlp200,jhlp200)
      jhlp200=0
      lhlp200=ihlp200.eq.mhlp200
c      lhlp200=ihlp200.eq.281 !###
      print *
      print '(a,2i6,a,3i6)',' before *200: ',ihlp200,khlp200,
     ,                  '. npoin,npartfr,nfront=',npoin,npartfr,nfront
#ifdef NAGFOR
      call flush(6,errno)
#else
      call flush(6)
#endif
      if(lhlp200) then !{
        print *
        print *,'    i   ik'
        print '(2i5)',(i,ikont(i),i=1,nfront)
        print *
        print *,'    i      x           y'
        print '(i5,1p,2e12.4)',(i,x(i),y(i),i=1,npoin)
        print *
        print *,'   i   i1   i2      dl'
        print '(3i5,1p,e12.4)',
     ,                (i,ifront(1,i),ifront(2,i),delfro(i),i=1,npartfr)
        print *
        print *,'*200: npartfr,npoin,ic=',npartfr,npoin,ic
        ia = ifront(1,npartfr)
        ib = ifront(2,npartfr)
        print '(a,1p,4e12.4)','xa1,ya1,xa2,ya2=',x(ia),y(ia),x(ib),y(ib)
#ifdef NAGFOR
        call flush(6,errno)
#else
        call flush(6)
#endif
        call filepltd(2,inodcon)  !###
        stop ': trap at *200' !###
      end if !}
!###}

200   CONTINUE

!###{
      jhlp200=jhlp200+1
      if(lhlp200) then !{
        print *,'*200: ',jhlp200,'. npartfr,frad,epsang=',
     ,                                              npartfr,frad,epsang
#ifdef NAGFOR
        call flush(6,errno)
#else
        call flush(6)
#endif
        if(jhlp200.gt.nhlp200) stop 'stopped at *200'
      end if !}
!###}
C---- TREAT ONE FRONTIER PART
      IA = IFRONT(1,NPARTFR)
      IB = IFRONT(2,NPARTFR)
      XA(1) = X(IA)
      XA(2) = Y(IA)
      XB(1) = X(IB)
      XB(2) = Y(IB)
!###{
      if(lhlp200) then !{
        write(6,*)
        write(6,*) 'ia,ib ',ia,ib
        write(6,*) 'a ',x(ia),y(ia)
        write(6,*) 'b ',x(ib),y(ib)
        do ind1=1,npartfr
        write(6,*)'i,front(1),front(2)',
     ,    ind1,ifront(1,ind1),ifront(2,ind1)
        enddo
      end if !}
!###}

      CALL OPTC ! COMPUTES THE BEST THIRD POINT OF THE TRIANGLE
!###{
      if(lhlp200) then !{
        print *,'after optc. ic,xc=',ic,xc
#ifdef NAGFOR
        call flush(6,errno)
#else
        call flush(6)
#endif
      end if !}
!###}

      CALL CANLIST(FRAD,EPSANG) ! CREATES CANDIDATE LIST
!###{
      if(lhlp200) then !{
        print *,'after canlist(',frad,',',epsang,
     ,                                '). ncandi,icandi=',ncandi,icandi
#ifdef NAGFOR
        call flush(6,errno)
#else
        call flush(6)
#endif
      end if !}
!###}

      CALL ADDCAN ! ADDS POINT C TO CANDIDATE LIST
!###{
      if(lhlp200) then !{
        print *,'after addcan. ncandi,icandi=',ncandi,icandi
#ifdef NAGFOR
        call flush(6,errno)
#else
        call flush(6)
#endif
      end if !}
!###}

      CALL CHOICE(FOUND) ! SELECTS THE TRIANGLE POINT UNDER
C----                      CONSIDERATION OF POINT C AND ALREADY FOUND 
C----                      GRID POINTS
!###{
      if(lhlp200) then !{
        print *,'after choice. found,inodcon=',found,inodcon
#ifdef NAGFOR
        call flush(6,errno)
#else
        call flush(6)
#endif
      end if !}
!###}

      IF (.NOT. FOUND) THEN !{
C---- NO POINT WAS FOUND BY CHOICE 
C---- THE SEARCH RADIUS IS ENLARGED AND THE MINIMAL INNER ANGLE IS 
C---- REDUCED
        FRAD = FRAD + 0.5
        IF (EPSANG .GT. 1E-6) THEN !{
          EPSANG = EPSANG / 10.
        ELSE !}{
          EPSANG = 0.
        ENDIF !}
        GOTO 200
      ELSE !}{
C---- A POINT WAS FOUND BY CHOICE
C---- THE SEARCH RADIUS AND THE MINIMAL INNER ANGLE ARE SET TO DEFAULT
        FRAD = 3.0
        EPSANG = 0.1
      ENDIF !}

      CALL COMPLETE ! UPDATES ELEMENT- AND NODE LIST

      CALL FRONTUPD ! UPDATES LIST OF FRONTIER PARTS
c!###{
C     IF (((XC(1).GT.1100.).AND.(XC(1).LT.1200.).AND.
C    .        (XC(2).GT.250.).AND.(XC(2).LT.350.)) .OR.
C    .          ((X(IA).GT.1100.).AND.(X(IA).LT.1200.).AND.
C    .                (Y(IA).GT.250.).AND.(Y(IA).LT.350.)) .OR.
C    .                  ((X(IB).GT.1100.).AND.(X(IB).LT.1200.).AND.
C    .                     (Y(IB).GT.250.).AND.(Y(IB).LT.350.))) THEN !{
C     DO I = 1,NPARTFR !{
C       WRITE(10,*) 'IFRONT',IFRONT(1,I),IFRONT(2,I),
C    .      DELFRO(I)
C     ENDDO !}
C     ENDIF !}
c!###}

      IF (NPARTFR .NE. 0) GOTO 98

C---- ALL FRONTIER PARTS ARE WORKED OUT

300   CONTINUE

      print *,'*300: finished with triangulation.'
      print *,'      npoin,nelm=',npoin,nelm
 
      CALL ADJAC ! CONSTRUCTS THE GRID FROM CALCULATED TRIANGLES

C---- OUTPUT OF COORDINATES
      WRITE(23,*) NPOIN
      WRITE(23,101) (X(I),I=1,NPOIN)
      WRITE(23,101) (Y(I),I=1,NPOIN)
      CLOSE(23)
 101  FORMAT (1P,4E17.9)
cc??? - debugging output?  !{
c      DO I=1,NPOIN !{
c        IF ((X(I) .GT. 215.) .AND. (X(I) .LT. 230.) .AND.
c     .                   (Y(I) .GT. -7.5) .AND. (Y(I) .LT. 7.5)) THEN !{
c         WRITE(8,*) I,X(I),Y(I)
c        ENDIF !}
c      ENDDO !}
cc??? !}

C---- OUTPUT OF ELEMENTS
      WRITE(24,*) NELM
      WRITE(25,*) NELM
      DO I=1,NELM !{
        WRITE(24,103) I,(IELM(J,I),J=1,3)
        WRITE(25,104) I,(IADJA(J,I),ISIDE(J,I),IPROP(J,I),J=1,3)
      ENDDO !}
      CLOSE(24)
      CLOSE(25)
103   FORMAT(I5,2X,3I7)
104   FORMAT(I5,2X,3(I6,2I3,2X))

C---- GRAPHIC OUTPUT
      DELTAX = ABS(XMAX-XMIN)
      DELTAY = ABS(YMAX-YMIN)
      DELTA = MAX(DELTAX,DELTAY)
      XCM = 25.*DELTAX/DELTA
      YCM = 25.*DELTAY/DELTA

      print*,'Before call to grstrt'
      CALL GRSTRT(35,8)
      print*,'After call to grstrt'
      CALL GRSCLC(5.,1.,5.+REAL(XCM),1.+REAL(YCM))
C     CALL GRSCLC(5.,1.,8.,4.)
      CALL GRSCLV(REAL(XMIN),REAL(YMIN),REAL(XMAX),REAL(YMAX))
C     CALL GRSCLV(2.5,0.5,5.,3.)
      DO IREG=1,NREG !{
C       WRITE(10,*) (REGION(K,IREG),K=1,5)
        CALL GRJMP(REAL(REGION(1,IREG)),REAL(REGION(2,IREG)))
        CALL GRDRW(REAL(REGION(1,IREG)),REAL(REGION(4,IREG)))
        CALL GRDRW(REAL(REGION(3,IREG)),REAL(REGION(4,IREG)))
        CALL GRDRW(REAL(REGION(3,IREG)),REAL(REGION(2,IREG)))
        CALL GRDRW(REAL(REGION(1,IREG)),REAL(REGION(2,IREG)))
      ENDDO !}
      CALL GRNWPN(1)
      DO I=1,NELM !{
        CALL GRJMP(REAL(X(IELM(1,I))),REAL(Y(IELM(1,I))))
        CALL GRDRW(REAL(X(IELM(2,I))),REAL(Y(IELM(2,I))))
        CALL GRDRW(REAL(X(IELM(3,I))),REAL(Y(IELM(3,I))))
        CALL GRDRW(REAL(X(IELM(1,I))),REAL(Y(IELM(1,I))))
      ENDDO !}
      CALL GRAXS(-1,'X,Y',-1,'X',-1,'Y')
      CALL GREND

      CALL TEST(NPOIN)
      call filepltd(2,0)

      END
