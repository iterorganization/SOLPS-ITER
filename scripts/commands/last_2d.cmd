# Command file for last_2d.py formatted output (last_2d_out_f)
#
#===============================================================================
#  USAGE:
#                Syntax (mandatory): " A : B : C : D : E "
#
#  A  - text, name of the file containing the original data without extension
#       (i.e b2time, sepdata etc)
#
#  B  - text, name of the desired quantity as it stands in the raw output
#       (for .trc files and single dimension quantities in .nc files
#       corresponds to the quantity names directly, whereas multidimensional
#       data from .nc files are unpacked via adding specific suffixes that
#       and the quantity names should be looked up in the last_2d.py driver)
#
#  C  - real, scaling factor, original quantity value will be scaled with it
#
#  D  - text, name under which the quantity will appear in the formatted output
#       (if blank the original quantity name (field B) will be used)
#
#  E  - text, the units of the resulting quantity value (after scaling), will
#       be shown in brackets after the name (if blank "N/A" will be added to
#       distinguish between lack of units provided and a.u. quantities)
#==============================================================================

sepdata  : ne_sep      : 1. : ne_sep     : m^-3
sepdata  : Te_sep      : 1. : Te_sep     : eV
sepdata  : Ti_sep      : 1. : Ti_sep     : eV
sepdata  : Zef_sep     : 1. : Zeff_sep   : a.u.
sepdata  : nr_sep_H    : 1. : nr_sep_H   : a.u.
sepdata  : nr_sep_D    : 1. : nr_sep_D   : a.u.
sepdata  : nr_sep_T    : 1. : nr_sep_T   : a.u.
sepdata  : nr_sep_He   : 1. : nr_sep_He  : a.u.
sepdata  : nr_sep_Li   : 1. : nr_sep_Li  : a.u.
sepdata  : nr_sep_Be   : 1. : nr_sep_Be  : a.u.
sepdata  : nr_sep_C    : 1. : nr_sep_C   : a.u.
sepdata  : nr_sep_N    : 1. : nr_sep_N   : a.u.
sepdata  : nr_sep_Ne   : 1. : nr_sep_Ne  : a.u.
sepdata  : nr_sep_Ar   : 1. : nr_sep_Ar  : a.u.
sepdata  : nr_sep_W    : 1. : nr_sep_W   : a.u.
user_SPb : Te_min_LCFS : 1. : Te_sep_min : eV

user_SPb : p_neut_PFR  : 1. : p_neut_av : Pa
user_SPb : p_neut_PFRi : 1. : p_neut_i  : Pa
user_SPb : p_neut_PFRo : 1. : p_neut_o  : Pa

user_SPb : q_max_i   : 1.e-6 : q_pk_i    : MW/m^2
user_SPb : q_max_o   : 1.e-6 : q_pk_o    : MW/m^2
user     : pk_pwr_i  : 1.e-6 : qpk_shp_i : MW/m^2
user     : pk_pwr_o  : 1.e-6 : qpk_shp_o : MW/m^2
user_SPb : I_s_tot_i : 1.e-6 : I_sat_i   : MA
user_SPb : I_s_tot_o : 1.e-6 : I_sat_o   : MA

user     : Sp_DT     : 1. : Sp_DT     : m^-3s^-1
user     : Sp_He     : 1. : Sp_He     : m^-3s^-1
user     : DT_thrpt  : 1. : DT_thrpt  : Pa*m^-3s^-1
user     : He_thrpt  : 1. : He_thrpt  : Pa*m^-3s^-1
user     : Area_pump : 1. : A_pump    : m^2
user     : n_H_pump  : 1. : n_H_pump  : m^-3
user     : T_H_pump  : 1. : T_H_pump  : eV
user     : p_H_pump  : 1. : P_H_pump  : Pa
user     : n_D_pump  : 1. : n_D_pump  : m^-3
user     : T_D_pump  : 1. : T_D_pump  : eV
user     : p_D_pump  : 1. : P_D_pump  : Pa
user     : n_T_pump  : 1. : n_T_pump  : m^-3
user     : T_T_pump  : 1. : T_T_pump  : eV
user     : p_T_pump  : 1. : P_T_pump  : Pa
user     : n_H2_pump : 1. : n_H2_pump : m^-3
user     : T_H2_pump : 1. : T_H2_pump : eV
user     : p_H2_pump : 1. : P_H2_pump : Pa
user     : n_D2_pump : 1. : n_D2_pump : m^-3
user     : T_D2_pump : 1. : T_D2_pump : eV
user     : p_D2_pump : 1. : P_D2_pump : Pa
user     : n_T2_pump : 1. : n_T2_pump : m^-3
user     : T_T2_pump : 1. : T_T2_pump : eV
user     : p_T2_pump : 1. : P_T2_pump : Pa
user     : n_He_pump : 1. : n_He_pump : m^-3
user     : T_He_pump : 1. : T_He_pump : eV
user     : p_He_pump : 1. : P_He_pump : Pa

