// $Id: graph.cpp 171 2009-10-22 13:23:06Z gramfort $
// $LastChangedBy: gramfort $
// $LastChangedDate: 2009-10-22 15:23:06 +0200 (Thu, 22 Oct 2009) $
// $Revision: 171 $

#include "graph.h"

int Vertex::m_count=0;

Graph::Graph()
{
}

int Graph::ne() const
{
    int r=0;
    for (vector<Vertex*>::const_iterator i = m_vertices.begin(); i!=m_vertices.end(); i++)
        r += (*i)->getAdj();
    return r/2;
}

Graph::Graph(const mxArray* mat) {
    Vertex::m_count = 0; // Reset static counter

    int nv = mxGetM(mat);
    for(int i=0; i < nv; ++i) {
        Vertex * v = new Vertex();
        m_vertices.push_back(v);
    }
    if(mxIsSparse(mat)) {
        mwIndex  *ir  = mxGetIr(mat); // row indexes
        mwIndex *jc  = mxGetJc(mat); // 
        double *data  = mxGetPr(mat);
        int nz = mxGetNzmax(mat);

        int current_col = 0;
        for (int k = 0; k < nz; ++k) {
            int i = ir[k];
            double val = data[k];
            while((int) jc[current_col + 1] <= k) { // look for the last idx of jc such that jc[idx+1] > k
                current_col++;
            }
            int j = current_col;
            if(current_col < nv) {
                m_vertices[i]->addNgh(j,val);
            }
        }
    } else {
        double* adj = mxGetPr(mat);
        for(int i=0; i < nv; ++i) {
            for(int j = 0; j < nv; ++j) {
                if(adj[j*nv+i] != 0.0) {
                    m_vertices[i]->addNgh(j,adj[j*nv+i]);
                }
            }
        }
    }
}

void Graph::getDist(int iref, double* dist, double dist_max)
{
    // labels >= 2 : active
    // labels == 1 : trial
    // labels == 0 : far
    vector<int> labels(nv());
    for(size_t i = 0; i < nv(); ++i) { // set everyone to far
        labels[i] = 0.0;
    }

    if(dist_max < 0) {
        dist_max = numeric_limits<double>::max()/2.0;
    }

    Heap h;
    // initialize
    for(int i = 0; i < nv(); ++i) {
        dist[i] = numeric_limits<double>::max()/2.0;
    }
    labels[iref] = 2; // set iref to alive
    dist[iref] = 0.0;
    double d;
    int ii;
    for (set<Edge>::const_iterator i = m_vertices[iref]->begin(); i!= m_vertices[iref]->end(); i++)
    {
        ii = (*i).first;
        labels[ii] = 1;
        d = (*i).second;
        m_vertices[ii]->setPriority(d);
        dist[ii] = d;
        h.push(m_vertices[ii]);
    }

    Vertex* x;
    double u;
    int ix,iy;
    while (!h.empty())
    {
        x = h.top();
        h.pop();
        ix = x->getIndex();
        labels[ix] = 2; // set point to alive
        if(dist[ix] >= dist_max) {
            return;
        }
        for (set<Edge>::const_iterator y = x->begin(); y!= x->end(); ++y) { // iterate on neighbors of x
            iy = (*y).first;
            if (labels[iy] == 0) { // if neighbor is far
                labels[iy] = 1; // add it to trial
                u = computeU(iy,dist);
                dist[iy] = u;
                m_vertices[iy]->setPriority(u);
                h.push(m_vertices[iy]);
            } else if (labels[iy] == 1) { // if neighbor is in trial
                u = computeU(iy,dist);
                if (u < dist[iy]) {
                    dist[iy] = u;
                    m_vertices[iy]->setPriority(u);
                }
            }
        }
    }
    return;
}

double Graph::computeU(int ix, double* dist)
{
    Vertex* x = m_vertices[ix];
    vector<double> values;
    values.clear();
    int iy;
    for (set<Edge>::const_iterator y = x->begin(); y!= x->end(); y++) // iterate on neighbors of x
    {
        iy = (*y).first;
        values.push_back(dist[iy] + (*y).second);
    }
    return *min_element(values.begin(), values.end());
}
