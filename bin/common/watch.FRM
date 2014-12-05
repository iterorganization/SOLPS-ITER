#! /bin/csh -f
back:
  touch .write
  while ( { ( timestamp B2SAVE.FRM .write > /dev/null ) } )
#    echo still sleeping
    sleep 10
  end
  rm .write
#  echo writing done
  sleep 3600
  goto back
