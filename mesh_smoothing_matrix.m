function [A] = mesh_smoothing_matrix(points,faces,options)

% MESH_SMOOTHING_MATRIX
%
%   SYNTAX
%       [A] = MESH_SMOOTHING_MATRIX(POINTS,FACES,OPTIONS)
%
%
%   Created by Alexandre Gramfort on 2008-02-26.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_SMOOTHING_MATRIX';

if nargin<3
    options.null = 0;
end

if ~isfield(options, 'smoothing')
    options.smoothing = 0.75;
end
smoothing = options.smoothing;

if ~isfield(options, 'fix_points')
    options.fix_points = zeros(1,size(points,1));
end
fix_points = options.fix_points;

if nargin == 0
    eval(['help ',lower(me)])
    options = rmfield(options,'null')
    return
end

% ****************************************************************************** %

npoints = size(points,1);
A = mesh_edges(faces);

inv_conn_idx = 1./sum(A,2);
inv_conn_idx(isnan(inv_conn_idx)) = 0;

A = smoothing*spdiags(inv_conn_idx,0,npoints,npoints)*A;
A = A + spdiags(ones(npoints,1)-smoothing,0,npoints,npoints);

fix_points_idx = find(fix_points);
no_fix_points_idx = find(fix_points==0);

if ~isempty(fix_points_idx)
    if length(fix_points_idx) > length(no_fix_points_idx)
        [ii,jj,vv] = find(A(no_fix_points_idx,:));
        A = spdiags(double(fix_points>0),0,npoints,npoints);
        A(no_fix_points_idx,:) = sparse(ii,jj,vv,length(no_fix_points_idx),npoints);
    else
        A(fix_points_idx,:) = 0;
        A(fix_points_idx,fix_points_idx) = 1;
    end
end

end %  function