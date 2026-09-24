-- Version number
local Version = "3.2.1a"
local AppName = "SOLPS_ITER"
local AppPath = "/global/common/software/m3739/perlmutter/SOLPS-ITER/"
local conda_env_path = "/global/common/software/m3739/perlmutter/conda_envs/solps_env"
-- Sets module help message
help(
[[
    This module provides the SOLPS-ITER code. Can only be loaded from a 
    tcsh shell.
    Important note:
    SOLPS-ITER falls under the IMAS user agreement. If your organization
    has signed this agreement and would like access pleace contact
    fus@fusion.gat.com. 
]])


whatis("Name        : " .. AppName)
whatis("Version     : " .. Version)
if(mode() == "load")
then
    if(not (myShellName() == "tcsh") )
    then
        LmodMessage ("You have to enter a tcsh shell before loading this module. You can start a tcsh shell by typing `tcsh` and hitting enter.")
        LmodError("SOLPS-ITER can only be loaded from tcsh.")
    end
end

-- Do not set CRAY_ADD_RPATH: it makes craype expand the full explicit PE library
-- list (dragging in -lpmi/-lpmi2 and libsci_gnu_mpi) instead of its lean default
-- link line, which breaks linking for non-MPI libraries such as MSCL.
--
-- Do not append CRAY_LD_LIBRARY_PATH either: append_path is reversed entry by
-- entry on unload, and this variable grows as the depends_on modules below load,
-- so load and unload would disagree and leave debris in LD_LIBRARY_PATH.

depends_on("texlive")
depends_on("cray-hdf5")
depends_on("cray-netcdf")
conflict("conda")

-- os.getenv() in a modulefile reads the environment as it was when Lmod started,
-- so variables published by the depends_on modules above are not reliably visible
-- here, and are looked up again when the module is unloaded. Every lookup needs a
-- deterministic fallback or `module reload` will not mirror what the load did.
local function env_or(names, fallback)
    for i = 1, #names do
        local v = os.getenv(names[i])
        if v ~= nil and v ~= "" then
            return v
        end
    end
    return fallback
end

-- setup compiler variables
-- The craype wrappers are on PATH via PrgEnv, so naming them directly keeps load
-- and unload identical. capture("which ftn") would re-run a subshell each time and
-- can resolve differently, or to nothing at all, when the module is unloaded.
setenv("FC", "ftn")
setenv("F90", "ftn")
setenv("F77", "ftn")
setenv("CC", "cc")
setenv("CXX", "CC")

-- b2run -m "mpiexec -n N" swaps the launcher for SOLPS_MPIRUN, keeping its arguments
setenv("SOLPS_MPIRUN", "srun")

local netcdf_dir = env_or({"NETCDF_DIR", "CRAY_NETCDF_PREFIX"}, "")
local hdf5_dir   = env_or({"HDF5_DIR", "CRAY_HDF5_PREFIX"}, "")

if mode() == "load" then
    if netcdf_dir == "" then
        LmodWarning(AppName .. ": NETCDF_DIR/CRAY_NETCDF_PREFIX unset, so NCDIR is empty and LD_NETCDF resolves to -L/lib.")
    end
    if hdf5_dir == "" then
        LmodWarning(AppName .. ": HDF5_DIR/CRAY_HDF5_PREFIX unset, so H5DIR is empty.")
    end
end

setenv("NCDIR", netcdf_dir)
setenv("H5DIR", hdf5_dir)

setenv("HOST_NAME", "NERSC")
local conda_root = "/global/common/software/nersc/pe/conda/26.1.0/Miniforge3-25.11.0-1/"
setenv("CONDA_ROOT", conda_root)

-- setenv("MSCL_ROOT", os.getenv("MSCL_DIR"))
-- setenv("GR_ROOT", os.getenv("GR_DIR"))

setenv("SYSNAME", "x86_64_rhel8")
setenv("HOSTNAME", "NERSC")
setenv("TOOLCHAIN", "gfortran")

setenv(string.upper(AppName) .. "_DIR", AppPath)
setenv("SOLPSTOP", AppPath)
setenv("SOLPSWORK", pathJoin("/global/cfs/cdirs/m3739/solps-results/", os.getenv("USER")))

-- Hack conda source replacement here
setenv("CONDA_PREFIX", conda_env_path)
setenv("CONDA_DEFAULT_ENV", "solps_env")
append_path("PATH", pathJoin(conda_env_path,"bin"))

-- setenv() above does not update os.getenv(), so reading CONDA_PREFIX back here
-- returned the pre-module value (usually nil). Use the literal.
local solpslib = pathJoin(AppPath, "lib", "NERSC.gfortran")
setenv("NCARG_ROOT", conda_env_path)

-- unclear why these are not derived from SOLPSLIB
setenv("LibGRS", pathJoin(solpslib, "gr"))
setenv("LibGKS", pathJoin(solpslib, "gli", "src", "gks"))

append_path("PKG_CONFIG_PATH", pathJoin(conda_env_path, "lib", "pkgconfig"))

setenv("SOLPSLIB", solpslib)

-- I would really like to avoid these and rather link them in with --rpath but it does not seem easy
append_path("LD_LIBRARY_PATH", pathJoin(solpslib,"mscl","lib"))

append_path("LD_LIBRARY_PATH", pathJoin(netcdf_dir, "lib"))

append_path("LD_LIBRARY_PATH", pathJoin(conda_env_path, "lib"))

if(mode() == "load")
then
    source_sh("tcsh", pathJoin(AppPath, "SETUP", "setup.csh.NERSC.gfortran"))
end
