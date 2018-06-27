/*
 * Copyright (c) 2011 Joshua V Dillon
 * Copyright (c) 2014 Andrew Smart (besed on "semaphore.c" by Joshua V. Dillon)
 * Copyright (c) 2018 Varfolomeev Igor (based on "semaphore.c" by Andrew Smart)
 *
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or
 * without modification, are permitted provided that the
 * following conditions are met:
 *  * Redistributions of source code must retain the above
 *    copyright notice, this list of conditions and the
 *    following disclaimer.
 *  * Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the
 *    following disclaimer in the documentation and/or other
 *    materials provided with the distribution.
 *  * Neither the name of the author nor the names of its
 *    contributors may be used to endorse or promote products
 *    derived from this software without specific prior written
 *    permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ''AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JOSHUA
 * V DILLON BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */


/*
 * This code can be compiled from within Matlab or command-line, assuming the
 * system is appropriately setup.  To compile, invoke:
 *
 * For 32-bit machines:
 *     mex -O -v semaphore.c
 * For 64-bit machines:
 *     mex -O -v semaphore.c
 *
 */


/* 
 * Programmer's Notes:
 *
 * MEX C API:
 * http://www.mathworks.com/access/helpdesk/help/techdoc/apiref/bqoqnz0.html
 *
 * Testing:
 *
 */


#include <windows.h>
#include <stdio.h>

#include <errno.h>

/* standard mex include */
#include "mex.h"

/* max length of directive string */
#define MAXDIRECTIVELEN 256


