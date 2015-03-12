      PROGRAM TRIAGEOM

c  version : 11.02.2006 00:32

cank-20041209{
c*** File opening with the standard names is added to avoid fort.NN
c*** which may interfere with other files used by B2 and Eirene - this
c*** routine is normally called from a B2-Eirene working directory
c*** The names are:
c***  tria.elemente     for fort.21
c***  tria.nodes        for fort.22
c***  tria.neighbor     for fort.23
c***  triageom.elemente for fort.8
c***  triageom.nodes    for fort.9
c***  triageom.neighbor for fort.10
cank}

      use cdimen
      use ctria
      use ccuts
      IMPLICIT NONE

C     VARIABLES FOR PLOTS
      REAL XMIN,XMAX,YMIN,YMAX,DELTAX,DELTAY,DELTA,XCM,YCM
      INTEGER IS, ISP

cank{
      open(21,file='tria.elemente',status='old',action='read')
      open(22,file='tria.nodes',status='old',action='read')
      open(23,file='tria.neighbor',status='old',action='read')
      open(8,file='triageom.elemente',status='replace',action='write')
      open(9,file='triageom.nodes',status='replace',action='write')
      open(10,file='triageom.neighbor',status='replace',action='write')
cank}
C     INITIALIZE
      CALL GRSTRT(35,8)
      CALL INIT
      WRITE (*,*) 'INITIALIZATION DONE '

C     READ TRIANGLE MESH
      CALL TRIIN
      WRITE (*,*) 'TRIANGLE MESH READ '

C     READ PHYSICAL COORDINATES FROM SONNET FILE TO XCOORD, YCOORD
cvk      CALL SONIN
CVK     READ PHYSICAL COORDINATES FROM FORT.30 FILE TO XCOORD, YCOOR
      CALL READ30 !VK
      WRITE (*,*) 'POLYGON MESH READ '

C     CREATE TRIANGLE MESH
      CALL TRIANG

C     ELIMINATE DOUBLE COORDINATES
      CALL ELIM

C     ADJUST CELL NUMBERS OF THE ADDED TRIANGLES
      DO ITRIA=NTRIA1+2*N2EFF+1, NTRIA
        IX=TRIX(ITRIA)
        IY=TRIY(ITRIA)
        TRIX(ITRIA)=TRIX(2*NCELL(IX,IY))
        TRIY(ITRIA)=TRIY(2*NCELL(IX,IY))
      ENDDO

C     FIND NEIGHBOURS
      CALL NEIGHBOUR

C     WRITE NEW GRID
      CALL GRIDOUT
      WRITE (*,*) 'GRID WRITTEN '

C     PLOT THE GRIDS
!pb   XMIN=480.
!pb   YMIN=-600.
!pb   XMAX=1130.
!pb   YMAX=630.
      XMIN = MINVAL(XCOORD(1:NCOORD))
      YMIN = MINVAL(YCOORD(1:NCOORD))
      XMAX = MAXVAL(XCOORD(1:NCOORD))
      YMAX = MAXVAL(YCOORD(1:NCOORD))
      DELTAX=ABS(XMAX-XMIN)
      DELTAY=ABS(YMAX-YMIN)
      DELTA=MAX(DELTAX,DELTAY)
      XCM=25.*DELTAX/DELTA
      YCM=25.*DELTAY/DELTA

      print *,'Plotting the grid'
      print '(9(3x,a6,3x))','XMIN ','YMIN ','XMAX ','YMAX ',
     ,                      'DELTAX','DELTAY','DELTA ','XCM  ','YCM  '
      print '(1p,9e12.3)',XMIN,YMIN,XMAX,YMAX,
     ,                                    DELTAX,DELTAY,DELTA,XCM,YCM

      CALL GR90DG
      CALL GRSCLC(5.,1.,5.+XCM,1.+YCM)
      CALL GRSCLV(XMIN,YMIN,XMAX,YMAX)
C     PLOT THE OLD TRIANGLE-MESH
      DO ITRIA1=1,NTRIA1
        CALL GRJMP(REAL(XCOORD(TRIA(ITRIA1,1))),
     .             REAL(YCOORD(TRIA(ITRIA1,1))))
        CALL GRDRW(REAL(XCOORD(TRIA(ITRIA1,2))),
     .             REAL(YCOORD(TRIA(ITRIA1,2))))
        CALL GRDRW(REAL(XCOORD(TRIA(ITRIA1,3))),
     .             REAL(YCOORD(TRIA(ITRIA1,3))))
        CALL GRDRW(REAL(XCOORD(TRIA(ITRIA1,1))),
     .             REAL(YCOORD(TRIA(ITRIA1,1))))
      ENDDO
