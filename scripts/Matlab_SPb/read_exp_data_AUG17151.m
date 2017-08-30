%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READ EXPERIMENTAL DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===================================================
% This script is a part of Analysis_B2.m script
%===================================================

% This script reads experimental data (in machine or even discharge
% specific format which experimentalists use to transfer data to
% theoreticians) and fills in the 'standard' arrays acceptable by
% Analysis_B2.m and Compare-B2.m

% These arrays are
%
%--------------
% Numbers of available diagnostics - numbers of profiles to plot%
%--------------
%
% N_ne_midpl [integer] - number of experimental diagnostics to measure
%                        electron density in equatorial midplane
%--------------
% N_Te_midpl [integer] - number of experimental diagnostics to measure
%                        electron temperature in equatorial midplane
% N_Ti_midpl [integer] - number of experimental diagnostics to measure
%                        ion temperature in equatorial midplane
% These two numbers should come in a group, i.e. to plot even one of two
% experimental quantities both numbers should be defined - for the missing
% quantity the number should be set to zero.
%--------------
%
% N_ne_inner bottom [integer] - number of experimental diagnostics to
%                         measure electron density at inner bottom target
% N_ne_outer bottom [integer] - number of experimental diagnostics to
%                         measure electron density at outer bottom target
% N_ne_outer_top    [integer] - number of experimental diagnostics to
%                         measure electron density at outer top target
% N_ne_inner top     [integer] - number of experimental diagnostics to
%                         measure electron density at inner top target
%These 4 numbers should come in a group, i.e. to plot even one of 4
% experimental quantities all four numbers should be defined - for the
% missing quantity the number should be set to zero.
%--------------
%
% N_Te_inner bottom [integer] - number of experimental diagnostics to
%                         measure electron temperature at inner bottom target
% N_Te_outer bottom [integer] - number of experimental diagnostics to
%                         measure electron temperature at outer bottom target
% N_Te_outer_top    [integer] - number of experimental diagnostics to
%                         measure electron temperature at outer top target
% N_Te_inner top     [integer] - number of experimental diagnostics to
%                         measure electron temperature at inner top target
%These 4 numbers should come in a group, i.e. to plot even one of 4
% experimental quantities all four numbers should be defined - for the
% missing quantity the number should be set to zero.
%--------------
%
% N_Ti_inner bottom [integer] - number of experimental diagnostics to
%                         measure ion temperature at inner bottom target
% N_Ti_outer bottom [integer] - number of experimental diagnostics to
%                         measure ion temperature at outer bottom target
% N_Ti_outer_top    [integer] - number of experimental diagnostics to
%                         measure ion temperature at outer top target
% N_Ti_inner top     [integer] - number of experimental diagnostics to
%                         measure ion temperature at inner top target
%These 4 numbers should come in a group, i.e. to plot even one of 4
% experimental quantities all four numbers should be defined - for the
% missing quantity the number should be set to zero.
%--------------
%
% N_po_inner bottom [integer] - number of experimental diagnostics to
%                         measure electrostatic potential at inner bottom target
% N_po_outer bottom [integer] - number of experimental diagnostics to
%                         measure electrostatic potential at outer bottom target
% N_po_outer_top    [integer] - number of experimental diagnostics to
%                         measure electrostatic potential at outer top target
% N_po_inner top     [integer] - number of experimental diagnostics to
%                         measure electrostatic potential at inner top target
%These 4 numbers should come in a group, i.e. to plot even one of 4
% experimental quantities all four numbers should be defined - for the
% missing quantity the number should be set to zero.
%--------------
%
% N_jsat_inner bottom [integer] - number of experimental diagnostics to
%                         measure ion satuartion current at inner bottom target
% N_jsat_outer bottom [integer] - number of experimental diagnostics to
%                         measure ion satuartion current at outer bottom target
% N_jsat_outer_top    [integer] - number of experimental diagnostics to
%                         measure ion satuartion current at outer top target
% N_jsat_inner top     [integer] - number of experimental diagnostics to
%                         measure ion satuartion current at inner top target
%These 4 numbers should come in a group, i.e. to plot even one of 4
% experimental quantities all four numbers should be defined - for the
% missing quantity the number should be set to zero.
%--------------
%
% N_fhtotX_inner bottom [integer] - number of experimental diagnostics to
%                         measure heat flux density at inner bottom target
% N_fhtotX_outer bottom [integer] - number of experimental diagnostics to
%                         measure heat flux density at outer bottom target
% N_fhtotX_outer_top    [integer] - number of experimental diagnostics to
%                         measure heat flux density at outer top target
% N_fhtotX_inner top     [integer] - number of experimental diagnostics to
%                         measure heat flux density at inner top target
%These 4 numbers should come in a group, i.e. to plot even one of 4
% experimental quantities all four numbers should be defined - for the
% missing quantity the number should be set to zero.
%--------------
%
%
%--------------
% Legend labels for each experimental profile
%
% legend_exp_ne_midpl=cell(N_ne_midpl,1);
% legend_exp_Te_midpl=cell(N_Te_midpl,1);
% legend_exp_Ti_midpl=cell(N_Ti_midpl,1);
% legend_exp_ne_outer_bottom=cell(N_ne_outer_bottom,1);
% legend_exp_Te_outer_bottom=cell(N_Te_outer_bottom,1);
% legend_exp_po_outer_bottom=cell(N_po_outer_bottom,1);
% legend_exp_jsat_inner_bottom=cell(N_jsat_inner_bottom,1);
% legend_exp_fhtotX_outer_bottom=cell(N_fhtotX_outer_bottom,1);
%
% 
%--------------
%
% Data arrays are organized as following
%
% exp_data_<QUANTITY>_<LOCUS>(:,1) contains the distance in meters (with
%                                 origin at separatrix) for first available
%                                 experimental profile of quantity 
%                                 <QUANTITY> at <LOCUS> 
% exp_data_<QUANTITY>_<LOCUS>(:,2) contains the experimental data for 
%                                 first available experimental profile
%                                 of quantity <QUANTITY> at <LOCUS>
% exp_data_<QUANTITY>_<LOCUS>(:,3) contains the distance in meters (with
%                                 origin at separatrix) for second available
%                                 experimental profile of quantity 
%                                 <QUANTITY> at <LOCUS> 
% exp_data_<QUANTITY>_<LOCUS>(:,4) contains the experimental data for 
%                                 second available experimental profile
%                                 of quantity <QUANTITY> at <LOCUS>
% ...
% exp_data_<QUANTITY>_<LOCUS>(:,2*N_<QUANTITY>_<LOCUS>-1) contains the 
%                                 distance in meters (with
%                                 origin at separatrix) for the last 
%                                 (N_<QUANTITY>_<LOCUS>) available 
%                                 experimental profile of quantity  
%                                 <QUANTITY> at <LOCUS> 
% exp_data_<QUANTITY>_<LOCUS>(:,2*N_<QUANTITY>_<LOCUS>) contains the 
%                                 experimental data for the last 
%                                 (N_<QUANTITY>_<LOCUS>) available
%                                 experimental profile
%                                 of quantity <QUANTITY> at <LOCUS>
%--------------


