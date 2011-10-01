// $Id: mesh_connectivity_mex.cpp 171 2009-10-22 13:23:06Z gramfort $
// $LastChangedBy: gramfort $
// $LastChangedDate: 2009-10-22 15:23:06 +0200 (Thu, 22 Oct 2009) $
// $Revision: 171 $

#include "mex.h"

#include <set>
#include <vector>

typedef std::set< double > Link;
typedef std::vector< Link > Links;

void mexFunction (int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    if  ( nrhs  != 2 ) {
        mexErrMsgTxt("Wrong number of input arguments");
    }

    mwSize npoints = mxGetM(prhs[0]);
    mwSize nfaces = mxGetM(prhs[1]);

    // assert(mxGetM(prhs[0]) == 3);
    // assert(mxGetM(prhs[1]) == 3);
    // assert(mxIsClass(prhs[0],'double'));
    // assert(mxIsClass(prhs[1],'double'));

    // mexPrintf("Number of points : %d\n",npoints);
    // mexPrintf("Number of faces : %d\n",nfaces);

    Links links(npoints);

    double* points = mxGetPr(prhs[0]);
    double* faces  = mxGetPr(prhs[1]);

    for(mwSize i = 0; i < nfaces; ++i)
    {
        mwSize s1 = faces[0*nfaces+i];
        mwSize s2 = faces[1*nfaces+i];
        mwSize s3 = faces[2*nfaces+i];
        //assert((s1-1) >= 0); assert((s1-1) < npoints);
        //assert((s2-1) >= 0); assert((s2-1) < npoints);
        //assert((s3-1) >= 0); assert((s3-1) < npoints);
        if (s1 < s2) { links[s1-1].insert(s2); links[s2-1].insert(s1); }
        if (s2 < s3) { links[s2-1].insert(s3); links[s3-1].insert(s2); }
        if (s3 < s1) { links[s3-1].insert(s1); links[s1-1].insert(s3); }
    }

    const mwSize dims[] = {npoints};
    plhs[0] = mxCreateCellArray(1, dims);
    Link::iterator it;

    for(mwSize i = 0; i < npoints; ++i)
    {
        const size_t nneighbors = links[i].size();
        mxArray* neighbors = mxCreateDoubleMatrix(1, nneighbors, mxREAL);
        double* pr = mxGetPr(neighbors);
        mwSize j = 0;
        for(it = links[i].begin(); it != links[i].end(); ++it)
        {
            pr[j] = *it;
            j++;
        }
        mxSetCell(plhs[0], i, neighbors);
    }
    return;
}
