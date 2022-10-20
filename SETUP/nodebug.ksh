if [[ "$SOLPS_PATH" ]]; then
  export   OLD_SOLPS_PATH=$SOLPS_PATH
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed 's|\.debug:|:|g'`
  export   PATH=`echo $PATH | sed "s|${OLD_SOLPS_PATH}|${SOLPS_PATH}|"`
  unset    OLD_SOLPS_PATH IMAS_AMNS_DEBUG SOLPS_DEBUG I_MPI_DEBUG PMI_DEBUG
  echo "SOLPS-ITER debug mode turned off"
else
  echo "SOLPS_PATH not set. Exiting."
fi
