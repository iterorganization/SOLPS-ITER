function [neut,wld] = read_ft44(file)
% [neut,wld] = read_ft44(file)
%
% Read fort.44 file
%
% For now
% - only fort.44 version 20081111 recognized
% - assuming nfla = 1 until a better fix 
% - assuming nlwrmsh = 1 until a better fix
%
% 
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

disp('read_ft44: assuming nlwrmsh = 1, nfla = 1.');
nlwrmsh = 1;
nfla = 1;

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

% neut = struct([]);
wld  = struct;


%% Read dimensions

% nx, ny, version
dims = fscanf(fid,'%d',3);
nx   = dims(1);
ny   = dims(2);
ver  = dims(3);

if ver ~= 20081111 && ver ~= 20160829
    error('read_ft44: unknown format of fort.44 file');
end

% natm, nmol, nion
dims = fscanf(fid,'%d',3);
natm = dims(1);
nmol = dims(2);
nion = dims(3);

% for now, ignore reading species labels
line = fgetl(fid);
for i = 1:natm
    line = fgetl(fid);
end
for i = 1:nmol
    line = fgetl(fid);
end
for i = 1:nion
    line = fgetl(fid);
end


%% Read basic data

neut.dab2     = read_ft44_rfield(fid,ver,'dab2',[nx,ny,natm]);
neut.tab2     = read_ft44_rfield(fid,ver,'tab2',[nx,ny,natm]);
neut.dmb2     = read_ft44_rfield(fid,ver,'dmb2',[nx,ny,nmol]);
neut.tmb2     = read_ft44_rfield(fid,ver,'tmb2',[nx,ny,nmol]);
neut.dib2     = read_ft44_rfield(fid,ver,'dib2',[nx,ny,nion]);
neut.tib2     = read_ft44_rfield(fid,ver,'tib2',[nx,ny,nion]);
neut.rfluxa   = read_ft44_rfield(fid,ver,'rfluxa',[nx,ny,natm]);
neut.rfluxm   = read_ft44_rfield(fid,ver,'rfluxm',[nx,ny,nmol]);
neut.pfluxa   = read_ft44_rfield(fid,ver,'pfluxa',[nx,ny,natm]);
neut.pfluxm   = read_ft44_rfield(fid,ver,'pfluxm',[nx,ny,nmol]);
neut.refluxa  = read_ft44_rfield(fid,ver,'refluxa',[nx,ny,natm]);
neut.refluxm  = read_ft44_rfield(fid,ver,'refluxm',[nx,ny,nmol]);
neut.pefluxa  = read_ft44_rfield(fid,ver,'pefluxa',[nx,ny,natm]);
neut.pefluxm  = read_ft44_rfield(fid,ver,'pefluxm',[nx,ny,nmol]);
% % % neut.emiss    = read_ft44_rfield(fid,[nx,ny,1]);
% % % neut.emissmol = read_ft44_rfield(fid,[nx,ny,1]);
% % % neut.srcml    = read_ft44_rfield(fid,[nx,ny,nmol]);
% % % neut.edissml  = read_ft44_rfield(fid,[nx,ny,nmol]);
% % % 
% % % 
% % % %% Data on wall loading
% % % 
% % % % nlim, nsts, nstra
% % % dims  = fscanf(fid,'%d',3);
% % % nlim  = dims(1);
% % % nsts  = dims(2);
% % % nstra = dims(3);
% % % 
% % % wld.wldnek = zeros(nlim+nsts,nstra+1);
% % % wld.wldnep = zeros(nlim+nsts,nstra+1);
% % % wld.wldna  = zeros(nlim+nsts,natm,nstra+1);
% % % wld.ewlda  = zeros(nlim+nsts,natm,nstra+1);
% % % wld.wldnm  = zeros(nlim+nsts,nmol,nstra+1);
% % % wld.ewldm  = zeros(nlim+nsts,nmol,nstra+1);
% % % 
% % % wld.wldnek(:,1)  = read_ft44_rfield(fid,nlim+nsts);
% % % wld.wldnep(:,1)  = read_ft44_rfield(fid,nlim+nsts);
% % % wld.wldna(:,:,1) = read_ft44_rfield(fid,[nlim+nsts,natm]);
% % % wld.ewlda(:,:,1) = read_ft44_rfield(fid,[nlim+nsts,natm]);
% % % wld.wldnm(:,:,1) = read_ft44_rfield(fid,[nlim+nsts,nmol]);
% % % wld.ewldm(:,:,1) = read_ft44_rfield(fid,[nlim+nsts,nmol]);
% % % 
% % % wld.poly = read_ft44_rfield(fid,[4,nlim]);
% % % 
% % % wld.wldra  = read_ft44_rfield(fid,[nlim+nsts,natm]);
% % % wld.wldrm  = read_ft44_rfield(fid,[nlim+nsts,nmol]);
% % % 
% % % if (nstra > 1)
% % %     for i = 2:nstra+1
% % %         wld.wldnek(:,i)  = read_ft44_rfield(fid,nlim+nsts);
% % %         wld.wldnep(:,i)  = read_ft44_rfield(fid,nlim+nsts);
% % %         wld.wldna(:,:,i) = read_ft44_rfield(fid,[nlim+nsts,natm]);
% % %         wld.ewlda(:,:,i) = read_ft44_rfield(fid,[nlim+nsts,natm]);
% % %         wld.wldnm(:,:,i) = read_ft44_rfield(fid,[nlim+nsts,nmol]);
% % %         wld.ewldm(:,:,i) = read_ft44_rfield(fid,[nlim+nsts,nmol]);
% % %     end
% % % end
% % % 
% % % 
% % % wld.wldpp   = zeros(nlim+nsts,nfla,nstra+1);
% % % wld.wldpa   = zeros(nlim+nsts,natm,nstra+1);
% % % wld.wldpm   = zeros(nlim+nsts,nmol,nstra+1);
% % % wld.wldpeb  = zeros(nlim+nsts,nstra+1);
% % % wld.wldspt  = zeros(nlim+nsts,nstra+1);
% % % 
% % % wld.wldpp(:,:,1) = read_ft44_rfield(fid,[nlim+nsts,nfla]);
% % % wld.wldpa(:,:,1) = read_ft44_rfield(fid,[nlim+nsts,natm]);
% % % wld.wldpm(:,:,1) = read_ft44_rfield(fid,[nlim+nsts,nmol]);
% % % wld.wldpeb(:,1)  = read_ft44_rfield(fid,nlim+nsts);
% % % wld.wldspt(:,1)  = read_ft44_rfield(fid,nlim+nsts);
% % % 
% % % if (nstra > 1)
% % %     for i = 2:nstra+1
% % %         wld.wldpp(:,:,i) = read_ft44_rfield(fid,[nlim+nsts,nfla]);
% % %         wld.wldpa(:,:,i) = read_ft44_rfield(fid,[nlim+nsts,natm]);
% % %         wld.wldpm(:,:,i) = read_ft44_rfield(fid,[nlim+nsts,nmol]);
% % %         wld.wldpeb(:,i)  = read_ft44_rfield(fid,nlim+nsts);
% % %         wld.wldspt(:,i)  = read_ft44_rfield(fid,nlim+nsts);
% % %     end
% % % end
% % % 
% % % wld.isrftype = read_ft44_ifield(fid,nlim+nsts);