C     PLOT THE NEW TRIANGLE-MESH
      CALL GRNWPN(5)
      DO ITRIA=NTRIA1+1,NTRIA
        CALL GRJMP(REAL(XCOORD(TRIA(ITRIA,1))),
     .             REAL(YCOORD(TRIA(ITRIA,1))))
        CALL GRDRW(REAL(XCOORD(TRIA(ITRIA,2))),
     .             REAL(YCOORD(TRIA(ITRIA,2))))
        CALL GRDRW(REAL(XCOORD(TRIA(ITRIA,3))),
     .             REAL(YCOORD(TRIA(ITRIA,3))))
        CALL GRDRW(REAL(XCOORD(TRIA(ITRIA,1))),
     .             REAL(YCOORD(TRIA(ITRIA,1))))
      ENDDO
C     PLOT THE MARGIN OF THE NEW TRIANGLE-GRID
      CALL GRSPTS(25)
      DO ITRIA=NTRIA1+1,NTRIA
        DO IS=1,3
          ISP=IS+1
          IF (ISP .EQ. 4) ISP = 1
          IF (NEIGHR(ITRIA,IS) .NE. 0) THEN
            CALL GRNWPN(NEIGHR(ITRIA,IS))
            CALL GRJMP(REAL(XCOORD(TRIA(ITRIA,IS))),
     .                 REAL(YCOORD(TRIA(ITRIA,IS))))
            CALL GRDRW(REAL(XCOORD(TRIA(ITRIA,ISP))),
     .                 REAL(YCOORD(TRIA(ITRIA,ISP))))
          ENDIF
        ENDDO
      ENDDO
C     PLOT THE AXIS
      CALL GRSPTS(18)
      CALL GRNWPN(1)
      CALL GRAXS(-1,'X=3,Y=3',-1,' ',-1,' ')
      CALL GREND
      END


*//INIT//
C=======================================================================
C          S U B R O U T I N E  I N I T
C=======================================================================
C     INITIALIZE THE VARIABLES OF THE COMMON BLOCKS

      SUBROUTINE INIT
      use cdimen
      use ctria
      use ccuts
      IMPLICIT NONE

      NCOORD = 0
      ICOORD = 0

      NTRIA = 0
      NTRIA1 = 0
      ITRIA = 0
      ITRIA1 = 0

      NNCUT = 0
      ICUT = 0
      NNISO = 0
      IISO = 0
      END

*//TRIIN//
C=======================================================================
C          S U B R O U T I N E  T R I I N
C=======================================================================
C     READ TRIANGLE MESH

      SUBROUTINE TRIIN
      use cdimen
      use ctria
      IMPLICIT NONE

      INTEGER IDUMMY

      READ(21,*) NTRIA
      READ(23,*) idummy
      if (ntria .ne. idummy) then
         write(6,*) '*.elemente and *.neighbor files differ in number',
     .              ' of triangles'
         call exit
      endif
      allocate(tria(ntria,3))
      allocate(neighb(ntria,3))
      allocate(neighs(ntria,3))
      allocate(neighr(ntria,3))
      allocate(trix(ntria))
      allocate(triy(ntria))
      DO ITRIA=1,NTRIA
        READ(21,103) IDUMMY,TRIA(ITRIA,1),TRIA(ITRIA,2),TRIA(ITRIA,3)
        READ(23,104) IDUMMY,
     .               NEIGHB(ITRIA,1),NEIGHS(ITRIA,1),NEIGHR(ITRIA,1),
     .               NEIGHB(ITRIA,2),NEIGHS(ITRIA,2),NEIGHR(ITRIA,2),
     .               NEIGHB(ITRIA,3),NEIGHS(ITRIA,3),NEIGHR(ITRIA,3)
        TRIX(ITRIA) = -1
        TRIY(ITRIA) = -1
      ENDDO
103   FORMAT(I5,2X,3I7)
104   FORMAT(I5,2X,3(I6,2I3,2X))

      READ(22,*) NCOORD
      allocate(xcoord(ncoord))
      allocate(ycoord(ncoord))
      READ(22,*) (XCOORD(ICOORD),ICOORD=1,NCOORD)
      READ(22,*) (YCOORD(ICOORD),ICOORD=1,NCOORD)
      NTRIA1 = NTRIA
      END

*//SONIN//
C=======================================================================
C          S U B R O U T I N E  S O N I N
C=======================================================================
C     READ PHYSICAL COORDINATES FROM SONNET FILE TO XCOORD, YCOORD

      SUBROUTINE SONIN
      use cdimen
      use ctria
      use ccuts
      IMPLICIT NONE

      DOUBLEPRECISION, allocatable :: BR(:,:,:), BZ(:,:,:)
      doubleprecision  CR, CZ, PIT
      doubleprecision, allocatable :: help3(:,:,:)
      INTEGER I0, I0E, I1, I2, I3, I4, IX0
      integer dim1, dim2
      CHARACTER*110 ZEILE

