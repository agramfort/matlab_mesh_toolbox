function hm = mesh_display_light(points,faces,vals)
%   MESH_DISPLAY_LIGHT   Show mesh with a colors defined by vals
%       [HM] = MESH_DISPLAY_LIGHT(POINTS,FACES,VALS)
%
%   Created by Alexandre Gramfort on 2008-06-03.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_DISPLAY_LIGHT';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

options.face_vertex_color = vals;

hm = mesh_display(points,faces,options);

end %  function