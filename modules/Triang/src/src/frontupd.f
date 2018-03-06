C******* -SUBROUTINE FRONTUPD- *****************************************
C----
C---- THIS SUBROUTINE UPDATES THE FRONTIER

      SUBROUTINE FRONTUPD
      use cpoin
      use cfront
      use creg
      use celm
      use cdelta
      IMPLICIT NONE

C---- LOCAL VARIABLES
C---- J : LOOP OVER FRONTIER PARTS
C---- LNODA : TRUE IF THERE IS ALREADY A FRONTIER PART THAT BEGINS AT
C----         POINT INODCON AND ENDS AT POINT IA
C---- LNODB : TRUE IF THERE IS ALREADY A FRONTIER PART THAT BEGINS AT
C----         POINT IB AND ENDS AT POINT INODCON
C---- INODA : IF LNODA IS TRUE: INDEX OF FRONTIER PART THAT BEGINS AT
C----         POINT INODCON AND ENDS AT POINT IA
C---- INODB : IF LNODB IS TRUE: INDEX OF FRONTIER PART THAT BEGINS AT
C----         POINT IB AND ENDS AT POINT INODCON
C---- K : LOOP INDEX
C---- BOUND, IND1, IND2, IHELP, HELP : AUXILARY VARIABLES FOR SORTING
      INTEGER J,INODA,INODB,K,BOUND,IND1,IND2,IHELP
      DOUBLE PRECISION HELP,DIST
      LOGICAL LNODA,LNODB

C---- THE LAST FRONTIER PART IN THE LIST MUST BE DELETED BECAUSE IT
C---- BECAME THE BASE LINE OF THE NEW TRIANGLE
      NPARTFR = NPARTFR-1
      IFRONT(1,NPARTFR+1) = 0
      IFRONT(2,NPARTFR+1) = 0
      DELFRO(NPARTFR+1) = 0

      IF (INODCON .EQ. IC) THEN
C---- THE POINT C IS SELECTED AS NEW GRID POINT 
C---- TWO FRONTIER PARTS MUST BE ADDED (FRONTIER PART FROM IA TO IC AND 
C---- FRONTIER PART FROM IC TO IB)
        IF (NPARTFR+2 .GT. size(ifront,2)) THEN
           call realloc_cfront('ifront',10)
        ENDIF
        IF (NPARTFR+2 .GT. size(delfro)) THEN
           call realloc_cfront('delfro',10)
        ENDIF
        IFRONT(1,NPARTFR+1) = IA
        IFRONT(2,NPARTFR+1) = IC
        DELFRO(NPARTFR+1) = DIST(X(IA),Y(IA),X(IC),Y(IC))
        IFRONT(1,NPARTFR+2) = IC
        IFRONT(2,NPARTFR+2) = IB
        DELFRO(NPARTFR+2) = DIST(X(IC),Y(IC),X(IB),Y(IB))
        NPARTFR = NPARTFR +2
      ELSE
C---- THE TRIANGLE SIDES A-NODCON AND NODCON-B MUST BE COMPARED WITH
C---- THE FRONTIER PARTS. IF THERE IS A FRONTIER PART WITH THE REVERSE 
C---- NODES (NODCON-A OR B-NODCON) THESE FRONTIER PART MUST BE DELETED.
        LNODA = .FALSE.
        LNODB = .FALSE.
        DO J=1,NPARTFR
          IF ((IFRONT(1,J).EQ.INODCON) .AND. (IFRONT(2,J).EQ.IA)) THEN
              LNODA = .TRUE.
              INODA = J
          ENDIF
          IF ((IFRONT(1,J).EQ.IB) .AND. (IFRONT(2,J).EQ.INODCON)) THEN
              LNODB = .TRUE.
              INODB = J
          ENDIF
        ENDDO
        IF (LNODA) THEN
          DO K=INODA+1,NPARTFR
            IFRONT(1,K-1) = IFRONT(1,K)
            IFRONT(2,K-1) = IFRONT(2,K)
            DELFRO(K-1) = DELFRO(K)
          ENDDO
          NPARTFR = NPARTFR-1
          IFRONT(1,NPARTFR+1) = 0
          IFRONT(2,NPARTFR+1) = 0
          DELFRO(NPARTFR+1) = 0
          IF (LNODB .AND. INODA .LT. INODB) INODB = INODB - 1
        ENDIF
        IF (LNODB) THEN
          DO K=INODB+1,NPARTFR
            IFRONT(1,K-1) = IFRONT(1,K)
            IFRONT(2,K-1) = IFRONT(2,K)
            DELFRO(K-1) = DELFRO(K)
          ENDDO
          NPARTFR = NPARTFR-1
          IFRONT(1,NPARTFR+1) = 0
          IFRONT(2,NPARTFR+1) = 0
          DELFRO(NPARTFR+1) = 0
        ENDIF
C---- IF THERE IS NO FRONTIER PARTS WITH REVERSED NODES IS FOUND THE
C---- FRONTIER PART A-NODCON OR NODCON-B MUST BE ADDED.
        IF (.NOT. LNODA)THEN
          NPARTFR = NPARTFR+1
          IF (NPARTFR .GT. size(delfro)) THEN
             call realloc_cfront('delfro',10)
          ENDIF
          IF (NPARTFR .GT. size(ifront,2)) THEN
             call realloc_cfront('ifront',10)
          ENDIF
          IFRONT(1,NPARTFR) = IA
          IFRONT(2,NPARTFR) = INODCON
          DELFRO(NPARTFR) = DIST(X(IA),Y(IA),X(INODCON),Y(INODCON))
        ENDIF
        IF (.NOT. LNODB) THEN
          NPARTFR = NPARTFR+1
          IF (NPARTFR .GT. size(delfro)) THEN
             call realloc_cfront('delfro',10)
          ENDIF
          IF (NPARTFR .GT. size(ifront,2)) THEN
             call realloc_cfront('ifront',10)
          ENDIF
          IFRONT(1,NPARTFR) = INODCON
          IFRONT(2,NPARTFR) = IB
          DELFRO(NPARTFR) = DIST(X(IB),Y(IB),X(INODCON),Y(INODCON))
        ENDIF
      ENDIF

C---- SORTING OF FRONTIER LIST FROM LONGEST TO SHORTEST
C---- BUBBLE_SORT: 
      BOUND = NPARTFR
      DO WHILE (BOUND .GT. 1)
        IND1 = 1
        IND2 = 1

        DO WHILE (BOUND .GT. IND2)
          IF (DELFRO(IND2) .LT. DELFRO(IND2+1)) THEN
            HELP           = DELFRO(IND2)
            DELFRO(IND2)   = DELFRO(IND2+1)
            DELFRO(IND2+1) = HELP
            IHELP          = IFRONT(1,IND2)
            IFRONT(1,IND2) = IFRONT(1,IND2+1)
            IFRONT(1,IND2+1) = IHELP
            IHELP          = IFRONT(2,IND2)
            IFRONT(2,IND2) = IFRONT(2,IND2+1)
            IFRONT(2,IND2+1) = IHELP
          ENDIF
          IND1=IND2
          IND2=IND2+1
        ENDDO
        BOUND=IND1
      ENDDO

      END
