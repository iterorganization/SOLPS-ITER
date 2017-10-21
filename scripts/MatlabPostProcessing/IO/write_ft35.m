function write_ft35(file,links)
% write_ft35(file,links)
%
% Write fort.35-files (triangle data). 
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
fprintf(fid,'%12d\n',size(links.nghbr,1));

% actual data
for i = 1:size(links.nghbr,1)
    fprintf(fid,'%6d %7d %5d %5d %9d %5d %5d %9d %5d %5d %9d %5d\n',...
        [i links.nghbr(i,1) links.side(i,1) links.cont(i,1) ...
           links.nghbr(i,2) links.side(i,2) links.cont(i,2) ...
           links.nghbr(i,3) links.side(i,3) links.cont(i,3) ...
           links.ixiy(i,1)  links.ixiy(i,2)]);
end
   
% Close file
fclose(fid);

end