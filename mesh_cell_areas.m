function [faces_areas] = mesh_cell_areas(points,faces)

% MESH_CELL_AREAS   Compute mesh cell areas
%
%   SYNTAX
%       [FACES_AREAS] = MESH_CELL_AREAS(POINTS,FACES)
%
%   Created by Alexandre Gramfort on 2008-03-10.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_CELL_AREAS';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

nfaces = size(faces,1);
npoints = size(points,1);

[faces_column_sorted,I] = sort(faces(:)); % sorted Vertex numbers
faces_numbers = rem(I-1,nfaces)+1; % triangle number for each Vertex
% For the ith vertex, then faces_numbers(faces_column_sorted == i) returns the indices of the
% faces attached to the ith vertex.

areas = mesh_areas(points,faces);

all_averages = cumsum(areas(faces_numbers));

% now extract each sum
points_idx = find(diff([faces_column_sorted;Inf])); % each idx where a new vertex starts
% pull out the sum for each vertex, then difference from previous vertex to get
% the sum for just that vertex
sorted_averages = diff([0 all_averages(:,points_idx)]);
sorted_averages = sorted_averages/3; % 1/3 assignment
% the average area assigned to each vertex. 1/3 of the area of each triangle is
% assigned equally to it's vertices

% now make sure it is assigned to the right vertex numbers
faces_areas = zeros(npoints,1);
faces_areas(faces_column_sorted(points_idx)) = sorted_averages;

end %  function