/* ------------------------------------------------------------------------- */
/* Matlab gateway function                                                   */
/*                                                                           */
/* (see semaphore.m for description)                                      */
/* ------------------------------------------------------------------------- */
void mexFunction( int nlhs,       mxArray *plhs[], 
                  int nrhs, const mxArray *prhs[]  )
{
	/* for storing directive (string) input */
	char directive[MAXDIRECTIVELEN+1];
	int semval = 1;

	char semkeyStr[MAXDIRECTIVELEN];
	HANDLE hSemaphore = NULL;
	DWORD lastError;
	LPVOID lpMsgBuf;
	typedef unsigned long long uint64;

	/* check min number of arguments */
	if(nrhs<2)mexErrMsgIdAndTxt("MATLAB:semaphore","Minimum input arguments missing; must supply directive and key.");

	/* get directive (ARGUMENT 0) */
	if (mxGetString(prhs[0], (char*)(&directive), MAXDIRECTIVELEN)!=0) 
		mexErrMsgIdAndTxt("MATLAB:semaphore:BadArg0", "First input argument must be one of {'create','wait','post','destroy'}.");

	/* get UID str (ARGUMENT 1) */
	if (mxGetString(prhs[1], (char*)(&semkeyStr), MAXDIRECTIVELEN) != 0) 
		mexErrMsgIdAndTxt("MATLAB:semaphore:BadArg1", "Second input argument must be char uid, with length up to 256.");
	

	/* check outputs */
	if(nlhs > 1) 
		mexErrMsgIdAndTxt("MATLAB:semaphore", "Function returns only one value.");

	/* clone, attach, detach, free */
	switch (tolower(directive[0])) {


	case 'c': /* Create --------------------------------------------------------------------------------------------------------- */
		{
			/* Assign Input Parameters */
			if (nrhs > 2 && mxIsNumeric(prhs[2]) && mxGetNumberOfElements(prhs[2]) == 1) semval = (int)(mxGetScalar(prhs[2]) + 0.5);
			else mexErrMsgIdAndTxt("MATLAB:semaphore:create", "Third input argument must be initial semaphore value (numeric scalar).");

			if (0 == (hSemaphore = CreateSemaphore(NULL, semval, semval, semkeyStr)))
			{
				if (GetLastError() != ERROR_INVALID_HANDLE)
				{
					lastError = GetLastError();

					FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_MAX_WIDTH_MASK,
						NULL,
						lastError,
						MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), /* Default language */
						(LPTSTR)&lpMsgBuf,
						0,
						NULL);

					mexErrMsgIdAndTxt("MATLAB:semaphore:post", "Unable to post the semaphore with key #%s due to system error #%d \"%s\".",
						semkeyStr, lastError, (LPCTSTR)lpMsgBuf);

					LocalFree(lpMsgBuf);
				}
				else
				{
					mexErrMsgIdAndTxt("MATLAB:semaphore:create", "Unable to create semaphore due to ERROR_INVALID_HANDLE.");
				}
			}

			// return handle_as_uint64 (for debugging mostly)
			static_assert(sizeof(HANDLE) == 8, "handle is not 64-bit.");
			static_assert(sizeof(uint64) == 8, "long long is not 64-bit.");
			uint64* handle_val_p = &hSemaphore;
			uint64 handle_val = handle_val_p[0];

			plhs[0] = mxCreateUninitNumericMatrix(1, 1, mxINT64_CLASS, mxREAL);
			uint64* pointer = mxGetPr(plhs[0]);
			pointer[0] = handle_val;
		}
		break;


	case 'w': /* Wait --------------------------------------------------------------------------------------------------------- */		
		{
			DWORD max_wait_msec = INFINITE;

			if (nrhs == 3)  
			{
				mxArray* arg2 = prhs[2];
				if (!mxIsNumeric(arg2) || mxGetNumberOfElements(arg2) != 1)
					mexErrMsgIdAndTxt("MATLAB:semaphore:badWaitTime1", "max_wait_time must be represented with numeric uint32 scalar (msec).");

				if (mxGetClassID(arg2)!=mxUINT32_CLASS)
					mexErrMsgIdAndTxt("MATLAB:semaphore:badWaitTime2", "max_wait_time must be represented with uint32 scalar (msec).");

				DWORD* val = (DWORD*)mxGetData(arg2);
				max_wait_msec = val[0];
			}

			if (0 == (hSemaphore = OpenSemaphore(SYNCHRONIZE, false, semkeyStr)))			
				mexErrMsgIdAndTxt("MATLAB:semaphore:wait1", "Unable to open the semaphore handle \"%s\".", semkeyStr);

			DWORD wait_result = WaitForSingleObject(hSemaphore, max_wait_msec);

			if ( wait_result == WAIT_FAILED )
				mexErrMsgIdAndTxt("MATLAB:semaphore:wait2", "Failed waiting for \"%s\".", semkeyStr);				

			if ( wait_result == WAIT_TIMEOUT )
				mexErrMsgIdAndTxt("MATLAB:semaphore:waitTimeout", "Timeout (%d msec) waiting for \"%s\".", max_wait_msec, semkeyStr);

			CloseHandle(hSemaphore);					
		}
		break;


	case 'p': /* Post --------------------------------------------------------------------------------------------------------- */

		if(0==(hSemaphore=OpenSemaphore(SEMAPHORE_MODIFY_STATE,false,semkeyStr))) {
			mexErrMsgIdAndTxt("MATLAB:semaphore:post", "Unable to open the semaphore handle \"%s\".", semkeyStr);

		} else {
			long outCounter = -1;
			if (0 == ReleaseSemaphore(hSemaphore, 1, &outCounter)) {
				lastError = GetLastError();
				FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_MAX_WIDTH_MASK,
								NULL,
								lastError,
								MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), /* Default language */
								(LPTSTR) &lpMsgBuf,
								0,
								NULL);
				CloseHandle(hSemaphore);
				mexErrMsgIdAndTxt("MATLAB:semaphore:post", "Unable to post the semaphore with key #%s due to system error #%d \"%s\".", semkeyStr, lastError, (LPCTSTR)lpMsgBuf);
				LocalFree(lpMsgBuf);
			}

			if (nlhs != 1)
				mexErrMsgIdAndTxt("MATLAB:semaphore:notOneOutArg2", "Function returns only one value.");

			plhs[0] = mxCreateDoubleScalar((double)outCounter);
			CloseHandle(hSemaphore);
		}

		break;


	case 'd': /* Destroy --------------------------------------------------------------------------------------------------------- */
		/* On MS Windows the semaphore is destroyed when the process is. */		
		break;


	default: /* Error --------------------------------------------------------------------------------------------------------- */
		mexErrMsgIdAndTxt("MATLAB:semaphore", "Unrecognized directive.");
	} /* end directive switch */
}