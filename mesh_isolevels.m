function [isolevels] = mesh_isolevels(faces,isovalues)

% MESH_ISOLEVELS   Compute mesh isolevels
%
%   SYNTAX
%       [ISOLEVELS] = MESH_ISOLEVELS(FACES,ISOVALUES)
%
%   Created by Alexandre Gramfort on 2008-03-10.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_ISOLEVELS';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

nfaces = size(faces,1);
[faces_column_sorted,I] = sort(faces(:)); % sorted point numbers
faces_numbers = rem(I-1,nfaces)+1; % triangle number for each point
% For the ith points, then faces_numbers(faces_column_sorted == i) returns the indices of the
% faces attached to the ith points.

isolevels = {};

for l=1:size(isovalues,2)
    progressbar(l,size(isovalues,2));
    if length(find(isovalues(:,l))) > length(find(isovalues(:,l)==0))
        level_points = find(isovalues(:,l)==0);
    else
        level_points = find(isovalues(:,l));
    end
    if ~isempty(level_points)
        level_faces = [];
        for p=1:length(level_points)
            new_level_faces = faces_numbers(faces_column_sorted==level_points(p));
            level_faces = [level_faces;new_level_faces];
        end
        level_faces = unique(level_faces);
        edges = mesh_edges(faces(level_faces,:));
        [ii,jj] = find(edges == 1);
        isolevels{l} = [ii,jj];
    end
end