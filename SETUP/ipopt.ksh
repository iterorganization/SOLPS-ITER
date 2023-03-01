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

  unset TAO
  export OPT="ipopt"
  export IPOPT="yes"
  echo "IPOPT compilation and optimization turned on"
else
  echo "SOLPS_PATH not set. Exiting."
fi

