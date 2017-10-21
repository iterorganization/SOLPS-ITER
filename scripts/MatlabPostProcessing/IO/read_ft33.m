function nodes = read_ft33(file)
% nodes = read_ft33(file)
%
% Read fort.33-files (triangle nodes). Converts to SI units (m).
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

disp('read_ft33: assuming ntrfrm = 0.');
ntrfrm = 0;


%% Read coordinates

% number of nodes
nnodes = fscanf(fid,'%d',1);
nodes  = zeros(nnodes,2);

switch ntrfrm
    
    case 0
        
        nodes(:,1) = fscanf(fid,'%f',nnodes);
        nodes(:,2) = fscanf(fid,'%f',nnodes);
        
    otherwise
        
        error('read_ft33: wrong ntrfrm.');
        
end

% Convert from cm to m
nodes = nodes*1e-2;

% close file
fclose(fid);