*  READ PHYSICAL COORDINATES FROM SONNET FILE
*  ---------------------------------------------------------------------
*  INFORMATION FOR EACH CELL
*
*     NO. OF CELL     (IX,IY)     (BR(4),BZ(4))       (BR(3),BZ(3))
*
*            PITCH                             (CR,CZ)
*
*                                 (BR(1),BZ(1))       (BR(2),BZ(2))
      
      allocate(br(0:10,0:10,4))
      allocate(bz(0:10,0:10,4))
      read (20,*)
      read (20,*)
      read (20,*)
      read (20,*)

4711  continue

*  READ FIRST LINE OF CELL DATA
      read (20,'(a110)',end=99) zeile
      i0=index(zeile,'(')
      i0e=index(zeile,')')
      read (zeile(i0+1:i0e-1),*) ix,iy

      if (ix .ge. size(br,1)) then
         dim1 = size(br,1)
         dim2 = size(br,2)
         allocate(help3(dim1,dim2,4))
         
         help3(1:dim1,1:dim2,1:4) = br(0:dim1-1,0:dim2-1,1:4)
         deallocate(br)
         allocate(br(0:dim1-1+10,0:dim2-1,4))
         br = 0.
         br(0:dim1-1,0:dim2-1,1:4) = help3(1:dim1,1:dim2,1:4)
         
         help3(1:dim1,1:dim2,1:4) = bz(0:dim1-1,0:dim2-1,1:4)
         deallocate(bz)
         allocate(bz(0:dim1-1+10,0:dim2-1,4))
         bz = 0.
         bz(0:dim1-1,0:dim2-1,1:4) = help3(1:dim1,1:dim2,1:4)
         
         deallocate(help3)
      endif
      if (iy .ge. size(br,2)) then
         dim1 = size(br,1)
         dim2 = size(br,2)
         allocate(help3(dim1,dim2,4))
         
         help3(1:dim1,1:dim2,1:4) = br(0:dim1-1,0:dim2-1,1:4)
         deallocate(br)
         allocate(br(0:dim1-1,0:dim2-1+10,4))
         br = 0.
         br(0:dim1-1,0:dim2-1,1:4) = help3(1:dim1,1:dim2,1:4)
         
         help3(1:dim1,1:dim2,1:4) = bz(0:dim1-1,0:dim2-1,1:4)
         deallocate(bz)
         allocate(bz(0:dim1-1,0:dim2-1+10,4))
         bz = 0.
         bz(0:dim1-1,0:dim2-1,1:4) = help3(1:dim1,1:dim2,1:4)
         
         deallocate(help3)
      endif
      
      i1=index(zeile,': (')
      i2=index(zeile(i1+3:),')')+i1+2
      read (zeile(i1+3:i2-1),*) br(ix,iy,4),bz(ix,iy,4)
      i3=index(zeile(i2+1:),'(')+i2
      i4=i3+index(zeile(i3+1:),')')
      read (zeile(i3+1:i4-1),*) br(ix,iy,3),bz(ix,iy,3)
      
*     READ SECOND LINE OF CELL DATA
      read (20,'(a110)') zeile

*     READ THIRD LINE OF CELL DATA
      read (20,'(a110)') zeile
      i1=index(zeile,'(')
      i2=index(zeile,')')
      read (zeile(i1+1:i2-1),*) br(ix,iy,1),bz(ix,iy,1)
      i3=i2+index(zeile(i2+1:),'(')
      i4=i2+index(zeile(i2+1:),')')
      read (zeile(i3+1:i4-1),*) br(ix,iy,2),bz(ix,iy,2)

      read (20,*,end=99)

      goto 4711

99    continue
      NX=IX-1
      NY=IY-1
C     SEARCHING FOR CUTS
      NNCUT=0
      DO IX=0,NX
        IF (ABS(BR(IX,0,2)-BR(IX+1,0,1)) .GT. 1E-6 .OR.
     .      ABS(BZ(IX,0,2)-BZ(IX+1,0,1)) .GT. 1E-6 .OR.
     .      ABS(BR(IX,0,3)-BR(IX+1,0,4)) .GT. 1E-6 .OR.
     .      ABS(BZ(IX,0,3)-BZ(IX+1,0,4)) .GT. 1E-6) THEN
          if (allocated(nxcut1)) then
             call realloc_ccuts('cut',1)
          else
             allocate(nxcut1(1))
             allocate(nxcut2(1))
             allocate(nycut1(1))
             allocate(nycut2(1))
          endif
          NNCUT=NNCUT+1
          NXCUT1(NNCUT)=IX
          DO IX0=0,NX
            IF (ABS(BR(IX,0,2)-BR(IX0,0,1)) .LT. 1E-6 .AND.
     .          ABS(BZ(IX,0,2)-BZ(IX0,0,1)) .LT. 1E-6 .AND.
     .          ABS(BR(IX,0,3)-BR(IX0,0,4)) .LT. 1E-6 .AND.
     .          ABS(BZ(IX,0,3)-BZ(IX0,0,4)) .LT. 1E-6) THEN
              NXCUT2(NNCUT)=IX0
            ENDIF
          ENDDO
          NYCUT1(NNCUT)=0
        ENDIF
      ENDDO
      IF (NNCUT .GT. 0) THEN
        DO ICUT=1,NNCUT
          DO IY=0,NY+1
            IF (ABS(BR(NXCUT1(ICUT),IY,2)-
     .              BR(NXCUT1(ICUT)+1,IY,1)) .LT. 1E-6 .AND.
     .          ABS(BZ(NXCUT1(ICUT),IY,2)-
     .              BZ(NXCUT1(ICUT)+1,IY,1)) .LT. 1E-6 .AND.
     .          ABS(BR(NXCUT1(ICUT),IY,3)-
     .              BR(NXCUT1(ICUT)+1,IY,4)) .LT. 1E-6 .AND.
     .          ABS(BZ(NXCUT1(ICUT),IY,3)-
     .              BZ(NXCUT1(ICUT)+1,IY,4)) .LT. 1E-6) THEN
              NYCUT2(ICUT)=IY-1
              GOTO 10
            ENDIF
          ENDDO
