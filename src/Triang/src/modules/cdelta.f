      module cdelta      
      implicit none
C---- DELTA0 : SIZE OF TRIANGLE, CONSTANT AND GIVEN
C---- DELTA2 : LENGTH OF TRIANGLE SIDES, CALCULATED FROM DELTA1
C----          AND DELBAS
C---- DELBAS : BASE LENGTH OF TRIANGLES
      DOUBLE PRECISION, public, save :: DELTA0,DELTA2,DELBAS
      end module cdelta
