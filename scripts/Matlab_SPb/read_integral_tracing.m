%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READ TRACING FILE integral.trc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===================================================
% This script is a part of Analysis_B2.m script,
% however, it may be used separately and independently
%===================================================

if exist('PATH_PREFIX','var')
% Use a PATH_PREFIX already defined in Analysis_B2.m    
    PATH_PREFIX
else
% Define a PATH_PREFIX manually
    PATH_PREFIX = '/home/senichenkov/SOLPS-ITER/solps-iter/runs/AUG28903_Nitrogen/variant040_eirene_drift_Npuff_2e18_alb0.87/';
end;

if exist([PATH_PREFIX './integral.trc'],'file') == 2
        Possible_Relative_Path='';
elseif exist([PATH_PREFIX './b2mn.exe.dir/tracing/integral.trc'],'file') == 2
        Possible_Relative_Path='b2mn.exe.dir/tracing/';
elseif exist([PATH_PREFIX '../b2mn.exe.dir/tracing/integral.trc'],'file') == 2
        Possible_Relative_Path='../b2mn.exe.dir/tracing/';
elseif exist([PATH_PREFIX './tracing/integral.trc'],'file') == 2
        Possible_Relative_Path='tracing/';
elseif exist([PATH_PREFIX '../tracing/integral.trc'],'file') == 2
        Possible_Relative_Path='../tracing/';
else
    'No file integral.trc is found - exiting'
    stop;
end;

Trc_version = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',[0,1,0,1]);
Trc_N_globals = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',[0,2,0,2]);
Trc_N_per_region = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',[0,3,0,3]);
Trc_N_per_species = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',[0,4,0,4]);
Trc_N_per_species_and_region = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',[0,5,0,5]);
Trc_N_per_stratum = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',[0,6,0,6]);
Trc_N_regions = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',[0,7,0,7]);
Trc_N_species = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',[0,8,0,8]);
Trc_N_strata = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',[0,9,0,9]);
Trc_N_per_species_and_stratum = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',[0,10,0,10]);

Trc_N_records = 1 +                                                                    ...   % Time
                Trc_N_globals +                                                        ...   % Global variables
                Trc_N_per_region * Trc_N_regions +                                     ...   % Variables per region
                Trc_N_per_species * Trc_N_species +                                    ...   % Variables per species
                Trc_N_per_species_and_region * Trc_N_species * Trc_N_regions  +        ...   % Variables per species and per region
                Trc_N_per_stratum * Trc_N_strata +                                     ...   % Variables per stratum
                (Trc_N_per_species_and_stratum + 1) * Trc_N_species * Trc_N_strata;    ...   % Variables per species and per stratum plus something else
                

[status, result] = system( ['wc -l ' PATH_PREFIX Possible_Relative_Path 'integral.trc'] );
Str_N_lines=split(result);
Trc_N_Lines=str2num(Str_N_lines{1});

Trc_Time = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',...
    [3 0 Trc_N_Lines-1 0]);

Trc_EE_reg = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',...
    [3 Trc_N_globals+6*Trc_N_regions+1 Trc_N_Lines-1 Trc_N_globals+7*Trc_N_regions]);

Trc_EI_reg = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',...
    [3 Trc_N_globals+7*Trc_N_regions+1 Trc_N_Lines-1 Trc_N_globals+8*Trc_N_regions]);

Trc_KI_reg = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',...
    [3 Trc_N_globals+8*Trc_N_regions+1 Trc_N_Lines-1 Trc_N_globals+9*Trc_N_regions]);

Trc_tot_En_reg = Trc_EE_reg + Trc_EI_reg + Trc_KI_reg;


Trc_Na_spec = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',...
    [3 Trc_N_globals+Trc_N_per_region*Trc_N_regions+Trc_N_per_species+1 Trc_N_Lines-1 Trc_N_globals+Trc_N_per_region*Trc_N_regions+Trc_N_per_species+Trc_N_species]);

Trc_Ni_spec_reg = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',...
    [3 Trc_N_globals+Trc_N_per_region*Trc_N_regions+Trc_N_per_species*Trc_N_species+Trc_N_species*Trc_N_regions+1 Trc_N_Lines-1 Trc_N_globals+Trc_N_per_region*Trc_N_regions+Trc_N_per_species*Trc_N_species+2*Trc_N_species*Trc_N_regions]);

