function geo = read_geo(file)
% geo = read_geo(file)
%
% Read .geo file.
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

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

% Read nx, ny
if str2num(strrep(version,'.','')) >= str2num(strrep('01.001.028','.',''))
    dims = fscanf(fid,'%d',4);
else
    dims = fscanf(fid,'%d',2);
end
nx   = dims(1);
ny   = dims(2);

% Initialize output arrarys
crxs   = zeros(nx+2,ny+2,5);
crys   = zeros(nx+2,ny+2,5);
bp     = zeros(nx+2,ny+2);
bt     = zeros(nx+2,ny+2);
psi    = zeros(nx+2,ny+2,5,3);
ffbz   = zeros(nx+2,ny+2,4);
cflags = zeros(nx+2,ny+2,5);

% Scan file line by line
if str2num(strrep(version,'.','')) >= str2num(strrep('01.001.028','.',''))
    for j = 2:ny+1
        for i = 2:nx+1
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
    % Set cflags for default structured grid assumptions
    cflags(:,:,1) = 9;
    cflags(2:end-1,2:end-1,1) = 3;
    cflags(3:end-2,3:end-2,1) = 1;
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