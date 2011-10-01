function save_smf(filename, points, faces, renormalize);

% SAVE_SMF - write a mesh to a SMF file
%
%   SAVE_SMF(FILENAME, POINTS, FACES)
%


if nargin<4
    renormalize = 0;
end

if size(points,2)~=3
    points=points';
end
if size(points,2)~=3
    error('points does not have the correct format.');
end

if renormalize==1
    m = mean(points);
    s = std(points);
    for i=1:3
        points(:,i) = (points(:,i)-m(i))/s(i);
    end
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
fprintf(fid, '#$SMF 1.0\n');
fprintf(fid, '#$vertices %d\n#$faces %d\n', size(points,1), size(faces,1));

% write the points & faces
fprintf(fid, 'v %f %f %f\n', points');
fprintf(fid, 'f %d %d %d\n', faces');

fclose(fid);