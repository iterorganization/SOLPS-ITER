function writerzpsi(file,fieldfunction)
%
% writerzpsi(file, fieldfunction)
%
% This functions writes a rzpsi file from matlab structure fieldfunction
% containing these data, in this case being matrices filled with the
% R and Z axis values and for each of the grid points the magnetic flux
% function values.
%
% As input the file name should be given + the fieldfunction.
%

[fid,msg] = fopen(file,'wt');
if (fid == -1)
   error(msg);
end

% Write dimension header
% (Not present in all versions it seems; to be checked!)
nR   = length(fieldfunction.R);
nZ   = length(fieldfunction.Z);
fprintf(fid,'\n%5d %5d\n',[nR, nZ]);

% Write R-coordinates
fprintf(fid,' $r\n');
fprintf(fid,' nr=%4d\n',nR);

% Print the coordinates to string
sfield = sprintf('  %12.5E %12.5E %12.5E %12.5E %12.5E %12.5E\n',fieldfunction.R);

% Print to file, making sure there is only a single newline character
% to avoid a blank line in the output
if strcmp(sfield(end),sprintf('\n'))
    sfield = sfield(1:end-1);
end
fprintf(fid,'%s\n',sfield);


% Write Z-coordinates
fprintf(fid,' $z\n');
fprintf(fid,' nz=%4d\n',nZ);

% Print the coordinates to string
sfield = sprintf('  %12.5E %12.5E %12.5E %12.5E %12.5E %12.5E\n',fieldfunction.Z);

% Print to file, making sure there is only a single newline character
% to avoid a blank line in the output
if strcmp(sfield(end),sprintf('\n'))
    sfield = sfield(1:end-1);
end
fprintf(fid,'%s\n',sfield);


% Write Psi-function
fprintf(fid,'\n $psi\n');

% Print the coordinates to string
sfield = sprintf('  %12.5E %12.5E %12.5E %12.5E %12.5E %12.5E\n',fieldfunction.Psi);

% Print to file, making sure there is only a single newline character
% to avoid a blank line in the output
if strcmp(sfield(end),sprintf('\n'))
    sfield = sfield(1:end-1);
end
fprintf(fid,'%s\n',sfield);

%
% line = fgetl(fid);
% while ~contains(line,'nr=')
%     line = fgetl(fid);
%     if line == -1
%         error(['EOF reached without finding nr=.']);
%     end
% end
% nR0 = strread(line,'%*s%d');
% if nR ~= nR0
%     error('readrzpsi: inconsistent specification of nR.');
% end
% R=fscanf(fid, '%f',nR);
%
% % Read Z-coordinates
% line = fgetl(fid);
% while ~contains(line,'nz=')
%     line = fgetl(fid);
%     if line == -1
%         error(['EOF reached without finding nz=.']);
%     end
% end
% nZ0 = strread(line,'%*s %d');
% if nZ ~= nZ0
%     error('readrzpsi: inconsistent specification of nZ.');
% end
% Z=fscanf(fid, '%f',nZ);
%
% % Read Psi function
% Psi=zeros(nR,nZ);
% %in psi verandert de R index het eerst
% fscanf(fid, '%*s\n',1);
% Psi=(fscanf(fid, '%f',[nR,nZ]));
fclose(fid);

end

