// $Id: $
// $LastChangedBy: $
// $LastChangedDate: $
// $Revision: $

#include <string.h>
#include <assert.h>
#include "mex.h"
#include "graph.h"

void mexFunction (int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    if  ( nrhs  != 3 ) {
        mexErrMsgTxt("Wrong number of input arguments");
    }

    mwSize npoints = mxGetM(prhs[0]);
    mwSize nidx = mxGetM(prhs[1]);

    double dist_max = mxGetScalar(prhs[2]);

    if (!mxIsDouble(prhs[0])) {
        mexErrMsgIdAndTxt("Djikstra Mex:A","Adjacency matrix should a real (double) valued matrix");
    }

    if ( mxGetClassID(prhs[1]) != mxINT32_CLASS ) {
        mexErrMsgIdAndTxt("Djikstra Mex:pidx","Point index argument is not of type int32");
    }

    int* pidx = (int*)mxGetData(prhs[1]);

    plhs[0] = mxCreateDoubleMatrix(npoints, nidx, mxREAL);
    double* dist = mxGetPr(plhs[0]);

    Graph g(prhs[0]);

    // mexPrintf("Graph\n");
    // mexPrintf("\tNb of vertices     : %d\n", g.nv());
    // mexPrintf("\tNb of egdes        : %d\n", g.ne());
    // mexPrintf("\n");
    // mexPrintf("\tNb of starts        : %d\n", nidx);

    for(size_t i = 0; i < nidx; ++i) {
        // mexPrintf("Djikstra from node : %d\n",pidx[i]);
        int starting_node = pidx[i]-1;
        g.getDist(starting_node,dist+i*npoints,dist_max);
    }
}