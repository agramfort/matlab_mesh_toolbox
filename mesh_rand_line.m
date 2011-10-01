function idx = mesh_rand_line(points,faces,npoints,idx_init,direction)
%   MESH_RAND_LINE   Short description
%       [IDX] = MESH_RAND_LINE(FACES,NPOINTS,IDX_INIT)
%
%   Find a series of connected points over the mesh
%
%   this function is part of the EMBAL toolbox, see COPYING for license
%
%   Copyright (c) 2009 Alexandre Gramfort. All rights reserved.


if nargin<4
    idx_init = faces(randinteger(1,1,[1 size(points,1)]));
end

links = mesh_connectivity(points,faces);
idx_current = idx_init;
idx = zeros(1,npoints);
idx(1) = idx_init;
for ii=2:npoints
    nidx = randinteger(1,1,[1 length(links{idx(ii-1)})]);
    [tmp,nidx] = max(points(links{idx(ii-1)},2));
    [tmp,nidx] = min(points(links{idx(ii-1)},2));
    % if direction > 0
    %     [tmp,nidx] = min(points(links{idx(ii-1)},direction));
    % else
    %     [tmp,nidx] = max(points(links{idx(ii-1)},-direction));
    % end
    idx(ii) = links{idx(ii-1)}(nidx);
end

end %  function