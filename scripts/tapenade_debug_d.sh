rm print_tgt_gradient.F set_tgt_perturbation.F

sed -i -e 's/LOGICAL :: arg10/LOGICAL :: arg10(2*m%nfc)/g' b2us_prep_diff.F90
sed -i '/switchd%b2mndr_na_min = 0.D0/d' b2stbc_d.F90  b2stbc_phys_d.F90 b2npco_d.F90
sed -i '/switchd%fch_pte = 0.D0/d' b2tqce_d.F90 b2trcl_d.F90
sed -i '/switchd%b2sqcx_phm0 = 0.D0/d' b2trcl_d.F90
sed -i -e 's/LOGICAL :: arg1/LOGICAL :: arg1(m%nfc)/g' find_faces_d.F90
sed -i -e 's/SIZE(sx, 1)+1/n/g' myblas_d.F90 sfill_d.F90
sed -i -e 's/SIZE(sy, 1)+1/n/g' myblas_d.F90
sed -i -e 's/(SIZE(\&/\&/g' sfill_d.F90 myblas_d.F90
sed -i -e 's/\&                                s., 1)+1)\/8)/\&                                n\/8)/g' sfill_d.F90 myblas_d.F90
sed -i -e 's/(SIZE(sx, &/n\&/g' myblas_d.F90 sfill_d.F90 
sed -i -e 's/\&                            1)+1)\/8)/\&                            \/8)/g' myblas_d.F90 sfill_d.F90
sed -i -e 's/(SIZE(sy, \&/n\&/g' myblas_d.F90
sed -i -e 's/(SIZE(sx\&/\&/g' myblas_d.F90
sed -i -e 's/\&                              , 1)+1)\/8)/\&                              n\/8)/g' myblas_d.F90

# i put intent in for pld, geod, rtd, rtwd in b2stel_d
sed -i -e 's/TYPE(GEOMETRY), INTENT(IN) :: geod/TYPE(GEOMETRY), INTENT(INout) :: geod/g' b2stel_d.F90
sed -i -e 's/TYPE(B2PLASMA_DIFF), INTENT(IN)/TYPE(B2PLASMA_DIFF), INTENT(INout)/g' b2stel_d.F90
sed -i -e 's/TYPE(B2RATES_DIFF), INTENT(IN) :: rtd/TYPE(B2RATES_DIFF), INTENT(INout) :: rtd/g' b2stel_d.F90
sed -i -e 's/TYPE(B2RATESWORK), INTENT(IN) :: rtwd/TYPE(B2RATESWORK), INTENT(INout) :: rtwd/g' b2stel_d.F90

sed -i -e 's/MODULE B2MOD_GEO/MODULE B2MOD_GEO_DIFF/g' b2mod_geo_diff.F90
mv b2mod_sources_diff.F90 b2mod_sources.F90
sed -i -e 's/MODULE B2MOD_SOURCES_DIFF/MODULE B2MOD_SOURCES/g' b2mod_sources.F90
sed -i -e 's/use b2mod_sources_diff/use b2mod_sources/g' *.F*
mv b2mod_transport_diff.F90 b2mod_transport.F90
sed -i -e 's/MODULE B2MOD_TRANSPORT_DIFF/MODULE B2MOD_TRANSPORT/g' b2mod_transport.F90
mv b2mod_anomalous_transport_diff.F90 b2mod_anomalous_transport.F90
sed -i -e 's/MODULE B2MOD_ANOMALOUS_TRANSPORT_DIFF/MODULE B2MOD_ANOMALOUS_TRANSPORT/g' b2mod_anomalous_transport.F90

sed -i -e 's/8ARRAY(parm_hced, r8\/8)/8(parm_hced, r8\/8)/g' b2tqna_d.F90
sed -i -e 's/8ARRAY(df0d, r8\/8)/8(df0d, r8\/8)/g' b2tqna_d.F90
sed -i -e 's/8ARRAY(dnnd, r8\/8)/8(dnnd, r8\/8)/g' b2tqna_d.F90
sed -i -e 's/8ARRAY(dind, r8\/8)/8(dind, r8\/8)/g' b2tqna_d.F90
sed -i -e 's/8ARRAY(diond, r8\/8)/8(diond, r8\/8)/g' b2tqna_d.F90
sed -i -e 's/8ARRAY(vcxd, r8\/8)/8(vcxd, r8\/8)/g' b2tqna_d.F90
sed -i -e 's/8ARRAY(arg2d, r8\/8)/8(arg2d, r8\/8)/g' b2tqna_d.F90
sed -i -e 's/8ARRAY(wrk0d, r8\/8)/8(wrk0d, r8\/8)/g' b2tqna_d.F90
sed -i -e 's/8ARRAY(tavd, r8\/8)/8(tavd, r8\/8)/g' b2tqna_d.F90
sed -i -e 's/8ARRAY(result1d, r8\/8)/8(result1d, r8\/8)/g' b2tqna_d.F90
sed -i -e 's/8ARRAY(max3d, r8\/8)/8(max3d, r8\/8)/g' b2tqna_d.F90

