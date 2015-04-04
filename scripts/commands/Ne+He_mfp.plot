'${HOST} ${PWD} `date` T=${TIME}' extl glob
a4l 2 1 page
# clvl lbof
phys vesl 1.1 rmin 1.9 rmax -0.7 zmax -1.2 zmin sep
logf

# vth sqrt(2*te*qe/(mu*mp))

ti qe rm* 2.0 rm* mi 8 8 sumz m/ sqrt ! vth

ne

# ElectronImpactIonizationNeEir(te)=1e-6*exp(((((((((-5.920062008659E-06)*log(te)+3.039725447970E-04)*log(te)-6.741770005530E-03)*log(te)+8.425486548641E-02)*log(te)-6.505105290012E-01)*log(te)+3.222200909755E+00)*log(te)-1.045785599440E+01)*log(te)+2.213072746982E+01)*log(te)-4.159776009189E+01)

te ln  -5.920062E-06 dup rm*
        3.039725E-04 rm+ over m*
       -6.741770E-03 rm+ over m*
        8.425487E-02 rm+ over m*
       -6.505105E-01 rm+ over m*
        3.222201E+00 rm+ over m*
       -1.045786E+01 rm+ over m*
        2.213073E+01 rm+ over m*
       -4.159776E+01 rm+
        exp 1e-6 rm*

swap drop m* m/

'Ne mean free path (based on ion temp)' extl 1.0e-3 fmin 1.0 fmax cont

# vth sqrt(2*te*qe/(mu*mp))

ti qe rm* 2.0 rm* mi 18 18 sumz m/ sqrt ! vth

ne

# ElectronImpactIonizationHeEir(te)=1e-6*exp(((((((((-3.649161E-06)*log(te)+2.067236E-04)*log(te)-5.009056E-03)*log(te)+6.795391E-02)*log(te)-5.685119E-01)*log(te)+3.058039)*log(te)-1.075323E+01)*log(te)+2.391597E+01)*log(te)-4.409865E+01)

te ln  -3.649161E-06 dup rm*
        2.067236E-04 rm+ over m*
       -5.009056E-03 rm+ over m*
        6.795391E-02 rm+ over m*
       -5.685119E-01 rm+ over m*
        3.058039E+00 rm+ over m*
       -1.075323E+01 rm+ over m*
        2.391597E+01 rm+ over m*
       -4.409865E+01 rm+
        exp 1e-6 rm*

swap drop m* m/

'He mean free path (based on ion temp)' extl 1.0e-3 fmin 1.0 fmax cont

#  Based on neutral temperatures

# vth sqrt(2*te*qe/(mu*mp))

tib2 3 3 sumz qe rm* 2.0 rm* mi 8 8 sumz m/ sqrt ! vth

ne

# ElectronImpactIonizationNeEir(te)=1e-6*exp(((((((((-5.920062008659E-06)*log(te)+3.039725447970E-04)*log(te)-6.741770005530E-03)*log(te)+8.425486548641E-02)*log(te)-6.505105290012E-01)*log(te)+3.222200909755E+00)*log(te)-1.045785599440E+01)*log(te)+2.213072746982E+01)*log(te)-4.159776009189E+01)

te ln  -5.920062E-06 dup rm*
        3.039725E-04 rm+ over m*
       -6.741770E-03 rm+ over m*
        8.425487E-02 rm+ over m*
       -6.505105E-01 rm+ over m*
        3.222201E+00 rm+ over m*
       -1.045786E+01 rm+ over m*
        2.213073E+01 rm+ over m*
       -4.159776E+01 rm+
        exp 1e-6 rm*

swap drop m* m/

'Ne mean free path (based on neutral temp)' extl 1.0e-3 fmin 1.0 fmax cont

# vth sqrt(2*te*qe/(mu*mp))

tib2 4 4 sumz qe rm* 2.0 rm* mi 18 18 sumz m/ sqrt ! vth

ne

# ElectronImpactIonizationHeEir(te)=1e-6*exp(((((((((-3.649161E-06)*log(te)+2.067236E-04)*log(te)-5.009056E-03)*log(te)+6.795391E-02)*log(te)-5.685119E-01)*log(te)+3.058039)*log(te)-1.075323E+01)*log(te)+2.391597E+01)*log(te)-4.409865E+01)

te ln  -3.649161E-06 dup rm*
        2.067236E-04 rm+ over m*
       -5.009056E-03 rm+ over m*
        6.795391E-02 rm+ over m*
       -5.685119E-01 rm+ over m*
        3.058039E+00 rm+ over m*
       -1.075323E+01 rm+ over m*
        2.391597E+01 rm+ over m*
       -4.409865E+01 rm+
        exp 1e-6 rm*

swap drop m* m/

'He mean free path (based on neutral temp)' extl 1.0e-3 fmin 1.0 fmax cont
