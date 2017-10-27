
clear all;

SOLPS_ITER = 1;

% select the case to define mesh configuration and cuts

 Mesh = 'upgrade_96x36';
% Mesh = 'upgrade_96x36_my_mesh_30.12.2016';
%  Mesh = 'globus_82x24';  % shot # 34439
%   Mesh = 'globus_82x26';  % shot # 34358
% Mesh = 'globus_76x22';
% Mesh = 'globus_76x24';  % shot #34410
 Mesh = 'upgrade_96x36_SOLPSITER_D_N';
Mesh = 'globus_146x40';
 
%  Mesh = 'ITER_90x36_D_Ne';
%  Mesh = 'ITER_2410_90x36_D_He_Ne';

% define mesh configuration and cuts
%mesh
[nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,nin,nout,ntop,nbot] = set_mesh(Mesh);

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
Plasma_Composition = 'D_C';
Plasma_Composition = 'D_N';
%Plasma_Composition = 'D_He_Ne';
%Plasma_Composition = 'D_Ne';
%Plasma_Composition = 'D';

plasma_composition

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% CHOOSE WHETHER TO READ EXPERIMENTAL DATA
%%%%%% FOR EACH CASE A SEPARATE ROUTINE IS REQUIRED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

exp_data_flag=0;
global exp_data_flag;

%exp_data_flag=0; No experimetal data are available or they are not desired
%                 to be plotted
%exp_data_flag=1; plot the experimental data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% CHOOSE WHETHER TO READ OUTPUT FROM EIRENE OR NOT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EIRENE_flag=0;

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

% % % PlotSize(1) = 1;
% % % PlotSize(2) = 900;
% % % PlotSize(3) = 900;
% % % PlotSize(4) = 900;

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
 Plot2DMargins = [0.18 0.4  -0.6 -0.2]; 
 Plot2DMargins_whole = [0.05 0.7  -1.00 1.00];

% The region near X-point on AUG
% Plot2DMargins = [1.25 1.7  -1.25 -0.65];
% AUG whole B2 mesh
% Plot2DMargins_whole = [0.8 2.3  -1.30 1.10];

 
 % ITER near X-point
 %Plot2DMargins = [4.0 6.5  -4.60 -2.10];
 
 % ITER whole B2 mesh
 %Plot2DMargins_whole = [4.1 8.7  -5.00 5.00];

%--------------------------------------------------------------



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%  DIRECTORY THAT CONTAINS DATA %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%global label2D;

PATH_PREFIX='/home/ilya/B2runs/solps5.2/GlobusM/34358/B2run008/watch_03.03.2016/';
label2D='Globus 34358';

PATH_PREFIX='/home/ilya/B2runs/solps5.2/GlobusM/34410/watch_without_ASTRA/run/';
label2D='Globus 34410';

% PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0_negativeB/watch_27.05.2015/';
% label2D='<n_i> = 8.0\cdot 10^{19} m^{-3} negative B';
% 
% PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0/watch_05.05.2015/';
% label2D='<n_i> = 12.0\cdot 10^{19} m^{-3}';
% 
%  PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0/watch_05.05.2015/';
%  label2D='<n_i> = 4.0\cdot 10^{19} m^{-3}';
% 
 %PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_05.10.2015/';
%  EXP_DATA_PREFIX='/home/ilya/Integrated_modeling/DATA_AUG17151/from Pereverzev/';
%  EXP_DATA_PREFIX='/home/ilya/B2SOLPS/Chankin_experimental_data/';
 %label2D='<n_i> = 12.0\cdot 10^{19} m^{-3}';

%  PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_05.10.2015/';
% EXP_DATA_PREFIX='/home/ilya/Integrated_modeling/DATA_AUG17151/from Pereverzev/';
% label2D='<n_i> = 12.0\cdot 10^{19} m^{-3}';

%  PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0_nodrift/watch_22.05.2015/';
% EXP_DATA_PREFIX='/home/ilya/Integrated_modeling/DATA_AUG17151/from Pereverzev/';
% label2D='<n_i> = 8.0\cdot 10^{19} m^{-3} no drift';

 %PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0_nodrift/watch_22.05.2015/';
 % label2D='<n_i> = 8.0\cdot 10^{19} m^{-3} no drifts';
% 
% 
% % PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_nodrift/watch_22.05.2015/';
% PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/test_ua/u_negative_new/watch_23.12.2015/';
% label2D='<n_i> = 12.0\cdot 10^{19} m^{-3} nodrift';
% 
% 
%   PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903/debug_rflux_30.11.2015_plus3000steps/b2mn.exe.dir/';
%   PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903/debug_rflux_03.12.2015_plus3000steps/b2mn.exe.dir/';
%   PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903/BCexp_5.5MW_drift/watch_20.09.2015/';

%      PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_ANK/BCCON27_ANK_albFelix/watch_04.02.2016/';
%     PATH_PREFIX='sftp://senichenkov@localhost:9800/home/senichenkov/B2runs/AUG28903/solps-iter_nitrogen/BCCON27_ANK_albFelix_repeat_12.02/run/';
%      PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April/alb0.81_Dpuff8e20_Npuff2e19_nodrift/watch_27.04.2016/';
%     PATH_PREFIX='/media/ilya/SP UFD U2/watch_19.02_thf/';
 

%PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Coriolis/NODRIFT_alb0.81_Dpuff2e22/Npuff2e19_lowNinit_lowNflux/watch_20.05.2016/';
%PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Coriolis/DRIFT1.0_alb0.87_Dpuff2e22_ThF/BCCON27_Npuff12e19_BCCON10_alpha-1e-2/watch_23.06.2016/b2mn.exe.dir/';
% PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/June_results/alb0.87_Dpuff2e22_Npuff2e19_drift1.0_BCCON27_ThF_watch_27.06.2016/b2mn.exe.dir/';
% PATH_PREFIX='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.87_Dpuff2e22_Npuff2e19_drift1.0_BCCON27_ThF_watch_17.06.2016/b2mn.exe.dir/';
% PATH_PREFIX='/tokp/work/iys/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/test_BCCON27/b2mn.exe.dir/';
% label2D='N_2 seeding 2e19';

% % % % % PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_from_5e20/watch_22.09.2016/';
% % % % % PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_22.09.2016/';
% % % % % PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e18/watch_10.10.2016/';
% % % % % 
% % % % % PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/ne_fit/alb_0.98_alpha_5e-2/watch_13.10.2016/';

% PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_22.09.2016/';
%PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_5e20_visc_dt2e-8/watch_10.10.2016/';
%PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_12e19/watch_06.10.2016/';

% % % for IAEA 2016
% % PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_2e18/watch_10.10.2016/';
% % PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e18/watch_10.10.2016/'
% % PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_2e19/watch_10.10.2016/';
% % PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_5e19/watch_06.10.2016/';
% % PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e19/watch_06.10.2016/';
% % PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_12e19/watch_06.10.2016/';
% % PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_5e20_visc_dt2e-8/watch_10.10.2016/';
% % 
% % label2D='N_2 seeding 2e18';
% % %for IAEA 2016

  PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Neon/Ne_puff_2e18_red_transport_watch_13.04.2017/b2mn.exe.dir/';   %_reduced_alfa4_2times
  label2D='N_2 seeding 2e18';
  PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_8e20_red_transport/watch_16.05.2017/';   %_reduced_alfa4_2times
  label2D='N_2 seeding 8e20';
% % % 

  PATH_PREFIX='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_2e18_red_transport/watch_24.05.2017/';   %_reduced_alfa4_2times
  label2D='N_2 seeding 2e18';
  
% %   PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_2e20/watch_28.03.2017/'; 
% %   label2D='N_2 seeding 2e20';
%   PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Deuterium/alb0.81_watch_17.04.2017/b2mn.exe.dir/';   %_reduced_alfa4_2times
%   label2D='D alb 0.81';

  % PATH_PREFIX='/home/ilya/B2runs/solps5.2/GlobusM/34358/watch_low_ion_flux/run1/';
%  label2D='N_2 seeding 4e20';

% PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_5e20_BCCON26/watch_20.09.2016/';

% % % PATH_PREFIX='/tokp/scratch/iys/tmp_SOLPS_ITER/solps-iter/runs/AUG28903_ver_03.000.005/variant012_fluid_nodrift_dt1e-6/b2mn.exe.dir/';
% % % PATH_PREFIX='/tokp/work/iys/B2runs/tests_Iter_D+Ne/output_Kuk/';
% % % label2D='ITER Neon';


PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/Globus-M2_Dasha/Nitrogen/testrun22/';   %_reduced_alfa4_2times
label2D='Nitrogen Dasha';


EXP_DATA_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903/130603/';
      
% PATH_PREFIX='/home/ilya/B2runs/solps5.2/GlobusM2/Lena_34410/drift_0.4/watch_drift_04/run/';


%PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/ITER/ITER-2410/watch_ITER2410_drift1.0_11.05.2016/b2mn.exe.dir/';
%label2D='ITER #2410';


%PATH_PREFIX='/home/ilya/B2runs/solps5.3/ITER/output/';
%label2D='';

     %   PATH_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28093/BCexp_5.5MW_nodrift/watch_28.10.2015/';
%   label2D='AUG28903 N_2 seeding no drifts';
% 
%PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0_test_ulim_Bz/watch_04.06.2015/';

%PATH_PREFIX='/home/ilya/B2runs/solps5.2/GlobusM/32171/start_25.07/BC_simple_dt5.0e-8/run_lk1_28.12.2015/';

% label2D='Globus 34358';
%  PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/test_intcor/new_correction/watch_16.02.2016/';
%  label2D='<n_i> = 12.0\cdot 10^{19} m^{-3}';

% PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_05.10.2015/';
% label2D='<n_i> = 12.0\cdot 10^{19} m^{-3}';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%  READ GEOMETRY DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

read_geometry

plot_mesh


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exp_data_flag
    Color_exp=cell(7);
%    legend_exp=cell(5);
    Marker_exp=cell(8);
    
    Color_exp{1} = [0.9 0.1 0.1];     % looks like red  - to correspond to quantities plotted in red
    Color_exp{2} = [0.95 0.05 0.05];  % looks like red  - to correspond to quantities plotted in red
    Color_exp{3} = [0.1 0.1 0.9];     % looks like blue - to correspond to quantities plotted in blue
    Color_exp{4} = [0.05 0.05 0.95];  % looks like blue - to correspond to quantities plotted in blue
    Color_exp{5} = [0.0 0.05 0.9];    % looks like blue - to correspond to quantities plotted in blue
    Color_exp{6} = [0.85,0.15,0.9];   % looks like   - to correspond to quantities plotted in  
    Color_exp{7} = [0.5,0.15,0.1];    % looks like   - to correspond to quantities plotted in  

    Marker_exp{1} = 'x';
    Marker_exp{2} = '*';
    Marker_exp{3} = '+';
    Marker_exp{4} = 'o';
    Marker_exp{5} = 'd';
    Marker_exp{6} = '^';
    Marker_exp{7} = 'v';
    Marker_exp{8} = 's';

    read_exp_data_AUG28903
%    read_exp_data_AUG17151
end;


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

%subplots_2D;
scalar_plots_2D;



