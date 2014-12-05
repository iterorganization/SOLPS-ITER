c  Common dimensions
c
c  version : 01.12.98 21:42
c
#ifndef DIMENSIONS_DEFINED
#define DIMENSIONS_DEFINED

c
c parameters that are common to Eirene and B2
c

c NOTE: DEF_NXD should not include the additional cells to handle the cuts
#define DEF_NXD 128
#define DEF_NCUT 4
#define DEF_ISOEXTRA 0
#define DEF_NYD 36
#define DEF_NPHID 1
#define DEF_NSTRA 10
#define DEF_NFL 9
#define DEF_NPLS 9
#define DEF_NATM 3
#define DEF_NMOL 1
#define DEF_NION 1
#define DEF_NLIM 300
#define DEF_NSTS 50
#define DEF_NTOR 1
c*** Max. number of groups of Eirene surfaces for which the data can
c*** be transferred from B2 (DG specification "Surface special")
#define DEF_NSPCSRFG 40

c new! [2002.04.22]
#define DEF_NADD 2
#define DEF_NPRNL 50000
c new! [2002.06.14]
#define DEF_NSRFS 2

c
c parameters that are unique to B2
c

#define DEF_NSD 42

c
c parameters that are unique to Eirene
c

#define DEF_NGSTAL 1

#endif
