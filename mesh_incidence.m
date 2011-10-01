function [Ic] = mesh_incidence(faces)
%   MESH_INCIDENCE   Computes mesh incidence matrix
%       [IC] = MESH_INCIDENCE(FACES)
%
%   For each edge number k of the mesh linking (i,j)
%       Ic(i,k)=1 and Ic(j,k)=-1
%
%   Created by Alexandre Gramfort on 2008-06-25.
%   inspired by Gabriel Peyré
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_INCIDENCE';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

A = mesh_adjacency(faces);

%% compute list of edges
[ii,jj] = find(sparse(A));
idx = find(ii<=jj);
ii = ii(idx);
jj = jj(idx);
% number of edges
n = length(ii);
% number of vertices
nverts = size(A,1);

%% build sparse matrix
s = [ones(n,1); -ones(n,1)];
is = [(1:n)'; (1:n)'];
js = [ii(:); jj(:)];
Ic = sparse(is,js,s,n,nverts);
Ic = Ic';

% fix self-linking problem (0)
a = find(ii==jj);
if not(isempty(a))
    for t=a'
        Ic(ii(t),t) = 1;
    end
end

end %  function