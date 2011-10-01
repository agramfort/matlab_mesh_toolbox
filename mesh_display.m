function [h,hn] = mesh_display(points,faces,options)

% mesh_display - plot a 3D mesh with a lot of options
%
%   mesh_display(points,faces, options);
%
%   'options' is a structure that may contains:
%       - 'normals' : a (nvertx x 3) array specifying the normals at each points.
%       - 'edge_color' : a float specifying the color of the edges.
%       - 'face_color' : a float specifying the color of the faces.
%       - 'face_vertex_color' : a color per points or face.
%       - 'points'
%
%   Copyright (c) 2007-2011 Alexandre Gramfort


if nargin<3
    options.null = 0;
end

if ~isfield(options, 'camera_mode')
    options.camera_mode = 0; % 0 : default , 1 : fixed, 2 : with full interactor
end
camera_mode = options.camera_mode;

% can flip to accept data in correct ordering
if size(points,1)==3 && size(points,2)~=3
    points = points';
end
if size(faces,1)==3 && size(faces,2)~=3
    faces = faces';
end

if size(faces,2)~=3 || size(points,2)~=3
    error('faces or points does not have correct format.');
end

if ~isfield(options, 'normals')
    options.normals = [];
end
normals = options.normals;

if ~isfield(options, 'normals_scale')
    options.normals_scale = 1;
end
normals_scale = options.normals_scale;

if ~isfield(options, 'face_color')
    % options.face_color = [0.7 0.7 0.7];
    options.face_color = [.8 .55 .35]*1.1; % caucasion skin
end
face_color = options.face_color;

if ~isfield(options, 'edge_color')
    options.edge_color = 'none';
end
edge_color = options.edge_color;

if ~isfield(options, 'face_alpha')
    options.face_alpha = 1;
end
face_alpha = options.face_alpha;

if ~isfield(options, 'cmap')
    options.cmap = gray(256);
end
cmap = options.cmap;

if ~isfield(options, 'mesh_name')
    options.mesh_name = 'mesh';
end
mesh_name = options.mesh_name;

if ~isfield(options, 'double_click_action')
    options.double_click_action = 'mesh_picker;';
end
double_click_action = options.double_click_action;

if ~isfield(options, 'face_vertex_color')
    h = patch('vertices',points,'faces',faces,'facecolor',face_color,'edgecolor', ...
               edge_color,'FaceAlpha',face_alpha);
else
    face_vertex_color = double(options.face_vertex_color);
    if size(face_vertex_color,1) == size(faces,1)
        h = patch('vertices',points,'faces',faces,'FaceVertexCData',face_vertex_color,'FaceColor','flat', ...
                  'edgecolor',edge_color,'FaceAlpha',face_alpha);
    else
        h = patch('vertices',points,'faces',faces,'FaceVertexCData',face_vertex_color,'FaceColor','interp', ...
                  'edgecolor',edge_color,'FaceAlpha',face_alpha);
    end
end

set(h,'Tag',mesh_name);

if ~isfield(options, 'lights')
    options.lights = true;
end
lights = options.lights;

if lights
    hl(1) = camlight(0,40,'infinite');
    hl(2) = camlight(90,40,'infinite');
    hl(2) = camlight(180,40,'infinite');
    hl(2) = camlight(270,40,'infinite');

    hl(1) = camlight(0,-40,'infinite');
    hl(2) = camlight(90,-40,'infinite');
    hl(2) = camlight(180,-40,'infinite');
    hl(2) = camlight(270,-40,'infinite');
end

lighting phong;
% material dull
% material shiny
material([ 0.00 0.50 0.20 2.00 1.00 ])

% camproj('perspective');
axis square;
axis off;

if ~isempty(normals)
    % plot the normals
    hold on;
    hn = quiver3(points(:,1),points(:,2),points(:,3),normals(:,1),normals(:,2),normals(:,3),normals_scale,'g','LineWidth',2);
    set(hn,'Tag','normals');
    hold off;
end

axis tight;
axis equal;

if isfield(options,'comment')
    set(gcf,'Name',options.comment);
end

if isfield(options,'caxis')
    % colorbar
    caxis(options.caxis)
end

switch camera_mode
case 0
    cameramenu
    return
case 1
    return