b2time   : nesepi_l : 1.    : ne_SP_i   : m^-3
b2time   : nesepa_l : 1.    : ne_SP_o   : m^-3
b2time   : nemxip_l : 1.    : ne_max_i  : m^-3
b2time   : nemxap_l : 1.    : ne_max_o  : m^-3
b2time   : tesepi_l : 1.    : Te_SP_i   : eV
b2time   : tesepa_l : 1.    : Te_SP_o   : eV
b2time   : temxip_l : 1.    : Te_max_i  : eV
b2time   : temxap_l : 1.    : Te_max_o  : eV
b2time   : tisepi_l : 1.    : Ti_SP_i   : eV
b2time   : tisepa_l : 1.    : Ti_SP_o   : eV
b2time   : timxip_l : 1.    : Ti_max_i  : eV
b2time   : timxap_l : 1.    : Ti_max_o  : eV
b2time   : posepi_l : 1.    : Pot_SP_i  : V
b2time   : posepa_l : 1.    : Pot_SP_o  : V
b2time   : pomxip_l : 1.    : Pot_max_i : V
b2time   : pomxap_l : 1.    : Pot_max_o : V

blne    : tot_core   : 1.e-6 : P_core      : MW
sepdata : Qt_sep     : 1.e-6 : P_sep       : MW
blne    : tot_targ   : 1.e-6 : Q_trg       : MW
blne    : tot_wall   : 1.e-6 : Q_wall      : MW
blne    : tot_rad    : 1.e-6 : Q_tot_rad   : MW
blne    : ntrl_rad   : 1.e-6 : Q_neut_rad  : MW
blne    : imp_rad    : 1.e-6 : Q_imp_rad   : MW
blne    : imp_rad_He : 1.e-6 : Q_imp_He    : MW
blne    : imp_rad_Li : 1.e-6 : Q_imp_Li    : MW
blne    : imp_rad_Be : 1.e-6 : Q_imp_Be    : MW
blne    : imp_rad_C  : 1.e-6 : Q_imp_C     : MW
blne    : imp_rad_N  : 1.e-6 : Q_imp_N     : MW
blne    : imp_rad_Ne : 1.e-6 : Q_imp_Ne    : MW
blne    : imp_rad_Ar : 1.e-6 : Q_imp_Ar    : MW
blne    : imp_rad_W  : 1.e-6 : Q_imp_W     : MW

b2time  : feesip_l : -1.e-6 : P_div_e_il  : MW
b2time  : feisip_l : -1.e-6 : P_div_i_il  : MW
b2time  : fetsip_l : -1.e-6 : P_div_t_il  : MW
b2time  : feesap_l :  1.e-6 : P_div_e_ol  : MW
b2time  : feisap_l :  1.e-6 : P_div_i_ol  : MW
b2time  : fetsap_l :  1.e-6 : P_div_t_ol  : MW

blne    : pwr_totl_il  : 1.e-6 : Q_tot_trg_il   : MW
blne    : pwr_plsm_il  : 1.e-6 : Q_plsm_trg_il  : MW
blne    : pwr_neut_il  : 1.e-6 : Q_neut_trg_il  : MW
blne    : pwr_ionz_il  : 1.e-6 : Q_ionz_trg_il  : MW
blne    : pwr_diss_il  : 1.e-6 : Q_diss_trg_il  : MW

