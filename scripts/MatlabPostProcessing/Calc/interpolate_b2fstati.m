function state1 = interpolate_b2fstati(gmtry0,state0,gmtry1)
% state1 = interpolate_b2fstati(gmtry0,state0,gmtry1)
%
% Routine to interpolate a plasma state0 defined on gmtry0 onto a new
% gmtry1.
%
% All structures assume unstructured data format. No consistency checks on
% compatibility of the two geometries is done.
%

% Init: simple copy to have the relevant fields
state1 = state0;

ns = size(state0.na,2);

state1.zamin = state0.zamin;
state1.zamax = state0.zamax;
state1.zn    = state0.zn;
state1.am    = state0.am;

state1.na      = zeros(gmtry1.nCv,ns);
for is = 1:ns
    state1.na(:,is) = griddata(gmtry0.cvX(:),gmtry0.cvY(:),state0.na(:,is),gmtry1.cvX,gmtry1.cvY,'nearest');
end
state1.ne      = griddata(gmtry0.cvX(:),gmtry0.cvY(:),state0.ne(:),gmtry1.cvX,gmtry1.cvY,'nearest');
state1.ua      = zeros(gmtry1.nCv,ns);
for is = 1:ns
    state1.ua(:,is) = griddata(gmtry0.cvX(:),gmtry0.cvY(:),state0.ua(:,is),gmtry1.cvX,gmtry1.cvY,'nearest');
end
state1.uadia   = zeros(gmtry1.nFc,2,ns);
state1.te      = griddata(gmtry0.cvX(:),gmtry0.cvY(:),state0.te(:),gmtry1.cvX,gmtry1.cvY,'nearest');
state1.ti      = griddata(gmtry0.cvX(:),gmtry0.cvY(:),state0.ti(:),gmtry1.cvX,gmtry1.cvY,'nearest');
state1.tn      = griddata(gmtry0.cvX(:),gmtry0.cvY(:),state0.tn(:),gmtry1.cvX,gmtry1.cvY,'nearest');
state1.kt      = griddata(gmtry0.cvX(:),gmtry0.cvY(:),state0.kt(:),gmtry1.cvX,gmtry1.cvY,'nearest');
state1.zt      = griddata(gmtry0.cvX(:),gmtry0.cvY(:),state0.zt(:),gmtry1.cvX,gmtry1.cvY,'nearest');
state1.po      = griddata(gmtry0.cvX(:),gmtry0.cvY(:),state0.po(:),gmtry1.cvX,gmtry1.cvY,'nearest');

state1.fna     = zeros(gmtry1.nFc,2,ns);
state1.fhe     = zeros(gmtry1.nFc,2);
state1.fhi     = zeros(gmtry1.nFc,2);
state1.fhn     = zeros(gmtry1.nFc,2);
state1.fhm     = zeros(gmtry1.nFc,2,ns);
state1.fkt     = zeros(gmtry1.nFc,2);
state1.fzt     = zeros(gmtry1.nFc,2);
state1.fch     = zeros(gmtry1.nFc,2);
state1.fch_32  = zeros(gmtry1.nFc,2);
state1.fch_52  = zeros(gmtry1.nFc,2);
state1.kinrgy  = zeros(gmtry1.nCv,ns);
state1.time    = 0;
state1.fch_p   = zeros(gmtry1.nFc,2);

state1.fna_mdf   = zeros(gmtry1.nFc,2,ns);
state1.fhe_mdf   = zeros(gmtry1.nFc,2);
state1.fhi_mdf   = zeros(gmtry1.nFc,2);
state1.fna_fcor  = zeros(gmtry1.nFc,2,ns);
state1.fna_nodrift = zeros(gmtry1.nFc,2,ns);
state1.fna_he    = zeros(gmtry1.nFc,2,ns);
state1.fnaPSch   = zeros(gmtry1.nFc,2,ns);
state1.fhePSch   = zeros(gmtry1.nFc,2);
state1.fhiPSch   = zeros(gmtry1.nFc,2);
state1.fna_eir   = zeros(gmtry1.nFc,2,ns);
state1.fne_eir   = zeros(gmtry1.nFc,2);
state1.fhe_eir   = zeros(gmtry1.nFc,2);
state1.fhi_eir   = zeros(gmtry1.nFc,2);
state1.fna_32    = zeros(gmtry1.nFc,2,ns);
state1.fna_52    = zeros(gmtry1.nFc,2,ns);
state1.fni_32    = zeros(gmtry1.nFc,2);
state1.fni_52    = zeros(gmtry1.nFc,2);
state1.fne_32    = zeros(gmtry1.nFc,2);
state1.fne_52    = zeros(gmtry1.nFc,2);
state1.fchdia    = zeros(gmtry1.nFc,2);
state1.fchin     = zeros(gmtry1.nFc,2);
state1.fchvispar = zeros(gmtry1.nFc,2);
state1.fchvisper = zeros(gmtry1.nFc,2);
state1.fchvisq   = zeros(gmtry1.nFc,2);
state1.fchviskt  = zeros(gmtry1.nFc,2);
state1.fchinert  = zeros(gmtry1.nFc,2);
state1.vaecrb    = zeros(gmtry1.nFc,2,ns);
state1.vadia     = zeros(gmtry1.nFc,2,ns);
state1.wadia     = zeros(gmtry1.nFc,2,ns);
state1.veecrb    = zeros(gmtry1.nFc,2);
state1.vedia     = zeros(gmtry1.nFc,2);
state1.floe_noc  = zeros(gmtry1.nFc,2);
state1.floi_noc  = zeros(gmtry1.nFc,2);