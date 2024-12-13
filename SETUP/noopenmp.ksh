if [[ -n "$SOLPS_PATH" ]]; then
  export OLD_SOLPS_PATH=$SOLPS_PATH
  export FC=$OLD_COMPILER
  export MPI_FC=$OLD_MPI_COMPILER
  export PATH=`echo $PATH | sed "s|${SOLPS_PATH}:||"`
  export SOLPS_PATH=`echo $SOLPS_PATH | sed 's|\.openmp||g'`
  export PATH=${SOLPS_PATH}:${OLD_PATH}
  unset  OLD_SOLPS_PATH SOLPS_OPENMP USE_OPENMP
  rehash
  echo "SOLPS-ITER OpenMP mode turned off"
else
  echo "SOLPS_PATH not set. Exiting."
fi

