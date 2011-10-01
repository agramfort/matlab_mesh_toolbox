#include <string.h>
#include <assert.h>
#include "mex.h"

void floyd_warshall(double* dist,mwSize npoints) {
    int i, j, k;
    for (k = 0; k < npoints; ++k) {
        for (i = 0; i < npoints; ++i) {
            for (j = 0; j < npoints; ++j) {
                /* If i and j are different nodes and if 
                    the paths between i and k and between
                    k and j exist, do */
                if ((dist[k*npoints+i] * dist[j*npoints+k] != 0) && (i != j))
                    /* See if you can't get a shorter path
                        between i and j by interspacing
                        k somewhere along the current
                        path */
                    if ((dist[k*npoints+i] + dist[j*npoints+k] < dist[j*npoints+i]) ||
                        (dist[j*npoints+i] == 0)) {
                            dist[j*npoints+i] = dist[k*npoints+i] + dist[j*npoints+k];
                    }
            }
        }
    }
}

void mexFunction (int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    if  ( nrhs  != 1 ) {
        mexErrMsgTxt("Wrong number of input arguments");
    }

    mwSize npoints = mxGetM(prhs[0]);
    
    if (!mxIsDouble(prhs[0]) && !mxIsSparse(prhs[0]))
        mexErrMsgTxt("Input should a full double matrix"); 

    plhs[0] = mxCreateDoubleMatrix(npoints, npoints, mxREAL);
    double* dist = mxGetPr(plhs[0]);
    memcpy(dist,mxGetPr(prhs[0]),sizeof(double)*npoints*npoints);

    floyd_warshall(dist,npoints);
}