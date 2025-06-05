function gmtry = read_b2fgmtry_us(file)
% gmtry = read_b2fgmtry(file)
%
% Read b2fgmtry file created by B2.5.
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

disp(['Attempting read_b2fgmtry_us.'])

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end


%% Get version of the b2fstate file

line    = fgetl(fid);
version = line(8:17);

gmtry.version = version;

%% Read dimensions nCi, nCg, nCv, nFc, nVx, nFs, nFt


dim = read_ifield(fid,'nCi,nCg,nCv,nFc,nVx,nFs,nFt',7);
nCi  = dim(1);
nCg  = dim(2);
nCv  = dim(3);
nFc  = dim(4);
nVx  = dim(5);
nFs  = dim(6);
nFt  = dim(7);

dim = read_ifield(fid,'nCmxVx,nCmxFc,nVmxCv,nVmxFc,nCmx',5);
nCmxVx = dim(1);
nCmxFc = dim(2);
nVmxCv = dim(3);
nVmxFc = dim(4);
nCmxNv = dim(5);

gmtry.nCi = nCi;
gmtry.nCg = nCg;
gmtry.nCv = nCv;
gmtry.nFc = nFc;
gmtry.nVx = nVx;
gmtry.nFs = nFs;
gmtry.nFt = nFt;

gmtry.nCmxVx = nCmxVx;
gmtry.nCmxFc = nCmxFc;
gmtry.nVmxCv = nVmxCv;
gmtry.nVmxFc = nVmxFc;
gmtry.nCmxNv = nCmxNv;

%% Check for structured grid

gmtry.isClassicalGrid = read_ifield(fid,'isClassicalGrid',1);
dim = read_ifield(fid,'nx,ny,nncut',3);
nx    = dim(1);
ny    = dim(2);
nncut = dim(3);
gmtry.nx = nx;
gmtry.ny=ny;
gmtry.nncut=nncut;


%% Read symmetry information

gmtry.isymm = read_ifield(fid,'isymm',1);


%% Read Mapping

gmtry.cvFcP = read_ifield(fid, 'cvFcP', [nCv,2] );
gmtry.cvFc  = read_ifield(fid, 'cvFc' , [nCmxFc]);
gmtry.fcCv  = read_ifield(fid, 'fcCv' , [nFc,2] );
gmtry.fcVx  = read_ifield(fid, 'fcVx' , [nFc,2] );
gmtry.cvVxP = read_ifield(fid, 'cvVxP', [nCv,2] );
gmtry.cvVx  = read_ifield(fid, 'cvVx' , [nCmxVx]);
gmtry.vxFcP = read_ifield(fid, 'vxFcP', [nVx,2] );
gmtry.vxFc  = read_ifield(fid, 'vxFc' , [nVmxFc]);
gmtry.vxCvP = read_ifield(fid, 'vxCvP', [nVx,2] );
gmtry.vxCv  = read_ifield(fid, 'vxCv' , [nVmxCv]);
gmtry.ftCvP = read_ifield(fid, 'ftCvP', [nFt,2] );
gmtry.ftCv  = read_ifield(fid, 'ftCv' , [nCv]   );
gmtry.ftFcP = read_ifield(fid, 'ftFcP', [nFt,2] );
gmtry.ftFc  = read_ifield(fid, 'ftFc' , [nFc]   );
gmtry.cvFt  = read_ifield(fid, 'cvFt' , [nCv]   );
gmtry.fsFcP = read_ifield(fid, 'fsFcP', [nFs,2] );
gmtry.fsFc  = read_ifield(fid, 'fsFc' , [nFc]   );
gmtry.fcReg = read_ifield(fid, 'fcReg', [nFc]   );
gmtry.cvReg = read_ifield(fid, 'cvReg', [nCv]   );
gmtry.ftReg = read_ifield(fid, 'ftReg', [nFt]   );
gmtry.intcellP = read_rfield(fid, 'intcellP', [nCmxFc]);
gmtry.intcellR = read_rfield(fid, 'intcellR', [nCmxFc]);
if gmtry.isClassicalGrid == 1
    gmtry.imapCv  = read_ifield(fid, 'imapCv',  [nx+2,ny+2]   );
    gmtry.imapFcx = read_ifield(fid, 'imapFcx', [nx+2,ny+2]   );
    gmtry.imapFcy = read_ifield(fid, 'imapFcy', [nx+2,ny+2]   );
    gmtry.imapVx  = read_ifield(fid, 'imapVx',  [nx+2,ny+2]   );
    gmtry.icornVx = read_ifield(fid, 'icornVx',  nx   );
else
    gmtry.imapCv  = [];
    gmtry.imapFcx = [];
    gmtry.imapFcy = [];
    gmtry.imapVx  = [];
    gmtry.icornVx = [];
end
gmtry.fcLbl = read_ifield(fid, 'fcLbl', [nFc]);
gmtry.cvLbl = read_ifield(fid, 'cvLbl', [nCv]);
gmtry.ftLbl = read_ifield(fid, 'ftLbl', [nFt]);


% cell volumes 
gmtry.cvBb   = read_rfield(fid, 'cvBb',  [nCv,4]  );
gmtry.cvEb   = read_rfield(fid, 'cvEb',  [nCv,3]  );
gmtry.cvX    = read_rfield(fid, 'cvX',   [nCv]    );
gmtry.cvY    = read_rfield(fid, 'cvY',   [nCv]    );
gmtry.cvSz   = read_rfield(fid, 'cvSz',  [nCv]    );
gmtry.cvHz   = read_rfield(fid, 'cvHz',  [nCv]    );
gmtry.cvHx   = read_rfield(fid, 'cvHx',  [nCv]    );
gmtry.cvQgam = read_rfield(fid, 'cvQgam',[nCv,2]  );
gmtry.cvVol  = read_rfield(fid, 'cvVol', [nCv]    );


% face quantities
gmtry.fcBb   = read_rfield(fid,'fcBb',  [nFc,4]  );
gmtry.fcS    = read_rfield(fid,'fcS',   [nFc]   );
gmtry.fcHc   = read_rfield(fid,'fcHc',  [nFc,2] );
gmtry.fcHt   = read_rfield(fid,'fcHt',  [nFc]   );
gmtry.fcQgam = read_rfield(fid,'fcQgam',[nFc,2] );
gmtry.fcQalf = read_rfield(fid,'fcQalf',[nFc,2] );
gmtry.fcQbet = read_rfield(fid,'fcQbet',[nFc,2] );
gmtry.fcPbs  = read_rfield(fid,'fcPbs', [nFc]   );

% vertex quantities
gmtry.vxBb   = read_rfield(fid,'vxBb',  [nVx,4]  );
gmtry.vxX    = read_rfield(fid,'vxX',   [nVx]    );
gmtry.vxY    = read_rfield(fid,'vxY',   [nVx]    );
gmtry.vxFfbz = read_rfield(fid,'vxFfbz',[nVx]    );
gmtry.vxFpsi = read_rfield(fid,'vxFpsi',[nVx]    );

% flux surface quantities
gmtry.cvConn = read_rfield(fid,'cvConn',[nCv] );
gmtry.fsPsi  = read_rfield(fid,'fsPsi',[nFs] );

% Qalfmin
gmtry.Qalfmin = read_rfield(fid,'Qalfmin',1);
gmtry.Qalfmax = read_rfield(fid,'Qalfmax',1);


%% Close file

fclose(fid);

disp(['Done read_b2fgmtry_us with no errors.'])

end

