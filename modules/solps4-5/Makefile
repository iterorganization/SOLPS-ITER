# Test whether necessary environment variables are defined; if not, exit
ifndef HOST_NAME
$(error HOST_NAME not defined)
endif
ifndef COMPILER
$(error COMPILER not defined)
endif

# Extension for OBJDIR if debug option is used
ifdef SOLPS_DEBUG
EXT_DEBUG = .debug
endif

TOOL_CHAIN = ${HOST_NAME}.${COMPILER}${EXT_DEBUG}

SRCDIR = ${SOLPSTOP}/modules/solps4-5/src
S45DIR = ${SOLPSTOP}/modules/solps4-5
EIRDIR = ${SOLPSTOP}/modules/Eirene/builds/couple_SOLPS-ITER.${TOOL_CHAIN}
B2BDIR = ${SOLPSTOP}/modules/B2.5/builds/couple_Eirene.${TOOL_CHAIN}
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
INCLUDE = -I${SRC4LOCAL}
TAGSLIST = ${SRC4LOCAL}/*.F
VPATH = ${SRC4LOCAL}:
else
INCLUDE =
TAGSLIST =
VPATH = 
endif
ifeq ($(shell [ -d ${SRC5LOCAL} ] && echo yes || echo no ),yes)
INCLUDE += -I${SRC5LOCAL}
TAGSLIST += ${SRC5LOCAL}/*.F
VPATH += ${SRC5LOCAL}:
endif
ifeq ($(shell [ -d ${INC4LOCAL} ] && echo yes || echo no ),yes)
INCLUDE += -I${INC4LOCAL}
TAGSLIST += ${INC4LOCAL}/*.h
VPATH += ${INC4LOCAL}:
endif
ifeq ($(shell [ -d ${INC5LOCAL} ] && echo yes || echo no ),yes)
INCLUDE += -I${INC5LOCAL}
TAGSLIST += ${INC5LOCAL}/*.h
VPATH += ${INC5LOCAL}:
endif
ifeq ($(shell [ -d ${B2M5LOCAL} ] && echo yes || echo no ),yes)
INCLUDE += -I${B2M5LOCAL}
TAGSLIST += ${B2M5LOCAL}/*.F
VPATH += ${B2M5LOCAL}:
endif
ifeq ($(shell [ -d ${EIRMLOCAL} ] && echo yes || echo no ),yes)
INCLUDE += -I${EIRMLOCAL}
TAGSLIST += ${EIRMLOCAL}/*.F
VPATH += ${EIRMLOCAL}:
endif
INCLUDE += -I${SRCDIR}/B2.5_include -I${SRCDIR}/B2.5_commons -I${SRCDIR}/B2_include -I${SRCDIR}/Eirene_commons -I${MDSPLUS_DIR}/include
TAGSLIST += ${SRCDIR}/*_commons/*.[hH] ${SRCDIR}/*/*.F ${SRCDIR}/*.F
VPATH += ${SRCDIR}/B2.5_modules:${SRCDIR}:${SRCDIR}/solps4_B2:${SRCDIR}/solps4_Eirene:${SRCDIR}/solps5

include ${S45DIR}/config/compile
ifeq ($(shell [ -e ${S45DIR}/config/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
include ${S45DIR}/config/config.${HOST_NAME}.${COMPILER}.local
endif
SOLPS4 ?= ${SOLPSTOP}/../[sS][oO][lL][pP][sS]4.3
ifeq ($(shell [ -d ${SOLPS4} ] && echo yes || echo no ),no)
$(error Invalid SOLPS4 directory address)
endif

ifeq ($(shell [ -e ${BASEDIR}/LISTOBJ ] && echo yes || echo no ),yes)
include ${BASEDIR}/LISTOBJ
endif

PROG_XR = b2sxdr.exe
MOD4LES = ${patsubst ${SRCDIR}/Eirene_modules/%.F,%.o,${shell echo ${SRCDIR}/Eirene_modules/*.F}}
MOD5LES = ${patsubst ${SRCDIR}/B2.5_modules/%.F,%.o,${shell echo ${SRCDIR}/B2.5_modules/*.F}}
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
ALLOBJS = ${OBJS:%.o=${OBJDIR}/%.o}
FFLIST  = ${SRC5LOCAL}/*.F ${SRC4LOCAL}/*.F 
FFLIST  = ${shell echo ${SRCDIR}/*/*.H ${SRCDIR}/*.F ${SRCDIR}/solps5/*.F ${SRCDIR}/B2.5_modules/*.F ${SRCDIR}/solps4_B2/*.F}
ifeq ($(shell [ -d ${SRC4LOCAL} ] && echo yes || echo no ),yes)
FFLIST  += ${shell echo ${SRC4LOCAL}/*.F}
endif
ifeq ($(shell [ -d ${SRC5LOCAL} ] && echo yes || echo no ),yes)
FFLIST  += ${shell echo ${SRC5LOCAL}/*.F}
endif
MODLIST += ${shell echo ${SRCDIR}/B2.5_modules/*.F ${SRCDIR}/b2_4to5.F}

EXCLUDELIST = ${patsubst %.exe, %.o, ${PROG_XR}}
XREXE = ${patsubst %.exe, ${OBJDIR}/%.exe, ${PROG_XR}}
XROBJ = ${patsubst %.exe, ${OBJDIR}/%.o, ${PROG_XR}}

XREXTRA=${OBJDIR}/b2_4to5.o ${OBJDIR}/xerset_5.o ${OBJDIR}/myblass.o
MNEXTRA=

.PHONY: DEFAULT ALL clean depend listobj tags links

ALL: links ${XREXE}

DEFAULT: ${XREXE}

b2sxdr: ${XREXE}

${XREXE}: ${XROBJ} ${XREXTRA} ${OBJDIR}/libb2_solps5.a ${OBJDIR}/libb2_solps4.a ${MNEXTRA} 
	${LD} ${LDOPTS} $^ -o $@ ${LDLIBES} ${LCPP} ${LDOPTSend}

${OBJDIR}/allocate_modules.o: ${OBJDIR}/cadgeo.${MOD} ${OBJDIR}/cai.${MOD} ${OBJDIR}/ccflux.${MOD} ${OBJDIR}/ccona.${MOD} ${OBJDIR}/cestim.${MOD} ${OBJDIR}/cgeom.${MOD} ${OBJDIR}/clast.${MOD} ${OBJDIR}/clena.${MOD} ${OBJDIR}/clogau.${MOD} ${OBJDIR}/comnnl.${MOD} ${OBJDIR}/comspl.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comxs.${MOD} ${OBJDIR}/coutau.${MOD} ${OBJDIR}/cpes.${MOD} ${OBJDIR}/cplot.${MOD} ${OBJDIR}/cpolyg.${MOD} ${OBJDIR}/cref.${MOD} ${OBJDIR}/crefmod.${MOD} ${OBJDIR}/csdvi.${MOD} ${OBJDIR}/csdvi_bgk.${MOD} ${OBJDIR}/csdvi_cop.${MOD} ${OBJDIR}/cspei.${MOD} ${OBJDIR}/cspez.${MOD} ${OBJDIR}/cstep.${MOD} ${OBJDIR}/ctetra.${MOD} ${OBJDIR}/ctext.${MOD} ${OBJDIR}/cupd.${MOD} ${OBJDIR}/czt1.${MOD} ${OBJDIR}/eirbra.${MOD} ${OBJDIR}/photon.${MOD}

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

${OBJDIR}/if0prm.o: ${OBJDIR}/cinit.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comprt.${MOD}

${OBJDIR}/impneut_interface.o: ${OBJDIR}/impdns.${MOD} ${OBJDIR}/impmom.${MOD} ${OBJDIR}/impsrc.${MOD}

${OBJDIR}/infcop.o: ${OBJDIR}/brascl.${MOD} ${OBJDIR}/braspoi.${MOD} ${OBJDIR}/ccona.${MOD} ${OBJDIR}/csdvi.${MOD} ${OBJDIR}/cspei.${MOD} ${OBJDIR}/cstep.${MOD} ${OBJDIR}/coutau.${MOD} ${OBJDIR}/eirbra.${MOD} ${OBJDIR}/ifwrite.${MOD} ${OBJDIR}/impdns.${MOD}

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

${OBJDIR}/wneutral_fluxes.o: ${OBJDIR}/amark_mod.${MOD} ${OBJDIR}/ccona.${MOD} ${OBJDIR}/cestim.${MOD}

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

ifneq (${MOD},o)
${OBJDIR}/b2_4to5.o: ${OBJDIR}/eirmod_parmmod.${MOD} ${OBJDIR}/braeir.${MOD} ${OBJDIR}/eirdiag.${MOD}

${OBJDIR}/b2mod_b2_to_astra.o: ${OBJDIR}/eirmod_extrab25.${MOD} 

${OBJDIR}/b2mod_neutrals_namelist.o: ${OBJDIR}/eirmod_parmmod.${MOD} ${OBJDIR}/braeir.${MOD} ${OBJDIR}/eirdiag.${MOD}

${OBJDIR}/eirmod_parmmod.o: 
	ln -sf ${OBJDIR}/parmmod.o $@

${OBJDIR}/eirmod_precision.o: 
	ln -sf ${OBJDIR}/precision.o $@

${OBJDIR}/eirmod_braeir.o: 
	ln -sf ${EIRDIR}/eirmod_braeir.o ${OBJDIR}

${OBJDIR}/eirmod_ctrig.o:
	ln -sf ${EIRDIR}/eirmod_ctrig.o ${OBJDIR}

${OBJDIR}/eirmod_extrab25.o: 
	ln -sf ${EIRDIR}/eirmod_extrab25.o ${OBJDIR}

${OBJDIR}/eirmod_octree.o: ${SRCDIR}/Eirene_modules/eirmod_octree.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/eirmod_octree.o -c ${SRCDIR}/Eirene_modules/eirmod_octree.F

${OBJDIR}/adsp.o: ${OBJDIR}/cpes.${MOD} ${SRCDIR}/Eirene_modules/adsp.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/adsp.o -c ${SRCDIR}/Eirene_modules/adsp.F

${OBJDIR}/amark_mod.o: ${SRCDIR}/Eirene_modules/amark_mod.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/amark_mod.o -c ${SRCDIR}/Eirene_modules/amark_mod.F

${OBJDIR}/avltree.o: ${OBJDIR}/ccona.${MOD} ${SRCDIR}/Eirene_modules/avltree.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/avltree.o -c ${SRCDIR}/Eirene_modules/avltree.F

${OBJDIR}/braeir.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/braeir.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/braeir.o -c ${SRCDIR}/Eirene_modules/braeir.F

${OBJDIR}/brascl.o: ${SRCDIR}/Eirene_modules/brascl.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/brascl.o -c ${SRCDIR}/Eirene_modules/brascl.F

${OBJDIR}/braspoi.o: ${SRCDIR}/Eirene_modules/braspoi.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/braspoi.o -c ${SRCDIR}/Eirene_modules/braspoi.F

${OBJDIR}/cadgeo.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cadgeo.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cadgeo.o -c ${SRCDIR}/Eirene_modules/cadgeo.F

${OBJDIR}/cai.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cai.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cai.o -c ${SRCDIR}/Eirene_modules/cai.F

${OBJDIR}/caprmc.o: ${OBJDIR}/cgrid.${MOD} ${OBJDIR}/comsou.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comxs.${MOD} ${OBJDIR}/ctrcei.${MOD} ${SRCDIR}/Eirene_modules/caprmc.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/caprmc.o -c ${SRCDIR}/Eirene_modules/caprmc.F

${OBJDIR}/ccflux.o: ${OBJDIR}/ctrig.${MOD} ${OBJDIR}/ctrcei.${MOD} ${OBJDIR}/cgeom.${MOD} ${OBJDIR}/ccona.${MOD} ${OBJDIR}/comusr.${MOD} ${SRCDIR}/Eirene_modules/ccflux.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/ccflux.o -c ${SRCDIR}/Eirene_modules/ccflux.F

${OBJDIR}/ccona.o: ${SRCDIR}/Eirene_modules/ccona.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/ccona.o -c ${SRCDIR}/Eirene_modules/ccona.F

${OBJDIR}/ccoupl.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/ccoupl.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/ccoupl.o -c ${SRCDIR}/Eirene_modules/ccoupl.F

${OBJDIR}/ccrm.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/comxs.${MOD} ${OBJDIR}/ctrcei.${MOD} ${OBJDIR}/clogau.${MOD} ${OBJDIR}/cestim.${MOD} ${OBJDIR}/czt1.${MOD} ${OBJDIR}/comsou.${MOD} ${OBJDIR}/caprmc.${MOD} ${OBJDIR}/photon.${MOD} ${OBJDIR}/csdvi.${MOD} ${OBJDIR}/ccflux.${MOD} ${SRCDIR}/Eirene_modules/ccrm.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/ccrm.o -c ${SRCDIR}/Eirene_modules/ccrm.F

${OBJDIR}/cdiprl.o: ${SRCDIR}/Eirene_modules/cdiprl.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cdiprl.o -c ${SRCDIR}/Eirene_modules/cdiprl.F

${OBJDIR}/ceirsrt.o: ${SRCDIR}/Eirene_modules/ceirsrt.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/ceirsrt.o -c ${SRCDIR}/Eirene_modules/ceirsrt.F

${OBJDIR}/censav.o: ${SRCDIR}/Eirene_modules/censav.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/censav.o -c ${SRCDIR}/Eirene_modules/censav.F

${OBJDIR}/cestim.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cestim.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cestim.o -c ${SRCDIR}/Eirene_modules/cestim.F

${OBJDIR}/cfit.o: ${SRCDIR}/Eirene_modules/cfit.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cfit.o -c ${SRCDIR}/Eirene_modules/cfit.F

${OBJDIR}/cfplk.o: ${SRCDIR}/Eirene_modules/cfplk.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cfplk.o -c ${SRCDIR}/Eirene_modules/cfplk.F

${OBJDIR}/cgeom.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cgeom.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cgeom.o -c ${SRCDIR}/Eirene_modules/cgeom.F

${OBJDIR}/cgrid.o: ${OBJDIR}/comprt.${MOD} ${SRCDIR}/Eirene_modules/cgrid.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cgrid.o -c ${SRCDIR}/Eirene_modules/cgrid.F

${OBJDIR}/cgrptl.o: ${SRCDIR}/Eirene_modules/cgrptl.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cgrptl.o -c ${SRCDIR}/Eirene_modules/cgrptl.F

${OBJDIR}/cinit.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cinit.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cinit.o -c ${SRCDIR}/Eirene_modules/cinit.F

${OBJDIR}/clast.o: ${SRCDIR}/Eirene_modules/clast.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/clast.o -c ${SRCDIR}/Eirene_modules/clast.F

${OBJDIR}/clena.o: ${OBJDIR}/comsig.${MOD} ${SRCDIR}/Eirene_modules/clena.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/clena.o -c ${SRCDIR}/Eirene_modules/clena.F

${OBJDIR}/clgin.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/clgin.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/clgin.o -c ${SRCDIR}/Eirene_modules/clgin.F

${OBJDIR}/clmsur.o: ${SRCDIR}/Eirene_modules/clmsur.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/clmsur.o -c ${SRCDIR}/Eirene_modules/clmsur.F

${OBJDIR}/clogau.o: ${SRCDIR}/Eirene_modules/clogau.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/clogau.o -c ${SRCDIR}/Eirene_modules/clogau.F

${OBJDIR}/comnnl.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comnnl.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/comnnl.o -c ${SRCDIR}/Eirene_modules/comnnl.F

${OBJDIR}/comprt.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comprt.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/comprt.o -c ${SRCDIR}/Eirene_modules/comprt.F

${OBJDIR}/comsig.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comsig.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/comsig.o -c ${SRCDIR}/Eirene_modules/comsig.F

${OBJDIR}/comsmu.o: ${SRCDIR}/Eirene_modules/comsmu.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/comsmu.o -c ${SRCDIR}/Eirene_modules/comsmu.F

${OBJDIR}/comsou.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comsou.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/comsou.o -c ${SRCDIR}/Eirene_modules/comsou.F

${OBJDIR}/comspl.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comspl.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/comspl.o -c ${SRCDIR}/Eirene_modules/comspl.F

${OBJDIR}/comusr.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comusr.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/comusr.o -c ${SRCDIR}/Eirene_modules/comusr.F

${OBJDIR}/comxs.o: ${OBJDIR}/cupd.${MOD} ${OBJDIR}/comprt.${MOD} ${SRCDIR}/Eirene_modules/comxs.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/comxs.o -c ${SRCDIR}/Eirene_modules/comxs.F

${OBJDIR}/coutau.o: ${SRCDIR}/Eirene_modules/coutau.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/coutau.o -c ${SRCDIR}/Eirene_modules/coutau.F

${OBJDIR}/cpes.o: ${OBJDIR}/ctrcei.${MOD} ${OBJDIR}/eirmod_precision.${MOD} ${SRCDIR}/Eirene_modules/cpes.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cpes.o -c ${SRCDIR}/Eirene_modules/cpes.F

${OBJDIR}/cplmsk.o: ${SRCDIR}/Eirene_modules/cplmsk.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cplmsk.o -c ${SRCDIR}/Eirene_modules/cplmsk.F

${OBJDIR}/cplot.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cplot.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cplot.o -c ${SRCDIR}/Eirene_modules/cplot.F

${OBJDIR}/cpl3d.o: ${SRCDIR}/Eirene_modules/cpl3d.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cpl3d.o -c ${SRCDIR}/Eirene_modules/cpl3d.F

${OBJDIR}/cpolyg.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cpolyg.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cpolyg.o -c ${SRCDIR}/Eirene_modules/cpolyg.F

${OBJDIR}/crand.o: ${SRCDIR}/Eirene_modules/crand.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/crand.o -c ${SRCDIR}/Eirene_modules/crand.F

${OBJDIR}/crech.o: ${SRCDIR}/Eirene_modules/crech.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/crech.o -c ${SRCDIR}/Eirene_modules/crech.F

${OBJDIR}/cref.o: ${SRCDIR}/Eirene_modules/cref.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cref.o -c ${SRCDIR}/Eirene_modules/cref.F

${OBJDIR}/crefmod.o: ${SRCDIR}/Eirene_modules/crefmod.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/crefmod.o -c ${SRCDIR}/Eirene_modules/crefmod.F

${OBJDIR}/csdvi.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/csdvi.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/csdvi.o -c ${SRCDIR}/Eirene_modules/csdvi.F

${OBJDIR}/csdvi_bgk.o: ${SRCDIR}/Eirene_modules/csdvi_bgk.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/csdvi_bgk.o -c ${SRCDIR}/Eirene_modules/csdvi_bgk.F

${OBJDIR}/csdvi_cop.o: ${SRCDIR}/Eirene_modules/csdvi_cop.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/csdvi_cop.o -c ${SRCDIR}/Eirene_modules/csdvi_cop.F

${OBJDIR}/cspars.o: ${SRCDIR}/Eirene_modules/cspars.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cspars.o -c ${SRCDIR}/Eirene_modules/cspars.F

${OBJDIR}/cspei.o: ${SRCDIR}/Eirene_modules/cspei.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cspei.o -c ${SRCDIR}/Eirene_modules/cspei.F

${OBJDIR}/cspez.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cspez.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cspez.o -c ${SRCDIR}/Eirene_modules/cspez.F

${OBJDIR}/cstep.o: ${SRCDIR}/Eirene_modules/cstep.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cstep.o -c ${SRCDIR}/Eirene_modules/cstep.F

${OBJDIR}/ctetra.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/ctetra.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/ctetra.o -c ${SRCDIR}/Eirene_modules/ctetra.F

${OBJDIR}/ctext.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/ctext.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/ctext.o -c ${SRCDIR}/Eirene_modules/ctext.F

${OBJDIR}/ctrcei.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/ctrcei.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/ctrcei.o -c ${SRCDIR}/Eirene_modules/ctrcei.F

${OBJDIR}/ctrig.o: ${OBJDIR}/cgrid.${MOD} ${SRCDIR}/Eirene_modules/ctrig.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/ctrig.o -c ${SRCDIR}/Eirene_modules/ctrig.F

${OBJDIR}/ctsurf.o: ${SRCDIR}/Eirene_modules/ctsurf.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/ctsurf.o -c ${SRCDIR}/Eirene_modules/ctsurf.F

${OBJDIR}/cupd.o: ${OBJDIR}/comsig.${MOD} ${SRCDIR}/Eirene_modules/cupd.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cupd.o -c ${SRCDIR}/Eirene_modules/cupd.F

${OBJDIR}/czt1.o: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/czt1.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/czt1.o -c ${SRCDIR}/Eirene_modules/czt1.F

${OBJDIR}/eirbase.o: ${SRCDIR}/Eirene_modules/eirbase.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/eirbase.o -c ${SRCDIR}/Eirene_modules/eirbase.F

${OBJDIR}/eirbra.o: ${SRCDIR}/Eirene_modules/eirbra.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/eirbra.o -c ${SRCDIR}/Eirene_modules/eirbra.F

${OBJDIR}/eircolsp.o: ${SRCDIR}/Eirene_modules/eircolsp.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/eircolsp.o -c ${SRCDIR}/Eirene_modules/eircolsp.F

${OBJDIR}/eirdiag.o: ${OBJDIR}/clgin.${MOD} ${OBJDIR}/ccoupl.${MOD} ${SRCDIR}/Eirene_modules/eirdiag.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/eirdiag.o -c ${SRCDIR}/Eirene_modules/eirdiag.F

${OBJDIR}/eirgrid.o: ${SRCDIR}/Eirene_modules/eirgrid.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/eirgrid.o -c ${SRCDIR}/Eirene_modules/eirgrid.F

${OBJDIR}/eirgrid_lib.o: ${OBJDIR}/eirmap.${MOD} ${SRCDIR}/Eirene_modules/eirgrid_lib.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/eirgrid_lib.o -c ${SRCDIR}/Eirene_modules/eirgrid_lib.F

${OBJDIR}/eirmap.o: ${OBJDIR}/eirbase.${MOD} ${SRCDIR}/Eirene_modules/eirmap.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/eirmap.o -c ${SRCDIR}/Eirene_modules/eirmap.F

${OBJDIR}/eirsamsp.o: ${SRCDIR}/Eirene_modules/eirsamsp.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/eirsamsp.o -c ${SRCDIR}/Eirene_modules/eirsamsp.F

${OBJDIR}/ifwrite.o: ${SRCDIR}/Eirene_modules/ifwrite.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/ifwrite.o -c ${SRCDIR}/Eirene_modules/ifwrite.F

${OBJDIR}/impdns.o: ${SRCDIR}/Eirene_modules/impdns.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/impdns.o -c ${SRCDIR}/Eirene_modules/impdns.F

${OBJDIR}/impmom.o: ${OBJDIR}/impdns.${MOD} ${SRCDIR}/Eirene_modules/impmom.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/impmom.o -c ${SRCDIR}/Eirene_modules/impmom.F

${OBJDIR}/impsrc.o: ${OBJDIR}/impmom.${MOD} ${SRCDIR}/Eirene_modules/impsrc.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/impsrc.o -c ${SRCDIR}/Eirene_modules/impsrc.F

${OBJDIR}/parmmod.o: ${OBJDIR}/precision.${MOD} ${SRCDIR}/Eirene_modules/parmmod.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/parmmod.o -c ${SRCDIR}/Eirene_modules/parmmod.F

${OBJDIR}/photon.o: ${OBJDIR}/clogau.${MOD} ${OBJDIR}/czt1.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comxs.${MOD} ${SRCDIR}/Eirene_modules/photon.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/photon.o -c ${SRCDIR}/Eirene_modules/photon.F

${OBJDIR}/precision.o: ${SRCDIR}/Eirene_modules/precision.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/precision.o -c ${SRCDIR}/Eirene_modules/precision.F

${OBJDIR}/rcm.o: ${SRCDIR}/Eirene_modules/rcm.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/rcm.o -c ${SRCDIR}/Eirene_modules/rcm.F

endif

${OBJDIR}/b2_4to5.${MOD}: ${OBJDIR}/eirmod_parmmod.${MOD} ${OBJDIR}/braeir.${MOD} ${OBJDIR}/eirdiag.${MOD}

${OBJDIR}/b2mod_b2_to_astra.${MOD}: ${OBJDIR}/eirmod_extrab25.${MOD}

${OBJDIR}/b2mod_neutrals_namelist.${MOD}: ${OBJDIR}/eirmod_parmmod.${MOD} ${OBJDIR}/braeir.${MOD} ${OBJDIR}/eirdiag.${MOD}

${OBJDIR}/eirmod_braeir.${MOD}: 
	ln -sf ${EIRDIR}/eirmod_braeir.${MOD} ${OBJDIR}

${OBJDIR}/eirmod_ctrig.${MOD}:
	ln -sf ${EIRDIR}/eirmod_ctrig.${MOD} ${OBJDIR}

${OBJDIR}/eirmod_extrab25.${MOD}: 
	ln -sf ${EIRDIR}/eirmod_extrab25.${MOD} ${OBJDIR}

${OBJDIR}/eirmod_parmmod.${MOD}: ${OBJDIR}/parmmod.${MOD} 
	ln -sf ${OBJDIR}/parmmod.${MOD} $@

${OBJDIR}/eirmod_precision.${MOD}: ${OBJDIR}/precision.${MOD} 
	ln -sf ${OBJDIR}/precision.${MOD} $@

${OBJDIR}/eirmod_octree.${MOD}: ${SRCDIR}/Eirene_modules/eirmod_octree.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirmod_octree.o -c ${SRCDIR}/Eirene_modules/eirmod_octree.F

${OBJDIR}/adsp.${MOD}: ${OBJDIR}/cpes.${MOD} ${SRCDIR}/Eirene_modules/adsp.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/adsp.o -c ${SRCDIR}/Eirene_modules/adsp.F

${OBJDIR}/amark_mod.${MOD}: ${SRCDIR}/Eirene_modules/amark_mod.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/amark_mod.o -c ${SRCDIR}/Eirene_modules/amark_mod.F

${OBJDIR}/avltree.${MOD}: ${OBJDIR}/ccona.${MOD} ${SRCDIR}/Eirene_modules/avltree.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/avltree.o -c ${SRCDIR}/Eirene_modules/avltree.F

${OBJDIR}/braeir.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/braeir.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/braeir.o -c ${SRCDIR}/Eirene_modules/braeir.F

${OBJDIR}/brascl.${MOD}: ${SRCDIR}/Eirene_modules/brascl.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/brascl.o -c ${SRCDIR}/Eirene_modules/brascl.F

${OBJDIR}/braspoi.${MOD}: ${SRCDIR}/Eirene_modules/braspoi.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/braspoi.o -c ${SRCDIR}/Eirene_modules/braspoi.F

${OBJDIR}/cadgeo.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cadgeo.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cadgeo.o -c ${SRCDIR}/Eirene_modules/cadgeo.F

${OBJDIR}/cai.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cai.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cai.o -c ${SRCDIR}/Eirene_modules/cai.F

${OBJDIR}/caprmc.${MOD}: ${OBJDIR}/cgrid.${MOD} ${OBJDIR}/comsou.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comxs.${MOD} ${OBJDIR}/ctrcei.${MOD} ${SRCDIR}/Eirene_modules/caprmc.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/caprmc.o -c ${SRCDIR}/Eirene_modules/caprmc.F

${OBJDIR}/ccflux.${MOD}: ${OBJDIR}/ctrig.${MOD} ${OBJDIR}/ctrcei.${MOD} ${OBJDIR}/cgeom.${MOD} ${OBJDIR}/ccona.${MOD} ${OBJDIR}/comusr.${MOD} ${SRCDIR}/Eirene_modules/ccflux.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ccflux.o -c ${SRCDIR}/Eirene_modules/ccflux.F

${OBJDIR}/ccona.${MOD}: ${SRCDIR}/Eirene_modules/ccona.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ccona.o -c ${SRCDIR}/Eirene_modules/ccona.F

${OBJDIR}/ccoupl.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/ccoupl.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ccoupl.o -c ${SRCDIR}/Eirene_modules/ccoupl.F

${OBJDIR}/ccrm.${MOD}: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/comxs.${MOD} ${OBJDIR}/ctrcei.${MOD} ${OBJDIR}/clogau.${MOD} ${OBJDIR}/cestim.${MOD} ${OBJDIR}/czt1.${MOD} ${OBJDIR}/comsou.${MOD} ${OBJDIR}/caprmc.${MOD} ${OBJDIR}/photon.${MOD} ${OBJDIR}/csdvi.${MOD} ${OBJDIR}/ccflux.${MOD} ${SRCDIR}/Eirene_modules/ccrm.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ccrm.o -c ${SRCDIR}/Eirene_modules/ccrm.F

${OBJDIR}/cdiprl.${MOD}: ${SRCDIR}/Eirene_modules/cdiprl.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cdiprl.o -c ${SRCDIR}/Eirene_modules/cdiprl.F

${OBJDIR}/ceirsrt.${MOD}: ${SRCDIR}/Eirene_modules/ceirsrt.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ceirsrt.o -c ${SRCDIR}/Eirene_modules/ceirsrt.F

${OBJDIR}/censav.${MOD}: ${SRCDIR}/Eirene_modules/censav.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/censav.o -c ${SRCDIR}/Eirene_modules/censav.F

${OBJDIR}/cestim.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cestim.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cestim.o -c ${SRCDIR}/Eirene_modules/cestim.F

${OBJDIR}/cfit.${MOD}: ${SRCDIR}/Eirene_modules/cfit.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cfit.o -c ${SRCDIR}/Eirene_modules/cfit.F

${OBJDIR}/cfplk.${MOD}: ${SRCDIR}/Eirene_modules/cfplk.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cfplk.o -c ${SRCDIR}/Eirene_modules/cfplk.F

${OBJDIR}/cgeom.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cgeom.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cgeom.o -c ${SRCDIR}/Eirene_modules/cgeom.F

${OBJDIR}/cgrid.${MOD}: ${OBJDIR}/comprt.${MOD} ${SRCDIR}/Eirene_modules/cgrid.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cgrid.o -c ${SRCDIR}/Eirene_modules/cgrid.F

${OBJDIR}/cgrptl.${MOD}: ${SRCDIR}/Eirene_modules/cgrptl.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cgrptl.o -c ${SRCDIR}/Eirene_modules/cgrptl.F

${OBJDIR}/cinit.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cinit.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cinit.o -c ${SRCDIR}/Eirene_modules/cinit.F

${OBJDIR}/clast.${MOD}: ${SRCDIR}/Eirene_modules/clast.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/clast.o -c ${SRCDIR}/Eirene_modules/clast.F

${OBJDIR}/clena.${MOD}: ${OBJDIR}/comsig.${MOD} ${SRCDIR}/Eirene_modules/clena.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/clena.o -c ${SRCDIR}/Eirene_modules/clena.F

${OBJDIR}/clgin.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/clgin.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/clgin.o -c ${SRCDIR}/Eirene_modules/clgin.F

${OBJDIR}/clmsur.${MOD}: ${SRCDIR}/Eirene_modules/clmsur.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/clmsur.o -c ${SRCDIR}/Eirene_modules/clmsur.F

${OBJDIR}/clogau.${MOD}: ${SRCDIR}/Eirene_modules/clogau.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/clogau.o -c ${SRCDIR}/Eirene_modules/clogau.F

${OBJDIR}/comnnl.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comnnl.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comnnl.o -c ${SRCDIR}/Eirene_modules/comnnl.F

${OBJDIR}/comprt.${MOD}: ${SRCDIR}/Eirene_modules/comprt.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comprt.o -c ${SRCDIR}/Eirene_modules/comprt.F

${OBJDIR}/comsig.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comsig.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comsig.o -c ${SRCDIR}/Eirene_modules/comsig.F

${OBJDIR}/comsmu.${MOD}: ${SRCDIR}/Eirene_modules/comsmu.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comsmu.o -c ${SRCDIR}/Eirene_modules/comsmu.F

${OBJDIR}/comsou.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comsou.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comsou.o -c ${SRCDIR}/Eirene_modules/comsou.F

${OBJDIR}/comspl.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comspl.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comspl.o -c ${SRCDIR}/Eirene_modules/comspl.F

${OBJDIR}/comusr.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/comusr.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comusr.o -c ${SRCDIR}/Eirene_modules/comusr.F

${OBJDIR}/comxs.${MOD}: ${OBJDIR}/cupd.${MOD} ${OBJDIR}/comprt.${MOD} ${SRCDIR}/Eirene_modules/comxs.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comxs.o -c ${SRCDIR}/Eirene_modules/comxs.F

${OBJDIR}/coutau.${MOD}: ${SRCDIR}/Eirene_modules/coutau.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/coutau.o -c ${SRCDIR}/Eirene_modules/coutau.F

${OBJDIR}/cpes.${MOD}: ${OBJDIR}/ctrcei.${MOD} ${OBJDIR}/eirmod_precision.${MOD} ${SRCDIR}/Eirene_modules/cpes.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cpes.o -c ${SRCDIR}/Eirene_modules/cpes.F

${OBJDIR}/cplmsk.${MOD}: ${SRCDIR}/Eirene_modules/cplmsk.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cplmsk.o -c ${SRCDIR}/Eirene_modules/cplmsk.F

${OBJDIR}/cplot.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cplot.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cplot.o -c ${SRCDIR}/Eirene_modules/cplot.F

${OBJDIR}/cpl3d.${MOD}: ${SRCDIR}/Eirene_modules/cpl3d.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cpl3d.o -c ${SRCDIR}/Eirene_modules/cpl3d.F

${OBJDIR}/cpolyg.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cpolyg.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cpolyg.o -c ${SRCDIR}/Eirene_modules/cpolyg.F

${OBJDIR}/crand.${MOD}: ${SRCDIR}/Eirene_modules/crand.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/crand.o -c ${SRCDIR}/Eirene_modules/crand.F

${OBJDIR}/cref.${MOD}: ${SRCDIR}/Eirene_modules/cref.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cref.o -c ${SRCDIR}/Eirene_modules/cref.F

${OBJDIR}/crech.${MOD}: ${SRCDIR}/Eirene_modules/crech.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/crech.o -c ${SRCDIR}/Eirene_modules/crech.F

${OBJDIR}/crefmod.${MOD}: ${SRCDIR}/Eirene_modules/crefmod.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/crefmod.o -c ${SRCDIR}/Eirene_modules/crefmod.F

${OBJDIR}/csdvi.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/csdvi.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/csdvi.o -c ${SRCDIR}/Eirene_modules/csdvi.F

${OBJDIR}/csdvi_bgk.${MOD}: ${SRCDIR}/Eirene_modules/csdvi_bgk.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/csdvi_bgk.o -c ${SRCDIR}/Eirene_modules/csdvi_bgk.F

${OBJDIR}/csdvi_cop.${MOD}: ${SRCDIR}/Eirene_modules/csdvi_cop.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/csdvi_cop.o -c ${SRCDIR}/Eirene_modules/csdvi_cop.F

${OBJDIR}/cspars.${MOD}: ${SRCDIR}/Eirene_modules/cspars.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cspars.o -c ${SRCDIR}/Eirene_modules/cspars.F

${OBJDIR}/cspei.${MOD}: ${SRCDIR}/Eirene_modules/cspei.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cspei.o -c ${SRCDIR}/Eirene_modules/cspei.F

${OBJDIR}/cspez.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/cspez.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cspez.o -c ${SRCDIR}/Eirene_modules/cspez.F

${OBJDIR}/cstep.${MOD}: ${SRCDIR}/Eirene_modules/cstep.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cstep.o -c ${SRCDIR}/Eirene_modules/cstep.F

${OBJDIR}/ctetra.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/ctetra.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ctetra.o -c ${SRCDIR}/Eirene_modules/ctetra.F

${OBJDIR}/ctext.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/ctext.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ctext.o -c ${SRCDIR}/Eirene_modules/ctext.F

${OBJDIR}/ctrcei.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/ctrcei.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ctrcei.o -c ${SRCDIR}/Eirene_modules/ctrcei.F

${OBJDIR}/ctrig.${MOD}: ${OBJDIR}/cgrid.${MOD} ${SRCDIR}/Eirene_modules/ctrig.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ctrig.o -c ${SRCDIR}/Eirene_modules/ctrig.F

${OBJDIR}/ctsurf.${MOD}: ${SRCDIR}/Eirene_modules/ctsurf.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ctsurf.o -c ${SRCDIR}/Eirene_modules/ctsurf.F

${OBJDIR}/cupd.${MOD}: ${OBJDIR}/comsig.${MOD} ${SRCDIR}/Eirene_modules/cupd.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cupd.o -c ${SRCDIR}/Eirene_modules/cupd.F

${OBJDIR}/czt1.${MOD}: ${OBJDIR}/parmmod.${MOD} ${SRCDIR}/Eirene_modules/czt1.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/czt1.o -c ${SRCDIR}/Eirene_modules/czt1.F

${OBJDIR}/eirbase.${MOD}: ${SRCDIR}/Eirene_modules/eirbase.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirbase.o -c ${SRCDIR}/Eirene_modules/eirbase.F

${OBJDIR}/eirbra.${MOD}: ${SRCDIR}/Eirene_modules/eirbra.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirbra.o -c ${SRCDIR}/Eirene_modules/eirbra.F

${OBJDIR}/eircolsp.${MOD}: ${SRCDIR}/Eirene_modules/eircolsp.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eircolsp.o -c ${SRCDIR}/Eirene_modules/eircolsp.F

${OBJDIR}/eirdiag.${MOD}: ${OBJDIR}/clgin.${MOD} ${OBJDIR}/ccoupl.${MOD} ${SRCDIR}/Eirene_modules/eirdiag.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirdiag.o -c ${SRCDIR}/Eirene_modules/eirdiag.F

${OBJDIR}/eirgrid.${MOD}: ${SRCDIR}/Eirene_modules/eirgrid.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirgrid.o -c ${SRCDIR}/Eirene_modules/eirgrid.F

${OBJDIR}/eirgrid_lib.${MOD}: ${OBJDIR}/eirmap.${MOD} ${SRCDIR}/Eirene_modules/eirgrid_lib.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirgrid_lib.o -c ${SRCDIR}/Eirene_modules/eirgrid_lib.F

${OBJDIR}/eirmap.${MOD}: ${OBJDIR}/eirbase.${MOD} ${SRCDIR}/Eirene_modules/eirmap.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirmap.o -c ${SRCDIR}/Eirene_modules/eirmap.F

${OBJDIR}/eirsamsp.${MOD}: ${SRCDIR}/Eirene_modules/eirsamsp.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirsamsp.o -c ${SRCDIR}/Eirene_modules/eirsamsp.F

${OBJDIR}/ifwrite.${MOD}: ${SRCDIR}/Eirene_modules/ifwrite.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ifwrite.o -c ${SRCDIR}/Eirene_modules/ifwrite.F

${OBJDIR}/impdns.${MOD}: ${SRCDIR}/Eirene_modules/impdns.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/impdns.o -c ${SRCDIR}/Eirene_modules/impdns.F

${OBJDIR}/impmom.${MOD}: ${OBJDIR}/impdns.${MOD} ${SRCDIR}/Eirene_modules/impmom.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/impmom.o -c ${SRCDIR}/Eirene_modules/impmom.F

${OBJDIR}/impsrc.${MOD}: ${OBJDIR}/impmom.${MOD} ${SRCDIR}/Eirene_modules/impsrc.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/impsrc.o -c ${SRCDIR}/Eirene_modules/impsrc.F

${OBJDIR}/parmmod.${MOD}: ${OBJDIR}/precision.${MOD} ${SRCDIR}/Eirene_modules/parmmod.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/parmmod.o -c ${SRCDIR}/Eirene_modules/parmmod.F

${OBJDIR}/photon.${MOD}: ${OBJDIR}/clogau.${MOD} ${OBJDIR}/czt1.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comxs.${MOD} ${SRCDIR}/Eirene_modules/photon.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/photon.o -c ${SRCDIR}/Eirene_modules/photon.F

${OBJDIR}/precision.${MOD}: ${SRCDIR}/Eirene_modules/precision.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/precision.o -c ${SRCDIR}/Eirene_modules/precision.F

${OBJDIR}/rcm.${MOD}: ${SRCDIR}/Eirene_modules/rcm.F
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/rcm.o -c ${SRCDIR}/Eirene_modules/rcm.F

${OBJDIR}/libb2_solps4.a: ${MD4OBJS} ${SB4OBJS} ${SE4OBJS}
	${BLD} $@ $?

${OBJDIR}/libb2_solps5.a: ${MD5OBJS} ${SR5OBJS}
	${BLD} $@ $?

depend: ${BASEDIR}/LISTOBJ ${OBJS:.o=.F} ${EXCLUDELIST:.o=.F}
	`which makedepend` -p'$${OBJDIR}/' ${DEFINES} -f- ${INCLUDE} $^ | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' | \
        sed 's,: ${SOLPSTOP},: $${SOLPSTOP},' > ${OBJDIR}/dependencies
ifneq (${MOD},o)
	`which makedepend` -p'$${OBJDIR}/' ${DEFINES} -f- ${INCLUDE} $^ -o.${MOD} | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' | \
        sed 's,: ${SOLPSTOP},: $${SOLPSTOP},' >> ${OBJDIR}/dependencies
endif
	egrep -ai '^ {6,}use ' ${FFLIST} | grep -v 'IGNORE' | awk '{sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
ifneq (${MOD},o)
	egrep -ai '^ {6,}use ' ${MODLIST} | grep -v 'IGNORE' | awk '{sub("\\.F:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
endif

${BASEDIR}/TAGS: tags

tags: 
	rm -f ${BASEDIR}/TAGS ; etags ${TAGSLIST}

clean:
	rm -f ${OBJDIR}/*.f ${OBJDIR}/*.o ${OBJDIR}/*.${MOD} ${OBJDIR}/*.a ${OBJDIR}/*.exe
	rm -Rf ${SRCDIR}/B2_include
	rm -Rf ${SRCDIR}/Eirene_modules
	rm -Rf ${SRCDIR}/solps4_B2
	rm -Rf ${SRCDIR}/solps4_Eirene

listobj: 
	@rm -f ${BASEDIR}/LISTOBJ; touch ${BASEDIR}/LISTOBJ; l="OBJS ="; \
	for d in `echo "${VPATH}" | tr : \ `; do \
		l="$$l `(cd $$d > /dev/null; echo *.[Ff])`"; \
	done; \
	E="-e 's/\.[Ff]/\.o/g'" ; for f in ${EXCLUDELIST}; do \
		E="$$E -e 's/ $$f//'"; \
	done; \
	echo "$$l" | eval sed "$$E" > ${BASEDIR}/LISTOBJ

links:
	[ -L ${SRCDIR}/B2_include ] && rm -Rf ${SRCDIR}/B2_include || echo > /dev/null
	-mkdir -p ${SRCDIR}/B2_include
	lndir ${SOLPS4}/src/Braams/b2/include ${SRCDIR}/B2_include
	[ -L ${SRCDIR}/Eirene_modules ] && rm -Rf ${SRCDIR}/Eirene_modules || echo > /dev/null
	-mkdir -p ${SRCDIR}/Eirene_modules
	lndir ${SOLPS4}/src/Eirene/src/modules ${SRCDIR}/Eirene_modules
	-mkdir -p ${SRCDIR}/solps4_B2
	cat B2_4.3.source_files | sed -e 's:[^ ]*/: ${SRCDIR}/solps4_B2/:' | paste B2_4.3.source_files - | sed -e "s:^:ln -sf ${SOLPS4}/src/Braams/b2/src/:" > B2_links
	. B2_links
	rm B2_links
	-mkdir -p ${SRCDIR}/solps4_Eirene
	cat Eirene_4.3.source_files | sed -e 's:[^ ]*/: ${SRCDIR}/solps4_Eirene/:' | paste Eirene_4.3.source_files - | sed -e "s:^:ln -sf ${SOLPS4}/src/Eirene/src/:" > Eirene_links
	. Eirene_links
	rm Eirene_links

${BASEDIR}/LISTOBJ: listobj

${OBJDIR}/dependencies: ${SRCDIR}/B2.5_modules/.new_modules
ifeq ($(shell [ -d ${OBJDIR} ] && echo yes || echo no ),no)
	-mkdir -p ${OBJDIR}
endif
	touch ${OBJDIR}/dependencies
	${MAKE} links
	${MAKE} tags
	${MAKE} listobj
	${MAKE} depend

include ${OBJDIR}/dependencies

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

