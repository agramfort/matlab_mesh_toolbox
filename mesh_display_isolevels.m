function [handles] = mesh_display_isolevels(points,faces,isolevels,options)

% MESH_DISPLAY_ISOLEVELS
%
%   SYNTAX
%       [HANDLES] = MESH_DISPLAY_ISOLEVELS(POINTS,FACES,ISOLEVELS,OPTIONS)
%
%   Created by Alexandre Gramfort on 2008-03-10.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_DISPLAY_ISOLEVELS';

if nargin<4
    options.null = 0;
end

if nargin == 0 % avoid errors when no arguments
    options.cmap = jet(3);
end

if ~isfield(options, 'cmap')
    options.cmap = jet(length(isolevels));
end
cmap = options.cmap;

if ~isfield(options, 'linewidth')
    options.linewidth = 4;
end
linewidth = options.linewidth;

if nargin == 0
    eval(['help ',lower(me)])
    options = rmfield(options,'null')
    return
end

nfaces = size(faces,1);
[faces_column_sorted,I] = sort(faces(:)); % sorted point numbers
faces_numbers = rem(I-1,nfaces)+1; % triangle number for each point
% For the ith points, then faces_numbers(faces_column_sorted == i) returns the indices of the
% faces attached to the ith points.

handles = zeros(1,length(isolevels));

for l=1:length(isolevels)
    if ~isempty(isolevels{l})
        ii = isolevels{l}(:,1);
        jj = isolevels{l}(:,2);
        hold on
        isoh = patch('vertices',points,'faces',[ii,jj],'edgecolor',cmap(l,:));
        set(isoh,'LineWidth',linewidth)
        hold off
        handles(l) = isoh;
    end
end
