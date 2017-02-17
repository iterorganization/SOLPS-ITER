"""
Generates b2cdcd.F and LaTeX output
"""
from __future__ import print_function

import xml.etree.ElementTree as etree
import textwrap

# Structure

b2mn_categories = ['Run', 'Geometry', 'Physics', 'Output', 'Numerics', 'Atomic Physics', 'Unused']

switch_list = ('ank_tracing', 'b2agdr_nxiso1', 'b2agdr_nxiso2',
'b2agdr_nyiso1', 'b2agdr_nyiso2', 'b2agfs_bottomcut', 'b2agfs_bottomcut2',
'b2agfs_Bt_adjust', 'b2agfs_Bt_rescale', 'b2agfs_Bt_reversal',
'b2agfs_geom_match_dist', 'b2agfs_geometry', 'b2agfs_leftcut',
'b2agfs_leftcut2', 'b2agfs_min_pitch', 'b2agfs_nncut', 'b2agfs_periodic_bc',
'b2agfs_pit_rescale', 'b2agfs_rightcut', 'b2agfs_rightcut2', 'b2agfs_topcut',
'b2agfs_topcut2', 'b2agfs_xoffset', 'b2agfs_yoffset', 'b2agfs_xrescale',
'b2agfs_yrescale', 'b2agmt_1d_width', 'b2agmx_pbs_from_basis_mesh',
'b2agsi_isymm', 'b2aidr_read_b2fstate', 'b2ardr_fix_cx', 'b2ardr_fix_recomb',
'b2ardr_no_weisheit', 'b2ardr_no_smoothing', 'b2ardr_rtnt', 'b2ardr_rtnn',
'b2mndr_astra', 'b2mndr_atomic_physics_rescale', 'b2mndr_b2time',
'b2mndr_cdfmovietim', 'b2mndr_coronal_model', 'b2mndr_cpu',
'b2mndr_density_rescale', 'b2mndr_delta_max', 'b2mndr_delta_min',
'b2mndr_dpc_mod_rates_ne_hot_frac', 'b2mndr_dpc_mod_rates_te_hot',
'b2mndr_dt_change_dec', 'b2mndr_dt_change_inc', 'b2mndr_dt_max',
'b2mndr_dt_min', 'b2mndr_dtim', 'b2mndr_eirene', 'b2mndr_elapsed',
'b2mndr_etim', 'b2mndr_hz', 'b2mndr_idout0', 'b2mndr_idout1',
'b2mndr_inverse_ua', 'b2mndr_isfb', 'b2mndr_ismain', 'b2mndr_ixfb',
'b2mndr_iyfb', 'b2mndr_min_areshe', 'b2mndr_min_areshi', 'b2mndr_min_aresco',
'b2mndr_mvinc', 'b2mndr_mvnum', 'b2mndr_ntim_save', 'b2mndr_plasinc',
'b2mndr_plasnum', 'b2mndr_na_eps', 'b2mndr_na_min', 'b2mndr_na_new',
'b2mndr_ne_wanted', 'b2mndr_ne_wanted_time', 'b2mndr_ntim', 'b2mndr_plasmatim',
'b2mndr_po_eps', 'b2mndr_rescale_neutrals', 'b2mndr_rescale_neutrals_sources',
'b2mndr_savecpu', 'b2mndr_stim', 'b2mndr_tally', 'b2mndr_te_eps',
'b2mndr_ti_eps', 'b2mndr_trantim', 'b2mndr_ua_eps', 'b2mndt_density_control',
'b2mndt_moitlv', 'b2mndt_moqtlv', 'b2mndt_nstg_areshe', 'b2mndt_nstg_areshi',
'b2mndt_nstg_aresco', 'b2mndt_nstg0', 'b2mndt_nstg1', 'b2mndt_nstg2',
'b2mndt_ntim_step_out', 'b2mndt_rxf', 'b2mndt_style', 'b2mndt_use_b2srst',
'b2mwqt_style', 'b2mwti_ismain0', 'b2mwti_jxa', 'b2mwti_jxi',
'b2mwti_target_offset', 'b2news_area_fix', 'b2news_BoRiS',
'b2news_do_2nd_b2npco_call', 'b2news_ExB', 'b2news_fac_ref',
'b2news_fac_ExB_tanh_a', 'b2news_fac_ExB_tanh_b', 'b2news_facdrift_dec',
'b2news_facdrift_inc', 'b2news_facdrift_start', 'b2news_facdrift_tanh_a',
'b2news_facdrift_tanh_b', 'b2news_facdrift_target', 'b2news_facExB_dec',
'b2news_facExB_inc', 'b2news_facExB_start', 'b2news_facExB_target',
'b2news_fac_vis_tanh_a', 'b2news_fac_vis_tanh_b', 'b2news_facvis_dec',
'b2news_facvis_inc', 'b2news_facvis_start', 'b2news_facvis_target',
'b2news_guard_flows', 'b2news_iy_nocoreExB', 'b2news_ncallout',
'b2news_no_b2sral_call', 'b2news_no_solve', 'b2news_nsmin', 'b2news_nsmax',
'b2news_poteq', 'b2news_potit', 'b2news_potitmin', 'b2news_potok',
'b2news_ramp_slow', 'b2news_recalculate_contributions',
'b2news_re_eval_prtls_fluxes', 'b2news_vis', 'b2news_xfm0', 'b2news_xfm1',
'b2news_xfm2', 'b2news_xfm3', 'b2npco_pcm0', 'b2npco_pcm1', 'b2npco_rxg',
'b2npht_pcm0', 'b2npht_pcm1', 'b2npht_rxg', 'b2npht_style', 'b2nph9_style',
'b2npmo_b2sifr_', 'b2npmo_rxg', 'b2npp7_style', 'b2nxdv_style', 'b2nxfc_style',
'b2nxfx_style', 'b2sdia_facgt', 'b2sicf_phm0', 'b2sicf_phm1', 'b2sifr_limthee',
'b2sifr_limthii', 'b2sifr_phm0', 'b2sifr_phm1', 'b2sifr_phm2', 'b2sifr_styl0',
'b2sifr_styl1', 'b2sigp_style', 'b2sihs_istyle_Joule_heating', 'b2sihs_phm0',
'b2sihs_phm1', 'b2sihs_phm2', 'b2sihs_phm3', 'b2sihs_phm4', 'b2sihs_phm5',
'b2sihs_phm6', 'b2sihs_phm7', 'b2sihs_rf0', 'b2sihs_rf1', 'b2sihs_rf2',
'b2sihs_rf3', 'b2sihs_rf4', 'b2sihs_style', 'b2sqcx_phm0', 'b2sqcx_styl0',
'b2sqel_artificial_radiation', 'b2sqel_phm0', 'b2sqel_phm1', 'b2sqel_phm2',
'b2sral_inputfile', 'b2sral_style', 'b2srdt_numerics_namelist', 'b2srdt_phm0',
'b2srdt_phm1', 'b2srdt_phm3', 'b2srdt_phm4', 'b2srdt_phm5', 'b2srsm_diagno',
'b2srsm_enable', 'b2srst_rf0', 'b2srst_rf1', 'b2srst_rf2', 'b2srst_rf3',
'b2stbc_bcpot_16_step', 'b2stbc_boundary_namelist', 'b2stbc_cbc',
'b2stbc_cbsnafac', 'b2stbc_coreregno', 'b2stbc_coreregn2', 'b2stbc_diagno',
'b2stbc_fchy_dia', 'b2stbc_fchy_dia_coreonly', 'b2stbc_fchycore',
'b2stbc_fchycore_alpha', 'b2stbc_feedback', 'b2stbc_fheycore',
'b2stbc_fheycore_alpha', 'b2stbc_fhiycore', 'b2stbc_fhiycore_alpha',
'b2stbc_fhiycore_kinetic_energy', 'b2stbc_fix_fch_in_fhe_sheath',
'b2stbc_fnaycore', 'b2stbc_fnaycore_alpha', 'b2stbc_integral_current',
'b2stbc_isfeedback', 'b2stbc_istyle_cur_contr_on_S_and_N',
'b2stbc_istyle_fchi', 'b2stbc_iyped', 'b2stbc_ncallfeedback', 'b2stbc_ndes',
'b2stbc_ndes_sol', 'b2stbc_neoclassical', 'b2stbc_nepedm_sol', 'b2stbc_nesepm',
'b2stbc_nesepm_alpha', 'b2stbc_nesepm_beta', 'b2stbc_nesepm_gamma',
'b2stbc_nesepm_overshoot', 'b2stbc_nesepm_minpuff', 'b2stbc_nesepm_maxpuff',
'b2stbc_nesepm_pfr', 'b2stbc_nesepm_sol', 'b2stbc_pfrregno1',
'b2stbc_pfrregno2', 'b2stbc_private_flux_puff', 'b2stbc_secmodel',
'b2stbc_sheath_drift_fix', 'b2stbc_she0ep', 'b2stbc_shi0ep', 'b2stbc_sna0ep',
'b2stbc_solregno', 'b2stbc_type13_fac', 'b2stbc_type13_norm',
'b2stbc_type13_ref', 'b2stbc_type16_kinetic_energy', 'b2stbc_type16_ref',
'b2stbc_type20_ref', 'b2stbc_type21_ref', 'b2stbc_volrec',
'b2stbc_volrec_alpha', 'b2stbc_volrec_beta', 'b2stbc_volrec_overshoot',
'b2stbm_impgyro_mod', 'b2stbm_linearisation', 'b2stbr_alpha',
'b2stbr_b2wall_netcdf', 'b2stbr_core_sources_rescale', 'b2stbr_eir_src_nhist',
'b2stbr_first_flight', 'b2stbr_first_flight_dl',
'b2stbr_first_flight_no_of_flights', 'b2stbr_first_flight_no_of_start_points',
'b2stbr_first_flight_table_size', 'b2stbr_neutrals_namelist', 'b2stbr_output',
'b2stbr_plate_model', 'b2stbr_plate_option', 'b2stbr_plate_temp',
'b2stbr_plate_thick', 'b2stbr_potential_at_guard_cell', 'b2stbr_redep_alpha',
'b2stbr_refl_model', 'b2stbr_reflection_on', 'b2stbr_sput_chem_alpha',
'b2stbr_sput_chem_model', 'b2stbr_sput_chem_cutoff_alpha',
'b2stbr_sput_chem_cutoff_beta', 'b2stbr_sput_dst', 'b2stbr_sput_dst2',
'b2stbr_sput_dst3', 'b2stbr_sput_frc', 'b2stbr_sput_mixed_alpha',
'b2stbr_sput_mixed_beta', 'b2stbr_sput_phys', 'b2stbr_sput_phys_alpha',
'b2stbr_sput_phys_col', 'b2stbr_sput_phys_model', 'b2stbr_sput_res',
'b2stbr_sput_src', 'b2stbr_sputter_energy_on', 'b2stbr_therm_evap',
'b2stbr_bas_recycled_neutrals_contr', 'b2stcx_rg0', 'b2stcx_styl0',
'b2stel_fix_recomb_energy', 'b2stel_phm0', 'b2stel_rg0', 'b2stel_rg1',
'b2stel_rxm0', 'b2stel_rxm1', 'b2stel_rxm2', 'b2stel_rxm3', 'b2stel_rxm4',
'b2stel_styl0', 'b2tanml_anomalous', 'b2tfcc_xfac', 'b2tfhe_alfTeEh',
'b2tfhe_anomalous', 'b2tfhe_conduction_only', 'b2tfhe_fch_pTe', 'b2tfhe_hybr2',
'b2tfhe_lim_flux', 'b2tfhe_mdf', 'b2tfhe_neutral', 'b2tfhe_no_current',
'b2tfhe_no_hybr', 'b2tfhe_upwind', 'b2tfhe_vis_par', 'b2tfhe_vis_per',
'b2tfhe_vis_q', 'b2tfhi_hybr2', 'b2tfhi_lim_flux', 'b2tfhi_mdf',
'b2tfhi_no_hybr', 'b2tfhi_upwind', 'b2tfnb_alpha',
'b2tfnb_anomalous_core_only', 'b2tfnb_drift_style', 'b2tfnb_gamma',
'b2tfnb_flux_limit_min_ti', 'b2tfnb_fnb_nodrift_style', 'b2tfnb_mdf',
'b2tfnb_no_hybr', 'b2tfnb_pflux_cor', 'b2tfnb_PSch', 'b2tfnb_xfrhie',
'b2tfnb_xfrhiehz', 'b2tfnb_ycur', 'b2tlc0_alpha', 'b2tlc0_gamma',
'b2tlh0_alpha', 'b2tlh0_gamma', 'b2tlh0_flux_limit_min_ti',
'b2tlh0_flux_limit_style', 'b2tlh0_hcimx_flag', 'b2tlmv_style', 'b2tlnl_ee',
'b2tlnl_ei', 'b2tlnl_ii', 'b2tqca_model', 'b2tqca_phm0', 'b2tqce_model',
'b2tqce_fke_Zhdanov', 'b2tqna_ballooning', 'b2tqna_ballooning_rescale',
'b2tqna_bb_ref', 'b2tqna_diagno', 'b2tqna_divsol_rescale', 'b2tqna_inputfile',
'b2tqna_ixref', 'b2tqna_max_df0', 'b2tqna_min_df0', 'b2tqna_model_sig',
'b2tqna_new_df0', 'b2tqna_pfr_rescale', 'b2tqna_transport_namelist',
'b2tqna_user_transport', 'b2tral_mode', 'b2trcl_conductive_limit',
'b2trcl_core_cond_limit', 'b2trcl_cthe', 'b2trcl_cthi', 'b2trcl_cvsa_mltpl',
'b2trcl_lambda', 'b2trcl_lluciani', 'b2trcl_lthf21', 'b2trcl_lvis21',
'b2treq_phm0', 'b2trno_csig_an_style', 'b2trno_flux_limit_to_dpa',
'b2trno_pol_anom_scale', 'b2upht_stylec', 'b2usmo_cfc0', 'b2ux5p_acpar',
'b2ux5p_cpu', 'b2ux5p_mult_nonzero', 'b2ux5p_mult_solvdim',
'b2ux5p_mult_solvdim1', 'b2ux5p_nltrsol', 'b2ux5p_style', 'b2ux7p_nltrsol',
'b2ux7p_style', 'b2ux9p_nltrsol', 'b2ux9p_style', 'b2wdat_iout',
'b2xzdd_zero_dead_and_core', 'b2yrdr_ns', 'b2ytdr_ndepth1',
'b2ytdr_non_commensurate', 'b2ytdr_ns', 'b2ytdr_rescale_neutrals',
'eirene_ank_mods', 'eirene_dpc_fix', 'eirene_extrap', 'eirene_ionising_core',
'eirene_format', 'eirene_lhalpha', 'eirene_lvib', 'eirene_mc_linearisation',
'eirene_mc_output_style', 'eirene_na_max', 'eirene_na_min',
'eirene_nesepm_istra', 'eirene_neutr_avg', 'eirene_print_minmax',
'eirene_repeat_first_call', 'eirene_savef30', 'eirene_savef31',
'eirene_te_max', 'eirene_te_min', 'eirene_ti_max', 'eirene_ti_min',
'eirene_ua_max', 'eirene_ua_min', 'eirene_underrelax', 'eirene_use_recyceir',
'eirene_uub_style', 'eirene_background', 'eirene_sheath_pot',
'heatdiff1D_linlog', 'heatdiff1D_ratio', 'ma28_nwrite', 'neoclassical_ic',
'set_transport_eta', 'set_transport_eta_alpha', 'set_transport_eta_floor',
'set_transport_eta_ceiling', 'set_transport_ixref',
'set_transport_iyref', 'set_transport_required_te_gradient', 'solps_version',
'tallies_netcdf', )