10      ENDDO
      ENDIF

      call realloc_ctria('xycoord',(nx+1)*(ny+1))
      DO IY=1,NY+1
        DO IX=1,NX+1
          XCOORD((IY-1)*(NX+1)+IX+NCOORD)=BR(IX,IY,1)*100.
          YCOORD((IY-1)*(NX+1)+IX+NCOORD)=BZ(IX,IY,1)*100.
        ENDDO
      ENDDO
      END

*//TRIANG//
C=======================================================================
C          S U B R O U T I N E  T R I A N G
C=======================================================================
C     CREATE TRIANGLE MESH

      SUBROUTINE TRIANG
      use cdimen
      use ctria
      use ccuts
      IMPLICIT NONE

      INTEGER IX1

      call realloc_ctria('tria',2*n2eff+ntria1-size(tria,1))
      call realloc_ctria('neigh',2*n2eff+ntria1-size(neighb,1))
      call realloc_ctria('trixy',2*n2eff+ntria1-size(trix))
      DO IY=1,NY
        DO IX=1,NX
          IF (NCELL(IX,IY).NE.0) THEN
c location of vertices in the list of coordinates
            TRIA(2*NCELL(IX,IY)-1+NTRIA1,1)=(IY-1)*(NX+1)+IX+NCOORD
            TRIA(2*NCELL(IX,IY)-1+NTRIA1,2)=IY*(NX+1)+IX+1+NCOORD
            TRIA(2*NCELL(IX,IY)-1+NTRIA1,3)=IY*(NX+1)+IX+NCOORD

            TRIA(2*NCELL(IX,IY)+NTRIA1,1)=(IY-1)*(NX+1)+IX+NCOORD
            TRIA(2*NCELL(IX,IY)+NTRIA1,2)=(IY-1)*(NX+1)+IX+1+NCOORD
            TRIA(2*NCELL(IX,IY)+NTRIA1,3)=IY*(NX+1)+IX+1+NCOORD

c shared side
            NEIGHB(2*NCELL(IX,IY)-1+NTRIA1,1)=2*NCELL(IX,IY)+NTRIA1
            NEIGHS(2*NCELL(IX,IY)-1+NTRIA1,1)=3
            NEIGHR(2*NCELL(IX,IY)-1+NTRIA1,1)=0

            NEIGHB(2*NCELL(IX,IY)+NTRIA1,3)=2*NCELL(IX,IY)-1+NTRIA1
            NEIGHS(2*NCELL(IX,IY)+NTRIA1,3)=1
            NEIGHR(2*NCELL(IX,IY)+NTRIA1,3)=0

c top side
            IF (NCELL(IX,IY+1).NE.0) THEN
              NEIGHB(2*NCELL(IX,IY)-1+NTRIA1,2)=2*NCELL(IX,IY+1)+NTRIA1
              NEIGHS(2*NCELL(IX,IY)-1+NTRIA1,2)=1
              NEIGHR(2*NCELL(IX,IY)-1+NTRIA1,2)=0
            ELSE
              NEIGHB(2*NCELL(IX,IY)-1+NTRIA1,2)=0
              NEIGHS(2*NCELL(IX,IY)-1+NTRIA1,2)=0
              NEIGHR(2*NCELL(IX,IY)-1+NTRIA1,2)=2
            ENDIF
              