Trc_Na_spec_reg = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',...
    [3 Trc_N_globals+Trc_N_per_region*Trc_N_regions+Trc_N_per_species*Trc_N_species+2*Trc_N_species*Trc_N_regions+1 Trc_N_Lines-1 Trc_N_globals+Trc_N_per_region*Trc_N_regions+Trc_N_per_species*Trc_N_species+3*Trc_N_species*Trc_N_regions]);

Trc_Na_spec_stra = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',...
    [3 Trc_N_globals+Trc_N_per_region*Trc_N_regions+Trc_N_per_species*Trc_N_species+Trc_N_per_species_and_stratum*Trc_N_species*Trc_N_regions+Trc_N_strata*Trc_N_per_stratum+2*Trc_N_species*Trc_N_strata+1 Trc_N_Lines-1 Trc_N_globals+Trc_N_per_region*Trc_N_regions+Trc_N_per_species*Trc_N_species+Trc_N_per_species_and_stratum*Trc_N_species*Trc_N_regions+Trc_N_strata*Trc_N_per_stratum+3*Trc_N_species*Trc_N_strata]);

Trc_SNa_spec_stra = dlmread([PATH_PREFIX Possible_Relative_Path 'integral.trc'],'',...
    [3 Trc_N_globals+Trc_N_per_region*Trc_N_regions+Trc_N_per_species*Trc_N_species+Trc_N_per_species_and_stratum*Trc_N_species*Trc_N_regions+Trc_N_strata*Trc_N_per_stratum+3*Trc_N_species*Trc_N_strata+1 Trc_N_Lines-1 Trc_N_globals+Trc_N_per_region*Trc_N_regions+Trc_N_per_species*Trc_N_species+Trc_N_per_species_and_stratum*Trc_N_species*Trc_N_regions+Trc_N_strata*Trc_N_per_stratum+4*Trc_N_species*Trc_N_strata]);


%30 types of line are prescribed
SYMBOL={'-o' '-s' '-*' '-h' '-^' '->' '-<' '-v' '-+' '-o' '-s' '-*' '-h' '-^' '->' '-<' '-v' '-+' '-o' '-s' '-*' '-h' '-^' '->' '-<' '-v' '-o' '-s' '-*' '-h' '-^' '->' '-<' '-v'};
COLOUR={[1,0,0] [0,0,1] [0.45,0.1,0.05] [0.75,0.2,0.15] [0.15,0.05,0.5] [0.25,0.5,0.25] [1,0.6,0] [1,0.05,0.75] ...
    [0.5,0.5,1] [0.0,0.5,1] [0.5,0.1,0] [0.6,0.05,0.4] [0.35,0.65,0.15] [0.8,0.2,0.8] [0.2,0.2,0.5] [0.4,0.4,0.55] ...
    [0.5,0.5,0.5] [0.2,0.8,0.8] [0.8,0.7,0.3] [0.3,0.9,0.5] [0,1,0] [0.25,0.25,0.85] [0.85,0.2,0.2] [0.3,0,0.9] [0.75,0.75,0.05] ...
    [0.9,0.2,0.2] [0.2,0.9,0.9] [0.15,0.9,0.15] [0.2,0.15,0.9] [0.2,0.2,0.65]};

plot_by_reg(Trc_Time,Trc_EE_reg,Trc_N_regions,'Electron internal Energy',COLOUR,1);
plot_by_reg(Trc_Time,Trc_EI_reg,Trc_N_regions,'Ion internal Energy',COLOUR,1);
plot_by_reg(Trc_Time,Trc_KI_reg,Trc_N_regions,'Ion kinetic Energy',COLOUR,1);
plot_by_reg(Trc_Time,Trc_tot_En_reg,Trc_N_regions,'Plasma total Energy',COLOUR,1);

species_label=cell(Trc_N_species);
species_label{1}='D';
species_label{2}='N';


plot_by_spec(Trc_Time,Trc_Na_spec,Trc_N_species,'Number of atoms in whole domain',species_label,COLOUR);

plot_by_spec_and_reg(Trc_Time,Trc_Na_spec_reg,Trc_N_species,Trc_N_regions,'Number of atoms',species_label,COLOUR,1);

plot_by_spec_and_stra(Trc_Time,Trc_Na_spec_stra,Trc_N_species,Trc_N_strata,'Number of atoms',species_label,COLOUR,1);
plot_by_spec_and_stra(Trc_Time,Trc_SNa_spec_stra,Trc_N_species,Trc_N_strata,'Source due to neutral ionization',species_label,COLOUR,1);