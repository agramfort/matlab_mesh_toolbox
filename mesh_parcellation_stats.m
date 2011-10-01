function [patch_areas,nb_points_per_patch] = mesh_parcellation_stats(points,faces,patches)
%   MESH_PARCELLATION_STATS   Display infos about mesh parcellation
%       [PATCH_AREAS,NB_POINTS_PER_PATCH] = MESH_PARCELLATION_STATS(POINTS,FACES,PATCHES)
%
%   Created by Alexandre Gramfort on 2008-11-07.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


npoints = size(patches,1);
npatches = size(patches,2);
[ii,jj,vv] = find(patches);

nb_points_per_patch = full(sum(patches>0))';

if find(nb_points_per_patch==0)
    warning('Some patches are empty')
end

areas = mesh_cell_areas(points,faces);
[ii,jj] = find(patches>0);
patches_with_areas = sparse(ii,jj,areas(ii),npoints,npatches);

patch_areas = full(sum(patches_with_areas,1))';

if nargout == 0
    disp(['Number of patches : ',num2str(length(patch_areas))]);

    smart_figure('nb_points_per_patch');
    hist(nb_points_per_patch,20);
    xlabel('Nb point');
    title('Nb points per patch');

    smart_figure('areas_per_patch');
    hist(patch_areas,20);
    xlabel('Area');
    xlabel('Nb');
    title('Areas of patch');
end

end %  function