blne    : pwr_totl_ol  : 1.e-6 : Q_tot_trg_ol   : MW
blne    : pwr_plsm_ol  : 1.e-6 : Q_plsm_trg_ol  : MW
blne    : pwr_neut_ol  : 1.e-6 : Q_neut_trg_ol  : MW
blne    : pwr_ionz_ol  : 1.e-6 : Q_ionz_trg_ol  : MW
blne    : pwr_diss_ol  : 1.e-6 : Q_diss_trg_ol  : MW

blne    : pwr_totl_wl  : 1.e-6 : Q_tot_trg_wl   : MW
blne    : pwr_plsm_wl  : 1.e-6 : Q_plsm_trg_wl  : MW
blne    : pwr_neut_wl  : 1.e-6 : Q_neut_trg_wl  : MW
blne    : pwr_ionz_wl  : 1.e-6 : Q_ionz_trg_wl  : MW
blne    : pwr_diss_wl  : 1.e-6 : Q_diss_trg_wl  : MW

blnn_SPb : ion_core_H       : 1. : ion_core_H   : s^-1
blnn_SPb : ntr_core_H       : 1. : neut_core_H  : s^-1
blnn_SPb : ntr_targ_spt_H   : 1. : trg_spt_H    : s^-1
blnn_SPb : ntr_wall_spt_H   : 1. : wll_spt_H    : s^-1
blnn_SPb : ntr_targ_pmp_H   : 1. : trg_pmp_H    : s^-1
blnn_SPb : ntr_wall_pmp_H   : 1. : wll_pmp_H    : s^-1
blnn_SPb : ntr_puff_H       : 1. : puff_H       : s^-1
blnn_SPb : src_ext_H        : 1. : src_ext_H    : s^-1
blnn_SPb : flux_tot_H       : 1. : flux_tot_H   : s^-1
blnn_SPb : ion_core_D       : 1. : ion_core_D   : s^-1
blnn_SPb : ntr_core_D       : 1. : neut_core_D  : s^-1
blnn_SPb : ntr_targ_spt_D   : 1. : trg_spt_D    : s^-1
blnn_SPb : ntr_wall_spt_D   : 1. : wll_spt_D    : s^-1
blnn_SPb : ntr_targ_pmp_D   : 1. : trg_pmp_D    : s^-1
blnn_SPb : ntr_wall_pmp_D   : 1. : wll_pmp_D    : s^-1
blnn_SPb : ntr_puff_D       : 1. : puff_D       : s^-1
blnn_SPb : src_ext_D        : 1. : src_ext_D    : s^-1
blnn_SPb : flux_tot_D       : 1. : flux_tot_D   : s^-1
blnn_SPb : ion_core_T       : 1. : ion_core_T   : s^-1
blnn_SPb : ntr_core_T       : 1. : neut_core_T  : s^-1
blnn_SPb : ntr_targ_spt_T   : 1. : trg_spt_T    : s^-1
blnn_SPb : ntr_wall_spt_T   : 1. : wll_spt_T    : s^-1
blnn_SPb : ntr_targ_pmp_T   : 1. : trg_pmp_T    : s^-1
blnn_SPb : ntr_wall_pmp_T   : 1. : wll_pmp_T    : s^-1
blnn_SPb : ntr_puff_T       : 1. : puff_T       : s^-1
blnn_SPb : src_ext_T        : 1. : src_ext_T    : s^-1
blnn_SPb : flux_tot_T       : 1. : flux_tot_T   : s^-1
blnn_SPb : ion_core_He      : 1. : ion_core_He   : s^-1
blnn_SPb : ntr_core_He      : 1. : neut_core_He  : s^-1
blnn_SPb : ntr_targ_spt_He  : 1. : trg_spt_He    : s^-1
blnn_SPb : ntr_wall_spt_He  : 1. : wll_spt_He    : s^-1
blnn_SPb : ntr_targ_pmp_He  : 1. : trg_pmp_He    : s^-1
blnn_SPb : ntr_wall_pmp_He  : 1. : wll_pmp_He    : s^-1
blnn_SPb : ntr_puff_He      : 1. : puff_He       : s^-1
blnn_SPb : src_ext_He       : 1. : src_ext_He    : s^-1
blnn_SPb : flux_tot_He      : 1. : flux_tot_He   : s^-1
blnn_SPb : ion_core_Li      : 1. : ion_core_Li   : s^-1
blnn_SPb : ntr_core_Li      : 1. : neut_core_Li  : s^-1
blnn_SPb : ntr_targ_spt_Li  : 1. : trg_spt_Li    : s^-1
blnn_SPb : ntr_wall_spt_Li  : 1. : wll_spt_Li    : s^-1
blnn_SPb : ntr_targ_pmp_Li  : 1. : trg_pmp_Li    : s^-1
blnn_SPb : ntr_wall_pmp_Li  : 1. : wll_pmp_Li    : s^-1
blnn_SPb : ntr_puff_Li      : 1. : puff_Li       : s^-1
blnn_SPb : src_ext_Li       : 1. : src_ext_Li    : s^-1
blnn_SPb : flux_tot_Li      : 1. : flux_tot_Li   : s^-1
blnn_SPb : ion_core_Be      : 1. : ion_core_Be   : s^-1
blnn_SPb : ntr_core_Be      : 1. : neut_core_Be  : s^-1
blnn_SPb : ntr_targ_spt_Be  : 1. : trg_spt_Be    : s^-1
blnn_SPb : ntr_wall_spt_Be  : 1. : wll_spt_Be    : s^-1
blnn_SPb : ntr_targ_pmp_Be  : 1. : trg_pmp_Be    : s^-1
blnn_SPb : ntr_wall_pmp_Be  : 1. : wll_pmp_Be    : s^-1
blnn_SPb : ntr_puff_Be      : 1. : puff_Be       : s^-1
blnn_SPb : src_ext_Be       : 1. : src_ext_Be    : s^-1
blnn_SPb : flux_tot_Be      : 1. : flux_tot_Be   : s^-1
blnn_SPb : ion_core_C       : 1. : ion_core_C   : s^-1
blnn_SPb : ntr_core_C       : 1. : neut_core_C  : s^-1
blnn_SPb : ntr_targ_spt_C   : 1. : trg_spt_C    : s^-1
blnn_SPb : ntr_wall_spt_C   : 1. : wll_spt_C    : s^-1
blnn_SPb : ntr_targ_pmp_C   : 1. : trg_pmp_C    : s^-1
blnn_SPb : ntr_wall_pmp_C   : 1. : wll_pmp_C    : s^-1
blnn_SPb : ntr_puff_C       : 1. : puff_C       : s^-1
blnn_SPb : src_ext_C        : 1. : src_ext_C    : s^-1
blnn_SPb : flux_tot_C       : 1. : flux_tot_C   : s^-1
blnn_SPb : ion_core_N       : 1. : ion_core_N   : s^-1
blnn_SPb : ntr_core_N       : 1. : neut_core_N  : s^-1
blnn_SPb : ntr_targ_spt_N   : 1. : trg_spt_N    : s^-1
blnn_SPb : ntr_wall_spt_N   : 1. : wll_spt_N    : s^-1
blnn_SPb : ntr_targ_pmp_N   : 1. : trg_pmp_N    : s^-1
blnn_SPb : ntr_wall_pmp_N   : 1. : wll_pmp_N    : s^-1
blnn_SPb : ntr_puff_N       : 1. : puff_N       : s^-1
blnn_SPb : src_ext_N        : 1. : src_ext_N    : s^-1
blnn_SPb : flux_tot_N       : 1. : flux_tot_N   : s^-1
blnn_SPb : ion_core_Ne      : 1. : ion_core_Ne   : s^-1
blnn_SPb : ntr_core_Ne      : 1. : neut_core_Ne  : s^-1
blnn_SPb : ntr_targ_spt_Ne  : 1. : trg_spt_Ne    : s^-1
blnn_SPb : ntr_wall_spt_Ne  : 1. : wll_spt_Ne    : s^-1
blnn_SPb : ntr_targ_pmp_Ne  : 1. : trg_pmp_Ne    : s^-1
blnn_SPb : ntr_wall_pmp_Ne  : 1. : wll_pmp_Ne    : s^-1
blnn_SPb : ntr_puff_Ne      : 1. : puff_Ne       : s^-1
blnn_SPb : src_ext_Ne       : 1. : src_ext_Ne    : s^-1
blnn_SPb : flux_tot_Ne      : 1. : flux_tot_Ne   : s^-1
blnn_SPb : ion_core_Ar      : 1. : ion_core_Ar   : s^-1
blnn_SPb : ntr_core_Ar      : 1. : neut_core_Ar  : s^-1
blnn_SPb : ntr_targ_spt_Ar  : 1. : trg_spt_Ar    : s^-1
blnn_SPb : ntr_wall_spt_Ar  : 1. : wll_spt_Ar    : s^-1
blnn_SPb : ntr_targ_pmp_Ar  : 1. : trg_pmp_Ar    : s^-1
blnn_SPb : ntr_wall_pmp_Ar  : 1. : wll_pmp_Ar    : s^-1
blnn_SPb : ntr_puff_Ar      : 1. : puff_Ar       : s^-1
blnn_SPb : src_ext_Ar       : 1. : src_ext_Ar    : s^-1
blnn_SPb : flux_tot_Ar      : 1. : flux_tot_Ar   : s^-1
blnn_SPb : ion_core_W       : 1. : ion_core_W   : s^-1
blnn_SPb : ntr_core_W       : 1. : neut_core_W  : s^-1
blnn_SPb : ntr_targ_spt_W   : 1. : trg_spt_W    : s^-1
blnn_SPb : ntr_wall_spt_W   : 1. : wll_spt_W    : s^-1
blnn_SPb : ntr_targ_pmp_W   : 1. : trg_pmp_W    : s^-1
blnn_SPb : ntr_wall_pmp_W   : 1. : wll_pmp_W    : s^-1
blnn_SPb : ntr_puff_W       : 1. : puff_W       : s^-1
blnn_SPb : src_ext_W        : 1. : src_ext_W    : s^-1
blnn_SPb : flux_tot_W       : 1. : flux_tot_W   : s^-1

