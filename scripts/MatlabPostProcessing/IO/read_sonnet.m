function sonnet = read_sonnet(file)
% sonnet = read_sonnet(file)
%
% Read .sonnet file.
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

% Scan until first line with = sign is found (R*Btor)
line = fgetl(fid);
while isempty(strfind(line,'='))
    line = fgetl(fid);
    if line1 == -1
        error('read_sonnet: EOF reached.');
    end
end    

if ~isempty(strfind(line,'R*Btor'))
    i = strfind(line,'=');
    sonnet.RBtor = strread(line(i+1:end),'%f');
else
    error('read_sonnet: R*Btor not found.');
end

% Scan for dimensions nx and ny
line = fgetl(fid);
if ~isempty(strfind(line,'nx'))
    i = strfind(line,'=');
    sonnet.nx = strread(line(i+1:end),'%d');
else
    error('read_sonnet: nx not found.');
end

line = fgetl(fid);
if ~isempty(strfind(line,'ny'))
    i = strfind(line,'=');
    sonnet.ny = strread(line(i+1:end),'%d');
else
    error('read_sonnet: ny not found.');
end

% Scan for cuts
line = fgetl(fid);
if ~isempty(strfind(line,'ncut'))
    i = strfind(line,'=');
    sonnet.ncut = strread(line(i+1:end),'%d');
else
    error('read_sonnet: ncut not found.');
end
for i = 1:sonnet.ncut
    % Read nxcut, nycut
    line = fgetl(fid);
    if ~isempty(strfind(line,'nxcut'))
        i = strfind(line,'=');
        sonnet.nxcut = strread(line(i+1:end),'%d', sonnet.ncut);
    else
        error('read_sonnet: nxcut not found.');
    end
    
    line = fgetl(fid);
    if ~isempty(strfind(line,'nycut'))
        i = strfind(line,'=');
        sonnet.nycut = strread(line(i+1:end),'%d', sonnet.ncut);
    else
        error('read_sonnet: nycut not found.');
    end
end

% Scan for isolations
line = fgetl(fid);
if ~isempty(strfind(line,'niso'))
    i = strfind(line,'=');
    sonnet.niso = strread(line(i+1:end),'%d');
else
    sonnet.niso = 0;
end
if sonnet.niso > 0
    error('read_sonnet: niso > 0.');
end


% Initialize output arrarys
crxs = zeros(sonnet.nx+2,sonnet.ny+2,5);
crys = zeros(sonnet.nx+2,sonnet.ny+2,5);
pit  = zeros(sonnet.nx+2,sonnet.ny+2);

% To be written...


sonnet.crxs = crxs;
sonnet.crys = crys;
sonnet.pit  = pit;

% % % 
% % % % Scan file line by line
% % % for j = 1:sonnet.ny+2
% % %     for i = 1:sonnet.nx+2
% % %         line = fscanf(fid,'%d %d %f %f %f %f %f %f %f %f %f %f %f %f',14);
% % %         crxs(i,j,1) = line(3);  crys(i,j,1) = line(4);
% % %         crxs(i,j,2) = line(5);  crys(i,j,2) = line(6);
% % %         crxs(i,j,3) = line(7);  crys(i,j,3) = line(8);
% % %         crxs(i,j,4) = line(9);  crys(i,j,4) = line(10);
% % %         crxs(i,j,5) = line(11); crys(i,j,5) = line(12);
% % %         bp(i,j)     = line(13); bt(i,j)     = line(14);
% % %     end
% % % end
% % % 
% % % % Store in struct
% % % sonnet.crxs = crxs;
% % % sonnet.crys = crys;
% % % sonnet.bp   = bp;
% % % sonnet.bt   = bt;
% % % 
% % % 
% % % % Close file
% % % fclose(fid);