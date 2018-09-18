      PROGRAM TRIAGEOM

c  version : 26.09.2016 20:42

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
      INTEGER IS, IX, IY, ISP, ITRIA, ITRIA1

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
C     PLOT THE OLD TRIANGLE MESH
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
C     PLOT THE NEW TRIANGLE MESH
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
C     PLOT THE MARGIN OF THE NEW TRIANGLE GRID
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

      NTRIA = 0
      NTRIA1 = 0

      NNCUT = 0
      NNISO = 0
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

      INTEGER IDUMMY, ICOORD, ITRIA

      READ(21,*) NTRIA
      READ(23,*) idummy
      if (ntria .ne. idummy) then
         write(6,*) '*.elemente and *.neighbor files differ in number',
     .              ' of triangles'
         stop
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
      print *,'ncoord=',ncoord  !###
      allocate(xcoord(ncoord))
      allocate(ycoord(ncoord))
      if(ncoord.gt.0) then !{
        READ(22,*) (XCOORD(ICOORD),ICOORD=1,NCOORD)
        READ(22,*) (YCOORD(ICOORD),ICOORD=1,NCOORD)
      end if !}
      NTRIA1 = NTRIA
      END

c*//SONIN//
cC=======================================================================
cC          S U B R O U T I N E  S O N I N
cC=======================================================================
cC     READ PHYSICAL COORDINATES FROM SONNET FILE TO XCOORD, YCOORD
c
c      SUBROUTINE SONIN
c      use cdimen
c      use ctria
c      use ccuts
c      IMPLICIT NONE
c
c      DOUBLEPRECISION, allocatable :: BR(:,:,:), BZ(:,:,:)
c      doubleprecision  CR, CZ, PIT
c      doubleprecision, allocatable :: help3(:,:,:)
c      INTEGER I0, I0E, I1, I2, I3, I4, IX, IY, IX0
c      integer dim1, dim2
c      CHARACTER*110 ZEILE
c
c*  READ PHYSICAL COORDINATES FROM SONNET FILE
c*  ---------------------------------------------------------------------
c*  INFORMATION FOR EACH CELL
c*
c*     NO. OF CELL     (IX,IY)     (BR(4),BZ(4))       (BR(3),BZ(3))
c*
c*            PITCH                             (CR,CZ)
c*
c*                                 (BR(1),BZ(1))       (BR(2),BZ(2))
c      
c      allocate(br(0:10,0:10,4))
c      allocate(bz(0:10,0:10,4))
c      read (20,*)
c      read (20,*)
c      read (20,*)
c      read (20,*)
c
c4711  continue
c
c*  READ FIRST LINE OF CELL DATA
c      read (20,'(a110)',end=99) zeile
c      i0=index(zeile,'(')
c      i0e=index(zeile,')')
c      read (zeile(i0+1:i0e-1),*) ix,iy
c
c      if (ix .ge. size(br,1)) then
c         dim1 = size(br,1)
c         dim2 = size(br,2)
c         allocate(help3(dim1,dim2,4))
c         
c         help3(1:dim1,1:dim2,1:4) = br(0:dim1-1,0:dim2-1,1:4)
c         deallocate(br)
c         allocate(br(0:dim1-1+10,0:dim2-1,4))
c         br = 0.
c         br(0:dim1-1,0:dim2-1,1:4) = help3(1:dim1,1:dim2,1:4)
c         
c         help3(1:dim1,1:dim2,1:4) = bz(0:dim1-1,0:dim2-1,1:4)
c         deallocate(bz)
c         allocate(bz(0:dim1-1+10,0:dim2-1,4))
c         bz = 0.
c         bz(0:dim1-1,0:dim2-1,1:4) = help3(1:dim1,1:dim2,1:4)
c         
c         deallocate(help3)
c      endif
c      if (iy .ge. size(br,2)) then
c         dim1 = size(br,1)
c         dim2 = size(br,2)
c         allocate(help3(dim1,dim2,4))
c         
c         help3(1:dim1,1:dim2,1:4) = br(0:dim1-1,0:dim2-1,1:4)
c         deallocate(br)
c         allocate(br(0:dim1-1,0:dim2-1+10,4))
c         br = 0.
c         br(0:dim1-1,0:dim2-1,1:4) = help3(1:dim1,1:dim2,1:4)
c         
c         help3(1:dim1,1:dim2,1:4) = bz(0:dim1-1,0:dim2-1,1:4)
c         deallocate(bz)
c         allocate(bz(0:dim1-1,0:dim2-1+10,4))
c         bz = 0.
c         bz(0:dim1-1,0:dim2-1,1:4) = help3(1:dim1,1:dim2,1:4)
c         
c         deallocate(help3)
c      endif
c      
c      i1=index(zeile,': (')
c      i2=index(zeile(i1+3:),')')+i1+2
c      read (zeile(i1+3:i2-1),*) br(ix,iy,4),bz(ix,iy,4)
c      i3=index(zeile(i2+1:),'(')+i2
c      i4=i3+index(zeile(i3+1:),')')
c      read (zeile(i3+1:i4-1),*) br(ix,iy,3),bz(ix,iy,3)
c      
c*     READ SECOND LINE OF CELL DATA
c      read (20,'(a110)') zeile
c
c*     READ THIRD LINE OF CELL DATA
c      read (20,'(a110)') zeile
c      i1=index(zeile,'(')
c      i2=index(zeile,')')
c      read (zeile(i1+1:i2-1),*) br(ix,iy,1),bz(ix,iy,1)
c      i3=i2+index(zeile(i2+1:),'(')
c      i4=i2+index(zeile(i2+1:),')')
c      read (zeile(i3+1:i4-1),*) br(ix,iy,2),bz(ix,iy,2)
c
c      read (20,*,end=99)
c
c      goto 4711
c
c99    continue
c      NX=IX-1
c      NY=IY-1
cC     SEARCHING FOR CUTS
c      NNCUT=0
c      DO IX=0,NX
c        IF (ABS(BR(IX,0,2)-BR(IX+1,0,1)) .GT. 1E-6 .OR.
c     .      ABS(BZ(IX,0,2)-BZ(IX+1,0,1)) .GT. 1E-6 .OR.
c     .      ABS(BR(IX,0,3)-BR(IX+1,0,4)) .GT. 1E-6 .OR.
c     .      ABS(BZ(IX,0,3)-BZ(IX+1,0,4)) .GT. 1E-6) THEN
c          if (allocated(nxcut1)) then
c             call realloc_ccuts('cut',1)
c          else
c             allocate(nxcut1(1))
c             allocate(nxcut2(1))
c             allocate(nycut1(1))
c             allocate(nycut2(1))
c          endif
c          NNCUT=NNCUT+1
c          NXCUT1(NNCUT)=IX
c          DO IX0=0,NX
c            IF (ABS(BR(IX,0,2)-BR(IX0,0,1)) .LT. 1E-6 .AND.
c     .          ABS(BZ(IX,0,2)-BZ(IX0,0,1)) .LT. 1E-6 .AND.
c     .          ABS(BR(IX,0,3)-BR(IX0,0,4)) .LT. 1E-6 .AND.
c     .          ABS(BZ(IX,0,3)-BZ(IX0,0,4)) .LT. 1E-6) THEN
c              NXCUT2(NNCUT)=IX0
c            ENDIF
c          ENDDO
c          NYCUT1(NNCUT)=0
c        ENDIF
c      ENDDO
c      IF (NNCUT .GT. 0) THEN
c        DO ICUT=1,NNCUT
c          DO IY=0,NY+1
c            IF (ABS(BR(NXCUT1(ICUT),IY,2)-
c     .              BR(NXCUT1(ICUT)+1,IY,1)) .LT. 1E-6 .AND.
c     .          ABS(BZ(NXCUT1(ICUT),IY,2)-
c     .              BZ(NXCUT1(ICUT)+1,IY,1)) .LT. 1E-6 .AND.
c     .          ABS(BR(NXCUT1(ICUT),IY,3)-
c     .              BR(NXCUT1(ICUT)+1,IY,4)) .LT. 1E-6 .AND.
c     .          ABS(BZ(NXCUT1(ICUT),IY,3)-
c     .              BZ(NXCUT1(ICUT)+1,IY,4)) .LT. 1E-6) THEN
c              NYCUT2(ICUT)=IY-1
c              GOTO 10
c            ENDIF
c          ENDDO
c10      ENDDO
c      ENDIF
c
c      call realloc_ctria('xycoord',(nx+1)*(ny+1))
c      DO IY=1,NY+1
c        DO IX=1,NX+1
c          XCOORD((IY-1)*(NX+1)+IX+NCOORD)=BR(IX,IY,1)*100.
c          YCOORD((IY-1)*(NX+1)+IX+NCOORD)=BZ(IX,IY,1)*100.
c        ENDDO
c      ENDDO
c      END

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

      INTEGER IX, IY, IX1, ICUT, IISO

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
      INTEGER J, K, ICOORD, ANZCOORD, ITRIA

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

      INTEGER I, J, K, KK, L, M, IS, INCR, ITRIA, ITRIA1
      DATA INCR /1000/
      LOGICAL PARA
      LOGICAL DBG, DBG0
#ifdef DBG
      DATA DBG /.false./, DBG0 /.false./
#else
      DATA DBG /.true./, DBG0 /.true./
#endif

      CALL GRSPTS(25)
      CALL GRNWPN(6)
13    CONTINUE

c loop over triangles (a) from tria
c neighr(i,k).ne.0 -> side k of triangle i is on the tria grid edge

      DO ITRIA1=1,NTRIA1 !{
c        dbg0=itria1.eq.1   !###
        if(dbg0) then !{
          print *,'itria1,ntria1,ntria=',itria1,ntria1,ntria
          print *,'neighr=',(neighr(itria1,k),k=1,3)
          print *,'neighb=',(neighb(itria1,k),k=1,3)
        end if !}
        IF (ABS(NEIGHR(ITRIA1,1))+ABS(NEIGHR(ITRIA1,2))+
     .      ABS(NEIGHR(ITRIA1,3)) .NE. 0) THEN !{
C         ELEMENT ITRIA1 HAT MINDESTENS EINE SEITE AUF BEGRENZUNGS-
C         KONTUR

c loop over triangles (b) inside the b2 grid

          DO ITRIA=NTRIA1+1,NTRIA !{
c            dbg=dbg0.and.itria.eq.1363  !###
            if(dbg) then !{
              print *,'itria=',itria
              print *,'neighr=',(neighr(itria,k),k=1,3)
              print *,'neighb=',(neighb(itria,k),k=1,3)
            end if !}
            IF (ABS(NEIGHR(ITRIA,1))+ABS(NEIGHR(ITRIA,2))+
     .          ABS(NEIGHR(ITRIA,3)).NE.0) THEN !{
C             ELEMENT ITRIA HAT MINDESTENS EINE SEITE AUF BEGRENZUNGS-
C             KONTUR
c loop over the sides of triangle (a)
              DO I=1,3 !{
                J=I+1
                IF (J .EQ. 4) J = 1
c loop over the sides of triangle (b)
                DO K=1,3 !{
                  L=K+1
                  IF (L .EQ. 4) L = 1
                  M=L+1
                  IF (M .EQ. 4) M = 1
                  if(dbg) then !{
                    print '(a,t12,3i8/t12,3i8)','triangles',
     ,                (tria(itria1,kk),kk=1,3),
     ,                (tria(itria ,kk),kk=1,3)
                  end if !}
                  IF ((TRIA(ITRIA1,I) .EQ. TRIA(ITRIA,L)) .AND.
     .                (TRIA(ITRIA1,J) .EQ. TRIA(ITRIA,K))) THEN !{
c two corners of triangle (b) coincide with two corners of triangle (a)
                    NEIGHB(ITRIA1,I) = ITRIA
                    NEIGHS(ITRIA1,I) = K
                    NEIGHR(ITRIA1,I) = 0
                    NEIGHB(ITRIA,K) = ITRIA1
                    NEIGHS(ITRIA,K) = I
                    NEIGHR(ITRIA,K) = 0
                    if(dbg) then !{
                      
                    end if !}
                    CALL GRJMP(REAL(XCOORD(TRIA(ITRIA1,I))),
     .                         REAL(YCOORD(TRIA(ITRIA1,I))))
                    CALL GRDRW(REAL(XCOORD(TRIA(ITRIA1,J))),
     .                         REAL(YCOORD(TRIA(ITRIA1,J))))
                  ENDIF !}
                  if(dbg) then !{
                    print *,'neighr1',neighr(itria1,i),neighr(itria,k)
                  end if !}
                  IF ((NEIGHR(ITRIA1,I) .NE. 0) .AND.
     .                (NEIGHR(ITRIA,K) .NE. 0)) then !{
c edges (i) and (k) of triangles (a) and (b) are of different length 
c but still have unindentified neighbors
                  if(dbg) then !{
                    print *,'tria j k i l:',TRIA(ITRIA1,J),
     ,                        TRIA(ITRIA,K),TRIA(ITRIA1,I),TRIA(ITRIA,L)
                    print *,'para: ',PARA(XCOORD(TRIA(ITRIA1,J)),
     .                                    YCOORD(TRIA(ITRIA1,J)),
     .                                    XCOORD(TRIA(ITRIA1,I)),
     .                                    YCOORD(TRIA(ITRIA1,I)),
     .                                    XCOORD(TRIA(ITRIA,K)),
     .                                    YCOORD(TRIA(ITRIA,K)),
     .                                    XCOORD(TRIA(ITRIA,L)),
     .                                    YCOORD(TRIA(ITRIA,L)))
                    print '(2a17)','xcoord','ycoord'
                    print '(a,1p,t4,2e17.8)',
     ,                           'j',xcoord(tria(itria1,j))*10.,
     ,                                ycoord(tria(itria1,j))*10.,
     ,                           'i',xcoord(tria(itria1,i))*10.,
     ,                                ycoord(tria(itria1,i))*10.,
     ,                           'k',xcoord(tria(itria,k))*10.,
     ,                                ycoord(tria(itria,k))*10.,
     ,                           'l',xcoord(tria(itria,l))*10.,
     ,                                ycoord(tria(itria,l))*10.
                  end if !}
                  if(PARA(XCOORD(TRIA(ITRIA1,J)),
     .                      YCOORD(TRIA(ITRIA1,J)),
     .                      XCOORD(TRIA(ITRIA1,I)),
     .                      YCOORD(TRIA(ITRIA1,I)),
     .                      XCOORD(TRIA(ITRIA,K)),
     .                      YCOORD(TRIA(ITRIA,K)),
     .                      XCOORD(TRIA(ITRIA,L)),
     .                      YCOORD(TRIA(ITRIA,L))) .AND.
     .                (TRIA(ITRIA1,J) .EQ. TRIA(ITRIA,K)) .AND.
     .                (TRIA(ITRIA1,I) .NE. TRIA(ITRIA,L))) THEN !{
                    NTRIA = NTRIA + 1
                    if(dbg) print *,'ntria,size',ntria,size(tria,1)
                    if(size(tria,1).lt.ntria) then !{
                      call realloc_ctria('neigh',incr)
                      call realloc_ctria('tria',incr)
                      call realloc_ctria('trixy',incr)
                    end if !}
                    DO IS=1,3 !{
                      TRIA(NTRIA,IS) = TRIA(ITRIA,IS)
                      NEIGHB(NTRIA,IS) = NEIGHB(ITRIA,IS)
                      NEIGHS(NTRIA,IS) = NEIGHS(ITRIA,IS)
                      NEIGHR(NTRIA,IS) = NEIGHR(ITRIA,IS)
                    ENDDO !}
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
                  ENDIF !}
                  end if !}
                  if(dbg) then !{
                    print *,'neighr2',neighr(itria1,i),neighr(itria,k)
                  end if !}
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
     .                (TRIA(ITRIA1,J) .NE. TRIA(ITRIA,K))) THEN !{
                    NTRIA = NTRIA + 1
                    if(dbg) print *,'ntria,size',ntria,size(tria,1)
                    if(size(tria,1).lt.ntria) then !{
                      call realloc_ctria('neigh',incr)
                      call realloc_ctria('tria',incr)
                      call realloc_ctria('trixy',incr)
                    end if !}
                    DO IS=1,3 !{
                      TRIA(NTRIA,IS) = TRIA(ITRIA,IS)
                      NEIGHB(NTRIA,IS) = NEIGHB(ITRIA,IS)
                      NEIGHS(NTRIA,IS) = NEIGHS(ITRIA,IS)
                      NEIGHR(NTRIA,IS) = NEIGHR(ITRIA,IS)
                    ENDDO !}
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
                  ENDIF !}
                ENDDO !}
              ENDDO !}
            ENDIF !}
          ENDDO !}
        ENDIF !}
        dbg=.false.
      ENDDO !}
      END

