function [points,faces] = load_smf(filename)

% load_smf - read data from SMF file.
%
%   [points,faces] = load_smf(filename);
%


fid = fopen(filename,'r');
if( fid==-1 )
    error('Can''t open the file.');
    return;
end

points = [];
faces = [];

tmp = 1;
while ( ~isempty(tmp) )
    tmp = fscanf(fid, '%s %g %g %g', [4 inf]);
    if isempty(tmp)
        continue
    end
    idx = find(tmp(1,:) == uint8('v'));
    if ~isempty(idx)
        points = [points,tmp(2:4,idx)];
    end
    idx = find(tmp(1,:) == uint8('t'));
    idx = [idx ; find(tmp(1,:) == uint8('f'))];
    if ~isempty(idx)
        faces = [faces,tmp(2:4,idx)];
    end
end

points = points';
faces = faces';

return

str = 0;
while ( str ~= -1)
    str = fgets(fid);   % -1 if eof
    if str(1)=='v'
        [a,str] = strtok(str);
        [a,str] = strtok(str); x = str2num(a);
        [a,str] = strtok(str); y = str2num(a);
        [a,str] = strtok(str); z = str2num(a);
        points = [points;[x y z]];
    elseif str(1)=='t' || str(1)=='f'
        [a,str] = strtok(str);
        [a,str] = strtok(str); x = str2num(a);
        [a,str] = strtok(str); y = str2num(a);
        [a,str] = strtok(str); z = str2num(a);
        faces = [faces;[x y z]];
    end
end

fclose(fid);