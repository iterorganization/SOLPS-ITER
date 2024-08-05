                                                                     
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pwd.h>
#include <rpc/rpc.h>

#include "stdcpp.h"
#include "open.h"
#include "rpc-xdr.h"

#define xdr_open xdr_open_
#define xdr_close xdr_close_
#define xdr_real xdr_real_
#define xdr_integer xdr_integer_
#define xdr_single xdr_single_
#define xdr_character xdr_character_

#define B2D_MAGIC   0x2DEAFFFA
#define B2D_VERSION 2

static bool Details = false;
static XDR_ACTION Action;  /* transfer to file scope */
static XDR xdrHandle;
static FILE* PointerToFile = nil;

extern "C" {

void xdr_open (
      char* file,     //  Name of XDR file
      char* action,   //  "read" or "write"
      int len_file,   //  string length file
      int len_action  //  string length action
) {   
    char* local_file = new char [len_file+1];
    char* local_action = new char [len_action+1];

    strncpy(local_file, file, len_file);
    strncpy(local_action, action, len_action);

    char endchar = '\0';
    char* toLastBlank;

    toLastBlank = local_file + len_file - 1; 
    while ( !strncmp(toLastBlank, " ", 1) ) --toLastBlank;
    strncpy(toLastBlank+1, &endchar, 1);

    toLastBlank = local_action + len_action - 1; 
    while ( !strncmp(toLastBlank, " ", 1) ) --toLastBlank;
    strncpy(toLastBlank+1, &endchar, 1);

    int info = 1;
    if (info >= 1) {
        printf("   file is %s (%d characters)\n", 
            local_file, 
            strlen(local_file)
        );
        printf("   action is %s (%d characters)\n", 
            local_action, 
            strlen(local_action)
      );
    }

    enum xdr_op xdrOption;
    const char* fileType;
    int status, B2D_version, B2D_magic;

    if (Details) {
        printf("   local_file     = \"%s\"\n", local_file    );
        printf("   local_action   = \"%s\"\n", local_action  );
    }

    XDR_ACTION xdr_action; 
             
    if (!strcmp(local_action, "read")) {
        if (Details) 
            printf("   XDR action: read\n");
        xdr_action = readXDR;
        xdrOption = XDR_DECODE;
        fileType = "r";
    } else if (!strcmp(local_action, "write")) {
        if (Details) 
            printf("   XDR action: write\n");
        xdr_action = writeXDR;
        xdrOption = XDR_ENCODE;
        fileType = "w+";
        B2D_magic = B2D_MAGIC;
        B2D_version = B2D_VERSION;
    } else if (!strcmp(local_action, "info")) {
        printf("info option not done");
    } else {
        printf("Second parameter of xdr_open(): 'read'|'write' !");
    }

    Action = xdr_action;

    FILE* fp = fopen(local_file, fileType);
    if (fp == nil) printf("\n   Opening %s ...\n", local_file);
    testOpening (fp);
	  PointerToFile = fp;

    xdrstdio_create(&xdrHandle, fp, xdrOption);

    status = SUCCESS;
    if (xdr_int(&xdrHandle, &B2D_magic  ) == FALSE ||
        xdr_int(&xdrHandle, &B2D_version) == FALSE ||
        B2D_magic   != B2D_MAGIC ||
        B2D_version != B2D_VERSION ) {

        status = FAILURE;
    }

    delete [] local_file;
    delete [] local_action;
    return;
}

void xdr_character (
      char* string,
      int length
) {
    char* local_string = new char [length+1];
    strncpy(local_string, string, length);
    int local_length = length;

    char endchar = '\0';
    char* toLast;

    toLast = local_string + local_length - 1; 
    while ( !strncmp(toLast, " ", 1) ) --toLast;
    strncpy(toLast+1, &endchar, 1);

    int returnLength;
    int response;
    if (Action == readXDR) {
        response = xdr_int(&xdrHandle, &returnLength);
        if (response == FALSE) printf("xdr_int() failed for reading string length.");
        if (returnLength > local_length) 
           printf("Returned length greater input length.");
    } else if (Action == writeXDR) {

        if (Details) printf("   local_string = \"%s\"\n", local_string);
        if (Details) printf("   local_length = %d\n", local_length);
        response = xdr_int(&xdrHandle, &local_length);
        if (response == FALSE) 
            printf("xdr_int() failed for writing string length");
    } else
        printf("action");

    response = xdr_string(&xdrHandle, &local_string, local_length);

    if (response == FALSE && Action == writeXDR) {
        printf("xdr_string() failed for writing.");
    }
    if (response == FALSE && Action == readXDR) {
        printf("xdr_string() failed for reading.");
    }

    if (Action == readXDR) {
    strcpy(string, local_string);
    }

    return;
}

void xdr_close () { 
    xdr_destroy(&xdrHandle); 
    fclose(PointerToFile);
}


void xdr_real (double* reals, int* number, int *increment) {

    int response, i;
    for (i = 0; i < *number; i += *increment) {
        if (Details) 
            printf("   reals[%d] = %f\n", i, reals[i]);
        response = xdr_double(&xdrHandle, reals+i);
        if (response == FALSE) printf("Response problem for xdr_double");
    }
    return;
}

void xdr_single (float *singles, int *number, int *increment) {

    int response, i;
    double double_value;

    for (i = 0; i < *number; i += *increment) {
        if (Details) 
            printf("   singles[%d] = %f\n", i, singles[i]);

        if (Action == writeXDR) {
            double_value = (double) singles[i];
            response = xdr_double(&xdrHandle, &double_value);
            if (response == FALSE) printf("Response problem for xdr_single");
        } else if (Action == readXDR) {
            response = xdr_double(&xdrHandle, &double_value);
            if (response == FALSE) {
				printf("Response problem for xdr_single\n");
				exit(0);
			}
            singles[i] = (float) double_value;
        } else {
            printf("Neither readXDR nor writeXDR\n");
        }

    }
    return;
}

void xdr_integer (int integers[], int *number, int *increment) {
    int response, i;
    for (i = 0; i < *number; i += *increment) {
        if (Details) 
            printf("   integers[%d] = %d\n", i, *(integers+i));
        response = xdr_int(&xdrHandle, integers+i);

        if (response == FALSE) printf("Response problem for xdr_int");
    }
    return;
}

} // extern "C"
