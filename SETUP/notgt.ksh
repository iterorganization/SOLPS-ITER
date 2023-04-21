if [[ -n "$SOLPS_PATH" ]]; then
  export OLD_SOLPS_PATH=$SOLPS_PATH
  export PATH=`echo $PATH | sed "s|${SOLPS_PATH}:||"`
  export SOLPS_PATH=`echo $SOLPS_PATH | sed 's|\.tgt||g'`
  export PATH=${SOLPS_PATH}:${OLD_PATH}
  unset  OLD_SOLPS_PATH SOLPS_TGT
  rehash
  echo "SOLPS-ITER TGT mode turned off"
else
  echo "SOLPS_PATH not set. Exiting."
fi
