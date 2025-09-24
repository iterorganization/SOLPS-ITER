# Command file for the plot_trc.py script
# designed to produce default analysis plots from the files tracing/*
#
#==============================================================================
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
#==============================================================================

@file:ld_tg_i
@page: Parallel heat flux around X-point, inner lower divertor, MW/m^{2}
@setx:xMP:r-r_{IMP}, m:
@setymin:0.
@setxmin:0.
:Wpar_xpt:q_{\parallel}^{xpt}:1.e-6
@page: Parallel heat flux X-point and target, inner lower divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@setymin:0.
@setxmin:0.
:Wpar_xpt:q_{\parallel}^{xpt}:1.e-6
:WWpar:q_{\parallel}^{trg}:1.e-6
@page: Target heat flux, inner lower divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@setymin:0.
:WWtrg:w/o diss:1.e-6
:Wtot:with diss:1.e-6
@page: Heat loads breakdown, inner lower divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@setymin:0.
:Wtot:total:1.e-6
:Wpls:plasma:1.e-6
:Wneut:neutrals:1.e-6
:Wrad:radiation:1.e-6
@page: Heat loads breakdown, inner lower divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@log:
:Wtot:total:1.e-6
:Wpls:plasma:1.e-6
:Wneut:neutrals:1.e-6
:Wrad:radiation:1.e-6
@page: Particle heat loads breakdown, inner lower divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@setymin:0.
:Wpart:total:1.e-6
:Wheat:kinetic:1.e-6
:Wpot:potential:1.e-6
@page: n_{e} at the target, inner lower divertor, m^{-3}
@setx:x:r-r_{sep}, m:
@setymin:0.
:ne:n_{e}:
@page: T_{i,e} at the target, inner lower divertor, eV
@setx:x:r-r_{sep}, m:
@setymin:0.
:Te:T_{e}:
:Ti:T_{i}:
@file:fp_tg_i
@page: H ion flux, inner lower divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@setymin:0.
:H_flux_ion:\Gamma_{H+}:
:D_flux_ion:\Gamma_{D+}:
:T_flux_ion:\Gamma_{T+}:
@page: H atom flux, inner lower divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@setymin:0.
:H_flux_atm:\Gamma_{H}:
:D_flux_atm:\Gamma_{D}:
:T_flux_atm:\Gamma_{T}:
@page: H atom pressure at the target, inner lower divertor, Pa
@setx:x:r-r_{sep}, m:
@setymin:0.
:H_pres_atm:p_{H}:
:D_pres_atm:p_{D}:
:T_pres_atm:p_{T}:
@page: H mol flux, inner lower divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@setymin:0.
:H2_flux_mol:\Gamma_{H_{2}}:
:D2_flux_mol:\Gamma_{D_{2}}:
:T2_flux_mol:\Gamma_{T_{2}}:
@page: H mol pressure at the target, inner lower divertor, Pa
@setx:x:r-r_{sep}, m:
@setymin:0.
:H2_pres_mol:p_{H_{2}}:
:D2_pres_mol:p_{D_{2}}:
:T2_pres_mol:p_{T_{2}}:
@page: Imp ion flux, inner lower divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@log:
:He_flux_ion:\Gamma_{He+}:
:Be_flux_ion:\Gamma_{Be+}:
:Li_flux_ion:\Gamma_{Li+}:
:C_flux_ion:\Gamma_{C+}:
:N_flux_ion:\Gamma_{N+}:
:Ne_flux_ion:\Gamma_{Ne+}:
:Ar_flux_ion:\Gamma_{Ar+}:
:W_flux_ion:\Gamma_{W+}:
@page: Imp atom flux, inner lower divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@log:
:He_flux_atm:\Gamma_{He}:
:Be_flux_atm:\Gamma_{Be}:
:Li_flux_atm:\Gamma_{Li}:
:C_flux_atm:\Gamma_{C}:
:N_flux_atm:\Gamma_{N}:
:Ne_flux_atm:\Gamma_{Ne}:
:Ar_flux_atm:\Gamma_{Ar}:
:W_flux_atm:\Gamma_{W}:
@page: Imp atom pressure at the target, inner lower divertor, Pa
@setx:x:r-r_{sep}, m:
@log:
:He_pres_atm:p_{He}:
:Be_pres_atm:p_{Be}:
:Li_pres_atm:p_{Li}:
:C_pres_atm:p_{C}:
:N_pres_atm:p_{N}:
:Ne_pres_atm:p_{Ne}:
:Ar_pres_atm:p_{Ar}:
:W_pres_atm:p_{W}:

