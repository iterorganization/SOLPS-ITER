function [neut,wld] = read_ft44_us(file,nCv)

disp('read_ft44: assuming nlwrmsh = 1, nfla = 1.');
nlwrmsh = 1;
nfla = 1;

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

% neut = struct([]);
wld  = struct;
neut = struct;
%% Read dimensions

% go to new line (skip reading a possible git-hash)
fgetl(fid);

% natm, nmol, nion
dims = fscanf(fid,'%d',3);
natm = dims(1);
nmol = dims(2);
nion = dims(3);

%% version
ver = 20170328
%% Read basic data

neut.dab2     = read_ft44_rfield(fid,ver,'dab2',[nCv,1,natm]);
neut.tab2     = read_ft44_rfield(fid,ver,'tab2',[nCv,1,natm]);
neut.dmb2     = read_ft44_rfield(fid,ver,'dmb2',[nCv,1,nmol]);
neut.tmb2     = read_ft44_rfield(fid,ver,'tmb2',[nCv,1,nmol]);
neut.dib2     = read_ft44_rfield(fid,ver,'dib2',[nCv,1,nion]);
neut.tib2     = read_ft44_rfield(fid,ver,'tib2',[nCv,1,nion]);
neut.rfluxa   = read_ft44_rfield(fid,ver,'rfluxa',[nCv,1,natm]);
neut.rfluxm   = read_ft44_rfield(fid,ver,'rfluxm',[nCv,1,nmol]);
neut.pfluxa   = read_ft44_rfield(fid,ver,'pfluxa',[nCv,1,natm]);
neut.pfluxm   = read_ft44_rfield(fid,ver,'pfluxm',[nCv,1,nmol]);
neut.refluxa  = read_ft44_rfield(fid,ver,'refluxa',[nCv,1,natm]);
neut.refluxm  = read_ft44_rfield(fid,ver,'refluxm',[nCv,1,nmol]);
neut.pefluxa  = read_ft44_rfield(fid,ver,'pefluxa',[nCv,1,natm]);
neut.pefluxm  = read_ft44_rfield(fid,ver,'pefluxm',[nCv,1,nmol]);

fclose(fid);
