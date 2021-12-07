function [ fieldfunction ] = readrzpsi(file)
% 
% [ fieldfunction ] = readrzpsi(file)
% 
% This functions reads a rzpsi file and generates matlab data
% files containing these data, in this case being matrices filled with the
% R and Z axis values and for each of the grid points the magnetic flux 
% function values.
% 
% As input the file name should be given
% Output is R,Z,Psi and dimensions
%

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

% Read dimension header
% (Not present in all versions it seems; to be checked!)
dims  = fscanf(fid,'%d',2);
nR   = dims(1);
nZ   = dims(2);

% Read R-coordinates
line = fgetl(fid);
while ~contains(line,'nr=')
    line = fgetl(fid);
    if line == -1
        error(['EOF reached without finding nr=.']);
    end
end
nR0 = strread(line,'%*s%d');
if nR ~= nR0
    error('readrzpsi: inconsistent specification of nR.');
end
R=fscanf(fid, '%f',nR);

% Read Z-coordinates
line = fgetl(fid);
while ~contains(line,'nz=')
    line = fgetl(fid);
    if line == -1
        error(['EOF reached without finding nz=.']);
    end
end
nZ0 = strread(line,'%*s %d');
if nZ ~= nZ0
    error('readrzpsi: inconsistent specification of nZ.');
end
Z=fscanf(fid, '%f',nZ);

% Read Psi function
Psi=zeros(nR,nZ);
%in psi verandert de R index het eerst
fscanf(fid, '%*s\n',1);
Psi=(fscanf(fid, '%f',[nR,nZ]));
fclose(fid);

% Store
fieldfunction.nR=nR;
fieldfunction.nZ=nZ;
fieldfunction.N=nR*nZ;
fieldfunction.R=R;
fieldfunction.Z=Z;
fieldfunction.Psi=Psi;
end

