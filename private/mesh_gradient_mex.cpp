// $Id: mesh_gradient_mex.cpp 171 2009-10-22 13:23:06Z gramfort $
// $LastChangedBy: gramfort $
// $LastChangedDate: 2009-10-22 15:23:06 +0200 (Thu, 22 Oct 2009) $
// $Revision: 171 $

#include "mex.h"

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <fstream>
#include <iostream>
#include <map>
#include <utility>

class SparseMatrix {

public:

    typedef std::map< std::pair< int, int >, double > Tank;
    typedef std::map< std::pair< int, int >, double >::const_iterator const_iterator;
    typedef std::map< std::pair< int, int >, double >::iterator iterator;

    SparseMatrix() : m_nlin(0), m_ncol(0) {};
    SparseMatrix(int N,int M) : m_nlin(N), m_ncol(M) {};
    ~SparseMatrix() {};

    inline double operator()( int i, int j ) const {
        assert(i < nlin());
        assert(j < ncol());
        const_iterator it = m_tank.find(std::make_pair<int, int>(i, j));
        if (it != m_tank.end()) return it->second;
        else return 0.0;
    }

    inline double& operator()( int i, int j ) {
        assert(i < nlin());
        assert(j < ncol());
        return m_tank[ std::make_pair( i, j ) ];
    }

    int size() const {
        return m_tank.size();
    }

    const_iterator begin() const {return m_tank.begin();}
    const_iterator end() const {return m_tank.end();}

    const Tank& tank() const {return m_tank;}

private:

    int m_nlin;
    int m_ncol;
    Tank m_tank;
};

class Vect3 {

private:
    double m_x,m_y,m_z; //!< Coordinates of the vector

public:
    inline Vect3 (const double &x, const double &y, const double &z) : m_x(x),m_y(y),m_z(z) {}
    inline Vect3 (const double &a) : m_x(a),m_y(a),m_z(a) {}
    inline Vect3() {}
    inline ~Vect3() {}
    inline double & x(){return m_x;}
    inline double & y(){return m_y;}
    inline double & z(){return m_z;}
    inline const double& x() const {return m_x;}
    inline const double& y() const {return m_y;}
    inline const double& z() const {return m_z;}

    inline double operator* (const Vect3 &v) const {return m_x*v.x() + m_y*v.y() + m_z*v.z();}
    inline double norm2() const {return m_x*m_x+m_y*m_y+m_z*m_z;}
    inline Vect3 operator+ (const Vect3&v) const {return Vect3(m_x+v.x(), m_y+v.y(), m_z+v.z());}
    inline Vect3 operator- (const Vect3 &v) const {return Vect3(m_x-v.x(), m_y-v.y(), m_z-v.z());}
    inline Vect3 operator* (const double &d) const {return Vect3(d*m_x, d*m_y, d*m_z);}
    inline Vect3 operator/ (const double &d) const {double d2 = 1.0/d; return Vect3(d2*m_x, d2*m_y, d2*m_z);}

    inline double operator() (const int i) const
    {
        assert(i>=0 && i<3);
        switch(i)
        {
            case 0 : return m_x;
            case 1 : return m_y;
            case 2 : return m_z;
            default : exit(1);
        }
    }

    inline double& operator() (const int i)
    {
        assert(i>=0 && i<3);
        switch(i)
        {
            case 0 : return m_x;
            case 1 : return m_y;
            case 2 : return m_z;
            default : exit(1);
        }
    }

    inline Vect3 operator- () {return Vect3(-m_x,-m_y,-m_z);}

};

inline Vect3 operator * (const double &d, const Vect3 &v) {return v*d;}

inline Vect3 P1Vector( const Vect3 &p0, const Vect3 &p1, const Vect3 &p2, const int idx )
{
    assert(idx>-1 && idx<3);
    int i = idx+1;
    Vect3 pts[5] = {p2,p0,p1,p2,p0};
    Vect3 ret(0,0,0);
    Vect3 pim1pi = pts[i]-pts[i-1];
    Vect3 pim1pip1 = pts[i+1]-pts[i-1];
    Vect3 pim1H = ( (1.0/pim1pip1.norm2()) * ( pim1pi*pim1pip1 ) ) * pim1pip1;
    Vect3 piH = pim1H-pim1pi;
    ret = -1.0/piH.norm2()*piH;

    return ret;
}

void mexFunction (int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    if  ( nrhs  != 2 ) {
        mexErrMsgTxt("Wrong number of input arguments");
    }

    mwSize npoints = mxGetN(prhs[0]);
    mwSize nfaces = mxGetN(prhs[1]);

    // assert(mxGetM(prhs[0]) == 3);
    // assert(mxGetM(prhs[1]) == 3);
    // assert(mxIsClass(prhs[0],'double'));
    // assert(mxIsClass(prhs[1],'double'));

    // mexPrintf("Number of points : %d\n",npoints);
    // mexPrintf("Number of faces : %d\n",nfaces);

    double* points = mxGetPr(prhs[0]);
    double* faces  = mxGetPr(prhs[1]);

    // const mwSize dims[] = {npoints};
    // plhs[0] = mxCreateCellArray(1, dims);
    // Link::iterator it;

    SparseMatrix grad(3*nfaces,npoints);

    // loop on triangles
    for (int t=0;t<nfaces;t++) {
        const double* trg = faces+3*t;
        const Vect3 p1(points[(int)(3*trg[0])],points[(int)(3*trg[0]+1)],points[(int)(3*trg[0]+2)]);
        const Vect3 p2(points[(int)(3*trg[1])],points[(int)(3*trg[1]+1)],points[(int)(3*trg[1]+2)]);
        const Vect3 p3(points[(int)(3*trg[2])],points[(int)(3*trg[2]+1)],points[(int)(3*trg[2]+2)]);
        Vect3 pts[3] = {p1,p2,p3};
        for(int j=0;j<3;j++) {
            Vect3 grads = P1Vector(pts[0], pts[1], pts[2], j);
            for(int i=0;i<3;i++) {
                grad(3*t+i,trg[j]) = grads(i);
            }
        }
    }

    int nz = grad.size();
    plhs[0] = mxCreateDoubleMatrix(3,nz,mxREAL);
    double* grad_linear = mxGetPr(plhs[0]);

    int cnt = 0;
    for(SparseMatrix::const_iterator it = grad.begin(); it != grad.end(); ++it) {
        grad_linear[3*cnt + 0] = (double) it->first.first;
        grad_linear[3*cnt + 1] = (double) it->first.second;
        grad_linear[3*cnt + 2] = (double) it->second;
        cnt++;
    }

    return;
}
