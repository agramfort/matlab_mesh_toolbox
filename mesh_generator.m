function faces = mesh_generator(points)
% MESH_GENERATOR   Generate mesh faces for points
%
%       [FACES] = MESH_GENERATOR(POINTS)
%
%   Created by Alexandre Gramfort on 2008-05-21.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.
%

if nargin == 0
    eval(['help ',lower(me)])
    return
end

offset = [mean(points(:,1)) mean(points(:,2)) min(points(:,3))];
prj = elproj(points - repmat(offset, size(points,1), 1));
% prj = elproj(points - repmat(offset, size(points,1), 1),'orthographic');
% prj = elproj(points - repmat(offset, size(points,1), 1),'inverse');
faces = delaunay(prj(:,1), prj(:,2));

% ****************************************************************************** %

function [proj] = elproj(pos, method)

% ELPROJ makes a azimuthal projection of a 3D electrode cloud
%  on a plane tangent to the sphere fitted through the electrodes
%  the projection is along the z-axis
%
%  [proj] = elproj([x, y, z], 'method');
%
% Method should be one of these:
%	'gnomic'
%	'stereographic'
%	'ortographic'
%	'inverse'
%	'default'
%
% Imagine a plane being placed against (tangent to) a globe. If
% a light source inside the globe projects the graticule onto
% the plane the result would be a planar, or azimuthal, map
% projection. If the imaginary light is inside the globe a Gnomonic
% projection results, if the light is antipodal a Sterographic,
% and if at infinity, an Orthographic.
%
% The default projection is an angular projection (BESA like).
% An inverse projection is the opposite of the default angular projection.

% Copyright (C) 2000-2001, Robert Oostenveld
%
% $Log: elproj.m,v $
% Revision 1.2  2003/03/17 10:37:28  roberto
% improved general help comments and added copyrights
%

x = pos(:,1);
y = pos(:,2);
if size(pos, 2)==3
    z = pos(:,3);
end

if nargin<2
    method='default';
end

method

if strcmp(method, 'orthographic')
    % this method compresses the lowest electrodes very much
    % electrodes on the bottom half of the sphere are folded inwards
    xp = x;
    yp = y;
    num = length(find(z<0));
    str = sprintf('%d electrodes may be folded inwards in orthographic projection\n', num);
    if num
        warning('EMBAL:warning',str);
    end
    proj = [xp yp];

elseif strcmp(method, 'gnomic')
    % the lightsource is in the middle of the sphere
    % electrodes on the equator are projected at infinity
    % electrodes below the equator are not projected at all
    rad = mean(sqrt(x.^2 + y.^2 + z.^2));
    phi = cart2pol(x, y);
    th  = atan(sqrt(x.^2 + y.^2) ./ z);
    xp  = cos(phi) .* tan(th) .* rad;
    yp  = sin(phi) .* tan(th) .* rad;
    num = length(find(th==pi/2 | z<0));
    str = sprintf('removing %d electrodes from gnomic projection\n', num);
    if num
        warning('EMBAL:warning',str);
    end
    xp(find(th==pi/2 | z<0)) = NaN;
    yp(find(th==pi/2 | z<0)) = NaN;
    proj = [xp yp];

elseif strcmp(method, 'stereographic')
    % the lightsource is antipodal (on the south-pole)
    rad = mean(sqrt(x.^2 + y.^2 + z.^2));
    z   = z + rad;
    phi = cart2pol(x, y);
    th  = atan(sqrt(x.^2 + y.^2) ./ z);
    xp  = cos(phi) .* tan(th) .* rad * 2;
    yp  = sin(phi) .* tan(th) .* rad * 2;
    num = length(find(th==pi/2 | z<0));
    str = sprintf('removing %d electrodes from stereographic projection\n', num);
    if num
        warning('EMBAL:warning',str);
    end
    xp(find(th==pi/2 | z<0)) = NaN;
    yp(find(th==pi/2 | z<0)) = NaN;
    proj = [xp yp];

elseif strcmp(method, 'inverse')
    % compute the inverse projection of the default angular projection
    [th, r] = cart2pol(x, y);
    [xi, yi, zi] = sph2cart(th, pi/2 - r, 1);
    proj = [xi, yi, zi];

else
    % use default angular projection
    [az, el, r] = cart2sph(x, y, z);
    [x, y] = pol2cart(az, pi/2 - el);
    proj = [x, y];
end
