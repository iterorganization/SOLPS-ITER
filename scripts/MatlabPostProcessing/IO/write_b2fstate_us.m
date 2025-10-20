function write_b2fstate_us(file,label,state)
% write_b2fstate_us(file,label,state)
%
% Write b2fstati/b2fstate file for use by B2.5.
%
% Input argument verions is optional. If not specified, will use default
% version = 03.000.000.
% 
% Notes: 
%  - routine does not do any consistency checking on the data (size of
%    the fields in state, etc.)
%  - routine will overwrite existing data if 'file' exists
% 

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file,'wt');
if (fid == -1)
   error(msg);
end

%% Write a version header

% Set default value for version, if not supplied
if isfield(state,'version')
    version = state.version;
else
    version = '03.002.001';
end

disp(['write_b2fstate -- file version ',version]);
VERSION = strcat('VERSION',version,' Matlab');
fprintf(fid,'%s\n',VERSION);


%% Write dimensions nCv, nFc, ns

nCv = size(state.na,1);
nFc = size(state.fna,1);
ns  = size(state.na,2);

write_ifield(fid,'nCv,nFc,ns',[nCv,nFc,ns]);


%% Write label

write_sfield(fid,'label',label);

%% Write charges etc.

write_rfield(fid,'zamin',state.zamin);
write_rfield(fid,'zamax',state.zamax);
write_rfield(fid,'zn   ',state.zn);
write_rfield(fid,'am   ',state.am);


%% Write state variables

write_rfield(fid,'na'    , state.na);
write_rfield(fid,'ne'    , state.ne);
write_rfield(fid,'ua'    , state.ua);
write_rfield(fid,'uadia' , state.uadia);
write_rfield(fid,'te'    , state.te);
write_rfield(fid,'ti'    , state.ti);
write_rfield(fid,'tn'    , state.tn);
write_rfield(fid,'po'    , state.po);
write_rfield(fid,'kt'    , state.kt);
write_rfield(fid,'zt'    , state.zt);

%% Write fluxes

write_rfield(fid,'fna'   ,state.fna);
write_rfield(fid,'fhe'   ,state.fhe);
write_rfield(fid,'fhi'   ,state.fhi);
write_rfield(fid,'fhn'   ,state.fhn);
write_rfield(fid,'fch'   ,state.fch);
write_rfield(fid,'fch_32',state.fch_32);
write_rfield(fid,'fch_52',state.fch_52);
write_rfield(fid,'kinrgy',state.kinrgy);
write_rfield(fid,'fhm' ,state.fhm);
write_rfield(fid,'fkt' ,state.fkt);
write_rfield(fid,'fzt' ,state.fzt);
write_rfield(fid,'time'  ,state.time);
write_rfield(fid,'fch_p' ,state.fch_p);

% Starting at version 03.000.005, a large number of additional fields
% was added to remove restart effect for 5.2 model equations (BCs)
write_rfield(fid,'fna_mdf'    ,state.fna_mdf);
write_rfield(fid,'fhe_mdf'    ,state.fhe_mdf);
write_rfield(fid,'fhi_mdf'    ,state.fhi_mdf);
write_rfield(fid,'fna_fcor'   ,state.fna_fcor);
write_rfield(fid,'fna_nodrift',state.fna_nodrift);
write_rfield(fid,'fna_he'     ,state.fna_he);
write_rfield(fid,'fnaPSch'    ,state.fnaPSch);
write_rfield(fid,'fhePSch'    ,state.fhePSch);
write_rfield(fid,'fhiPSch'    ,state.fhiPSch);
write_rfield(fid,'fna_eir'    ,state.fna_eir);
write_rfield(fid,'fne_eir'    ,state.fne_eir);
write_rfield(fid,'fhe_eir'    ,state.fhe_eir);
write_rfield(fid,'fhi_eir'    ,state.fhi_eir);
write_rfield(fid,'fna_32'     ,state.fna_32);
write_rfield(fid,'fna_52'     ,state.fna_52);
write_rfield(fid,'fni_32'     ,state.fni_32);
write_rfield(fid,'fni_52'     ,state.fni_52);
write_rfield(fid,'fne_32'     ,state.fne_32);
write_rfield(fid,'fne_52'     ,state.fne_52);
write_rfield(fid,'fchdia'     ,state.fchdia);
write_rfield(fid,'fchin'      ,state.fchin);
write_rfield(fid,'fchvispar'  ,state.fchvispar);
write_rfield(fid,'fchvisper'  ,state.fchvisper);
write_rfield(fid,'fchvisq'    ,state.fchvisq);
write_rfield(fid,'fchviskt'  ,state.fchviskt);
write_rfield(fid,'fchinert'   ,state.fchinert);

write_rfield(fid,'vaecrb' ,state.vaecrb);
write_rfield(fid,'vadia'  ,state.vadia);
write_rfield(fid,'wadia'  ,state.wadia);
write_rfield(fid,'veecrb' ,state.veecrb);
write_rfield(fid,'vedia'  ,state.vedia);

write_rfield(fid,'floe_noc' ,state.floe_noc);
write_rfield(fid,'floi_noc' ,state.floi_noc);


%% Close file

fclose(fid);

end