case 2
    % cameramenu
    axis(gca,'vis3d')
    set(gcf, 'renderer', 'opengl');
    % set(gcf,'MenuBar','none','Toolbar','none', 'DockControls', 'on','Units','normalized', ...
    set(gcf,'MenuBar','none','Toolbar','none', 'DockControls', 'on','Units','normalized','Color',[0 0 0], ...
                  'WindowButtonDownFcn', @(h,ev)FigureClickCallback(h,double_click_action), ...
                  'WindowButtonMotionFcn', @FigureMouseMoveCallback, ...
                  'WindowButtonUpFcn',     @FigureMouseUpCallback)
              % 'KeyPressFcn',           @(h,ev)bst_safeCall(@FigureKeyPressedCallback,h,ev), ...
    return
end

drawnow

%%%%%%%%%%%%%%%%%%%%%
% === callbacks === %
%%%%%%%%%%%%%%%%%%%%%

function FigureClickCallback(hFig, double_click_action)
    % Start an action (pan, zoom, rotate, contrast, luminosity)
    % Action depends on :
    %    - the mouse button that was pressed (LEFT/RIGHT/MIDDLE),
    %    - the keys that the user presses simultaneously
    %
    % Possible combinations
    %     - Left click ('normal')                : ROTATE
    %     - Left click ('normal') + keyALT       : ZOOM
    %     - Mouse wheel                          : ZOOM
    %     - Right click, or CTRL + click ('ALT') : CONTRAST/LUMINOSITY
    %     - SHIFT+click ('extended')             : PAN
    %     - double click ('open')                : ZOOM RESET (already processed)
    clickAction = '';
    switch(get(hFig, 'SelectionType'))
        % double click
    case 'open'
        if ~isempty(double_click_action)
            eval(double_click_action);
        end
        return
        % Left click
    case 'normal'
        % If 3D: rotate
        clickAction = 'rotate';
        % CTRL+Mouse, or Mouse right
    case 'alt'
        % POPUP MENU
        clickAction = 'popup';
        % SHIFT+Mouse
    case 'extend'
        clickAction = 'pan';
    end

    hAxes = gca;

    % If no action was defined : nothing to do more
    if isempty(clickAction)
        return
    end

    % Reset the motion flag
    setappdata(hFig, 'hasMoved', 0);
    % Record mouse location in the figure coordinates system
    setappdata(hFig, 'clickPositionFigure', get(hFig, 'CurrentPoint'));
    % Record other values useful for the mouse motion processing
    setappdata(hFig, 'clickSource', hAxes);
    % Record action to perform when the mouse is moved
    setappdata(hFig, 'clickAction', clickAction);
end

%% ===== FIGURE MOVE =====
function FigureMouseMoveCallback(hFig, varargin)
    % Get current mouse action
    clickAction = getappdata(hFig, 'clickAction');
    % ONLY FOR 3D
    % If no action is currently performed
    if isempty(clickAction)
        return
    end
    % Get axes handle
    hAxes = getappdata(hFig, 'clickSource');
    % Set the motion flag
    setappdata(hFig, 'hasMoved', 1);
    % Get current mouse location
    curptFigure = get(hFig, 'CurrentPoint');
    motionFigure = 200 * (curptFigure - getappdata(hFig, 'clickPositionFigure'));
    % Update click point location
    setappdata(hFig, 'clickPositionFigure', curptFigure);

    % Switch between different actions (Pan, Rotate, Zoom, Contrast)
    switch(clickAction)
    case 'rotate'
        % Else : ROTATION
        % Rotation functions : 5 different areas in the figure window
        %     ,---------------------------.
        %     |             2             |
        % .75 |---------------------------|
        %     |   3  |      5      |  4   |
        %     |      |             |      |
        % .25 |---------------------------|
        %     |             1             |
        %     '---------------------------'
        %           .25           .75
        %
        % ----- AREA 1 -----
        if (curptFigure(2) < .25)
            camroll(motionFigure(1));
            camorbit(0,-motionFigure(2), 'camera');
            % ----- AREA 2 -----
        elseif (curptFigure(2) > .75)
            camroll(-motionFigure(1));
            camorbit(0,-motionFigure(2), 'camera');
            % ----- AREA 3 -----
        elseif (curptFigure(1) < .25)
            camroll(-motionFigure(2));
            camorbit(-motionFigure(1),0, 'camera');
            % ----- AREA 4 -----
        elseif (curptFigure(1) > .75)
            camroll(motionFigure(2));
            camorbit(-motionFigure(1),0, 'camera');
            % ----- AREA 5 -----
        else
            camorbit(-motionFigure(1),-motionFigure(2), 'camera');
        end
        % camlight(findobj(hAxes, 'Tag', 'FrontLight'), 'headlight');

    case 'pan'

        % Get camera textProperties
        pos    = get(hAxes, 'CameraPosition');
        up     = get(hAxes, 'CameraUpVector');
        target = get(hAxes, 'CameraTarget');
        % Calculate a normalised right vector
        right = cross(up, target - pos);
        up    = up ./ realsqrt(sum(up.^2));
        right = right ./ realsqrt(sum(right.^2));
        % Calculate new camera position and camera target
        % pan_speed = .02;
        pan_speed = 1;
        pos    = pos    + pan_speed .* (motionFigure(1).*right - motionFigure(2).*up);
        target = target + pan_speed .* (motionFigure(1).*right - motionFigure(2).*up);
        set(hAxes, 'CameraPosition', pos, 'CameraTarget', target);

    case {'zoom', 'popup'}
        motionFigure(2) = -motionFigure(2);
        if (motionFigure(2) == 0)
            return;
        elseif (motionFigure(2) < 0)
            % ZOOM IN
            Factor = 1-motionFigure(2)./100;
        elseif (motionFigure(2) > 0)
            % ZOOM OUT
            Factor = 1./(1+motionFigure(2)./100);
        end
        zoom(Factor);
    end
end

%% ===== FIGURE MOUSE UP =====
function FigureMouseUpCallback(hFig, varargin)
    % Get application data (current user/mouse actions)
    clickAction = getappdata(hFig, 'clickAction');
    hasMoved    = getappdata(hFig, 'hasMoved');
    hAxes       = getappdata(hFig, 'clickSource');
    isSelectingCorticalSpot = getappdata(hFig, 'isSelectingCorticalSpot');

    % Remove mouse appdata (to stop movements first)
    setappdata(hFig, 'clickSource', []);
    setappdata(hFig, 'hasMoved', 0);
    if isappdata(hFig, 'clickPositionFigure')
        rmappdata(hFig, 'clickPositionFigure');
    end
    if isappdata(hFig, 'clickAction')
        rmappdata(hFig, 'clickAction');
    end
end

end