%%%%%%%%%%%%% ELECTRON DENSITY AT OUTER MIDPLANE %%%%%%%%%%%%%%%%%%%%%%%%%%
exp_data_ne_midpl_Rmaj=dlmread([EXP_DATA_PREFIX 'augped_fits_17151_pne2.dat'],'',[5 0 2955 0]);
exp_data_ne_midpl_ne=dlmread([EXP_DATA_PREFIX 'augped_fits_17151_pne2.dat'],'',[5 3 2955 3]);
N_ne_midpl = 1;
%global N_ne_midpl;

exp_data_ne_midpl(1:max(size(exp_data_ne_midpl_Rmaj)),1)=exp_data_ne_midpl_Rmaj-2.1531-0.01;
                                                                                                                       % this 0.01 is artificial,
                                                                                                                       % probably due to uncertainty in separatrix location
                                                                                                                       % (R0(nsep+2,nout+2)+R1(nsep+2,nout+2))/2 = 2.1531
exp_data_ne_midpl(1:max(size(exp_data_ne_midpl_ne)),2)=exp_data_ne_midpl_ne;
legend_exp_ne_midpl=cell(N_ne_midpl,1);
legend_exp_ne_midpl{1} = 'ne_{exp}';
clear('exp_data_ne_midpl_Rmaj','exp_data_ne_midpl_ne');