@file:ld_tg_o
@page: Parallel heat flux around X-point, outer lower divertor, MW/m^{2}
@setx:xMP:r-r_{OMP}, m:
@setymin:0.
@setxmin:0.
:Wpar_xpt:q_{\parallel}^{xpt}:1.e-6
@page: Parallel heat flux X-point and target, outer lower divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@setymin:0.
@setxmin:0.
:Wpar_xpt:q_{\parallel}^{xpt}:1.e-6
:WWpar:q_{\parallel}^{trg}:1.e-6
@page: Target heat flux, outer lower divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@setymin:0.
:WWtrg:w/o diss:1.e-6
:Wtot:with diss:1.e-6
@page: Heat loads breakdown, outer lower divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@setymin:0.
:Wtot:total:1.e-6
:Wpls:plasma:1.e-6
:Wneut:neutrals:1.e-6
:Wrad:radiation:1.e-6
@page: Heat loads breakdown, outer lower divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@log:
:Wtot:total:1.e-6
:Wpls:plasma:1.e-6
:Wneut:neutrals:1.e-6
:Wrad:radiation:1.e-6
@page: Particle heat loads breakdown, outer lower divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@setymin:0.
:Wpart:total:1.e-6
:Wheat:kinetic:1.e-6
:Wpot:potential:1.e-6
@page: n_{e} at the target, outer lower divertor, m^{-3}
@setx:x:r-r_{sep}, m:
@setymin:0.
:ne:n_{e}:
@page: T_{e,i} at the target, outer lower divertor, eV
@setx:x:r-r_{sep}, m:
@setymin:0.
:Te:T_{e}:
:Ti:T_{i}:
@file:fp_tg_o
@page: H ion flux, outer lower divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@setymin:0.
:H_flux_ion:\Gamma_{H+}:
:D_flux_ion:\Gamma_{D+}:
:T_flux_ion:\Gamma_{T+}:
@page: H atom flux, outer lower divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@setymin:0.
:H_flux_atm:\Gamma_{H}:
:D_flux_atm:\Gamma_{D}:
:T_flux_atm:\Gamma_{T}:
@page: H atom pressure at the target, outer lower divertor, Pa
@setx:x:r-r_{sep}, m:
@setymin:0.
:H_pres_atm:p_{H}:
:D_pres_atm:p_{D}:
:T_pres_atm:p_{T}:
@page: H mol flux, outer lower divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@setymin:0.
:H2_flux_mol:\Gamma_{H_{2}}:
:D2_flux_mol:\Gamma_{D_{2}}:
:T2_flux_mol:\Gamma_{T_{2}}:
@page: H mol pressure at the target, outer lower divertor, Pa
@setx:x:r-r_{sep}, m:
@setymin:0.
:H2_pres_mol:p_{H_{2}}:
:D2_pres_mol:p_{D_{2}}:
:T2_pres_mol:p_{T_{2}}:
@page: Imp ion flux, outer lower divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@log:
:He_flux_ion:\Gamma_{He+}:
:Be_flux_ion:\Gamma_{Be+}:
:Li_flux_ion:\Gamma_{Li+}:
:C_flux_ion:\Gamma_{C+}:
:N_flux_ion:\Gamma_{N+}:
:Ne_flux_ion:\Gamma_{Ne+}:
:Ar_flux_ion:\Gamma_{Ar+}:
:W_flux_ion:\Gamma_{W+}:
@page: Imp atom flux, outer lower divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@log:
:He_flux_atm:\Gamma_{He}:
:Be_flux_atm:\Gamma_{Be}:
:Li_flux_atm:\Gamma_{Li}:
:C_flux_atm:\Gamma_{C}:
:N_flux_atm:\Gamma_{N}:
:Ne_flux_atm:\Gamma_{Ne}:
:Ar_flux_atm:\Gamma_{Ar}:
:W_flux_atm:\Gamma_{W}:
@page: Imp atom pressure at the target, outer lower divertor, Pa
@setx:x:r-r_{sep}, m:
@log:
:He_pres_atm:p_{He}:
:Be_pres_atm:p_{Be}:
:Li_pres_atm:p_{Li}:
:C_pres_atm:p_{C}:
:N_pres_atm:p_{N}:
:Ne_pres_atm:p_{Ne}:
:Ar_pres_atm:p_{Ar}:
:W_pres_atm:p_{W}:

