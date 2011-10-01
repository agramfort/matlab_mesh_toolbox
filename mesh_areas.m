function [areas] = mesh_areas(points,faces)

% MESH_AREAS   compute areas of each face
%
%   SYNTAX
%       [AREAS] = MESH_AREAS(POINTS,FACES)
%
%   Created by Alexandre Gramfort on 2008-02-19.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_AREAS';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

v1 = points(faces(:,2),:)-points(faces(:,1),:);
v2 = points(faces(:,3),:)-points(faces(:,1),:);

areas = cross(v1',v2') / 2;
areas = sqrt(sum(areas.^2,1));

end %  function