% %%%%%%%%%%%%% ELECTRON TEMPERATURE AT OUTER MIDPLANE %%%%%%%%%%%%%%%%%%%%%%
exp_data_Te_midpl_Rmaj=dlmread([EXP_DATA_PREFIX 'augped_fits_17151_pTe2.dat'],'',[5 0 2045 0]);
exp_data_Te_midpl_Te=dlmread([EXP_DATA_PREFIX 'augped_fits_17151_pTe2.dat'],'',[5 3 2045 3]);
N_Te_midpl = 1;
%global N_ne_midpl;

exp_data_Te_midpl(1:max(size(exp_data_Te_midpl_Rmaj)),1)=exp_data_Te_midpl_Rmaj-2.1531-0.01;
                                                                                                                       % this 0.01 is artificial,
                                                                                                                       % probably due to uncertainty in separatrix location
                                                                                                                       % (R0(nsep+2,nout+2)+R1(nsep+2,nout+2))/2 = 2.1531
exp_data_Te_midpl(1:max(size(exp_data_Te_midpl_Te)),2)=exp_data_Te_midpl_Te;
legend_exp_Te_midpl=cell(N_Te_midpl,1);
legend_exp_Te_midpl{1} = 'Te_{exp}';
clear('exp_data_Te_midpl_Rmaj','exp_data_Te_midpl_Te');
% 
% 
% %%%%%%%%%%%%% ION TEMPERATURE AT OUTER MIDPLANE %%%%%%%%%%%%%%%%%%%%%%%%%%%
exp_data_Ti_midpl_Rmaj=dlmread([EXP_DATA_PREFIX 'augped_fits_17151_pTi2.dat'],'',[5 0 465 0]);
exp_data_Ti_midpl_Ti=dlmread([EXP_DATA_PREFIX 'augped_fits_17151_pTi2.dat'],'',[5 3 465 3]);
N_Ti_midpl = 1;
%global N_ne_midpl;

exp_data_Ti_midpl(1:max(size(exp_data_Ti_midpl_Rmaj)),1)=exp_data_Ti_midpl_Rmaj-2.1531-0.01;
                                                                                                                       % this 0.01 is artificial,
                                                                                                                       % probably due to uncertainty in separatrix location
                                                                                                                       % (R0(nsep+2,nout+2)+R1(nsep+2,nout+2))/2 = 2.1531
exp_data_Ti_midpl(1:max(size(exp_data_Ti_midpl_Ti)),2)=exp_data_Ti_midpl_Ti;
legend_exp_Ti_midpl=cell(N_Ti_midpl,1);
legend_exp_Ti_midpl{1} = 'Ti_{exp}';
clear('exp_data_Ti_midpl_Rmaj','exp_data_Ti_midpl_Ti');
% 
% 
% %%%%%%%%%%%%% ELECTRON DENSITY AT INNER BOTTOM TARGET %%%%%%%%%%%%%%%%%%%%%
% exp_data_ne_inner_bottom_LP=dlmread([EXP_DATA_PREFIX 'LP-ne-profile-iD'],'');
% %exp_data_ne_inner_bottom_IR=dlmread([EXP_DATA_PREFIX 'IR-ne-profile-iD'],'');
 N_ne_inner_bottom = 0;
