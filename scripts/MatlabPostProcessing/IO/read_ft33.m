function nodes = read_ft33(file,ntrfrm)
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


if ~exist('ntrfrm','var') || isempty(ntrfrm)
    disp('read_ft33: assuming ntrfrm = 0.');
    ntrfrm = 0;
end


%% Read coordinates

% number of nodes
nnodes = fscanf(fid,'%d',1);
nodes  = zeros(nnodes,2);

switch ntrfrm
    
    case 0
        
        nodes(:,1) = fscanf(fid,'%f',nnodes);
        nodes(:,2) = fscanf(fid,'%f',nnodes);
    
    case 1
        
        for i = 1:nnodes
            
            data = fscanf(fid,'%f',3);
            nodes(i,1) = data(2);
            nodes(i,2) = data(3);
            
        end
        
    otherwise
        
        error('read_ft33: wrong ntrfrm.');
        
end

% Convert from cm to m
nodes = nodes*1e-2;

% close file
fclose(fid);