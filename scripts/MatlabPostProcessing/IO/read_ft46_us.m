function tdata = read_ft46_us(file,nCi)
% tdata = read_ft46(file,nCi,nCv)
%
% Read fort.46 file. Convert to SI units.
%
% For now, only fort.46 version 20160513 recognized 
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end


%% Read dimensions

% ntri, version
nCv = fscanf(fid,'%d',1);
ver     = fscanf(fid,'%d',1);



if ver ~= 20160513 && ver ~= 20160829 && ver ~= 20170930
    error('read_ft46: unknown format of fort.46 file');
end

% go to new line (skip reading a possible git-hash)
fgetl(fid);

% natm, nmol, nion
dims = fscanf(fid,'%d',3);
natm = dims(1);
nmol = dims(2);
nion = dims(3);

% for now, ignore reading species labels
fgetl(fid);
for i = 1:natm
    fgetl(fid);
end
for i = 1:nmol
    fgetl(fid);
end
for i = 1:nion
    fgetl(fid);
end

eV   = 1.6022e-19;

%% Read data

tdata.pdena = zeros(nCv,natm);
tdata.pdenm = zeros(nCv,nmol);
tdata.pdenm = zeros(nCv,nion);

tdata.edena = zeros(nCv,natm);
tdata.edenm = zeros(nCv,nmol);
tdata.edenm = zeros(nCv,nion);

tdata.vxdena = zeros(nCv,natm);
tdata.vxdenm = zeros(nCv,nmol);
tdata.vxdenm = zeros(nCv,nion);

tdata.vydena = zeros(nCv,natm);
tdata.vydenm = zeros(nCv,nmol);
tdata.vydenm = zeros(nCv,nion);

tdata.vzdena = zeros(nCv,natm);
tdata.vzdenm = zeros(nCv,nmol);
tdata.vzdenm = zeros(nCv,nion);

tdata.pdena(1:nCi,1:natm)  = read_ft44_rfield(fid,ver,'pdena',[nCi,natm])*1e6; % m^{-3}
tdata.pdenm(1:nCi,1:nmol)  = read_ft44_rfield(fid,ver,'pdenm',[nCi,nmol])*1e6;
tdata.pdeni(1:nCi,1:nion)  = read_ft44_rfield(fid,ver,'pdeni',[nCi,nion])*1e6;

tdata.edena(1:nCi,1:natm)  = read_ft44_rfield(fid,ver,'edena',[nCi,natm])*1e6*eV; % J m^{-3}
tdata.edenm(1:nCi,1:nmol)  = read_ft44_rfield(fid,ver,'edenm',[nCi,nmol])*1e6*eV;
tdata.edeni(1:nCi,1:nion)  = read_ft44_rfield(fid,ver,'edeni',[nCi,nion])*1e6*eV;

tdata.vxdena(1:nCi,1:natm) = read_ft44_rfield(fid,ver,'vxdena',[nCi,natm])*1e1; % kg s^{-1} m^{-2}
tdata.vxdenm(1:nCi,1:nmol) = read_ft44_rfield(fid,ver,'vxdenm',[nCi,nmol])*1e1;
tdata.vxdeni(1:nCi,1:nion) = read_ft44_rfield(fid,ver,'vxdeni',[nCi,nion])*1e1;

tdata.vydena(1:nCi,1:natm) = read_ft44_rfield(fid,ver,'vydena',[nCi,natm])*1e1; % kg s^{-1} m^{-2}
tdata.vydenm(1:nCi,1:nmol) = read_ft44_rfield(fid,ver,'vydenm',[nCi,nmol])*1e1;
tdata.vydeni(1:nCi,1:nion) = read_ft44_rfield(fid,ver,'vydeni',[nCi,nion])*1e1;

tdata.vzdena(1:nCi,1:natm) = read_ft44_rfield(fid,ver,'vzdena',[nCi,natm])*1e1; % kg s^{-1} m^{-2}
tdata.vzdenm(1:nCi,1:nmol) = read_ft44_rfield(fid,ver,'vzdenm',[nCi,nmol])*1e1;
tdata.vzdeni(1:nCi,1:nion) = read_ft44_rfield(fid,ver,'vzdeni',[nCi,nion])*1e1;


%% Close file

fclose(fid);
