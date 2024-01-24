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

  export   OLD_SOLPS_PATH=$SOLPS_PATH
  export   PATH=`echo $PATH | sed "s|${SOLPS_PATH}:||"`
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed 's|\.debug:|:|g'`
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|${HOST_NAME}.${COMPILER}.openmp.mpi:|${HOST_NAME}.${COMPILER}.openmp.mpi.debug:|g"`
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|${HOST_NAME}.${COMPILER}.openmp:|${HOST_NAME}.${COMPILER}.openmp.debug:|g"`
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|${HOST_NAME}.${COMPILER}.mpi:|${HOST_NAME}.${COMPILER}.mpi.debug:|g"`
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|${HOST_NAME}.${COMPILER}:|${HOST_NAME}.${COMPILER}.debug:|g"`
  export   PATH=${SOLPS_PATH}:${OLD_PATH}
  export   IMAS_AMNS_DEBUG=yes
  export   SOLPS_DEBUG=yes
  export   I_MPI_DEBUG=5
  export   PMI_DEBUG=1
  if [[ -n "$SOLPS_OPENMP" ]]; then
    export OMP_DISPLAY_AFFINITY="true"
    export OMP_DISPLAY_ENV="true"
  fi
  unset    OLD_SOLPS_PATH
  echo "SOLPS-ITER debug mode turned on"
else
  echo "SOLPS_PATH not set. Exiting."
fi
