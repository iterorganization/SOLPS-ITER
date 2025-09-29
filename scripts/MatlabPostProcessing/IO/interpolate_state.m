function state = interpolate_state(gmtry0,gmtry1,state0,version,ns)
% state = interpolate_state(gmtry0,gmtry1,state0,version,ns)
%
% Interpolates a b2fstate file for ns species from a grid gmtry0 to a
% different grid gmtry1.
%

nCv = gmtry1.nCv;
nFc = gmtry1.nFc;

state.version = version;

state.zamin = state0.zamin;
state.zamax = state0.zamax;
state.zn = state0.zn;
state.am = state0.am;

state.na = zeros(nCv,ns);
state.ua = zeros(nCv,ns);

for is = 1:ns
    tmp = state0.na(:,is);
    state.na(:,is) = griddata(gmtry0.cvX,gmtry0.cvY,tmp,gmtry1.cvX,gmtry1.cvY,'nearest');
    tmp = state0.ua(:,is);
    state.ua(:,is) = griddata(gmtry0.cvX,gmtry0.cvY,tmp,gmtry1.cvX,gmtry1.cvY,'nearest');
end

state.uadia = zeros(nFc,2,ns);

state.ne = zeros(nCv,1);
tmp = state0.ne;
state.ne = griddata(gmtry0.cvX,gmtry0.cvY,tmp,gmtry1.cvX,gmtry1.cvY,'nearest');

state.te = zeros(nCv,1);
tmp = state0.te;
state.te = griddata(gmtry0.cvX,gmtry0.cvY,tmp,gmtry1.cvX,gmtry1.cvY,'nearest');

state.ti = zeros(nCv,1);
tmp = state0.ti;
state.ti = griddata(gmtry0.cvX,gmtry0.cvY,tmp,gmtry1.cvX,gmtry1.cvY,'nearest');

state.po = zeros(nCv,1);
tmp = state0.po;
state.po = griddata(gmtry0.cvX,gmtry0.cvY,tmp,gmtry1.cvX,gmtry1.cvY,'nearest');

state.tn = state.ti;
state.kt = zeros(nCv,1);
state.zt = zeros(nCv,1);

state.fna = zeros(nFc,2,ns);
state.fhe = zeros(nFc,2);
state.fhi = zeros(nFc,2);
state.fhn = zeros(nFc,2);
state.fch = zeros(nFc,2);
state.fch_32 = zeros(nFc,2);
state.fch_52 = zeros(nFc,2);
state.kinrgy = zeros(nCv,ns);
state.fhm = zeros(nFc,2,ns);
state.fkt = zeros(nFc,2);
state.fzt = zeros(nFc,2);
state.time = 0;
state.fch_p = zeros(nFc,2);

state.fna_mdf = zeros(nFc,2,ns);
state.fhe_mdf = zeros(nFc,2);
state.fhi_mdf = zeros(nFc,2);
state.fna_fcor = zeros(nFc,2,ns);
state.fna_nodrift = zeros(nFc,2,ns);
state.fna_he = zeros(nFc,2,ns);
state.fnaPSch = zeros(nFc,2,ns);
state.fhePSch = zeros(nFc,2);
state.fhiPSch = zeros(nFc,2);
state.fna_eir = zeros(nFc,2,ns);
state.fne_eir = zeros(nFc,2);
state.fhe_eir = zeros(nFc,2);
state.fhi_eir = zeros(nFc,2);
state.fna_32 = zeros(nFc,2,ns);
state.fna_52 = zeros(nFc,2,ns);
state.fni_32 = zeros(nFc,2);
state.fni_52 = zeros(nFc,2);
state.fne_32 = zeros(nFc,2);
state.fne_52 = zeros(nFc,2);
state.fchdia = zeros(nFc,2);
state.fchin = zeros(nFc,2);
state.fchvispar = zeros(nFc,2);
state.fchvisper = zeros(nFc,2);
state.fchvisq = zeros(nFc,2);
state.fchviskt = zeros(nFc,2);
state.fchinert = zeros(nFc,2);

state.vaecrb = zeros(nFc,2,ns);
state.vadia = zeros(nFc,2,ns);
state.wadia = zeros(nFc,2,ns);
state.veecrb = zeros(nFc,2);
state.vedia = zeros(nFc,2);

state.floe_noc = zeros(nFc,2);
state.floi_noc = zeros(nFc,2);

end

