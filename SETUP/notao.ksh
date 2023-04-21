if [[ -n "$SOLPS_PATH" ]]; then
  unset OPT TAO TAO_OPT
  echo "PETSC-TAO compilation and optimization turned off"
else
  echo "SOLPS_PATH not set. Exiting."
fi

