if ($?SOLPS_PATH) then
  # Check whether HOST_NAME and COMPILER are defined
  if (! $?HOST_NAME) then
    echo "HOST_NAME not defined. Exiting.
    exit 1
  endif
  if (! $?COMPILER) then
    echo "COMPILER not defined. Exiting.
    exit 1
  endif

  export   OLD_SOLPS_PATH=$SOLPS_PATH
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed 's|.debug||g'`
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|${HOST_NAME}.${COMPILER}.mpi|${HOST_NAME}.${COMPILER}.mpi.debug|g"`
  export   SOLPS_PATH=`echo $SOLPS_PATH | sed "s|${HOST_NAME}.${COMPILER}:|${HOST_NAME}.${COMPILER}.debug:|g"`.debug
  export   PATH=`echo $PATH | sed "s|${OLD_SOLPS_PATH}|${SOLPS_PATH}|"`
  export   SOLPS_DEBUG=yes
  unset    OLD_SOLPS_PATH
else
  echo "SOLPS_PATH not set. Exiting."
endif