sed -i -e 's/expu_d = DIM_D(arg1, arg1d, cutlo, cutlod, expu)/CALL DIM_D(arg1, arg1d, cutlo, cutlod, expu, expu_d)/g' b2mod_math_diff.F90
sed -i -e 's/expu2_d = DIM_D(arg1, arg1d, cutlo, cutlod, expu2)/CALL DIM_D(arg1, arg1d, cutlo, cutlod, expu2, expu2_d)/g' b2mod_math_diff.F90
sed -i -e '/CALL DIM_D/i\    cutlod=0.0_R8' b2mod_math_diff.F90

sed -i -e '/REAL(kind=r8) :: temp1/i\     REAL(kind=r8) :: dummy' b2usht_d.F90
sed -i -e '/result1d = DIM_D(1.0_R8, 0.D0, arg1, arg1d, result1)/i\     dummy = 0.0_R8' b2usht_d.F90
sed -i -e '/result1d = DIM_D(1.0_R8, 0.D0, arg1, arg1d, result1)/ call DIM_D(1.0_R8, dummy, arg1, arg1d, result1, result1d)/g'

sed -i -e 's/pld\%na = 0.D0/\!pld\%na = 0.D0/g' b2tfhe__d.F90 b2mod_recycle_diff.F90 b2stbc_phys_d.F90
sed -i -e 's/nad = 0.D0/\!nad = 0.D0/g' b2upht_d.F90
sed -i -e 's/pld\%ua = 0.D0/\!pld\%ua = 0.D0/g' b2stbc_phys_d.F90
sed -i -e 's/pld\%po = 0.D0/\!pld\%po = 0.D0/g' b2stbc_phys_d.F90
sed -i -e 's/pld\%te = 0.D0/\!pld\%te = 0.D0/g' b2stbc_phys_d.F90
sed -i -e 's/pld\%ti = 0.D0/\!pld\%ti = 0.D0/g' b2stbc_phys_d.F90
sed -i -e 's/pld\%kt = 0.D0/\!pld\%kt = 0.D0/g' b2stbc_phys_d.F90
sed -i -e 's/rtd\%rza = 0.D0/\!rtd\%rza = 0.D0/g' b2stbc_phys_d.F90
sed -i -e 's/geod\%cvbb = 0.D0/\!geod\%cvbb = 0.D0/g' b2mndt_d.F90 b2news__d.F90 b2sral_d.F90 b2stel_d.F90 b2tqca_d.F90 b2tqce_d.F90 b2tqin_d.F90 b2tral_d.F90 b2trcl_d.F90

sed -i '/switchd%fnb_drift_hyb = 0.D0/d' b2tfnb_d.F90 
  
sed -i -e '/EXTERNAL SFILL_D/a\  real (kind=r8) :: dummydiff' b2xpni_d.F90 b2xpne_d.F90 b2tqna_d.F90 b2trno_d.F90 b2npmo_d.F90 b2sral_d.F90 b2stbc_d.F90 b2stbr_d.F90 b2stcx_d.F90 b2stel_d.F90 b2tqca_d.F90 b2tqce_d.F90 b2trcl_d.F90 b2xpfe_d.F90 b2xpfi_d.F90 b2xpfn_d.F90 b2xpfz_d.F90 b2xpnm_d.F90
sed -i -e '/CALL SFILL_D/i\  dummydiff = 0.0_R8' b2xpni_d.F90 b2xpne_d.F90 b2tqna_d.F90 b2trno_d.F90 b2npmo_d.F90 b2sral_d.F90 b2stbc_d.F90 b2stbr_d.F90 b2stcx_d.F90 b2stel_d.F90 b2tqca_d.F90 b2tqce_d.F90 b2trcl_d.F90 b2xpfe_d.F90 b2xpfi_d.F90 b2xpfn_d.F90 b2xpfz_d.F90 b2xpnm_d.F90
sed -i -e 's/SFILL_D(ncv, 0.0_R8, 0.D0/SFILL_D(ncv, 0.0_R8, dummydiff/g' b2tqna_d.F90 b2xpne_d.F90 b2trno_d.F90 b2xpnm_d.F90 b2trcl_d.F90 b2tqce_d.F90 b2tqca_d.F90 b2npmo_d.F90
sed -i -e 's/SFILL_D(arg1, 0.0_R8, 0.D0/SFILL_D(arg1, 0.0_R8, dummydiff/g' b2tqna_d.F90 b2xpni_d.F90 b2trno_d.F90 b2xpfe_d.F90 b2xpfi_d.F90 b2xpfn_d.F90 b2xpfz_d.F90 b2trcl_d.F90 b2sral_d.F90 b2stbc_d.F90 b2stbr_d.F90 b2stcx_d.F90 b2stel_d.F90
sed -i -e 's/CALL SFILL_D(nfc, 0.0e0_R8, 0.D0/CALL SFILL_D(nfc, 0.0e0_R8, dummydiff/g' b2trno_d.F90

