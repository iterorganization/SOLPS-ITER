if [[ -n "$SOLPS_PATH" ]]; then
  export OLD_SOLPS_PATH=$SOLPS_PATH
  export PATH=`echo $PATH | sed "s|${SOLPS_PATH}:||"`
  export SOLPS_PATH=`echo $SOLPS_PATH | sed 's|\.openmp||g'`
  export PATH=${SOLPS_PATH}:${OLD_PATH}
  unset  OLD_SOLPS_PATH SOLPS_OPENMP USE_OPENMP
  export OMP_DISPLAY_AFFINITY="false"
  export OMP_DISPLAY_ENV="false"
  unset  OMP_PROC_BIND
  unset  OMP_PLACES
  rehash
  echo "SOLPS-ITER OpenMP mode turned off"
else
  echo "SOLPS_PATH not set. Exiting."
fi