@file:ld_tg_iu
@page: Parallel heat flux around X-point, inner upper divertor, MW/m^{2}
@setx:xMP:r-r_{IMP}, m:
@setymin:0.
@setxmin:0.
:Wpar_xpt:q_{\parallel}^{xpt}:1.e-6
@page: Parallel heat flux X-point and target, inner upper divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@setymin:0.
@setxmin:0.
:Wpar_xpt:q_{\parallel}^{xpt}:1.e-6
:WWpar:q_{\parallel}^{trg}:1.e-6
@page: Target heat flux, outer upper upper divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@setymin:0.
:WWtrg:w/o diss:1.e-6
:Wtot:with diss:1.e-6
@page: Heat loads breakdown, outer upper upper divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@setymin:0.
:Wtot:total:1.e-6
:Wpls:plasma:1.e-6
:Wneut:neutrals:1.e-6
:Wrad:radiation:1.e-6
@page: Heat loads breakdown, outer upper upper divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@log:
:Wtot:total:1.e-6
:Wpls:plasma:1.e-6
:Wneut:neutrals:1.e-6
:Wrad:radiation:1.e-6
@page: Particle heat loads breakdown, outer upper upper divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@setymin:0.
:Wpart:total:1.e-6
:Wheat:kinetic:1.e-6
:Wpot:potential:1.e-6
@page: n_{e} at the target, outer upper upper divertor, m^{-3}
@setx:x:r-r_{sep}, m:
@setymin:0.
:ne:n_{e}:
@page: T_{e,i} at the target, outer upper upper divertor, eV
@setx:x:r-r_{sep}, m:
@setymin:0.
:Te:T_{e}:
:Ti:T_{i}:
@file:fp_tg_iu
@page: H ion flux, outer upper upper divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@setymin:0.
:H_flux_ion:\Gamma_{H+}:
:D_flux_ion:\Gamma_{D+}:
:T_flux_ion:\Gamma_{T+}:
@page: H atom flux, outer upper upper divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@setymin:0.
:H_flux_atm:\Gamma_{H}:
:D_flux_atm:\Gamma_{D}:
:T_flux_atm:\Gamma_{T}:
@page: H atom pressure at the target, outer upper upper divertor, Pa
@setx:x:r-r_{sep}, m:
@setymin:0.
:H_pres_atm:p_{H}:
:D_pres_atm:p_{D}:
:T_pres_atm:p_{T}:
@page: H mol flux, outer upper upper divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@setymin:0.
:H2_flux_mol:\Gamma_{H_{2}}:
:D2_flux_mol:\Gamma_{D_{2}}:
:T2_flux_mol:\Gamma_{T_{2}}:
@page: H mol pressure at the target, outer upper upper divertor, Pa
@setx:x:r-r_{sep}, m:
@setymin:0.
:H2_pres_mol:p_{H_{2}}:
:D2_pres_mol:p_{D_{2}}:
:T2_pres_mol:p_{T_{2}}:
@page: Imp ion flux, outer upper upper divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@log:
:He_flux_ion:\Gamma_{He+}:
:Be_flux_ion:\Gamma_{Be+}:
:Li_flux_ion:\Gamma_{Li+}:
:C_flux_ion:\Gamma_{C+}:
:N_flux_ion:\Gamma_{N+}:
:Ne_flux_ion:\Gamma_{Ne+}:
:Ar_flux_ion:\Gamma_{Ar+}:
:W_flux_ion:\Gamma_{W+}:
@page: Imp atom flux, outer upper upper divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@log:
:He_flux_atm:\Gamma_{He}:
:Be_flux_atm:\Gamma_{Be}:
:Li_flux_atm:\Gamma_{Li}:
:C_flux_atm:\Gamma_{C}:
:N_flux_atm:\Gamma_{N}:
:Ne_flux_atm:\Gamma_{Ne}:
:Ar_flux_atm:\Gamma_{Ar}:
:W_flux_atm:\Gamma_{W}:
@page: Imp atom pressure at the target, outer upper upper divertor, Pa
@setx:x:r-r_{sep}, m:
@log:
:He_pres_atm:p_{He}:
:Be_pres_atm:p_{Be}:
:Li_pres_atm:p_{Li}:
:C_pres_atm:p_{C}:
:N_pres_atm:p_{N}:
:Ne_pres_atm:p_{Ne}:
:Ar_pres_atm:p_{Ar}:
:W_pres_atm:p_{W}:

@file:ld_tg_ou
@page: Parallel heat flux around X-point, outer upper divertor, MW/m^{2}
@setx:xMP:r-r_{OMP}, m:
@setymin:0.
@setxmin:0.
:Wpar_xpt:q_{\parallel}^{xpt}:1.e-6
@page: Parallel heat flux X-point and target, outer upper divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@setymin:0.
@setxmin:0.
:Wpar_xpt:q_{\parallel}^{xpt}:1.e-6
:WWpar:q_{\parallel}^{trg}:1.e-6
@page: Target heat flux, outer upper divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@setymin:0.
:WWtrg:w/o diss:1.e-6
:Wtot:with diss:1.e-6
@page: Heat loads breakdown, outer upper divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@setymin:0.
:Wtot:total:1.e-6
:Wpls:plasma:1.e-6
:Wneut:neutrals:1.e-6
:Wrad:radiation:1.e-6
@page: Heat loads breakdown, outer upper divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@log:
:Wtot:total:1.e-6
:Wpls:plasma:1.e-6
:Wneut:neutrals:1.e-6
:Wrad:radiation:1.e-6
@page: Particle heat loads breakdown, outer upper divertor, MW/m^{2}
@setx:x:r-r_{sep}, m:
@setymin:0.
:Wpart:total:1.e-6
:Wheat:kinetic:1.e-6
:Wpot:potential:1.e-6
@page: n_{e} at the target, outer upper divertor, m^{-3}
@setx:x:r-r_{sep}, m:
@setymin:0.
:ne:n_{e}:
@page: T_{e,i} at the target, outer upper divertor, eV
@setx:x:r-r_{sep}, m:
@setymin:0.
:Te:T_{e}:
:Ti:T_{i}:
@file:fp_tg_ou
@page: H ion flux, outer upper divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@setymin:0.
:H_flux_ion:\Gamma_{H+}:
:D_flux_ion:\Gamma_{D+}:
:T_flux_ion:\Gamma_{T+}:
@page: H atom flux, outer upper divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@setymin:0.
:H_flux_atm:\Gamma_{H}:
:D_flux_atm:\Gamma_{D}:
:T_flux_atm:\Gamma_{T}:
@page: H atom pressure at the target, outer upper divertor, Pa
@setx:x:r-r_{sep}, m:
@setymin:0.
:H_pres_atm:p_{H}:
:D_pres_atm:p_{D}:
:T_pres_atm:p_{T}:
@page: H mol flux, outer upper divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@setymin:0.
:H2_flux_mol:\Gamma_{H_{2}}:
:D2_flux_mol:\Gamma_{D_{2}}:
:T2_flux_mol:\Gamma_{T_{2}}:
@page: H mol pressure at the target, outer upper divertor, Pa
@setx:x:r-r_{sep}, m:
@setymin:0.
:H2_pres_mol:p_{H_{2}}:
:D2_pres_mol:p_{D_{2}}:
:T2_pres_mol:p_{T_{2}}:
@page: Imp ion flux, outer upper divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@log:
:He_flux_ion:\Gamma_{He+}:
:Be_flux_ion:\Gamma_{Be+}:
:Li_flux_ion:\Gamma_{Li+}:
:C_flux_ion:\Gamma_{C+}:
:N_flux_ion:\Gamma_{N+}:
:Ne_flux_ion:\Gamma_{Ne+}:
:Ar_flux_ion:\Gamma_{Ar+}:
:W_flux_ion:\Gamma_{W+}:
@page: Imp atom flux, outer upper divertor, m^{-2}s^{-1}
@setx:x:r-r_{sep}, m:
@log:
:He_flux_atm:\Gamma_{He}:
:Be_flux_atm:\Gamma_{Be}:
:Li_flux_atm:\Gamma_{Li}:
:C_flux_atm:\Gamma_{C}:
:N_flux_atm:\Gamma_{N}:
:Ne_flux_atm:\Gamma_{Ne}:
:Ar_flux_atm:\Gamma_{Ar}:
:W_flux_atm:\Gamma_{W}:
@page: Imp atom pressure at the target, outer upper divertor, Pa
@setx:x:r-r_{sep}, m:
@log:
:He_pres_atm:p_{He}:
:Be_pres_atm:p_{Be}:
:Li_pres_atm:p_{Li}:
:C_pres_atm:p_{C}:
:N_pres_atm:p_{N}:
:Ne_pres_atm:p_{Ne}:
:Ar_pres_atm:p_{Ar}:
:W_pres_atm:p_{W}:

