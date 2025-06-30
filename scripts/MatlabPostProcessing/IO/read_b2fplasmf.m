function [gmtry,state] = read_b2fplasmf(file,nx,ny,ns)
% [gmtry,state] = read_b2fplasmf(file,nx,ny,ns)
%
% Read formatted b2fplasmf file created by B2.5.
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

gmtry = [];
state = [];


%% Get version of the b2fstate file

line    = fgetl(fid);
version = line(8:17);

disp(['read_b2fplasmf -- file version ',version]);


% Expected array sizes, gmtry
qcdim = [nx+2,ny+2];
if version >= '03.001.000'
    qcdim  = [nx+2,ny+2,2];
end


% Expected array sizes, state
fluxdim  = [nx+2,ny+2,2];
fluxdims = [nx+2,ny+2,2,ns];
if version >= '03.001.000'
    fluxdim  = [nx+2,ny+2,2,2];
    fluxdims = [nx+2,ny+2,2,2,ns];
end


%% Read gmtry variables

gmtry.bb   = read_rfield(fid,'bb'  ,[nx+2,ny+2,4]);
gmtry.crx  = read_rfield(fid,'crx' ,[nx+2,ny+2,4]);
gmtry.cry  = read_rfield(fid,'cry' ,[nx+2,ny+2,4]);
gmtry.ffbz = read_rfield(fid,'ffbz',[nx+2,ny+2,4]);
gmtry.fpsi = read_rfield(fid,'fpsi',[nx+2,ny+2,4]);
gmtry.gs   = read_rfield(fid,'gs'  ,[nx+2,ny+2,3]);
gmtry.hx   = read_rfield(fid,'hx'  ,[nx+2,ny+2]);
gmtry.hy   = read_rfield(fid,'hy'  ,[nx+2,ny+2]);
gmtry.qz   = read_rfield(fid,'qz'  ,[nx+2,ny+2,2]);
gmtry.qc   = read_rfield(fid,'qc'  ,qcdim);
gmtry.vol  = read_rfield(fid,'vol' ,[nx+2,ny+2]);
gmtry.pbs  = read_rfield(fid,'pbs' ,[nx+2,ny+2,2]);


%% Read state variables

