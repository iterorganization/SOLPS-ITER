function aver = read_b2favere_st(file)
% state = read_b2favere(file,nx,ny,ns)
%
% Read b2faveri/b2favere file created by B2.5.
%
% Output is a struct "aver" with all the data fields in the 
% file.
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% February 2017

disp(['Attempting read_b2favere_st.'])


% Open file
[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

%% Read dimensions nx, ny, ns

dim = read_ifield(fid,'nx,ny,ns',3);
nx  = dim(1);
ny  = dim(2);
ns  = dim(3);

%% Read some integers

aver.naver  = read_ifield(fid,'naver' ,1);
aver.ntotdt = read_ifield(fid,'ntotdt',1);


%% Read state variables

aver.na  = read_rfield(fid,'na_mean'    ,[nx+2,ny+2,ns]);
aver.te  = read_rfield(fid,'te_mean'    ,[nx+2,ny+2]);
aver.ti  = read_rfield(fid,'ti_mean'    ,[nx+2,ny+2]);
aver.po  = read_rfield(fid,'po_mean'    ,[nx+2,ny+2]);
aver.ua  = read_rfield(fid,'ua_mean'    ,[nx+2,ny+2,ns]);


%% Read sources

aver.sna     = read_rfield(fid,'sna_mean'    ,[nx+2,ny+2,2,ns]);
aver.sne     = read_rfield(fid,'sne_mean'    ,[nx+2,ny+2,2]);
aver.she     = read_rfield(fid,'she_mean'    ,[nx+2,ny+2,4]);
aver.shi     = read_rfield(fid,'shi_mean'    ,[nx+2,ny+2,4]);
aver.sch     = read_rfield(fid,'sch_mean'    ,[nx+2,ny+2,4]);
aver.smo     = read_rfield(fid,'smo_mean'    ,[nx+2,ny+2,4,ns]);


%% Close file

fclose(fid);

disp(['Done read_b2favere_st with no errors.'])

end