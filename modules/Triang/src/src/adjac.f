C******* -SUBROUTINE ADJAC- *******************************************
C----
C---- THIS SUBROUTINE CONSTRUCTS THE GRID FROM THE CALCULATED TRIANGLES

      SUBROUTINE ADJAC
      use cpoin
      use celm
      IMPLICIT NONE

C---- LOCAL VARIABLES
C---- I : OUTER LOOP OVER TRIANGLES
C---- J : INNER LOOP OVER TRIANGLES
C----     THE TRIANGLES I AND J ARE CHECKED ON ADJACENCY
C---- K,L,M,N : LOOP OVER TRIANGLE SIDES
C---- ITR : CORNER POINTS OF TRIANGLE I
C---- JTR : CORNER POINTS OF TRIANGLE J
C---- FOUND : TRUE IF ADJACENT TRIANGLE WAS FOUND
      INTEGER I,J,K,L,M,N,ITR(3),JTR(3)
      LOGICAL FOUND(3)

      allocate(iadja(3,nelm))
      allocate(iside(3,nelm))
      allocate(iprop(3,nelm))
      DO I=1,NELM
        DO K=1,3
          FOUND(K) = .FALSE.
          ITR(K) = IELM(K,I)
        ENDDO
        DO J=1,NELM
          IF (I .NE. J) THEN
            DO K=1,3
              JTR(K) = IELM(K,J)
            ENDDO
            DO K=1,3
              L = K+1
              IF (L.EQ.4) L=1
              DO M=1,3
                N = M+1
                IF (N.EQ.4) N=1
                IF ((ITR(K).EQ.JTR(N)).AND.
     >              (ITR(L).EQ.JTR(M))) THEN
C---- SIDE M OF TRIANGLE J IS EQUAL TO SIDE K OF TRIANGLE I
                  IADJA(K,I) = J
                  ISIDE(K,I) = M
                  IPROP(K,I) = 0
                  FOUND(K) = .TRUE.
                ENDIF
              ENDDO
            ENDDO
          ENDIF
        ENDDO ! OF DO J=1,NELM
        DO K=1,3
          IF (.NOT. FOUND(K)) THEN
C---- NO ADJACENT TRIANGLE WAS FOUND FOR SIDE K OF TRIANGLE I
C---- THE NUMBER OF THE BOUNDARY IS SAVED (IPROP)
            L = K+1
            IF (L.EQ.4) L=1
            IADJA(K,I) = 0
            ISIDE(K,I) = 0
            DO J=1,NFRONT
              IF ((IELM(K,I) .LE. IKONT(J)).AND.
     >            (IELM(L,I) .LE. IKONT(J))) THEN
                IPROP(K,I) = -1*J
                GOTO 15
              ENDIF
            ENDDO
          ENDIF
15        CONTINUE
        ENDDO
      ENDDO

      END