integral : SSNI_tot_H   : 1.        : SNI_tot_H  : s^-1
integral : SSNI_tot_D   : 1.        : SNI_tot_D  : s^-1
integral : SSNI_tot_T   : 1.        : SNI_tot_T  : s^-1
integral : SSNI_tot_He  : 1.        : SNI_tot_He : s^-1
integral : SSNI_tot_Li  : 1.        : SNI_tot_Li : s^-1
integral : SSNI_tot_Be  : 1.        : SNI_tot_Be : s^-1
integral : SSNI_tot_C   : 1.        : SNI_tot_C  : s^-1
integral : SSNI_tot_N   : 1.        : SNI_tot_N  : s^-1
integral : SSNI_tot_Ne  : 1.        : SNI_tot_Ne : s^-1
integral : SSNI_tot_Ar  : 1.        : SNI_tot_Ar : s^-1
integral : SSNI_tot_W   : 1.        : SNI_tot_W  : s^-1
integral : SNI_rcmb     : 6.242e+18 : SNI_rcmb   : s^-1

integral : SSNIreg_01_H  : 1. : SNI_01_H   : s^-1
integral : SSNIreg_02_H  : 1. : SNI_02_H   : s^-1
integral : SSNIreg_03_H  : 1. : SNI_03_H   : s^-1
integral : SSNIreg_04_H  : 1. : SNI_04_H   : s^-1
integral : SSNIreg_01_D  : 1. : SNI_01_D   : s^-1
integral : SSNIreg_02_D  : 1. : SNI_02_D   : s^-1
integral : SSNIreg_03_D  : 1. : SNI_03_D   : s^-1
integral : SSNIreg_04_D  : 1. : SNI_04_D   : s^-1
integral : SSNIreg_01_T  : 1. : SNI_01_T   : s^-1
integral : SSNIreg_02_T  : 1. : SNI_02_T   : s^-1
integral : SSNIreg_03_T  : 1. : SNI_03_T   : s^-1
integral : SSNIreg_04_T  : 1. : SNI_04_T   : s^-1
integral : SSNIreg_01_He : 1. : SNI_01_He  : s^-1
integral : SSNIreg_02_He : 1. : SNI_02_He  : s^-1
integral : SSNIreg_03_He : 1. : SNI_03_He  : s^-1
integral : SSNIreg_04_He : 1. : SNI_04_He  : s^-1
integral : SSNIreg_01_Li : 1. : SNI_01_Li  : s^-1
integral : SSNIreg_02_Li : 1. : SNI_02_Li  : s^-1
integral : SSNIreg_03_Li : 1. : SNI_03_Li  : s^-1
integral : SSNIreg_04_Li : 1. : SNI_04_Li  : s^-1
integral : SSNIreg_01_Be : 1. : SNI_01_Be  : s^-1
integral : SSNIreg_02_Be : 1. : SNI_02_Be  : s^-1
integral : SSNIreg_03_Be : 1. : SNI_03_Be  : s^-1
integral : SSNIreg_04_Be : 1. : SNI_04_Be  : s^-1
integral : SSNIreg_01_C  : 1. : SNI_01_C   : s^-1
integral : SSNIreg_02_C  : 1. : SNI_02_C   : s^-1
integral : SSNIreg_03_C  : 1. : SNI_03_C   : s^-1
integral : SSNIreg_04_C  : 1. : SNI_04_C   : s^-1
integral : SSNIreg_01_N  : 1. : SNI_01_N   : s^-1
integral : SSNIreg_02_N  : 1. : SNI_02_N   : s^-1
integral : SSNIreg_03_N  : 1. : SNI_03_N   : s^-1
integral : SSNIreg_04_N  : 1. : SNI_04_N   : s^-1
integral : SSNIreg_01_Ne : 1. : SNI_01_Ne  : s^-1
integral : SSNIreg_02_Ne : 1. : SNI_02_Ne  : s^-1
integral : SSNIreg_03_Ne : 1. : SNI_03_Ne  : s^-1
integral : SSNIreg_04_Ne : 1. : SNI_04_Ne  : s^-1
integral : SSNIreg_01_Ar : 1. : SNI_01_Ar  : s^-1
integral : SSNIreg_02_Ar : 1. : SNI_02_Ar  : s^-1
integral : SSNIreg_03_Ar : 1. : SNI_03_Ar  : s^-1
integral : SSNIreg_04_Ar : 1. : SNI_04_Ar  : s^-1
integral : SSNIreg_01_W  : 1. : SNI_01_W   : s^-1
integral : SSNIreg_02_W  : 1. : SNI_02_W   : s^-1
integral : SSNIreg_03_W  : 1. : SNI_03_W   : s^-1
integral : SSNIreg_04_W  : 1. : SNI_04_W   : s^-1

