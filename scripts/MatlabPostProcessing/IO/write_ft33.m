function write_ft33(file,nodes)
% write_ft33(file,nodes)
%
% Write fort.33-files (triangle nodes). Converts to EIRENE units (cm).
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file,'wt');
if (fid == -1)
   error(msg);
end

disp('write_ft33: assuming ntrfrm = 0.');
ntrfrm = 0;


% Convert to cm
nodes = nodes*1e2;

%% Write data

% number of nodes
fprintf(fid,'%12d\n',size(nodes,1));

% actual data
switch ntrfrm
    
    case 0
        
        % Messy fix for format...
        nodes = nodes*10;
        
        % Print the data to string, change format to have leading 0
        sfield = sprintf('%18.7E%18.7E%18.7E%18.7E\n',nodes(:,1));
        sfield = strrep(sfield,'0.','0.');
        sfield = strrep(sfield,'1.','0.1');
        sfield = strrep(sfield,'2.','0.2');
        sfield = strrep(sfield,'3.','0.3');
        sfield = strrep(sfield,'4.','0.4');
        sfield = strrep(sfield,'5.','0.5');
        sfield = strrep(sfield,'6.','0.6');
        sfield = strrep(sfield,'7.','0.7');
        sfield = strrep(sfield,'8.','0.8');
        sfield = strrep(sfield,'9.','0.9');
        
        % Print to file, making sure there is only a single newline character
        % to avoid a blank line in the output
        if strcmp(sfield(end),sprintf('\n'))
            sfield = sfield(1:end-1);
        end
        fprintf(fid,'%s\n',sfield);
        
        % Print the data to string, change format to have leading 0
        sfield = sprintf('%18.7E%18.7E%18.7E%18.7E\n',nodes(:,2));
        sfield = strrep(sfield,'0.','0.0');
        sfield = strrep(sfield,'1.','0.1');
        sfield = strrep(sfield,'2.','0.2');
        sfield = strrep(sfield,'3.','0.3');
        sfield = strrep(sfield,'4.','0.4');
        sfield = strrep(sfield,'5.','0.5');
        sfield = strrep(sfield,'6.','0.6');
        sfield = strrep(sfield,'7.','0.7');
        sfield = strrep(sfield,'8.','0.8');
        sfield = strrep(sfield,'9.','0.9');
        
        % Print to file, making sure there is only a single newline character
        % to avoid a blank line in the output
        if strcmp(sfield(end),sprintf('\n'))
            sfield = sfield(1:end-1);
        end
        fprintf(fid,'%s\n',sfield);
        
    otherwise
        
        error('write_ft33: wrong ntrfrm.');
        
end


% Close file
fclose(fid);

end