c left side
            IF (NCELL(IX-1,IY).NE.0) THEN
              NEIGHB(2*NCELL(IX,IY)-1+NTRIA1,3)=2*NCELL(IX-1,IY)+NTRIA1
              NEIGHS(2*NCELL(IX,IY)-1+NTRIA1,3)=2
              NEIGHR(2*NCELL(IX,IY)-1+NTRIA1,3)=0
            ELSE
              NEIGHB(2*NCELL(IX,IY)-1+NTRIA1,3)=0
              NEIGHS(2*NCELL(IX,IY)-1+NTRIA1,3)=0
              NEIGHR(2*NCELL(IX,IY)-1+NTRIA1,3)=3
            ENDIF

c bottom side
            IF (NCELL(IX,IY-1).NE.0) THEN
              NEIGHB(2*NCELL(IX,IY)+NTRIA1,1)=2*NCELL(IX,IY-1)-1+NTRIA1
              NEIGHS(2*NCELL(IX,IY)+NTRIA1,1)=2
              NEIGHR(2*NCELL(IX,IY)+NTRIA1,1)=0
            ELSE
              NEIGHB(2*NCELL(IX,IY)+NTRIA1,1)=0
              NEIGHS(2*NCELL(IX,IY)+NTRIA1,1)=0
              NEIGHR(2*NCELL(IX,IY)+NTRIA1,1)=1
            ENDIF

c right side
            IF (NCELL(IX+1,IY).NE.0) THEN
              NEIGHB(2*NCELL(IX,IY)+NTRIA1,2)=2*NCELL(IX+1,IY)-1+NTRIA1
              NEIGHS(2*NCELL(IX,IY)+NTRIA1,2)=3
              NEIGHR(2*NCELL(IX,IY)+NTRIA1,2)=0
            ELSE
              NEIGHB(2*NCELL(IX,IY)+NTRIA1,2)=0
              NEIGHS(2*NCELL(IX,IY)+NTRIA1,2)=0
              NEIGHR(2*NCELL(IX,IY)+NTRIA1,2)=4
            ENDIF

c mesh coordinates
            TRIX(2*NCELL(IX,IY)-1+NTRIA1) = IX
            TRIY(2*NCELL(IX,IY)-1+NTRIA1) = IY

            TRIX(2*NCELL(IX,IY)+NTRIA1) = IX
            TRIY(2*NCELL(IX,IY)+NTRIA1) = IY
          ENDIF
        ENDDO
      ENDDO
C     CUTS !!
c     Modify neighbouring information
c     Shift from B2 grid numbering to Eirene grid numbering
      DO ICUT=1,NNCUT
        IX=NXCUT1(ICUT)
        IX1=NXCUT2(ICUT)
        DO IY=MAX(1,NYCUT1(ICUT)),MIN(NY,NYCUT2(ICUT))
          TRIA(2*NCELL(IX,IY)-1+NTRIA1,2)=IY*(NX+1)+IX1+NCOORD

          TRIA(2*NCELL(IX,IY)+NTRIA1,3)=IY*(NX+1)+IX1+NCOORD
          TRIA(2*NCELL(IX,IY)+NTRIA1,2)=(IY-1)*(NX+1)+IX1+NCOORD
          NEIGHB(2*NCELL(IX,IY)+NTRIA1,2)=2*NCELL(IX1,IY)-1+NTRIA1

          NEIGHB(2*NCELL(IX1,IY)-1+NTRIA1,3)=2*NCELL(IX,IY)+NTRIA1
        ENDDO
        DO IX=NXCUT2(ICUT),NX
          DO IY=1,NY
            IF (NCELL(IX,IY).NE.0) THEN
              TRIX(2*NCELL(IX,IY)+NTRIA1) =
     .               TRIX(2*NCELL(IX,IY)+NTRIA1) + 1
              TRIX(2*NCELL(IX,IY)-1+NTRIA1) =
     .               TRIX(2*NCELL(IX,IY)-1+NTRIA1) + 1
            ENDIF
          ENDDO
        ENDDO
      ENDDO
      DO IISO=1,NNISO
        IF(NYISO1(IISO).EQ.0 .AND. NYISO2(IISO).EQ.NY) THEN
          DO IX=NXISO2(IISO)+1,NX
            DO IY=1,NY
              IF (NCELL(IX,IY).NE.0) THEN
                TRIX(2*NCELL(IX,IY)+NTRIA1) =
     .               TRIX(2*NCELL(IX,IY)+NTRIA1) + 1
                TRIX(2*NCELL(IX,IY)-1+NTRIA1) =
     .               TRIX(2*NCELL(IX,IY)-1+NTRIA1) + 1
              ENDIF
            ENDDO
          ENDDO
        ENDIF
      ENDDO
      NTRIA = NTRIA1 + 2*N2EFF
      END

*//ELIM//
C=======================================================================
C          S U B R O U T I N E  E L I M
C=======================================================================
C     ELIMINATE DOUBLE COORDINATES

      SUBROUTINE ELIM
      use cdimen
      use ctria
      IMPLICIT NONE

      integer, allocatable :: ico(:)
      INTEGER L,I,J, K, ANZCOORD

      allocate(ico(ncoord+(nx+1)*(ny+1)))
      DO J=1,NCOORD+(NX+1)*(NY+1)
        ICO(J)=J
      ENDDO
      ANZCOORD=NCOORD+(NX+1)*(NY+1)
      DO ICOORD=1,NCOORD+(NX+1)*(NY+1)
