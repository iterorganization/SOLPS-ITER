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
  
  # Pragmatic approach: assume only Eirene, B2.5 and B25Eirene will require mpi-versions
  export   OLD_SOLPS_PATH=$SOLPS_PATH
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed 's|\.ig||g'` # remove .mpi if already present
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|standalone.${HOST_NAME}.${COMPILER}|standalone.${HOST_NAME}.${COMPILER}.ig|g"`
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}|couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}.ig|g"`
  export   PATH=`echo $PATH | sed "s|${OLD_SOLPS_PATH}|${SOLPS_PATH}|"`
  export   USE_IMPGYRO="-DUSE_IMPGYRO"
  export   USE_MPI="-DUSE_MPI"
  export   SOLPS_MPI=yes
  unset    OLD_SOLPS_PATH
  echo "SOLPS-ITER_IMPGYRO mode turned on (implies MPI)"
else
  echo "SOLPS_PATH not set. Exiting."
fi

