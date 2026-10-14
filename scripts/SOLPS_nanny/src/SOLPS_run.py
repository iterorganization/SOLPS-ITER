import subprocess
import os
import time
import numpy as np

from scipy.constants import e

"""
This class establishes the functionality to interact with a SOLPS-case that 
is located in a specific run-folder. 
The attributes that are required are:
   run_dir: path to the run directory
   launch_command: path to the SLURM script
   path_to_b2plot_script: path to a script that can run b2plot
       This is primarily for plate heat flux analysis.
       If b2plot processing is not needed, then this can be set as 
       a dummy path ''.
   psubdiv_ixlist: a python list of ix-coordinates along the private flux 
                   boundary, within which the subdiv averaging is done.
                   If the user does not use subdiv averaging, a dummy []
                   is sufficient. 
   clean: whether to remove the *tar-files and slurm-logs. Default is True.
"""

class SOLPS_run():
    def __init__(self,
                 run_dir,
                 # Move these to the config file
                 launch_command='path_to_slurm_script',
                 path_to_b2plot_script='path_to_a_script_to_run_b2plot',
                 psubdiv_ixlist = [9,10, 11, 12, 13, 14, 15,
                                   77, 78, 79, 80, 81, 82, 83],
                 clean=True):
        self.run_dir = run_dir
        self.launch_command = launch_command
        self.path_to_b2plot_script = path_to_b2plot_script
        self.clean = clean
        self.psubdiv_ixlist  = psubdiv_ixlist
        # The system keeps track of the state of the run with a binary flag
        # self.runnign = True/False, which is updated through the function
        # self.check_if_running()
        self.check_if_running()

### Functions that are needed to run the simulation or the postprocessors----

    def check_if_running(self, verbose=True):
        # The function goes to the run directory to check the status
        # N.B. if one ever wants to parallize these, there is probably
        # a race condition risk with this implementation.
        # A more professional coding strategy would be to have static
        # cwd and only operate with full paths. 
        starting_dir = os.getcwd()
        os.chdir(self.run_dir)
        
        # Check if 'run.log' exists
        if os.path.exists('run.log'):
            # Check when 'run.log' was updated the last time
            timem = os.path.getmtime('run.log')
            ts = time.time()
            if np.abs(timem - ts) < 100:
                if verbose:
                    print(self.run_dir+' run.log exists and is being updated')
                self.running = True
            else:
                print(self.run_dir+' run.log exists, but is not updated')
        else:
            # Check if 'b2mn.prt' exists
            if os.path.exists('b2mn.prt'):
                if verbose:
                    print(self.run_dir+' b2mn.prt exists')
                self.running = False
            else:
                try:
                    # Check the time from the launch by looking at the
                    # time of b2fstati. Wait 20 minutes, before
                    # raising a warning text.
                    timem = os.path.getmtime('b2fstati')
                    ts = time.time()
                    if np.abs(timem - ts) < 1200:
                        print(self.run_dir+' seems to be waiting for a launch')
                    else:
                        print(self.run_dir+' No run.log or b2mn.prt and more'+
                              ' than 20 minutes from submission.'+
                              'Check manually.')
                except:
                    # If this ever happens, there is something seriously
                    # wrong with the run.
                    print('No b2fstati found')
        # Return to the run directory
        os.chdir(starting_dir)
        
    def launch(self, force_launch=False):
        # This the launch command.
        # Since SOLPS-ITER accumulates some of the archive files
        # by default, the default setup with clean=True removes
        # many of these archives and past slurm-logs.
        # If the user does not want this, then clean should be
        # setup to False.
        # force_launch can be used to ignore the running flag.
        # Use this only if you know what you are doing.
        if force_launch:
            self.running = False

        # Don't launch the case if it is already running 
        if self.running:
            print(self.run_dir+' is already running')
        else:
            # Move of the run directory
            starting_dir = os.getcwd()
            os.chdir(self.run_dir)
            # Take a back up of the original b2fstati
            subprocess.run(['cp', 'b2fstati', 'b2fstati_back'])
            if os.path.exists('b2fstate'):
                # Copy b2fstate to b2fstati
                # To avoid destroying the case accidentally, check the
                # file size of b2fstate.
                if os.path.getsize('b2fstate') < 10000:
                    print('b2fstate corrupted')
                    print('Check manually!!!!!')
                    print('Nothing will happen until you do!')
                    return
                else:
                    subprocess.run(['cp', 'b2fstate', 'b2fstati'])
                    if self.clean:
                        dirlist = os.listdir()
                        filvec = ['tar.', 'slurm-']
                        for i in dirlist:
                            for j in filvec:
                                if j in i:
                                    subprocess.run(['rm', i])
            else:
                # Something has prevented b2fstate generation.
                # Generally, should be checked manually, but may
                # recover with resubmission.
                print('Warning! '+'No b2fstate')
            # Remove b2mn.prt
            subprocess.run(['rm', 'b2mn.prt'])
            # Run SOLPS-ITER
            subprocess.run(['sbatch', self.launch_command])
            # Return to the original directory
            os.chdir(starting_dir)
            # Set the status as running=True
            self.running = True

    def stop(self):
        # This is a simple command to stop the run
        subprocess.run(['touch', self.run_dir+'b2mn.exe.dir/.quit'])
        # Set the status as running=False
        self.running = False

    def run_plot_trc(self):
        # This runs the plot_trc
        starting_dir = os.getcwd()
        os.chdir(self.run_dir)
        subprocess.run(['plot_trc'])
        os.chdir(starting_dir)

    def run_b2uf(self):
        # This runs b2uf
        starting_dir = os.getcwd()
        os.chdir(self.run_dir)
        subprocess.run(['b2run','b2uf'])
        os.chdir(starting_dir)

    def run_b2plot(self):
        # This function runs b2plot with
        # a b2plot_script that user provides.
        starting_dir = os.getcwd()
        os.chdir(self.run_dir)
        subprocess.run([self.path_to_b2plot_script])
        os.chdir(starting_dir)
        
