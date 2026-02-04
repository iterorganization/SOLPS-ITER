# Command file for the plot_trc.py script
# designed to produce default analysis plots from the files tracing/*
#
#===============================================================================
# USAGE:
#
# @file:XXX     - read XXX or XXX.trc file
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

@file:series
@page: Density at the separatrix, 10^{19} m^{-3}
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:ne_sep:n_{e,avg}^{sep}:1.e-19
@page: Temperature at the separatrix, eV
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:Te_sep:T_{e}^{sep}:
:Ti_sep:T_{i}^{sep}:
@page: Power through the separatrix, MW
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:P_sep:P_{SOL}:1.e-6
@page: Power to targets and wall, MW
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:Q_trg:targets:1.e-6
:Q_wall:wall:1.e-6
@page: Total radiated power, MW
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:Q_tot_rad:Q_{rad}:1.e-6
@page: Radiation by region, MW
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:Q_tot_rad_01:core_lt:-1.e-6
:Q_tot_rad_02:SOL_lt:-1.e-6
:Q_tot_rad_03:inner_lt:-1.e-6
:Q_tot_rad_04:outer_lt:-1.e-6
:Q_tot_rad_05:core_rt:-1.e-6
:Q_tot_rad_06:SOL_rt:-1.e-6
:Q_tot_rad_07:inner_rt:-1.e-6
:Q_tot_rad_08:outer_rt:-1.e-6
@page: Peak symmetric heat flux to the target, MW/m^{2}
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:qpk_shp_i:q_{peak,shp}^{inner}:1.e-6
:qpk_shp_o:q_{peak,shp}^{outer}:1.e-6
:qpk_shp_iu:q_{peak,shp}^{in_up}:1.e-6
:qpk_shp_ou:q_{peak,shp}^{ou_up}:1.e-6
@page: Peak parallel heat flux to the wall, MW/m^{2}
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:qpk_par_w:q_{peak,par}^{wall}:1.e-6
@page: Neutral pressure in PFR as defined by SPb, Pa
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:p_neut_av:average:
:p_neut_i:inner:
:p_neut_o:outer:
@page: DT throughput, Pa*m^{-3}/s
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:DT_thrpt:DT:1.
@page: Integral ion saturation current to the target, MA
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:I_sat_i:I_{sat}^{inner}:1.e-6
:I_sat_o:I_{sat}^{outer}:1.e-6
:I_sat_iu:I_{sat}^{in_up}:1.e-6
:I_sat_ou:I_{sat}^{ou_up}:1.e-6
@page: Recombination sink, s^{-1} 
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:SNI_rcmb::6.242e+18
@page: Strike point T_{e} at the target, eV
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:te_sp_i:inner:
:te_sp_o:outer:
:te_sp_iu:inner_up:
:te_sp_ou:outer_up:
@page: Strike point T_{i} at the target, eV
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:Ti_SP_i:inner:
:Ti_SP_o:outer:
:Ti_SP_iu:inner_up:
:Ti_SP_ou:outer_up:
@page: Strike point n_{e}, m^{-3}
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:ne_SP_i:inner:
:ne_SP_o:outer:
:ne_SP_iu:inner_up:
:ne_SP_ou:outer_up:
@page: Maximum T_{e} at the target, eV
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:Te_max_i:inner:
:Te_max_o:outer:
:Te_max_iu:inner_up:
:Te_max_ou:outer_up:
@page: Maximum T_{i} at the target, eV
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:Ti_max_i:inner:
:Ti_max_o:outer:
:Ti_max_iu:inner_up:
:Ti_max_ou:outer_up:
@page: Maximum n_{e} at the target, m^{-3}
@setx:p_neut_av:p_{n}^{avg}, Pa:1.
@linepoints:
@grid:
:ne_max_i:inner:
:ne_max_o:outer:
:ne_max_iu:inner_up:
:ne_max_ou:outer_up:

