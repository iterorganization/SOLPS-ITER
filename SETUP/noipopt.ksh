if [[ -n "$SOLPS_PATH" ]]; then
  unset OPT IPOPT
  echo "IPOPT compilation and optimization turned off"
else
  echo "SOLPS_PATH not set. Exiting."
fi

