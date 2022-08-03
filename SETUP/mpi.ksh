if [[ -n "$SOLPS_PATH" ]]; then
  # Check whether HOST_NAME and COMPILER are defined
  if [[ -z "$HOST_NAME" ]]; then
    echo "HOST_NAME not defined. Exiting."
    exit 1
  fi
  if [[ -z "$COMPILER" ]]; then
    echo "COMPILER not defined. Exiting."
    exit 1
  fi
  
  # Pragmatic approach: assume only Uinp, Eirene, B2.5 and B25Eirene will require mpi-versions
  export   OLD_SOLPS_PATH=$SOLPS_PATH
  export   PATH=`echo $PATH | sed "s|${SOLPS_PATH}:||"`
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed 's|\.mpi||g'` # remove .mpi if already present
  if [[ -n "$SOLPS_OPENMP" ]]; then
    export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|B2.5/builds/standalone.${HOST_NAME}.${COMPILER}.openmp|B2.5/builds/standalone.${HOST_NAME}.${COMPILER}.openmp.mpi|g"`
    export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|B2.5/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}.openmp|B2.5/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}.openmp.mpi|g"`
    export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|Uinp/builds/${HOST_NAME}.${COMPILER}.openmp|Uinp/builds/${HOST_NAME}.${COMPILER}.openmp.mpi|g"`
    export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|scripts/${HOST_NAME}.${COMPILER}.openmp|scripts/${HOST_NAME}.${COMPILER}.openmp.mpi|g"`
  fi
  if [[ -n "$SOLPS_DEBUG" ]]; then
    export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|standalone.${HOST_NAME}.${COMPILER}.debug|standalone.${HOST_NAME}.${COMPILER}.mpi.debug|g"`
    export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|Uinp/builds/${HOST_NAME}.${COMPILER}.debug|Uinp/builds/${HOST_NAME}.${COMPILER}.mpi.debug|g"`
    export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}.debug|couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}.mpi.debug|g"`
    export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|scripts/${HOST_NAME}.${COMPILER}.debug|scripts/${HOST_NAME}.${COMPILER}.mpi.debug|g"`
  else
    export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|standalone.${HOST_NAME}.${COMPILER}:|standalone.${HOST_NAME}.${COMPILER}.mpi:|g"`
    export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|Uinp/builds/${HOST_NAME}.${COMPILER}:|Uinp/builds/${HOST_NAME}.${COMPILER}.mpi:|g"`
    export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}:|couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}.mpi:|g"`
    export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|scripts/${HOST_NAME}.${COMPILER}|scripts/${HOST_NAME}.${COMPILER}.mpi|g"`
  fi
  export   PATH=${SOLPS_PATH}:${OLD_PATH}
  export   USE_MPI="-DUSE_MPI"
  export   SOLPS_MPI="yes"
  unset    OLD_SOLPS_PATH
  echo "SOLPS-ITER MPI mode turned on"
else
  echo "SOLPS_PATH not set. Exiting."
fi

