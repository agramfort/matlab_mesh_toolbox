function [is_closed] = mesh_is_closed(faces)

% MESH_IS_CLOSED   Check if a mesh is closed
%
%   SYNTAX
%       [IS_CLOSED] = MESH_IS_CLOSED(FACES)
%
%
%   Created by Alexandre Gramfort on 2008-02-19.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.
%


if nargin == 0
    eval(['help ',lower(me)])
    return
end

edges = mesh_edges(faces);

[ii,jj,ss] = find(edges);

uss = unique(ss);
is_closed = length(uss) == 1 && uss == 2;

