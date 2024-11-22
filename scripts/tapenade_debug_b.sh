
rm set_adj_gradient.F
sed -i -e 's/ISIZE1OFfceb/mpg%nFc/g' b2us_geo_diff.F90 
sed -i -e "s/arg1(2\*m%nfc)0/arg10(2\*m%nfc)/g" b2us_prep_diff.F90
sed -i -e 's/ISIZE1OFarg1/mpg%nCv/g' b2npmo_b.F90 
sed -i -e 's/ISIZE1OFresult1/mpg%nCv/g' b2npmo_b.F90
sed -i -e 's/smo0_cxb(chunklength)/smo0_cxb(ncv, 0:3, 0:ns-1)/g' b2sral_b.F90
sed -i -e 's/sna0_cxb(chunklength)/sna0_cxb(ncv, 0:1, 0:ns-1)/g' b2sral_b.F90
sed -i -e 's/shi0_cxb(chunklength)/shi0_cxb(ncv, 0:3)/g' b2sral_b.F90
sed -i -e 's/smo0_cx(chunklength)/smo0_cx(ncv, 0:3, 0:ns-1)/g' b2sral_b.F90
sed -i -e 's/sna0_cx(chunklength)/sna0_cx(ncv, 0:1, 0:ns-1)/g' b2sral_b.F90
sed -i -e 's/shi0_cx(chunklength)/shi0_cx(ncv, 0:3)/g' b2sral_b.F90
sed -i -e 's/ISIZE1OFarg1/nCv/g' b2tqna_b.F90
sed -i -e 's/ISIZE1OFresult1/nCv/g' b2tqna_b.F90
sed -i -e 's/ISIZE1OFcvbb/nCv/g' b2tvspa_b.F90
sed -i -e 's/SIZE(sx, 1)+1/n/g' myblas_b.F90 sfill_b.F90
sed -i -e 's/SIZE(sy, 1)+1/n/g' myblas_b.F90

sed -i -e 's/plb\%na = 0.D0/\!plb\%na = 0.D0/g' b2tfhe__b.F90 b2mod_recycle_diff.F90 b2stbc_phys_b.F90
sed -i -e 's/nab = 0.D0/\!nab = 0.D0/g' b2upht_b.F90
sed -i -e 's/plb\%ua = 0.D0/\!plb\%ua = 0.D0/g' b2stbc_phys_b.F90
sed -i -e 's/plb\%po = 0.D0/\!plb\%po = 0.D0/g' b2stbc_phys_b.F90
sed -i -e 's/plb\%te = 0.D0/\!plb\%te = 0.D0/g' b2stbc_phys_b.F90
sed -i -e 's/plb\%ti = 0.D0/\!plb\%ti = 0.D0/g' b2stbc_phys_b.F90
sed -i -e 's/plb\%kt = 0.D0/\!plb\%kt = 0.D0/g' b2stbc_phys_b.F90
sed -i -e 's/rtb\%rza = 0.D0/\!rtb\%rza = 0.D0/g' b2stbc_phys_b.F90

sed -i -e 's/EXTERNAL SUBINI, SUBEND, XERTST, SFILL, DIM/EXTERNAL SUBINI, SUBEND, XERTST, SFILL/g' b2usht_b.F90
sed -i -e 's/EXTERNAL MACHSFR, DIM/EXTERNAL MACHSFR/g' expu2_b.F90 expu_b.F90
sed -i '/EXTERNAL B2TRCI/d' b2mod_driver_diff.F90

sed -i -e "s/, uold, mold, told, uoldb, moldb, toldb, uoldb0, moldb0, toldb0/, uold, mold, told/g" b2mod_driver_diff.F90

sed -i -e 's/ISIZE1OFfcbb/nFc/g' b2siav_b.F90 b2tvspa_b.F90 b2tvsq_b.F90 b2tvskt_b.F90 b2tfch__b.F90 b2tfnb_b.F90 b2tinnt_b.F90
sed -i -e 's/ISIZE1OFvxbb/nVx/g' b2siav_b.F90
sed -i -e 's/ISIZE1OFcvbb/nCv/g' b2siav_b.F90 b2tvsq_b.F90
sed -i -e 's/ISIZE1OFresult1/nCv/g' b2sikt_b.F90 b2npmo_b.F90 b2tqna_b.F90 b2trcl_b.F90
sed -i -e 's/ISIZE1OFarg1/nCv/g' b2npmo_b.F90 b2stbr_phys_b.F90 b2mod_recycle_diff.F90 b2tqna_b.F90 b2sikt_b.F90 b2trcl_b.F90 calc_res_fp_b.F90


sed -i -e 's/DIMENSION(SIZE(x1, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x2, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x3, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x4, 1), SIZE(x4, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x6, 1))/DIMENSION(mpg%nCv)/g' b2mod_driver_diff.F90
sed -i -e 's/DIMENSION(SIZE(x7, 1), SIZE(x7, 2))/DIMENSION(mpg%nCv, 0:state%pl%ns-1)/g' b2mod_driver_diff.F90

cp $TAPENADEDIR/ADFirstAidKit/adDebug.c .
cp $TAPENADEDIR/ADFirstAidKit/adDebug.h .