% % if nlwrmsh
% %     
% %     wld.wlarea  = read_ft44_rfield(fid,nlim+nsts);
% %     
% %     wld.wlabsrp = zeros(natm+nmol+nion+nfla,nlim+nsts);
% %     line = fgetl(fid)
% %     wld.wlabsrp(1:natm,:) = read_ft44_rfield(fid,[natm,nlim+nsts]);
% %     line = fgetl(fid)
% %     ns = natm;
% %     wld.wlabsrp(ns+1:ns+nmol,:) = read_ft44_rfield(fid,[nmol,nlim+nsts]);
% %     line = fgetl(fid)
% %     ns = natm+nmol;
% %     wld.wlabsrp(ns+1:ns+nion,:) = read_ft44_rfield(fid,[nion,nlim+nsts]);
% %     line = fgetl(fid)
% %     ns = natm+nmol+nion;
% %     wld.wlabsrp(ns+1:ns+nfla,:) = read_ft44_rfield(fid,[nfla,nlim+nsts]);
% %     
% %     neut.eneutrad = read_ft44_rfield(fid,[nx,ny,natm]);
% %     
% %     wld.eirdiag_nds_ind   = read_ft44_ifield(fid,nsts+1);
% %     wld.eirdiag_nds_typ   = read_ft44_ifield(fid,nsts);
% %     wld.eirdiag_nds_srf   = read_ft44_ifield(fid,nsts);
% %     wld.eirdiag_nds_start = read_ft44_ifield(fid,nsts);
% %     wld.eirdiag_nds_end   = read_ft44_ifield(fid,nsts);
% %     
% %     ncl = wld.eirdiag_nds_ind(nsts+1);
% %     
% %     wld.sarea_res  = read_ft44_rfield(fid,ncl);
% %     wld.wldna_res  = read_ft44_rfield(fid,[natm,ncl]);
% %     wld.wldnm_res  = read_ft44_rfield(fid,[nmol,ncl]);
% %     wld.ewldna_res = read_ft44_rfield(fid,[natm,ncl]);
% %     wld.ewldnm_res = read_ft44_rfield(fid,[nmol,ncl]);
% %     wld.ewldea_res = read_ft44_rfield(fid,[natm,ncl]);
% %     wld.ewldem_res = read_ft44_rfield(fid,[nmol,ncl]);
% %     wld.ewldrp_res = read_ft44_rfield(fid,ncl);
% %     wld.ewldmr_res = read_ft44_rfield(fid,[nmol,ncl]);
% %     
% %     neut.PDENA_INT    = read_ft44_rfield(fid,[natm,nstrata]);
% %     neut.PDENM_INT    = read_ft44_rfield(fid,[nmol,nstrata]);
% %     neut.PDENI_INT    = read_ft44_rfield(fid,[nion,nstrata]);
% %     neut.PDENA_INT_B2 = read_ft44_rfield(fid,[natm,nstrata]);
% %     neut.PDENM_INT_B2 = read_ft44_rfield(fid,[nmol,nstrata]);
% %     neut.PDENI_INT_B2 = read_ft44_rfield(fid,[nion,nstrata]);
% %     neut.EDENA_INT    = read_ft44_rfield(fid,[natm,nstrata]);
% %     neut.EDENM_INT    = read_ft44_rfield(fid,[nmol,nstrata]);
% %     neut.EDENI_INT    = read_ft44_rfield(fid,[nion,nstrata]);
% %     neut.EDENA_INT_B2 = read_ft44_rfield(fid,[natm,nstrata]);
% %     neut.EDENM_INT_B2 = read_ft44_rfield(fid,[nmol,nstrata]);
% %     neut.EDENI_INT_B2 = read_ft44_rfield(fid,[nion,nstrata]);
% % else
% %     neut.eneutrad = read_ft44_rfield(fid,[nx,ny,natm]);
% % end

fclose(fid);