function ogr = read_ogr(file)
% ogr = read_ogr(file)
%
% Read *.ogr-file, typically templates for DG.
%
% Note: *.ogr-files typically contain coordinates in mm. The routine will
% automatically convert to m.
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Open file
[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

% Init structure
ogr = struct('r',{},'z',{});

% In the ogr-file, polygons are separated by blank lines, and number of
% points per polygon not specied
line = fgetl(fid);
i    = 0;
while line ~= -1
    
    coords = [];
    while (length(line) > 1) & (line ~= -1) % scan until next blank line (or EOF)
        point  = textscan(line,'%f',2);
        coords = [coords;point{:}'];
        line = fgetl(fid);
    end

    % Store this polygon in ogr
    i = i+1;    
    ogr(i).r   = coords(:,1)*0.001; % Convert to m
    ogr(i).z   = coords(:,2)*0.001; % Convert to m
    
    % Read next line
    line = fgetl(fid);
end

