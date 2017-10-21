function write_ft78(file,cont)
% write_ft78(file,cont)
%
% Write fort.78-files (contours for triang). 
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
fprintf(fid,'%19.14f\n\n',cont(1).tsize);

% actual data
for i = 1:length(cont)
    fprintf(fid,'%12d\n',length(cont(i).r));
    for j = 1:length(cont(i).r)
        fprintf(fid,'%23.14E %22.14E\n',...
            [1e2*cont(i).r(j), 1e2*cont(i).z(j)]);
    end
end

% Close file
fclose(fid);

end