state.fch    = read_rfield(fid,'fch'   ,fluxdim);
state.fch0   = read_rfield(fid,'fch0'  ,fluxdim);
state.fchp   = read_rfield(fid,'fchp'  ,fluxdim);
state.fhe    = read_rfield(fid,'fhe'   ,fluxdim);
state.fhe0   = read_rfield(fid,'fhe0'  ,fluxdim);
state.fhep   = read_rfield(fid,'fhep'  ,fluxdim);
state.fhet   = read_rfield(fid,'fhet'  ,fluxdim);
state.fhi    = read_rfield(fid,'fhi'   ,fluxdim);
state.fhi0   = read_rfield(fid,'fhi0'  ,fluxdim);
state.fhip   = read_rfield(fid,'fhip'  ,fluxdim);
state.fhit   = read_rfield(fid,'fhit'  ,fluxdim);
state.fna    = read_rfield(fid,'fna'   ,fluxdims);
state.fna0   = read_rfield(fid,'fna0'  ,fluxdims);
state.fnap   = read_rfield(fid,'fnap'  ,fluxdims);
state.fne    = read_rfield(fid,'fne'   ,fluxdim);
state.fni    = read_rfield(fid,'fni'   ,fluxdim);
state.na     = read_rfield(fid,'na'    ,[nx+2,ny+2,ns]);
state.na0    = read_rfield(fid,'na0'   ,[nx+2,ny+2,ns]);
state.nap    = read_rfield(fid,'nap'   ,[nx+2,ny+2,ns]);
state.ne     = read_rfield(fid,'ne'    ,[nx+2,ny+2]);
state.ne0    = read_rfield(fid,'ne0'   ,[nx+2,ny+2]);
state.ne2    = read_rfield(fid,'ne2'   ,[nx+2,ny+2]);
state.nep    = read_rfield(fid,'nep'   ,[nx+2,ny+2]);
state.ni     = read_rfield(fid,'ni'    ,[nx+2,ny+2,2]);
state.ni0    = read_rfield(fid,'ni0'   ,[nx+2,ny+2,2]);
state.pb     = read_rfield(fid,'pb'    ,[nx+2,ny+2]);
state.po     = read_rfield(fid,'po'    ,[nx+2,ny+2]);
state.po0    = read_rfield(fid,'po0'   ,[nx+2,ny+2]);
state.pop    = read_rfield(fid,'pop'   ,[nx+2,ny+2]);
state.te     = read_rfield(fid,'te'    ,[nx+2,ny+2]);
state.te0    = read_rfield(fid,'te0'   ,[nx+2,ny+2]);
state.tep    = read_rfield(fid,'tep'   ,[nx+2,ny+2]);
state.ti     = read_rfield(fid,'ti'    ,[nx+2,ny+2]);
state.ti0    = read_rfield(fid,'ti0'   ,[nx+2,ny+2]);
state.tip    = read_rfield(fid,'tip'   ,[nx+2,ny+2]);
state.ua     = read_rfield(fid,'ua'    ,[nx+2,ny+2,ns]);
state.ua0    = read_rfield(fid,'ua0'   ,[nx+2,ny+2,ns]);
state.uap    = read_rfield(fid,'uap'   ,[nx+2,ny+2,ns]);
state.uadia  = read_rfield(fid,'uadia' ,fluxdims);
state.fchdia = read_rfield(fid,'fchdia',fluxdim);
state.fmo    = read_rfield(fid,'fmo'   ,fluxdims);
state.fna_32 = read_rfield(fid,'fna_32',fluxdims);
state.fna_52 = read_rfield(fid,'fna_52',fluxdims);
state.fni_32 = read_rfield(fid,'fni_32',fluxdim);
state.fni_52 = read_rfield(fid,'fni_52',fluxdim);
state.fne_32 = read_rfield(fid,'fne_32',fluxdim);
state.fne_52 = read_rfield(fid,'fne_52',fluxdim);
state.wadia  = read_rfield(fid,'wadia' ,fluxdims);
state.vaecrb = read_rfield(fid,'vaecrb',fluxdims);
state.facdrift     = read_rfield(fid,'facdrift'    ,[nx+2,ny+2]);
state.fac_ExB      = read_rfield(fid,'fac_ExB'     ,[nx+2,ny+2]);
state.fchvispar    = read_rfield(fid,'fchvispar'   ,fluxdim);
state.fchvisper    = read_rfield(fid,'fchvisper'   ,fluxdim);
state.fchin        = read_rfield(fid,'fchin'       ,fluxdim);
state.fna_nodrift  = read_rfield(fid,'fna_nodrift' ,fluxdims);
state.fac_vis      = read_rfield(fid,'fac_vis'     ,[nx+2,ny+2]);
state.fna_mdf      = read_rfield(fid,'fna_mdf'     ,fluxdims);
state.fhe_mdf      = read_rfield(fid,'fhe_mdf'     ,fluxdim);
state.fhi_mdf      = read_rfield(fid,'fhi_mdf'     ,fluxdim);
state.fnaPSch      = read_rfield(fid,'fnaPSch'     ,fluxdims);
state.fhePSch      = read_rfield(fid,'fhePSch'     ,fluxdim);
state.fhiPSch      = read_rfield(fid,'fhiPSch'     ,fluxdim);
state.fna_fcor     = read_rfield(fid,'fna_fcor'    ,fluxdims);
state.fna_he       = read_rfield(fid,'fna_he'      ,fluxdims);
state.fchvisq      = read_rfield(fid,'fchvisq'     ,fluxdim);
state.fchinert     = read_rfield(fid,'fchinert'    ,fluxdim);
state.resco        = read_rfield(fid,'resco'       ,[nx+2,ny+2,ns]);
state.reshe        = read_rfield(fid,'reshe'       ,[nx+2,ny+2]);
state.reshi        = read_rfield(fid,'reshi'       ,[nx+2,ny+2]);
state.resmo        = read_rfield(fid,'resmo'       ,[nx+2,ny+2,ns]);
state.resmt        = read_rfield(fid,'resmt'       ,[nx+2,ny+2]);
state.respo        = read_rfield(fid,'respo'       ,[nx+2,ny+2]);
state.sch          = read_rfield(fid,'sch'         ,[nx+2,ny+2,4]);
state.she          = read_rfield(fid,'she'         ,[nx+2,ny+2,4]);
state.shi          = read_rfield(fid,'shi'         ,[nx+2,ny+2,4]);
state.smo          = read_rfield(fid,'smo'         ,[nx+2,ny+2,4,ns]);
state.smq          = read_rfield(fid,'smq'         ,[nx+2,ny+2,4,ns]);
state.sna          = read_rfield(fid,'sna'         ,[nx+2,ny+2,2,ns]);
state.sne          = read_rfield(fid,'sne'         ,[nx+2,ny+2,2]);
state.rsana        = read_rfield(fid,'rsana'       ,[nx+2,ny+2,ns]);
state.rsahi        = read_rfield(fid,'rsahi'       ,[nx+2,ny+2,ns]);
state.rsamo        = read_rfield(fid,'rsamo'       ,[nx+2,ny+2,ns]);
state.rrana        = read_rfield(fid,'rrana'       ,[nx+2,ny+2,ns]);
state.rrahi        = read_rfield(fid,'rrahi'       ,[nx+2,ny+2,ns]);
state.rramo        = read_rfield(fid,'rramo'       ,[nx+2,ny+2,ns]);
state.rqahe        = read_rfield(fid,'rqahe'       ,[nx+2,ny+2,ns]);
state.rqrad        = read_rfield(fid,'rqrad'       ,[nx+2,ny+2,ns]);
state.rqbrm        = read_rfield(fid,'rqbrm'       ,[nx+2,ny+2,ns]);
state.rcxna        = read_rfield(fid,'rcxna'       ,[nx+2,ny+2,ns]);
state.rcxhi        = read_rfield(fid,'rcxhi'       ,[nx+2,ny+2,ns]);
state.rcxmo        = read_rfield(fid,'rcxmo'       ,[nx+2,ny+2,ns]);
state.b2stbr_sna   = read_rfield(fid,'b2stbr_sna'  ,[nx+2,ny+2,ns]);
state.b2stbr_smo   = read_rfield(fid,'b2stbr_smo'  ,[nx+2,ny+2,ns]);
state.b2stbr_she   = read_rfield(fid,'b2stbr_she'  ,[nx+2,ny+2]);
state.b2stbr_shi   = read_rfield(fid,'b2stbr_shi'  ,[nx+2,ny+2]);
state.b2stbr_sch   = read_rfield(fid,'b2stbr_sch'  ,[nx+2,ny+2]);
state.b2stbr_sne   = read_rfield(fid,'b2stbr_sne'  ,[nx+2,ny+2]);
state.b2stbc_sna   = read_rfield(fid,'b2stbc_sna'  ,[nx+2,ny+2,ns]);
state.b2stbc_smo   = read_rfield(fid,'b2stbc_smo'  ,[nx+2,ny+2,ns]);
state.b2stbc_she   = read_rfield(fid,'b2stbc_she'  ,[nx+2,ny+2]);
state.b2stbc_shi   = read_rfield(fid,'b2stbc_shi'  ,[nx+2,ny+2]);
state.b2stbc_sch   = read_rfield(fid,'b2stbc_sch'  ,[nx+2,ny+2]);
state.b2stbc_sne   = read_rfield(fid,'b2stbc_sne'  ,[nx+2,ny+2]);
state.b2stbm_sna   = read_rfield(fid,'b2stbm_sna'  ,[nx+2,ny+2,ns]);
state.b2stbm_smo   = read_rfield(fid,'b2stbm_smo'  ,[nx+2,ny+2,ns]);
state.b2stbm_she   = read_rfield(fid,'b2stbm_she'  ,[nx+2,ny+2]);
state.b2stbm_shi   = read_rfield(fid,'b2stbm_shi'  ,[nx+2,ny+2]);
state.b2stbm_sch   = read_rfield(fid,'b2stbm_sch'  ,[nx+2,ny+2]);
state.b2stbm_sne   = read_rfield(fid,'b2stbm_sne'  ,[nx+2,ny+2]);
state.b2sihs_divue = read_rfield(fid,'b2sihs_divue',[nx+2,ny+2]);
state.b2sihs_divua = read_rfield(fid,'b2sihs_divua',[nx+2,ny+2]);
state.b2sihs_exbe  = read_rfield(fid,'b2sihs_exbe' ,[nx+2,ny+2]);
state.b2sihs_exba  = read_rfield(fid,'b2sihs_exba' ,[nx+2,ny+2]);
state.b2sihs_visa  = read_rfield(fid,'b2sihs_visa' ,[nx+2,ny+2]);
state.b2sihs_joule = read_rfield(fid,'b2sihs_joule',[nx+2,ny+2]);
state.b2sihs_fraa  = read_rfield(fid,'b2sihs_fraa' ,[nx+2,ny+2]);
state.b2sihs_str   = read_rfield(fid,'b2sihs_str ' ,[nx+2,ny+2]);
state.b2npmo_smaf  = read_rfield(fid,'b2npmo_smaf' ,[nx+2,ny+2,4,ns]);
state.b2npmo_smag  = read_rfield(fid,'b2npmo_smag' ,[nx+2,ny+2,4,ns]);
state.b2npmo_smav  = read_rfield(fid,'b2npmo_smav' ,[nx+2,ny+2,4,ns]);
state.smpr         = read_rfield(fid,'smpr'        ,[nx+2,ny+2,ns]);
state.smpt         = read_rfield(fid,'smpt'        ,[nx+2,ny+2,ns]);
state.smfr         = read_rfield(fid,'smfr'        ,[nx+2,ny+2,ns]);
state.smcf         = read_rfield(fid,'smcf'        ,[nx+2,ny+2,ns]);
state.ext_sna      = read_rfield(fid,'ext_sna'     ,[nx+2,ny+2,ns]);
state.ext_smo      = read_rfield(fid,'ext_smo'     ,[nx+2,ny+2,ns]);
state.ext_she      = read_rfield(fid,'ext_she'     ,[nx+2,ny+2]);
state.ext_shi      = read_rfield(fid,'ext_shi'     ,[nx+2,ny+2]);
state.ext_sch      = read_rfield(fid,'ext_sch'     ,[nx+2,ny+2]);
state.ext_sne      = read_rfield(fid,'ext_sne'     ,[nx+2,ny+2]);
state.calf         = read_rfield(fid,'calf'        ,fluxdim);
state.cdna         = read_rfield(fid,'cdna'        ,fluxdims);
state.cdpa         = read_rfield(fid,'cdpa'        ,fluxdims);
state.ceqp         = read_rfield(fid,'ceqp'        ,[nx+2,ny+2]);
state.chce         = read_rfield(fid,'chce'        ,fluxdim);
state.chci         = read_rfield(fid,'chci'        ,fluxdim);
state.chve         = read_rfield(fid,'chve'        ,fluxdim);
state.chvemx       = read_rfield(fid,'chvemx'      ,[nx+2,ny+2]);
state.chvi         = read_rfield(fid,'chvi'        ,fluxdim);
state.chvimx       = read_rfield(fid,'chvimx'      ,[nx+2,ny+2]);
state.csig         = read_rfield(fid,'csig'        ,fluxdim);
state.cvla         = read_rfield(fid,'cvla'        ,fluxdims);
state.cvsa         = read_rfield(fid,'cvsa'        ,fluxdims);
state.cthe         = read_rfield(fid,'cthe'        ,[nx+2,ny+2,ns]);
state.cthi         = read_rfield(fid,'cthi'        ,[nx+2,ny+2,ns]);
state.csigin       = read_rfield(fid,'csigin'      ,[fluxdims,ns]);
state.cvsa_cl      = read_rfield(fid,'cvsa_cl'     ,fluxdims);
state.fllime       = read_rfield(fid,'fllime'      ,[nx+2,ny+2]);
state.fllimi       = read_rfield(fid,'fllimi'      ,[nx+2,ny+2]);
state.fllim0fna    = read_rfield(fid,'fllim0fna'   ,fluxdims);
state.fllim0fhi    = read_rfield(fid,'fllim0fhi'   ,fluxdims);
state.fllimvisc    = read_rfield(fid,'fllimvisc'   ,[nx+2,ny+2,ns]);
state.sig0         = read_rfield(fid,'sig0'        ,[nx+2,ny+2]);
state.hce0         = read_rfield(fid,'hce0'        ,[nx+2,ny+2]);
state.alf0         = read_rfield(fid,'alf0'        ,[nx+2,ny+2]);
state.hci0         = read_rfield(fid,'hci0'        ,[nx+2,ny+2]);
state.hcib         = read_rfield(fid,'hcib'        ,[nx+2,ny+2,ns]);
state.dpa0         = read_rfield(fid,'dpa0'        ,[nx+2,ny+2,ns]);
state.dna0         = read_rfield(fid,'dna0'        ,[nx+2,ny+2,ns]);
state.vsa0         = read_rfield(fid,'vsa0'        ,[nx+2,ny+2,ns]);
state.vla0         = read_rfield(fid,'vla0'        ,[nx+2,ny+2,2,ns]);
state.csig_an      = read_rfield(fid,'csig_an'     ,fluxdim);
state.calf_an      = read_rfield(fid,'calf_an'     ,fluxdim);
nstra              = read_ifield(fid,'nstra'       ,[1]);
state.sclstra      = read_rfield(fid,'sclstra'     ,[ns+1,nstra]);
state.sclrtio      = read_rfield(fid,'sclrtio'     ,[ns+1,nstra]);

fclose(fid);
