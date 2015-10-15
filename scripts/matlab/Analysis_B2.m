
clear all;

SOLPS_ITER = 1;

% select the case to define mesh configuration and cuts

% Mesh = 'upgrade_96x36';
% Mesh = 'globus_82x24';
Mesh = 'upgrade_96x36_SOLPSITER_D_N';

% define mesh configuration and cuts
mesh

set(0,'DefaultFigureWindowStyle','normal')
set(0,'DefaultFigureWindowStyle','docked')
format compact



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% colour pallete
SYMBOL={'-o' '-s' '-*' '-h' '-^' '->' '-<' '-v' '-+' '-o' '-s' '-*' '-h' '-^' '->' '-<' '-v' '-+'};
COLOUR={[1,0,0] [0,0,1] [0.45,0.1,0.05] [0.75,0.2,0.15] [0.15,0.05,0.5] [0.25,0.5,0.25] [1,0.6,0] [1,0.05,0.75] ...
    [0.5,0.5,1] [0.0,0.5,1] [0.5,0.1,0] [0.6,0.05,0.4] [0.35,0.65,0.15] [0.8,0.2,0.8] [0.2,0.2,0.5] [0.4,0.4,0.55] ...
    [0.5,0.5,0.5] [0.2,0.8,0.2]};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%  PHYSICAL CONSTANTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

qe=1.602176487e-19;
mp=1.672621637e-27;
me=9.10938215e-31;
epsilon_0=8.8542e-12;

Lambda_Coulomb = 12;

%%%%%%% END OF PHYSICAL CONSTANTS DECLARATION



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%  PLASMA COMPOSITION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Plasma_Composition = 'D_C_He';
%Plasma_Composition = 'D_C';
Plasma_Composition = 'D_N';

plasma_composition

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% CHOOSE WHETHER TO READ OUTPUT FROM EIRENE OR NOT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EIRENE_flag=1;

%EIRENE_flag=0; Run with fluid neutrals - read output from "fluid" routines
%               of B2SOLPS
%EIRENE_flag=1; Run with Monte-Carlo neutrals - read output from EIRENE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% SCREEN SIZE AND GRAPH SIZE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PlotSize;

% Use actual screen size to plot in a full screen mode
PlotSize = get(0,'ScreenSize');

% or set up the plot size manually (in pixels)
PlotSize=zeros(1,4);

PlotSize(1) = 1;
PlotSize(2) = 900;
PlotSize(3) = 1200;
PlotSize(4) = 900;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% SOME SPECIFICATIONS FOR 2D PLOTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% SELECT THE MARGINS

%%%%%%%%%%%%%global Plot2DMargins;

%     Plot2DMargins = [R_min R_max  Z_min Z_max];

%%%%% R_max, R_min, Z_max, Z_min are cylindrical coordinates in meters

%%%%% Note that the instruction
%     axis equal;
%%%%% is used, therefore MATLAB corrects this choice


% The whole poloidal cross-section of Globus-M tokamak
%Plot2DMargins = [0 0.7  -0.6 0.6]; 

% The region near X-point on AUG
Plot2DMargins = [1.1 1.7  -1.25 -0.65];

%--------------------------------------------------------------



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%  DIRECTORY THAT CONTAINS DATA %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%global label2D;

%PATH_PREFIX='/home/ilya/B2runs/solps5.2/GlobusM/34439/Lena_04.06.2015/run1/';
%label2D='Globus 34439';

PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0/watch_05.05.2015/';
label2D='<n_i> = 8.0\cdot 10^{19} m^{-3}';

PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_17.06.2015/';
label2D='<n_i> = 12.0\cdot 10^{19} m^{-3}';

PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28093/BCexp_nodrift_5.5MW/watch_11.09.2015/';
label2D='Nitrogen no drift enhanced power';

%PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0_test_ulim_Bz/watch_04.06.2015/';
%PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0_negativeB/watch_19.05.2015/';
%PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0/watch_05.05.2015/';
%label2D='<n_i> = 12.0\cdot 10^{19} m^{-3} no drift';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%  READ GEOMETRY DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

read_geometry

plot_mesh

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READ DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

read_data


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALCULATE SECONDARY QUANTITIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

calc_secondary


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plots 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


plots1D;

scalar_plots_2D;



