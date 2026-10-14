import subprocess
import time
from SOLPS_run import SOLPS_run

"""
This class handles a series of SOLPS-cases. 
Each SOLPS-case is represented by a SOLPS_run object.
The parameters that are required are:
    case_list: A list of cases (folder name)
    run_dir_base:  The base directory in which the runs
                   are executed. Usually a folder in 
                   /scratch/
    proj_dir_base: The directory where the cases
                   are stored. Usually under /work/...
    subcase:       The specific subcase to run.
    The full run/storage directories are 
        /run_dir_base/case_list[*]/subcase
        /proj_dir_base/case_list[*]/subcase
    
    Each case is also given plotting related paramers:
    psymbol: standard python notation for linestyle and symbol
    color:   color of the symbol and line

    The rest are the same as for SOLPS_run and are given
    here to be provided to SOLPS_run.
"""

class SOLPS_series:
    def __init__(self,
                 case_list,
                 run_dir_base,
                 proj_dir_base,
                 subcase='drifts',
                 psymbol='o--',
                 color='k',
                 launch_command='path_to_slurm_script',
                 path_to_b2plot_script='path_to_a_script_to_run_b2plot',
                 psubdiv_ixlist = [9,10, 11, 12, 13, 14, 15,
                                   77, 78, 79, 80, 81, 82, 83],
                 clean=True):
        run_dir_list = []
        proj_dir_list = []
        for case in case_list:
            run_dir_list.append(run_dir_base+case+'/'+subcase+'/')
            proj_dir_list.append(proj_dir_base+case+'/'+subcase+'/')
        self.run_dir_list = run_dir_list
        self.proj_dir_list = proj_dir_list
        sruns = []
        for run_dir in self.run_dir_list:
            sruns.append(SOLPS_run(run_dir,
                                   launch_command=launch_command,
                                   path_to_b2plot_script=path_to_b2plot_script,
                                   psubdiv_ixlist=psubdiv_ixlist,
                                   clean=clean
                                   ))
        self.sruns = sruns
        self.psymbol = psymbol
        self.color = color

    def check_if_running(self):
        # To check if the cases in the series are running.
        for sr in self.sruns:
            sr.check_if_running()

    def launch_if_not_running(self, force_launch=False):
        # Launch cases that are not running.
        # force_launch can be used to ignore the
        # sr.running flag. Only to be used if you know
        # what you are doing.
        for sr in self.sruns:
            if force_launch:
                sr.running = False
            if sr.running == False:
                sr.launch()

    def stopall(self):
        # Stop all runs.
        for sr in self.sruns:
            sr.stop()

    def process_trc(self):
        # Process trc.
        for sr in self.sruns:
            if sr.running == False:
                sr.run_plot_trc()

    def autopilot(self):
        # Relaunch cases that are not running.
        # Presently autopilot is done only
        # at series level.
        try:
            while True:
                self.check_if_running()
                #self.process_trc()
                self.launch_if_not_running()
                print('Waiting 5 minutes')
                time.sleep(300)
                #print('5 minutes passed. Check status.')
        except KeyboardInterrupt:
            pass

    def syncfiles(self):
        # Sync files between run and project dirs.
        for i in range(len(self.run_dir_list)):
            subprocess.run(['rsync', '-r', self.run_dir_list[i],
                            self.proj_dir_list[i]])

    def sync_b2mn(self, base=0):
        # Sync b2mn through the series.
        for i in range(len(self.sruns)):
            if i != base:
                subprocess.run(["cp",
                                self.sruns[base].run_dir+'b2mn.dat',
                                self.sruns[i].run_dir+'b2mn.dat'
                                ])
    def sync_param(self, base=0):
        # Sync param.dg through the series.
        for i in range(len(self.sruns)):
            if i != base:
                subprocess.run(["rm", self.sruns[i].run_dir+'param.dg'])
                subprocess.run(["cp",
                                self.sruns[base].run_dir+'param.dg',
                                self.sruns[i].run_dir+'param.dg'
                                ])         

   

                
 
