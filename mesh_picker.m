function point_index = mesh_picker(mesh_name)
% MESH_PICKER   Pick 3d point on a mesh
%       [POINT_INDEX] = MESH_PICKER(MESH_NAME)
%
%   Created by Alexandre Gramfort on 2008-05-28.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_PICKER';

if nargin == 0
    mesh_name = 'mesh';
end

hm = findobj(gca,'Tag',mesh_name);

if ~isempty(hm)
    [p, v, point_index] = select3d(hm);
    if ~isempty(point_index)

        hscat = findobj(gca,'Tag','ClickedPoint');
        if ~isempty(hscat)
            delete(hscat)
        end

        points = get(hm,'vertices');
        point = points(point_index,:);

        face_vertex_color = get(hm,'FaceVertexCData');
        if ~isempty(face_vertex_color)
            disp(['Mesh pick - Point : ', num2str(point_index),' , value : ',num2str(face_vertex_color(point_index,:))]);
        else
            disp(['Mesh pick - Point : ', num2str(point_index)]);
        end

        hold on;
        hscat = scatter3(point(1),point(2),point(3),100,'g','filled','MarkerEdgeColor', [1 0 0],'LineWidth',2);
        disp(['Point position : ',num2str(point)])
        set(hscat,'Tag','ClickedPoint');
        hold off;
    else
        hscat = findobj(gca,'Tag','ClickedPoint');
        if ~isempty(hscat)
            delete(hscat)
        end
        disp('Unable to pick a point on the mesh');
    end
end

end % function