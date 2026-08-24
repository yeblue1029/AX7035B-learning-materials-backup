/*************************************

   Version Y-2006.06-B-11 -- Mon Jun 26 16:48:27 2006

   Copyright (c) 1991-2005 by Synopsys Inc.

   Induced headers for external functions.
   Only actually called external functions.

*************************************/

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _VC_TYPES_
#define _VC_TYPES_
/* common definitions shared with DirectC.h */

typedef unsigned int U;
typedef unsigned char UB;
typedef unsigned char scalar;
typedef struct { U c; U d;} vec32;

#define scalar_0 0
#define scalar_1 1
#define scalar_z 2
#define scalar_x 3

extern long long int ConvUP2LLI(U* a);
extern void ConvLLI2UP(long long int a1, U* a2);
typedef struct VeriC_Descriptor *vc_handle;

#endif /* _VC_TYPES_ */





extern void WmaskAndSet2(/*INOUT*/vec32* res, const U* mask, const vec32* drive, int length);
extern /*PURE*/ int getCurSchedRegion(void);

#ifdef __cplusplus
}
#endif

