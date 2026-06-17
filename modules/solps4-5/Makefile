# Test whether necessary environment variables are defined; if not, exit
ifndef HOST_NAME
$(error HOST_NAME not defined)
endif
ifndef COMPILER
$(error COMPILER not defined)
endif

MAKES = Makefile
# Include global SOLPS compiler settings
ifndef SOLPS_CPP
  ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER} ] && echo yes || echo no ),yes)
    include ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}
    MAKES += ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER} ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}
  else
    $(warning ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER} not found.)
  endif
  ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/config.common.${COMPILER} ] && echo yes || echo no ),yes)
    include ${SOLPSTOP}/SETUP/config.common.${COMPILER}
    MAKES += ${SOLPSTOP}/SETUP/config.common.${COMPILER}
  endif
  ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
    include ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}.local
    MAKES += ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}.local
  endif
else
  MAKES += ${SOLPSTOP}/Makefile ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER} ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}
  ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/config.common.${COMPILER} ] && echo yes || echo no ),yes)
    MAKES += ${SOLPSTOP}/SETUP/config.common.${COMPILER}
  endif
  ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
    MAKES += ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}.local
  endif
endif
ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
  MAKES += ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER}.local
endif

MAKETAGS ?= ctags -e -f

# Extensions for object directories when various options are used
ifdef SOLPS_OPENMP
EXT_OPENMP = .openmp
endif
ifdef USE_IMPGYRO
EXT_IMPGYRO = .ig
else
ifdef SOLPS_MPI
EXT_MPI = .mpi
endif
endif
ifdef SOLPS_DEBUG
EXT_DEBUG = .debug
endif

TOOL_CHAIN = ${HOST_NAME}.${COMPILER}${EXT_DEBUG}