integral : N_s_slt_H  : 1. : N_t_edge_H  : part.
integral : N_s_slt_D  : 1. : N_t_edge_D  : part.
integral : N_s_slt_T  : 1. : N_t_edge_T  : part.
integral : N_s_slt_He : 1. : N_t_edge_He : part.
integral : N_s_slt_Li : 1. : N_t_edge_Li : part.
integral : N_s_slt_Be : 1. : N_t_edge_Be : part.
integral : N_s_slt_C  : 1. : N_t_edge_C  : part.
integral : N_s_slt_N  : 1. : N_t_edge_N  : part.
integral : N_s_slt_Ne : 1. : N_t_edge_Ne : part.
integral : N_s_slt_Ar : 1. : N_t_edge_Ar : part.
integral : N_s_slt_W  : 1. : N_t_edge_W  : part.

integral : N_a_tot_H  : 1. : N_a_tot_H  : part.
integral : N_a_tot_D  : 1. : N_a_tot_D  : part.
integral : N_a_tot_T  : 1. : N_a_tot_T  : part.
integral : N_a_tot_He : 1. : N_a_tot_He : part.
integral : N_a_tot_Li : 1. : N_a_tot_Li : part.
integral : N_a_tot_Be : 1. : N_a_tot_Be : part.
integral : N_a_tot_C  : 1. : N_a_tot_C  : part.
integral : N_a_tot_N  : 1. : N_a_tot_N  : part.
integral : N_a_tot_Ne : 1. : N_a_tot_Ne : part.
integral : N_a_tot_Ar : 1. : N_a_tot_Ar : part.
integral : N_a_tot_W  : 1. : N_a_tot_W  : part.

