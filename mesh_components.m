function [labels] = mesh_components(faces)
%   MESH_COMPONENTS   Compute connected or strongly connected components of a mesh
%       [LABELS] = MESH_COMPONENTS(FACES)
%
%   LABELS : N x 1 vector. LABELS(i) is the index of the components vertex i belongs to
%
%   Created by Alexandre Gramfort on 2008-06-25.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_COMPONENTS';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

if isempty(faces)
    labels = [];
    return;
end

A = mesh_combinatorial_laplacian(faces);

[n,m] = size(A);
if n ~= m, error ('Adjacency matrix must be square'), end;

if ~all(diag(A))
    [p,p,r,r] = dmperm(A|speye(size(A)));
else
    [p,p,r,r] = dmperm(A);
end;

% Now the i-th component of A(p,p) is r(i):r(i+1)-1.

sizes = diff(r);        % Sizes of components, in vertices.
k = length(sizes);      % Number of components.

% Now compute an array "labels" that maps vertices of A to components;
% First, it will map vertices of A(p,p) to components...

labels = zeros(1,n);
labels(r(1:k)) = ones(1,k);
labels = cumsum(labels);

% Second, permute it so it maps vertices of A to components.

labels(p) = labels;
labels = labels(:);
