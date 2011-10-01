function [nearest_index,nearest_points] = mesh_vertex_nearest(vertices,points)
% mesh_vertex_nearest - find nearest vertices to specified points
%
% Usage: [NEAREST_INDEX,NEAREST_POINTS] = MESH_VERTEX_NEAREST(VERTICES,POINTS)
%
% vertices is a Vx3 matrix of 3D Cartesian coordinates.
% points is a Px3 matrix of 3D Cartesian coordinates.  These points need not
% be among the vertices, but they are somewhere near to particular points
% in the vertices cloud.  The function finds just one of the nearest
% vertices in the cloud for each of these points.
%
% nearest_index is the indices into vertices nearest to points
% nearest_points is the coordinates for nearest_index
%
% This function is just a wrapper for dsearchn.

% $Id: $

nearest_index = dsearchn(vertices,points);
nearest_points = vertices(nearest_index,:);
