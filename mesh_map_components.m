function [map_components,components_area] = mesh_map_components(points,faces,map)
%   MESH_MAP_COMPONENTS   Compute connected components in activation map and return their sizes
%       [MAP_COMPONENTS,COMPONENTS_AREA] = MESH_MAP_COMPONENTS(POINTS,FACES,MAP)
%
%   Created by Alexandre Gramfort on 2008-11-13.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


if size(map,2) ~= 1
    error('MESH_MAP_COMPONENTS map should be a column vector');
end

active_idx = find(map~=0);

[points_active,faces_active] = mesh_remove_points(points,faces,[],find(map==0));
npoints_active = size(points_active,1);

components = mesh_components(faces_active);

% Hack : pad with zeros
if length(components) < npoints_active
    missing_points = (length(components)+1):npoints_active;
    nmissing_points = length(missing_points);
    if isempty(components)
        max_comp = 0;
    else
        max_comp = max(components);
    end
    components(missing_points) = max_comp+(1:nmissing_points);
end

map_components = zeros(length(map),1);
map_components(active_idx) = components;

areas = mesh_cell_areas(points,faces);

unique_components = sort(unique(map_components));

for ii=2:length(unique_components)
    idx = find(components==unique_components(ii));
    components_area(unique_components(ii)) = sum(areas(idx));
end

end %  function