#! /bin/tcsh -f
  if (-s run.log.gz) then
    echo "Found run.log.gz, unzipping..."
    gunzip run.log.gz
  else if (-s run.log) then
    echo "Found run.log"
  else
    echo "No run.log or run.log.gz file present, stopping"
    exit
  endif

  run_info
  cp b2mn.exe.dir/*.OUT .
  grep -i 'TAO,  Function value' run.info | awk '{print $5}' | awk -F"," '{print $1}' > objval.dat
  grep -i 'TAO GRADIENT NORM' run.info | awk '{print $4}' > grad.dat

  set npar_opt=`grep -i npar_opt run.info | awk '{print $3}'`

  [ -e tmp ] && rm tmp
  grep -i -B$npar_opt 'TAO,  Function value' run.info > tmp
  foreach jj ( `seq 1 $npar_opt` )
   grep -i "grad_F with x$jj=" tmp | awk '{print $5}' > parm$jj.dat
  end
  rm tmp

  foreach jj ( `seq 1 $npar_opt` )
   grep -i "grad_F with x$jj=" run.info | awk '{print $5}' > parm_hist$jj.dat
  end

  grep -i 'number of iterations' PETSC-TAO.OUT | awk -F'=' '{print $2}' | awk '{print $1}' > fgeval.dat
