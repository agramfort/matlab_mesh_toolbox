function [L] = mesh_combinatorial_laplacian(faces)
%   MESH_COMBINATORIAL_LAPLACIAN   Computes the combinatorial laplacian of a mesh
%       [L] = MESH_COMBINATORIAL_LAPLACIAN(FACES)
%
%   L : is the laplacian
%
%       L(i,j) = -1 if i != j and i is connected to j
%       L(i,i) = - sum_j L(i,j)
%       L(i,j) = 0  otherwise
%
%   Created by Alexandre Gramfort on 2008-06-25.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_COMBINATORIAL_LAPLACIAN';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

Ic = mesh_incidence(faces);

L = Ic*Ic';

end %  function