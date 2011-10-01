function [] = save_off(filename,points,faces)

% SAVE_OFF   Save .off mesh file
%
%   SYNTAX
%       [] = SAVE_OFF(FILENAME,POINTS,FACES)
%
% 
%
%   Created by Alexandre Gramfort on 2008-03-27.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.
%

me = 'SAVE_OFF';

if size(points,2)~=3
    points=points';
end
if size(points,2)~=3
    error('points does not have the correct format.');
end

if size(faces,2)~=3
    faces=faces';
end
if size(faces,2)~=3
    error('faces does not have the correct format.');
end

fid = fopen(filename,'wt');
if( fid==-1 )
    error('Can''t open the file.');
    return;
end

% header
fprintf(fid, 'OFF\n');
fprintf(fid, '%d %d 0\n', size(points,1), size(faces,1));

% write the points & facess
fprintf(fid, '%f %f %f\n', points');
fprintf(fid, '3 %d %d %d\n', faces'-1);

fclose(fid);