SRCDIR = ${SOLPSTOP}/modules/solps4-5/src
S45DIR = ${SOLPSTOP}/modules/solps4-5
EIRDIR = ${SOLPSTOP}/modules/Eirene/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_OPENMP}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
B2BDIR = ${SOLPSTOP}/modules/B2.5/builds/couple_Eirene.${HOST_NAME}.${COMPILER}${EXT_OPENMP}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
OBJDIR = ${SOLPSTOP}/modules/solps4-5/builds/${TOOL_CHAIN}
BASEDIR = ${SOLPSTOP}/modules/solps4-5
DEFINES += -DSOLPS4_3 -DB25_EIRENE -DUSE_ARRAYS
SRC4LOCAL = ${SOLPSTOP}/modules/solps4-5/src/local_4
SRC5LOCAL = ${SOLPSTOP}/modules/solps4-5/src/local_5
INC4LOCAL = ${SOLPSTOP}/modules/solps4-5/src/B2_include.local
INC5LOCAL = ${SOLPSTOP}/modules/solps4-5/src/B2.5_include.local
B2M5LOCAL = ${SOLPSTOP}/modules/solps4-5/src/B2.5_modules.local
EIRMLOCAL = ${SOLPSTOP}/modules/solps4-5/src/Eirene_modules.local
ifeq ($(shell [ -d ${SRC4LOCAL} ] && echo yes || echo no ),yes)
SOLPSINCLUDE += -I${SRC4LOCAL}
TAGSLIST = ${SRC4LOCAL}/*.F
VPATH = ${SRC4LOCAL}:
else
TAGSLIST =
VPATH =
endif
ifeq ($(shell [ -d ${SRC5LOCAL} ] && echo yes || echo no ),yes)
SOLPSINCLUDE += -I${SRC5LOCAL}
TAGSLIST += ${SRC5LOCAL}/*.F
VPATH += ${SRC5LOCAL}:
endif
ifeq ($(shell [ -d ${SOLPS4}/src/Braams/b2/include.local ] && echo yes || echo no ),yes)
ifeq ($(shell [ -d ${INC4LOCAL} ] && echo yes || echo no ),yes)
SOLPSINCLUDE += -I${INC4LOCAL}
TAGSLIST += ${INC4LOCAL}/*.h
endif
endif
ifeq ($(shell [ -d ${INC5LOCAL} ] && echo yes || echo no ),yes)
SOLPSINCLUDE += -I${INC5LOCAL}
TAGSLIST += ${INC5LOCAL}/*.h
endif
ifeq ($(shell [ -d ${B2M5LOCAL} ] && echo yes || echo no ),yes)
SOLPSINCLUDE += -I${B2M5LOCAL}
TAGSLIST += ${B2M5LOCAL}/*.F
VPATH += ${B2M5LOCAL}:
endif
ifeq ($(shell [ -d ${EIRMLOCAL} ] && echo yes || echo no ),yes)
SOLPSINCLUDE += -I${EIRMLOCAL}
TAGSLIST += ${EIRMLOCAL}/*.F
VPATH += ${EIRMLOCAL}:
endif
ifdef MDSPLUS_DIR
SOLPSINCLUDE += -I${MDSPLUS_DIR}/include
endif
ifdef NCDIR
SOLPSINCLUDE += -I${NCDIR}/include
endif
SOLPSINCLUDE += -I${SRCDIR}/B2.5_include -I${SRCDIR}/B2.5_commons -I${SRCDIR}/B2_include
ifeq ($(shell [ -d ${SRCDIR}/Eirene_commons ] && echo yes || echo no ),yes)
SOLPSINCLUDE += -I${SRCDIR}/Eirene_commons
endif
TAGSLIST += ${SRCDIR}/*_commons/*.[hH] ${SRCDIR}/*/*.F ${SRCDIR}/*.F
VPATH += ${SRCDIR}/B2.5_modules:${SRCDIR}:${SRCDIR}/solps4_B2:${SRCDIR}/solps4_Eirene:${SRCDIR}/solps5

ifeq ($(shell [ -s ${SRCDIR}/B2.5_modules/b2mod_dimensions.F ] && echo yes || echo no ),yes)
DEFINES += -DDIMENSIONS_MODULE
endif

include ${S45DIR}/config/compile
MAKES += ${S45DIR}/config/compile ${S45DIR}/config/config.${HOST_NAME}.${COMPILER}
ifeq ($(shell [ -e ${S45DIR}/config/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
include ${S45DIR}/config/config.${HOST_NAME}.${COMPILER}.local
MAKES += ${S45DIR}/config/config.${HOST_NAME}.${COMPILER}.local
endif

# Verify that some needed variables are defined
SOLPS4 ?= ${SOLPSTOP}/../[sS][oO][lL][pP][sS]4.3
ifeq ($(shell [ -d ${SOLPS4} ] && echo yes || echo no ),no)
$(warning modules/solps4-5: SOLPS4 directory not found at '${SOLPS4}'. Legacy solps4-5 module will not be built.)
SOLPS4_MISSING := yes
endif
ifndef SOLPS4_MISSING
ifndef LD_MSCL
$(error LD_MSCL not defined. Run the install_dependencies script first.)
endif
endif

$(shell awk 'FNR==1{if(!/^FOBJS *=/){e=1;exit}} END{exit e}' \
        ${BASEDIR}/LISTOBJ 2>/dev/null || rm -f ${BASEDIR}/LISTOBJ)
ifeq ($(shell [ -e ${BASEDIR}/LISTOBJ ] && echo yes || echo no ),yes)
include ${BASEDIR}/LISTOBJ
endif

PROG_XR = b2sxdr.exe
MOD4LES = ${patsubst ${SRCDIR}/Eirene_modules/%.F,%.o,${shell echo ${SRCDIR}/Eirene_modules/*.F}}
MOD4LES+= ${patsubst ${SRCDIR}/Eirene_modules/%.F90,%.o,${shell echo ${SRCDIR}/Eirene_modules/*.F90}}
MOD5LES = ${patsubst ${SRCDIR}/B2.5_modules/%.F,%.o,${shell echo ${SRCDIR}/B2.5_modules/*.F}}
MOD5LES += ${patsubst ${SRCDIR}/solps5/%.F90,%.o,${shell echo ${SRCDIR}/solps5/*.F90}}
MODULES	= ${MOD4LES} ${MOD5LES}
SOURCB4 = ${patsubst ${SRCDIR}/solps4_B2/%.F,%.o,${shell echo ${SRCDIR}/solps4_B2/*.F}}
SOURCE4 = ${patsubst ${SRCDIR}/solps4_Eirene/%.F,%.o,${shell echo ${SRCDIR}/solps4_Eirene/*.F}}
SOURCE5 = ${patsubst ${SRCDIR}/solps5/%.F,%.o,${shell echo ${SRCDIR}/solps5/*.F}}
SOURCF4 = ${shell echo ${SRCDIR}/solps4_*/*.F}
SOURCF5 = ${shell echo ${SRCDIR}/solps5/*.F}
MODMODS = ${MODULES:%.o=${OBJDIR}/%.${MOD}}
MD4OBJS = ${MOD4LES:%.o=${OBJDIR}/%.o}
MD5OBJS = ${MOD5LES:%.o=${OBJDIR}/%.o}
MODOBJS = ${MODULES:%.o=${OBJDIR}/%.o}
SB4OBJS = ${SOURCB4:%.o=${OBJDIR}/%.o}
SE4OBJS = ${SOURCE4:%.o=${OBJDIR}/%.o}
SR5OBJS = ${SOURCE5:%.o=${OBJDIR}/%.o}
ALLOBJS = ${FOBJS:%.o=${OBJDIR}/%.o} ${F90OBJS:%.o=${OBJDIR}/%.o}
FFLIST  = ${shell echo ${SRCDIR}/*/*.H ${SRCDIR}/*.F ${SRCDIR}/solps5/*.F ${SRCDIR}/solps5/*.F90 ${SRCDIR}/B2.5_modules/*.F ${SRCDIR}/B2.5_modules/*.F90 ${SRCDIR}/solps4_B2/*.F}
ifeq ($(shell [ -d ${SRC4LOCAL} ] && echo yes || echo no ),yes)
FFLIST  += ${shell echo ${SRC4LOCAL}/*.F}
endif
ifeq ($(shell [ -d ${SRC5LOCAL} ] && echo yes || echo no ),yes)
FFLIST  += ${shell echo ${SRC5LOCAL}/*.F}
endif
MODLIST = ${shell echo ${SRCDIR}/B2.5_modules/*.F ${SRCDIR}/b2_4to5.F ${SRCDIR}/B2.5_modules/*.F90 ${SRCDIR}/solps5/*.F90 ${SRCDIR}/solps5/b2mod_*.F ${SRCDIR}/solps5/eirmod_*.F}

EXELIST = ${patsubst %.exe, %.o, ${PROG_XR}}
EXCLUDELIST = ${patsubst %.o, %\\.o, ${EXELIST}}
XREXE = ${patsubst %.exe, ${OBJDIR}/%.exe, ${PROG_XR}}
XROBJ = ${patsubst %.exe, ${OBJDIR}/%.o, ${PROG_XR}}

XREXTRA=${OBJDIR}/b2_4to5.o ${OBJDIR}/xerset_5.o
MNEXTRA=

.PHONY: DEFAULT ALL clean depend listobj tags local links

ALL: links ${XREXE}

DEFAULT: ${XREXE}

b2sxdr: ${XREXE}

${XREXE}: ${XROBJ} ${XREXTRA} ${OBJDIR}/libb2_solps5.a ${OBJDIR}/libb2_solps4.a ${MNEXTRA} ${MAKES}
	${LD} ${LDOPTS} ${XROBJ} ${XREXTRA} ${OBJDIR}/libb2_solps5.a ${OBJDIR}/libb2_solps4.a ${MNEXTRA} -o $@ ${LDLIBES} ${LCPP} ${LDOPTSend}

${OBJDIR}/allocate_modules.o: ${OBJDIR}/braeir.${MOD} ${OBJDIR}/cadgeo.${MOD} ${OBJDIR}/cai.${MOD} ${OBJDIR}/ccflux.${MOD} ${OBJDIR}/ccona.${MOD} ${OBJDIR}/cestim.${MOD} ${OBJDIR}/cgeom.${MOD} ${OBJDIR}/clast.${MOD} ${OBJDIR}/clena.${MOD} ${OBJDIR}/clogau.${MOD} ${OBJDIR}/comnnl.${MOD} ${OBJDIR}/comspl.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comxs.${MOD} ${OBJDIR}/coutau.${MOD} ${OBJDIR}/cpes.${MOD} ${OBJDIR}/cplot.${MOD} ${OBJDIR}/cpolyg.${MOD} ${OBJDIR}/cref.${MOD} ${OBJDIR}/crefmod.${MOD} ${OBJDIR}/csdvi.${MOD} ${OBJDIR}/csdvi_bgk.${MOD} ${OBJDIR}/csdvi_cop.${MOD} ${OBJDIR}/cspei.${MOD} ${OBJDIR}/cspez.${MOD} ${OBJDIR}/cstep.${MOD} ${OBJDIR}/ctetra.${MOD} ${OBJDIR}/ctext.${MOD} ${OBJDIR}/cupd.${MOD} ${OBJDIR}/czt1.${MOD} ${OBJDIR}/eirbra.${MOD} ${OBJDIR}/photon.${MOD}

${OBJDIR}/areaa.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/cgrid.${MOD}

${OBJDIR}/b2rw.o: ${OBJDIR}/eirdiag.${MOD}

${OBJDIR}/b2sxdr.o: ${OBJDIR}/cpes.${MOD} ${OBJDIR}/eirmod_parmmod.${MOD}

${OBJDIR}/cdef.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/comxs.${MOD}

${OBJDIR}/cdefn.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/comxs.${MOD}

${OBJDIR}/checks.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/ctrig.${MOD} ${OBJDIR}/eirmod_octree.${MOD}

${OBJDIR}/condense.o: ${OBJDIR}/comxs.${MOD}

${OBJDIR}/couple_core.o: ${OBJDIR}/cspei.${MOD} ${OBJDIR}/eirmap.${MOD}

${OBJDIR}/ctell.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/default.o: ${OBJDIR}/ceirsrt.${MOD} ${OBJDIR}/eirdiag.${MOD}

${OBJDIR}/ducttr.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/clgin.${MOD}

${OBJDIR}/eirene_f30f31.o: ${OBJDIR}/ctrig.${MOD}

${OBJDIR}/ello.o: ${OBJDIR}/clmsur.${MOD}

${OBJDIR}/ellu.o: ${OBJDIR}/clmsur.${MOD}

${OBJDIR}/emaxw.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/fcosin.o: ${OBJDIR}/crand.${MOD}

${OBJDIR}/feelei1.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/comxs.${MOD}

${OBJDIR}/feelrc1.o: ${OBJDIR}/comxs.${MOD}

${OBJDIR}/fehvds1.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/comxs.${MOD}

${OBJDIR}/find_param.o: ${OBJDIR}/parmmod.${MOD} ${OBJDIR}/ccrm.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comprt.${MOD} ${OBJDIR}/cpes.${MOD}

${OBJDIR}/fmaxwl.o: ${OBJDIR}/crand.${MOD}

${OBJDIR}/ftabei1.o: ${OBJDIR}/comxs.${MOD}

${OBJDIR}/ftabrc1.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/comxs.${MOD}

${OBJDIR}/fzrtor.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/cgrid.${MOD}

${OBJDIR}/fzrtra.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/cgrid.${MOD}

${OBJDIR}/fzrtri.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/cgrid.${MOD}

${OBJDIR}/geousr.o: ${OBJDIR}/cgrid.${MOD}

${OBJDIR}/geradx.o: ${OBJDIR}/clmsur.${MOD}

${OBJDIR}/gerady.o: ${OBJDIR}/clmsur.${MOD}

${OBJDIR}/grid.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/hypm.o: ${OBJDIR}/clmsur.${MOD}

${OBJDIR}/hypp.o: ${OBJDIR}/clmsur.${MOD}

${OBJDIR}/if0prm.o: ${OBJDIR}/braeir.${MOD} ${OBJDIR}/cinit.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comprt.${MOD}

${OBJDIR}/impneut_interface.o: ${OBJDIR}/impdns.${MOD} ${OBJDIR}/impmom.${MOD} ${OBJDIR}/impsrc.${MOD}

${OBJDIR}/impsrc.o: ${OBJDIR}/ccoupl.${MOD} ${OBJDIR}/ctrig.${MOD}

${OBJDIR}/infcop.o: ${OBJDIR}/brascl.${MOD} ${OBJDIR}/braeir.${MOD} ${OBJDIR}/braspoi.${MOD} ${OBJDIR}/ccona.${MOD} ${OBJDIR}/csdvi.${MOD} ${OBJDIR}/cspei.${MOD} ${OBJDIR}/cstep.${MOD} ${OBJDIR}/coutau.${MOD} ${OBJDIR}/eirbra.${MOD} ${OBJDIR}/ifwrite.${MOD} ${OBJDIR}/impdns.${MOD}

${OBJDIR}/infstat.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/csdvi.${MOD} ${OBJDIR}/eirbra.${MOD}

${OBJDIR}/init.o: ${OBJDIR}/ceirsrt.${MOD} ${OBJDIR}/eirdiag.${MOD}

${OBJDIR}/input.o: ${OBJDIR}/adsp.${MOD} ${OBJDIR}/ccona.${MOD} ${OBJDIR}/ccrm.${MOD} ${OBJDIR}/cdiprl.${MOD} ${OBJDIR}/ceirsrt.${MOD} ${OBJDIR}/censav.${MOD} ${OBJDIR}/cgrptl.${MOD} ${OBJDIR}/clogau.${MOD} ${OBJDIR}/comsmu.${MOD} ${OBJDIR}/comsou.${MOD} ${OBJDIR}/cpes.${MOD} ${OBJDIR}/cpl3d.${MOD} ${OBJDIR}/cref.${MOD} ${OBJDIR}/crefmod.${MOD} ${OBJDIR}/csdvi.${MOD} ${OBJDIR}/cspei.${MOD} ${OBJDIR}/cstep.${MOD} ${OBJDIR}/photon.${MOD}

${OBJDIR}/inspect.o: ${OBJDIR}/eircolsp.${MOD}

${OBJDIR}/leer.o: ${OBJDIR}/comprt.${MOD}

${OBJDIR}/octree.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/eirmod_octree.${MOD}

${OBJDIR}/para1.o: ${OBJDIR}/clmsur.${MOD}

${OBJDIR}/para2o.o: ${OBJDIR}/clmsur.${MOD}

${OBJDIR}/para2u.o: ${OBJDIR}/clmsur.${MOD}

${OBJDIR}/plasma.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/plasma_deriv.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/cspei.${MOD}

${OBJDIR}/plgell.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/pltadd.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/clmsur.${MOD} ${OBJDIR}/crech.${MOD}

${OBJDIR}/pltaxi.o: ${OBJDIR}/cplmsk.${MOD}

${OBJDIR}/pltka.o: ${OBJDIR}/clmsur.${MOD} ${OBJDIR}/crech.${MOD}

${OBJDIR}/pltki.o: ${OBJDIR}/clmsur.${MOD} ${OBJDIR}/crech.${MOD}

${OBJDIR}/pltku.o: ${OBJDIR}/clmsur.${MOD} ${OBJDIR}/crech.${MOD}

${OBJDIR}/pltmsk.o: ${OBJDIR}/cplmsk.${MOD}

${OBJDIR}/plt2d.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/crech.${MOD} ${OBJDIR}/cplmsk.${MOD} ${OBJDIR}/cpl3d.${MOD}

${OBJDIR}/pl3d.o: ${OBJDIR}/cpl3d.${MOD}

${OBJDIR}/profe.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/profn.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/profr.o: ${OBJDIR}/cspei.${MOD}

${OBJDIR}/profs.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/pside.o: ${OBJDIR}/crech.${MOD}

${OBJDIR}/read_photdbk.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/photon.${MOD}

${OBJDIR}/rdtrim.o: ${OBJDIR}/cref.${MOD} ${OBJDIR}/crefmod.${MOD}

${OBJDIR}/refdat.o: ${OBJDIR}/cref.${MOD} ${OBJDIR}/crefmod.${MOD}

${OBJDIR}/reflec.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/crand.${MOD} ${OBJDIR}/cref.${MOD} ${OBJDIR}/crefmod.${MOD}

${OBJDIR}/secang.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/setamd.o: ${OBJDIR}/ccrm.${MOD} ${OBJDIR}/photon.${MOD}

${OBJDIR}/setcon.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/setfit.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/settxt.o: ${OBJDIR}/coutau.${MOD}

${OBJDIR}/sheath.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/sneigh.o: ${OBJDIR}/avltree.${MOD} ${OBJDIR}/ccona.${MOD}

${OBJDIR}/sputer.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/crand.${MOD}

${OBJDIR}/srcusr.o: ${OBJDIR}/eirsamsp.${MOD}

${OBJDIR}/stcoor.o: ${OBJDIR}/crech.${MOD}

${OBJDIR}/step.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/cstep.${MOD}

${OBJDIR}/tetra_schnitt.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/timea.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/eirmod_octree.${MOD}

${OBJDIR}/user_default.o: ${OBJDIR}/eirdiag.${MOD}

${OBJDIR}/user_input.o: ${OBJDIR}/impdns.${MOD} ${OBJDIR}/impmom.${MOD} ${OBJDIR}/impsrc.${MOD}

${OBJDIR}/velocs.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/crand.${MOD}

${OBJDIR}/volume.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/wneutral.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/cestim.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comxs.${MOD} ${OBJDIR}/ifwrite.${MOD}

${OBJDIR}/wneutral_fluxes.o: ${OBJDIR}/amark_mod.${MOD} ${OBJDIR}/braeir.${MOD} ${OBJDIR}/ccona.${MOD} ${OBJDIR}/cestim.${MOD}

${OBJDIR}/wrplam.o: ${OBJDIR}/ccrm.${MOD} ${OBJDIR}/ifwrite.${MOD}

${OBJDIR}/xsecta.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/xsectm.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/xsectp.o: ${OBJDIR}/caprmc.${MOD} ${OBJDIR}/ccona.${MOD} ${OBJDIR}/photon.${MOD}

${OBJDIR}/xsectph.o: ${OBJDIR}/photon.${MOD}

${OBJDIR}/xsectph_param.o: ${OBJDIR}/photon.${MOD}

${OBJDIR}/xstapi.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/xstcx.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/xstei.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/xstel.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/zylnd2.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/zylpln.o: ${OBJDIR}/ccona.${MOD}

${OBJDIR}/b2_4to5.o: ${OBJDIR}/eirmod_parmmod.${MOD} ${OBJDIR}/braeir.${MOD} ${OBJDIR}/eirdiag.${MOD}

${OBJDIR}/b2mod_b2_to_astra.o: ${OBJDIR}/eirdiag.${MOD}

${OBJDIR}/b2mod_neutrals_namelist.o: ${OBJDIR}/eirmod_parmmod.${MOD} ${OBJDIR}/parmmod.${MOD} ${OBJDIR}/braeir.${MOD} ${OBJDIR}/ceirsrt.${MOD} ${OBJDIR}/comnnl.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/eirdiag.${MOD}

${OBJDIR}/eirmod_parmmod.o:
	ln -sf ${OBJDIR}/parmmod.o $@

${OBJDIR}/eirmod_precision.o:
	ln -sf ${OBJDIR}/precision.o $@

${OBJDIR}/eirmod_braeir.o:
	ln -sf ${EIRDIR}/eirmod_braeir.o ${OBJDIR}

${OBJDIR}/eirmod_cinit.o:
	ln -sf ${EIRDIR}/eirmod_cinit.o ${OBJDIR}

${OBJDIR}/eirmod_comusr.o:
	ln -sf ${EIRDIR}/eirmod_comusr.o ${OBJDIR}

${OBJDIR}/eirmod_comxs.o:
	ln -sf ${EIRDIR}/eirmod_comxs.o ${OBJDIR}

${OBJDIR}/eirmod_ctrig.o:
	ln -sf ${EIRDIR}/eirmod_ctrig.o ${OBJDIR}

${OBJDIR}/eirmod_extrab25.o: ${OBJDIR}/eirmod_comxs.${MOD}
	ln -sf ${EIRDIR}/eirmod_extrab25.o ${OBJDIR}

${OBJDIR}/eirmod_mpi.o: ${OBJDIR}/comprt.${MOD} ${OBJDIR}/precision.${MOD} ${SRCDIR}/Eirene_modules/eirmod_mpi.F90 ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/eirmod_mpi.o -c ${SRCDIR}/Eirene_modules/eirmod_mpi.F90

${OBJDIR}/eirmod_octree.o: ${SRCDIR}/Eirene_modules/eirmod_octree.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/eirmod_octree.o -c ${SRCDIR}/Eirene_modules/eirmod_octree.F

${OBJDIR}/adsp.o: ${OBJDIR}/clogau.${MOD} ${OBJDIR}/comprt.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/cpes.${MOD} ${OBJDIR}/ctrcei.${MOD} ${OBJDIR}/eirmod_mpi.${MOD} ${OBJDIR}/precision.${MOD} ${SRCDIR}/Eirene_modules/adsp.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/adsp.o -c ${SRCDIR}/Eirene_modules/adsp.F

${OBJDIR}/amark_mod.o: ${SRCDIR}/Eirene_modules/amark_mod.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/amark_mod.o -c ${SRCDIR}/Eirene_modules/amark_mod.F

${OBJDIR}/avltree.o: ${OBJDIR}/ccona.${MOD} ${SRCDIR}/Eirene_modules/avltree.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/avltree.o -c ${SRCDIR}/Eirene_modules/avltree.F

${OBJDIR}/braeir.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/braeir.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/braeir.o -c ${SRCDIR}/Eirene_modules/braeir.F

${OBJDIR}/brascl.o: ${SRCDIR}/Eirene_modules/brascl.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/brascl.o -c ${SRCDIR}/Eirene_modules/brascl.F

${OBJDIR}/braspoi.o: ${SRCDIR}/Eirene_modules/braspoi.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/braspoi.o -c ${SRCDIR}/Eirene_modules/braspoi.F

${OBJDIR}/cadgeo.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cadgeo.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cadgeo.o -c ${SRCDIR}/Eirene_modules/cadgeo.F

${OBJDIR}/cai.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cai.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cai.o -c ${SRCDIR}/Eirene_modules/cai.F

${OBJDIR}/caprmc.o: ${OBJDIR}/cgrid.${MOD} ${OBJDIR}/comsou.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comxs.${MOD} ${OBJDIR}/ctrcei.${MOD} ${SRCDIR}/Eirene_modules/caprmc.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/caprmc.o -c ${SRCDIR}/Eirene_modules/caprmc.F

${OBJDIR}/ccflux.o: ${OBJDIR}/ctrig.${MOD} ${OBJDIR}/ctrcei.${MOD} ${OBJDIR}/cgeom.${MOD} ${OBJDIR}/ccona.${MOD} ${OBJDIR}/comusr.${MOD} ${SRCDIR}/Eirene_modules/ccflux.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/ccflux.o -c ${SRCDIR}/Eirene_modules/ccflux.F

${OBJDIR}/ccona.o: ${SRCDIR}/Eirene_modules/ccona.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/ccona.o -c ${SRCDIR}/Eirene_modules/ccona.F

${OBJDIR}/ccoupl.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/ccoupl.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/ccoupl.o -c ${SRCDIR}/Eirene_modules/ccoupl.F

${OBJDIR}/ccrm.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/comxs.${MOD} ${OBJDIR}/ctrcei.${MOD} ${OBJDIR}/clogau.${MOD} ${OBJDIR}/cestim.${MOD} ${OBJDIR}/czt1.${MOD} ${OBJDIR}/comsou.${MOD} ${OBJDIR}/caprmc.${MOD} ${OBJDIR}/photon.${MOD} ${OBJDIR}/csdvi.${MOD} ${OBJDIR}/ccflux.${MOD} ${SRCDIR}/Eirene_modules/ccrm.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/ccrm.o -c ${SRCDIR}/Eirene_modules/ccrm.F

${OBJDIR}/cdiprl.o: ${SRCDIR}/Eirene_modules/cdiprl.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cdiprl.o -c ${SRCDIR}/Eirene_modules/cdiprl.F

${OBJDIR}/ceirsrt.o: ${OBJDIR}/precision.o ${SRCDIR}/Eirene_modules/ceirsrt.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/ceirsrt.o -c ${SRCDIR}/Eirene_modules/ceirsrt.F

${OBJDIR}/censav.o: ${SRCDIR}/Eirene_modules/censav.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/censav.o -c ${SRCDIR}/Eirene_modules/censav.F

${OBJDIR}/cestim.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cestim.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cestim.o -c ${SRCDIR}/Eirene_modules/cestim.F

${OBJDIR}/cfit.o: ${SRCDIR}/Eirene_modules/cfit.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cfit.o -c ${SRCDIR}/Eirene_modules/cfit.F

${OBJDIR}/cfplk.o: ${SRCDIR}/Eirene_modules/cfplk.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cfplk.o -c ${SRCDIR}/Eirene_modules/cfplk.F

${OBJDIR}/cgeom.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cgeom.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cgeom.o -c ${SRCDIR}/Eirene_modules/cgeom.F

${OBJDIR}/cgrid.o: ${OBJDIR}/comprt.${MOD} ${SRCDIR}/Eirene_modules/cgrid.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cgrid.o -c ${SRCDIR}/Eirene_modules/cgrid.F

${OBJDIR}/cgrptl.o: ${SRCDIR}/Eirene_modules/cgrptl.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cgrptl.o -c ${SRCDIR}/Eirene_modules/cgrptl.F

${OBJDIR}/cinit.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cinit.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cinit.o -c ${SRCDIR}/Eirene_modules/cinit.F

${OBJDIR}/clast.o: ${SRCDIR}/Eirene_modules/clast.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/clast.o -c ${SRCDIR}/Eirene_modules/clast.F

${OBJDIR}/clena.o: ${OBJDIR}/comsig.${MOD} ${SRCDIR}/Eirene_modules/clena.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/clena.o -c ${SRCDIR}/Eirene_modules/clena.F

${OBJDIR}/clgin.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/clgin.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/clgin.o -c ${SRCDIR}/Eirene_modules/clgin.F

${OBJDIR}/clmsur.o: ${SRCDIR}/Eirene_modules/clmsur.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/clmsur.o -c ${SRCDIR}/Eirene_modules/clmsur.F

${OBJDIR}/clogau.o: ${OBJDIR}/precision.${MOD} ${SRCDIR}/Eirene_modules/clogau.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/clogau.o -c ${SRCDIR}/Eirene_modules/clogau.F

${OBJDIR}/comnnl.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comnnl.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/comnnl.o -c ${SRCDIR}/Eirene_modules/comnnl.F

${OBJDIR}/comprt.o: ${OBJDIR}/precision.${MOD} ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comprt.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/comprt.o -c ${SRCDIR}/Eirene_modules/comprt.F

${OBJDIR}/comsig.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comsig.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/comsig.o -c ${SRCDIR}/Eirene_modules/comsig.F

${OBJDIR}/comsmu.o: ${SRCDIR}/Eirene_modules/comsmu.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/comsmu.o -c ${SRCDIR}/Eirene_modules/comsmu.F

${OBJDIR}/comsou.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comsou.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/comsou.o -c ${SRCDIR}/Eirene_modules/comsou.F

${OBJDIR}/comspl.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comspl.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/comspl.o -c ${SRCDIR}/Eirene_modules/comspl.F

${OBJDIR}/comusr.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comusr.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/comusr.o -c ${SRCDIR}/Eirene_modules/comusr.F

${OBJDIR}/comxs.o: ${OBJDIR}/cupd.${MOD} ${OBJDIR}/comprt.${MOD} ${SRCDIR}/Eirene_modules/comxs.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/comxs.o -c ${SRCDIR}/Eirene_modules/comxs.F

${OBJDIR}/coutau.o: ${SRCDIR}/Eirene_modules/coutau.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/coutau.o -c ${SRCDIR}/Eirene_modules/coutau.F

${OBJDIR}/cpes.o: ${OBJDIR}/comprt.${MOD} ${OBJDIR}/ctrcei.${MOD} ${OBJDIR}/eirmod_precision.${MOD} ${OBJDIR}/eirmod_mpi.${MOD} ${SRCDIR}/Eirene_modules/cpes.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cpes.o -c ${SRCDIR}/Eirene_modules/cpes.F

${OBJDIR}/cplmsk.o: ${SRCDIR}/Eirene_modules/cplmsk.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cplmsk.o -c ${SRCDIR}/Eirene_modules/cplmsk.F

${OBJDIR}/cplot.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cplot.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cplot.o -c ${SRCDIR}/Eirene_modules/cplot.F

${OBJDIR}/cpl3d.o: ${SRCDIR}/Eirene_modules/cpl3d.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cpl3d.o -c ${SRCDIR}/Eirene_modules/cpl3d.F

${OBJDIR}/cpolyg.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cpolyg.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cpolyg.o -c ${SRCDIR}/Eirene_modules/cpolyg.F

${OBJDIR}/crand.o: ${SRCDIR}/Eirene_modules/crand.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/crand.o -c ${SRCDIR}/Eirene_modules/crand.F

${OBJDIR}/crech.o: ${SRCDIR}/Eirene_modules/crech.F ${OBJDIR}/precision.${MOD} ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/crech.o -c ${SRCDIR}/Eirene_modules/crech.F

${OBJDIR}/cref.o: ${SRCDIR}/Eirene_modules/cref.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cref.o -c ${SRCDIR}/Eirene_modules/cref.F

${OBJDIR}/crefmod.o: ${SRCDIR}/Eirene_modules/crefmod.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/crefmod.o -c ${SRCDIR}/Eirene_modules/crefmod.F

${OBJDIR}/csdvi.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/csdvi.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/csdvi.o -c ${SRCDIR}/Eirene_modules/csdvi.F

${OBJDIR}/csdvi_bgk.o: ${SRCDIR}/Eirene_modules/csdvi_bgk.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/csdvi_bgk.o -c ${SRCDIR}/Eirene_modules/csdvi_bgk.F

${OBJDIR}/csdvi_cop.o: ${SRCDIR}/Eirene_modules/csdvi_cop.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/csdvi_cop.o -c ${SRCDIR}/Eirene_modules/csdvi_cop.F

${OBJDIR}/cspars.o: ${SRCDIR}/Eirene_modules/cspars.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cspars.o -c ${SRCDIR}/Eirene_modules/cspars.F

${OBJDIR}/cspei.o: ${SRCDIR}/Eirene_modules/cspei.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cspei.o -c ${SRCDIR}/Eirene_modules/cspei.F

${OBJDIR}/cspez.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cspez.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cspez.o -c ${SRCDIR}/Eirene_modules/cspez.F

${OBJDIR}/cstep.o: ${SRCDIR}/Eirene_modules/cstep.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cstep.o -c ${SRCDIR}/Eirene_modules/cstep.F

${OBJDIR}/ctetra.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/ctetra.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/ctetra.o -c ${SRCDIR}/Eirene_modules/ctetra.F

${OBJDIR}/ctext.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/ctext.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/ctext.o -c ${SRCDIR}/Eirene_modules/ctext.F

${OBJDIR}/ctrcei.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/ctrcei.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/ctrcei.o -c ${SRCDIR}/Eirene_modules/ctrcei.F

${OBJDIR}/ctrig.o: ${OBJDIR}/cgrid.${MOD} ${SRCDIR}/Eirene_modules/ctrig.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/ctrig.o -c ${SRCDIR}/Eirene_modules/ctrig.F

${OBJDIR}/ctsurf.o: ${SRCDIR}/Eirene_modules/ctsurf.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/ctsurf.o -c ${SRCDIR}/Eirene_modules/ctsurf.F

${OBJDIR}/cupd.o: ${OBJDIR}/comsig.${MOD} ${SRCDIR}/Eirene_modules/cupd.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/cupd.o -c ${SRCDIR}/Eirene_modules/cupd.F

${OBJDIR}/czt1.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/czt1.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/czt1.o -c ${SRCDIR}/Eirene_modules/czt1.F

${OBJDIR}/eirbase.o: ${SRCDIR}/Eirene_modules/eirbase.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/eirbase.o -c ${SRCDIR}/Eirene_modules/eirbase.F

${OBJDIR}/eirbra.o: ${SRCDIR}/Eirene_modules/eirbra.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/eirbra.o -c ${SRCDIR}/Eirene_modules/eirbra.F

${OBJDIR}/eircolsp.o: ${SRCDIR}/Eirene_modules/eircolsp.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/eircolsp.o -c ${SRCDIR}/Eirene_modules/eircolsp.F

${OBJDIR}/eirdiag.o: ${OBJDIR}/clgin.${MOD} ${OBJDIR}/ccoupl.${MOD} ${SRCDIR}/Eirene_modules/eirdiag.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/eirdiag.o -c ${SRCDIR}/Eirene_modules/eirdiag.F

${OBJDIR}/eirgrid.o: ${SRCDIR}/Eirene_modules/eirgrid.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/eirgrid.o -c ${SRCDIR}/Eirene_modules/eirgrid.F

${OBJDIR}/eirgrid_lib.o: ${OBJDIR}/eirmap.${MOD} ${SRCDIR}/Eirene_modules/eirgrid_lib.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/eirgrid_lib.o -c ${SRCDIR}/Eirene_modules/eirgrid_lib.F

${OBJDIR}/eirmap.o: ${OBJDIR}/eirbase.${MOD} ${SRCDIR}/Eirene_modules/eirmap.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/eirmap.o -c ${SRCDIR}/Eirene_modules/eirmap.F

${OBJDIR}/eirsamsp.o: ${SRCDIR}/Eirene_modules/eirsamsp.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/eirsamsp.o -c ${SRCDIR}/Eirene_modules/eirsamsp.F

${OBJDIR}/ifwrite.o: ${SRCDIR}/Eirene_modules/ifwrite.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/ifwrite.o -c ${SRCDIR}/Eirene_modules/ifwrite.F

${OBJDIR}/impdns.o: ${SRCDIR}/Eirene_modules/impdns.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/impdns.o -c ${SRCDIR}/Eirene_modules/impdns.F

${OBJDIR}/impmom.o: ${OBJDIR}/impdns.${MOD} ${SRCDIR}/Eirene_modules/impmom.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/impmom.o -c ${SRCDIR}/Eirene_modules/impmom.F

${OBJDIR}/impsrc.o: ${OBJDIR}/impmom.${MOD} ${SRCDIR}/Eirene_modules/impsrc.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/impsrc.o -c ${SRCDIR}/Eirene_modules/impsrc.F

${OBJDIR}/parmmod.o: ${OBJDIR}/precision.${MOD} ${SRCDIR}/Eirene_modules/parmmod.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/parmmod.o -c ${SRCDIR}/Eirene_modules/parmmod.F

${OBJDIR}/photon.o: ${OBJDIR}/clogau.${MOD} ${OBJDIR}/czt1.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comxs.${MOD} ${SRCDIR}/Eirene_modules/photon.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/photon.o -c ${SRCDIR}/Eirene_modules/photon.F

${OBJDIR}/precision.o: ${SRCDIR}/Eirene_modules/precision.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/precision.o -c ${SRCDIR}/Eirene_modules/precision.F

${OBJDIR}/rcm.o: ${SRCDIR}/Eirene_modules/rcm.F ${MAKES}
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${OBJDEST} -o ${OBJDIR}/rcm.o -c ${SRCDIR}/Eirene_modules/rcm.F

ifneq (${MOD},o)
${OBJDIR}/b2_4to5.${MOD}: ${OBJDIR}/eirmod_parmmod.${MOD} ${OBJDIR}/braeir.${MOD} ${OBJDIR}/eirdiag.${MOD}

${OBJDIR}/b2mod_b2_to_astra.${MOD}: ${OBJDIR}/eirdiag.${MOD}

${OBJDIR}/b2mod_neutrals_namelist.${MOD}: ${OBJDIR}/parmmod.${MOD} ${OBJDIR}/braeir.${MOD} ${OBJDIR}/ceirsrt.${MOD} ${OBJDIR}/comnnl.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/eirdiag.${MOD}

${OBJDIR}/eirmod_braeir.${MOD}:
	ln -sf ${EIRDIR}/eirmod_braeir.${MOD} ${OBJDIR}

${OBJDIR}/eirmod_cinit.${MOD}:
	ln -sf ${EIRDIR}/eirmod_cinit.${MOD} ${OBJDIR}

${OBJDIR}/eirmod_comusr.${MOD}:
	ln -sf ${EIRDIR}/eirmod_comusr.${MOD} ${OBJDIR}

${OBJDIR}/eirmod_comxs.${MOD}:
	ln -sf ${EIRDIR}/eirmod_comxs.${MOD} ${OBJDIR}

${OBJDIR}/eirmod_ctrig.${MOD}:
	ln -sf ${EIRDIR}/eirmod_ctrig.${MOD} ${OBJDIR}

${OBJDIR}/eirmod_extrab25.${MOD}: ${OBJDIR}/eirmod_comxs.${MOD}
	ln -sf ${EIRDIR}/eirmod_extrab25.${MOD} ${OBJDIR}

${OBJDIR}/eirmod_parmmod.${MOD}: ${OBJDIR}/parmmod.${MOD}
	ln -sf ${OBJDIR}/parmmod.${MOD} $@

${OBJDIR}/eirmod_precision.${MOD}: ${OBJDIR}/precision.${MOD}
	ln -sf ${OBJDIR}/precision.${MOD} $@

${OBJDIR}/eirmod_mpi.${MOD}: ${OBJDIR}/comprt.${MOD} ${OBJDIR}/precision.${MOD} ${SRCDIR}/Eirene_modules/eirmod_mpi.F90 ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirmod_mpi.o -c ${SRCDIR}/Eirene_modules/eirmod_mpi.F90

${OBJDIR}/eirmod_octree.${MOD}: ${SRCDIR}/Eirene_modules/eirmod_octree.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirmod_octree.o -c ${SRCDIR}/Eirene_modules/eirmod_octree.F

${OBJDIR}/adsp.${MOD}: ${OBJDIR}/clogau.${MOD} ${OBJDIR}/comprt.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/cpes.${MOD} ${OBJDIR}/ctrcei.${MOD} ${OBJDIR}/eirmod_mpi.${MOD} ${SRCDIR}/Eirene_modules/adsp.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/adsp.o -c ${SRCDIR}/Eirene_modules/adsp.F

${OBJDIR}/amark_mod.${MOD}: ${SRCDIR}/Eirene_modules/amark_mod.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/amark_mod.o -c ${SRCDIR}/Eirene_modules/amark_mod.F

${OBJDIR}/avltree.${MOD}: ${OBJDIR}/ccona.${MOD} ${SRCDIR}/Eirene_modules/avltree.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/avltree.o -c ${SRCDIR}/Eirene_modules/avltree.F

${OBJDIR}/braeir.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/braeir.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/braeir.o -c ${SRCDIR}/Eirene_modules/braeir.F

${OBJDIR}/brascl.${MOD}: ${SRCDIR}/Eirene_modules/brascl.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/brascl.o -c ${SRCDIR}/Eirene_modules/brascl.F

${OBJDIR}/braspoi.${MOD}: ${SRCDIR}/Eirene_modules/braspoi.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/braspoi.o -c ${SRCDIR}/Eirene_modules/braspoi.F

${OBJDIR}/cadgeo.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cadgeo.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cadgeo.o -c ${SRCDIR}/Eirene_modules/cadgeo.F

${OBJDIR}/cai.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cai.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cai.o -c ${SRCDIR}/Eirene_modules/cai.F

${OBJDIR}/caprmc.${MOD}: ${OBJDIR}/cgrid.${MOD} ${OBJDIR}/comsou.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comxs.${MOD} ${OBJDIR}/ctrcei.${MOD} ${SRCDIR}/Eirene_modules/caprmc.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/caprmc.o -c ${SRCDIR}/Eirene_modules/caprmc.F

${OBJDIR}/ccflux.${MOD}: ${OBJDIR}/ctrig.${MOD} ${OBJDIR}/ctrcei.${MOD} ${OBJDIR}/cgeom.${MOD} ${OBJDIR}/ccona.${MOD} ${OBJDIR}/comusr.${MOD} ${SRCDIR}/Eirene_modules/ccflux.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ccflux.o -c ${SRCDIR}/Eirene_modules/ccflux.F

${OBJDIR}/ccona.${MOD}: ${SRCDIR}/Eirene_modules/ccona.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ccona.o -c ${SRCDIR}/Eirene_modules/ccona.F

${OBJDIR}/ccoupl.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/ccoupl.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ccoupl.o -c ${SRCDIR}/Eirene_modules/ccoupl.F

${OBJDIR}/ccrm.${MOD}: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/comxs.${MOD} ${OBJDIR}/ctrcei.${MOD} ${OBJDIR}/clogau.${MOD} ${OBJDIR}/cestim.${MOD} ${OBJDIR}/czt1.${MOD} ${OBJDIR}/comsou.${MOD} ${OBJDIR}/caprmc.${MOD} ${OBJDIR}/photon.${MOD} ${OBJDIR}/csdvi.${MOD} ${OBJDIR}/ccflux.${MOD} ${SRCDIR}/Eirene_modules/ccrm.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ccrm.o -c ${SRCDIR}/Eirene_modules/ccrm.F

${OBJDIR}/cdiprl.${MOD}: ${SRCDIR}/Eirene_modules/cdiprl.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cdiprl.o -c ${SRCDIR}/Eirene_modules/cdiprl.F

${OBJDIR}/ceirsrt.${MOD}: ${OBJDIR}/precision.${MOD} ${SRCDIR}/Eirene_modules/ceirsrt.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ceirsrt.o -c ${SRCDIR}/Eirene_modules/ceirsrt.F

${OBJDIR}/censav.${MOD}: ${SRCDIR}/Eirene_modules/censav.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/censav.o -c ${SRCDIR}/Eirene_modules/censav.F

${OBJDIR}/cestim.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cestim.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cestim.o -c ${SRCDIR}/Eirene_modules/cestim.F

${OBJDIR}/cfit.${MOD}: ${SRCDIR}/Eirene_modules/cfit.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cfit.o -c ${SRCDIR}/Eirene_modules/cfit.F

${OBJDIR}/cfplk.${MOD}: ${SRCDIR}/Eirene_modules/cfplk.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cfplk.o -c ${SRCDIR}/Eirene_modules/cfplk.F

${OBJDIR}/cgeom.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cgeom.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cgeom.o -c ${SRCDIR}/Eirene_modules/cgeom.F

${OBJDIR}/cgrid.${MOD}: ${OBJDIR}/comprt.${MOD} ${SRCDIR}/Eirene_modules/cgrid.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cgrid.o -c ${SRCDIR}/Eirene_modules/cgrid.F

${OBJDIR}/cgrptl.${MOD}: ${SRCDIR}/Eirene_modules/cgrptl.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cgrptl.o -c ${SRCDIR}/Eirene_modules/cgrptl.F

${OBJDIR}/cinit.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cinit.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cinit.o -c ${SRCDIR}/Eirene_modules/cinit.F

${OBJDIR}/clast.${MOD}: ${SRCDIR}/Eirene_modules/clast.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/clast.o -c ${SRCDIR}/Eirene_modules/clast.F

${OBJDIR}/clena.${MOD}: ${OBJDIR}/comsig.${MOD} ${SRCDIR}/Eirene_modules/clena.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/clena.o -c ${SRCDIR}/Eirene_modules/clena.F

${OBJDIR}/clgin.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/clgin.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/clgin.o -c ${SRCDIR}/Eirene_modules/clgin.F

${OBJDIR}/clmsur.${MOD}: ${SRCDIR}/Eirene_modules/clmsur.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/clmsur.o -c ${SRCDIR}/Eirene_modules/clmsur.F

${OBJDIR}/clogau.${MOD}: ${OBJDIR}/precision.${MOD} ${SRCDIR}/Eirene_modules/clogau.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/clogau.o -c ${SRCDIR}/Eirene_modules/clogau.F

${OBJDIR}/comnnl.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comnnl.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comnnl.o -c ${SRCDIR}/Eirene_modules/comnnl.F

${OBJDIR}/comprt.${MOD}: ${OBJDIR}/parmmod.${MOD} ${OBJDIR}/precision.${MOD} ${SRCDIR}/Eirene_modules/comprt.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comprt.o -c ${SRCDIR}/Eirene_modules/comprt.F

${OBJDIR}/comsig.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comsig.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comsig.o -c ${SRCDIR}/Eirene_modules/comsig.F

${OBJDIR}/comsmu.${MOD}: ${SRCDIR}/Eirene_modules/comsmu.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comsmu.o -c ${SRCDIR}/Eirene_modules/comsmu.F

${OBJDIR}/comsou.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comsou.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comsou.o -c ${SRCDIR}/Eirene_modules/comsou.F

${OBJDIR}/comspl.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comspl.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comspl.o -c ${SRCDIR}/Eirene_modules/comspl.F

${OBJDIR}/comusr.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comusr.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comusr.o -c ${SRCDIR}/Eirene_modules/comusr.F

${OBJDIR}/comxs.${MOD}: ${OBJDIR}/cupd.${MOD} ${OBJDIR}/comprt.${MOD} ${SRCDIR}/Eirene_modules/comxs.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comxs.o -c ${SRCDIR}/Eirene_modules/comxs.F

${OBJDIR}/coutau.${MOD}: ${SRCDIR}/Eirene_modules/coutau.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/coutau.o -c ${SRCDIR}/Eirene_modules/coutau.F

${OBJDIR}/cpes.${MOD}: ${OBJDIR}/comprt.${MOD} ${OBJDIR}/ctrcei.${MOD} ${OBJDIR}/eirmod_precision.${MOD} ${OBJDIR}/eirmod_mpi.${MOD} ${SRCDIR}/Eirene_modules/cpes.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cpes.o -c ${SRCDIR}/Eirene_modules/cpes.F

${OBJDIR}/cplmsk.${MOD}: ${SRCDIR}/Eirene_modules/cplmsk.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cplmsk.o -c ${SRCDIR}/Eirene_modules/cplmsk.F

${OBJDIR}/cplot.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cplot.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cplot.o -c ${SRCDIR}/Eirene_modules/cplot.F

${OBJDIR}/cpl3d.${MOD}: ${SRCDIR}/Eirene_modules/cpl3d.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cpl3d.o -c ${SRCDIR}/Eirene_modules/cpl3d.F

${OBJDIR}/cpolyg.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cpolyg.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cpolyg.o -c ${SRCDIR}/Eirene_modules/cpolyg.F

${OBJDIR}/crand.${MOD}: ${SRCDIR}/Eirene_modules/crand.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/crand.o -c ${SRCDIR}/Eirene_modules/crand.F

${OBJDIR}/cref.${MOD}: ${SRCDIR}/Eirene_modules/cref.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cref.o -c ${SRCDIR}/Eirene_modules/cref.F

${OBJDIR}/crech.${MOD}: ${SRCDIR}/Eirene_modules/crech.F ${OBJDIR}/precision.${MOD} ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/crech.o -c ${SRCDIR}/Eirene_modules/crech.F

${OBJDIR}/crefmod.${MOD}: ${SRCDIR}/Eirene_modules/crefmod.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/crefmod.o -c ${SRCDIR}/Eirene_modules/crefmod.F

${OBJDIR}/csdvi.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/csdvi.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/csdvi.o -c ${SRCDIR}/Eirene_modules/csdvi.F

${OBJDIR}/csdvi_bgk.${MOD}: ${SRCDIR}/Eirene_modules/csdvi_bgk.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/csdvi_bgk.o -c ${SRCDIR}/Eirene_modules/csdvi_bgk.F

${OBJDIR}/csdvi_cop.${MOD}: ${SRCDIR}/Eirene_modules/csdvi_cop.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/csdvi_cop.o -c ${SRCDIR}/Eirene_modules/csdvi_cop.F

${OBJDIR}/cspars.${MOD}: ${SRCDIR}/Eirene_modules/cspars.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cspars.o -c ${SRCDIR}/Eirene_modules/cspars.F

${OBJDIR}/cspei.${MOD}: ${SRCDIR}/Eirene_modules/cspei.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cspei.o -c ${SRCDIR}/Eirene_modules/cspei.F

${OBJDIR}/cspez.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cspez.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cspez.o -c ${SRCDIR}/Eirene_modules/cspez.F

${OBJDIR}/cstep.${MOD}: ${SRCDIR}/Eirene_modules/cstep.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cstep.o -c ${SRCDIR}/Eirene_modules/cstep.F

${OBJDIR}/ctetra.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/ctetra.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ctetra.o -c ${SRCDIR}/Eirene_modules/ctetra.F

${OBJDIR}/ctext.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/ctext.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ctext.o -c ${SRCDIR}/Eirene_modules/ctext.F

${OBJDIR}/ctrcei.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/ctrcei.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ctrcei.o -c ${SRCDIR}/Eirene_modules/ctrcei.F

${OBJDIR}/ctrig.${MOD}: ${OBJDIR}/cgrid.${MOD} ${SRCDIR}/Eirene_modules/ctrig.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ctrig.o -c ${SRCDIR}/Eirene_modules/ctrig.F

${OBJDIR}/ctsurf.${MOD}: ${SRCDIR}/Eirene_modules/ctsurf.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ctsurf.o -c ${SRCDIR}/Eirene_modules/ctsurf.F

${OBJDIR}/cupd.${MOD}: ${OBJDIR}/comsig.${MOD} ${SRCDIR}/Eirene_modules/cupd.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cupd.o -c ${SRCDIR}/Eirene_modules/cupd.F

${OBJDIR}/czt1.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/czt1.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/czt1.o -c ${SRCDIR}/Eirene_modules/czt1.F

${OBJDIR}/eirbase.${MOD}: ${SRCDIR}/Eirene_modules/eirbase.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirbase.o -c ${SRCDIR}/Eirene_modules/eirbase.F

${OBJDIR}/eirbra.${MOD}: ${SRCDIR}/Eirene_modules/eirbra.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirbra.o -c ${SRCDIR}/Eirene_modules/eirbra.F

${OBJDIR}/eircolsp.${MOD}: ${SRCDIR}/Eirene_modules/eircolsp.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eircolsp.o -c ${SRCDIR}/Eirene_modules/eircolsp.F

${OBJDIR}/eirdiag.${MOD}: ${OBJDIR}/braeir.${MOD} ${OBJDIR}/clgin.${MOD} ${OBJDIR}/ccoupl.${MOD} ${SRCDIR}/Eirene_modules/eirdiag.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirdiag.o -c ${SRCDIR}/Eirene_modules/eirdiag.F

${OBJDIR}/eirgrid.${MOD}: ${SRCDIR}/Eirene_modules/eirgrid.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirgrid.o -c ${SRCDIR}/Eirene_modules/eirgrid.F

${OBJDIR}/eirgrid_lib.${MOD}: ${OBJDIR}/eirmap.${MOD} ${SRCDIR}/Eirene_modules/eirgrid_lib.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirgrid_lib.o -c ${SRCDIR}/Eirene_modules/eirgrid_lib.F

${OBJDIR}/eirmap.${MOD}: ${OBJDIR}/eirbase.${MOD} ${SRCDIR}/Eirene_modules/eirmap.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirmap.o -c ${SRCDIR}/Eirene_modules/eirmap.F

${OBJDIR}/eirsamsp.${MOD}: ${SRCDIR}/Eirene_modules/eirsamsp.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirsamsp.o -c ${SRCDIR}/Eirene_modules/eirsamsp.F

${OBJDIR}/ifwrite.${MOD}: ${SRCDIR}/Eirene_modules/ifwrite.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ifwrite.o -c ${SRCDIR}/Eirene_modules/ifwrite.F

${OBJDIR}/impdns.${MOD}: ${SRCDIR}/Eirene_modules/impdns.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/impdns.o -c ${SRCDIR}/Eirene_modules/impdns.F

${OBJDIR}/impmom.${MOD}: ${OBJDIR}/impdns.${MOD} ${SRCDIR}/Eirene_modules/impmom.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/impmom.o -c ${SRCDIR}/Eirene_modules/impmom.F

${OBJDIR}/impsrc.${MOD}: ${OBJDIR}/impmom.${MOD} ${SRCDIR}/Eirene_modules/impsrc.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/impsrc.o -c ${SRCDIR}/Eirene_modules/impsrc.F

${OBJDIR}/parmmod.${MOD}: ${OBJDIR}/precision.${MOD} ${SRCDIR}/Eirene_modules/parmmod.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/parmmod.o -c ${SRCDIR}/Eirene_modules/parmmod.F

${OBJDIR}/photon.${MOD}: ${OBJDIR}/clogau.${MOD} ${OBJDIR}/czt1.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comxs.${MOD} ${SRCDIR}/Eirene_modules/photon.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/photon.o -c ${SRCDIR}/Eirene_modules/photon.F

${OBJDIR}/precision.${MOD}: ${SRCDIR}/Eirene_modules/precision.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/precision.o -c ${SRCDIR}/Eirene_modules/precision.F

${OBJDIR}/rcm.${MOD}: ${SRCDIR}/Eirene_modules/rcm.F ${MAKES}
	@[ -e $@ ] && rm $@ || echo > /dev/null
	${DBLFC} ${DBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${SOLPSINCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/rcm.o -c ${SRCDIR}/Eirene_modules/rcm.F

endif

${OBJDIR}/libb2_solps4.a: ${MD4OBJS} ${SB4OBJS} ${SE4OBJS}
	${BLD} $@ $?

${OBJDIR}/libb2_solps5.a: ${MD5OBJS} ${SR5OBJS}
	${BLD} $@ $?

depend: ${BASEDIR}/LISTOBJ ${FOBJS:.o=.F} ${F90OBJS:.o=.F90} ${EXELIST:.o=.F}
	@`which makedepend` -p'$${OBJDIR}/' ${DEFINES} -f- ${SOLPSINCLUDE} $^ | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' | \
        sed 's,: ${SOLPSTOP},: $${SOLPSTOP},' > ${OBJDIR}/dependencies
ifneq (${MOD},o)
	@`which makedepend` -p'$${OBJDIR}/' ${DEFINES} -f- ${SOLPSINCLUDE} $^ -o.${MOD} | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' | \
        sed 's,: ${SOLPSTOP},: $${SOLPSTOP},' >> ${OBJDIR}/dependencies
endif
	@egrep -ai '^ *use ' ${FFLIST} | grep -v 'IGNORE' | tr , ' ' | awk '{sub("\\.F90:",".o:",$$1);sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
ifneq (${MOD},o)
	@egrep -ai '^ *use ' ${MODLIST} | grep -v 'IGNORE' | tr , ' ' | awk '{sub("\\.F90:",".${MOD}:",$$1);sub("\\.F:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
endif

${BASEDIR}/TAGS: tags

tags:
	rm -f ${BASEDIR}/TAGS ; ${MAKETAGS} ${BASEDIR}/TAGS ${TAGSLIST} || touch ${BASEDIR}/TAGS

clean:
	rm -f ${OBJDIR}/*.f ${OBJDIR}/*.f90 ${OBJDIR}/*.o ${OBJDIR}/*.${MOD} ${OBJDIR}/*.a ${OBJDIR}/*.exe
	rm -Rf ${SRCDIR}/B2_include
	rm -Rf ${SRCDIR}/B2_include.local
	rm -Rf ${SRCDIR}/Eirene_modules
	rm -Rf ${SRCDIR}/solps4_B2
	rm -Rf ${SRCDIR}/solps4_Eirene

listobj:
	@rm -f ${BASEDIR}/LISTOBJ; touch ${BASEDIR}/LISTOBJ; l="FOBJS ="; \
	for d in `echo "${VPATH}" | tr : \ `; do \
		l="$$l `(cd $$d > /dev/null; echo *.[Ff])`"; \
	done; \
	E="-e 's/ \*.\[Ff\]90//g' -e 's/\.[Ff]90/\.o/g' -e 's/\.[Ff]/\.o/g'" ; for f in ${EXCLUDELIST}; do \
		E="$$E -e 's/ $$f//'"; \
	done; \
	echo "$$l" | eval sed "$$E" > ${BASEDIR}/LISTOBJ
	@ll="F90OBJS ="; \
	for d in `echo "${VPATH}" | tr : \ `; do \
		ll="$$ll `(cd $$d > /dev/null; echo *.[Ff]90)`"; \
	done; \
	E="-e 's/ \*.\[Ff\]90//g' -e 's/\.[Ff]90/\.o/g'" ; for f in ${EXCLUDELIST}; do \
		E="$$E -e 's/ $$f//'"; \
	done; \
	echo "$$ll" | eval sed "$$E" >> ${BASEDIR}/LISTOBJ

links: local
	@[ -L ${SRCDIR}/B2_include.local ] && rm -Rf ${SRCDIR}/B2_include.local || echo > /dev/null
ifeq ($(shell [ -d ${SOLPS4}/src/Braams/b2/include.local ] && echo yes || echo no ),yes)
	-mkdir -p ${SRCDIR}/B2_include.local
	@[ -r `which lndir` ] && ( lndir ${SOLPS4}/src/Braams/b2/include.local ${SRCDIR}/B2_include.local >& /dev/null ) || ln -sf ${SOLPS4}/src/Braams/b2/include.local/* ${SRCDIR}/B2_include.local/
endif
	@[ -L ${SRCDIR}/B2_include ] && rm -Rf ${SRCDIR}/B2_include || echo > /dev/null
	-mkdir -p ${SRCDIR}/B2_include
	@[ -r `which lndir` ] && ( lndir ${SOLPS4}/src/Braams/b2/include ${SRCDIR}/B2_include >& /dev/null ) || ln -sf ${SOLPS4}/src/Braams/b2/include/* ${SRCDIR}/B2_include/
ifdef LD_NETCDF
	@rm -f ${SRCDIR}/B2_include/netcdf.inc
endif
	@[ -L ${SRCDIR}/Eirene_modules ] && rm -Rf ${SRCDIR}/Eirene_modules || echo > /dev/null
	-mkdir -p ${SRCDIR}/Eirene_modules
	@[ -r `which lndir` ] && ( lndir ${SOLPS4}/src/Eirene/src/modules ${SRCDIR}/Eirene_modules >& /dev/null ) || ln -sf ${SOLPS4}/src/Eirene/src/modules/* ${SRCDIR}/Eirene_modules/
	-mkdir -p ${SRCDIR}/solps4_B2
	@cat B2_4.3.source_files | sed -e 's:[^ ]*/: ${SRCDIR}/solps4_B2/:' | paste B2_4.3.source_files - | sed -e "s:^:ln -sf ${SOLPS4}/src/Braams/b2/src/:" > B2_links
	. ./B2_links
	@rm B2_links
	-mkdir -p ${SRCDIR}/solps4_Eirene
	@cat Eirene_4.3.source_files | sed -e 's:[^ ]*/: ${SRCDIR}/solps4_Eirene/:' | paste Eirene_4.3.source_files - | sed -e "s:^:ln -sf ${SOLPS4}/src/Eirene/src/:" > Eirene_links
	. ./Eirene_links
	@rm Eirene_links

local:
	@[ -L ${SRC5LOCAL} ] || ln -sf ${SOLPSTOP}/modules/B2.5/src.local ${SRC5LOCAL}
	@[ -L ${INC5LOCAL} ] || ln -sf ${SOLPSTOP}/modules/B2.5/src/include.local ${INC5LOCAL}
	@[ -L ${B2M5LOCAL} ] || ln -sf ${SOLPSTOP}/modules/B2.5/src/modules.local ${B2M5LOCAL}

${BASEDIR}/LISTOBJ: listobj

${OBJDIR}/dependencies: ${SRCDIR}/B2.5_modules/.new_modules
ifeq ($(shell [ -d ${OBJDIR} ] && echo yes || echo no ),no)
	-mkdir -p ${OBJDIR}
endif
	printf '# Dummy dependencies file for solps4-5\n' > ${OBJDIR}/dependencies
	${MAKE} links
	${MAKE} tags
	${MAKE} listobj
	${MAKE} depend

$(shell [ -s ${OBJDIR}/dependencies ] || rm -f ${OBJDIR}/dependencies)
include ${OBJDIR}/dependencies
ifeq ($(shell [ -e ${S45DIR}/config/dependencies.local ] && echo yes || echo no ),yes)
include ${S45DIR}/config/dependencies.local
endif

echo:
	@echo VPATH=${VPATH}
	@echo MOD4LES=${MOD4LES}
	@echo MOD5LES=${MOD5LES}
#	@echo MODOBJS=${MODOBJS}
	@echo MD5OBJS=${MD5OBJS}
	@echo MD4OBJS=${MD5OBJS}
	@echo SB4OBJS=${SB4OBJS}
	@echo SE4OBJS=${SE4OBJS}
#	@echo SR5OBJS=${SR5OBJS}
	@echo FFLIST=${FFLIST}
	@echo MODLIST=${MODLIST}
	@echo SOLPSINCLUDE=${SOLPSINCLUDE}