individual_parameters = (  
    # (Category, Category headline for Fotrtran, (switches in correct order))
    ("Geometry", "1.1. Geometry switches", 
     ("b2agfs_geometry", "b2mwti_jxa", "b2mwti_jxi",
    "b2agmx_pbs_from_basis_mesh", "b2agfs_periodic_bc", "b2agsi_isymm",
    "b2stbc_coreregno", "b2stbc_coreregn2", "b2stbc_pfrregno1", "b2stbc_pfrregno2",
    "b2stbc_solregno", "b2agmt_1d_width", "b2stbr_first_flight_no_of_start_points",
    "b2agfs_geom_match_dist", "b2agfs_Bt_adjust", "b2agfs_Bt_rescale",
    "b2agfs_pit_rescale", "b2agfs_Bt_reversal", "b2agfs_min_pitch",
    "b2agfs_xoffset", "b2agfs_yoffset", "b2agfs_xrescale", "b2agfs_yrescale",
    "b2agfs_nncut", "b2agfs_leftcut", "b2agfs_rightcut", "b2agfs_bottomcut",
    "b2agfs_topcut", "b2agfs_leftcut2", "b2agfs_rightcut2", "b2agfs_bottomcut2",
    "b2agfs_topcut2", "b2agdr_nxiso1", "b2agdr_nxiso2", "b2agdr_nyiso1",
    "b2agdr_nyiso2", )),

    ("Run", "1.2. Run switches", 
     ("b2aidr_read_b2fstate", "b2mndr_ntim", "b2mndr_dtim", "b2mndr_delta_max",
    "b2mndr_delta_min", "b2mndr_dt_change_dec", "b2mndr_dt_change_inc",
    "b2mndr_dt_max", "b2mndr_dt_min", "b2mndr_stim", "b2mndr_etim", "b2mndt_nstg0",
    "b2mndt_nstg1", "b2mndt_nstg2", "b2news_no_solve", "b2mndr_cpu",
    "b2mndr_elapsed", "b2mndr_savecpu", "b2mndr_ismain", "b2news_facdrift_dec",
    "b2news_facdrift_inc", "b2news_facdrift_start", "b2news_facdrift_target",
    "b2news_facExB_dec", "b2news_facExB_inc", "b2news_facExB_start",
    "b2news_facExB_target", "b2news_facvis_dec", "b2news_facvis_inc",
    "b2news_facvis_start", "b2news_facvis_target", "b2stbc_boundary_namelist",
    "b2stbr_neutrals_namelist", "b2srdt_numerics_namelist",
    "b2tqna_transport_namelist", "b2sral_inputfile", "b2tqna_inputfile",
    "b2mndr_eirene", "b2mndr_astra", "b2mndr_rescale_neutrals_sources",
    "b2mndr_rescale_neutrals", "b2mndr_density_rescale",
    "b2stbr_core_sources_rescale", 
    "b2mndt_density_control", "b2stbc_feedback", "b2stbc_ncallfeedback",
    "b2stbr_first_flight", "b2ytdr_ns", "b2ytdr_ndepth1",
    "b2ytdr_rescale_neutrals", "b2ytdr_non_commensurate", )),

    ("Physics", "1.3. Physics switches", 
     ("b2siav_addvis", "b2siav_addvis1","b2npmo_b2sifr_", "b2sihs_istyle_Joule_heating",
    "b2sicf_phm0", "b2sicf_phm1", "b2tfhe_anomalous", "b2tanml_anomalous",
    "b2news_ExB", "b2tfhe_neutral", "b2tfhe_vis_par", "b2tfhe_vis_q",
    "b2trcl_lluciani", "b2trcl_lthf21", "b2trcl_lvis21",
    "b2sqel_artificial_radiation", "b2stbc_fheycore", "b2stbc_fhiycore",
    "b2stbc_fhiycore_kinetic_energy", "b2stbc_fchycore", "b2stbc_fnaycore",
    "b2stbc_isfeedback", "b2stbc_iyped", "b2stbc_ndes", "b2stbc_ndes_sol",
    "b2stbc_nepedm_sol", "b2stbc_nesepm", "b2stbc_nesepm_overshoot",
    "b2stbc_nesepm_pfr", "b2stbc_nesepm_sol", "b2stbc_private_flux_puff",
    "b2stbc_volrec", "b2stbc_volrec_overshoot", "b2stbc_nesepm_minpuff",
    "b2stbc_nesepm_maxpuff", "eirene_nesepm_istra", "b2stbc_type13_ref",
    "b2stbc_type16_ref", "b2stbc_type20_ref", "b2stbc_type21_ref",
    "b2stbc_type16_kinetic_energy", "b2stbc_secmodel", "b2stbr_plate_model",
    "b2stbr_plate_option", "b2stbr_sput_chem_model",
    "b2stbr_sput_chem_cutoff_alpha", "b2stbr_sput_chem_cutoff_beta",
    "b2stbr_sput_mixed_alpha", "b2stbr_sput_mixed_beta", "b2stbr_sput_phys_model",
    "b2stbr_sputter_energy_on", "b2stbr_sput_res", "b2stbr_therm_evap",
    "b2stbr_sput_dst", "b2stbr_sput_dst2", "b2stbr_sput_dst3",
    "b2stbr_sput_frac_flag", "b2stbr_sput_frc", "b2stbr_sput_phys",
    "b2stbr_sput_src", "b2stbr_sput_phys_col", "b2stbr_alpha", "b2stbr_plate_temp",
    "b2stbr_plate_thick", "b2stbr_redep_alpha", "b2stbr_refl_model",
    "b2stbr_reflection_on", "b2mndr_coronal_model", "b2mndr_hz",
    "b2stbr_bas_recycled_neutrals_contr", "b2tfhe_alfTeEh", "b2tfhe_fch_pTe",
    "b2tfnb_ycur", "b2tqce_fke_Zhdanov", "b2tqna_ixref", "b2tqna_user_transport",
    "set_transport_eta", "set_transport_eta_alpha", "set_transport_eta_floor",
    "set_transport_eta_ceiling", "set_transport_ixref", "set_transport_iyref",
    "set_transport_required_te_gradient", "b2tqna_max_df0", "b2tqna_min_df0",
    "b2tqna_new_df0", "b2tqna_ballooning", "b2tqna_ballooning_rescale",
    "b2tqna_bb_ref", "b2tqna_pfr_rescale", "b2tqna_divsol_rescale", "b2sifr_phm0",
    "b2sifr_phm1", "b2sifr_phm2", "b2sifr_phm3", "b2sifr_limthee",
    "b2sifr_limthii", "b2sifr_phm1", "b2trcl_cthe", "b2trcl_cthi", "b2trcl_lambda",
    "b2tlnl_ee", "b2tlnl_ei", "b2tlnl_ii", "b2tfnb_PSch", "b2news_BoRiS",
    "b2tfhe_conduction_only", "b2tfnb_alpha", "b2tfnb_gamma",
    "b2tfnb_flux_limit_min_ti", "b2tlc0_alpha", "b2tlc0_gamma", "b2tlh0_alpha",
    "b2tlh0_gamma", "b2tlh0_flux_limit_min_ti", "b2tlmv_style", "b2sihs_phm0",
    "b2sihs_phm1", "b2sihs_phm2", "b2sihs_phm3", "b2sihs_phm4", "b2sihs_phm5",
    "b2sihs_phm6", "b2sihs_phm7", "b2sdia_facgt", "b2sral_style", "b2sqcx_styl0",
    "b2sqcx_phm0", "b2sqel_phm0", "b2sqel_phm1", "b2sqel_phm2", "b2stel_phm0",
    "b2tfhe_lim_flux", "b2tfhi_lim_flux", "b2treq_phm0", "b2tqca_phm0", "b2tqca_model",
    "b2tqce_model", "b2tqna_model_sig", "b2trno_csig_an_style",
    "b2trno_pol_anom_scale", "b2sifr_phm2", "eirene_lhalpha", "eirene_lvib",
    "eirene_repeat_first_call", "eirene_use_recyceir", "eirene_ionising_core", "eirene_background", "eirene_sheath_pot",
    "b2stel_fix_recomb_energy", "b2mndr_atomic_physics_rescale", 
    "neoclassical_ic", )),

    ("Output", "1.4. Output switches",
     ("b2mndr_b2time", "b2mndr_tally", "b2mndt_moitlv",
    "b2mndt_moqtlv", "b2mndr_mvnum", "b2mndr_mvinc", "b2mndr_plasnum", "b2mndr_plasinc", "b2mndr_cdfmovietim",
    "b2mndr_ntim_save",
     "b2mndr_plasmatim", "b2wdat_iout","b2mndr_na_eps", "b2mndr_po_eps",
    "b2mndr_te_eps", "b2mndr_ti_eps", "b2mndr_ua_eps", "b2mndr_trantim",
    "b2mwti_target_offset", "b2mwti_ismain0", "b2mwqt_style", "tallies_netcdf",
    "b2stbr_b2wall_netcdf", "ank_tracing", "b2stbc_diagno", "b2stbr_output",
    "eirene_savef30", "eirene_savef31", "b2mndr_inverse_ua", "b2yrdr_ns",
    "b2srsm_diagno", "b2ux5p_cpu", "b2ux5p_nltrsol", "b2ux7p_nltrsol",
    "b2ux9p_nltrsol", "eirene_mc_output_style", "ma28_nwrite", "b2news_ncallout",
    "b2tqna_diagno", "b2mndr_idout0", "b2mndr_idout1",
    "eirene_format", "solps_version")),

    ("Numerics", "1.5. Numerics switches", 
    ("b2news_potit", "b2news_potitmin", "b2news_potok", "b2news_ramp_slow",
    "b2mndr_min_areshe", "b2mndr_min_areshi", "b2mndr_min_aresco",
    "b2mndt_nstg_areshe", "b2mndt_nstg_areshi", "b2mndt_nstg_aresco",
    "b2news_nsmin", "b2news_nsmax", "eirene_na_max", "eirene_na_min",
    "eirene_te_max", "eirene_te_min", "eirene_ti_max", "eirene_ti_min",
    "eirene_ua_max", "eirene_ua_min", "eirene_print_minmax",
    "eirene_extrap", "eirene_ank_mods", "eirene_dpc_fix", "b2stbr_eir_src_nhist", "eirene_neutr_avg",
    "eirene_underrelax", "eirene_uub_style", "b2news_area_fix", "b2tfhe_vis_per",
    "b2stbc_sheath_drift_fix", "b2stbc_fix_fch_in_fhe_sheath",
    "b2stbr_potential_at_guard_cell", "b2trcl_conductive_limit",
    "b2trcl_core_cond_limit", "b2tlh0_flux_limit_style", "b2tral_mode",
    "b2tfhe_no_hybr", "b2tfhi_no_hybr", "b2tfnb_no_hybr", "b2tfhe_hybr2",
    "b2tfhi_hybr2", "b2tfhe_upwind", "b2tfhi_upwind", "b2tfnb_pflux_cor", "b2trcl_cvsa_mltpl",
    "b2ux5p_mult_nonzero", "b2ux5p_mult_solvdim", "b2ux5p_mult_solvdim1",
    "b2ux5p_style", "b2ux7p_style", "b2ux9p_style", "b2ux5p_acpar",
    "b2stbc_fchy_dia", "b2stbc_fchy_dia_coreonly", "b2stbc_neoclassical",
    "b2stbc_cbc", "b2stbc_integral_current", "b2stbr_first_flight_dl",
    "b2stbr_first_flight_no_of_flights", "b2stbr_first_flight_table_size",
    "b2stbc_she0ep", "b2stbc_shi0ep", "b2stbc_sna0ep", "b2stbc_bcpot_16_step",
    "b2mndr_na_min", "b2mndr_na_new", "b2news_guard_flows", "b2news_fac_ref",
    "b2news_facdrift_tanh_a", "b2news_facdrift_tanh_b", "b2news_fac_ExB_tanh_a",
    "b2news_fac_ExB_tanh_b", "b2news_fac_vis_tanh_a", "b2news_fac_vis_tanh_b",
    "b2news_iy_nocoreExB", "b2stbc_istyle_cur_contr_on_S_and_N",
    "b2stbc_istyle_fchi", "b2news_recalculate_contributions",
    "b2news_no_b2sral_call", "b2news_do_2nd_b2npco_call",
    "b2news_re_eval_prtls_fluxes", "b2mndt_style", "b2mndt_ntim_step_out",
    "b2stbc_cbsnafac", "b2stbc_fchycore_alpha", "b2stbc_fheycore_alpha",
    "b2stbc_fhiycore_alpha", "b2stbc_fnaycore_alpha", "b2stbc_nesepm_alpha",
    "b2stbc_nesepm_beta", "b2stbc_nesepm_gamma", "b2stbc_volrec_alpha",
    "b2stbc_volrec_beta", "b2stbr_sput_chem_alpha", "b2stbr_sput_phys_alpha",
    "b2stbc_type13_fac", "b2stbc_type13_norm", "heatdiff1D_linlog",
    "heatdiff1D_ratio", "b2tlh0_hcimx_flag", "b2trno_flux_limit_to_dpa",
    "b2mndr_isfb", "b2mndr_ixfb", "b2mndr_iyfb",
    "b2mndr_ne_wanted", "b2mndr_ne_wanted_time", "b2mndt_use_b2srst", "b2mndt_rxf",
    "b2news_xfm0", "b2news_xfm1", "b2news_xfm2", "b2news_xfm3", "b2npco_pcm0",
    "b2npco_pcm1", "b2npco_rxg", "b2npht_pcm0", "b2npht_pcm1", "b2npht_rxg",
    "b2npht_style", "b2nph9_style", "b2npp7_style", "b2npmo_rxg", "b2news_poteq",
    "b2nxdv_style", "b2nxfc_style", "b2nxfx_style", "b2sifr_styl0", "b2sifr_styl1",
    "b2sigp_style", "b2xzdd_zero_dead_and_core", "b2sihs_rf0", "b2sihs_rf1",
    "b2sihs_rf2", "b2sihs_rf3", "b2sihs_rf4", "b2sihs_style", "b2srdt_phm0",
    "b2srdt_phm1", "b2srdt_phm3", "b2srdt_phm4", "b2srdt_phm5", "b2srst_rf0",
    "b2srst_rf1", "b2srst_rf2", "b2srst_rf3", "b2stcx_rg0", "b2stcx_styl0",
    "eirene_mc_linearisation", "b2stbm_linearisation","b2stbm_impgyro_mod", 
    "b2stel_rg0", "b2stel_rg1",
    "b2stel_rxm0", "b2stel_rxm1", "b2stel_rxm2", "b2stel_rxm3", "b2stel_rxm4",
    "b2stel_styl0", "b2tfcc_xfac", "b2tfhe_mdf", "b2tfhe_no_current", "b2tfhi_mdf",
    "b2tfnb_drift_style", "b2tfnb_fnb_nodrift_style", "b2tfnb_mdf",
    "b2tfnb_xfrhie", "b2upht_stylec", "b2usmo_cfc0",
    "b2srsm_enable")),

    ("Atomic Physics", "1.6. Atomic physics switches", 
     ('b2ardr_fix_cx', 'b2ardr_no_weisheit', 'b2ardr_no_smoothing',
      'b2ardr_fix_recomb', 'b2ardr_rtnt', 'b2ardr_rtnn', 
      'b2mndr_dpc_mod_rates_ne_hot_frac', 'b2mndr_dpc_mod_rates_te_hot',)))

