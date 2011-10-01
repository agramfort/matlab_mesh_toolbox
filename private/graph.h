// $Id: graph.h 171 2009-10-22 13:23:06Z gramfort $
// $LastChangedBy: gramfort $
// $LastChangedDate: 2009-10-22 15:23:06 +0200 (Thu, 22 Oct 2009) $
// $Revision: 171 $

#ifndef _GRAPH_H_
#define _GRAPH_H_

#include <vector>
#include <set>
#include <fstream>
#include <iostream>
#include <queue>
#include <map>
#include <limits>
#include <functional>
#include <algorithm>
#include <utility>
#include <cmath>

#include "mex.h"

using namespace std;

class Vertex;

typedef std::pair<int,double> Edge; // index of other vertex and edge weight

class Vertex
{
public:
    inline set<Edge>::const_iterator begin() const {return m_edges.begin();};
    inline set<Edge>::const_iterator end() const {return m_edges.end();};

    inline int getAdj() const {return m_edges.size();};
    inline int getIndex() const {return m_index;};
    inline double getPriority() const {return m_priority;};
    inline void setPriority(double priority) {m_priority = priority;};
    inline void addNgh(int i, double dist)
    {
        Edge e(i,dist);
        m_edges.insert(e);
    };

    inline ~Vertex(){
    };

    Vertex & operator=(const Vertex&);

    friend class Graph;

private:
    inline Vertex():m_index(m_count++){};
    static int m_count;
    const int m_index;
    double m_priority;
    std::set<Edge> m_edges;
};

struct Greater:public std::binary_function<Vertex*, Vertex*, bool>
{
public:
    bool operator()(const Vertex* v1, const Vertex* v2)  const
    {
        return v1->getPriority() > v2->getPriority();
    }
};

typedef std::vector<Vertex*> HeapContainer;
typedef std::priority_queue<Vertex*, HeapContainer, Greater> Heap;

class Graph
{
public:
    inline Vertex* operator()(int i) const {return m_vertices[i];};
    Graph(double *, int);
    Graph(const mxArray *);
    Graph(const Graph &);
    Graph & operator=(const Graph&);
    Graph();
    inline int nv() const {return m_vertices.size();};
    int ne() const;
    void getDist(int, double*, double dist_max = -1);
    double distance(int ,int);
    double computeU(int , double*);
    inline ~Graph() {
        for(vector<Vertex*>::iterator i = m_vertices.begin(); i != m_vertices.end(); ++i) delete (*i);
    };

private:
    std::vector<Vertex*> m_vertices;
};

inline std::ostream& operator<<(std::ostream& f,const Graph &g) {
    f << "Graph "            << endl;
    f << "\tNb of vertices     : " << g.nv() << endl;
    f << "\tNb of egdes        : " << g.ne() << endl;
    return f;
}

#endif
