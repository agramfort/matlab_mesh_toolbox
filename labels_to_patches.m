function patches = labels_to_patches(labels)
%   LABELS_TO_PATCHES
%       [PATCHES] = LABELS_TO_PATCHES(LABELS)
% 
%   Created by Alexandre Gramfort on 2008-11-07.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


labels_unique = unique(labels);
nlabels = length(labels_unique);
npoints = length(labels);
labels_unique_inv = invperm(labels_unique);
patches = sparse(1:npoints,labels_unique_inv(labels),ones(npoints,1),npoints,nlabels);

end %  function