### Functions that collect information from the files in the run directory --- 
### Some of these may be specific to running ITER database cases and can be
### update to be more generic in future iterations of the SOLPS_nanny.

    def read_target_conc(self):
        # Read the target concentration from b2.feedback_control.parameters
        # This target concentration is set as self.target_conc
        # Move to the run directory
        starting_dir = os.getcwd()
        os.chdir(self.run_dir)
        # Open 'b2.feedback_control.parameters'
        fid1 = open('b2.feedback_control.parameters','r')
        for line in fid1.readlines():
            if 'na_feedback_target' in line:
                ls = line.split(',')
                self.target_conc = float(ls[2])
        os.chdir(starting_dir)
        fid1.close()

    def read_tracing(self):
        # This function reads the tracing data to be used
        # in evaluting convergence.
        tracingmat = np.loadtxt(self.run_dir+'tracing/sepdata.trc', skiprows=3)
        tracmat2 = np.loadtxt(self.run_dir+'tracing/user_SPb.trc', skiprows=3)
        intmat = np.loadtxt(self.run_dir+'tracing/integral.trc', skiprows=3)
        dict = {'time':tracingmat[:,0], 'nesep':tracingmat[:,1],
                'tesep':tracingmat[:,2], 'tisep':tracingmat[:,3],
                'hesep':tracingmat[:,11], 'impsep':tracingmat[:,12],
                'p_neut': tracmat2[:,3],
                'te_i':tracmat2[:,7], 'te_o':tracmat2[:,8],
                'q_i':tracmat2[:,11], 'q_o':tracmat2[:,12],
                'Dcore':intmat[:,88], 'Hecore':intmat[:,92],
                'Necore':intmat[:,96]
                }
        self.tracing = dict

    def read_sep_data(self):
        # From tracing/sepdata.trc, read separatrix density (nesep)
        # and separatrix neon concetration (ne_conc).
        # These are set as self.nesep and self.ne_conc
        # It is quite easy to expand this list as needed
        tracingmat = np.loadtxt(self.run_dir+'tracing/sepdata.trc', skiprows=3)
        self.nesep = tracingmat[-1,1]
        self.ne_conc = tracingmat[-1,12]/self.nesep

    def read_p_subdiv(self, tracing=False):
        # This read the sub-divertor neutral pressure that is the key
        # control/reference parameter in ITER simulations.
        # Using tracing, one can choose to apply the internal
        # calculation within SOLPS-ITER that is produced in
        # tracing.
        tracingmat = np.loadtxt(self.run_dir+
                                'tracing/user_SPb.trc',
                                skiprows=3)
        if tracing:
            # If using the internal SOLPS-ITER calculations
            self.p_subdiv = tracingmat[-1,1]
        else:
            # Computing the sub-divertor neutral pressure
            
            # Read b2fgmtry
            self.read_b2fgmtry()
            
            # Read fort.44
            self.read_f44()

            # Get the matrix dimensions
            nx = self.f44['nx']
            ny = self.f44['ny']
            natom = self.f44['natom']
            nmol = self.f44['nmol']
            
            # Compute pressure within the (nx, ny) grid 
            var1 = np.zeros((nx, ny))
            dab2 = self.f44['dab2']
            tab2 = self.f44['tab2']
            dmb2 = self.f44['dmb2']
            tmb2 = self.f44['tmb2']
            dab2 = dab2.reshape((nx, ny, natom), order='F')
            tab2 = tab2.reshape((nx, ny, natom), order='F')
            dmb2 = dmb2.reshape((nx, ny, nmol), order='F')
            tmb2 = tmb2.reshape((nx, ny, nmol), order='F')

            # Sum density*temperature for all atoms and molecules
            for i in range(natom):
                var1 += dab2[:,:,i]*tab2[:,:,i]
            for i in range(nmol):
                var1 += dmb2[:,:,i]*tmb2[:,:,i]

            # Index-list
            ixlist = self.psubdiv_ixlist
            
            # Compute the volume averaged pressure
            totpres = 0
            totvol  = 0
            for i in ixlist:
                j = 1
                totvol += self.gmtry['vol'][i,j]
                totpres += var1[i-1, j-1]*self.gmtry['vol'][i,j]
            self.p_subdiv = totpres/totvol

    def read_qrad(self):
        # Read the user_SPb.trc and collect the q_radtot
        # q_radsol.
        tracingmat = np.loadtxt(self.run_dir+
                                'tracing/user_SPb.trc',
                                skiprows=3)
        self.q_radtot = tracingmat[-1,5]*1e-6
        self.q_radsol = tracingmat[-1,6]*1e-6
        
    def plate_profiles(self):
        # Establish dictionaries for the inner and outer
        # plate profiles:
        #     self.ot_plate_profiles
        #     self.it_plate_profiles
        # keys:
        #     's'  : Distance from separatrix
        #     'te' : Electron temperature
        #     'ti' : Ion temperature
        #     'fna': Main plasma particle flux
        #     'ne' : Electron density

        # Read b2fgmtry and b2fstate
        self.read_b2fgmtry()
        self.read_b2fstate()
        gmtry = self.gmtry
        state = self.state
        nx = gmtry['nx']
        ny = gmtry['ny']
        ns = state['ns']

        # Target perpendicular area calculation
        gs = gmtry['gs'].reshape((nx+2, ny+2, 3), order='F')
        gsx = gs[:,:,0]
        gs_ot = gsx[nx,:]
        gs_it = gsx[1,:]
        
        # Target distance calculation
        crx = gmtry['crx'].reshape((nx+2, ny+2, 4), order='F')
        cry = gmtry['cry'].reshape((nx+2, ny+2, 4), order='F')
        cx = 0.25*(crx[:,:,0]+crx[:,:,1]+crx[:,:,2]+crx[:,:,3])
        cy = 0.25*(cry[:,:,0]+cry[:,:,1]+cry[:,:,2]+cry[:,:,3])
        dso = np.zeros((ny+2,1))
        dsi = np.zeros((ny+2,1))
        for i in range(1, len(dso)):
            xdisto = cx[nx,i]-cx[nx,i-1]
            xdisti = cx[1,i]-cx[1,i-1]
            ydisto = cy[nx,i]-cy[nx,i-1]
            ydisti = cy[1,i]-cy[1,i-1]
            disto = np.sqrt(xdisto*xdisto + ydisto*ydisto)
            disti = np.sqrt(xdisti*xdisti + ydisti*ydisti)
            dso[i] = dso[i-1] + disto
            dsi[i] = dsi[i-1] + disti

        # Target temperature
        te = state['te']
        ti = state['ti']
        te = te.reshape((nx+2, ny+2), order='F')
        ti = ti.reshape((nx+2, ny+2), order='F')

        # Target particle flux
        fna = state['fna']
        fna = fna.reshape((nx+2, ny+2, 2, ns), order='F')

        # Target electron density
        den = state['ne']
        den = den.reshape((nx+2, ny+2), order='F')
        
        # Separatrix coordinate
        sepo = 0.5*(dso[13] + dso[12])
        sepi = 0.5*(dsi[13] + dsi[12])

        # Outer plate profiles
        s_ot = 100*(dso - sepo)
        ot_te = te[nx,:]/e
        ot_ti = ti[nx,:]/e
        ot_fna = np.divide(fna[nx,:,0,1], gs_ot)
        ot_ne = den[nx,:]

        # Inner plate profiles
        s_it = 100*(dsi - sepi)
        it_te = te[1,:]/e
        it_ti = ti[1,:]/e
        it_fna = np.divide(-fna[1,:,0,1], gs_it)
        it_ne = den[1,:]

        # Build the dictionaries
        ot_profiles = {'s':s_ot, 'te':ot_te, 'ti':ot_ti, 'fna':ot_fna, 'ne':ot_ne}
        it_profiles = {'s':s_it, 'te':it_te, 'ti':it_ti, 'fna':it_fna, 'ne':it_ne}

        self.ot_plate_profiles = ot_profiles
        self.it_plate_profiels = it_profiles
        
    def plate_fluxes(self):
        # Read the total and peak main particle fluxes
        # at the plates
        self.read_b2fgmtry()
        self.read_b2fstate()
        gmtry = self.gmtry
        state = self.state
        fna = state['fna']
        nx = state['nx']
        ny = state['ny']
        ns = state['ns']
        fna = fna.reshape((nx+2, ny+2, 2, ns), order='F')
        
        # Target perpendicular area calculation
        gs = gmtry['gs'].reshape((nx+2, ny+2, 3), order='F')
        gsx = gs[:,:,0]
        gs_ot = gsx[nx,:]
        gs_it = gsx[1,:]

        otsum = np.sum(fna[nx,:,0,1])
        itsum = -np.sum(fna[1,:,0,1])
        otpeak = np.max(np.divide(fna[nx,:,0,1], gs_ot))
        itpeak = np.max(-np.divide(fna[1,:,0,1], gs_it))

        self.ot_part_sum = otsum
        self.it_part_sum = itsum
        self.ot_part_peak = otpeak
        self.it_part_peak = itpeak

    def read_ld_tg(self):
        # This function reads the target loading files
        # generated by b2plot.
        starting_dir = os.getcwd()
        os.chdir(self.run_dir)
        try:
            otld = np.loadtxt('b2pl.exe.dir/ld_tg_o.dat',
                              skiprows=23)
            itld = np.loadtxt('b2pl.exe.dir/ld_tg_i.dat',
                              skiprows=23)
            self.it_load = itld
            self.ot_load = otld
        except:
            print('Could not load target leading.',
                  'Run b2plot first.')
        os.chdir(starting_dir)

    def plate_heat(self, trgshp=1.5, run_b2plot=False):
        # Read target heat loads.
        # This function assumes that b2plot has been
        # executed for the case.
        # The function can also execute b2plot with
        # run_b2plot=True.
        # trgshp stands for the assumed monoblock
        # shaping multiplier.
        if run_b2plot:
            self.run_b2plot()
        self.read_ld_tg()
        otplasma = self.ot_load[:,7]*trgshp
        otrad = self.ot_load[:,6]
        otneut = self.ot_load[:,8]
        otrec = self.ot_load[:,10]
        otplasmarec = self.ot_load[:,12]
        otneutrec = otrec - otplasmarec
        self.ot_x = self.ot_load[:,0]
        self.ot_neut_load = otneut - otneutrec
        self.ot_rad_load = otrad
        self.ot_rec_load = otplasmarec*trgshp + otneutrec
        self.ot_tot_heat = otplasma + otrad + otneut
        self.ot_peak = np.max(self.ot_tot_heat)
        self.ot_xomp = self.ot_load[:,13]
        self.ot_par_xp = self.ot_load[:,16]
        self.ot_par_u = self.ot_load[:,17]
        self.ot_per_u = self.ot_load[:,18]
        itplasma = self.it_load[:,7]*trgshp
        itrad = self.it_load[:,6]
        itneut = self.it_load[:,8]
        itrec = self.it_load[:,10]
        itplasmarec = self.it_load[:,12]
        itneutrec = itrec - itplasmarec
        self.it_x = self.it_load[:,0]
        self.it_neut_load = itneut - itneutrec
        self.it_rad_load = itrad 
        self.it_rec_load = itplasmarec*trgshp + itneutrec
        self.it_tot_heat = itplasma + itrad + itneut
        self.it_peak = np.max(self.it_tot_heat)
        self.it_xomp = self.it_load[:,13]
        self.it_par_xp = self.it_load[:,16]
        self.it_par_u = self.it_load[:,17]
        self.it_per_u = self.it_load[:,18]
        
