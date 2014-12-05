C******* -SUBROUTINE CHOICE- *******************************************
C----
C---- THIS SUBROUTINE SELECTS THE THIRD TRIANGLE POINT FROM THE
C---- CANDIDATE LIST IF POSSIBLE.

ctk:  oct.05 bug fix: routine "choice": check candidate list for new points
ctk                   use wider selection of points than previously

      SUBROUTINE CHOICE(FOUND)
      use cpoin
      use cfront
      use ccandi
      IMPLICIT NONE

C---- OUTPUT VARIABLE
C---- FOUND  : INDICATES IF THE THIRD TRIANGLE POINT WAS FOUND
      LOGICAL FOUND

C---- LOCAL VARIABLES
C---- M : LOOP OVER CANDIDATES
C---- K : LOOP OVER FRONTIER PARTS
C---- IF1 : INDEX OF START POINT OF A FRONTIER PARTS
C---- IF2 : INDEX OF END POINT OF A FRONTIER PART
C---- IK : INDEX OF CANDIDATE TO BE TESTED FOR THIRD POINT OF TRIANGLE
C---- I : LOOP OVER CANDIDATES
C---- XM : COORDINATES OF MIDDLE POINT OF VECTOR FROM XA TO XB
C---- XKI : COORDINATES OF CANDIDATE IK
C---- XKM : COORDINATES OF CANDIDATE; CANDIDATE MUST NOT BE INSIDE
C----       OF TRIANGLE XA, XB, XKI
C---- XF1 : COORDINATES OF POINT IF1
C---- XF2 : COORDINATES OF POINT IF2
C---- U : PARAMETER OF THE EQUATION XM+U(XKI-XM) 
C---- W : PARAMETER OF THE EQUATION XF1+W(XF2-XF1)
C---- DET : AUXILARY VARIABLE FOR CALCULATION OF U AND W
C---- EPS : AUXILARY VARIBALE USED TO AVOID PROBLEMS CAUSED BY 
C           RUNDUNGSFEHLER
C---- MEMBER : FUNCTION FOR TESTING IF A POINT IS INSIDE AN TRIANGLE
C---- TRUFA1 : TRUE IF NO GRID POINT IS INSIDE THE TRIANGLE LIMITED
C----          BY XA, XB AND XKI
C---- TRUFA2 : TRUE IF NO FRONTIER PART (EXCEPT THE BASE LINE OF THE
C----          TRIANGLE) CROSSES THE MEDIAN FROM POINT XKI
C----          TO THE BASE SIDE
      INTEGER M,K,IF1,IF2,IK,I
      DOUBLE PRECISION XM(2),XKI(2),XKM(2)
      DOUBLE PRECISION XF1(2),XF2(2),U,W,DET,EPS,W1,W2
      LOGICAL MEMBER,TRUFA1,TRUFA2

C---- INITIALIZATION
      INODCON = 0
      EPS = 1E-5

      DO I=1,NCANDI
        U = 0.0
        W = 0.0
        TRUFA1 = .TRUE.
        TRUFA2 = .TRUE.
        IK = ICANDI(I)
        XKI(1) = X(IK)
        XKI(2) = Y(IK)

C---- 1. NO POINT OF THE EXISTING GRID MAY LIE INSIDE
C----    THE TRIANGLE XA, XB, XKI.

       DO M=1,(Npartfr-1)
        IF ((M .NE. I) .AND. (Ifront(1,M) .NE. IC) .AND. 
     >     (Ifront(1,M) .NE. Ia) .AND. (Ifront(1,M) .NE. Ib)) THEN
          XKM(1) = X(Ifront(1,M))
          XKM(2) = Y(Ifront(1,M))
          TRUFA1 = TRUFA1 .AND. .NOT. MEMBER(XKM,XA,XB,XKI)
        ENDIF
      ENDDO

C---- 2. NO FRONTIER PART (EXCEPT THE BASE LINE OF THE
C----    TRIANGLE) IS ALLOWED TO CROSS THE MEDIAN FROM
C----    POINT XKI. IT IS TESTED WITH THE PARAMETER FORM
C----    OF THE GERADENGLEICHUNGEN
C----    XM+U(XKI-XM) = XF1+W(XF2-XF1)
C----    0<=U<=1 AND 0<=W<=1 ==> CROSSING OF BASE LINE AND FRONTIER PART


      XM(1)  = 0.5 * (XA(1) + XB(1))
      XM(2)  = 0.5 * (XA(2) + XB(2))

      DO K=1,(NPARTFR-1)
        IF1    = IFRONT(1,K)
        IF2    = IFRONT(2,K)
        XF1(1) = X(IF1)
        XF1(2) = Y(IF1)
        XF2(1) = X(IF2)
        XF2(2) = Y(IF2)

        DET = (XKI(1)-XM(1))*(XF2(2)-XF1(2))-
     >        (XKI(2)-XM(2))*(XF2(1)-XF1(1))
        IF (DET .NE. 0) THEN
          U = ((XF1(1)-XM(1))*(XF2(2)-XF1(2))-
     >        (XF1(2)-XM(2))*(XF2(1)-XF1(1)))/DET
          IF ((XF2(1)-XF1(1)) .NE. 0.) THEN
            W = (XM(1)-XF1(1)+U*(XKI(1)-XM(1)))/(XF2(1)-XF1(1))
          ELSEIF ((XF2(2)-XF1(2)) .NE. 0.) THEN
            W = (XM(2)-XF1(2)+U*(XKI(2)-XM(2)))/(XF2(2)-XF1(2))
          ENDIF
        ELSE
          IF (ABS(XF2(1)-XF1(1)) .LT. 1E-6) THEN
            IF (ABS(XM(1)-XF1(1)) .LT. 1.E-6) THEN
              U=0.5
              W=0.5
C---- STRAIGHT LINES IDENTICAL
            ENDIF
          ELSEIF (ABS(XF2(2)-XF1(2)) .LT. 1E-6) THEN
            IF (ABS(XM(2)-XF1(2)) .LT. 1.E-6) THEN
C---- STRAIGHT LINES IDENTICAL
              U=0.5
              W=0.5
            ENDIF
          ELSE
            W1=(XM(1)-XF1(1))/(XF2(1)-XF1(1))
            W2=(XM(2)-XF1(2))/(XF2(2)-XF1(2))
            IF (ABS(W1-W2) .LT. 1.E-6) THEN
C---- STRAIGHT LINES IDENTICAL
              IF ((W1 .GE. 0.) .AND. (W1 .LE. 1.)) THEN
                U=0.5
                W=0.5
              ENDIF
            ENDIF
          ENDIF
        ENDIF

        IF ((W .GT. EPS) .AND. (W .LT. (1.0-EPS)) .AND.
     >      (U .GT. EPS) .AND. (U .LT. (1.0-EPS))) THEN
          TRUFA2 = .FALSE.
        ENDIF

      ENDDO
C---- IF NO GRID POINT IS INSIDE THE TRIANGLE AND NO FRONTIER PART
C---- CROSSES THE MEDIAN FROM THE THIRD POINT THE CANDIDATE IS SELECTED.
      IF (TRUFA1 .AND. TRUFA2) THEN
        INODCON = IK
        NODCON(1) = XKI(1)
        NODCON(2) = XKI(2)
        FOUND = .TRUE.
        GOTO 20
      ENDIF
      ENDDO ! DO I=1,NCANDI
20    CONTINUE

      END ! OF SUBROUTINE CHOICE
