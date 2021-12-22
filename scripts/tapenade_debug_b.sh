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
#sed -i -e '/EXTERNAL DIM_B/i\  real(kind=r8) DIM_B' b2usht_d.F90 expu2_d.F90 expu_d.F90
