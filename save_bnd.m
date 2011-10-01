function [] = save_bnd(filename,points,faces,options)

% SAVE_BND   Save .bnd file
%
%   SYNTAX
%       [] = SAVE_BND(FILENAME,POINTS,FACES,OPTIONS)
%
%
%   Created by Alexandre Gramfort on 2008-03-09.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.
%

me = 'SAVE_BND';

if nargin<4
    options.null = 0;
end

if ~isfield(options, 'name')
    options.name = 'Unknown';
end
name = options.name;

if nargin == 0
    eval(['help ',lower(me)])
    options = rmfield(options,'null')
    return
end

npoints = size(points,1);
nfaces = size(faces,1);
faces = faces-1;

fid = fopen(filename,'w');
fprintf(fid,'# File generate with save_bnd.m matlab script\n',npoints);
fprintf(fid,['Type= ',name,'\n']);
fprintf(fid,['NumberPositions= ',num2str(npoints),'\n']);
fprintf(fid,'UnitPosition mm\n');
fprintf(fid,'Positions\n');
fprintf(fid,'%g %g %g\n',points');
fprintf(fid,['NumberPolygons= ',num2str(nfaces),'\n']);
fprintf(fid,'TypePolygons= 3\n');
fprintf(fid,'Polygons\n');
fprintf(fid,'%d %d %d\n',faces');
fclose(fid);

end
