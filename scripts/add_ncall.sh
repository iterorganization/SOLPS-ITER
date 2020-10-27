files="b2mndt_b.F90 b2npmo_b.F90 b2sicf_b.F90 b2sral_b.F90 b2stbc_phys_b.F90 b2stel_b.F90 b2tfhe__b.F90 b2tinnt_b.F90 b2tlmv_b.F90 b2tral_b.F90 b2usht_b.F90"
files+=" b2news__b.F90 b2nxdv_b.F90 b2sigp_b.F90 b2srdt_b.F90 b2stbr_b.F90 b2tanml_b.F90 b2tfhi__b.F90 b2tlh0_b.F90 b2tqca_b.F90 b2trcl_b.F90 b2usmo_b.F90"
files+=" b2npco_b.F90 b2nxfc_b.F90 b2sihs__b.F90 b2srst_b.F90 b2stbr_phys_b.F90 b2tcpa_b.F90 b2tfnb_b.F90 b2tlhe_b.F90 b2tqce_b.F90 b2trno_b.F90"
files+=" b2npht_b.F90 b2nxfx_b.F90 b2sqel_b.F90 b2stbc_b.F90 b2stcx_b.F90 b2tfcc_b.F90 b2tiner_b.F90 b2tlhi_b.F90 b2tqna_b.F90 b2upht_b.F90"
files+=" b2urmo_b.F90 b2tfch__b.F90 b2xehy_b.F90 b2xehx_b.F90"
# MODLIST=`ls b2mod*_b.F90 b2us_*_b.F90 | sed -e 's/_b.F90//g'`
for d in $files; do
 vv=`echo $d | sed -e 's/.F90//g' | awk '{print toupper($0)}'`
# echo $vv
 sed -i -e "/END SUBROUTINE $vv/i\  ncall = ncall + 1" $d
done;

 sed -i -e "/END SUBROUTINE PRECOMPUTE_KUL_QUANT_B/i\  ncall = ncall + 1" b2mod_recycle_diff.F90


