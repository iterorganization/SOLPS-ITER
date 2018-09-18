%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script is a part of Compare_B2.m script
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%  Purpose is to read and plot some data from ANK tracing
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%

N_rec_trc = 41 % This constant is specific for D+N cases

%
% 30 types of line are prescribed
SYMBOL={'-o' '-s' '-*' '-h' '-^' '->' '-<' '-v' '-+' '-o' '-s' '-*' '-h' '-^' '->' '-<' '-v' '-+' '-o' '-s' '-*' '-h' '-^' '->' '-<' '-v' '-o' '-s' '-*' '-h' '-^' '->' '-<' '-v'};
COLOUR={[1,0,0] [0,0,1] [0.45,0.1,0.05] [0.75,0.2,0.15] [0.15,0.05,0.5] [0.25,0.5,0.25] [1,0.6,0] [1,0.05,0.75] ...
    [0.5,0.5,1] [0.0,0.5,1] [0.5,0.1,0] [0.6,0.05,0.4] [0.35,0.65,0.15] [0.8,0.2,0.8] [0.2,0.2,0.5] [0.4,0.4,0.55] ...
    [0.5,0.5,0.5] [0.2,0.8,0.2] [0.3,0.7,0.3] [0.3,0.9,0.1] [0,1,0] [0.25,0.25,0.85] [0.85,0.2,0.2] [0.3,0,0.9] [0.75,0.75,0.05] ...
    [0.9,0.2,0.2] [0.2,0.9,0.9] [0.15,0.9,0.15] [0.2,0.15,0.9] [0.2,0.2,0.65]};

size_of_trc = zeros(1,Nresults);

for m=1:Nresults
    
    PATH_to_trc = [PATH_PREFIX{m} '/../blnn.trc'];
    fileID=fopen(PATH_to_trc)
    tline1=fgetl(fileID);
    tline2=fgetl(fileID);
    [A,count]=fscanf(fileID,'%41f');
    size_of_trc(m)=count / N_rec_trc
    clear A;
    clear tline1;
    clear tline2;
end;

trc_time = zeros(max(size_of_trc)+1,Nresults);
trc_Ncore = zeros(max(size_of_trc)+1,Nresults);
trc_Ntot = zeros(max(size_of_trc)+1,Nresults);
trc_Dcore = zeros(max(size_of_trc)+1,Nresults);
trc_Dtot = zeros(max(size_of_trc)+1,Nresults);
trc_Nbln = zeros(max(size_of_trc)+1,Nresults);
trc_Dbln = zeros(max(size_of_trc)+1,Nresults);

for m=1:Nresults
    
    PATH_to_trc = [PATH_PREFIX{m} '/../blnn.trc'];
    trc_time(1:size_of_trc(m),m)=dlmread(PATH_to_trc,'',[2 0 size_of_trc(m)+1 0]);
    
    trc_Dcore(1:size_of_trc(m),m)=dlmread(PATH_to_trc','',[2 1 size_of_trc(m)+1 1]);
    trc_Dtot(1:size_of_trc(m),m)=dlmread(PATH_to_trc,'',[2 9 size_of_trc(m)+1 9]);
    
    trc_Ncore(1:size_of_trc(m),m)=dlmread(PATH_to_trc,'',[2 21 size_of_trc(m)+1 21]);
    trc_Ntot(1:size_of_trc(m),m)=dlmread(PATH_to_trc,'',[2 29 size_of_trc(m)+1 29]);

    trc_Dbln(1:size_of_trc(m),m)=dlmread(PATH_to_trc,'',[2 16 size_of_trc(m)+1 16]);
    trc_Nbln(1:size_of_trc(m),m)=dlmread(PATH_to_trc,'',[2 36 size_of_trc(m)+1 36]);
    
end;