def check_constant(string):
    if 'pzmm' in string or 'upgrade' in string or string == 'iter' or string=='+c' or string=='-c':
        return True
    for char in string:
        if not char.isdigit():
            if char in ['.', 'e', '-', '+']:
                continue
            else:
                return False
    return True


def fort_switch(name, default, category, note):
    # Some switches may have no default value or categories.
    category = 'None' if category is None else category
    pname = "'" + name + "'"
    if check_constant(default):
        pdefault = '\'' + default + '\''
    else:
        pdefault = default
    fort = "*    "
    fort += pname
    fort += (27-len(pname) if 27-len(pname) >= 0 else 1) * ' ' + pdefault
    fort += (55-len(fort) if 55-len(fort) >= 0 else 1) * ' ' + category
    if note:
        fort += (67 - len(fort)) * ' ' + note + '\n'
    else:
        fort += '\n'
    #fort = "*    {:<26} {:<22} {:<14}\n".format(pname, pdefault, category)
    return fort

xml_name = "test.xml"
tree = etree.parse(xml_name)
root = tree.getroot()

b2cdci_switches = {}

for category in root.find('module[@name="b2mn"]'):
    for switchgroup in category.findall('switchgroup'):
        switch_description = switchgroup.findtext('description')
        for switch in switchgroup.findall('switch'):
            switch_name = switch.findtext('name')
            switch_default = switch.findtext('default')
            switch_note = switch.findtext('note')
            b2cdci_switches[switch_name] = (switch_default, 
                                            switch_description, 
                                            switch_note,
                                            category.attrib['name'])

    for switch in category.findall('switch'):
        switch_name = switch.findtext('name')
        switch_default = switch.findtext('default')
        switch_description = switch.findtext('description')
        switch_note = switch.findtext('note')
        b2cdci_switches[switch_name] = (switch_default,
                                        switch_description,
                                        switch_note,
                                        category.attrib['name'])


