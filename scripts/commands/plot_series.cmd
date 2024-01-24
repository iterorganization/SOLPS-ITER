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
@points:
@page: Temperature at the separatrix, eV
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:Te_sep:T_{e}^{sep}:
:Ti_sep:T_{i}^{sep}:
@page: Zeff at the separatrix
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:Zeff_sep:Z_{eff}^{sep}:
@page: Power through the separatrix, MW
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:P_sep:P_{SOL}:1.e-6
@page: Total radiated power, MW
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:Q_tot_rad:Q_{rad}:1.e-6
@page: Separatrix density fraction He, \%
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:nr_sep_He:\eta_{He}^{sep}:1.e+2
@page: Separatrix density fraction Li, \%
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:nr_sep_Li:\eta_{Li}^{sep}:1.e+2
@page: Separatrix density fraction Be, \%
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:nr_sep_Be:\eta_{Be}^{sep}:1.e+2
@page: Separatrix density fraction C, \%
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:nr_sep_C:\eta_{C}^{sep}:1.e+2
@page: Separatrix density fraction N, \%
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:nr_sep_N:\eta_{N}^{sep}:1.e+2
@page: Separatrix density fraction Ne, \%
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:nr_sep_Ne:\eta_{Ne}^{sep}:1.e+2
@page: Separatrix density fraction Ar, \%
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:nr_sep_Ar:\eta_{Ar}^{sep}:1.e+2
@page: Power to the targets and walls, MW
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:Q_trg:targets:1.e-6
:Q_wall:wall:1.e-6
@page: Fuel throughput, s^{-1}
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:wll_pmp_H:H:-1.
:wll_pmp_D:D:-1.
:wll_pmp_T:T:-1.
@page: He throughput, s^{-1}
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:wll_pmp_He:He:-1.
@page: Recombination sink, s^{-1}
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:SNI_rcmb::6.242e+18
@page: Impurity radiation, MW
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:Q_imp_rad:total:1.e-6
:Q_imp_rad_02:SOL:1.e-6
:Q_imp_rad_03:inner:1.e-6
:Q_imp_rad_04:outer:1.e-6
@page: Strike point T_{e} at the target, eV
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:Te_SP_i:inner:
:Te_SP_o:outer:
@page: Strike point T_{i} at the target, eV
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:Ti_SP_i:inner:
:Ti_SP_o:outer:
@page: Strike point n_{e}, m^{-3}
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:ne_SP_i:inner:
:ne_SP_o:outer:
@page: Maximum T_{e} at the target, eV
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:Te_max_i:inner:
:Te_max_o:outer:
@page: Maximum T_{i} at the target, eV
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:Ti_max_i:inner:
:Ti_max_o:outer:
@page: Maximum n_{e} at the target, m^{-3}
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:ne_max_i:inner:
:ne_max_o:outer:
@page: Integral ion saturation current to the target, MA
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:I_sat_i:I_{sat}^{inner}:1.e-6
:I_sat_o:I_{sat}^{outer}:1.e-6
@page: Peak heat flux to the target, MW/m^{2}
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:q_pk_i:q_{peak}^{inner}:1.e-6
:q_pk_o:q_{peak}^{outer}:1.e-6
@page: Neutral pressure in PFR as defined by SPb, Pa
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:p_neut_av:average:
:p_neut_i:inner:
:p_neut_o:outer:
@page: Power to the divertors, MW
@points:
@setx:ne_sep:n_{e,avg}^{sep}, 10^{20} m^{-3}:1.e-20
:P_div_t_il:inner:-1.e-6
:P_div_t_ol:outer:1.e-6

