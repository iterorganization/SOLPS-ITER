C******* -SUBROUTINE CANLIST- ******************************************
C----
C---- THIS SUBROUTINE SEARCHS GRID POINTS NEAR POINT C AND ADDS THESE
C---- POINTS TO THE CANDIDATELIST

      SUBROUTINE CANLIST(FRAD,EPSANG)
      use cpoin
      use cfront
      use ccandi
      use cdelta
      IMPLICIT NONE

C---- INPUT VARIABLES
C---- FRAD   : SEARCH RADIUS
C---- EPSANG : MINIMAL INNER ANGLE TO AVOID TRIANGLES DEGENERATED TO A
C----          LINE
      DOUBLE PRECISION FRAD,EPSANG

C---- LOCAL VARIABLES
C---- I : LOOP VARIABLE
C---- U,V,BOUND,IHELP,HELP : AUXILARY VARIABLES FOR SORTING
C---- IP : INDEX OF FRONTIER POINT
C---- RADIUS : SEARCH RADIUS FOR ONE TRIANGLE (FRAD SCALED WITH THE
C----          BASE LENGTH OF THE TRIANGLE)
C---- XP : COORDINATES FOR THE POINT TO BE TESTED
C---- VECAB : VECTOR FROM POINT XA TO POINT XB
C---- VECAP : VECTOR FROM POINT XA TO POINT XP
C---- S1,S2 : CORSS PRODUCT OF VECAB AND VECAP
C---- ANGLE : CALCULATED INNER ANGLE OF THE TRIANGLE
C---- DIST : FUNCTION FOR CALCULATING THE DISTANCE BETWEEN TWO POINTS

      INTEGER I,U,V,BOUND,IP,IHELP
      DOUBLE PRECISION RADIUS,XP(2)
      DOUBLE PRECISION VECAB(2),VECAP(2),ANGLE,S1,S2,DIST
      DOUBLE PRECISION HELP

      if (.not. allocated(icandi)) then
         allocate(icandi(1))
         allocate(radkan(1))
      endif
      ICANDI = 0
      NCANDI = 0

      RADIUS = FRAD*DELBAS
      DO I=1,NPARTFR
        IP = IFRONT(1,I)
        IF (IP .NE. IA .AND. IP .NE. IB) THEN
          XP(1) = X(IFRONT(1,I))
          XP(2) = Y(IFRONT(1,I))

C---- CALCULATION OF THE INNER ANGLE OF THE TRIANGLE AX,XB,XP
          VECAB(1) = XB(1)-XA(1)
          VECAB(2) = XB(2)-XA(2)
          VECAP(1) = XP(1)-XA(1)
          VECAP(2) = XP(2)-XA(2)
          S1 = VECAB(1)*VECAP(2)
          S2 = VECAB(2)*VECAP(1)
          ANGLE = (S1-S2)/DIST(XB(1),XB(2),XA(1),XA(2))/
     .               DIST(XP(1),XP(2),XA(1),XA(2))

C---- XP IS ADDED TO THE CANDIDATE LIST IF 
C----   1. THE DISTANCE BETWEEN XP AND POINT C <= SEARCH RADIUS
C----   2. THE INNER ANGLE OF THE TRIANGLE > MINIMAL INNER ANGLE
          IF ((DIST(XC(1),XC(2),XP(1),XP(2)) .LE. RADIUS)
     .     .AND. (ANGLE .GT. EPSANG)) THEN
C---- ONE CANDIDATE IS ADDED
              NCANDI = NCANDI+1
              IF (NCANDI .GT. size(icandi)) THEN
                 call realloc_ccandi('icandi',ncandi-size(icandi)+10)
              ENDIF
              IF (NCANDI .GT. size(radkan)) THEN
                 call realloc_ccandi('radkan',ncandi-size(radkan)+10)
              ENDIF
              ICANDI(NCANDI) = IP
              RADKAN(NCANDI) = DIST(XC(1),XC(2),XP(1),XP(2))
          ENDIF
        ENDIF
      ENDDO ! OF DO I=1,NPARTFR

C---- SORTING THE CANDIDATE LIST FROM NEAREST TO DISTANT
C---- BUBBLE_SORT
      BOUND=NCANDI
      DO WHILE (BOUND .GT. 1)
        U=1
        V=1
        DO WHILE (BOUND .GT. V)
          IF (RADKAN(V) .GT. RADKAN(V+1)) THEN

            HELP = RADKAN(V)
            RADKAN(V) = RADKAN(V+1)
            RADKAN(V+1) = HELP

            IHELP = ICANDI(V)
            ICANDI(V) = ICANDI(V+1)
            ICANDI(V+1) = IHELP
          ENDIF
          U=V
          V=V+1
        ENDDO
        BOUND=U
      ENDDO

      END
