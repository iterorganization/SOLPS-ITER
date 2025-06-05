function write_b2frates(file,rates)
% Write b2frates file for use by B2.5.
%
% Input argument verions is optional. If not specified, will use default
% version = 03.000.000.
% 
% Notes: 
%  - routine does not do any consistency checking on the data (size of
%    the fields in rates, etc.)
%  - routine will overwrite existing data if 'file' exists
% 

% Author: Stefano Carli
% E-mail: stefano.carli@kuleuven.be
% February 2022

[fid,msg] = fopen(file,'wt');
if (fid == -1)
   error(msg);
end

%% Write a version header

% Set default value for version, if not supplied
if isfield(rates,'version')
    version = rates.version;
else
    version = '03.002.000';
end

disp(['write_b2frates -- file version ',version]);
VERSION = strcat('VERSION',version,' Matlab');
fprintf(fid,'%s\n',VERSION);
%% Write label

write_sfield(fid,'label',rates.label);

%% Write dimensions

write_ifield(fid,'ppout',rates.ppout);
rtnt = rates.rtnt;
rtnn = rates.rtnn;
rtns = rates.rtns;
write_ifield(fid,'rtnt,rtnn,rtns',[rtnt,rtnn,rtns]);

%% Write charges etc.

write_rfield(fid,'rtzmin',rates.zamin);
write_rfield(fid,'rtzmax',rates.zamax);
write_rfield(fid,'rtzn   ',rates.zn);
write_rfield(fid,'rtt  ',rates.rtt);
write_rfield(fid,'rtn  ',rates.rtn);
write_rfield(fid,'rtlt ',rates.rtlt);
write_rfield(fid,'rtln ',rates.rtln);

%% Write rates variables

write_rfield(fid,'rtlsa'    , rates.rtlsa);
write_rfield(fid,'rtlra'    , rates.rtlra);
write_rfield(fid,'rtlqa'    , rates.rtlqa);
write_rfield(fid,'rtlqr'    , rates.rtlqr);
write_rfield(fid,'rtlcx'    , rates.rtlcx);
write_rfield(fid,'rtlrd'    , rates.rtlrd);
write_rfield(fid,'rtlbr'    , rates.rtlbr);
write_rfield(fid,'rtlza'    , rates.rtlza);
write_rfield(fid,'rtlz2'    , rates.rtlz2);
write_rfield(fid,'rtlpt'    , rates.rtlpt);
write_rfield(fid,'rtlpi'    , rates.rtlpi);

%% Write fix_recomb e zmax_recomb

write_ifield(fid,'fix_recomb,zmax_recomb',[rates.fix_recomb,rates.zmax_recomb]);

%% Close file

fclose(fid);

end
