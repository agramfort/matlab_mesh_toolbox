function [mixedRGB,activations_colormap,min_activations,max_activations] = blend_data(background,activations,options)

% BLEND_DATA   Blend activations data with background texture like the curvature
%
%   SYNTAX
%       [MIXEDRGB,ACTIVATIONS_COLORMAP,MIN_ACTIVATIONS,MAX_ACTIVATIONS] =
%               BLEND_DATA(BACKGROUND,ACTIVATIONS,OPTIONS)
%
%
%   Created by Alexandre Gramfort on 2008-02-14.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.

me = 'BLEND_DATA';

if nargin < 3
    options.null = 1;
end

if nargin == 0
    activations = [0 1];
end

if ~isfield(options, 'colors_transparency')
    options.colors_transparency = 0.2;
end
colors_transparency = options.colors_transparency;

if ~isfield(options, 'background_colors')
    options.background_colors = [.2 .2 .2; .6 .6 .6];
end
background_colors = options.background_colors;

if ~isfield(options, 'no_color')
    options.no_color = 0;
end
no_color_value = options.no_color;

if ~isfield(options, 'activations_colormap')
    % color1 = hot(140);
    % color2 = color1(:,[3 2 1]);
    % tmp = flipud([flipud(color1);color2]);
    % options.activations_colormap = tmp(40:240,:);
    options.activations_colormap = jet(64);
end
activations_colormap = options.activations_colormap;
ncolors = size(activations_colormap,1);

if isfield(options, 'colormax')
    activations( activations > options.colormax ) = options.colormax;
    % activations( activations < -options.colormax ) = -options.colormax;
else
    options.colormax = max(activations);
end
colormax = options.colormax;

if isfield(options, 'colormin')
    activations( activations < options.colormin ) = options.colormin;
else
    options.colormin = min(activations);
end
colormin = options.colormin;

if isfield(options, 'mask')
    toBlend = find(options.mask);
end

if nargin == 0
    eval(['help ',lower(me)])
    options = rmfield(options,'null')
    return
end

% ****************************************************************************** %

if size(background_colors,1) == 2
    % Anatomy colormap - articifical zero padding
    background_colormap = [background_colors(1,:);zeros(ncolors-2,3);background_colors(2,:)];
elseif size(background_colors,1) > 2
    background_colormap = background_colors;
end

% Translate anatomy background in RGB values
min_background = min(background);
max_background = max(background);
if max_background == min_background % No background encoding
    color_index_background = ncolors * ones(size(background));
else
    color_index_background = floor((background-min_background)*(ncolors-1)/(max_background-min_background)+1);
end

color_index_background(isnan(color_index_background)) = 1;
background_RGB = background_colormap(color_index_background,:); clear color_index_background

% Translate activations in RGB values
min_activations = min(activations);
max_activations = max(activations);
npoints = length(activations);

if max_background == min_background % No background encoding
    color_index_activations = ncolors * ones(npoints,1);
else
    % color_index_activations = floor((activations-min_activations)*(ncolors-1)/(max_activations-min_activations)+1);
    color_index_activations = floor((activations-colormin)*(ncolors-1)/(colormax-colormin)+1);
end

color_index_activations(isnan(color_index_activations)) = 1;

if ~isfield(options, 'mask')
    toBlend = find(activations ~= no_color_value); % Find vertex indices holding non-zero activation (after thresholding)
end

colors_RGB = zeros(npoints,3);
colors_RGB(toBlend,:) = activations_colormap(color_index_activations(toBlend),:);

% Now mix background and current RGBs
mixedRGB = background_RGB;
mixedRGB(toBlend,:) = colors_transparency*background_RGB(toBlend,:) + (1-colors_transparency)*colors_RGB(toBlend,:);
