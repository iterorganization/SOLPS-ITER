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
@page: Separatrix density fraction O, \%
:nr_sep_O:\eta_{O}^{sep}:1.e+2
@page: Separatrix density fraction Ne, \%
:nr_sep_Ne:\eta_{Ne}^{sep}:1.e+2
@page: Separatrix density fraction Ar, \%
:nr_sep_Ar:\eta_{Ar}^{sep}:1.e+2
@page: Separatrix density fraction W, \%
:nr_sep_W:\eta_{W}^{sep}:1.e+2
@file:user_SPb
@page: Minimal temperature at LCFS, eV
:Te_min_LCFS:T_{e,min}^{LCFS}:
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
:imp_rad_O:O:1.e-6
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
@page: Flux balance total O, s^{-1}
:ion_core_O:ion_core:
:ntr_core_O:ntr_core:
:ion_targ_O:ion_targ:
:ntr_targ_O:ntr_targ:
:ion_wall_O:ion_wall:
:ntr_wall_O:ntr_wall:
:ntr_puff_O:ntr_puff:
:flux_tot_O:tot_flux:
:flux_bln_O:err_totl:
@page: O ion dN/dt, s^{-1}
:flx_d/dt_O:dN/dt:
@page: O content dln(N)/dt, s^{-1}
:flux_ttr_O:dln(N)/dt:
@page: Total relative error in O balance
:bln_blnr_O:err/sum:
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
:Brmsreg_01:core:-1.e-6
:Brmsreg_02:SOL:-1.e-6
:Brmsreg_03:inner:-1.e-6
:Brmsreg_04:outer:-1.e-6
@page: Impurity radiation per region, MW
:imp_rad_01:core:-1.e-6
:imp_rad_02:SOL:-1.e-6
:imp_rad_03:inner:-1.e-6
:imp_rad_04:outer:-1.e-6
@page: Neutral radiation per region, MW
:neu_rad_01:core:-1.e-6
:neu_rad_02:SOL:-1.e-6
:neu_rad_03:inner:-1.e-6
:neu_rad_04:outer:-1.e-6
@page: Total radiation per region, MW
:tot_rad_01:core:-1.e-6
:tot_rad_02:SOL:-1.e-6
:tot_rad_03:inner:-1.e-6
:tot_rad_04:outer:-1.e-6
@page: Total number of electrons per region
:N_e_reg_01:core:
:N_e_reg_02:SOL:
:N_e_reg_03:inner:
:N_e_reg_04:outer:
@page: Total number of H ions per region
:N_i_reg_01_H:core:
:N_i_reg_02_H:SOL:
:N_i_reg_03_H:inner:
:N_i_reg_04_H:outer:
@page: Total number of H neutrals per region
:N_a_reg_01_H:core:
:N_a_reg_02_H:SOL:
:N_a_reg_03_H:inner:
:N_a_reg_04_H:outer:
@page: Total number of D ions per region
:N_i_reg_01_D:core:
:N_i_reg_02_D:SOL:
:N_i_reg_03_D:inner:
:N_i_reg_04_D:outer:
@page: Total number of D neutrals per region
:N_a_reg_01_D:core:
:N_a_reg_02_D:SOL:
:N_a_reg_03_D:inner:
:N_a_reg_04_D:outer:
@page: Total number of He ions per region
:N_i_reg_01_He:core:
:N_i_reg_02_He:SOL:
:N_i_reg_03_He:inner:
:N_i_reg_04_He:outer:
@page: Total number of He neutrals per region
:N_a_reg_01_He:core:
:N_a_reg_02_He:SOL:
:N_a_reg_03_He:inner:
:N_a_reg_04_He:outer:
@page: Total number of Li ions per region
:N_i_reg_01_Li:core:
:N_i_reg_02_Li:SOL:
:N_i_reg_03_Li:inner:
:N_i_reg_04_Li:outer:
@page: Total number of Li neutrals per region
:N_a_reg_01_Li:core:
:N_a_reg_02_Li:SOL:
:N_a_reg_03_Li:inner:
:N_a_reg_04_Li:outer:
@page: Total number of Be ions per region
:N_i_reg_01_Be:core:
:N_i_reg_02_Be:SOL:
:N_i_reg_03_Be:inner:
:N_i_reg_04_Be:outer:
@page: Total number of Be neutrals per region
:N_a_reg_01_Be:core:
:N_a_reg_02_Be:SOL:
:N_a_reg_03_Be:inner:
:N_a_reg_04_Be:outer:
@page: Total number of B ions per region
:N_i_reg_01_B:core:
:N_i_reg_02_B:SOL:
:N_i_reg_03_B:inner:
:N_i_reg_04_B:outer:
@page: Total number of B neutrals per region
:N_a_reg_01_B:core:
:N_a_reg_02_B:SOL:
:N_a_reg_03_B:inner:
:N_a_reg_04_B:outer:
@page: Total number of C ions per region
:N_i_reg_01_C:core:
:N_i_reg_02_C:SOL:
:N_i_reg_03_C:inner:
:N_i_reg_04_C:outer:
@page: Total number of C neutrals per region
:N_a_reg_01_C:core:
:N_a_reg_02_C:SOL:
:N_a_reg_03_C:inner:
:N_a_reg_04_C:outer:
@page: Total number of N ions per region
:N_i_reg_01_N:core:
:N_i_reg_02_N:SOL:
:N_i_reg_03_N:inner:
:N_i_reg_04_N:outer:
@page: Total number of N neutrals per region
:N_a_reg_01_N:core:
:N_a_reg_02_N:SOL:
:N_a_reg_03_N:inner:
:N_a_reg_04_N:outer:
@page: Total number of O ions per region
:N_i_reg_01_O:core:
:N_i_reg_02_O:SOL:
:N_i_reg_03_O:inner:
:N_i_reg_04_O:outer:
@page: Total number of O neutrals per region
:N_a_reg_01_O:core:
:N_a_reg_02_O:SOL:
:N_a_reg_03_O:inner:
:N_a_reg_04_O:outer:
@page: Total number of Ne ions per region
:N_i_reg_01_Ne:core:
:N_i_reg_02_Ne:SOL:
:N_i_reg_03_Ne:inner:
:N_i_reg_04_Ne:outer:
@page: Total number of Ne neutrals per region
:N_a_reg_01_Ne:core:
:N_a_reg_02_Ne:SOL:
:N_a_reg_03_Ne:inner:
:N_a_reg_04_Ne:outer:
@page: Total number of Ar ions per region
:N_i_reg_01_Ar:core:
:N_i_reg_02_Ar:SOL:
:N_i_reg_03_Ar:inner:
:N_i_reg_04_Ar:outer:
@page: Total number of Ar neutrals per region
:N_a_reg_01_Ar:core:
:N_a_reg_02_Ar:SOL:
:N_a_reg_03_Ar:inner:
:N_a_reg_04_Ar:outer:
@page: Total number of W ions per region
:N_i_reg_01_W:core:
:N_i_reg_02_W:SOL:
:N_i_reg_03_W:inner:
:N_i_reg_04_W:outer:
@page: Total number of W neutrals per region
:N_a_reg_01_W:core:
:N_a_reg_02_W:SOL:
:N_a_reg_03_W:inner:
:N_a_reg_04_W:outer:
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
@page: Total number of O ions in the egde
:N_s_sli_O:N_{i,O}^{edge}:
@page: Total number of O particles in the egde
:N_s_slt_O:N_{O}^{edge}:
@page: Total number of Ne ions in the egde
:N_s_sli_Ne:N_{i,Ne}^{edge}:
@page: Total number of Ne particles in the egde
:N_s_slt_Ne:N_{Ne}^{edge}:
@page: Total number of Ar ions in the egde
:N_s_sli_Ar:N_{i,Ar}^{edge}:
@page: Total number of Ar particles in the egde
:N_s_slt_Ar:N_{Ar}^{edge}:
@page: Total number of W ions in the egde
:N_s_sli_W:N_{i,W}^{edge}:
@page: Total number of W particles in the egde
:N_s_slt_W:N_{W}^{edge}:
@page: Internal source rescaling ratios H
:sclrtio_01_H:
:sclrtio_02_H:
:sclrtio_03_H:
:sclrtio_04_H:
:sclrtio_05_H:
:sclrtio_06_H:
:sclrtio_07_H:
:sclrtio_08_H:
:sclrtio_09_H:
:sclrtio_10_H:
:sclrtio_11_H:
:sclrtio_12_H:
:sclrtio_13_H:
:sclrtio_14_H:
:sclrtio_15_H:
:sclrtio_16_H:
:sclrtio_17_H:
:sclrtio_18_H:
:sclrtio_19_H:
:sclrtio_20_H:
:sclrtio_21_H:
:sclrtio_22_H:
:sclrtio_23_H:
:sclrtio_24_H:
:sclrtio_25_H:
:sclrtio_26_H:
:sclrtio_27_H:
:sclrtio_28_H:
:sclrtio_29_H:
:sclrtio_30_H:
:sclrtio_31_H:
:sclrtio_32_H:
:sclrtio_33_H:
:sclrtio_34_H:
:sclrtio_35_H:
:sclrtio_36_H:
:sclrtio_37_H:
:sclrtio_38_H:
:sclrtio_39_H:
:sclrtio_40_H:
:sclrtio_41_H:
:sclrtio_42_H:
:sclrtio_43_H:
:sclrtio_44_H:
:sclrtio_45_H:
:sclrtio_46_H:
:sclrtio_47_H:
:sclrtio_48_H:
:sclrtio_49_H:
:sclrtio_50_H:
@page: Internal source rescaling factors H
:sclfact_01_H:
:sclfact_02_H:
:sclfact_03_H:
:sclfact_04_H:
:sclfact_05_H:
:sclfact_06_H:
:sclfact_07_H:
:sclfact_08_H:
:sclfact_09_H:
:sclfact_10_H:
:sclfact_11_H:
:sclfact_12_H:
:sclfact_13_H:
:sclfact_14_H:
:sclfact_15_H:
:sclfact_16_H:
:sclfact_17_H:
:sclfact_18_H:
:sclfact_19_H:
:sclfact_20_H:
:sclfact_21_H:
:sclfact_22_H:
:sclfact_23_H:
:sclfact_24_H:
:sclfact_25_H:
:sclfact_26_H:
:sclfact_27_H:
:sclfact_28_H:
:sclfact_29_H:
:sclfact_30_H:
:sclfact_31_H:
:sclfact_32_H:
:sclfact_33_H:
:sclfact_34_H:
:sclfact_35_H:
:sclfact_36_H:
:sclfact_37_H:
:sclfact_38_H:
:sclfact_39_H:
:sclfact_40_H:
:sclfact_41_H:
:sclfact_42_H:
:sclfact_43_H:
:sclfact_44_H:
:sclfact_45_H:
:sclfact_46_H:
:sclfact_47_H:
:sclfact_48_H:
:sclfact_49_H:
:sclfact_50_H:
@page: Internal source rescaling ratios D
:sclrtio_01_D:
:sclrtio_02_D:
:sclrtio_03_D:
:sclrtio_04_D:
:sclrtio_05_D:
:sclrtio_06_D:
:sclrtio_07_D:
:sclrtio_08_D:
:sclrtio_09_D:
:sclrtio_10_D:
:sclrtio_11_D:
:sclrtio_12_D:
:sclrtio_13_D:
:sclrtio_14_D:
:sclrtio_15_D:
:sclrtio_16_D:
:sclrtio_17_D:
:sclrtio_18_D:
:sclrtio_19_D:
:sclrtio_20_D:
:sclrtio_21_D:
:sclrtio_22_D:
:sclrtio_23_D:
:sclrtio_24_D:
:sclrtio_25_D:
:sclrtio_26_D:
:sclrtio_27_D:
:sclrtio_28_D:
:sclrtio_29_D:
:sclrtio_30_D:
:sclrtio_31_D:
:sclrtio_32_D:
:sclrtio_33_D:
:sclrtio_34_D:
:sclrtio_35_D:
:sclrtio_36_D:
:sclrtio_37_D:
:sclrtio_38_D:
:sclrtio_39_D:
:sclrtio_40_D:
:sclrtio_41_D:
:sclrtio_42_D:
:sclrtio_43_D:
:sclrtio_44_D:
:sclrtio_45_D:
:sclrtio_46_D:
:sclrtio_47_D:
:sclrtio_48_D:
:sclrtio_49_D:
:sclrtio_50_D:
@page: Internal source rescaling factors D
:sclfact_01_D:
:sclfact_02_D:
:sclfact_03_D:
:sclfact_04_D:
:sclfact_05_D:
:sclfact_06_D:
:sclfact_07_D:
:sclfact_08_D:
:sclfact_09_D:
:sclfact_10_D:
:sclfact_11_D:
:sclfact_12_D:
:sclfact_13_D:
:sclfact_14_D:
:sclfact_15_D:
:sclfact_16_D:
:sclfact_17_D:
:sclfact_18_D:
:sclfact_19_D:
:sclfact_20_D:
:sclfact_21_D:
:sclfact_22_D:
:sclfact_23_D:
:sclfact_24_D:
:sclfact_25_D:
:sclfact_26_D:
:sclfact_27_D:
:sclfact_28_D:
:sclfact_29_D:
:sclfact_30_D:
:sclfact_31_D:
:sclfact_32_D:
:sclfact_33_D:
:sclfact_34_D:
:sclfact_35_D:
:sclfact_36_D:
:sclfact_37_D:
:sclfact_38_D:
:sclfact_39_D:
:sclfact_40_D:
:sclfact_41_D:
:sclfact_42_D:
:sclfact_43_D:
:sclfact_44_D:
:sclfact_45_D:
:sclfact_46_D:
:sclfact_47_D:
:sclfact_48_D:
:sclfact_49_D:
:sclfact_50_D:
@page: Internal source rescaling ratios He
:sclrtio_01_He:
:sclrtio_02_He:
:sclrtio_03_He:
:sclrtio_04_He:
:sclrtio_05_He:
:sclrtio_06_He:
:sclrtio_07_He:
:sclrtio_08_He:
:sclrtio_09_He:
:sclrtio_10_He:
:sclrtio_11_He:
:sclrtio_12_He:
:sclrtio_13_He:
:sclrtio_14_He:
:sclrtio_15_He:
:sclrtio_16_He:
:sclrtio_17_He:
:sclrtio_18_He:
:sclrtio_19_He:
:sclrtio_20_He:
:sclrtio_21_He:
:sclrtio_22_He:
:sclrtio_23_He:
:sclrtio_24_He:
:sclrtio_25_He:
:sclrtio_26_He:
:sclrtio_27_He:
:sclrtio_28_He:
:sclrtio_29_He:
:sclrtio_30_He:
:sclrtio_31_He:
:sclrtio_32_He:
:sclrtio_33_He:
:sclrtio_34_He:
:sclrtio_35_He:
:sclrtio_36_He:
:sclrtio_37_He:
:sclrtio_38_He:
:sclrtio_39_He:
:sclrtio_40_He:
:sclrtio_41_He:
:sclrtio_42_He:
:sclrtio_43_He:
:sclrtio_44_He:
:sclrtio_45_He:
:sclrtio_46_He:
:sclrtio_47_He:
:sclrtio_48_He:
:sclrtio_49_He:
:sclrtio_50_He:
@page: Internal source rescaling factors He
:sclfact_01_He:
:sclfact_02_He:
:sclfact_03_He:
:sclfact_04_He:
:sclfact_05_He:
:sclfact_06_He:
:sclfact_07_He:
:sclfact_08_He:
:sclfact_09_He:
:sclfact_10_He:
:sclfact_11_He:
:sclfact_12_He:
:sclfact_13_He:
:sclfact_14_He:
:sclfact_15_He:
:sclfact_16_He:
:sclfact_17_He:
:sclfact_18_He:
:sclfact_19_He:
:sclfact_20_He:
:sclfact_21_He:
:sclfact_22_He:
:sclfact_23_He:
:sclfact_24_He:
:sclfact_25_He:
:sclfact_26_He:
:sclfact_27_He:
:sclfact_28_He:
:sclfact_29_He:
:sclfact_30_He:
:sclfact_31_He:
:sclfact_32_He:
:sclfact_33_He:
:sclfact_34_He:
:sclfact_35_He:
:sclfact_36_He:
:sclfact_37_He:
:sclfact_38_He:
:sclfact_39_He:
:sclfact_40_He:
:sclfact_41_He:
:sclfact_42_He:
:sclfact_43_He:
:sclfact_44_He:
:sclfact_45_He:
:sclfact_46_He:
:sclfact_47_He:
:sclfact_48_He:
:sclfact_49_He:
:sclfact_50_He:
@page: Internal source rescaling ratios Li
:sclrtio_01_Li:
:sclrtio_02_Li:
:sclrtio_03_Li:
:sclrtio_04_Li:
:sclrtio_05_Li:
:sclrtio_06_Li:
:sclrtio_07_Li:
:sclrtio_08_Li:
:sclrtio_09_Li:
:sclrtio_10_Li:
:sclrtio_11_Li:
:sclrtio_12_Li:
:sclrtio_13_Li:
:sclrtio_14_Li:
:sclrtio_15_Li:
:sclrtio_16_Li:
:sclrtio_17_Li:
:sclrtio_18_Li:
:sclrtio_19_Li:
:sclrtio_20_Li:
:sclrtio_21_Li:
:sclrtio_22_Li:
:sclrtio_23_Li:
:sclrtio_24_Li:
:sclrtio_25_Li:
:sclrtio_26_Li:
:sclrtio_27_Li:
:sclrtio_28_Li:
:sclrtio_29_Li:
:sclrtio_30_Li:
:sclrtio_31_Li:
:sclrtio_32_Li:
:sclrtio_33_Li:
:sclrtio_34_Li:
:sclrtio_35_Li:
:sclrtio_36_Li:
:sclrtio_37_Li:
:sclrtio_38_Li:
:sclrtio_39_Li:
:sclrtio_40_Li:
:sclrtio_41_Li:
:sclrtio_42_Li:
:sclrtio_43_Li:
:sclrtio_44_Li:
:sclrtio_45_Li:
:sclrtio_46_Li:
:sclrtio_47_Li:
:sclrtio_48_Li:
:sclrtio_49_Li:
:sclrtio_50_Li:
@page: Internal source rescaling factors Li
:sclfact_01_Li:
:sclfact_02_Li:
:sclfact_03_Li:
:sclfact_04_Li:
:sclfact_05_Li:
:sclfact_06_Li:
:sclfact_07_Li:
:sclfact_08_Li:
:sclfact_09_Li:
:sclfact_10_Li:
:sclfact_11_Li:
:sclfact_12_Li:
:sclfact_13_Li:
:sclfact_14_Li:
:sclfact_15_Li:
:sclfact_16_Li:
:sclfact_17_Li:
:sclfact_18_Li:
:sclfact_19_Li:
:sclfact_20_Li:
:sclfact_21_Li:
:sclfact_22_Li:
:sclfact_23_Li:
:sclfact_24_Li:
:sclfact_25_Li:
:sclfact_26_Li:
:sclfact_27_Li:
:sclfact_28_Li:
:sclfact_29_Li:
:sclfact_30_Li:
:sclfact_31_Li:
:sclfact_32_Li:
:sclfact_33_Li:
:sclfact_34_Li:
:sclfact_35_Li:
:sclfact_36_Li:
:sclfact_37_Li:
:sclfact_38_Li:
:sclfact_39_Li:
:sclfact_40_Li:
:sclfact_41_Li:
:sclfact_42_Li:
:sclfact_43_Li:
:sclfact_44_Li:
:sclfact_45_Li:
:sclfact_46_Li:
:sclfact_47_Li:
:sclfact_48_Li:
:sclfact_49_Li:
:sclfact_50_Li:
@page: Internal source rescaling ratios Be
:sclrtio_01_Be:
:sclrtio_02_Be:
:sclrtio_03_Be:
:sclrtio_04_Be:
:sclrtio_05_Be:
:sclrtio_06_Be:
:sclrtio_07_Be:
:sclrtio_08_Be:
:sclrtio_09_Be:
:sclrtio_10_Be:
:sclrtio_11_Be:
:sclrtio_12_Be:
:sclrtio_13_Be:
:sclrtio_14_Be:
:sclrtio_15_Be:
:sclrtio_16_Be:
:sclrtio_17_Be:
:sclrtio_18_Be:
:sclrtio_19_Be:
:sclrtio_20_Be:
:sclrtio_21_Be:
:sclrtio_22_Be:
:sclrtio_23_Be:
:sclrtio_24_Be:
:sclrtio_25_Be:
:sclrtio_26_Be:
:sclrtio_27_Be:
:sclrtio_28_Be:
:sclrtio_29_Be:
:sclrtio_30_Be:
:sclrtio_31_Be:
:sclrtio_32_Be:
:sclrtio_33_Be:
:sclrtio_34_Be:
:sclrtio_35_Be:
:sclrtio_36_Be:
:sclrtio_37_Be:
:sclrtio_38_Be:
:sclrtio_39_Be:
:sclrtio_40_Be:
:sclrtio_41_Be:
:sclrtio_42_Be:
:sclrtio_43_Be:
:sclrtio_44_Be:
:sclrtio_45_Be:
:sclrtio_46_Be:
:sclrtio_47_Be:
:sclrtio_48_Be:
:sclrtio_49_Be:
:sclrtio_50_Be:
@page: Internal source rescaling factors Be
:sclfact_01_Be:
:sclfact_02_Be:
:sclfact_03_Be:
:sclfact_04_Be:
:sclfact_05_Be:
:sclfact_06_Be:
:sclfact_07_Be:
:sclfact_08_Be:
:sclfact_09_Be:
:sclfact_10_Be:
:sclfact_11_Be:
:sclfact_12_Be:
:sclfact_13_Be:
:sclfact_14_Be:
:sclfact_15_Be:
:sclfact_16_Be:
:sclfact_17_Be:
:sclfact_18_Be:
:sclfact_19_Be:
:sclfact_20_Be:
:sclfact_21_Be:
:sclfact_22_Be:
:sclfact_23_Be:
:sclfact_24_Be:
:sclfact_25_Be:
:sclfact_26_Be:
:sclfact_27_Be:
:sclfact_28_Be:
:sclfact_29_Be:
:sclfact_30_Be:
:sclfact_31_Be:
:sclfact_32_Be:
:sclfact_33_Be:
:sclfact_34_Be:
:sclfact_35_Be:
:sclfact_36_Be:
:sclfact_37_Be:
:sclfact_38_Be:
:sclfact_39_Be:
:sclfact_40_Be:
:sclfact_41_Be:
:sclfact_42_Be:
:sclfact_43_Be:
:sclfact_44_Be:
:sclfact_45_Be:
:sclfact_46_Be:
:sclfact_47_Be:
:sclfact_48_Be:
:sclfact_49_Be:
:sclfact_50_Be:
@page: Internal source rescaling ratios B
:sclrtio_01_B:
:sclrtio_02_B:
:sclrtio_03_B:
:sclrtio_04_B:
:sclrtio_05_B:
:sclrtio_06_B:
:sclrtio_07_B:
:sclrtio_08_B:
:sclrtio_09_B:
:sclrtio_10_B:
:sclrtio_11_B:
:sclrtio_12_B:
:sclrtio_13_B:
:sclrtio_14_B:
:sclrtio_15_B:
:sclrtio_16_B:
:sclrtio_17_B:
:sclrtio_18_B:
:sclrtio_19_B:
:sclrtio_20_B:
:sclrtio_21_B:
:sclrtio_22_B:
:sclrtio_23_B:
:sclrtio_24_B:
:sclrtio_25_B:
:sclrtio_26_B:
:sclrtio_27_B:
:sclrtio_28_B:
:sclrtio_29_B:
:sclrtio_30_B:
:sclrtio_31_B:
:sclrtio_32_B:
:sclrtio_33_B:
:sclrtio_34_B:
:sclrtio_35_B:
:sclrtio_36_B:
:sclrtio_37_B:
:sclrtio_38_B:
:sclrtio_39_B:
:sclrtio_40_B:
:sclrtio_41_B:
:sclrtio_42_B:
:sclrtio_43_B:
:sclrtio_44_B:
:sclrtio_45_B:
:sclrtio_46_B:
:sclrtio_47_B:
:sclrtio_48_B:
:sclrtio_49_B:
:sclrtio_50_B:
@page: Internal source rescaling factors B
:sclfact_01_B:
:sclfact_02_B:
:sclfact_03_B:
:sclfact_04_B:
:sclfact_05_B:
:sclfact_06_B:
:sclfact_07_B:
:sclfact_08_B:
:sclfact_09_B:
:sclfact_10_B:
:sclfact_11_B:
:sclfact_12_B:
:sclfact_13_B:
:sclfact_14_B:
:sclfact_15_B:
:sclfact_16_B:
:sclfact_17_B:
:sclfact_18_B:
:sclfact_19_B:
:sclfact_20_B:
:sclfact_21_B:
:sclfact_22_B:
:sclfact_23_B:
:sclfact_24_B:
:sclfact_25_B:
:sclfact_26_B:
:sclfact_27_B:
:sclfact_28_B:
:sclfact_29_B:
:sclfact_30_B:
:sclfact_31_B:
:sclfact_32_B:
:sclfact_33_B:
:sclfact_34_B:
:sclfact_35_B:
:sclfact_36_B:
:sclfact_37_B:
:sclfact_38_B:
:sclfact_39_B:
:sclfact_40_B:
:sclfact_41_B:
:sclfact_42_B:
:sclfact_43_B:
:sclfact_44_B:
:sclfact_45_B:
:sclfact_46_B:
:sclfact_47_B:
:sclfact_48_B:
:sclfact_49_B:
:sclfact_50_B:
@page: Internal source rescaling ratios C
:sclrtio_01_C:
:sclrtio_02_C:
:sclrtio_03_C:
:sclrtio_04_C:
:sclrtio_05_C:
:sclrtio_06_C:
:sclrtio_07_C:
:sclrtio_08_C:
:sclrtio_09_C:
:sclrtio_10_C:
:sclrtio_11_C:
:sclrtio_12_C:
:sclrtio_13_C:
:sclrtio_14_C:
:sclrtio_15_C:
:sclrtio_16_C:
:sclrtio_17_C:
:sclrtio_18_C:
:sclrtio_19_C:
:sclrtio_20_C:
:sclrtio_21_C:
:sclrtio_22_C:
:sclrtio_23_C:
:sclrtio_24_C:
:sclrtio_25_C:
:sclrtio_26_C:
:sclrtio_27_C:
:sclrtio_28_C:
:sclrtio_29_C:
:sclrtio_30_C:
:sclrtio_31_C:
:sclrtio_32_C:
:sclrtio_33_C:
:sclrtio_34_C:
:sclrtio_35_C:
:sclrtio_36_C:
:sclrtio_37_C:
:sclrtio_38_C:
:sclrtio_39_C:
:sclrtio_40_C:
:sclrtio_41_C:
:sclrtio_42_C:
:sclrtio_43_C:
:sclrtio_44_C:
:sclrtio_45_C:
:sclrtio_46_C:
:sclrtio_47_C:
:sclrtio_48_C:
:sclrtio_49_C:
:sclrtio_50_C:
@page: Internal source rescaling factors C
:sclfact_01_C:
:sclfact_02_C:
:sclfact_03_C:
:sclfact_04_C:
:sclfact_05_C:
:sclfact_06_C:
:sclfact_07_C:
:sclfact_08_C:
:sclfact_09_C:
:sclfact_10_C:
:sclfact_11_C:
:sclfact_12_C:
:sclfact_13_C:
:sclfact_14_C:
:sclfact_15_C:
:sclfact_16_C:
:sclfact_17_C:
:sclfact_18_C:
:sclfact_19_C:
:sclfact_20_C:
:sclfact_21_C:
:sclfact_22_C:
:sclfact_23_C:
:sclfact_24_C:
:sclfact_25_C:
:sclfact_26_C:
:sclfact_27_C:
:sclfact_28_C:
:sclfact_29_C:
:sclfact_30_C:
:sclfact_31_C:
:sclfact_32_C:
:sclfact_33_C:
:sclfact_34_C:
:sclfact_35_C:
:sclfact_36_C:
:sclfact_37_C:
:sclfact_38_C:
:sclfact_39_C:
:sclfact_40_C:
:sclfact_41_C:
:sclfact_42_C:
:sclfact_43_C:
:sclfact_44_C:
:sclfact_45_C:
:sclfact_46_C:
:sclfact_47_C:
:sclfact_48_C:
:sclfact_49_C:
:sclfact_50_C:
@page: Internal source rescaling ratios N
:sclrtio_01_N:
:sclrtio_02_N:
:sclrtio_03_N:
:sclrtio_04_N:
:sclrtio_05_N:
:sclrtio_06_N:
:sclrtio_07_N:
:sclrtio_08_N:
:sclrtio_09_N:
:sclrtio_10_N:
:sclrtio_11_N:
:sclrtio_12_N:
:sclrtio_13_N:
:sclrtio_14_N:
:sclrtio_15_N:
:sclrtio_16_N:
:sclrtio_17_N:
:sclrtio_18_N:
:sclrtio_19_N:
:sclrtio_20_N:
:sclrtio_21_N:
:sclrtio_22_N:
:sclrtio_23_N:
:sclrtio_24_N:
:sclrtio_25_N:
:sclrtio_26_N:
:sclrtio_27_N:
:sclrtio_28_N:
:sclrtio_29_N:
:sclrtio_30_N:
:sclrtio_31_N:
:sclrtio_32_N:
:sclrtio_33_N:
:sclrtio_34_N:
:sclrtio_35_N:
:sclrtio_36_N:
:sclrtio_37_N:
:sclrtio_38_N:
:sclrtio_39_N:
:sclrtio_40_N:
:sclrtio_41_N:
:sclrtio_42_N:
:sclrtio_43_N:
:sclrtio_44_N:
:sclrtio_45_N:
:sclrtio_46_N:
:sclrtio_47_N:
:sclrtio_48_N:
:sclrtio_49_N:
:sclrtio_50_N:
@page: Internal source rescaling factors N
:sclfact_01_N:
:sclfact_02_N:
:sclfact_03_N:
:sclfact_04_N:
:sclfact_05_N:
:sclfact_06_N:
:sclfact_07_N:
:sclfact_08_N:
:sclfact_09_N:
:sclfact_10_N:
:sclfact_11_N:
:sclfact_12_N:
:sclfact_13_N:
:sclfact_14_N:
:sclfact_15_N:
:sclfact_16_N:
:sclfact_17_N:
:sclfact_18_N:
:sclfact_19_N:
:sclfact_20_N:
:sclfact_21_N:
:sclfact_22_N:
:sclfact_23_N:
:sclfact_24_N:
:sclfact_25_N:
:sclfact_26_N:
:sclfact_27_N:
:sclfact_28_N:
:sclfact_29_N:
:sclfact_30_N:
:sclfact_31_N:
:sclfact_32_N:
:sclfact_33_N:
:sclfact_34_N:
:sclfact_35_N:
:sclfact_36_N:
:sclfact_37_N:
:sclfact_38_N:
:sclfact_39_N:
:sclfact_40_N:
:sclfact_41_N:
:sclfact_42_N:
:sclfact_43_N:
:sclfact_44_N:
:sclfact_45_N:
:sclfact_46_N:
:sclfact_47_N:
:sclfact_48_N:
:sclfact_49_N:
:sclfact_50_N:
@page: Internal source rescaling ratios O
:sclrtio_01_O:
:sclrtio_02_O:
:sclrtio_03_O:
:sclrtio_04_O:
:sclrtio_05_O:
:sclrtio_06_O:
:sclrtio_07_O:
:sclrtio_08_O:
:sclrtio_09_O:
:sclrtio_10_O:
:sclrtio_11_O:
:sclrtio_12_O:
:sclrtio_13_O:
:sclrtio_14_O:
:sclrtio_15_O:
:sclrtio_16_O:
:sclrtio_17_O:
:sclrtio_18_O:
:sclrtio_19_O:
:sclrtio_20_O:
:sclrtio_21_O:
:sclrtio_22_O:
:sclrtio_23_O:
:sclrtio_24_O:
:sclrtio_25_O:
:sclrtio_26_O:
:sclrtio_27_O:
:sclrtio_28_O:
:sclrtio_29_O:
:sclrtio_30_O:
:sclrtio_31_O:
:sclrtio_32_O:
:sclrtio_33_O:
:sclrtio_34_O:
:sclrtio_35_O:
:sclrtio_36_O:
:sclrtio_37_O:
:sclrtio_38_O:
:sclrtio_39_O:
:sclrtio_40_O:
:sclrtio_41_O:
:sclrtio_42_O:
:sclrtio_43_O:
:sclrtio_44_O:
:sclrtio_45_O:
:sclrtio_46_O:
:sclrtio_47_O:
:sclrtio_48_O:
:sclrtio_49_O:
:sclrtio_50_O:
@page: Internal source rescaling factors O
:sclfact_01_O:
:sclfact_02_O:
:sclfact_03_O:
:sclfact_04_O:
:sclfact_05_O:
:sclfact_06_O:
:sclfact_07_O:
:sclfact_08_O:
:sclfact_09_O:
:sclfact_10_O:
:sclfact_11_O:
:sclfact_12_O:
:sclfact_13_O:
:sclfact_14_O:
:sclfact_15_O:
:sclfact_16_O:
:sclfact_17_O:
:sclfact_18_O:
:sclfact_19_O:
:sclfact_20_O:
:sclfact_21_O:
:sclfact_22_O:
:sclfact_23_O:
:sclfact_24_O:
:sclfact_25_O:
:sclfact_26_O:
:sclfact_27_O:
:sclfact_28_O:
:sclfact_29_O:
:sclfact_30_O:
:sclfact_31_O:
:sclfact_32_O:
:sclfact_33_O:
:sclfact_34_O:
:sclfact_35_O:
:sclfact_36_O:
:sclfact_37_O:
:sclfact_38_O:
:sclfact_39_O:
:sclfact_40_O:
:sclfact_41_O:
:sclfact_42_O:
:sclfact_43_O:
:sclfact_44_O:
:sclfact_45_O:
:sclfact_46_O:
:sclfact_47_O:
:sclfact_48_O:
:sclfact_49_O:
:sclfact_50_O:
@page: Internal source rescaling ratios Ne
:sclrtio_01_Ne:
:sclrtio_02_Ne:
:sclrtio_03_Ne:
:sclrtio_04_Ne:
:sclrtio_05_Ne:
:sclrtio_06_Ne:
:sclrtio_07_Ne:
:sclrtio_08_Ne:
:sclrtio_09_Ne:
:sclrtio_10_Ne:
:sclrtio_11_Ne:
:sclrtio_12_Ne:
:sclrtio_13_Ne:
:sclrtio_14_Ne:
:sclrtio_15_Ne:
:sclrtio_16_Ne:
:sclrtio_17_Ne:
:sclrtio_18_Ne:
:sclrtio_19_Ne:
:sclrtio_20_Ne:
:sclrtio_21_Ne:
:sclrtio_22_Ne:
:sclrtio_23_Ne:
:sclrtio_24_Ne:
:sclrtio_25_Ne:
:sclrtio_26_Ne:
:sclrtio_27_Ne:
:sclrtio_28_Ne:
:sclrtio_29_Ne:
:sclrtio_30_Ne:
:sclrtio_31_Ne:
:sclrtio_32_Ne:
:sclrtio_33_Ne:
:sclrtio_34_Ne:
:sclrtio_35_Ne:
:sclrtio_36_Ne:
:sclrtio_37_Ne:
:sclrtio_38_Ne:
:sclrtio_39_Ne:
:sclrtio_40_Ne:
:sclrtio_41_Ne:
:sclrtio_42_Ne:
:sclrtio_43_Ne:
:sclrtio_44_Ne:
:sclrtio_45_Ne:
:sclrtio_46_Ne:
:sclrtio_47_Ne:
:sclrtio_48_Ne:
:sclrtio_49_Ne:
:sclrtio_50_Ne:
@page: Internal source rescaling factors Ne
:sclfact_01_Ne:
:sclfact_02_Ne:
:sclfact_03_Ne:
:sclfact_04_Ne:
:sclfact_05_Ne:
:sclfact_06_Ne:
:sclfact_07_Ne:
:sclfact_08_Ne:
:sclfact_09_Ne:
:sclfact_10_Ne:
:sclfact_11_Ne:
:sclfact_12_Ne:
:sclfact_13_Ne:
:sclfact_14_Ne:
:sclfact_15_Ne:
:sclfact_16_Ne:
:sclfact_17_Ne:
:sclfact_18_Ne:
:sclfact_19_Ne:
:sclfact_20_Ne:
:sclfact_21_Ne:
:sclfact_22_Ne:
:sclfact_23_Ne:
:sclfact_24_Ne:
:sclfact_25_Ne:
:sclfact_26_Ne:
:sclfact_27_Ne:
:sclfact_28_Ne:
:sclfact_29_Ne:
:sclfact_30_Ne:
:sclfact_31_Ne:
:sclfact_32_Ne:
:sclfact_33_Ne:
:sclfact_34_Ne:
:sclfact_35_Ne:
:sclfact_36_Ne:
:sclfact_37_Ne:
:sclfact_38_Ne:
:sclfact_39_Ne:
:sclfact_40_Ne:
:sclfact_41_Ne:
:sclfact_42_Ne:
:sclfact_43_Ne:
:sclfact_44_Ne:
:sclfact_45_Ne:
:sclfact_46_Ne:
:sclfact_47_Ne:
:sclfact_48_Ne:
:sclfact_49_Ne:
:sclfact_50_Ne:
@page: Internal source rescaling ratios Ar
:sclrtio_01_Ar:
:sclrtio_02_Ar:
:sclrtio_03_Ar:
:sclrtio_04_Ar:
:sclrtio_05_Ar:
:sclrtio_06_Ar:
:sclrtio_07_Ar:
:sclrtio_08_Ar:
:sclrtio_09_Ar:
:sclrtio_10_Ar:
:sclrtio_11_Ar:
:sclrtio_12_Ar:
:sclrtio_13_Ar:
:sclrtio_14_Ar:
:sclrtio_15_Ar:
:sclrtio_16_Ar:
:sclrtio_17_Ar:
:sclrtio_18_Ar:
:sclrtio_19_Ar:
:sclrtio_20_Ar:
:sclrtio_21_Ar:
:sclrtio_22_Ar:
:sclrtio_23_Ar:
:sclrtio_24_Ar:
:sclrtio_25_Ar:
:sclrtio_26_Ar:
:sclrtio_27_Ar:
:sclrtio_28_Ar:
:sclrtio_29_Ar:
:sclrtio_30_Ar:
:sclrtio_31_Ar:
:sclrtio_32_Ar:
:sclrtio_33_Ar:
:sclrtio_34_Ar:
:sclrtio_35_Ar:
:sclrtio_36_Ar:
:sclrtio_37_Ar:
:sclrtio_38_Ar:
:sclrtio_39_Ar:
:sclrtio_40_Ar:
:sclrtio_41_Ar:
:sclrtio_42_Ar:
:sclrtio_43_Ar:
:sclrtio_44_Ar:
:sclrtio_45_Ar:
:sclrtio_46_Ar:
:sclrtio_47_Ar:
:sclrtio_48_Ar:
:sclrtio_49_Ar:
:sclrtio_50_Ar:
@page: Internal source rescaling factors Ar
:sclfact_01_Ar:
:sclfact_02_Ar:
:sclfact_03_Ar:
:sclfact_04_Ar:
:sclfact_05_Ar:
:sclfact_06_Ar:
:sclfact_07_Ar:
:sclfact_08_Ar:
:sclfact_09_Ar:
:sclfact_10_Ar:
:sclfact_11_Ar:
:sclfact_12_Ar:
:sclfact_13_Ar:
:sclfact_14_Ar:
:sclfact_15_Ar:
:sclfact_16_Ar:
:sclfact_17_Ar:
:sclfact_18_Ar:
:sclfact_19_Ar:
:sclfact_20_Ar:
:sclfact_21_Ar:
:sclfact_22_Ar:
:sclfact_23_Ar:
:sclfact_24_Ar:
:sclfact_25_Ar:
:sclfact_26_Ar:
:sclfact_27_Ar:
:sclfact_28_Ar:
:sclfact_29_Ar:
:sclfact_30_Ar:
:sclfact_31_Ar:
:sclfact_32_Ar:
:sclfact_33_Ar:
:sclfact_34_Ar:
:sclfact_35_Ar:
:sclfact_36_Ar:
:sclfact_37_Ar:
:sclfact_38_Ar:
:sclfact_39_Ar:
:sclfact_40_Ar:
:sclfact_41_Ar:
:sclfact_42_Ar:
:sclfact_43_Ar:
:sclfact_44_Ar:
:sclfact_45_Ar:
:sclfact_46_Ar:
:sclfact_47_Ar:
:sclfact_48_Ar:
:sclfact_49_Ar:
:sclfact_50_Ar:
@page: Internal source rescaling ratios W
:sclrtio_01_W:
:sclrtio_02_W:
:sclrtio_03_W:
:sclrtio_04_W:
:sclrtio_05_W:
:sclrtio_06_W:
:sclrtio_07_W:
:sclrtio_08_W:
:sclrtio_09_W:
:sclrtio_10_W:
:sclrtio_11_W:
:sclrtio_12_W:
:sclrtio_13_W:
:sclrtio_14_W:
:sclrtio_15_W:
:sclrtio_16_W:
:sclrtio_17_W:
:sclrtio_18_W:
:sclrtio_19_W:
:sclrtio_20_W:
:sclrtio_21_W:
:sclrtio_22_W:
:sclrtio_23_W:
:sclrtio_24_W:
:sclrtio_25_W:
:sclrtio_26_W:
:sclrtio_27_W:
:sclrtio_28_W:
:sclrtio_29_W:
:sclrtio_30_W:
:sclrtio_31_W:
:sclrtio_32_W:
:sclrtio_33_W:
:sclrtio_34_W:
:sclrtio_35_W:
:sclrtio_36_W:
:sclrtio_37_W:
:sclrtio_38_W:
:sclrtio_39_W:
:sclrtio_40_W:
:sclrtio_41_W:
:sclrtio_42_W:
:sclrtio_43_W:
:sclrtio_44_W:
:sclrtio_45_W:
:sclrtio_46_W:
:sclrtio_47_W:
:sclrtio_48_W:
:sclrtio_49_W:
:sclrtio_50_W:
@page: Internal source rescaling factors W
:sclfact_01_W:
:sclfact_02_W:
:sclfact_03_W:
:sclfact_04_W:
:sclfact_05_W:
:sclfact_06_W:
:sclfact_07_W:
:sclfact_08_W:
:sclfact_09_W:
:sclfact_10_W:
:sclfact_11_W:
:sclfact_12_W:
:sclfact_13_W:
:sclfact_14_W:
:sclfact_15_W:
:sclfact_16_W:
:sclfact_17_W:
:sclfact_18_W:
:sclfact_19_W:
:sclfact_20_W:
:sclfact_21_W:
:sclfact_22_W:
:sclfact_23_W:
:sclfact_24_W:
:sclfact_25_W:
:sclfact_26_W:
:sclfact_27_W:
:sclfact_28_W:
:sclfact_29_W:
:sclfact_30_W:
:sclfact_31_W:
:sclfact_32_W:
:sclfact_33_W:
:sclfact_34_W:
:sclfact_35_W:
:sclfact_36_W:
:sclfact_37_W:
:sclfact_38_W:
:sclfact_39_W:
:sclfact_40_W:
:sclfact_41_W:
:sclfact_42_W:
:sclfact_43_W:
:sclfact_44_W:
:sclfact_45_W:
:sclfact_46_W:
:sclfact_47_W:
:sclfact_48_W:
:sclfact_49_W:
:sclfact_50_W:
@file:residuals
@page: Electron energy equation residuals
@iter:100
@log:
:resee01:
:resee02:
:resee03:
:resee04:
@page: Ion energy equation residuals
@iter:100
@log:
:resei01:
:resei02:
:resei03:
:resei04:
@page: Continuity balance equation residuals core
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
:resco01_01_O:
:resco01_02_O:
:resco01_03_O:
:resco01_04_O:
:resco01_05_O:
:resco01_06_O:
:resco01_07_O:
:resco01_08_O:
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
@page: Continuity balance equation residuals SOL
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
:resco02_01_O:
:resco02_02_O:
:resco02_03_O:
:resco02_04_O:
:resco02_05_O:
:resco02_06_O:
:resco02_07_O:
:resco02_08_O:
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
@page: Continuity balance equation residuals inner
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
:resco03_01_O:
:resco03_02_O:
:resco03_03_O:
:resco03_04_O:
:resco03_05_O:
:resco03_06_O:
:resco03_07_O:
:resco03_08_O:
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
@page: Continuity balance equation residuals outer
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
:resco04_01_O:
:resco04_02_O:
:resco04_03_O:
:resco04_04_O:
:resco04_05_O:
:resco04_06_O:
:resco04_07_O:
:resco04_08_O:
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
@page: Momentum balance equation residuals core
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
:resmo01_01_O:
:resmo01_02_O:
:resmo01_03_O:
:resmo01_04_O:
:resmo01_05_O:
:resmo01_06_O:
:resmo01_07_O:
:resmo01_08_O:
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
@page: Momentum balance equation residuals SOL
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
:resmo02_01_O:
:resmo02_02_O:
:resmo02_03_O:
:resmo02_04_O:
:resmo02_05_O:
:resmo02_06_O:
:resmo02_07_O:
:resmo02_08_O:
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
@page: Momentum balance equation residuals inner
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
:resmo03_01_O:
:resmo03_02_O:
:resmo03_03_O:
:resmo03_04_O:
:resmo03_05_O:
:resmo03_06_O:
:resmo03_07_O:
:resmo03_08_O:
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
@page: Momentum balance equation residuals outer
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
:resmo04_01_O:
:resmo04_02_O:
:resmo04_03_O:
:resmo04_04_O:
:resmo04_05_O:
:resmo04_06_O:
:resmo04_07_O:
:resmo04_08_O:
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
@file:user_SPb
@page: Maximum T_{e} at the target, eV
:Te_max_i:inner:
:Te_max_o:outer:
:Te_max_iu:inner upper:
:Te_max_ou:outer upper:
@page: Peak ion saturation current to the target, MA/m^{2}
:j_s_tot_i:j_{sat,max}^{inner}:1.e-6
:j_s_tot_o:j_{sat,max}^{outer}:1.e-6
:j_s_tot_iu:j_{sat,max}^{inner,up}:1.e-6
:j_s_tot_ou:j_{sat,max}^{outer,up}:1.e-6
@page: Integral ion saturation current to the target, MA
:I_s_tot_i:I_{sat}^{inner}:1.e-6
:I_s_tot_o:I_{sat}^{outer}:1.e-6
:I_s_tot_iu:I_{sat}^{inner,up}:1.e-6
:I_s_tot_ou:I_{sat}^{outer,up}:1.e-6
@page: Net electric current to the target, MA
:I_tot_i:I_{net}^{inner}:1.e-6
:I_tot_o:I_{net}^{outer}:1.e-6
:I_tot_iu:I_{net}^{inner,up}:1.e-6
:I_tot_ou:I_{net}^{outer,up}:1.e-6
@page: Symmetric peak heat flux to the target, MW/m^{2}
:q_max_i:q_{peak,sym}^{inner}:1.e-6
:q_max_o:q_{peak,sym}^{outer}:1.e-6
:q_max_iu:q_{peak,sym}^{inner,up}:1.e-6
:q_max_ou:q_{peak,sym}^{outer,up}:1.e-6
@file:user
@page: Shaped peak heat flux to the target, MW/m^{2}
:pk_pwr_i:q_{peak,shp}^{inner}:1.e-6
:pk_pwr_o:q_{peak,shp}^{outer}:1.e-6
:pk_pwr_iu:q_{peak,shp}^{inner,up}:1.e-6
:pk_pwr_ou:q_{peak,shp}^{outer,up}:1.e-6
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
@page: DT throughput, Pa/m^{3}/s
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
@file:user.trc.n.01
@page: Shaped peak heat flux to the target, MW/m^{2}
:pk_pwr_i:q_{peak,shp}^{inner}:1.e-6
:pk_pwr_o:q_{peak,shp}^{outer}:1.e-6
:pk_pwr_iu:q_{peak,shp}^{inner,up}:1.e-6
:pk_pwr_ou:q_{peak,shp}^{outer,up}:1.e-6
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
@page: DT throughput, Pa/m^{3}/s
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

