function write_ogr(file,ogr)
% write_ogr(file,ogr)
%
% Write *.ogr-file, typically templates for DG.
%
% ogr is a structure of length n, with n the number of polygon segments,
% and ogr(i).r, ogr(i).z the r and z coordinates of polygon segment i,
% respectively.
%
% Note: *.ogr-files contain coordinates in mm. The routine will
% automatically convert to mm, but assumes input is in m.
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file,'wt');
if (fid == -1)
   error(msg);
end

% In the ogr-file, polygons are separated by blank lines, and number of
% points per polygon not specied
for i = 1:length(ogr)
    
    % Convert to mm
    ogr(i).r = ogr(i).r*1000;
    ogr(i).z = ogr(i).z*1000;
    
    % Print coordinates
    for j = 1:length(ogr(i).r)
        fprintf(fid,'%12.4f %12.4f\n',[ogr(i).r(j),ogr(i).z(j)]);
    end
    
    % If not last polygon, print blank line
    if i < length(ogr)
        fprintf(fid,'\n');
    end
end
   
% Close file
fclose(fid);

end