11      CONTINUE
        DO J=ICOORD+1,NCOORD+(NX+1)*(NY+1)
C         IF (ICO(J) .GT. NCOORD) THEN
          IF (ICO(J) .NE. ICOORD) THEN
            IF (ABS(XCOORD(ICOORD)-XCOORD(ICO(J))) .LT. 1.E-6 .AND.
     .          ABS(YCOORD(ICOORD)-YCOORD(ICO(J))) .LT. 1.E-6) THEN
              DO K=ICOORD+1,NCOORD+(NX+1)*(NY+1)
                IF ( ICO(K).GT.ICO(J) ) THEN
                  ICO(K)=ICO(K)-1
                ENDIF
              ENDDO
              DO K=ICO(J),ANZCOORD-1
                XCOORD(K)=XCOORD(K+1)
                YCOORD(K)=YCOORD(K+1)
              ENDDO
              XCOORD(ANZCOORD)=0.
              YCOORD(ANZCOORD)=0.
              ICO(J)=ICOORD
              ANZCOORD=ANZCOORD-1
              GOTO 11
            ENDIF
          ENDIF
        ENDDO
      ENDDO
      DO ITRIA=NTRIA1+1,NTRIA1+2*N2EFF
        DO K=NCOORD+1,NCOORD+(NX+1)*(NY+1)
          IF (TRIA(ITRIA,1) .EQ. K) TRIA(ITRIA,1)=ICO(K)
          IF (TRIA(ITRIA,2) .EQ. K) TRIA(ITRIA,2)=ICO(K)
          IF (TRIA(ITRIA,3) .EQ. K) TRIA(ITRIA,3)=ICO(K)
        ENDDO
      ENDDO
      NCOORD=ANZCOORD
      END

*//NEIGHBOUR//
C=======================================================================
C          S U B R O U T I N E  N E I G H B O U R
C=======================================================================
C     FIND NEIGHBOURS

      SUBROUTINE NEIGHBOUR
      use cdimen
      use ctria
      use ccuts
      IMPLICIT NONE

      INTEGER I, J, K, L, M, IS
      LOGICAL PARA

      CALL GRSPTS(25)
      CALL GRNWPN(6)
13    CONTINUE
      DO ITRIA1=1,NTRIA1
        IF (ABS(NEIGHR(ITRIA1,1))+ABS(NEIGHR(ITRIA1,2))+
     .      ABS(NEIGHR(ITRIA1,3)) .NE. 0) THEN
C         ELEMENT ITRIA1 HAT MINDESTENS EINE SEITE AUF BEGRENZUNGS-
C         KONTUR
          DO ITRIA=NTRIA1+1,NTRIA
            IF (ABS(NEIGHR(ITRIA,1))+ABS(NEIGHR(ITRIA,2))+
     .          ABS(NEIGHR(ITRIA,3)).NE.0) THEN
