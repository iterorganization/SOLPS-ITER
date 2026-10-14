import yaml
import argparse
from SOLPS_series import SOLPS_series

"""
This class establishes SOLPS-nanny.
Presently, the nanny is only a list of
SOLPS_series instances.

The function time_to_hire_nanny(path_to_config)
returns a SOLPS_nanny corresponding to the 
config-file.

"""
class Nanny:
    def __init__(self, config):
        sl = []
        for key in config.SOLPS_nanny.keys():
            sdict = config.SOLPS_nanny[key]
            sl.append(SOLPS_series(sdict['case_list'],
                                   sdict['run_dir_base'],
                                   sdict['proj_dir_base'],
                                   subcase=sdict['subcase'],
                                   psymbol=sdict['psymbol'],
                                   color=sdict['color']
                                   ))
        self.sl = sl
        
def load_configuration(config_path: str):
    with open(config_path, "r", encoding="utf-8") as file:
        config = yaml.safe_load(file)
    config = argparse.Namespace(**config)
    return config
        
def time_to_hire_nanny(config_path=''):
    config = load_configuration(config_path)
    return Nanny(config)
    
    
  
