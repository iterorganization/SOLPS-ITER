      SUBROUTINE TEST(NPOIN)
      use celm
      IMPLICIT NONE

      INTEGER NPOIN,I,J,K

      DO I=1,NPOIN
        DO J=1,NELM
          DO K=1,3
            IF (IELM(K,J) .EQ. I) GOTO 10
          ENDDO
        ENDDO
        WRITE(6,*) 'PUNKT ',I,' WIRD NICHT IM GITTER VERWENDET'
10      CONTINUE
      ENDDO
      DO I=1,NELM
        DO J=1,3
          IF (IPROP(J,I) .EQ. 0) THEN
            IF (IADJA(ISIDE(J,I),IADJA(J,I)) .NE. I) THEN
              WRITE(6,*) 'FEHLER'
            ENDIF
            IF (ISIDE(ISIDE(J,I),IADJA(J,I)) .NE. J) THEN
              WRITE(6,*) 'FEHLER'
            ENDIF
          ENDIF
        ENDDO
      ENDDO
      END
