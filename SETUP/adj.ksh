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

  # Pragmatic approach: assume for now only B2.5 has adjoint version
  export OLD_SOLPS_PATH=$SOLPS_PATH
  export PATH=`echo $PATH | sed "s|${SOLPS_PATH}:||"`
  export SOLPS_PATH=`echo $SOLPS_PATH | sed 's|\.adj||g'` # remove .adj if already present
  export SOLPS_PATH=`echo $SOLPS_PATH | sed "s|B2.5/builds/standalone.${HOST_NAME}.${COMPILER}|B2.5/builds/standalone.${HOST_NAME}.${COMPILER}.adj|g"`
  export PATH=${SOLPS_PATH}:${OLD_PATH}
  export SOLPS_ADJ="yes"
  unset OLD_SOLPS_PATH SOLPS_TGT
  rehash
  echo "SOLPS-ITER ADJ mode turned on"
else
  echo "SOLPS_PATH not set. Exiting."
fi
