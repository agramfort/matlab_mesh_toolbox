function [bidx] = mesh_border(faces)

% MESH_BORDER   Find the indexes of the points of the border of the mesh
%
%   SYNTAX
%       [BIDX] = MESH_BORDER(FACES)
%
%   Created by Alexandre Gramfort on 2008-01-23.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_BORDER';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

if size(faces,1)<size(faces,2)
    faces=faces';
end

npoints=double(max(faces(:)));

A = mesh_edges(faces);

for ii=1:npoints
    u=find(A(ii,:)==1);
    if ~isempty(u)
        bidx=[ii u(1)];
        break;
    end
end

s=bidx(2);
ii=2;
while(ii<=npoints)
    u=find(A(s,:)==1);
    if length(u)~=2
        warning('EMBAL:warning','Problem in the identification of a border index');
    end
    if u(1)==bidx(ii-1)
        s=u(2);
    else
        s=u(1);
    end
    if s~=bidx(1)
        bidx=[bidx s];
    else
        break;
    end
    ii=ii+1;
end

end %  function