DELIMITER = """*---------------------------------------------------------------\
--------\n"""


def dedent(description):
    """ Removes first empty fort from description and any leading tabs
        from the next fort before the description and any following forts.
        First forts are wrapped to 70 characters.

    :param description(string): from the XML generated tooltips dictionary
    :return: formatted output for the tooltip
    """
    trim_start = 0  # Remove any leading newfort that affects dedent
    while trim_start < len(description) and description[trim_start] == '\n':
        trim_start += 1
    description = textwrap.dedent(description[trim_start:])
    lines = description.splitlines()
    output = ''
    for line in lines:
        output += '*    ' + '\n*    '.join(textwrap.wrap(line, 70)) + '\n'
    return output[0:]  # remove last newline


specification = root.find('module[@name="b2mn"]/routine[@name="b2cdci"]')

purpose = specification.findtext('purpose')
introduction = specification.findtext('introduction')


fort = DELIMITER
fort += """* Generated by b2cdci.py from solps-input.xml. DO NOT EDIT THIS FILE!
*.specification

      subroutine b2cdci ()
      implicit none

"""
fort += DELIMITER
fort += '*.documentation\n*\n'
fort += '*  1. purpose\n*\n'
fort += dedent(purpose)
fort += '*\n*\n' + DELIMITER
fort += '*.text\n*\n'
fort += '*  0. Overview and naming conventions.\n*\n'
fort += dedent(introduction)
fort += '*\n*\n'