*//PARA//
C=======================================================================
C          F U N C T I O N  P A R A
C=======================================================================
C     CHECK COLINEARITY OF TWO MARGINS

      FUNCTION PARA(XP2,YP2,XP1,YP1,XQ1,YQ1,XQ2,YQ2)
      IMPLICIT NONE
      double precision tol,tol2,tolx,toly
      parameter (tol=1.d-6)
      DOUBLE PRECISION XP2,YP2,XP1,YP1,XQ1,YQ1,XQ2,YQ2
      LOGICAL PARA

cxpb  We need to have not only (P1,P2) parallel to (Q1,Q2) but
cxpb  also (P1,P2) shorter than (Q1,Q2)
 
      tolx=tol*abs(xp1+xq1+xp2+xq2)/4.
      toly=tol*abs(yp1+yq1+yp2+yq2)/4.
      tol2=sqrt(tolx*toly)

cank  The segments must be not only parallel, but colinear {
      IF (ABS(XQ2-XQ1) .GT. TOLX) THEN
        IF (ABS(YQ1-YQ2) .GT. TOLY) THEN
          IF (ABS((XP1-XP2)*(YQ1-YQ2)-(YP1-YP2)*(XQ1-XQ2)).LT.TOL2) THEN
            PARA = ABS(XP2-XP1).LE.ABS(XQ2-XQ1)+TOLX
          ELSE
            PARA = .FALSE.
          ENDIF
        ELSE
          PARA = ABS(YP1-YP2) .LE. TOLY
        ENDIF
      ELSE
        IF (ABS(XP1-XP2) .GT. TOLX) THEN
          PARA = .FALSE.
        ELSE
          PARA = ABS(YP2-YP1).LE.ABS(YQ2-YQ1)+TOLY
        ENDIF
      ENDIF
cank }
c DPC: additional constraint - (p1,p2) should be contained by (q1,q2)
cank: need to introduce tolerance here, 
c     otherwise some corners are not detected

      if(para) para=min(xp1,xp2)+tolx.ge.min(xq1,xq2)
      if(para) para=min(yp1,yp2)+toly.ge.min(yq1,yq2)
      if(para) para=max(xp1,xp2)-tolx.le.max(xq1,xq2)
      if(para) para=max(yp1,yp2)-toly.le.max(yq1,yq2)

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
      INTEGER ICOORD, ITRIA

      WRITE(9,*) NCOORD
      WRITE(9,'(1P,4E19.8)') (XCOORD(ICOORD),ICOORD=1,NCOORD)
      WRITE(9,'(1P,4E19.8)') (YCOORD(ICOORD),ICOORD=1,NCOORD)

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
