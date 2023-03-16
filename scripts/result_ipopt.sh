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
  grep -i objval run.info | awk '{print $3}' > objval.dat
  set nnvar=`grep -i nnvar run.info | awk '{print $3}'`
  foreach jj ( `seq 1 $nnvar` )
   grep -i "grad_F with x$jj" run.info | awk '{print $5}' > parm_hist$jj.dat
  end
  grep -i -c 'eval_f with x1' run.info > feval.dat
  grep -i 'number of iterations' IPOPT.OUT | awk '{print $4}' > geval.dat
  grep -i 'IPOPT GRADIENT NORM' run.info | awk '{print $4}' > grad.dat
