if [[ -n "$SOLPS_PATH" ]]; then
  unset OPT
  echo "Built-in BFGS compilation and optimization turned off"
else
  echo "SOLPS_PATH not set. Exiting."
fi

