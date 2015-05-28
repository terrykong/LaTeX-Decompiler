function [ out, componentLocation  ] = outlineConnectedComponents( input_image )
% find connected components and returns:
% - image with filled boxes in place of all characters
% - vector with [xmin, xmax, ymin, ymax]
%   
CC = bwconncomp(~input_image,4);

componentLocation = zeros(CC.NumObjects,4);
out = ones(size(input_image));
for n = 1:CC.NumObjects
   [i,j] = ind2sub(size(input_image), CC.PixelIdxList{n});
   componentLocation(n,1) = min(j);
   componentLocation(n,2) = max(j);
   componentLocation(n,3) = min(i);
   componentLocation(n,4) = max(i);
   % for outlined rect
   out(min(i):max(i),[min(j),max(j)]) = 0;
   out([min(i),max(i)],min(j):max(j)) = 0;
   % for filled rect: out(min(i):max(i),min(j):max(j)) = 0;
end

imshow(out)
end

