function [cpoints,cfaces,cnormals,bidx] = mesh_clean_small_components(points,faces,normals,tol)

% MESH_CLEAN   clean mesh by removing too small components
%
%   SYNTAX
%       [CPOINTS,CFACES,CNORMALS,BIDX] = MESH_CLEAN_SMALL_COMPONENTS(POINTS,FACES,NORMALS,TOL)
%
%   Created by Alexandre Gramfort on 2008-02-19.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_CLEAN';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

components = mesh_components(faces);
unique_components = unique(components);
bidx = [];
for c=1:length(unique_components)
    cidx = find(components==c);
    if length(cidx) < tol
        bidx = [bidx,cidx];
    end
end

[cpoints,cfaces,cnormals] = mesh_remove_points(points,faces,normals,bidx);
disp(['Removing ',num2str(length(bidx)),' points'])

end %  function
