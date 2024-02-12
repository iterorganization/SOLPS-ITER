function write_b2fgmtry_us(file,label,gmtry)
% write_b2fgmtry(file,label,gmtry)
%
% Write b2fgmtry file for use by B2.5.
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file,'wt');
if (fid == -1)
   error(msg);
end


%% Write a version header

VERSION = 'VERSION03.002.000 Matlab';
fprintf(fid,'%s\n',VERSION);


%% Write dimensions nx, ny, ns

write_ifield(fid,'nCi,nCg,nCv,nFc,nVx,nFs,nFt',[gmtry.nCi,gmtry.nCg,gmtry.nCv,gmtry.nFc,gmtry.nVx,gmtry.nFs,gmtry.nFt]);

write_ifield(fid,'nCmxVx,nCmxFc,nVmxCv,nVmxFc,nCmxNv',[gmtry.nCmxVx,gmtry.nCmxFc,gmtry.nVmxCv,gmtry.nVmxFc,gmtry.nCmxNv]);

%% Write label




%% Write symmetry information
write_ifield(fid,'isClassicalGrid',gmtry.isClassicalGrid);
write_ifield(fid,'nx,ny,nncut',[gmtry.nx,gmtry.ny,gmtry.nncut]);

write_sfield(fid,'label',label);

write_ifield(fid,'isymm',1);


%% Write mapping variables

write_ifield(fid,'cvFcP' ,gmtry.cvFcP);

write_ifield(fid, 'cvFc',gmtry.cvFc);
write_ifield(fid, 'fcCv',gmtry.fcCv);
write_ifield(fid, 'fcVx',gmtry.fcVx);
write_ifield(fid, 'cvVxP',gmtry.cvVxP);
write_ifield(fid, 'cvVx',gmtry.cvVx);
write_ifield(fid, 'vxFcP',gmtry.vxFcP);
write_ifield(fid, 'vxFc',gmtry.vxFc);
write_ifield(fid, 'vxCvP',gmtry.vxCvP);
write_ifield(fid, 'vxCv',gmtry.vxCv);
write_ifield(fid, 'ftCvP',gmtry.ftCvP);
write_ifield(fid, 'ftCv',gmtry.ftCv);
write_ifield(fid, 'ftFcP',gmtry.ftFcP);
write_ifield(fid, 'ftFc',gmtry.ftFc);
write_ifield(fid, 'cvFt',gmtry.cvFt);
write_ifield(fid, 'fsFcP',gmtry.fsFcP);
write_ifield(fid, 'fsFc',gmtry.fsFc);
write_ifield(fid, 'fcReg',gmtry.fcReg);
write_ifield(fid, 'cvReg',gmtry.cvReg);
write_ifield(fid, 'ftReg',gmtry.ftReg);
write_rfield(fid, 'intcellP',gmtry.intcellP);
write_rfield(fid, 'intcellR',gmtry.intcellR);

if gmtry.isClassicalGrid == 0
  gmtry.imapCv = [];
  gmtry.imapFcx = [];
  gmtry.imapFcy = [];
  gmtry.imapVx = [];
  gmtry.icornVx = [];
end
write_ifield(fid, 'imapCv', gmtry.imapCv);
write_ifield(fid, 'imapFcx', gmtry.imapFcx);
write_ifield(fid, 'imapFcy', gmtry.imapFcy);
write_ifield(fid, 'imapVx', gmtry.imapVx);
write_ifield(fid, 'icornVx', gmtry.icornVx);

write_ifield(fid, 'fcLbl',   gmtry.fcLbl );
write_ifield(fid, 'cvLbl',   gmtry.cvLbl );
write_ifield(fid, 'ftLbl',   gmtry.ftLbl );

%% Write geometry variables

% cell volumes 
write_rfield(fid, 'cvBb', gmtry.cvBb);
write_rfield(fid, 'cvEb', gmtry.cvEb);
write_rfield(fid, 'cvX', gmtry.cvX);
write_rfield(fid, 'cvY', gmtry.cvY     );
write_rfield(fid, 'cvSz', gmtry.cvSz   );
write_rfield(fid, 'cvHz', gmtry.cvHz    );
write_rfield(fid, 'cvHx', gmtry.cvHx  );
write_rfield(fid, 'cvQgam', gmtry.cvQgam );
write_rfield(fid, 'cvVol', gmtry.cvVol  );


% face quantities
write_rfield(fid,'fcBb', gmtry.fcBb   );
write_rfield(fid,'fcS', gmtry.fcS   );
write_rfield(fid,'fcHc', gmtry.fcHc );
write_rfield(fid,'fcHt', gmtry.fcHt  );
write_rfield(fid,'fcQgam', gmtry.fcQgam );
write_rfield(fid,'fcQalf', gmtry.fcQalf );
write_rfield(fid,'fcQbet', gmtry.fcQbet);
write_rfield(fid,'fcPbs', gmtry.fcPbs );

% vertex quantities
write_rfield(fid,'vxBb', gmtry.vxBb );
write_rfield(fid,'vxX', gmtry.vxX  );
write_rfield(fid,'vxY', gmtry.vxY  );
write_rfield(fid,'vxFfbz', gmtry.vxFfbz  );
write_rfield(fid,'vxFpsi', gmtry.vxFpsi  );

% flux surface quantities
write_rfield(fid,'cvConn', gmtry.cvConn );
write_rfield(fid,'fsPsi', gmtry.fsPsi );


%% Close file

fclose(fid);

end