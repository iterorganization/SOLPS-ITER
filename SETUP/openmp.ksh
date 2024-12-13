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
  
  # Pragmatic approach: assume only B2.5 and B2.5-Eirene will require OpenMP versions
  export   OLD_SOLPS_PATH=$SOLPS_PATH
  export   PATH=`echo $PATH | sed "s|${SOLPS_PATH}:||"`
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed 's|\.openmp||g'` # remove .openmp if already present
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|B2.5/builds/standalone.${HOST_NAME}.${COMPILER}|B2.5/builds/standalone.${HOST_NAME}.${COMPILER}.openmp|g"`
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|B2.5/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}|B2.5/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}.openmp|g"`
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|Uinp/builds/${HOST_NAME}.${COMPILER}|Uinp/builds/${HOST_NAME}.${COMPILER}.openmp|g"`
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|scripts/${HOST_NAME}.${COMPILER}|scripts/${HOST_NAME}.${COMPILER}.openmp|g"`
  export   PATH=${SOLPS_PATH}:${OLD_PATH}
  export   USE_OPENMP="-D_OPENMP"
  export   SOLPS_OPENMP="yes"
  if [ "$COMPILER" != "ifort64" ]; then
    export OMP_STACKSIZE="128M"
    export OLD_COMPILER=${FC}
    export OLD_MPI_COMPILER=${MPI_FC}
    if [ "$FC" == "ifx" ]; then
      export FC="ifort"
      echo "Reverting to ifort compiler as ifx is unsafe with OpenMP"
    fi
    if [ "$MPI_FC" == "mpiifort -fc=mpiifx" ]; then
      export MPI_FC="mpiifort"
    fi
  fi
  export   KMP_STACKSIZE="128M"
  export   KMP_AFFINITY="norespect,compact"
  unset    OLD_SOLPS_PATH
  echo "SOLPS-ITER OpenMP mode turned on"
else
  echo "SOLPS_PATH not set. Exiting."
fi