C             ELEMENT ITRIA HAT MINDESTENS EINE SEITE AUF BEGRENZUNGS-
C             KONTUR
              DO I=1,3
                J=I+1
                IF (J .EQ. 4) J = 1
                DO K=1,3
                  L=K+1
                  IF (L .EQ. 4) L = 1
                  M=L+1
                  IF (M .EQ. 4) M = 1
                  IF ((TRIA(ITRIA1,I) .EQ. TRIA(ITRIA,L)) .AND.
     .                (TRIA(ITRIA1,J) .EQ. TRIA(ITRIA,K))) THEN
                    NEIGHB(ITRIA1,I) = ITRIA
                    NEIGHS(ITRIA1,I) = K
                    NEIGHR(ITRIA1,I) = 0
                    NEIGHB(ITRIA,K) = ITRIA1
                    NEIGHS(ITRIA,K) = I
                    NEIGHR(ITRIA,K) = 0
                    CALL GRJMP(REAL(XCOORD(TRIA(ITRIA1,I))),
     .                         REAL(YCOORD(TRIA(ITRIA1,I))))
                    CALL GRDRW(REAL(XCOORD(TRIA(ITRIA1,J))),
     .                         REAL(YCOORD(TRIA(ITRIA1,J))))
                  ENDIF
                  IF ((NEIGHR(ITRIA1,I) .NE. 0) .AND.
     .                (NEIGHR(ITRIA,K) .NE. 0) .AND.
     .                (PARA(XCOORD(TRIA(ITRIA1,J)),
     .                      YCOORD(TRIA(ITRIA1,J)),
     .                      XCOORD(TRIA(ITRIA1,I)),
     .                      YCOORD(TRIA(ITRIA1,I)),
     .                      XCOORD(TRIA(ITRIA,K)),
     .                      YCOORD(TRIA(ITRIA,K)),
     .                      XCOORD(TRIA(ITRIA,L)),
     .                      YCOORD(TRIA(ITRIA,L)))) .AND.
     .                (TRIA(ITRIA1,J) .EQ. TRIA(ITRIA,K)) .AND.
     .                (TRIA(ITRIA1,I) .NE. TRIA(ITRIA,L))) THEN
                    NTRIA = NTRIA + 1
                    call realloc_ctria('neigh',1)
                    call realloc_ctria('tria',1)
                    call realloc_ctria('trixy',1)
                    DO IS=1,3
                      TRIA(NTRIA,IS) = TRIA(ITRIA,IS)
                      NEIGHB(NTRIA,IS) = NEIGHB(ITRIA,IS)
                      NEIGHS(NTRIA,IS) = NEIGHS(ITRIA,IS)
                      NEIGHR(NTRIA,IS) = NEIGHR(ITRIA,IS)
                    ENDDO
                    TRIA(NTRIA,K) = TRIA(ITRIA1,I)
                    NEIGHB(NTRIA,M) = ITRIA
                    NEIGHS(NTRIA,M) = L
                    NEIGHR(NTRIA,M) = 0
                    TRIX(NTRIA) = TRIX(ITRIA)
                    TRIY(NTRIA) = TRIY(ITRIA)
    
                    TRIA(ITRIA,L) = TRIA(ITRIA1,I)
                    NEIGHB(ITRIA,K) = ITRIA1
                    NEIGHB(ITRIA,L) = NTRIA
                    NEIGHS(ITRIA,K) = I
                    NEIGHS(ITRIA,L) = M
                    NEIGHR(ITRIA,K) = 0
                    NEIGHR(ITRIA,L) = 0
    
                    NEIGHB(ITRIA1,I) = ITRIA
                    NEIGHS(ITRIA1,I) = K
                    NEIGHR(ITRIA1,I) = 0

                    IF (NEIGHB(NTRIA,L).NE.0) 
     >               NEIGHB(NEIGHB(NTRIA,L),NEIGHS(NTRIA,L)) = NTRIA

                    CALL GRNWPN(7)
                    CALL GRJMP(REAL(XCOORD(TRIA(ITRIA1,J))),
     .                         REAL(YCOORD(TRIA(ITRIA1,J))))
                    CALL GRDRW(REAL(XCOORD(TRIA(ITRIA1,I))),
     .                         REAL(YCOORD(TRIA(ITRIA1,I))))
                    CALL GRJMP(REAL(XCOORD(TRIA(ITRIA,K))),
     .                         REAL(YCOORD(TRIA(ITRIA,K))))
                    CALL GRDRW(REAL(XCOORD(TRIA(ITRIA,L))),
     .                         REAL(YCOORD(TRIA(ITRIA,L))))
                    CALL GRNWPN(6)
                    GOTO 13
                  ENDIF
                  IF ((NEIGHR(ITRIA1,I) .NE. 0) .AND.
     .                (NEIGHR(ITRIA,K) .NE. 0) .AND.
     .                (PARA(XCOORD(TRIA(ITRIA1,I)),
     .                      YCOORD(TRIA(ITRIA1,I)),
     .                      XCOORD(TRIA(ITRIA1,J)),
     .                      YCOORD(TRIA(ITRIA1,J)),
     .                      XCOORD(TRIA(ITRIA,L)),
     .                      YCOORD(TRIA(ITRIA,L)),
     .                      XCOORD(TRIA(ITRIA,K)),
     .                      YCOORD(TRIA(ITRIA,K)))) .AND.
     .                (TRIA(ITRIA1,I) .EQ. TRIA(ITRIA,L)) .AND.
     .                (TRIA(ITRIA1,J) .NE. TRIA(ITRIA,K))) THEN
                    NTRIA = NTRIA + 1
                    call realloc_ctria('neigh',1)
                    call realloc_ctria('tria',1)
                    call realloc_ctria('trixy',1)
                    DO IS=1,3
                      TRIA(NTRIA,IS) = TRIA(ITRIA,IS)
                      NEIGHB(NTRIA,IS) = NEIGHB(ITRIA,IS)
                      NEIGHS(NTRIA,IS) = NEIGHS(ITRIA,IS)
                      NEIGHR(NTRIA,IS) = NEIGHR(ITRIA,IS)
                    ENDDO
                    TRIA(NTRIA,L) = TRIA(ITRIA1,J)
                    NEIGHB(NTRIA,L) = ITRIA
                    NEIGHS(NTRIA,L) = M
                    NEIGHR(NTRIA,L) = 0
                    TRIX(NTRIA) = TRIX(ITRIA)
                    TRIY(NTRIA) = TRIY(ITRIA)
    
                    TRIA(ITRIA,K) = TRIA(ITRIA1,J)
                    NEIGHB(ITRIA,K) = ITRIA1
                    NEIGHB(ITRIA,M) = NTRIA
                    NEIGHS(ITRIA,K) = I
                    NEIGHS(ITRIA,M) = L
                    NEIGHR(ITRIA,K) = 0
                    NEIGHR(ITRIA,M) = 0
    
                    NEIGHB(ITRIA1,I) = ITRIA
                    NEIGHS(ITRIA1,I) = K
                    NEIGHR(ITRIA1,I) = 0

                    IF (NEIGHB(NTRIA,M).NE.0) 
     >               NEIGHB(NEIGHB(NTRIA,M),NEIGHS(NTRIA,M)) = NTRIA

                    CALL GRNWPN(7)
                    CALL GRJMP(REAL(XCOORD(TRIA(ITRIA1,J))),
     .                         REAL(YCOORD(TRIA(ITRIA1,J))))
                    CALL GRDRW(REAL(XCOORD(TRIA(ITRIA1,I))),
     .                         REAL(YCOORD(TRIA(ITRIA1,I))))
                    CALL GRJMP(REAL(XCOORD(TRIA(ITRIA,K))),
     .                         REAL(YCOORD(TRIA(ITRIA,K))))
                    CALL GRDRW(REAL(XCOORD(TRIA(ITRIA,L))),
     .                         REAL(YCOORD(TRIA(ITRIA,L))))
                    CALL GRNWPN(6)
                    GOTO 13
                  ENDIF
                ENDDO
              ENDDO
            ENDIF
          ENDDO
        ENDIF
      ENDDO
      END

