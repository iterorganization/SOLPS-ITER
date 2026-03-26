function geo = read_geo(file)
% geo = read_geo(file)
%
% Read .geo file.
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Modified by Nikita Shtyrkhunov to read .geo file for wide grid meshes
% E-mail: shtirx@gmail.com
% October 2023

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

% Check whether version is available from file
line    = fgetl(fid);
if (line(1:7) == 'VERSION')
    version = line(8:17);
else
    version = '00.000.000';
    frewind(fid);
end

disp(['read_geo -- file version ',version]);

geo.version = [version ' fixed'];

% Read nx, ny
dims = fscanf(fid,'%d',4);
nx   = dims(1);
ny   = dims(2);
geo.nx = nx; geo.ny = ny;
geo.var1 = dims(3);
geo.var2 = dims(4);

% Initialize output arrarys
crxs   = zeros(nx,ny,5);
crys   = zeros(nx,ny,5);
bp     = zeros(nx,ny);
bt     = zeros(nx,ny);
psi    = zeros(nx,ny,5,3);
ffbz   = zeros(nx,ny,4);
cflags = zeros(nx,ny,5);

% Scan file line by line
if str2num(strrep(version,'.','')) >= str2num(strrep('01.001.028','.',''))
    for j = 1:ny
        for i = 1:nx
            line = fscanf(fid,'%d %d %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %d %d %d %d %d',36);
            crxs(i,j,1) = line(3);  crys(i,j,1) = line(4);   psi(i,j,1,1) = line(5);
            crxs(i,j,2) = line(6);  crys(i,j,2) = line(7);   psi(i,j,2,1) = line(8);  psi(i,j,2,2) = line(9);  psi(i,j,2,3) = line(10); ffbz(i,j,1) = line(11);
            crxs(i,j,3) = line(12); crys(i,j,3) = line(13);  psi(i,j,3,1) = line(14); psi(i,j,3,2) = line(15); psi(i,j,3,3) = line(16); ffbz(i,j,2) = line(17);
            crxs(i,j,4) = line(18); crys(i,j,4) = line(19);  psi(i,j,4,1) = line(20); psi(i,j,4,2) = line(21); psi(i,j,4,3) = line(22); ffbz(i,j,3) = line(23);
            crxs(i,j,5) = line(24); crys(i,j,5) = line(25);  psi(i,j,5,1) = line(26); psi(i,j,5,2) = line(27); psi(i,j,5,3) = line(28); ffbz(i,j,4) = line(29);
            bp(i,j)     = line(30); bt(i,j)     = line(31);
            cflags(i,j,1) = line(32); cflags(i,j,2) = line(33); cflags(i,j,3) = line(34); cflags(i,j,4) = line(35); cflags(i,j,5) = line(36);
        end
    end
else
    for j = 1:ny+2
        for i = 1:nx+2
            line = fscanf(fid,'%d %d %f %f %f %f %f %f %f %f %f %f %f %f',14);
            crxs(i,j,1) = line(3);  crys(i,j,1) = line(4);
            crxs(i,j,2) = line(5);  crys(i,j,2) = line(6);
            crxs(i,j,3) = line(7);  crys(i,j,3) = line(8);
            crxs(i,j,4) = line(9);  crys(i,j,4) = line(10);
            crxs(i,j,5) = line(11); crys(i,j,5) = line(12);
            bp(i,j)     = line(13); bt(i,j)     = line(14);
            
            
        end
    end
end

% Store in struct
geo.crxs = crxs;
geo.crys = crys;
geo.bp   = bp;
geo.bt   = bt;
geo.psi  = psi;
geo.ffbz = ffbz;
geo.cflags = cflags;

% Close file
fclose(fid);