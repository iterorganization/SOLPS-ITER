function [neut,wld] = read_ft44_us(file,imapcv)

disp('read_ft44: assuming nlwrmsh = 1, nfla = 1.');
nlwrmsh = 1;
nfla = 1;

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

% neut = struct([]);
wld  = struct;

[nx ny] = size(imapcv);
nc = nx*ny-4; % the corner cells do not exist in unstructured!

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

temp.dab2     = read_ft44_rfield(fid,ver,'dab2',[nc,1,natm]);
temp.tab2     = read_ft44_rfield(fid,ver,'tab2',[nc,1,natm]);
%temp.dmb2     = read_ft44_rfield(fid,ver,'dmb2',[nc,1,nmol]);
%temp.tmb2     = read_ft44_rfield(fid,ver,'tmb2',[nc,1,nmol]);
%temp.dib2     = read_ft44_rfield(fid,ver,'dib2',[nc,1,nion]);
%temp.tib2     = read_ft44_rfield(fid,ver,'tib2',[nc,1,nion]);
%temp.rfluxa   = read_ft44_rfield(fid,ver,'rfluxa',[nc,1,natm]);
%temp.rfluxm   = read_ft44_rfield(fid,ver,'rfluxm',[nc,1,nmol]);
%temp.pfluxa   = read_ft44_rfield(fid,ver,'pfluxa',[nc,1,natm]);
%temp.pfluxm   = read_ft44_rfield(fid,ver,'pfluxm',[nc,1,nmol]);
%temp.refluxa  = read_ft44_rfield(fid,ver,'refluxa',[nc,1,natm]);
%temp.refluxm  = read_ft44_rfield(fid,ver,'refluxm',[nc,1,nmol]);
%temp.pefluxa  = read_ft44_rfield(fid,ver,'pefluxa',[nc,1,natm]);
%temp.pefluxm  = read_ft44_rfield(fid,ver,'pefluxm',[nc,1,nmol]);

%% convert to a matrix using imapcv.
%% for now only do this for dab2 and tab2. Others can be added later if needed.
%%% TODO add loop if natm > 1
neut.dab2 = zeros(nx,ny);
neut.tab2 = zeros(nx,ny);
mind = min(temp.dab2);
mint = min(temp.tab2); 
for ix=1:nx
    for iy=1:ny
        index = imapcv(ix,iy);
        
        if ix == 1 && iy == 1
            neut.dab2(ix,iy) = mind;
            neut.dab2(ix,iy) = mint;
        elseif ix == 1 && iy == ny
            neut.dab2(ix,iy) = mind;
            neut.dab2(ix,iy) = mint;
        elseif ix == nx && iy == 1
            neut.dab2(ix,iy) = mind;
            neut.dab2(ix,iy) = mint;
        elseif ix == nx && iy == ny
            neut.dab2(ix,iy) = mind;
            neut.dab2(ix,iy) = mint;
        else
            neut.dab2(ix,iy) = temp.dab2(index);
            neut.tab2(ix,iy) = temp.tab2(index);
        end
    end
end

fclose(fid);
