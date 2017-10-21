function write_ft34(file,cells)
% write_ft34(file,cells)
%
% Write fort.34-files (nodes composing each triangle). 
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file,'wt');
if (fid == -1)
   error(msg);
end


%% Write data

% number of triangels
fprintf(fid,'%12d\n',size(cells,1));

% actual data
for i = 1:size(cells,1)
    fprintf(fid,'%6d %7d %5d %5d\n',[i cells(i,:)]);
end
   
% Close file
fclose(fid);

end