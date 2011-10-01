function [] = glyph_display(points,options)

% GLYPH_DISPLAY   Show points in current figure
%
%   SYNTAX
%       [] = GLYPH_DISPLAY(points)
%
%   Created by Alexandre Gramfort on 2008-02-25.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'GLYPH_DISPLAY';

if nargin<2
    options.null = 0;
end

colors = getoption(options,'colors','g');
camera_mode = getoption(options,'camera_mode',0);
glyph_size = getoption(options,'size',100);
marker = getoption(options,'marker','o');

if ~ischar(colors) && size(colors,1) == 1
    colors = repmat(colors,size(points,1),1);
end

orientation_size = getoption(options,'orientation_size',1);
orientation_colors = getoption(options,'orientation_colors',colors);

if nargin == 0
    eval(['help ',lower(me)])
    options = rmfield(options,'null')
    return
end

if ~ischar(orientation_colors) && size(orientation_colors,1) == 1
    orientation_colors = repmat(orientation_colors,size(points,1),1);
end

hs = scatter3(points(:,1),points(:,2),points(:,3),glyph_size,colors,[marker],'filled');
npoints = size(points, 1);

if size(points,2)==6
    hold on;
    if length(orientation_colors) == npoints
        for p=1:npoints
            hn = quiver3(points(p,1),points(p,2),points(p,3), ...
                         points(p,4),points(p,5),points(p,6), ...
                         0.8, 'color', orientation_colors(p, :));
            set(hn,'LineWidth',orientation_size)
        end
    else
        hn = quiver3(points(:,1),points(:,2),points(:,3), ...
                     points(:,4),points(:,5),points(:,6), ...
                     0.8, 'color', orientation_colors);
        set(hn,'LineWidth',orientation_size)
    end
    hold off;
end

switch camera_mode
case 0
    camproj('perspective');
    axis square;
    axis off;
    axis tight;
    axis equal;
    cameramenu;
    return
case 1
    return
case 2
    return
end
