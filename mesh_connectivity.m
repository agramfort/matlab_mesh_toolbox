function [links] = mesh_connectivity(points,faces)

% MESH_CONNECTIVITY   Computes mesh connectivity
%
%   links{i} = index list of neighboring points for point i
%
%   SYNTAX
%       [LINKS] = MESH_CONNECTIVITY(POINTS,FACES)
%
%   Created by Alexandre Gramfort on 2007-11-19.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


if nargin == 0
    eval(['help ',lower(me)])
    return
end

if exist('mesh_connectivity_mex','file') % Try to use mex code
    disp('Computing Connectivity (Mex File)')
    links = mesh_connectivity_mex(double(points),double(faces));
    return;
end

% slow code

disp('Computing Connectivity (slow code)')
npoints = size(points,1);
links = cell(npoints,1);
for ii=1:npoints
    progressbar(ii,npoints);
    % fidx = find(sum(faces==ii,2));
    neighbors = faces(sum(faces==ii,2) ~= 0,:);
    neighbors = unique(neighbors(:));
    links{ii} = neighbors(neighbors ~= ii);
end

end %  function
