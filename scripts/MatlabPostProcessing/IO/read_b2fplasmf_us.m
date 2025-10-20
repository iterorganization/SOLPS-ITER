function state = read_b2fplasmf_us(file)
% state = read_b2fplasmf_us(file)
%
% Read formatted b2fplasmf file created by B2.5.
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

disp(['Attempting read_b2fplasmf_us.'])

% Open file
[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end


%% Get version of the b2fstate file

line    = fgetl(fid);
version = line(8:17);

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
state.kt     = read_rfield(fid,'kt'    ,statedim);

%% Read fluxes

state.fna    = read_rfield(fid,'fna'   ,fluxdims);
state.fne    = read_rfield(fid,'fne'   ,fluxdim);
state.fni    = read_rfield(fid,'fni'   ,fluxdim);
state.fmo    = read_rfield(fid,'fmo'   ,fluxdims);
state.fhe    = read_rfield(fid,'fhe'   ,fluxdim);
state.fhi    = read_rfield(fid,'fhi'   ,fluxdim);
state.fhn    = read_rfield(fid,'fhn'   ,fluxdim);
state.fch    = read_rfield(fid,'fch'   ,fluxdim);
state.fch_32 = read_rfield(fid,'fch_32',fluxdim);
state.fch_52 = read_rfield(fid,'fch_52',fluxdim);
state.kinrgy = read_rfield(fid,'kinrgy',statedims);
state.fkt = read_rfield(fid,'fkt',fluxdim);
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
state.fchanml     = read_rfield(fid,'fchanml'    ,fluxdim);
state.fht         = read_rfield(fid,'fht'        ,fluxdim);
state.fhj         = read_rfield(fid,'fhj'        ,fluxdim);
state.fhm         = read_rfield(fid,'fhm'        ,fluxdims);
state.fhp         = read_rfield(fid,'fhp'        ,fluxdims);

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
state.reskt  = read_rfield(fid,'reskt' ,[nCv]);


state.sna  = read_rfield(fid,'sna' ,[nCv,2,ns]);
state.smo  = read_rfield(fid,'smo' ,[nCv,4,ns]);
state.smq  = read_rfield(fid,'smq' ,[nCv,4,ns]);
state.shi  = read_rfield(fid,'shi' ,[nCv,4]);
state.she  = read_rfield(fid,'she' ,[nCv,4]);
state.shn  = read_rfield(fid,'shn' ,[nCv,4]);
state.skt  = read_rfield(fid,'skt' ,[nCv,4]);
state.skt_prod  = read_rfield(fid,'skt_prod' ,[nCv]);
state.skt_diss  = read_rfield(fid,'skt_diss' ,[nCv]);


state.calf     = read_rfield(fid,'calf'    ,fluxdim);
state.cdna     = read_rfield(fid,'cdna'    ,fluxdims);
state.cdpa     = read_rfield(fid,'cdpa'    ,fluxdims);
state.ceqp     = read_rfield(fid,'ceqp'    ,[nCv]);
state.chce     = read_rfield(fid,'chce'    ,fluxdim);
state.chci     = read_rfield(fid,'chci'    ,fluxdim);
state.chve     = read_rfield(fid,'chve'    ,fluxdim);
state.chvemx     = read_rfield(fid,'chvemx'    ,[nFc]);
state.chvi     = read_rfield(fid,'chvi'    ,fluxdim);
state.chvimx     = read_rfield(fid,'chvimx'    ,[nFc]);
state.csig     = read_rfield(fid,'csig'    ,fluxdim);
state.cvla     = read_rfield(fid,'cvla'    ,fluxdims);
state.cvsa     = read_rfield(fid,'cvsa'    ,fluxdims);
state.cthe     = read_rfield(fid,'cthe'    ,statedims);
state.cthi     = read_rfield(fid,'cthi'    ,statedims);
state.csigin     = read_rfield(fid,'csigin'    ,[nFc 2 ns ns]);
state.cvsa_cl     = read_rfield(fid,'cvsa_cl'    ,fluxdims);
state.fllime     = read_rfield(fid,'fllime'    ,[nFc]);
state.fllimi     = read_rfield(fid,'fllimi'    ,[nFc]);
state.fllim0fna     = read_rfield(fid,'fllim0fna'    ,fluxdims);
state.fllim0fhi    = read_rfield(fid,'fllim0fhi'    ,fluxdims);
state.fllimvisc     = read_rfield(fid,'fllimvisc'    ,[nFc ns]);
state.f_luc_ke     = read_rfield(fid,'f_luc_ke'    ,[nFc]);
state.f_luc_ki     = read_rfield(fid,'f_luc_ki'    ,[nFc]);
state.f_luc_et     = read_rfield(fid,'f_luc_et'    ,[nFc]);
state.f_luc_sg     = read_rfield(fid,'f_luc_sg'    ,[nFc]);
state.f_luc_al     = read_rfield(fid,'f_luc_al'    ,[nFc]);
state.fllim_ke     = read_rfield(fid,'fllim_ke'    ,[nFc]);
state.fllim_ki     = read_rfield(fid,'fllim_ki'    ,[nFc]);
state.fllim_al     = read_rfield(fid,'fllim_al'    ,[nFc]);
state.fllim_al_c     = read_rfield(fid,'fllim_al_c'    ,[nCv]);




state.sig0     = read_rfield(fid,'sig0'    ,[nCv]);
state.hce0     = read_rfield(fid,'hce0'    ,[nCv]);
state.alf0     = read_rfield(fid,'alf0'    ,[nCv]);
state.hci0     = read_rfield(fid,'hci0'    ,[nCv]);
state.hcib     = read_rfield(fid,'hcib'    ,statedims);
state.dpa0     = read_rfield(fid,'dpa0'    ,statedims);
state.dna0     = read_rfield(fid,'dna0'    ,statedims);
state.vsa0     = read_rfield(fid,'vsa0'    ,statedims);
state.vla0     = read_rfield(fid,'vla0'    ,[nCv 2 ns]);
state.dkt0     = read_rfield(fid,'dkt0'    ,[nCv]);
state.dna_ExB     = read_rfield(fid,'dna_ExB'    ,[nCv]);
state.hce_ExB     = read_rfield(fid,'hce_ExB'    ,[nCv]);
state.hci_ExB     = read_rfield(fid,'hci_ExB'    ,[nCv]);
state.dna_bohm    = read_rfield(fid,'dna_bohm'    ,[nCv 2 ns]);
state.vla_bohm    = read_rfield(fid,'vla_bohm'    ,[nCv 2 ns]);
state.vsa_bohm    = read_rfield(fid,'vsa_bohm'    ,[nCv 2 ns]);

%% Close file

fclose(fid);

disp(['Done read_b2fplasmf_us with no errors.'])

end
