function rates = read_b2frates(file,ns)
% state = read_b2fstate(file)
%
% Read b2frates file created by B2.5.
%
% Output is a struct "rates" with all the data fields in the b2frates
% file (except for the dimensions nx,ny,ns, which are implicit in the array
% sizes).
%

% Author: Stefano Carli
% E-mail: stefano.carli@kuleuven.be
% February 2022 


% Open file
[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end


%% Get version of the b2fstate file

line    = fgetl(fid);
version = line(8:17);

disp(['read_b2frates -- file version ',version]);
rates.version = version;
%% get label --> for b2frates this is necessary for ppout!
line    = fgetl(fid);
line    = fgetl(fid);
rates.label = line(2:120);

%% Read dimensions

dim = read_ifield(fid,'ppout',ns);
rates.ppout= dim;

dim = read_ifield(fid,'rtnt,rtnn,rtns',3);
rates.rtnt = dim(1);
rates.rtnn = dim(2);
rates.rtns = dim(3);

ratdims = [rates.rtnt+1,rates.rtnn+1,rates.rtns];

%% Read charges etc.

rates.zamin = read_rfield(fid,'rtzmin',ns);
rates.zamax = read_rfield(fid,'rtzmax',ns);
rates.zn    = read_rfield(fid,'rtzn   ',ns);
rates.rtt    = read_rfield(fid,'rtt   ',rates.rtnt+1);
rates.rtn    = read_rfield(fid,'rtn   ',rates.rtnn+1);
rates.rtlt    = read_rfield(fid,'rtlt   ',rates.rtnt+1);
rates.rtln    = read_rfield(fid,'rtln   ',rates.rtnn+1);
%% Read state variables

rates.rtlsa     = read_rfield(fid,'rtlsa'    ,ratdims);
rates.rtlra     = read_rfield(fid,'rtlra'    ,ratdims);
rates.rtlqa     = read_rfield(fid,'rtlqa'    ,ratdims);
rates.rtlqr     = read_rfield(fid,'rtlqr'    ,ratdims);
rates.rtlcx     = read_rfield(fid,'rtlcx'    ,ratdims);
rates.rtlrd     = read_rfield(fid,'rtlrd'    ,ratdims);
rates.rtlbr     = read_rfield(fid,'rtlbr'    ,ratdims);
rates.rtlza     = read_rfield(fid,'rtlza'    ,ratdims);
rates.rtlz2     = read_rfield(fid,'rtlz2'    ,ratdims);
rates.rtlpt     = read_rfield(fid,'rtlpt'    ,ratdims);
rates.rtlpi     = read_rfield(fid,'rtlpi'    ,ratdims);

%% extra
dim = read_ifield(fid,'fix_recomb,zmax_recomb',2);
rates.fix_recomb = dim(1);
rates.zmax_recomb = dim(1);

%% Close file

fclose(fid);