fort += """*    Switch name:               Default value:         Category:
*  -----------------------------------------------------------------\n"""

for switch_name in switch_list:
    default = b2cdci_switches[switch_name][0]
    note = b2cdci_switches[switch_name][2]
    category = b2cdci_switches[switch_name][3]
    fort += fort_switch(switch_name, default, category, note)

fort += '*  -----------------------------------------------------------------' 
fort += '\n*\n*\n*\n'
fort += '*  1. Purpose of individual parameters\n*\n'



for section in individual_parameters:
    category = section[0]
    section_title = section[1]
    switches_list = section[2]

    fort += '*   ' + section_title + '\n'

    switch_group = []
    group_description = ''

    for el in switches_list:
        switch_name = el
        default = b2cdci_switches[switch_name][0]
        description = b2cdci_switches[switch_name][1]
        note = b2cdci_switches[switch_name][2]
        category = b2cdci_switches[switch_name][3]

        # Special cases
        if switch_name == 'b2ardr_no_smoothing':
            category = 'Numerics'
        elif switch_name == 'b2sifr_phm2':
            category = 'Unused'
        else:
            category = section[0]

        if description == group_description:
            switch_group.append((switch_name, default, note))

        # Special case
        elif description != group_description:
            if switch_group and switch_group[-1][0] == 'b2sifr_limthii':
                switch_group.append((switch_name, default, note))
                continue
            for switch in switch_group:
                # Special case
                if switch[0] == 'b2ardr_no_smoothing':
                    category = 'Numerics'
                else:
                    category = section[0]

                fort += fort_switch(switch[0], switch[1], category, switch[2])
            fort += dedent(group_description) + '*\n'
            switch_group = [(switch_name, default, note)]
            group_description = description

    # Last group processed
    for switch in switch_group:
        fort += fort_switch(switch[0], switch[1], category, switch[2])
    fort += dedent(group_description) + '*\n'
fort += """*-----------------------------------------------------------------------
*.end b2cdci

      end subroutine b2cdci
"""

with open('b2cdci.F', 'w') as f:
    f.write(fort)
