if [[ -n "$SOLPS_PATH" ]]; then
  export OLD_SOLPS_PATH=$SOLPS_PATH
  export PATH=`echo $PATH | sed "s|${SOLPS_PATH}:||"`
  export SOLPS_PATH=`echo $SOLPS_PATH | sed 's|\.adj||g'`
  export PATH=${SOLPS_PATH}:${OLD_PATH}
  unset  OLD_SOLPS_PATH SOLPS_ADJ
  rehash
  echo "SOLPS-ITER ADJ mode turned off"
else
  echo "SOLPS_PATH not set. Exiting."
fi
