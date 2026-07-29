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
  grep -e 'bfgs' run.log >> run.info
  grep -i -w 'OPTIM' run.log >> run.info
  grep -i -w 'BFGS' run.log >> run.info
  cp b2mn.exe.dir/*.OUT .
  grep -i 'BFGS iter =' run.log | awk '{print $7}' | awk -F"," '{print $1}' > objval.dat
  grep -i 'BFGS GRADIENT NORM' run.log | awk '{print $4}' > grad.dat

  set npar_opt=`grep -i npar_opt run.info | awk '{print $3}'`

  foreach jj ( `seq 1 $npar_opt` )
   grep -i "grad_F with x$jj=" run.log | awk '{print $5}' > parm_hist$jj.dat
  end

  grep -i 'Total iterations' BFGS.OUT | awk -F':' '{print $2}' | awk '{print $1}' > fgeval.dat
