function cells = read_ft34(file)
% cells = read_ft34(file)
%
% Read fort.34-files (nodes composing each triangle). 
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end



%% Read data

% number of triangels
ntria = fscanf(fid,'%d',1);

cells = zeros(ntria,3);

for i = 1:ntria
    data = fscanf(fid,'%d',4);
    cells(i,:) = data(2:end);
end

% close file
fclose(fid);