integral : N_e_reg_01 : 1. : N_e_01  : part.
integral : N_e_reg_02 : 1. : N_e_02  : part.
integral : N_e_reg_03 : 1. : N_e_03  : part.
integral : N_e_reg_04 : 1. : N_e_04  : part.

integral : N_i_reg_01_H  : 1. : N_i_01_H   : part.
integral : N_i_reg_02_H  : 1. : N_i_02_H   : part.
integral : N_i_reg_03_H  : 1. : N_i_03_H   : part.
integral : N_i_reg_04_H  : 1. : N_i_04_H   : part.
integral : N_i_reg_01_D  : 1. : N_i_01_D   : part.
integral : N_i_reg_02_D  : 1. : N_i_02_D   : part.
integral : N_i_reg_03_D  : 1. : N_i_03_D   : part.
integral : N_i_reg_04_D  : 1. : N_i_04_D   : part.
integral : N_i_reg_01_T  : 1. : N_i_01_T   : part.
integral : N_i_reg_02_T  : 1. : N_i_02_T   : part.
integral : N_i_reg_03_T  : 1. : N_i_03_T   : part.
integral : N_i_reg_04_T  : 1. : N_i_04_T   : part.
integral : N_i_reg_01_He : 1. : N_i_01_He  : part.
integral : N_i_reg_02_He : 1. : N_i_02_He  : part.
integral : N_i_reg_03_He : 1. : N_i_03_He  : part.
integral : N_i_reg_04_He : 1. : N_i_04_He  : part.
integral : N_i_reg_01_Li : 1. : N_i_01_Li  : part.
integral : N_i_reg_02_Li : 1. : N_i_02_Li  : part.
integral : N_i_reg_03_Li : 1. : N_i_03_Li  : part.
integral : N_i_reg_04_Li : 1. : N_i_04_Li  : part.
integral : N_i_reg_01_Be : 1. : N_i_01_Be  : part.
integral : N_i_reg_02_Be : 1. : N_i_02_Be  : part.
integral : N_i_reg_03_Be : 1. : N_i_03_Be  : part.
integral : N_i_reg_04_Be : 1. : N_i_04_Be  : part.
integral : N_i_reg_01_C  : 1. : N_i_01_C   : part.
integral : N_i_reg_02_C  : 1. : N_i_02_C   : part.
integral : N_i_reg_03_C  : 1. : N_i_03_C   : part.
integral : N_i_reg_04_C  : 1. : N_i_04_C   : part.
integral : N_i_reg_01_N  : 1. : N_i_01_N   : part.
integral : N_i_reg_02_N  : 1. : N_i_02_N   : part.
integral : N_i_reg_03_N  : 1. : N_i_03_N   : part.
integral : N_i_reg_04_N  : 1. : N_i_04_N   : part.
integral : N_i_reg_01_Ne : 1. : N_i_01_Ne  : part.
integral : N_i_reg_02_Ne : 1. : N_i_02_Ne  : part.
integral : N_i_reg_03_Ne : 1. : N_i_03_Ne  : part.
integral : N_i_reg_04_Ne : 1. : N_i_04_Ne  : part.
integral : N_i_reg_01_Ar : 1. : N_i_01_Ar  : part.
integral : N_i_reg_02_Ar : 1. : N_i_02_Ar  : part.
integral : N_i_reg_03_Ar : 1. : N_i_03_Ar  : part.
integral : N_i_reg_04_Ar : 1. : N_i_04_Ar  : part.
integral : N_i_reg_01_W  : 1. : N_i_01_W   : part.
integral : N_i_reg_02_W  : 1. : N_i_02_W   : part.
integral : N_i_reg_03_W  : 1. : N_i_03_W   : part.
integral : N_i_reg_04_W  : 1. : N_i_04_W   : part.

