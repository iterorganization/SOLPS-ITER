# Command file for the plot_trc.py script
# designed to produce default analysis plots from the files tracing/*
#
#===============================================================================
# USAGE:
#
# @file:XXX     - read XXX, XXX.trc or XXX.nc file
# @page:XXX     - start next page labeled XXX defaults to the .trc header
# @log:         - plot in semilogY scale
# @iter:XX      - plot against last XX iterations, not time,
#                  (if XX < 0 or absent will plot for the whole history)
# @points:      - lines replaced by markers
# @linepoints:  - lines supplemented by markers
# @grid:        - add grid lines to the page
#
# @setymax:XX   - set Y-axis maximum plotting limit to XX
# @setymin:XX   - set Y-axis minimum plotting limit to XX
# @setxmax:XX   - set X-axis maximum plotting limit to XX
# @setxmin:XX   - set X-axis minimum plotting limit to XX
#
# @setx:quantity:label:XX  - change X-axis from default time to given
#                             quantity with provided label and scaling
#                             factor XX
#
# :quantity:label:XX - name of quantity added to the plot
#                       multiplied by XX (used for unit and sign conversion)
#                       label can be added to clarify the meaning in plot
#                       (otherwise default 'quantity' name will be used)
#===============================================================================

@file:sepdata
@page: Electron density at the separatrix, 10^{20} m^{-3}
:ne_sep:n_{e,avg}^{sep}:1.e-20
@page: Temperature at the separatrix, eV
:Te_sep:T_{e}^{sep}:
:Ti_sep:T_{i}^{sep}:
@page: Zeff at separatrix
:Zef_sep:Z_{eff}^{sep}:
@page: Power through the separatrix, MW
:Qt_sep:P_{SOL}:1.e-6
:Qe_sep:Q_{e}^{sep}:1.e-6
:Qi_sep:Q_{i}^{sep}:1.e-6
@page: Power radiated in SOL, MW
:Qrad_SOL:Q_{rad}^{SOL}:1.e-6
@page: Separatrix density fraction He, \%
:nr_sep_He:\eta_{He}^{sep}:1.e+2
@page: Separatrix density fraction Li, \%
:nr_sep_Li:\eta_{Li}^{sep}:1.e+2
@page: Separatrix density fraction Be, \%
:nr_sep_Be:\eta_{Be}^{sep}:1.e+2
@page: Separatrix density fraction B, \%
:nr_sep_B:\eta_{B}^{sep}:1.e+2
@page: Separatrix density fraction C, \%
:nr_sep_C:\eta_{C}^{sep}:1.e+2
@page: Separatrix density fraction N, \%
:nr_sep_N:\eta_{N}^{sep}:1.e+2
@page: Separatrix density fraction Ne, \%
:nr_sep_Ne:\eta_{Ne}^{sep}:1.e+2
@page: Separatrix density fraction Ar, \%
:nr_sep_Ar:\eta_{Ar}^{sep}:1.e+2
@page: Separatrix density fraction W, \%
:nr_sep_W:\eta_{W}^{sep}:1.e+2
@file:blne
@page: Power balance, MW
:tot_core:from core:1.e-6
:tot_targ:to targets:1.e-6
:tot_wall:to walls:1.e-6
:tot_rad:radiated:1.e-6
:pwr_totl:total:1.e-6
@page: Energy timescale d(ln(W))/dt, s^{-1}
:pwr_tscl:1/\tau_{E}:
@page: Core power balance, MW
:heat_cor:heat:1.e-6
:ptnt_cor:particles:1.e-6
:ntrl_cor:neutrals:1.e-6
:tot_core:total:1.e-6
@page: Impurity radiation, MW
:imp_rad:total:1.e-6
:imp_rad_He:He:1.e-6
:imp_rad_Li:Li:1.e-6
:imp_rad_Be:Be:1.e-6
:imp_rad_B:B:1.e-6
:imp_rad_C:C:1.e-6
:imp_rad_N:N:1.e-6
:imp_rad_Ne:Ne:1.e-6
:imp_rad_Ar:Ar:1.e-6
:imp_rad_W:W:1.e-6
@page: Stored energy, W
:tot_enre:electrons:
:tot_enri:ions:
:tot_enrg:total:
@page: Power to the inner target, MW
:pwr_plsm_il:plasma:1.e-6
:pwr_neut_il:neutrals:1.e-6
:pwr_ionz_il:ionization:1.e-6
:pwr_diss_il:dissociation:1.e-6
:pwr_totl_il:total:1.e-6
@page: Power to the outer target, MW
:pwr_plsm_ol:plasma:1.e-6
:pwr_neut_ol:neutrals:1.e-6
:pwr_ionz_ol:ionization:1.e-6
:pwr_diss_ol:dissociation:1.e-6
:pwr_totl_ol:total:1.e-6
@page: Power to the upper inner target, MW
:pwr_plsm_iu:plasma:1.e-6
:pwr_neut_iu:neutrals:1.e-6
:pwr_ionz_iu:ionization:1.e-6
:pwr_diss_iu:dissociation:1.e-6
:pwr_totl_iu:total:1.e-6
@page: Power to the upper outer target, MW
:pwr_plsm_ou:plasma:1.e-6
:pwr_neut_ou:neutrals:1.e-6
:pwr_ionz_ou:ionization:1.e-6
:pwr_diss_ou:dissociation:1.e-6
:pwr_totl_ou:total:1.e-6
@page:Power to the walls, MW
:pwr_plsm_wl:plasma:1.e-6
:pwr_neut_wl:neutrals:1.e-6
:pwr_ionz_wl:ionization:1.e-6
:pwr_diss_wl:dissociation:1.e-6
:pwr_totl_wl:total:1.e-6
@file:blnn
@page: Flux balance total H, s^{-1}
:ion_core_H:ion_core:
:ntr_core_H:ntr_core:
:ion_targ_H:ion_targ:
:ntr_targ_H:ntr_targ:
:ion_wall_H:ion_wall:
:ntr_wall_H:ntr_wall:
:ntr_puff_H:ntr_puff:
:flux_tot_H:tot_flux:
:flux_bln_H:err_totl:
@page: H ion dN/dt, s^{-1}
:flx_d/dt_H:dN/dt:
@page: H content dln(N)/dt, s^{-1}
:flux_ttr_H:dln(N)/dt:
@page: Total relative error in H balance
:bln_blnr_H:err/sum:
@page: Flux balance total D, s^{-1}
:ion_core_D:ion_core:
:ntr_core_D:ntr_core:
:ion_targ_D:ion_targ:
:ntr_targ_D:ntr_targ:
:ion_wall_D:ion_wall:
:ntr_wall_D:ntr_wall:
:ntr_puff_D:ntr_puff:
:flux_tot_D:tot_flux:
:flux_bln_D:err_totl:
@page: D ion dN/dt, s^{-1}
:flx_d/dt_D:dN/dt:
@page: D content dln(N)/dt, s^{-1}
:flux_ttr_D:dln(N)/dt:
@page: Total relative error in D balance
:bln_blnr_D:err/sum:
@page: Flux balance total T, s^{-1}
:ion_core_T:ion_core:
:ntr_core_T:ntr_core:
:ion_targ_T:ion_targ:
:ntr_targ_T:ntr_targ:
:ion_wall_T:ion_wall:
:ntr_wall_T:ntr_wall:
:ntr_puff_T:ntr_puff:
:flux_tot_T:tot_flux:
:flux_bln_T:err_totl:
@page: T ion dN/dt, s^{-1}
:flx_d/dt_T:dN/dt:
@page: T content dln(N)/dt, s^{-1}
:flux_ttr_T:dln(N)/dt:
@page: Total relative error in T balance
:bln_blnr_T:err/sum:
@page: Flux balance total He, s^{-1}
:ion_core_He:ion_core:
:ntr_core_He:ntr_core:
:ion_targ_He:ion_targ:
:ntr_targ_He:ntr_targ:
:ion_wall_He:ion_wall:
:ntr_wall_He:ntr_wall:
:ntr_puff_He:ntr_puff:
:flux_tot_He:tot_flux:
:flux_bln_He:err_totl:
@page: He ion dN/dt, s^{-1}
:flx_d/dt_He:dN/dt:
@page: He content dln(N)/dt, s^{-1}
:flux_ttr_He:dln(N)/dt:
@page: Total relative error in He balance
:bln_blnr_He:err/sum:
@page: Flux balance total Li, s^{-1}
:ion_core_Li:ion_core:
:ntr_core_Li:ntr_core:
:ion_targ_Li:ion_targ:
:ntr_targ_Li:ntr_targ:
:ion_wall_Li:ion_wall:
:ntr_wall_Li:ntr_wall:
:ntr_puff_Li:ntr_puff:
:flux_tot_Li:tot_flux:
:flux_bln_Li:err_totl:
@page: Li ion dN/dt, s^{-1}
:flx_d/dt_Li:dN/dt:
@page: Li content dln(N)/dt, s^{-1}
:flux_ttr_Li:dln(N)/dt:
@page: Total relative error in Li balance
:bln_blnr_Li:err/sum:
@page: Flux balance total Be, s^{-1}
:ion_core_Be:ion_core:
:ntr_core_Be:ntr_core:
:ion_targ_Be:ion_targ:
:ntr_targ_Be:ntr_targ:
:ion_wall_Be:ion_wall:
:ntr_wall_Be:ntr_wall:
:ntr_puff_Be:ntr_puff:
:flux_tot_Be:tot_flux:
:flux_bln_Be:err_totl:
@page: Be ion dN/dt, s^{-1}
:flx_d/dt_Be:dN/dt:
@page: Be content dln(N)/dt, s^{-1}
:flux_ttr_Be:dln(N)/dt:
@page: Total relative error in Be balance
:bln_blnr_Be:err/sum:
@page: Flux balance total B, s^{-1}
:ion_core_B:ion_core:
:ntr_core_B:ntr_core:
:ion_targ_B:ion_targ:
:ntr_targ_B:ntr_targ:
:ion_wall_B:ion_wall:
:ntr_wall_B:ntr_wall:
:ntr_puff_B:ntr_puff:
:flux_tot_B:tot_flux:
:flux_bln_B:err_totl:
@page: B ion dN/dt, s^{-1}
:flx_d/dt_B:dN/dt:
@page: B content dln(N)/dt, s^{-1}
:flux_ttr_B:dln(N)/dt:
@page: Total relative error in B balance
:bln_blnr_B:err/sum:
@page: Flux balance total C, s^{-1}
:ion_core_C:ion_core:
:ntr_core_C:ntr_core:
:ion_targ_C:ion_targ:
:ntr_targ_C:ntr_targ:
:ion_wall_C:ion_wall:
:ntr_wall_C:ntr_wall:
:ntr_puff_C:ntr_puff:
:flux_tot_C:tot_flux:
:flux_bln_C:err_totl:
@page: C ion dN/dt, s^{-1}
:flx_d/dt_C:dN/dt:
@page: C content dln(N)/dt, s^{-1}
:flux_ttr_C:dln(N)/dt:
@page: Total relative error in C balance
:bln_blnr_C:err/sum:
@page: Flux balance total N, s^{-1}
:ion_core_N:ion_core:
:ntr_core_N:ntr_core:
:ion_targ_N:ion_targ:
:ntr_targ_N:ntr_targ:
:ion_wall_N:ion_wall:
:ntr_wall_N:ntr_wall:
:ntr_puff_N:ntr_puff:
:flux_tot_N:tot_flux:
:flux_bln_N:err_totl:
@page: N ion dN/dt, s^{-1}
:flx_d/dt_N:dN/dt:
@page: N content dln(N)/dt, s^{-1}
:flux_ttr_N:dln(N)/dt:
@page: Total relative error in N balance
:bln_blnr_N:err/sum:
@page: Flux balance total Ne, s^{-1}
:ion_core_Ne:ion_core:
:ntr_core_Ne:ntr_core:
:ion_targ_Ne:ion_targ:
:ntr_targ_Ne:ntr_targ:
:ion_wall_Ne:ion_wall:
:ntr_wall_Ne:ntr_wall:
:ntr_puff_Ne:ntr_puff:
:flux_tot_Ne:tot_flux:
:flux_bln_Ne:err_totl:
@page: Ne ion dN/dt, s^{-1}
:flx_d/dt_Ne:dN/dt:
@page: Ne content dln(N)/dt, s^{-1}
:flux_ttr_Ne:dln(N)/dt:
@page: Total relative error in Ne balance
:bln_blnr_Ne:err/sum:
@page: Flux balance total Ar, s^{-1}
:ion_core_Ar:ion_core:
:ntr_core_Ar:ntr_core:
:ion_targ_Ar:ion_targ:
:ntr_targ_Ar:ntr_targ:
:ion_wall_Ar:ion_wall:
:ntr_wall_Ar:ntr_wall:
:ntr_puff_Ar:ntr_puff:
:flux_tot_Ar:tot_flux:
:flux_bln_Ar:err_totl:
@page: Ar ion dN/dt, s^{-1}
:flx_d/dt_Ar:dN/dt:
@page: Ar content dln(N)/dt, s^{-1}
:flux_ttr_Ar:dln(N)/dt:
@page: Total relative error in Ar balance
:bln_blnr_Ar:err/sum:
@page: Flux balance total W, s^{-1}
:ion_core_W:ion_core:
:ntr_core_W:ntr_core:
:ion_targ_W:ion_targ:
:ntr_targ_W:ntr_targ:
:ion_wall_W:ion_wall:
:ntr_wall_W:ntr_wall:
:ntr_puff_W:ntr_puff:
:flux_tot_W:tot_flux:
:flux_bln_W:err_totl:
@page: W ion dN/dt, s^{-1}
:flx_d/dt_W:dN/dt:
@page: W content dln(N)/dt, s^{-1}
:flux_ttr_W:dln(N)/dt:
@page: Total relative error in W balance
:bln_blnr_W:
@file:blnn_SPb
@page: Hydrogenic ionization source, s^{-1}
:src_ioniz_H:H:
:src_ioniz_D:D:
:src_ioniz_T:T:
@file:integral
@page: Recombination sink, s^{-1}
:SNI_rcmb::6.242e+18
@page: Recombination power source, W
:SEE_rcmb:to electrons:
:SEI_rcmb:to ions:
@page: Radiation losses total, MW
:Brmsreg:bremsstrahlung:-1.e-6
:imp_rad:impurity:-1.e-6
:neut_rad:neutrals:-1.e-6
:tot_rad:total:-1.e-6
@page: Bremsstrahlung radiation per region, MW
:Brmsreg_01:core_lt:-1.e-6
:Brmsreg_02:SOL_lt:-1.e-6
:Brmsreg_03:inner_lt:-1.e-6
:Brmsreg_04:outer_lt:-1.e-6
:Brmsreg_05:core_rt:-1.e-6
:Brmsreg_06:SOL_rt:-1.e-6
:Brmsreg_07:inner_rt:-1.e-6
:Brmsreg_08:outer_rt:-1.e-6
@page: Impurity radiation per region, MW
:imp_rad_01:core_lt:-1.e-6
:imp_rad_02:SOL_lt:-1.e-6
:imp_rad_03:inner_lt:-1.e-6
:imp_rad_04:outer_lt:-1.e-6
:imp_rad_05:core_rt:-1.e-6
:imp_rad_06:SOL_rt:-1.e-6
:imp_rad_07:inner_rt:-1.e-6
:imp_rad_08:outer_rt:-1.e-6
@page: Neutral radiation per region, MW
:neu_rad_01:core_lt:-1.e-6
:neu_rad_02:SOL_lt:-1.e-6
:neu_rad_03:inner_lt:-1.e-6
:neu_rad_04:outer_lt:-1.e-6
:neu_rad_05:core_rt:-1.e-6
:neu_rad_06:SOL_rt:-1.e-6
:neu_rad_07:inner_rt:-1.e-6
:neu_rad_08:outer_rt:-1.e-6
@page: Total radiation per region, MW
:tot_rad_01:core_lt:-1.e-6
:tot_rad_02:SOL_lt:-1.e-6
:tot_rad_03:inner_lt:-1.e-6
:tot_rad_04:outer_lt:-1.e-6
:tot_rad_05:core_rt:-1.e-6
:tot_rad_06:SOL_rt:-1.e-6
:tot_rad_07:inner_rt:-1.e-6
:tot_rad_08:outer_rt:-1.e-6
@page: Total number of electrons per region
:N_e_reg_01:core_lt:
:N_e_reg_02:SOL_lt:
:N_e_reg_03:inner_lt:
:N_e_reg_04:outer_lt:
:N_e_reg_05:core_lt:
:N_e_reg_06:SOL_rt:
:N_e_reg_07:inner_rt:
:N_e_reg_08:outer_rt:
@page: Total number of H ions per region
:N_i_reg_01_H:core_lt:
:N_i_reg_02_H:SOL_lt:
:N_i_reg_03_H:inner_lt:
:N_i_reg_04_H:outer_lt:
:N_i_reg_05_H:core_rt:
:N_i_reg_06_H:SOL_rt:
:N_i_reg_07_H:inner_rt:
:N_i_reg_08_H:outer_rt:
@page: Total number of H neutrals per region
:N_a_reg_01_H:core_lt:
:N_a_reg_02_H:SOL_lt:
:N_a_reg_03_H:inner_lt:
:N_a_reg_04_H:outer_lt:
:N_a_reg_05_H:core_rt:
:N_a_reg_06_H:SOL_rt:
:N_a_reg_07_H:inner_rt:
:N_a_reg_08_H:outer_rt:
@page: Total number of D ions per region
:N_i_reg_01_D:core_lt:
:N_i_reg_02_D:SOL_lt:
:N_i_reg_03_D:inner_lt:
:N_i_reg_04_D:outer_lt:
:N_i_reg_05_D:core_rt:
:N_i_reg_06_D:SOL_rt:
:N_i_reg_07_D:inner_rt:
:N_i_reg_08_D:outer_rt:
@page: Total number of D neutrals per region
:N_a_reg_01_D:core_lt:
:N_a_reg_02_D:SOL_lt:
:N_a_reg_03_D:inner_lt:
:N_a_reg_04_D:outer_lt:
:N_a_reg_05_D:core_rt:
:N_a_reg_06_D:SOL_rt:
:N_a_reg_07_D:inner_rt:
:N_a_reg_08_D:outer_rt:
@page: Total number of He ions per region
:N_i_reg_01_He:core_lt:
:N_i_reg_02_He:SOL_lt:
:N_i_reg_03_He:inner_lt:
:N_i_reg_04_He:outer_lt:
:N_i_reg_05_He:core_rt:
:N_i_reg_06_He:SOL_rt:
:N_i_reg_07_He:inner_rt:
:N_i_reg_08_He:outer_rt:
@page: Total number of He neutrals per region
:N_a_reg_01_He:core_lt:
:N_a_reg_02_He:SOL_lt:
:N_a_reg_03_He:inner_lt:
:N_a_reg_04_He:outer_lt:
:N_a_reg_05_He:core_rt:
:N_a_reg_06_He:SOL_rt:
:N_a_reg_07_He:inner_rt:
:N_a_reg_08_He:outer_rt:
@page: Total number of Li ions per region
:N_i_reg_01_Li:core_lt:
:N_i_reg_02_Li:SOL_lt:
:N_i_reg_03_Li:inner_lt:
:N_i_reg_04_Li:outer_lt:
:N_i_reg_05_Li:core_rt:
:N_i_reg_06_Li:SOL_rt:
:N_i_reg_07_Li:inner_rt:
:N_i_reg_08_Li:outer_rt:
@page: Total number of Li neutrals per region
:N_a_reg_01_Li:core_lt:
:N_a_reg_02_Li:SOL_lt:
:N_a_reg_03_Li:inner_lt:
:N_a_reg_04_Li:outer_lt:
:N_a_reg_05_Li:core_rt:
:N_a_reg_06_Li:SOL_rt:
:N_a_reg_07_Li:inner_rt:
:N_a_reg_08_Li:outer_rt:
@page: Total number of Be ions per region
:N_i_reg_01_Be:core_lt:
:N_i_reg_02_Be:SOL_lt:
:N_i_reg_03_Be:inner_lt:
:N_i_reg_04_Be:outer_lt:
:N_i_reg_05_Be:core_rt:
:N_i_reg_06_Be:SOL_rt:
:N_i_reg_07_Be:inner_rt:
:N_i_reg_08_Be:outer_rt:
@page: Total number of Be neutrals per region
:N_a_reg_01_Be:core_lt:
:N_a_reg_02_Be:SOL_lt:
:N_a_reg_03_Be:inner_lt:
:N_a_reg_04_Be:outer_lt:
:N_a_reg_05_Be:core_rt:
:N_a_reg_06_Be:SOL_rt:
:N_a_reg_07_Be:inner_rt:
:N_a_reg_08_Be:outer_rt:
@page: Total number of B ions per region
:N_i_reg_01_B:core_lt:
:N_i_reg_02_B:SOL_lt:
:N_i_reg_03_B:inner_lt:
:N_i_reg_04_B:outer_lt:
:N_i_reg_05_B:core_rt:
:N_i_reg_06_B:SOL_rt:
:N_i_reg_07_B:inner_rt:
:N_i_reg_08_B:outer_rt:
@page: Total number of B neutrals per region
:N_a_reg_01_B:core_lt:
:N_a_reg_02_B:SOL_lt:
:N_a_reg_03_B:inner_lt:
:N_a_reg_04_B:outer_lt:
:N_a_reg_05_B:core_rt:
:N_a_reg_06_B:SOL_rt:
:N_a_reg_07_B:inner_rt:
:N_a_reg_08_B:outer_rt:
@page: Total number of C ions per region
:N_i_reg_01_C:core_lt:
:N_i_reg_02_C:SOL_lt:
:N_i_reg_03_C:inner_lt:
:N_i_reg_04_C:outer_lt:
:N_i_reg_05_C:core_rt:
:N_i_reg_06_C:SOL_rt:
:N_i_reg_07_C:inner_rt:
:N_i_reg_08_C:outer_rt:
@page: Total number of C neutrals per region
:N_a_reg_01_C:core_lt:
:N_a_reg_02_C:SOL_lt:
:N_a_reg_03_C:inner_lt:
:N_a_reg_04_C:outer_lt:
:N_a_reg_05_C:core_rt:
:N_a_reg_06_C:SOL_rt:
:N_a_reg_07_C:inner_rt:
:N_a_reg_08_C:outer_rt:
@page: Total number of N ions per region
:N_i_reg_01_N:core_lt:
:N_i_reg_02_N:SOL_lt:
:N_i_reg_03_N:inner_lt:
:N_i_reg_04_N:outer_lt:
:N_i_reg_05_N:core_rt:
:N_i_reg_06_N:SOL_rt:
:N_i_reg_07_N:inner_rt:
:N_i_reg_08_N:outer_rt:
@page: Total number of N neutrals per region
:N_a_reg_01_N:core_lt:
:N_a_reg_02_N:SOL_lt:
:N_a_reg_03_N:inner_lt:
:N_a_reg_04_N:outer_lt:
:N_a_reg_05_N:core_rt:
:N_a_reg_06_N:SOL_rt:
:N_a_reg_07_N:inner_rt:
:N_a_reg_08_N:outer_rt:
@page: Total number of Ne ions per region
:N_i_reg_01_Ne:core_lt:
:N_i_reg_02_Ne:SOL_lt:
:N_i_reg_03_Ne:inner_lt:
:N_i_reg_04_Ne:outer_lt:
:N_i_reg_05_Ne:core_rt:
:N_i_reg_06_Ne:SOL_rt:
:N_i_reg_07_Ne:inner_rt:
:N_i_reg_08_Ne:outer_rt:
@page: Total number of Ne neutrals per region
:N_a_reg_01_Ne:core_lt:
:N_a_reg_02_Ne:SOL_lt:
:N_a_reg_03_Ne:inner_lt:
:N_a_reg_04_Ne:outer_lt:
:N_a_reg_05_Ne:core_rt:
:N_a_reg_06_Ne:SOL_rt:
:N_a_reg_07_Ne:inner_rt:
:N_a_reg_08_Ne:outer_rt:
@page: Total number of Ar ions per region
:N_i_reg_01_Ar:core_lt:
:N_i_reg_02_Ar:SOL_lt:
:N_i_reg_03_Ar:inner_lt:
:N_i_reg_04_Ar:outer_lt:
:N_i_reg_05_Ar:core_rt:
:N_i_reg_06_Ar:SOL_rt:
:N_i_reg_07_Ar:inner_rt:
:N_i_reg_08_Ar:outer_rt:
@page: Total number of Ar neutrals per region
:N_a_reg_01_Ar:core_lt:
:N_a_reg_02_Ar:SOL_lt:
:N_a_reg_03_Ar:inner_lt:
:N_a_reg_04_Ar:outer_lt:
:N_a_reg_05_Ar:core_rt:
:N_a_reg_06_Ar:SOL_rt:
:N_a_reg_07_Ar:inner_rt:
:N_a_reg_08_Ar:outer_rt:
@page: Total number of W ions per region
:N_i_reg_01_W:core_lt:
:N_i_reg_02_W:SOL_lt:
:N_i_reg_03_W:inner_lt:
:N_i_reg_04_W:outer_lt:
:N_i_reg_05_W:core_rt:
:N_i_reg_06_W:SOL_rt:
:N_i_reg_07_W:inner_rt:
:N_i_reg_08_W:outer_rt:
@page: Total number of W neutrals per region
:N_a_reg_01_W:core_lt:
:N_a_reg_02_W:SOL_lt:
:N_a_reg_03_W:inner_lt:
:N_a_reg_04_W:outer_lt:
:N_a_reg_05_W:core_rt:
:N_a_reg_06_W:SOL_rt:
:N_a_reg_07_W:inner_rt:
:N_a_reg_08_W:outer_rt:
@page: Total number of electrons in the egde
:N_s_sle:N_{e}^{edge}:
@page: Total number of H ions in the egde
:N_s_sli_H:N_{i,H}^{edge}:
@page: Total number of H particles in the egde
:N_s_slt_H:N_{H}^{edge}:
@page: Total number of D ions in the egde
:N_s_sli_D:N_{i,D}^{edge}:
@page: Total number of D particles in the egde
:N_s_slt_D:N_{D}^{edge}:
@page: Total number of He ions in the egde
:N_s_sli_He:N_{i,He}^{edge}:
@page: Total number of He particles in the egde
:N_s_slt_He:N_{He}^{edge}:
@page: Total number of Li ions in the egde
:N_s_sli_Li:N_{i,Li}^{edge}:
@page: Total number of Li particles in the egde
:N_s_slt_Li:N_{Li}^{edge}:
@page: Total number of Be ions in the egde
:N_s_sli_Be:N_{i,Be}^{edge}:
@page: Total number of Be particles in the egde
:N_s_slt_Be:N_{Be}^{edge}:
@page: Total number of B ions in the egde
:N_s_sli_B:N_{i,B}^{edge}:
@page: Total number of B particles in the egde
:N_s_slt_B:N_{B}^{edge}:
@page: Total number of C ions in the egde
:N_s_sli_C:N_{i,C}^{edge}:
@page: Total number of C particles in the egde
:N_s_slt_C:N_{C}^{edge}:
@page: Total number of N ions in the egde
:N_s_sli_N:N_{i,N}^{edge}:
@page: Total number of N particles in the egde
:N_s_slt_N:N_{N}^{edge}:
@page: Total number of Ne ions in the egde
:N_s_sli_Ne:N_{i,Ne}^{edge}:
@page: Total number of Ne particles in the egde
:N_s_slt_Ne:N_{Ne}^{edge}:
@page: Total number of Ar ions in the egde
:N_s_sli_Ar:N_{i,Ar}^{edge}:
@page: Total number of Ar particles in the egde
:N_s_slt_Ar:N_{Ar}^{edge}:
@file:residuals
@page: Electron energy equation residuals
@iter:100
@log:
:resee01:core_lt:
:resee02:SOL_lt:
:resee03:inner_lt:
:resee04:outer_lt:
:resee05:core_rt:
:resee06:SOL_rt:
:resee07:inner_rt:
:resee08:outer_rt:
@page: Ion energy equation residuals
@iter:100
@log:
:resei01:core_lt:
:resei02:SOL_lt:
:resei03:inner_lt:
:resei04:outer_lt:
:resei05:core_rt:
:resei06:SOL_rt:
:resei07:inner_rt:
:resei08:outer_rt:
@page: Continuity balance equation residuals left core
@iter:100
@log:
:resco01_01_H:
:resco01_01_D:
:resco01_01_He:
:resco01_02_He:
:resco01_01_Li:
:resco01_02_Li:
:resco01_03_Li:
:resco01_01_Be:
:resco01_02_Be:
:resco01_03_Be:
:resco01_04_Be:
:resco01_01_B:
:resco01_02_B:
:resco01_03_B:
:resco01_04_B:
:resco01_01_C:
:resco01_02_C:
:resco01_03_C:
:resco01_04_C:
:resco01_05_C:
:resco01_06_C:
:resco01_01_N:
:resco01_02_N:
:resco01_03_N:
:resco01_04_N:
:resco01_05_N:
:resco01_06_N:
:resco01_07_N:
:resco01_01_Ne:
:resco01_02_Ne:
:resco01_03_Ne:
:resco01_04_Ne:
:resco01_05_Ne:
:resco01_06_Ne:
:resco01_07_Ne:
:resco01_08_Ne:
:resco01_09_Ne:
:resco01_10_Ne:
:resco01_01_Ar:
:resco01_02_Ar:
:resco01_03_Ar:
:resco01_04_Ar:
:resco01_05_Ar:
:resco01_06_Ar:
:resco01_07_Ar:
:resco01_08_Ar:
:resco01_09_Ar:
:resco01_11_Ar:
:resco01_12_Ar:
:resco01_13_Ar:
:resco01_14_Ar:
:resco01_15_Ar:
:resco01_16_Ar:
:resco01_17_Ar:
:resco01_18_Ar:
:resco01_01_W:
:resco01_02_W:
:resco01_03_W:
:resco01_04_W:
:resco01_05_W:
:resco01_06_W:
:resco01_07_W:
:resco01_08_W:
:resco01_09_W:
:resco01_11_W:
:resco01_12_W:
:resco01_13_W:
:resco01_14_W:
:resco01_15_W:
:resco01_16_W:
:resco01_17_W:
:resco01_18_W:
:resco01_19_W:
:resco01_20_W:
:resco01_21_W:
:resco01_22_W:
:resco01_23_W:
:resco01_24_W:
:resco01_25_W:
:resco01_26_W:
:resco01_27_W:
@page: Continuity balance equation residuals left SOL
@iter:100
@log:
:resco02_01_H:
:resco02_01_D:
:resco02_01_He:
:resco02_02_He:
:resco02_01_Li:
:resco02_02_Li:
:resco02_03_Li:
:resco02_01_Be:
:resco02_02_Be:
:resco02_03_Be:
:resco02_04_Be:
:resco02_01_B:
:resco02_02_B:
:resco02_03_B:
:resco02_04_B:
:resco02_01_C:
:resco02_02_C:
:resco02_03_C:
:resco02_04_C:
:resco02_05_C:
:resco02_06_C:
:resco02_01_N:
:resco02_02_N:
:resco02_03_N:
:resco02_04_N:
:resco02_05_N:
:resco02_06_N:
:resco02_07_N:
:resco02_01_Ne:
:resco02_02_Ne:
:resco02_03_Ne:
:resco02_04_Ne:
:resco02_05_Ne:
:resco02_06_Ne:
:resco02_07_Ne:
:resco02_08_Ne:
:resco02_09_Ne:
:resco02_10_Ne:
:resco02_01_Ar:
:resco02_02_Ar:
:resco02_03_Ar:
:resco02_04_Ar:
:resco02_05_Ar:
:resco02_06_Ar:
:resco02_07_Ar:
:resco02_08_Ar:
:resco02_09_Ar:
:resco02_11_Ar:
:resco02_12_Ar:
:resco02_13_Ar:
:resco02_14_Ar:
:resco02_15_Ar:
:resco02_16_Ar:
:resco02_17_Ar:
:resco02_18_Ar:
:resco02_01_W:
:resco02_02_W:
:resco02_03_W:
:resco02_04_W:
:resco02_05_W:
:resco02_06_W:
:resco02_07_W:
:resco02_08_W:
:resco02_09_W:
:resco02_11_W:
:resco02_12_W:
:resco02_13_W:
:resco02_14_W:
:resco02_15_W:
:resco02_16_W:
:resco02_17_W:
:resco02_18_W:
:resco02_19_W:
:resco02_20_W:
:resco02_21_W:
:resco02_22_W:
:resco02_23_W:
:resco02_24_W:
:resco02_25_W:
:resco02_26_W:
:resco02_27_W:
@page: Continuity balance equation residuals left inner
@iter:100
@log:
:resco03_01_H:
:resco03_01_D:
:resco03_01_He:
:resco03_02_He:
:resco03_01_Li:
:resco03_02_Li:
:resco03_03_Li:
:resco03_01_Be:
:resco03_02_Be:
:resco03_03_Be:
:resco03_04_Be:
:resco03_01_B:
:resco03_02_B:
:resco03_03_B:
:resco03_04_B:
:resco03_01_C:
:resco03_02_C:
:resco03_03_C:
:resco03_04_C:
:resco03_05_C:
:resco03_06_C:
:resco03_01_N:
:resco03_02_N:
:resco03_03_N:
:resco03_04_N:
:resco03_05_N:
:resco03_06_N:
:resco03_07_N:
:resco03_01_Ne:
:resco03_02_Ne:
:resco03_03_Ne:
:resco03_04_Ne:
:resco03_05_Ne:
:resco03_06_Ne:
:resco03_07_Ne:
:resco03_08_Ne:
:resco03_09_Ne:
:resco03_10_Ne:
:resco03_01_Ar:
:resco03_02_Ar:
:resco03_03_Ar:
:resco03_04_Ar:
:resco03_05_Ar:
:resco03_06_Ar:
:resco03_07_Ar:
:resco03_08_Ar:
:resco03_09_Ar:
:resco03_11_Ar:
:resco03_12_Ar:
:resco03_13_Ar:
:resco03_14_Ar:
:resco03_15_Ar:
:resco03_16_Ar:
:resco03_17_Ar:
:resco03_18_Ar:
:resco03_01_W:
:resco03_02_W:
:resco03_03_W:
:resco03_04_W:
:resco03_05_W:
:resco03_06_W:
:resco03_07_W:
:resco03_08_W:
:resco03_09_W:
:resco03_11_W:
:resco03_12_W:
:resco03_13_W:
:resco03_14_W:
:resco03_15_W:
:resco03_16_W:
:resco03_17_W:
:resco03_18_W:
:resco03_19_W:
:resco03_20_W:
:resco03_21_W:
:resco03_22_W:
:resco03_23_W:
:resco03_24_W:
:resco03_25_W:
:resco03_26_W:
:resco03_27_W:
@page: Continuity balance equation residuals left outer
@iter:100
@log:
:resco04_01_H:
:resco04_01_D:
:resco04_01_He:
:resco04_02_He:
:resco04_01_Li:
:resco04_02_Li:
:resco04_03_Li:
:resco04_01_Be:
:resco04_02_Be:
:resco04_03_Be:
:resco04_04_Be:
:resco04_01_B:
:resco04_02_B:
:resco04_03_B:
:resco04_04_B:
:resco04_01_C:
:resco04_02_C:
:resco04_03_C:
:resco04_04_C:
:resco04_05_C:
:resco04_06_C:
:resco04_01_N:
:resco04_02_N:
:resco04_03_N:
:resco04_04_N:
:resco04_05_N:
:resco04_06_N:
:resco04_07_N:
:resco04_01_Ne:
:resco04_02_Ne:
:resco04_03_Ne:
:resco04_04_Ne:
:resco04_05_Ne:
:resco04_06_Ne:
:resco04_07_Ne:
:resco04_08_Ne:
:resco04_09_Ne:
:resco04_10_Ne:
:resco04_01_Ar:
:resco04_02_Ar:
:resco04_03_Ar:
:resco04_04_Ar:
:resco04_05_Ar:
:resco04_06_Ar:
:resco04_07_Ar:
:resco04_08_Ar:
:resco04_09_Ar:
:resco04_11_Ar:
:resco04_12_Ar:
:resco04_13_Ar:
:resco04_14_Ar:
:resco04_15_Ar:
:resco04_16_Ar:
:resco04_17_Ar:
:resco04_18_Ar:
:resco04_01_W:
:resco04_02_W:
:resco04_03_W:
:resco04_04_W:
:resco04_05_W:
:resco04_06_W:
:resco04_07_W:
:resco04_08_W:
:resco04_09_W:
:resco04_11_W:
:resco04_12_W:
:resco04_13_W:
:resco04_14_W:
:resco04_15_W:
:resco04_16_W:
:resco04_17_W:
:resco04_18_W:
:resco04_19_W:
:resco04_20_W:
:resco04_21_W:
:resco04_22_W:
:resco04_23_W:
:resco04_24_W:
:resco04_25_W:
:resco04_26_W:
:resco04_27_W:
@page: Continuity balance equation residuals right core
@iter:100
@log:
:resco05_01_H:
:resco05_01_D:
:resco05_01_He:
:resco05_02_He:
:resco05_01_Li:
:resco05_02_Li:
:resco05_03_Li:
:resco05_01_Be:
:resco05_02_Be:
:resco05_03_Be:
:resco05_04_Be:
:resco05_01_B:
:resco05_02_B:
:resco05_03_B:
:resco05_04_B:
:resco05_01_C:
:resco05_02_C:
:resco05_03_C:
:resco05_04_C:
:resco05_05_C:
:resco05_06_C:
:resco05_01_N:
:resco05_02_N:
:resco05_03_N:
:resco05_04_N:
:resco05_05_N:
:resco05_06_N:
:resco05_07_N:
:resco05_01_Ne:
:resco05_02_Ne:
:resco05_03_Ne:
:resco05_04_Ne:
:resco05_05_Ne:
:resco05_06_Ne:
:resco05_07_Ne:
:resco05_08_Ne:
:resco05_09_Ne:
:resco05_10_Ne:
:resco05_01_Ar:
:resco05_02_Ar:
:resco05_03_Ar:
:resco05_04_Ar:
:resco05_05_Ar:
:resco05_06_Ar:
:resco05_07_Ar:
:resco05_08_Ar:
:resco05_09_Ar:
:resco05_11_Ar:
:resco05_12_Ar:
:resco05_13_Ar:
:resco05_14_Ar:
:resco05_15_Ar:
:resco05_16_Ar:
:resco05_17_Ar:
:resco05_18_Ar:
:resco05_01_W:
:resco05_02_W:
:resco05_03_W:
:resco05_04_W:
:resco05_05_W:
:resco05_06_W:
:resco05_07_W:
:resco05_08_W:
:resco05_09_W:
:resco05_11_W:
:resco05_12_W:
:resco05_13_W:
:resco05_14_W:
:resco05_15_W:
:resco05_16_W:
:resco05_17_W:
:resco05_18_W:
:resco05_19_W:
:resco05_20_W:
:resco05_21_W:
:resco05_22_W:
:resco05_23_W:
:resco05_24_W:
:resco05_25_W:
:resco05_26_W:
:resco05_27_W:
@page: Continuity balance equation residuals right SOL
@iter:100
@log:
:resco06_01_H:
:resco06_01_D:
:resco06_01_He:
:resco06_02_He:
:resco06_01_Li:
:resco06_02_Li:
:resco06_03_Li:
:resco06_01_Be:
:resco06_02_Be:
:resco06_03_Be:
:resco06_04_Be:
:resco06_01_B:
:resco06_02_B:
:resco06_03_B:
:resco06_04_B:
:resco06_01_C:
:resco06_02_C:
:resco06_03_C:
:resco06_04_C:
:resco06_05_C:
:resco06_06_C:
:resco06_01_N:
:resco06_02_N:
:resco06_03_N:
:resco06_04_N:
:resco06_05_N:
:resco06_06_N:
:resco06_07_N:
:resco06_01_Ne:
:resco06_02_Ne:
:resco06_03_Ne:
:resco06_04_Ne:
:resco06_05_Ne:
:resco06_06_Ne:
:resco06_07_Ne:
:resco06_08_Ne:
:resco06_09_Ne:
:resco06_10_Ne:
:resco06_01_Ar:
:resco06_02_Ar:
:resco06_03_Ar:
:resco06_04_Ar:
:resco06_05_Ar:
:resco06_06_Ar:
:resco06_07_Ar:
:resco06_08_Ar:
:resco06_09_Ar:
:resco06_11_Ar:
:resco06_12_Ar:
:resco06_13_Ar:
:resco06_14_Ar:
:resco06_15_Ar:
:resco06_16_Ar:
:resco06_17_Ar:
:resco06_18_Ar:
:resco06_01_W:
:resco06_02_W:
:resco06_03_W:
:resco06_04_W:
:resco06_05_W:
:resco06_06_W:
:resco06_07_W:
:resco06_08_W:
:resco06_09_W:
:resco06_11_W:
:resco06_12_W:
:resco06_13_W:
:resco06_14_W:
:resco06_15_W:
:resco06_16_W:
:resco06_17_W:
:resco06_18_W:
:resco06_19_W:
:resco06_20_W:
:resco06_21_W:
:resco06_22_W:
:resco06_23_W:
:resco06_24_W:
:resco06_25_W:
:resco06_26_W:
:resco06_27_W:
@page: Continuity balance equation residuals right inner
@iter:100
@log:
:resco07_01_H:
:resco07_01_D:
:resco07_01_He:
:resco07_02_He:
:resco07_01_Li:
:resco07_02_Li:
:resco07_03_Li:
:resco07_01_Be:
:resco07_02_Be:
:resco07_03_Be:
:resco07_04_Be:
:resco07_01_B:
:resco07_02_B:
:resco07_03_B:
:resco07_04_B:
:resco07_01_C:
:resco07_02_C:
:resco07_03_C:
:resco07_04_C:
:resco07_05_C:
:resco07_06_C:
:resco07_01_N:
:resco07_02_N:
:resco07_03_N:
:resco07_04_N:
:resco07_05_N:
:resco07_06_N:
:resco07_07_N:
:resco07_01_Ne:
:resco07_02_Ne:
:resco07_03_Ne:
:resco07_04_Ne:
:resco07_05_Ne:
:resco07_06_Ne:
:resco07_07_Ne:
:resco07_08_Ne:
:resco07_09_Ne:
:resco07_10_Ne:
:resco07_01_Ar:
:resco07_02_Ar:
:resco07_03_Ar:
:resco07_04_Ar:
:resco07_05_Ar:
:resco07_06_Ar:
:resco07_07_Ar:
:resco07_08_Ar:
:resco07_09_Ar:
:resco07_11_Ar:
:resco07_12_Ar:
:resco07_13_Ar:
:resco07_14_Ar:
:resco07_15_Ar:
:resco07_16_Ar:
:resco07_17_Ar:
:resco07_18_Ar:
:resco07_01_W:
:resco07_02_W:
:resco07_03_W:
:resco07_04_W:
:resco07_05_W:
:resco07_06_W:
:resco07_07_W:
:resco07_08_W:
:resco07_09_W:
:resco07_11_W:
:resco07_12_W:
:resco07_13_W:
:resco07_14_W:
:resco07_15_W:
:resco07_16_W:
:resco07_17_W:
:resco07_18_W:
:resco07_19_W:
:resco07_20_W:
:resco07_21_W:
:resco07_22_W:
:resco07_23_W:
:resco07_24_W:
:resco07_25_W:
:resco07_26_W:
:resco07_27_W:
@page: Continuity balance equation residuals right outer
@iter:100
@log:
:resco08_01_H:
:resco08_01_D:
:resco08_01_He:
:resco08_02_He:
:resco08_01_Li:
:resco08_02_Li:
:resco08_03_Li:
:resco08_01_Be:
:resco08_02_Be:
:resco08_03_Be:
:resco08_04_Be:
:resco08_01_B:
:resco08_02_B:
:resco08_03_B:
:resco08_04_B:
:resco08_01_C:
:resco08_02_C:
:resco08_03_C:
:resco08_04_C:
:resco08_05_C:
:resco08_06_C:
:resco08_01_N:
:resco08_02_N:
:resco08_03_N:
:resco08_04_N:
:resco08_05_N:
:resco08_06_N:
:resco08_07_N:
:resco08_01_Ne:
:resco08_02_Ne:
:resco08_03_Ne:
:resco08_04_Ne:
:resco08_05_Ne:
:resco08_06_Ne:
:resco08_07_Ne:
:resco08_08_Ne:
:resco08_09_Ne:
:resco08_10_Ne:
:resco08_01_Ar:
:resco08_02_Ar:
:resco08_03_Ar:
:resco08_04_Ar:
:resco08_05_Ar:
:resco08_06_Ar:
:resco08_07_Ar:
:resco08_08_Ar:
:resco08_09_Ar:
:resco08_11_Ar:
:resco08_12_Ar:
:resco08_13_Ar:
:resco08_14_Ar:
:resco08_15_Ar:
:resco08_16_Ar:
:resco08_17_Ar:
:resco08_18_Ar:
:resco08_01_W:
:resco08_02_W:
:resco08_03_W:
:resco08_04_W:
:resco08_05_W:
:resco08_06_W:
:resco08_07_W:
:resco08_08_W:
:resco08_09_W:
:resco08_11_W:
:resco08_12_W:
:resco08_13_W:
:resco08_14_W:
:resco08_15_W:
:resco08_16_W:
:resco08_17_W:
:resco08_18_W:
:resco08_19_W:
:resco08_20_W:
:resco08_21_W:
:resco08_22_W:
:resco08_23_W:
:resco08_24_W:
:resco08_25_W:
:resco08_26_W:
:resco08_27_W:
@page: Momentum balance equation residuals left core
@iter:100
@log:
:resmo01_01_H:
:resmo01_01_D:
:resmo01_01_He:
:resmo01_02_He:
:resmo01_01_Li:
:resmo01_02_Li:
:resmo01_03_Li:
:resmo01_01_Be:
:resmo01_02_Be:
:resmo01_03_Be:
:resmo01_04_Be:
:resmo01_01_B:
:resmo01_02_B:
:resmo01_03_B:
:resmo01_04_B:
:resmo01_01_C:
:resmo01_02_C:
:resmo01_03_C:
:resmo01_04_C:
:resmo01_05_C:
:resmo01_06_C:
:resmo01_01_N:
:resmo01_02_N:
:resmo01_03_N:
:resmo01_04_N:
:resmo01_05_N:
:resmo01_06_N:
:resmo01_07_N:
:resmo01_01_Ne:
:resmo01_02_Ne:
:resmo01_03_Ne:
:resmo01_04_Ne:
:resmo01_05_Ne:
:resmo01_06_Ne:
:resmo01_07_Ne:
:resmo01_08_Ne:
:resmo01_09_Ne:
:resmo01_10_Ne:
:resmo01_01_Ar:
:resmo01_02_Ar:
:resmo01_03_Ar:
:resmo01_04_Ar:
:resmo01_05_Ar:
:resmo01_06_Ar:
:resmo01_07_Ar:
:resmo01_08_Ar:
:resmo01_09_Ar:
:resmo01_11_Ar:
:resmo01_12_Ar:
:resmo01_13_Ar:
:resmo01_14_Ar:
:resmo01_15_Ar:
:resmo01_16_Ar:
:resmo01_17_Ar:
:resmo01_18_Ar:
:resmo01_01_W:
:resmo01_02_W:
:resmo01_03_W:
:resmo01_04_W:
:resmo01_05_W:
:resmo01_06_W:
:resmo01_07_W:
:resmo01_08_W:
:resmo01_09_W:
:resmo01_11_W:
:resmo01_12_W:
:resmo01_13_W:
:resmo01_14_W:
:resmo01_15_W:
:resmo01_16_W:
:resmo01_17_W:
:resmo01_18_W:
:resmo01_19_W:
:resmo01_20_W:
:resmo01_21_W:
:resmo01_22_W:
:resmo01_23_W:
:resmo01_24_W:
:resmo01_25_W:
:resmo01_26_W:
:resmo01_27_W:
@page: Momentum balance equation residuals left SOL
@iter:100
@log:
:resmo02_01_H:
:resmo02_01_D:
:resmo02_01_He:
:resmo02_02_He:
:resmo02_01_Li:
:resmo02_02_Li:
:resmo02_03_Li:
:resmo02_01_Be:
:resmo02_02_Be:
:resmo02_03_Be:
:resmo02_04_Be:
:resmo02_01_B:
:resmo02_02_B:
:resmo02_03_B:
:resmo02_04_B:
:resmo02_01_C:
:resmo02_02_C:
:resmo02_03_C:
:resmo02_04_C:
:resmo02_05_C:
:resmo02_06_C:
:resmo02_01_N:
:resmo02_02_N:
:resmo02_03_N:
:resmo02_04_N:
:resmo02_05_N:
:resmo02_06_N:
:resmo02_07_N:
:resmo02_01_Ne:
:resmo02_02_Ne:
:resmo02_03_Ne:
:resmo02_04_Ne:
:resmo02_05_Ne:
:resmo02_06_Ne:
:resmo02_07_Ne:
:resmo02_08_Ne:
:resmo02_09_Ne:
:resmo02_10_Ne:
:resmo02_01_Ar:
:resmo02_02_Ar:
:resmo02_03_Ar:
:resmo02_04_Ar:
:resmo02_05_Ar:
:resmo02_06_Ar:
:resmo02_07_Ar:
:resmo02_08_Ar:
:resmo02_09_Ar:
:resmo02_11_Ar:
:resmo02_12_Ar:
:resmo02_13_Ar:
:resmo02_14_Ar:
:resmo02_15_Ar:
:resmo02_16_Ar:
:resmo02_17_Ar:
:resmo02_18_Ar:
:resmo02_01_W:
:resmo02_02_W:
:resmo02_03_W:
:resmo02_04_W:
:resmo02_05_W:
:resmo02_06_W:
:resmo02_07_W:
:resmo02_08_W:
:resmo02_09_W:
:resmo02_11_W:
:resmo02_12_W:
:resmo02_13_W:
:resmo02_14_W:
:resmo02_15_W:
:resmo02_16_W:
:resmo02_17_W:
:resmo02_18_W:
:resmo02_19_W:
:resmo02_20_W:
:resmo02_21_W:
:resmo02_22_W:
:resmo02_23_W:
:resmo02_24_W:
:resmo02_25_W:
:resmo02_26_W:
:resmo02_27_W:
@page: Momentum balance equation residuals left inner
@iter:100
@log:
:resmo03_01_H:
:resmo03_01_D:
:resmo03_01_He:
:resmo03_02_He:
:resmo03_01_Li:
:resmo03_02_Li:
:resmo03_03_Li:
:resmo03_01_Be:
:resmo03_02_Be:
:resmo03_03_Be:
:resmo03_04_Be:
:resmo03_01_B:
:resmo03_02_B:
:resmo03_03_B:
:resmo03_04_B:
:resmo03_01_C:
:resmo03_02_C:
:resmo03_03_C:
:resmo03_04_C:
:resmo03_05_C:
:resmo03_06_C:
:resmo03_01_N:
:resmo03_02_N:
:resmo03_03_N:
:resmo03_04_N:
:resmo03_05_N:
:resmo03_06_N:
:resmo03_07_N:
:resmo03_01_Ne:
:resmo03_02_Ne:
:resmo03_03_Ne:
:resmo03_04_Ne:
:resmo03_05_Ne:
:resmo03_06_Ne:
:resmo03_07_Ne:
:resmo03_08_Ne:
:resmo03_09_Ne:
:resmo03_10_Ne:
:resmo03_01_Ar:
:resmo03_02_Ar:
:resmo03_03_Ar:
:resmo03_04_Ar:
:resmo03_05_Ar:
:resmo03_06_Ar:
:resmo03_07_Ar:
:resmo03_08_Ar:
:resmo03_09_Ar:
:resmo03_11_Ar:
:resmo03_12_Ar:
:resmo03_13_Ar:
:resmo03_14_Ar:
:resmo03_15_Ar:
:resmo03_16_Ar:
:resmo03_17_Ar:
:resmo03_18_Ar:
:resmo03_01_W:
:resmo03_02_W:
:resmo03_03_W:
:resmo03_04_W:
:resmo03_05_W:
:resmo03_06_W:
:resmo03_07_W:
:resmo03_08_W:
:resmo03_09_W:
:resmo03_11_W:
:resmo03_12_W:
:resmo03_13_W:
:resmo03_14_W:
:resmo03_15_W:
:resmo03_16_W:
:resmo03_17_W:
:resmo03_18_W:
:resmo03_19_W:
:resmo03_20_W:
:resmo03_21_W:
:resmo03_22_W:
:resmo03_23_W:
:resmo03_24_W:
:resmo03_25_W:
:resmo03_26_W:
:resmo03_27_W:
@page: Momentum balance equation residuals left outer
@iter:100
@log:
:resmo04_01_H:
:resmo04_01_D:
:resmo04_01_He:
:resmo04_02_He:
:resmo04_01_Li:
:resmo04_02_Li:
:resmo04_03_Li:
:resmo04_01_Be:
:resmo04_02_Be:
:resmo04_03_Be:
:resmo04_04_Be:
:resmo04_01_B:
:resmo04_02_B:
:resmo04_03_B:
:resmo04_04_B:
:resmo04_01_C:
:resmo04_01_C:
:resmo04_02_C:
:resmo04_03_C:
:resmo04_04_C:
:resmo04_05_C:
:resmo04_06_C:
:resmo04_01_N:
:resmo04_02_N:
:resmo04_03_N:
:resmo04_04_N:
:resmo04_05_N:
:resmo04_06_N:
:resmo04_07_N:
:resmo04_01_Ne:
:resmo04_02_Ne:
:resmo04_03_Ne:
:resmo04_04_Ne:
:resmo04_05_Ne:
:resmo04_06_Ne:
:resmo04_07_Ne:
:resmo04_08_Ne:
:resmo04_09_Ne:
:resmo04_10_Ne:
:resmo04_01_Ar:
:resmo04_02_Ar:
:resmo04_03_Ar:
:resmo04_04_Ar:
:resmo04_05_Ar:
:resmo04_06_Ar:
:resmo04_07_Ar:
:resmo04_08_Ar:
:resmo04_09_Ar:
:resmo04_11_Ar:
:resmo04_12_Ar:
:resmo04_13_Ar:
:resmo04_14_Ar:
:resmo04_15_Ar:
:resmo04_16_Ar:
:resmo04_17_Ar:
:resmo04_18_Ar:
:resmo04_01_W:
:resmo04_02_W:
:resmo04_03_W:
:resmo04_04_W:
:resmo04_05_W:
:resmo04_06_W:
:resmo04_07_W:
:resmo04_08_W:
:resmo04_09_W:
:resmo04_11_W:
:resmo04_12_W:
:resmo04_13_W:
:resmo04_14_W:
:resmo04_15_W:
:resmo04_16_W:
:resmo04_17_W:
:resmo04_18_W:
:resmo04_19_W:
:resmo04_20_W:
:resmo04_21_W:
:resmo04_22_W:
:resmo04_23_W:
:resmo04_24_W:
:resmo04_25_W:
:resmo04_26_W:
:resmo04_27_W:
@page: Momentum balance equation residuals right core
@iter:100
@log:
:resmo05_01_H:
:resmo05_01_D:
:resmo05_01_He:
:resmo05_02_He:
:resmo05_01_Li:
:resmo05_02_Li:
:resmo05_03_Li:
:resmo05_01_Be:
:resmo05_02_Be:
:resmo05_03_Be:
:resmo05_04_Be:
:resmo05_01_B:
:resmo05_02_B:
:resmo05_03_B:
:resmo05_04_B:
:resmo05_01_C:
:resmo05_02_C:
:resmo05_03_C:
:resmo05_04_C:
:resmo05_05_C:
:resmo05_06_C:
:resmo05_01_N:
:resmo05_02_N:
:resmo05_03_N:
:resmo05_04_N:
:resmo05_05_N:
:resmo05_06_N:
:resmo05_07_N:
:resmo05_01_Ne:
:resmo05_02_Ne:
:resmo05_03_Ne:
:resmo05_04_Ne:
:resmo05_05_Ne:
:resmo05_06_Ne:
:resmo05_07_Ne:
:resmo05_08_Ne:
:resmo05_09_Ne:
:resmo05_10_Ne:
:resmo05_01_Ar:
:resmo05_02_Ar:
:resmo05_03_Ar:
:resmo05_04_Ar:
:resmo05_05_Ar:
:resmo05_06_Ar:
:resmo05_07_Ar:
:resmo05_08_Ar:
:resmo05_09_Ar:
:resmo05_11_Ar:
:resmo05_12_Ar:
:resmo05_13_Ar:
:resmo05_14_Ar:
:resmo05_15_Ar:
:resmo05_16_Ar:
:resmo05_17_Ar:
:resmo05_18_Ar:
:resmo05_01_W:
:resmo05_02_W:
:resmo05_03_W:
:resmo05_04_W:
:resmo05_05_W:
:resmo05_06_W:
:resmo05_07_W:
:resmo05_08_W:
:resmo05_09_W:
:resmo05_11_W:
:resmo05_12_W:
:resmo05_13_W:
:resmo05_14_W:
:resmo05_15_W:
:resmo05_16_W:
:resmo05_17_W:
:resmo05_18_W:
:resmo05_19_W:
:resmo05_20_W:
:resmo05_21_W:
:resmo05_22_W:
:resmo05_23_W:
:resmo05_24_W:
:resmo05_25_W:
:resmo05_26_W:
:resmo05_27_W:
@page: Momentum balance equation residuals right SOL
@iter:100
@log:
:resmo06_01_H:
:resmo06_01_D:
:resmo06_01_He:
:resmo06_02_He:
:resmo06_01_Li:
:resmo06_02_Li:
:resmo06_03_Li:
:resmo06_01_Be:
:resmo06_02_Be:
:resmo06_03_Be:
:resmo06_04_Be:
:resmo06_01_B:
:resmo06_02_B:
:resmo06_03_B:
:resmo06_04_B:
:resmo06_01_C:
:resmo06_02_C:
:resmo06_03_C:
:resmo06_04_C:
:resmo06_05_C:
:resmo06_06_C:
:resmo06_01_N:
:resmo06_02_N:
:resmo06_03_N:
:resmo06_04_N:
:resmo06_05_N:
:resmo06_06_N:
:resmo06_07_N:
:resmo06_01_Ne:
:resmo06_02_Ne:
:resmo06_03_Ne:
:resmo06_04_Ne:
:resmo06_05_Ne:
:resmo06_06_Ne:
:resmo06_07_Ne:
:resmo06_08_Ne:
:resmo06_09_Ne:
:resmo06_10_Ne:
:resmo06_01_Ar:
:resmo06_02_Ar:
:resmo06_03_Ar:
:resmo06_04_Ar:
:resmo06_05_Ar:
:resmo06_06_Ar:
:resmo06_07_Ar:
:resmo06_08_Ar:
:resmo06_09_Ar:
:resmo06_11_Ar:
:resmo06_12_Ar:
:resmo06_13_Ar:
:resmo06_14_Ar:
:resmo06_15_Ar:
:resmo06_16_Ar:
:resmo06_17_Ar:
:resmo06_18_Ar:
:resmo06_01_W:
:resmo06_02_W:
:resmo06_03_W:
:resmo06_04_W:
:resmo06_05_W:
:resmo06_06_W:
:resmo06_07_W:
:resmo06_08_W:
:resmo06_09_W:
:resmo06_11_W:
:resmo06_12_W:
:resmo06_13_W:
:resmo06_14_W:
:resmo06_15_W:
:resmo06_16_W:
:resmo06_17_W:
:resmo06_18_W:
:resmo06_19_W:
:resmo06_20_W:
:resmo06_21_W:
:resmo06_22_W:
:resmo06_23_W:
:resmo06_24_W:
:resmo06_25_W:
:resmo06_26_W:
:resmo06_27_W:
@page: Momentum balance equation residuals right inner
@iter:100
@log:
:resmo07_01_H:
:resmo07_01_D:
:resmo07_01_He:
:resmo07_02_He:
:resmo07_01_Li:
:resmo07_02_Li:
:resmo07_03_Li:
:resmo07_01_Be:
:resmo07_02_Be:
:resmo07_03_Be:
:resmo07_04_Be:
:resmo07_01_B:
:resmo07_02_B:
:resmo07_03_B:
:resmo07_04_B:
:resmo07_01_C:
:resmo07_02_C:
:resmo07_03_C:
:resmo07_04_C:
:resmo07_05_C:
:resmo07_06_C:
:resmo07_01_N:
:resmo07_02_N:
:resmo07_03_N:
:resmo07_04_N:
:resmo07_05_N:
:resmo07_06_N:
:resmo07_07_N:
:resmo07_01_Ne:
:resmo07_02_Ne:
:resmo07_03_Ne:
:resmo07_04_Ne:
:resmo07_05_Ne:
:resmo07_06_Ne:
:resmo07_07_Ne:
:resmo07_08_Ne:
:resmo07_09_Ne:
:resmo07_10_Ne:
:resmo07_01_Ar:
:resmo07_02_Ar:
:resmo07_03_Ar:
:resmo07_04_Ar:
:resmo07_05_Ar:
:resmo07_06_Ar:
:resmo07_07_Ar:
:resmo07_08_Ar:
:resmo07_09_Ar:
:resmo07_11_Ar:
:resmo07_12_Ar:
:resmo07_13_Ar:
:resmo07_14_Ar:
:resmo07_15_Ar:
:resmo07_16_Ar:
:resmo07_17_Ar:
:resmo07_18_Ar:
:resmo07_01_W:
:resmo07_02_W:
:resmo07_03_W:
:resmo07_04_W:
:resmo07_05_W:
:resmo07_06_W:
:resmo07_07_W:
:resmo07_08_W:
:resmo07_09_W:
:resmo07_11_W:
:resmo07_12_W:
:resmo07_13_W:
:resmo07_14_W:
:resmo07_15_W:
:resmo07_16_W:
:resmo07_17_W:
:resmo07_18_W:
:resmo07_19_W:
:resmo07_20_W:
:resmo07_21_W:
:resmo07_22_W:
:resmo07_23_W:
:resmo07_24_W:
:resmo07_25_W:
:resmo07_26_W:
:resmo07_27_W:
@page: Momentum balance equation residuals right outer
@iter:100
@log:
:resmo08_01_H:
:resmo08_01_D:
:resmo08_01_He:
:resmo08_02_He:
:resmo08_01_Li:
:resmo08_02_Li:
:resmo08_03_Li:
:resmo08_01_Be:
:resmo08_02_Be:
:resmo08_03_Be:
:resmo08_04_Be:
:resmo08_01_B:
:resmo08_02_B:
:resmo08_03_B:
:resmo08_04_B:
:resmo08_01_C:
:resmo08_01_C:
:resmo08_02_C:
:resmo08_03_C:
:resmo08_04_C:
:resmo08_05_C:
:resmo08_06_C:
:resmo08_01_N:
:resmo08_02_N:
:resmo08_03_N:
:resmo08_04_N:
:resmo08_05_N:
:resmo08_06_N:
:resmo08_07_N:
:resmo08_01_Ne:
:resmo08_02_Ne:
:resmo08_03_Ne:
:resmo08_04_Ne:
:resmo08_05_Ne:
:resmo08_06_Ne:
:resmo08_07_Ne:
:resmo08_08_Ne:
:resmo08_09_Ne:
:resmo08_10_Ne:
:resmo08_01_Ar:
:resmo08_02_Ar:
:resmo08_03_Ar:
:resmo08_04_Ar:
:resmo08_05_Ar:
:resmo08_06_Ar:
:resmo08_07_Ar:
:resmo08_08_Ar:
:resmo08_09_Ar:
:resmo08_11_Ar:
:resmo08_12_Ar:
:resmo08_13_Ar:
:resmo08_14_Ar:
:resmo08_15_Ar:
:resmo08_16_Ar:
:resmo08_17_Ar:
:resmo08_18_Ar:
:resmo08_01_W:
:resmo08_02_W:
:resmo08_03_W:
:resmo08_04_W:
:resmo08_05_W:
:resmo08_06_W:
:resmo08_07_W:
:resmo08_08_W:
:resmo08_09_W:
:resmo08_11_W:
:resmo08_12_W:
:resmo08_13_W:
:resmo08_14_W:
:resmo08_15_W:
:resmo08_16_W:
:resmo08_17_W:
:resmo08_18_W:
:resmo08_19_W:
:resmo08_20_W:
:resmo08_21_W:
:resmo08_22_W:
:resmo08_23_W:
:resmo08_24_W:
:resmo08_25_W:
:resmo08_26_W:
:resmo08_27_W:
@file:user
@page: Integral ion saturation current to the target, MA
:isatt_il:I_{sat}^{inner}:1.e-6
:isatt_ol:I_{sat}^{outer}:1.e-6
:isatt_iu:I_{sat}^{in_up}:1.e-6
:isatt_ou:I_{sat}^{ou_up}:1.e-6
@page: Shaped peak heat flux to the target, MW/m^{2}
:pk_pwr_i:q_{peak,shp}^{inner}:1.e-6
:pk_pwr_o:q_{peak,shp}^{outer}:1.e-6
:pk_pw_iu:q_{peak,shp}^{in_up}:1.e-6
:pk_pw_ou:q_{peak,shp}^{ou_up}:1.e-6
@page: Parallel peak heat flux to wall, MW/m^{2}
:pk_ppf_w:q_{\parallel}^{wall}:1.e-6
@page: Neutral pressure in PFR, Pa
:Pneu_PFR:average:
:Pneu_PFRi:inner:
:Pneu_PFRo:outer:
@page: Neutral pressure at the pump H, Pa
:p_H2_pump:p_{H2}^{pump}:
:p_H_pump:p_{H}^{pump}:
@page: Neutral pressure at the pump D, Pa
:p_D2_pump:p_{D2}^{pump}:
:p_D_pump:p_{D}^{pump}:
@page: Neutral pressure at the pump T, Pa
:p_T2_pump:p_{T2}^{pump}:
:p_T_pump:p_{T}^{pump}:
@page: Neutral pressure at the pump He, Pa
:p_He_pump:p_{He}^{pump}:
@page: DT throughput, Pa*m^{3}/s
:DT_thrpt:DT_{thrpt}:
@page: Total fuel flux through PFR, s^{-1}
:PFR_flow_total_H:\Gamma_{H}^{PFR}:
:PFR_flow_total_D:\Gamma_{D}^{PFR}:
:PFR_flow_total_T:\Gamma_{T}^{PFR}:
@page: Total He flux through PFR, s^{-1}
:PFR_flow_total_He:\Gamma_{He}^{PFR}:
@page: Total impurity flux through PFR, s^{-1}
:PFR_flow_total_N:\Gamma_{N}^{PFR}:
:PFR_flow_total_Ne:\Gamma_{Ne}^{PFR}:
:PFR_flow_total_Ar:\Gamma_{Ar}^{PFR}:
@file:blnm
@page: Momentum balance lower inner (ank)
:ref_resf_il:relative force tot:
:rel_prtg_il:target pressure:
:rel_flxp_il:flow x-point:
:rel_fltg_il:flow target:
:rel_fneu_il:neutrals:
:ref_fmag_il:magnetic:
@page: Momentum balance lower outer (ank)
:ref_resf_ol:relative force tot:
:rel_prtg_ol:target pressure:
:rel_flxp_ol:flow x-point:
:rel_fltg_ol:flow target:
:rel_fneu_ol:neutrals:
:ref_fmag_ol:magnetic:
@page: Momentum balance upper inner (ank)
:ref_resf_iu:relative force tot:
:rel_prtg_iu:target pressure:
:rel_flxp_iu:flow x-point:
:rel_fltg_iu:flow target:
:rel_fneu_iu:neutrals:
:ref_fmag_iu:magnetic:
@page: Momentum balance upper outer (ank)
:ref_resf_ou:relative force tot:
:rel_prtg_ou:target pressure:
:rel_flxp_ou:flow x-point:
:rel_fltg_ou:flow target:
:rel_fneu_ou:neutrals:
:ref_fmag_ou:magnetic:
@file:b2time
@page: Electron density at the strike points, m^{-3}
:nesepi_l:Western lower:
:nesepa_l:Eastern lower:
:nesepi_u:Western upper:
:nesepa_u:Eastern upper:
@page: Electron temperature at the strike points, eV
:tesepi_l:Western lower:
:tesepa_l:Eastern lower:
:tesepi_u:Western upper:
:tesepa_u:Eastern upper:
@page: Ion temperature at the strike points, eV
:tisepi_l:Western lower:
:tisepa_l:Eastern lower:
:tisepi_u:Western upper:
:tisepa_u:Eastern upper:
@page: Maximum electron density at the plates, m^{-3}
:nemxip_l:Western lower:
:nemxap_l:Eastern lower:
:nemxip_u:Western upper:
:nemxap_u:Eastern upper:
@page: Maximum electron temperature at the plates, eV
:temxip_l:Western lower:
:temxap_l:Eastern lower:
:temxip_u:Western upper:
:temxap_u:Eastern upper:
@page: Maximum ion temperature at the plates, eV
:timxip_l:Western lower:
:timxap_l:Eastern lower:
:timxip_u:Western upper:
:timxap_u:Eastern upper:
@page: Total number of particles
:tmne:electrons:
@page: Stored energy, J
:tmte:electrons:1.60218e-19
:tmti:ions:1.60218e-19
@page: Power to the Western lower divertor, MW
:feesip_l:electrons:-1.e-6
:feisip_l:ions:-1.e-6
:fetsip_l:total:-1.e-6
@page: Power to the Western upper divertor, MW
:feesip_u:electrons:1.e-6
:feisip_u:ions:1.e-6
:fetsip_u:total:1.e-6
@page: Power to the Eastern lower divertor, MW
:feesap_l:electrons:1.e-6
:feisap_l:ions:1.e-6
:fetsap_l:total:1.e-6
@page: Power to the Eastern upper divertor, MW
:feesap_u:electrons:-1.e-6
:feisap_u:ions:-1.e-6
:fetsap_u:total:-1.e-6
@page: Power to the divertors, MW
:fetsip_l:Western lower:-1.e-6
:fetsap_l:Eastern lower:1.e-6
:fetsip_u:Western upper:1.e-6
:fetsap_u:Eastern upper:-1.e-6
@page: Ions flow to the divertors, s^{-1}
:fnisip_l:Western lower:-1.
:fnisap_l:Eastern lower:
:fnisip_u:Western upper:
:fnisap_u:Eastern upper:-1.
@page: H_{\alpha} signal from divertor region, ph/m^{2}/sr/s
:tmhadiv:H_{\alpha}:

