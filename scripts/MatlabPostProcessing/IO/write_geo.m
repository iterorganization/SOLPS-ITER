function write_geo(file,geo,type)
% write_geo(file,geo,type)
%
% Write .geo file. % Adjusted by Sander Van den Kerkhof
% (sander.vandenkerkhof@kuleuven.be), March 2022, for CARRE2 .geo file.
% Default behavior is CARRE, but switch can be given to other formats using
% the new optional argument 'type', which should be a string.
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file,'wt');
if (fid == -1)
    error(msg);
end

% Perform checks
if nargin < 3
    type = 'carre';
end

% Check version, set to default if not supplied
if isfield(geo,'version')
    version = geo.version;
else
    version = '03.000.000';
end

% Determine dimensions
nx = size(geo.crxs,1) - 2;
ny = size(geo.crxs,2) - 2;

% Write output depending on type
switch type

    case 'carre'

        % Write dimensions nx, ny
        fprintf(fid,'%12d %14d\n',[nx,ny]);

        crxs = geo.crxs;
        crys = geo.crys;
        bp   = geo.bp;
        bt   = geo.bt;

        % Write data into file line by line
        for j = 1:ny+2
            for i = 1:nx+2
                line = [i-1,j-1,crxs(i,j,1),crys(i,j,1),crxs(i,j,2),crys(i,j,2),crxs(i,j,3),crys(i,j,3),...
                    crxs(i,j,4),crys(i,j,4),crxs(i,j,5),crys(i,j,5),bp(i,j),bt(i,j)];
                fprintf(fid,'%4d %4d %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f\n',line);
            end
        end

    case 'carre2'

        % Carre2 output style, with guard cells.

        % Write version
        disp(['write_geo -- file version ',version]);
        VERSION = strcat('VERSION',version,' Matlab');
        fprintf(fid,'%s\n',VERSION);

        % Write dimensions nx, ny
        fprintf(fid,'%4d %4d %4d %d\n',[nx,ny,0,0]); % no idea for the zeros

        crxs    = geo.crxs;
        crys    = geo.crys;
        psi     = geo.psi;
        cflags  = geo.cflags;
        bp      = geo.bp;
        bt      = geo.bt;
        ffbz    = geo.ffbz;

        % Write data into file line by line
        for j = 1:ny+2
            for i = 1:nx+2
                line = [i-1 j-1 ...
                    crxs(i,j,1)     crys(i,j,1)     psi(i,j,1,1) ...
                    crxs(i,j,2)     crys(i,j,2)     psi(i,j,2,1)    psi(i,j,2,2)    psi(i,j,2,3)    ffbz(i,j,1) ...
                    crxs(i,j,3)     crys(i,j,3)     psi(i,j,3,1)    psi(i,j,3,2)    psi(i,j,3,3)    ffbz(i,j,2) ...
                    crxs(i,j,4)     crys(i,j,4)     psi(i,j,4,1)    psi(i,j,4,2)    psi(i,j,4,3)    ffbz(i,j,3) ...
                    crxs(i,j,5)     crys(i,j,5)     psi(i,j,5,1)    psi(i,j,5,2)    psi(i,j,5,3)    ffbz(i,j,4) ...
                    bp(i,j)         bt(i,j) ...
                    cflags(i,j,1)   cflags(i,j,2)   cflags(i,j,3)   cflags(i,j,4)   cflags(i,j,5)];

                fprintf(fid,['%4d %4d %12.8f %12.8f %12.8f %12.8f %12.8f' ...
                    '%12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f'...
                    '%12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f'...
                    '%12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f'...
                    '%4d %4d %4d %4d %4d\n'],line);

            end
        end

    case 'carre2_nogc'

        % Carre2 output style, without guard cells. Note: it is still
        % assumed that the arrays that are parsed are nx+2-by-nx+2, i.e.
        % including guard cells!

        % Write version
        disp(['write_geo -- file version ',version]);
        VERSION = strcat('VERSION',version,' Matlab');
        fprintf(fid,'%s\n',VERSION);

        % Write dimensions nx, ny
        fprintf(fid,'%4d %4d %4d %d\n',[nx,ny,0,0]); % no idea for the zeros

        crxs    = geo.crxs;
        crys    = geo.crys;
        psi     = geo.psi;
        cflags  = geo.cflags;
        bp      = geo.bp;
        bt      = geo.bt;
        ffbz    = geo.ffbz;

        % Write data into file line by line
        for j = 2:ny+1 % write only physical cell data, no guard cells
            for i = 2:nx+1
                line = [i-1 j-1 ...
                    crxs(i,j,1)     crys(i,j,1)     psi(i,j,1,1) ...
                    crxs(i,j,2)     crys(i,j,2)     psi(i,j,2,1)    psi(i,j,2,2)    psi(i,j,2,3)    ffbz(i,j,1) ...
                    crxs(i,j,3)     crys(i,j,3)     psi(i,j,3,1)    psi(i,j,3,2)    psi(i,j,3,3)    ffbz(i,j,2) ...
                    crxs(i,j,4)     crys(i,j,4)     psi(i,j,4,1)    psi(i,j,4,2)    psi(i,j,4,3)    ffbz(i,j,3) ...
                    crxs(i,j,5)     crys(i,j,5)     psi(i,j,5,1)    psi(i,j,5,2)    psi(i,j,5,3)    ffbz(i,j,4) ...
                    bp(i,j)         bt(i,j) ...
                    cflags(i,j,1)   cflags(i,j,2)   cflags(i,j,3)   cflags(i,j,4)   cflags(i,j,5)];

                fprintf(fid,['%4d %4d %12.8f %12.8f %12.8f %12.8f %12.8f ' ...
                    '%12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f '...
                    '%12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f '...
                    '%12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f '...
                    '%4d %4d %4d %4d %4d\n'],line);

            end
        end

    otherwise

        error(strcat('write_geo: unknown format ',type))

end

% Close file
fclose(fid);

end
