function tdata = read_ft46(file)
% tdata = read_ft46(file)
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
ntri = fscanf(fid,'%d',1);
ver  = fscanf(fid,'%d',1);

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

tdata.pdena  = read_ft44_rfield(fid,ver,'pdena',[ntri,natm])*1e6; % m^{-3}
tdata.pdenm  = read_ft44_rfield(fid,ver,'pdenm',[ntri,nmol])*1e6;
tdata.pdeni  = read_ft44_rfield(fid,ver,'pdeni',[ntri,nion])*1e6;

tdata.edena  = read_ft44_rfield(fid,ver,'edena',[ntri,natm])*1e6*eV; % J m^{-3}
tdata.edenm  = read_ft44_rfield(fid,ver,'edenm',[ntri,nmol])*1e6*eV;
tdata.edeni  = read_ft44_rfield(fid,ver,'edeni',[ntri,nion])*1e6*eV;

tdata.vxdena = read_ft44_rfield(fid,ver,'vxdena',[ntri,natm])*1e1; % kg s^{-1} m^{-2}
tdata.vxdenm = read_ft44_rfield(fid,ver,'vxdenm',[ntri,nmol])*1e1;
tdata.vxdeni = read_ft44_rfield(fid,ver,'vxdeni',[ntri,nion])*1e1;

tdata.vydena = read_ft44_rfield(fid,ver,'vydena',[ntri,natm])*1e1; % kg s^{-1} m^{-2}
tdata.vydenm = read_ft44_rfield(fid,ver,'vydenm',[ntri,nmol])*1e1;
tdata.vydeni = read_ft44_rfield(fid,ver,'vydeni',[ntri,nion])*1e1;

tdata.vzdena = read_ft44_rfield(fid,ver,'vzdena',[ntri,natm])*1e1; % kg s^{-1} m^{-2}
tdata.vzdenm = read_ft44_rfield(fid,ver,'vzdenm',[ntri,nmol])*1e1;
tdata.vzdeni = read_ft44_rfield(fid,ver,'vzdeni',[ntri,nion])*1e1;


%% Close file

fclose(fid);
