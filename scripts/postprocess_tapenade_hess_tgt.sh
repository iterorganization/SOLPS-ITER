#! /usr/bin/env tcsh

modify_tapenade_files_d_d_multi.sh

touch b2mod_diffsizes.F
echo "      module b2mod_diffsizes" >> b2mod_diffsizes.F
echo "      implicit none" >> b2mod_diffsizes.F
echo "      integer ,parameter :: nbdirsmax=5" >> b2mod_diffsizes.F
echo "      integer ,parameter :: nbdirsmax0=nbdirsmax" >> b2mod_diffsizes.F
echo "      end module b2mod_diffsizes" >> b2mod_diffsizes.F


