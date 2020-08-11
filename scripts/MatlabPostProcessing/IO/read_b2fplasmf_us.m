function state = read_b2fplasmf_us(file)


% Open file
[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end


%% Get version of the b2fstate file

%line    = fgetl(fid);
%version = line(8:17);

disp(['read_b2fsplasmf -- file version ',version]);
%state.version = version;


%% Read dimensions 
dim = read_ifield(fid,'nCv,nFc,ns',3);
nCv  = dim(1);
nFc  = dim(2);
ns   = dim(3);

statedim  = [nCv,1];
statedims = [nCv,ns];

fluxdim   = [nFc,2];
fluxdimp  = [nFc,2];
fluxdims  = [nFc,2,ns];


%% Read charges etc.

% state.zamin = read_rfield(fid,'zamin',ns);
% state.zamax = read_rfield(fid,'zamax',ns);
% state.zn    = read_rfield(fid,'zn   ',ns);
% state.am    = read_rfield(fid,'am   ',ns);


%% Read state variables

state.na     = read_rfield(fid,'na'    ,statedims);
state.ne     = read_rfield(fid,'ne'    ,statedim);
state.ua     = read_rfield(fid,'ua'    ,statedims);
state.uadia  = read_rfield(fid,'uadia' ,fluxdims);
state.te     = read_rfield(fid,'te'    ,statedim);
state.ti     = read_rfield(fid,'ti'    ,statedim);
state.tn     = read_rfield(fid,'tn'    ,statedim);
state.po     = read_rfield(fid,'po'    ,statedim);


%% Read fluxes

state.fna    = read_rfield(fid,'fna'   ,fluxdims);
state.fhe    = read_rfield(fid,'fhe'   ,fluxdim);
state.fhi    = read_rfield(fid,'fhi'   ,fluxdim);
state.fch    = read_rfield(fid,'fch'   ,fluxdim);
state.fch_32 = read_rfield(fid,'fch_32',fluxdim);
state.fch_52 = read_rfield(fid,'fch_52',fluxdim);
state.kinrgy = read_rfield(fid,'kinrgy',statedims);
%state.time   = read_rfield(fid,'time'  ,1);
state.fch_p  = read_rfield(fid,'fch_p' ,fluxdimp);

state.fna_mdf     = read_rfield(fid,'fna_mdf'    ,fluxdims);
state.fhe_mdf     = read_rfield(fid,'fhe_mdf'    ,fluxdim);
state.fhi_mdf     = read_rfield(fid,'fhi_mdf'    ,fluxdim);
state.fna_fcor    = read_rfield(fid,'fna_fcor'   ,fluxdims);
state.fna_nodrift = read_rfield(fid,'fna_nodrift',fluxdims);
state.fna_he      = read_rfield(fid,'fna_he'     ,fluxdims);
state.fnaPSch     = read_rfield(fid,'fnaPSch'    ,fluxdims);
state.fhePSch     = read_rfield(fid,'fhePSch'    ,fluxdim);
state.fhiPSch     = read_rfield(fid,'fhiPSch'    ,fluxdim);
state.fna_eir     = read_rfield(fid,'fna_eir'    ,fluxdims);
state.fne_eir     = read_rfield(fid,'fne_eir'    ,fluxdim);
state.fhe_eir     = read_rfield(fid,'fhe_eir'    ,fluxdim);
state.fhi_eir     = read_rfield(fid,'fhi_eir'    ,fluxdim);
state.fna_32      = read_rfield(fid,'fna_32'     ,fluxdims);
state.fna_52      = read_rfield(fid,'fna_52'     ,fluxdims);
state.fni_32      = read_rfield(fid,'fni_32'     ,fluxdim);
state.fni_52      = read_rfield(fid,'fni_52'     ,fluxdim);
state.fne_32      = read_rfield(fid,'fne_32'     ,fluxdim);
state.fne_52      = read_rfield(fid,'fne_52'     ,fluxdim);
state.fchdia      = read_rfield(fid,'fchdia'     ,fluxdim);
state.fchin       = read_rfield(fid,'fchin'      ,fluxdim);
state.fchvispar   = read_rfield(fid,'fchvispar'  ,fluxdim);
state.fchvisper   = read_rfield(fid,'fchvisper'  ,fluxdim);
state.fchvisq     = read_rfield(fid,'fchvisq'    ,fluxdim);
state.fchinert    = read_rfield(fid,'fchinert'   ,fluxdim);

state.vaecrb = read_rfield(fid,'vaecrb' ,fluxdims);
state.vadia  = read_rfield(fid,'vadia'  ,fluxdims);
state.wadia  = read_rfield(fid,'wadia'  ,fluxdims);
state.veecrb = read_rfield(fid,'veecrb' ,fluxdim);
state.vedia  = read_rfield(fid,'vedia'  ,fluxdim);

state.floe_noc  = read_rfield(fid,'floe_noc' ,fluxdim);
state.floi_noc  = read_rfield(fid,'floi_noc' ,fluxdim);

state.resco  = read_rfield(fid,'resco' ,[nCv,ns]);
state.reshe  = read_rfield(fid,'reshe' ,[nCv]);
state.reshi  = read_rfield(fid,'reshi' ,[nCv]);
state.reshn  = read_rfield(fid,'reshn' ,[nCv]);
state.resmo  = read_rfield(fid,'resmo' ,[nCv,ns]);
state.resmt  = read_rfield(fid,'resmt' ,[nCv]);
state.respo  = read_rfield(fid,'respo' ,[nCv]);



state.sna  = read_rfield(fid,'sna' ,[nCv,2,ns]);
state.smo  = read_rfield(fid,'smo' ,[nCv,4,ns]);
state.smq  = read_rfield(fid,'smq' ,[nCv,4,ns]);
state.shi  = read_rfield(fid,'shi' ,[nCv,4]);
state.she  = read_rfield(fid,'she' ,[nCv,4]);



%% Close file

fclose(fid);
