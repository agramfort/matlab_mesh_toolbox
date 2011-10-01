function [] = mesh_info(points,faces)

% MESH_INFO   Display info on mesh
%
%   SYNTAX
%       [] = MESH_INFO(POINTS,FACES)
%
%   Created by Alexandre Gramfort on 2008-02-19.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_INFO';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

areas = mesh_areas(points,faces);
components = mesh_components(faces);

ncomponents = max(components);
components_size = zeros(1,ncomponents);
for c=1:max(components)
    components_size(c) = numel(find(components==c));
end

min_area = min(areas(:));
max_area = max(areas(:));
disp('--- Inspecting mesh :')
disp(['Nb points : ',num2str(size(points,1))])
disp(['Nb faces : ',num2str(size(faces,1))])
disp(['Min area : ',num2str(min_area)])
disp(['Max area : ',num2str(max_area)])
disp(['Nb components : ',num2str(ncomponents)])
disp(['Components sizes : ',num2str(components_size)])
disp(['Is closed : ',num2str(mesh_is_closed(faces))])
% disp(['Euler : ',num2str(euler)])

end %  function