*//PARA//
C=======================================================================
C          F U N C T I O N  P A R A
C=======================================================================
C     CHECK PARALLELISM OF TWO MARGINS

      FUNCTION PARA(XP2,YP2,XP1,YP1,XQ1,YQ1,XQ2,YQ2)
      IMPLICIT NONE
      DOUBLE PRECISION XP2,YP2,XP1,YP1,XQ1,YQ1,XQ2,YQ2
      LOGICAL PARA

cxpb  We need to have not only (P1,P2) parallel to (Q1,Q2) but
cxpb  also (P1,P2) shorter than (Q1,Q2)
 
      IF (ABS(XP2-XP1) .GT. 1.E-6) THEN
        IF (ABS(XQ1-XQ2) .GT. 1.E-6) THEN
          IF (ABS(ABS((YP2-YP1)/((YQ1-YQ2)+1.e-20)) -
     .            ABS((XP2-XP1)/(XQ1-XQ2))) .LT. 1.E-6) THEN
            PARA = ABS(XP2-XP1).LE.ABS(XQ2-XQ1)
          ELSE
            PARA = .FALSE.
          ENDIF
        ELSE
          PARA = .FALSE.
        ENDIF
      ELSE
        IF (ABS(XQ1-XQ2) .GT. 1.E-6) THEN
          PARA = .FALSE.
        ELSE
          PARA = ABS(YP2-YP1).LE.ABS(YQ2-YQ1)
        ENDIF
      ENDIF
c DPC: additional constraint - (p1,p2) should be contained by (q1,q2)
      if(para) para=min(xp1,xp2).ge.min(xq1,xq2)
      if(para) para=min(yp1,yp2).ge.min(yq1,yq2)
      if(para) para=max(xp1,xp2).le.max(xq1,xq2)
      if(para) para=max(yp1,yp2).le.max(yq1,yq2)

      END

*//GRIDOUT//
C=======================================================================
C          S U B R O U T I N E  G R I D O U T
C=======================================================================
C     WRITE NEW GRID

      SUBROUTINE GRIDOUT
      use cdimen
      use ctria
      IMPLICIT NONE

      WRITE(9,*) NCOORD
      WRITE(9,'(4E19.8)') (XCOORD(ICOORD),ICOORD=1,NCOORD)
      WRITE(9,'(4E19.8)') (YCOORD(ICOORD),ICOORD=1,NCOORD)

      WRITE(8,*) NTRIA
      WRITE(10,*) NTRIA
      DO ITRIA=1,NTRIA
        WRITE(8,'(I6,2X,3I6,4X)') ITRIA,
     .       TRIA(ITRIA,1),TRIA(ITRIA,2),TRIA(ITRIA,3)
        WRITE(10,'(I6,2X,4(3I6,4X))') ITRIA,
     .       NEIGHB(ITRIA,1),NEIGHS(ITRIA,1),NEIGHR(ITRIA,1),
     .       NEIGHB(ITRIA,2),NEIGHS(ITRIA,2),NEIGHR(ITRIA,2),
     .       NEIGHB(ITRIA,3),NEIGHS(ITRIA,3),NEIGHR(ITRIA,3),
     .       TRIX(ITRIA),TRIY(ITRIA)
      ENDDO
      END