### Functions in this category parse the state and geometry files---
        
    def read_eir_vec(self, fid):
        # Read a field in an EIRENE
        # file and return as a dictionary
        line = fid.readline()
        if line == '':
            d = 'empty'
            return d
        ls = line.split()
        if len(ls) < 5:
            d = 'skip'
            return d
        if len(ls) > 7:
            veclen = int(ls[7])
        else:
            try:
                veclen = int(ls[6])
            except:
                d = 'skip'
                return d
        vecname = ls[3]
        vecout = []
        count = 0
        while count < veclen:
            line = fid.readline()
            ls = line.split()
            for j in ls:
                try:
                    vecout.append(float(j))
                    count += 1
                except:
                    continue
        vecout = np.array(vecout)
        d = {vecname:vecout}
        return d       

    def read_vec(self, fid):
        # Read a field in a B2.5 file
        # and return field name and
        # data.
        line = fid.readline()
        if line == '':
            vecname = 'empty'
            return vecname, -1
        ls = line.split()
        veclen = int(ls[2])
        vecname = ls[3]
        vecout = []
        count = 0
        while count < veclen:
            line = fid.readline()
            ls = line.split()
            for j in ls:
                vecout.append(float(j))
                count += 1
        vecout = np.array(vecout)
        return vecname, vecout

    def read_f33(self):
        # Read fort.33 and return as a
        # dictionary.
        starting_dir = os.getcwd()
        os.chdir(self.run_dir)
        fid = open('fort.33','r')
        f33= {}
        line = fid.readline()
        nump = int(line)
        f33.update({'nump':nump})
        counter = 0
        xcoord = []
        while counter < nump:            
            line = fid.readline()
            ls = line.split()
            for element in ls:
                xcoord.append(float(element))
                counter += 1
        xcoord = np.array(xcoord)
        ycoord = []
        counter = 0
        while counter < nump:            
            line = fid.readline()
            ls = line.split()
            for element in ls:
                ycoord.append(float(element))
                counter += 1
        ycoord = np.array(ycoord)
        f33.update({'xc':xcoord, 'yc':ycoord})
        self.f33 = f33
        os.chdir(starting_dir)

    def read_f34(self):
        # Read fort.34 and return as a
        # dictionary.
        starting_dir = os.getcwd()
        os.chdir(self.run_dir)
        fid = open('fort.34','r')
        f34= {}
        line = fid.readline()
        nump = int(line)
        f34.update({'nump':nump})
        trilist = []
        for i in range(nump):
            line = fid.readline()
            ls = line.split()
            trilist.append([int(ls[0]), int(ls[1]),
                            int(ls[2]), int(ls[3])])
        trilist = np.array(trilist, dtype=np.int16)
        f34.update({'trilist':trilist})
        self.f34 = f34
        os.chdir(starting_dir)

    def read_f35(self):
        # Read fort.35 and return as a dictionary.
        starting_dir = os.getcwd()
        os.chdir(self.run_dir)
        fid = open('fort.35','r')
        f35= {}
        line = fid.readline()
        nump = int(line)
        f35.update({'nump':nump})
        trilist = []
        for i in range(nump):
            line = fid.readline()
            ls = line.split()
            trilist.append([int(ls[0]), int(ls[1]), int(ls[2]),
                            int(ls[3]), int(ls[4]), int(ls[5]),
                            int(ls[6]), int(ls[7]), int(ls[8]),
                            int(ls[9]), int(ls[10]), int(ls[11])])
        trilist = np.array(trilist, dtype=np.int16)
        f35.update({'trilist':trilist})
        self.f35 = f35
        os.chdir(starting_dir)

    def read_input_dat(self):
        # Read input.dat
        starting_dir = os.getcwd()
        os.chdir(self.run_dir)
        fid = open('input.dat','r')
        text = fid.readline()
        while '*** 3b.' not in text:
            text = fid.readline()
        line = fid.readline()
        nump = int(line)
        add_surf_dict_list = []
        line = fid.readline()
        for i in range(nump):
            line = fid.readline()
            line = fid.readline()
            line = fid.readline()
            rcoord1 = float(line[:12])
            zcoord1 = float(line[12:24])
            rcoord2 = float(line[36:48])
            zcoord2 = float(line[48:60])
            line = fid.readline()
            if '*' not in line:
                text = line
                line = fid.readline()
            else:
                text = ''
            coords = np.array([[rcoord1, zcoord1],
                               [rcoord2, zcoord2]
                              ])
            add_surf_dict = {'coords':coords, 'label':text}
            add_surf_dict_list.append(add_surf_dict)
        self.add_surf = add_surf_dict_list
        os.chdir(starting_dir)
    
    def read_b2fgmtry(self):
        # Read b2fgmtry
        starting_dir = os.getcwd()
        os.chdir(self.run_dir)
        fid = open('b2fgmtry','r')
        gmtry = {}
        line = fid.readline()
        line = fid.readline()
        line = fid.readline()
        ls = line.split()
        nx = int(ls[0])
        ny = int(ls[1])
        gmtry.update({'nx':nx, 'ny':ny})
        line = fid.readline()
        line = fid.readline()
        line = fid.readline()
        line = fid.readline()
        dim1 = (nx+2)*(ny+2)
        dim2 = (nx+2)*(ny+2)*4
        dim3 = (nx+2)*(ny+2)*2
        dim4 = (nx+2)*(ny+2)*3
        neof = True
        while neof:
            vname, vout = self.read_vec(fid)
            if vname == 'empty':
                neof = False
            else:
                numpoints = len(vout)
                if numpoints == dim1:
                    vout = vout.reshape((nx+2, ny+2), order='F') 
                if numpoints == dim2:
                    vout = vout.reshape((nx+2, ny+2, 4), order='F') 
                if numpoints == dim3:
                    vout = vout.reshape((nx+2, ny+2, 2), order='F')
                if numpoints == dim4:
                    vout = vout.reshape((nx+2, ny+2, 3), order='F')
                gmtry.update({vname:vout})
        self.gmtry = gmtry
        os.chdir(starting_dir)
    
    def read_b2fstate(self):
        # Read b2fstate
        starting_dir = os.getcwd()
        os.chdir(self.run_dir)
        try:
            fid = open('b2fstate', 'r')
        except:
            print('No b2fstate. Reading b2fstati instead.')
            fid = open('b2fstati','r')
        state = {}
        line = fid.readline()
        line = fid.readline()
        line = fid.readline()
        ls = line.split()
        nx = int(ls[0])
        ny = int(ls[1])
        ns = int(ls[2])
        dim1 = (nx+2)*(ny+2)
        dim2 = (nx+2)*(ny+2)*ns
        dim3 = (nx+2)*(ny+2)*2*ns
        dim4 = (nx+2)*(ny+2)*2
        
        state.update({'nx':nx, 'ny':ny, 'ns':ns})
        line = fid.readline()
        line = fid.readline()
        neof = True
        while neof:
            vname, vout = self.read_vec(fid)
            if vname == 'empty':
                neof = False
            else:
                numpoints = len(vout)
                if numpoints == dim1:
                    vout = vout.reshape((nx+2, ny+2), order='F') 
                if numpoints == dim2:
                    vout = vout.reshape((nx+2, ny+2, ns), order='F') 
                if numpoints == dim3:
                    vout = vout.reshape((nx+2, ny+2, 2, ns), order='F')
                if numpoints == dim4:
                    vout = vout.reshape((nx+2, ny+2, 2), order='F')
                state.update({vname:vout})
        
        self.state = state
        os.chdir(starting_dir)

    def read_b2fplasmf(self):
        # Read b2fplasmf
        starting_dir = os.getcwd()
        os.chdir(self.run_dir)
        fid = open('b2fplasmf','r')
        state = {}
        line = fid.readline()
        self.read_b2fgmtry()
        self.read_b2fstate()
        nx = self.state['nx']
        ny = self.state['ny']
        ns = self.state['ns']
        dim1 = (nx+2)*(ny+2)
        dim2 = (nx+2)*(ny+2)*4
        dim3 = (nx+2)*(ny+2)*2
        dim4 = (nx+2)*(ny+2)*3
        dim5 = (nx+2)*(ny+2)*ns
        dim6 = (nx+2)*(ny+2)*2*ns
        
        neof = True
        while neof:
            vname, vout = self.read_vec(fid)
            if vname == 'empty':
                neof = False
            else:
                numpoints = len(vout)
                if numpoints == dim1:
                    vout = vout.reshape((nx+2, ny+2), order='F') 
                if numpoints == dim2:
                    vout = vout.reshape((nx+2, ny+2, 4), order='F') 
                if numpoints == dim3:
                    vout = vout.reshape((nx+2, ny+2, 2), order='F')
                if numpoints == dim4:
                    vout = vout.reshape((nx+2, ny+2, 3), order='F')
                if numpoints == dim5:
                    vout = vout.reshape((nx+2, ny+2, ns), order='F')
                if numpoints == dim6:
                    vout = vout.reshape((nx+2, ny+2, 2, ns), order='F')
                state.update({vname:vout})
        self.plasma = state
        os.chdir(starting_dir)

    def read_f44(self):
        # Read fort.44
        starting_dir = os.getcwd()
        os.chdir(self.run_dir)
        fid = open('fort.44','r')
        state = {}
        line = fid.readline()
        ls = line.split()
        nx = int(ls[0])
        ny = int(ls[1])
        line = fid.readline()
        ls = line.split()
        natom = int(ls[0])
        nmol  = int(ls[1])
        nmoli = int(ls[2])
        nspec = natom + nmol + nmoli
        state.update({'nx':nx,
                      'ny':ny,
                      'natom':natom,
                      'nmol':nmol,
                      'nmoli':nmoli})
        specvec = []
        for i in range(nspec):
            line = fid.readline()
            specvec.append(line)
        state.update({'species':specvec})
        neof = True
        while neof:
            d = self.read_eir_vec(fid)
            if d == 'empty':
                neof = False
            elif d == 'skip':
                continue
            else:
                state.update(d)
        self.f44 = state
        os.chdir(starting_dir)     

    def read_f46(self):
        # Read fort.46
        starting_dir = os.getcwd()
        os.chdir(self.run_dir)
        fid = open('fort.46','r')
        state = {}
        line = fid.readline()
        line = fid.readline()
        ls = line.split()
        natom = int(ls[0])
        nmol  = int(ls[1])
        nmoli = int(ls[2])
        nspec = natom + nmol + nmoli
        state.update({'natom':natom,
                      'nmol':nmol,
                      'nmoli':nmoli})
        specvec = []
        for i in range(nspec):
            line = fid.readline()
            specvec.append(line)
        state.update({'species':specvec})
        neof = True
        while neof:
            d = self.read_eir_vec(fid)
            if d == 'empty':
                neof = False
            elif d == 'skip':
                continue
            else:
                state.update(d)
        self.f46 = state
        os.chdir(starting_dir)  
        
    def read_paramdg(self):
        # Read paramdg
        starting_dir = os.getcwd()
        os.chdir(self.run_dir)
        fid = open('param.dg','r')
        state = {}
        line = fid.readline()
        line = fid.readline()
        text = ''
        xl = []
        yl = []
        while '0,0,' not in text:
            text = fid.readline()
            if '0,0' in text:
                break
            ls = text.split(',')
            xl.append(float(ls[0]))
            yl.append(float(ls[1]))
        p1arr = np.array([xl, yl])
        state.update({'p1a':p1arr})
        xl = []
        yl = []
        while 'p2' not in text:
            text = fid.readline()
            if 'p2' in text:
                break
            ls = text.split(',')
            xl.append(float(ls[0]))
            yl.append(float(ls[1]))
        p1arr1 = np.array([xl, yl])
        state.update({'p1b':p1arr1})

        xl = []
        yl = []
        while '1,1,' not in text:
            text = fid.readline()
            if '1,1' in text:
                break
            ls = text.split(',')
            xl.append(float(ls[0]))
            yl.append(float(ls[1]))
        p2arr = np.array([xl, yl])
        state.update({'p2a':p2arr})

        xl = []
        yl = []
        while 'mis' not in text:
            text = fid.readline()
            if 'mis' in text:
                break
            ls = text.split(',')
            xl.append(float(ls[0]))
            yl.append(float(ls[1]))
        p2arr2 = np.array([xl, yl])
        state.update({'p2b':p2arr2})
    
        self.paramdg = state
        os.chdir(starting_dir)         