sed -i -e 's/CALL SFILL_D(nfc, 1.0_R8, 0.D0/CALL SFILL_D(nfc, 1.0_R8, dummydiff/g' b2trcl_d.F90
sed -i -e 's/CALL SFILL_D(ncv, 1.0_R8, 0.D0/CALL SFILL_D(ncv, 1.0_R8, dummydiff/g' b2trcl_d.F90

sed -i -e 's/use b2mod_geo_diff/use b2mod_geo/g' ./*F*

# NOT NEEDED ANYMORE?
#sed -i '/switchd%b2npco_pcm0 = 0.D0/d' b2npco_d.F90 
#sed -i '/switchd%b2npco_rxg = 0.D0/d' b2npco_d.F90 
#sed -i '/switchd%art_rad = 0.D0/d' b2sqel_d.F90 
#sed -i '/ switchd%b2stcx_rg0 = 0.D0/d' b2stcx_d.F90 
#sed -i '/switchd%prl_cur = 0.D0/d' b2tcpa_d.F90
#sed -i '/switchd%b2sifr_phm2 = 0.D0/d' b2tcpa_d.F90


#sed -i '/switchd%b2trcl_lambda = 0.D0/d' b2treq_d.F90 b2trcl_d.F90 b2tqce_d.F90 b2tqca_d.F90 b2tlnl_d.F90 b2sihs__d.F90 b2npmo_d.F90 b2npht_d.F90
#sed -i '/switchd%b2treq_phm0 = 0.D0/d' b2treq_d.F90
  
#sed -i '/switchd%cthev = 0.D0/d' b2trcl_d.F90
#sed -i '/switchd%cthiv = 0.D0/d' b2trcl_d.F90
#sed -i '/switchd%prl_cur = 0.D0/d' b2trcl_d.F90 b2tqce_d.F90 b2tfch__d.F90
#sed -i '/switchd%b2tlv0_alpha = 0.D0/d' b2tlv0_d.F90 
#sed -i '/switchd%b2tlv0_gamma = 0.D0/d' b2tlv0_d.F90
#sed -i '/switchd%b2tlh0_alpha = 0.D0/d' b2tlh0_d.F90 
#sed -i '/switchd%b2tlh0_gamma = 0.D0/d' b2tlh0_d.F90
#sed -i '/switchd%b2tlc0_alpha = 0.D0/d' b2tlc0_d.F90 
#sed -i '/switchd%b2tlc0_gamma = 0.D0/d' b2tlc0_d.F90

#sed -i '/switchd%vspa_vis_par = 0.D0/d' b2tfch__d.F90
#sed -i '/switchd%fch_ion_neutral = 0.D0/d' b2tfch__d.F90
#sed -i '/switchd%dia_cur = 0.D0/d' b2tfch__d.F90
#sed -i '/switchd%fch_inert = 0.D0/d' b2tfch__d.F90
#sed -i '/switchd%b2sifr_phm2 = 0.D0/d' b2tfch__d.F90
#sed -i '/switchd%fch_anomalous = 0.D0/d' b2tfch__d.F90

#sed -i '/switchd%b2tfnb_alpha = 0.D0/d' b2tfnb_d.F90
#sed -i '/switchd%b2tfnb_gamma = 0.D0/d' b2tfnb_d.F90
#sed -i '/switchd%b2tfnb_flux_limit_min_ti = 0.D0/d' b2tfnb_d.F90

#sed -i '/switchd%fhepsch = 0.D0/d' b2tfhe__d.F90
#sed -i '/switchd%alfteeh = 0.D0/d' b2tfhe__d.F90
#sed -i '/switchd%fhe_vdia_par = 0.D0/d' b2tfhe__d.F90
    
#sed -i '/switchd%mfp_b1 = 0.D0/d' b2stbr_phys_d.F90
#sed -i '/switchd%mfp_b2 = 0.D0/d' b2stbr_phys_d.F90
sed -i '/switchd%auto_spatial_hyb_mfp_1 = 0.D0/d' b2stbr_phys_d.F90
sed -i '/switchd%auto_spatial_hyb_mfp_2 = 0.D0/d' b2stbr_phys_d.F90


sed -i '/switchd%sna0ep = 0.D0/d' b2stbc_d.F90
sed -i '/switchd%she0ep = 0.D0/d' b2stbc_d.F90
sed -i '/switchd%shi0ep = 0.D0/d' b2stbc_d.F90
sed -i '/switchd%b2stbc_neoclassical = 0.D0/d' b2stbc_d.F90 
sed -i '/switchd%integral_current = 0.D0/d' b2stbc_d.F90
sed -i '/switchd%b2stbc_fchy_dia = 0.D0/d' b2stbc_d.F90
sed -i '/switchd%qalfmin = 0.D0/d' b2stbc_d.F90
sed -i '/switchd%delpo = 0.D0/d' b2stbc_d.F90
sed -i '/switchd%b2stbc_phm0 = 0.D0/d' b2stbc_d.F90
sed -i '/switchd%b2stbc_phm1 = 0.D0/d' b2stbc_d.F90

sed -i '/switchd%fch_stochastic = 0.D0/d' b2sihs__d.F90 b2npht_d.F90
sed -i '/switchd%b2sihs_phm0 = 0.D0/d' b2sihs__d.F90 b2npht_d.F90
sed -i '/switchd%b2sihs_phm1 = 0.D0/d' b2sihs__d.F90 b2npht_d.F90
sed -i '/switchd%b2sihs_phm2 = 0.D0/d' b2sihs__d.F90 b2npht_d.F90
sed -i '/switchd%b2sihs_phm3 = 0.D0/d' b2sihs__d.F90 b2npht_d.F90
sed -i '/switchd%b2sihs_phm5 = 0.D0/d' b2sihs__d.F90 b2npht_d.F90
sed -i '/switchd%b2sihs_phm6 = 0.D0/d' b2sihs__d.F90 b2npht_d.F90
sed -i '/switchd%b2sihs_phm8 = 0.D0/d' b2sihs__d.F90 b2npht_d.F90
sed -i '/switchd%b2sihs__rf0 = 0.D0/d' b2sihs__d.F90 b2npht_d.F90
sed -i '/switchd%b2sihs__rf1 = 0.D0/d' b2sihs__d.F90 b2npht_d.F90
sed -i '/switchd%b2sihs__rf2 = 0.D0/d' b2sihs__d.F90 b2npht_d.F90
sed -i '/switchd%b2sihs__rf3 = 0.D0/d' b2sihs__d.F90 b2npht_d.F90
sed -i '/switchd%cfc0 = 0.D0/d' b2npmo_d.F90
sed -i '/switchd%b2sian_phm0 = 0.D0/d' b2npmo_d.F90
sed -i '/switchd%b2sicf_phm0 = 0.D0/d' b2npmo_d.F90
sed -i '/switchd%b2sicf_phm1 = 0.D0/d' b2npmo_d.F90
sed -i '/switchd%b2sigp_phm0 = 0.D0/d' b2npmo_d.F90
sed -i '/switchd%b2nxfv_phm0 = 0.D0/d' b2npmo_d.F90
sed -i '/switchd%b2nxfv_phm1 = 0.D0/d' b2npmo_d.F90
sed -i '/switchd%b2npmo_rxg = 0.D0/d' b2npmo_d.F90
sed -i '/switchd%b2npht_pcm0 = 0.D0/d' b2npht_d.F90
sed -i '/switchd%b2npht_rxg = 0.D0/d' b2npht_d.F90
sed -i '/switchd%b2sikt_fac_sheath_core = 0.D0/d' b2npht_d.F90
sed -i '/switchd%b2sikt_fac_sheath = 0.D0/d' b2npht_d.F90
sed -i '/switchd%b2sikt_fac_aniso = 0.D0/d' b2npht_d.F90

#sed -i -e 's/EXTERNAL SUBINI, SUBEND, XERTST, SFILL, DIM/EXTERNAL SUBINI, SUBEND, XERTST, SFILL/g' b2usht_d.F90
#sed -i -e '/EXTERNAL DIM_D/i\  INTRINSIC DIM' b2usht_d.F90 expu2_d.F90 expu_d.F90
#sed -i -e 's/EXTERNAL MACHSFR, DIM/EXTERNAL MACHSFR/g' expu2_d.F90 expu_d.F90


#gedit b2npht_d.F90 b2npmo_d.F90 b2sihs__d.F90 b2stbc_d.F90 b2stbr_phys_d.F90 b2tfch__d.F90 b2tfhe__d.F90 b2tfnb_d.F90 b2tlc0_d.F90 b2tlh0_d.F90 b2tlnl_d.F90 b2tlv0_d.F90 b2tqca_d.F90 b2tqce_d.F90 b2trcl_d.F90 b2treq_d.F90 
cp $TAPENADEDIR/ADFirstAidKit/adStack.h .
cp $TAPENADEDIR/ADFirstAidKit/adStack.c .
cp $TAPENADEDIR/ADFirstAidKit/adComplex.h .
