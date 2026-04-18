function aver = read_b2favere_us(file)
% state = read_b2favere(file)
%
% Read b2faveri/b2favere file created by B2.5.
%
% Output is a struct "aver" with all the data fields in the 
% file.
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% February 2017

disp(['Attempting read_b2favere_us.'])


% Open file
[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

%% Read some integers
dim = read_ifield(fid,'nCv,ns',2);
nCv  = dim(1);
ns   = dim(2);


read_rfield(fid,'zamin',ns);
read_rfield(fid,'zamax',ns);
read_rfield(fid,'zn   ',ns);
read_rfield(fid,'am   ',ns);
aver.naver  = read_ifield(fid,'naver' ,1);
aver.ntotdt = read_ifield(fid,'ntotdt',1);
statedim  = [nCv,1];
statedims = [nCv,ns];

%% Read state variables

aver.na  = read_rfield(fid,'na_mean'    ,statedims);
aver.te  = read_rfield(fid,'te_mean'    ,statedim);
aver.ti  = read_rfield(fid,'ti_mean'    ,statedim);
aver.po  = read_rfield(fid,'po_mean'    ,statedim);
aver.ua  = read_rfield(fid,'ua_mean'    ,statedims);
aver.kt  = read_rfield(fid,'kt_mean'    ,statedim);


%% Read sources

aver.sna     = read_rfield(fid,'sna_mean'    ,[nCv,ns]);
%aver.sne     = read_rfield(fid,'sne_mean'    ,[nCv]);
aver.she     = read_rfield(fid,'she_mean'    ,[nCv]);
aver.shi     = read_rfield(fid,'shi_mean'    ,[nCv]);
%aver.sch     = read_rfield(fid,'sch_mean'    ,[nCv]);
aver.smo     = read_rfield(fid,'smo_mean'    ,[nCv,ns]);

%% Close file

fclose(fid);

disp(['Done read_b2favere_us with no errors.'])

end