integral : N_a_reg_01_H  : 1. : N_a_01_H   : part.
integral : N_a_reg_02_H  : 1. : N_a_02_H   : part.
integral : N_a_reg_03_H  : 1. : N_a_03_H   : part.
integral : N_a_reg_04_H  : 1. : N_a_04_H   : part.
integral : N_a_reg_01_D  : 1. : N_a_01_D   : part.
integral : N_a_reg_02_D  : 1. : N_a_02_D   : part.
integral : N_a_reg_03_D  : 1. : N_a_03_D   : part.
integral : N_a_reg_04_D  : 1. : N_a_04_D   : part.
integral : N_a_reg_01_T  : 1. : N_a_01_T   : part.
integral : N_a_reg_02_T  : 1. : N_a_02_T   : part.
integral : N_a_reg_03_T  : 1. : N_a_03_T   : part.
integral : N_a_reg_04_T  : 1. : N_a_04_T   : part.
integral : N_a_reg_01_He : 1. : N_a_01_He  : part.
integral : N_a_reg_02_He : 1. : N_a_02_He  : part.
integral : N_a_reg_03_He : 1. : N_a_03_He  : part.
integral : N_a_reg_04_He : 1. : N_a_04_He  : part.
integral : N_a_reg_01_Li : 1. : N_a_01_Li  : part.
integral : N_a_reg_02_Li : 1. : N_a_02_Li  : part.
integral : N_a_reg_03_Li : 1. : N_a_03_Li  : part.
integral : N_a_reg_04_Li : 1. : N_a_04_Li  : part.
integral : N_a_reg_01_Be : 1. : N_a_01_Be  : part.
integral : N_a_reg_02_Be : 1. : N_a_02_Be  : part.
integral : N_a_reg_03_Be : 1. : N_a_03_Be  : part.
integral : N_a_reg_04_Be : 1. : N_a_04_Be  : part.
integral : N_a_reg_01_C  : 1. : N_a_01_C   : part.
integral : N_a_reg_02_C  : 1. : N_a_02_C   : part.
integral : N_a_reg_03_C  : 1. : N_a_03_C   : part.
integral : N_a_reg_04_C  : 1. : N_a_04_C   : part.
integral : N_a_reg_01_N  : 1. : N_a_01_N   : part.
integral : N_a_reg_02_N  : 1. : N_a_02_N   : part.
integral : N_a_reg_03_N  : 1. : N_a_03_N   : part.
integral : N_a_reg_04_N  : 1. : N_a_04_N   : part.
integral : N_a_reg_01_Ne : 1. : N_a_01_Ne  : part.
integral : N_a_reg_02_Ne : 1. : N_a_02_Ne  : part.
integral : N_a_reg_03_Ne : 1. : N_a_03_Ne  : part.
integral : N_a_reg_04_Ne : 1. : N_a_04_Ne  : part.
integral : N_a_reg_01_Ar : 1. : N_a_01_Ar  : part.
integral : N_a_reg_02_Ar : 1. : N_a_02_Ar  : part.
integral : N_a_reg_03_Ar : 1. : N_a_03_Ar  : part.
integral : N_a_reg_04_Ar : 1. : N_a_04_Ar  : part.
integral : N_a_reg_01_W  : 1. : N_a_01_W   : part.
integral : N_a_reg_02_W  : 1. : N_a_02_W   : part.
integral : N_a_reg_03_W  : 1. : N_a_03_W   : part.
integral : N_a_reg_04_W  : 1. : N_a_04_W   : part.

integral : imp_rad_01 : -1.e-6 : Q_imp_rad_01 : MW
integral : imp_rad_02 : -1.e-6 : Q_imp_rad_02 : MW
integral : imp_rad_03 : -1.e-6 : Q_imp_rad_03 : MW
integral : imp_rad_04 : -1.e-6 : Q_imp_rad_04 : MW
integral : neu_rad_01 : -1.e-6 : Q_neut_rad_01 : MW
integral : neu_rad_02 : -1.e-6 : Q_neut_rad_02 : MW
integral : neu_rad_03 : -1.e-6 : Q_neut_rad_03 : MW
integral : neu_rad_04 : -1.e-6 : Q_neut_rad_04 : MW
integral : tot_rad_01 : -1.e-6 : Q_tot_rad_01 : MW
integral : tot_rad_02 : -1.e-6 : Q_tot_rad_02 : MW
integral : tot_rad_03 : -1.e-6 : Q_tot_rad_03 : MW
integral : tot_rad_04 : -1.e-6 : Q_tot_rad_04 : MW
