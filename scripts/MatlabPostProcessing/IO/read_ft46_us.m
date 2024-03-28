function tdata = read_ft46_us(file,nCi,ft35)
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
ntri = fscanf(fid,'%d',1);
ver     = fscanf(fid,'%d',1);



if ver ~= 20160513 && ver ~= 20160829 && ver ~= 20170930  && ver ~= 20231224
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

tdata.pdena = zeros(ntri,natm);
tdata.pdenm = zeros(ntri,nmol);
tdata.pdenm = zeros(ntri,nion);

tdata.edena = zeros(ntri,natm);
tdata.edenm = zeros(ntri,nmol);
tdata.edenm = zeros(ntri,nion);

tdata.vxdena = zeros(ntri,natm);
tdata.vxdenm = zeros(ntri,nmol);
tdata.vxdenm = zeros(ntri,nion);

tdata.vydena = zeros(ntri,natm);
tdata.vydenm = zeros(ntri,nmol);
tdata.vydenm = zeros(ntri,nion);

tdata.vzdena = zeros(ntri,natm);
tdata.vzdenm = zeros(ntri,nmol);
tdata.vzdenm = zeros(ntri,nion);

tdata.pdena(1:ntri,1:natm)  = read_ft44_rfield(fid,ver,'pdena',[ntri,natm])*1e6; % m^{-3}
tdata.pdenm(1:ntri,1:nmol)  = read_ft44_rfield(fid,ver,'pdenm',[ntri,nmol])*1e6;
tdata.pdeni(1:ntri,1:nion)  = read_ft44_rfield(fid,ver,'pdeni',[ntri,nion])*1e6;

tdata.edena(1:ntri,1:natm)  = read_ft44_rfield(fid,ver,'edena',[ntri,natm])*1e6*eV; % J m^{-3}
tdata.edenm(1:ntri,1:nmol)  = read_ft44_rfield(fid,ver,'edenm',[ntri,nmol])*1e6*eV;
tdata.edeni(1:ntri,1:nion)  = read_ft44_rfield(fid,ver,'edeni',[ntri,nion])*1e6*eV;

tdata.vxdena(1:ntri,1:natm) = read_ft44_rfield(fid,ver,'vxdena',[ntri,natm])*1e1; % kg s^{-1} m^{-2}
tdata.vxdenm(1:ntri,1:nmol) = read_ft44_rfield(fid,ver,'vxdenm',[ntri,nmol])*1e1;
tdata.vxdeni(1:ntri,1:nion) = read_ft44_rfield(fid,ver,'vxdeni',[ntri,nion])*1e1;

tdata.vydena(1:ntri,1:natm) = read_ft44_rfield(fid,ver,'vydena',[ntri,natm])*1e1; % kg s^{-1} m^{-2}
tdata.vydenm(1:ntri,1:nmol) = read_ft44_rfield(fid,ver,'vydenm',[ntri,nmol])*1e1;
tdata.vydeni(1:ntri,1:nion) = read_ft44_rfield(fid,ver,'vydeni',[ntri,nion])*1e1;

tdata.vzdena(1:ntri,1:natm) = read_ft44_rfield(fid,ver,'vzdena',[ntri,natm])*1e1; % kg s^{-1} m^{-2}
tdata.vzdenm(1:ntri,1:nmol) = read_ft44_rfield(fid,ver,'vzdenm',[ntri,nmol])*1e1;
tdata.vzdeni(1:ntri,1:nion) = read_ft44_rfield(fid,ver,'vzdeni',[ntri,nion])*1e1;

%% translate data to triangle mesh
tdata.pdena = ft46_to_triangle_data(tdata.pdena,nCi,ft35);
tdata.pdenm = ft46_to_triangle_data(tdata.pdenm,nCi,ft35);
tdata.pdeni = ft46_to_triangle_data(tdata.pdeni,nCi,ft35);

tdata.edena = ft46_to_triangle_data(tdata.edena,nCi,ft35);
tdata.edenm = ft46_to_triangle_data(tdata.edenm,nCi,ft35);
tdata.edeni = ft46_to_triangle_data(tdata.edeni,nCi,ft35);

tdata.vxdena = ft46_to_triangle_data(tdata.vxdena,nCi,ft35);
tdata.vxdenm = ft46_to_triangle_data(tdata.vxdenm,nCi,ft35);
tdata.vxdeni = ft46_to_triangle_data(tdata.vxdeni,nCi,ft35);

tdata.vydena = ft46_to_triangle_data(tdata.vydena,nCi,ft35);
tdata.vydenm = ft46_to_triangle_data(tdata.vydenm,nCi,ft35);
tdata.vydeni = ft46_to_triangle_data(tdata.vydeni,nCi,ft35);

tdata.vzdena = ft46_to_triangle_data(tdata.vzdena,nCi,ft35);
tdata.vzdenm = ft46_to_triangle_data(tdata.vzdenm,nCi,ft35);
tdata.vzdeni = ft46_to_triangle_data(tdata.vzdeni,nCi,ft35);


%% Close file

fclose(fid);
