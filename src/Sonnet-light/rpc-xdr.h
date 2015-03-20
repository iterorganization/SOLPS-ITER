
                                                                     
// 04/02/2000  15:59                     Emacs Editing Mode -*-C++-*-
// ------------------------------------------------------------------ 
// ==== File: %A%
// ==== -------------------------------------------------------- ==== 
// ====     %Z% Version %I%   Date: %G%
// ==== -------------------------------------------------------- ==== 
// ====     %Z% latest Delta: %G% %U% 
// ================================================================== 


#ifndef epic_rpc_xdr_h
#define epic_rpc_xdr_h

#define SUCCESS 0           
#define FAILURE 1           

enum XDR_ACTION { readXDR, writeXDR };

#ifndef NO_TEST_XDR
#define testXDR(pt) if ((pt)==0) {printf("   XDR failed in file \"%s\" on line %d\n\n", __FILE__, __LINE__);return (pt);}
#else
#define testXDR(pt)
#endif

#endif // epic_rpc_xdr_h
