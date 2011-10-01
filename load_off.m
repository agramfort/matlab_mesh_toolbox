function [points,faces] = load_off(filename)

% LOAD_OFF   Load .off mesh files
%
%   SYNTAX
%       [POINTS,FACES] = LOAD_OFF(FILENAME)
%
%   Created by Alexandre Gramfort on 2008-03-27.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'LOAD_OFF';

fid = fopen(filename,'r');
if( fid==-1 )
    error('Can''t open the file.');
    return;
end

str = fgets(fid);
if ~strcmp(str(1:3), 'OFF')
    error('The file is not valid');
end

str = fgets(fid);
[a,str] = strtok(str); npoints = str2num(a);
[a,str] = strtok(str); nfaces = str2num(a);

[A,cnt] = fscanf(fid,'%f %f %f', 3*npoints);
if cnt ~= 3*npoints
    warning('EMBAL:warning','Problem reading points.');
end
A = reshape(A, 3, cnt/3);
points = A';

[A,cnt] = fscanf(fid,'%d %d %d %d\n', 4*nfaces);
if cnt~=4*nfaces
    warning('Problem reading faces.');
end
A = reshape(A, 4, cnt/4);
faces = A(2:4,:)+1;
faces = faces';

fclose(fid);

end %  function