% %global N_ne_midpl;
% %exp_data_ne_midpl=zeros(max(max(size(exp_data_ne_midpl_core)),max(size(exp_data_ne_midpl_edge))),2*N_ne_midpl);
% %exp_data_ne_midpl(1:max(size(exp_data_ne_midpl_core)),1:2)=exp_data_ne_midpl_core;
% %exp_data_ne_midpl(1:max(size(exp_data_ne_midpl_edge)),3:4)=exp_data_ne_midpl_edge;
% exp_data_ne_inner_bottom=exp_data_ne_inner_bottom_LP;
% legend_exp_ne_inner_bottom=cell(N_ne_inner_bottom,1);
% legend_exp_ne_inner_bottom{1} = 'LP iD';
% %legend_exp_ne_midpl{2} = 'VTAe';
% clear('exp_data_ne_inner_bottom_LP');
% 
%%%%%%%%%%%%% ELECTRON DENSITY AT OUTER BOTTOM TARGET %%%%%%%%%%%%%%%%%%%%%
exp_data_ne_outer_bottom_LP=dlmread([EXP_DATA_PREFIX 'ne_outer_exp.txt'],'',[1,0,22,1] );
%exp_data_ne_outer_bottom_IR=dlmread([EXP_DATA_PREFIX 'IR-ne-profile-iD'],'');
N_ne_outer_bottom = 1;
%global N_ne_midpl;
%exp_data_ne_midpl=zeros(max(max(size(exp_data_ne_midpl_core)),max(size(exp_data_ne_midpl_edge))),2*N_ne_midpl);
%exp_data_ne_midpl(1:max(size(exp_data_ne_midpl_core)),1:2)=exp_data_ne_midpl_core;
%exp_data_ne_midpl(1:max(size(exp_data_ne_midpl_edge)),3:4)=exp_data_ne_midpl_edge;
exp_data_ne_outer_bottom=exp_data_ne_outer_bottom_LP;
legend_exp_ne_outer_bottom=cell(N_ne_outer_bottom,1);
legend_exp_ne_outer_bottom{1} = 'n_e exp';
%legend_exp_ne_midpl{2} = 'VTAe';
clear('exp_data_ne_outer_bottom_LP');
% 
% %%%%%%%%%%%%% ELECTRON DENSITY AT OUTER TOP TARGET %%%%%%%%%%%%%%%%%%%%%%%%
 N_ne_outer_top = 0;  % zero value means the absence of experimental data for the outer top target
% 
% %%%%%%%%%%%%% ELECTRON DENSITY AT INNER TOP TARGET %%%%%%%%%%%%%%%%%%%%%%%%
 N_ne_inner_top = 0;  % zero value means the absence of experimental data for the inner top target
% 
% 
% %%%%%%%%%%%%% ELECTRON TEMPERATURE AT INNER BOTTOM TARGET %%%%%%%%%%%%%%%%%
% exp_data_Te_inner_bottom_LP=dlmread([EXP_DATA_PREFIX 'LP-te-profile-iD'],'');
% %exp_data_ne_inner_bottom_IR=dlmread([EXP_DATA_PREFIX 'IR-ne-profile-iD'],'');
 N_Te_inner_bottom = 0;
% %global N_ne_midpl;
% %exp_data_ne_midpl=zeros(max(max(size(exp_data_ne_midpl_core)),max(size(exp_data_ne_midpl_edge))),2*N_ne_midpl);
% %exp_data_ne_midpl(1:max(size(exp_data_ne_midpl_core)),1:2)=exp_data_ne_midpl_core;
% %exp_data_ne_midpl(1:max(size(exp_data_ne_midpl_edge)),3:4)=exp_data_ne_midpl_edge;
% exp_data_Te_inner_bottom=exp_data_Te_inner_bottom_LP;
% legend_exp_Te_inner_bottom=cell(N_Te_inner_bottom,1);
% legend_exp_Te_inner_bottom{1} = 'LP iD';
% %legend_exp_ne_midpl{2} = 'VTAe';
% clear('exp_data_Te_inner_bottom_LP');
% 
% %%%%%%%%%%%%% ELECTRON TEMPERATURE AT OUTER BOTTOM TARGET %%%%%%%%%%%%%%%%%
exp_data_Te_outer_bottom_LP=dlmread([EXP_DATA_PREFIX 'te_outer_exp.txt'],'',[1,0,26,1]);
%exp_data_ne_outer_bottom_IR=dlmread([EXP_DATA_PREFIX 'IR-ne-profile-iD'],'');
N_Te_outer_bottom = 1;
%global N_ne_midpl;
%exp_data_ne_midpl=zeros(max(max(size(exp_data_ne_midpl_core)),max(size(exp_data_ne_midpl_edge))),2*N_ne_midpl);
%exp_data_ne_midpl(1:max(size(exp_data_ne_midpl_core)),1:2)=exp_data_ne_midpl_core;
%exp_data_ne_midpl(1:max(size(exp_data_ne_midpl_edge)),3:4)=exp_data_ne_midpl_edge;
exp_data_Te_outer_bottom=exp_data_Te_outer_bottom_LP;
legend_exp_Te_outer_bottom=cell(N_Te_outer_bottom,1);
legend_exp_Te_outer_bottom{1} = 'T_e exp';
%legend_exp_ne_midpl{2} = 'VTAe';
clear('exp_data_Te_outer_bottom_LP');
% 
% %%%%%%%%%%%%% ELECTRON TEMPERATURE AT OUTER TOP TARGET %%%%%%%%%%%%%%%%%%%%
 N_Te_outer_top = 0;  % zero value means the absence of experimental data for the outer top target
