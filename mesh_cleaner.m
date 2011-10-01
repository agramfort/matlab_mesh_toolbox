function [points] = mesh_cleaner(points,faces,options)
%   MESH_CLEANER
%       [POINTS] = MESH_CLEANER(POINTS,FACES,OPTIONS)
%
%   Tries to clean mesh by smoothing locally where tesselation is bad
%
%   Created by Alexandre Gramfort on 2008-12-01.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


if nargin<3
    options.null = 0;
end

if ~isfield(options, 'smoothing')
    options.smoothing = 0.75;
    options.smoothing = 0.9;
end
smoothing = options.smoothing;

if ~isfield(options, 'nsize')
    options.nsize = 1;
end
nsize = options.nsize;

if ~isfield(options, 'niter')
    options.niter = 30;
end
niter = options.niter;

if isfield(options, 'null')
    options = rmfield(options,'null');
end

npoints = size(points,1);

[face_normals, face_areas, centers, normals, point_areas, suspect_faces, nfaces_per_point, duplicated_faces, not_twice_faces] = mesh_stats(points,faces,false);

suspect_faces = find(suspect_faces);

no_fix_points_idx = faces(suspect_faces,:);
no_fix_points_idx = unique(no_fix_points_idx(:));
edges = (mesh_edges(faces)>0);

for ii=1:nsize
    [ii,jj] = find(edges(no_fix_points_idx,:));
    no_fix_points_idx = unique([no_fix_points_idx;jj]);
end

disp(['no_fix_points_idx : ',num2str(length(no_fix_points_idx))]);

options.fix_points = zeros(npoints,1);
options.fix_points(setdiff(1:npoints,no_fix_points_idx)) = 1;

A = mesh_smoothing_matrix(points,faces,options);

for ii=1:niter
    progressbar(ii,niter)
    % mesh_display_faces(points,faces,22032);
    % mesh_display_faces(points,faces,61778);
    % drawnow
    % pause
    % pause(0.1)
    points = A*points;
end

end %  function