if [[ -n "$SOLPS_PATH" ]]; then
  export   OLD_SOLPS_PATH=$SOLPS_PATH
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed 's|\.ig||g'`
  export   PATH=`echo $PATH | sed "s|${OLD_SOLPS_PATH}|${SOLPS_PATH}|"`
  unset    OLD_SOLPS_PATH USE_IMPGYRO SOLPS_MPI USE_MPI
  rehash
  echo "SOLPS-ITER_IMPGYRO (and MPI) mode turned off"
else
  echo "SOLPS_PATH not set. Exiting."
fi