% 
% %%%%%%%%%%%%% ELECTRON TEMPERATURE AT INNER TOP TARGET %%%%%%%%%%%%%%%%%%%%
 N_Te_inner_top = 0;  % zero value means the absence of experimental data for the inner top target
% 
% 
% %%%%%%%%%%%%% ION SATURATION CURRENT DENSITY AT INNER BOTTOM TARGET %%%%%%%
% exp_data_jsat_inner_bottom_LP=dlmread([EXP_DATA_PREFIX 'LP-jsat-profile-iD'],'');
% exp_data_jsat_inner_bottom_LPm=dlmread([EXP_DATA_PREFIX 'LP-mjsat-profile-iD'],'');
% exp_data_jsat_inner_bottom_LP(:,2)=exp_data_jsat_inner_bottom_LP(:,2)*qe;
% exp_data_jsat_inner_bottom_LPm(:,2)=exp_data_jsat_inner_bottom_LPm(:,2)*qe;
% N_jsat_inner_bottom = 2;
% %global N_ne_midpl;
% exp_data_jsat_inner_bottom=zeros(max(max(size(exp_data_jsat_inner_bottom_LP)),max(size(exp_data_jsat_inner_bottom_LPm))),2*N_jsat_inner_bottom);
% exp_data_jsat_inner_bottom(1:max(size(exp_data_jsat_inner_bottom_LP)),1:2)=exp_data_jsat_inner_bottom_LP;
% exp_data_jsat_inner_bottom(1:max(size(exp_data_jsat_inner_bottom_LPm)),3:4)=exp_data_jsat_inner_bottom_LPm;
% %exp_data_jsat_inner_bottom=exp_data_jsat_inner_bottom_LP;
% legend_exp_jsat_inner_bottom=cell(N_jsat_inner_bottom,1);
% legend_exp_jsat_inner_bottom{1} = 'LP iD';
% legend_exp_jsat_inner_bottom{2} = 'LPm iD';
% %legend_exp_ne_midpl{2} = 'VTAe';
% clear('exp_data_jsat_inner_bottom_LP','exp_data_jsat_inner_bottom_LPm');
% 
% %%%%%%%%%%%%% ION SATURATION CURRENT DENSITY AT OUTER BOTTOM TARGET %%%%%%%
% exp_data_jsat_outer_bottom_LP=dlmread([EXP_DATA_PREFIX 'LP-jsat-profile-oD'],'');
% exp_data_jsat_outer_bottom_LPm=dlmread([EXP_DATA_PREFIX 'LP-mjsat-profile-oD'],'');
% exp_data_jsat_outer_bottom_LP(:,2)=exp_data_jsat_outer_bottom_LP(:,2)*qe;
% exp_data_jsat_outer_bottom_LPm(:,2)=exp_data_jsat_outer_bottom_LPm(:,2)*qe;
% N_jsat_outer_bottom = 2;
% %global N_ne_midpl;
% exp_data_jsat_outer_bottom=zeros(max(max(size(exp_data_jsat_outer_bottom_LP)),max(size(exp_data_jsat_outer_bottom_LPm))),2*N_jsat_outer_bottom);
% exp_data_jsat_outer_bottom(1:max(size(exp_data_jsat_outer_bottom_LP)),1:2)=exp_data_jsat_outer_bottom_LP;
% exp_data_jsat_outer_bottom(1:max(size(exp_data_jsat_outer_bottom_LPm)),3:4)=exp_data_jsat_outer_bottom_LPm;
% %exp_data_jsat_outer_bottom=exp_data_jsat_outer_bottom_LP;
% legend_exp_jsat_outer_bottom=cell(N_jsat_outer_bottom,1);
% legend_exp_jsat_outer_bottom{1} = 'LP iD';
% legend_exp_jsat_outer_bottom{2} = 'LPm iD';
% %legend_exp_ne_midpl{2} = 'VTAe';
% clear('exp_data_jsat_outer_bottom_LP','exp_data_jsat_outer_bottom_LPm');
% 
% %%%%%%%%%%%%% ION SATURATION CURRENT DENSITY AT OUTER TOP TARGET %%%%%%%%%%
% N_jsat_outer_top = 0;  % zero value means the absence of experimental data for the outer top target
% 
% %%%%%%%%%%%%% ION SATURATION CURRENT DENSITY AT INNER TOP TARGET %%%%%%%%%%
% N_jsat_inner_top = 0;  % zero value means the absence of experimental data for the inner top target
% 
% 
% %%%%%%%%%%%%% HEAT FLUX DENSITY AT INNER BOTTOM TARGET %%%%%%%%%%%%%%%%%%%%
% exp_data_fhtotX_inner_bottom_LP=dlmread([EXP_DATA_PREFIX 'LP-pflx-profile-iD'],'');
% exp_data_fhtotX_inner_bottom_IR=dlmread([EXP_DATA_PREFIX 'IR-pflx-profile-iD'],'');
% N_fhtotX_inner_bottom = 2;
% %global N_ne_midpl;
% exp_data_fhtotX_inner_bottom=zeros(max(max(size(exp_data_fhtotX_inner_bottom_LP)),max(size(exp_data_fhtotX_inner_bottom_IR))),2*N_fhtotX_inner_bottom);
% exp_data_fhtotX_inner_bottom(1:max(size(exp_data_fhtotX_inner_bottom_LP)),1:2)=exp_data_fhtotX_inner_bottom_LP;
% exp_data_fhtotX_inner_bottom(1:max(size(exp_data_fhtotX_inner_bottom_IR)),3:4)=exp_data_fhtotX_inner_bottom_IR;
% %exp_data_fhtotX_inner_bottom=exp_data_fhtotX_inner_bottom_LP;
% legend_exp_fhtotX_inner_bottom=cell(N_fhtotX_inner_bottom,1);
% legend_exp_fhtotX_inner_bottom{1} = 'LP iD';
% legend_exp_fhtotX_inner_bottom{2} = 'IR iD';
% %legend_exp_ne_midpl{2} = 'VTAe';
% clear('exp_data_fhtotX_inner_bottom_LP','exp_data_fhtotX_inner_bottom_IR');
% 
% %%%%%%%%%%%%% HEAT FLUX DENSITY AT OUTER BOTTOM TARGET %%%%%%%%%%%%%%%%%%%%
% exp_data_fhtotX_outer_bottom_LP=dlmread([EXP_DATA_PREFIX 'LP-pflx-profile-oD'],'');
% exp_data_fhtotX_outer_bottom_IR=dlmread([EXP_DATA_PREFIX 'IR-pflx-profile-oD'],'');
% N_fhtotX_outer_bottom = 2;
% %global N_ne_midpl;
% exp_data_fhtotX_outer_bottom=zeros(max(max(size(exp_data_fhtotX_outer_bottom_LP)),max(size(exp_data_fhtotX_outer_bottom_IR))),2*N_fhtotX_outer_bottom);
% exp_data_fhtotX_outer_bottom(1:max(size(exp_data_fhtotX_outer_bottom_LP)),1:2)=exp_data_fhtotX_outer_bottom_LP;
% exp_data_fhtotX_outer_bottom(1:max(size(exp_data_fhtotX_outer_bottom_IR)),3:4)=exp_data_fhtotX_outer_bottom_IR;
% %exp_data_fhtotX_outer_bottom=exp_data_fhtotX_outer_bottom_LP;
% legend_exp_fhtotX_outer_bottom=cell(N_fhtotX_outer_bottom,1);
% legend_exp_fhtotX_outer_bottom{1} = 'LP iD';
% legend_exp_fhtotX_outer_bottom{2} = 'IR iD';
% %legend_exp_ne_midpl{2} = 'VTAe';
% clear('exp_data_fhtotX_outer_bottom_LP','exp_data_fhtotX_outer_bottom_IR');
% 
% %%%%%%%%%%%%% HEAT FLUX DENSITY AT OUTER TOP TARGET %%%%%%%%%%%%%%%%%%%%%%%
% N_fhtotX_outer_top = 0;  % zero value means the absence of experimental data for the outer top target
% 
% %%%%%%%%%%%%% HEAT FLUX DENSITY AT INNER TOP TARGET %%%%%%%%%%%%%%%%%%%%%%%
% N_fhtotX_inner_top = 0;  % zero value means the absence of experimental data for the inner top target
