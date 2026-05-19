function state = create_b2fstati_from_b2fplasmf(plasmastate,zamin,zamax,zn,am)
% state = create_b2fstati_from_b2fplasmf(plasmastate)
%
% Generated formatted b2fstate file created from a plasma state.
%
%

% Author: Anthony Piras
% E-mail: anthony.piras@kuleuven.be
% November 2025

fprintf('\n')
disp(['Generating unstructured initial state from b2fplasmf: starting.'])

% Extra fields to be passed an input since not present in b2fplasmf
state.zamin = zamin;
state.zamax = zamax;
state.zn    = zn;
state.am    = am;

p = plasmastate;

state.na          = p.na;
state.ne          = p.ne;
state.ua          = p.ua;
state.uadia       = p.uadia;
state.te          = p.te;
state.ti          = p.ti;
state.tn          = p.ti;
state.po          = p.tn;
state.kt          = p.kt;
state.zt          = p.kt; % to be improved if zt written in b2fplasmf
state.fna         = p.fna;
state.fhe         = p.fne;
state.fhi         = p.fhi;
state.fhn         = p.fhn;
state.fch         = p.fch;
state.fch_32      = p.fch_32;
state.fch_52      = p.fch_52;
state.kinrgy      = p.kinrgy;
state.fhm         = p.fhm;
state.fkt         = p.fkt;
state.fzt         = p.fkt; % same as for zt
state.time        = 0.0;
state.fch_p       = p.fch_p;
state.fna_mdf     = p.fna_mdf;
state.fhe_mdf     = p.fhe_mdf;
state.fhi_mdf     = p.fhi_mdf;
state.fna_fcor    = p.fna_fcor;
state.fna_nodrift = p.fna_nodrift;
state.fna_he      = p.fna_he;
state.fnaPSch     = p.fnaPSch;
state.fhePSch     = p.fhePSch;
state.fhiPSch     = p.fhiPSch;
state.fna_eir     = p.fna_eir;
state.fne_eir     = p.fne_eir;
state.fhe_eir     = p.fhe_eir;
state.fhi_eir     = p.fhi_eir;
state.fna_32      = p.fna_32;
state.fna_52      = p.fna_52;
state.fni_32      = p.fni_32;
state.fni_52      = p.fni_52;
state.fne_32      = p.fne_32;
state.fne_52      = p.fne_52;
state.fchdia      = p.fchdia;
state.fchin       = p.fchin;
state.fchvispar   = p.fchvispar;
state.fchvisper   = p.fchvisper;
state.fchvisq     = p.fchvisq;
state.fchviskt    = p.fchvisq; % same as above
state.fchinert    = p.fchinert;
state.vaecrb      = p.vaecrb;
state.vadia       = p.vadia;
state.wadia       = p.wadia;
state.veecrb      = p.veecrb;
state.vedia       = p.vedia;
state.floe_noc    = p.floe_noc;
state.floi_noc    = p.floi_noc;

disp(['Generating unstructured initial state from b2fplasmf: done without errors.'])

end