@file:wlld_FWP
@page: Total heat flux at the first wall, MW/m^{2}
@setx:x:x, m:
@log:
:Wtot:Wtot:1.e-6
@page: Heat loads breakdown at the first wall, MW/m^{2}
@setx:x:x, m:
@log:
:Wtot:total:1.e-6
:Wpls:plasma:1.e-6
:Wneu:neutrals:1.e-6
:Wrad:radiation:1.e-6
@page: Particle heat loads breakdown at the first wall, MW/m^{2}
@setx:x:x, m:
@log:
:Wpart:total:1.e-6
:Wheat:kinetic:1.e-6
:Wpot:potential:1.e-6
@page: n_{e} at the first wall, m^{-3}
@setx:x:x, m:
@log:
:ne:n_{e}:
@page: T_{e,i} at the first wall, eV
@setx:x:x, m:
@log:
:Te:T_{e}:
:Ti:T_{i}:
@page: H ion flux at the first wall, m^{-2}s^{-1}
@setx:x:x, m:
@log:
:flxi_H:\Gamma_{H+}:
:flxi_D:\Gamma_{D+}:
:flxi_T:\Gamma_{T+}:
@page: Avg H ion energy at the first wall, eV
@setx:x:x, m:
@log:
:Eavi_H:\Gamma_{H+}:
:Eavi_D:\Gamma_{D+}:
:Eavi_T:\Gamma_{T+}:
@page: H atom flux at the first wall, m^{-2}s^{-1}
@setx:x:x, m:
@log:
:flxa_H:\Gamma_{H}:
:flxa_D:\Gamma_{D}:
:flxa_T:\Gamma_{T}:
@page: Avg H atom energy at the first wall, eV
@setx:x:x, m:
@log:
:Eava_H:\Gamma_{H}:
:Eava_D:\Gamma_{D}:
:Eava_T:\Gamma_{T}:
@page: H atom pressure at the first wall, Pa
@setx:x:x, m:
@log:
:pa_H:p_{H}:
:pa_D:p_{D}:
:pa_D:p_{T}:
@page: H mol flux at the first wall, m^{-2}s^{-1}
@setx:x:x, m:
@log:
:flxm_H2:\Gamma_{H_{2}}:
:flxm_D2:\Gamma_{D_{2}}:
:flxm_T2:\Gamma_{T_{2}}:
@page: Avg H mol energy at the first wall, eV
@setx:x:x, m:
@log:
:Eavm_H2:\Gamma_{H_{2}}:
:Eavm_D2:\Gamma_{D_{2}}:
:Eavm_T2:\Gamma_{T_{2}}:
@page: H mol pressure at the first wall, Pa
@setx:x:x, m:
@log:
:pm_H2:p_{H_{2}}:
:pm_D2:p_{D_{2}}:
:pm_T2:p_{T_{2}}:
@page: Imp ion flux at the first wall, m^{-2}s^{-1}
@setx:x:x, m:
@log:
:flxi_He:\Gamma_{He+}:
:flxi_Be:\Gamma_{Be+}:
:flxi_Li:\Gamma_{Li+}:
:flxi_C:\Gamma_{C+}:
:flxi_N:\Gamma_{N+}:
:flxi_Ne:\Gamma_{Ne+}:
:flxi_Ar:\Gamma_{Ar+}:
:flxi_W:\Gamma_{W+}:
@page: Avg imp ion energy at the first wall, eV
@setx:x:x, m:
@log:
:Eavi_He:\Gamma_{He+}:
:Eavi_Be:\Gamma_{Be+}:
:Eavi_Li:\Gamma_{Li+}:
:Eavi_C:\Gamma_{C+}:
:Eavi_N:\Gamma_{N+}:
:Eavi_Ne:\Gamma_{Ne+}:
:Eavi_Ar:\Gamma_{Ar+}:
:Eavi_W:\Gamma_{W+}:
@page: Imp atom flux at the first wall, m^{-2}s^{-1}
@setx:x:x, m:
@log:
:flxa_He:\Gamma_{He}:
:flxa_Be:\Gamma_{Be}:
:flxa_Li:\Gamma_{Li}:
:flxa_C:\Gamma_{C}:
:flxa_N:\Gamma_{N}:
:flxa_Ne:\Gamma_{Ne}:
:flxa_Ar:\Gamma_{Ar}:
:flxa_W:\Gamma_{W}:
@page: Avg imp atom energy at the first wall, eV
@setx:x:x, m:
@log:
:Eava_He:\Gamma_{He}:
:Eava_Be:\Gamma_{Be}:
:Eava_Li:\Gamma_{Li}:
:Eava_C:\Gamma_{C}:
:Eava_N:\Gamma_{N}:
:Eava_Ne:\Gamma_{Ne}:
:Eava_Ar:\Gamma_{Ar}:
:Eava_W:\Gamma_{W}:
@: Imp atom pressure at the first wall, Pa
@setx:x:x, m:
@log:
:pa_He:p_{He}:
:pa_Be:p_{Be}:
:pa_Li:p_{Li}:
:pa_C:p_{C}:
:pa_N:p_{N}:
:pa_Ne:p_{Ne}:
:pa_Ar:p_{Ar}:
:pa_W:p_{W}:

