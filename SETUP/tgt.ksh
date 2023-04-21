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

  # Pragmatic approach: assume for now only B2.5 has tangent version
  export OLD_SOLPS_PATH=$SOLPS_PATH
  export PATH=`echo $PATH | sed "s|${SOLPS_PATH}:||"`
  export SOLPS_PATH=`echo $SOLPS_PATH | sed 's|\.tgt||g'` # remove .tgt if already present
  export SOLPS_PATH=`echo $SOLPS_PATH | sed "s|B2.5/builds/standalone.${HOST_NAME}.${COMPILER}|B2.5/builds/standalone.${HOST_NAME}.${COMPILER}.tgt|g"`
  export PATH=${SOLPS_PATH}:${OLD_PATH}
  export SOLPS_TGT="yes"
  unset  OLD_SOLPS_PATH SOLPS_ADJ
  rehash
  echo "SOLPS-ITER TGT mode turned on"
else
  echo "SOLPS_PATH not set. Exiting."
fi
