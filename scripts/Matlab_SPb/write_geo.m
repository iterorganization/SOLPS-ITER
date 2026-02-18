function write_geo(file,geo)
%%% This function writes .geo file.
% Input arguments:
% - file - full path to file
% - geo - geo structure
%%% end of description
% write_geo(file,geo)
%
% Write .geo file.
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Modified by Nikita Shtyrkhunov to read .geo file for wide grid meshes
% E-mail: shtirx@gmail.com
% October 2023

[fid,msg] = fopen(file,'wt');
if (fid == -1)
   error(msg);
end

% Determine dimensions
nx = size(geo.crxs,1);
ny = size(geo.crxs,2);

[~,git_hash_string] = system('git rev-parse HEAD');
% fprintf(fid,'VERSIONg%sm\n', git_hash_string(1:8));
fprintf(fid,'VERSION%s g%s %s\n', geo.version,git_hash_string(1:7),datetime('now'));
% Write dimensions nx, ny
fprintf(fid,'%3d %6d %6d %6d\n',[nx,ny, geo.var1, geo.var2]);

crxs = geo.crxs;
crys = geo.crys;
bp   = geo.bp;
bt   = geo.bt;
psi = geo.psi;
ffbz = geo.ffbz;
cflags = geo.cflags;

% Write data into file line by line
for j = 1:ny
    for i = 1:nx
        fprintf(fid,'%4d %4d ',[i j]);
        for ip=1:5
            line = [crxs(i,j,ip),crys(i,j,ip),psi(i,j,ip,1)];
            fprintf(fid,'%12.8f %12.8f %12.8f ',line);
            if ip>1
                line = [psi(i,j,ip,2), psi(i,j,ip,3), ffbz(i,j,ip-1)];
                fprintf(fid,'%12.8f %12.8f %12.8f ',line);
            end
        end
        line = [bp(i,j), bt(i,j)];
        fprintf(fid,'%12.8f %12.8f ',line);
        line = cflags(i,j,:);
        fprintf(fid,'%2d %2d %2d %2d %2d\n',line);
        % line = [i,j,crxs(i,j,1),crys(i,j,1), crxs(i,j,2),crys(i,j,2),crxs(i,j,3),crys(i,j,3),...
        %     crxs(i,j,4),crys(i,j,4),crxs(i,j,5),crys(i,j,5),bp(i,j),bt(i,j)];
        % fprintf(fid,'%4d %4d %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f\n',line);
    end
end

% Close file
fclose(fid);

end