function [reducedBox,mask,boundingBox,CCLoc] = oCCReduce( input_image )
% find connected components and returns:
% - image with filled boxes in place of all characters
% - vector with [xmin, xmax, ymin, ymax]
%   

%% First Dilate
% CC = bwconncomp(~input_image,4);
% widths = zeros(1,CC.NumObjects);
% for n = 1:CC.NumObjects
%    [~,j] = ind2sub(size(input_image), CC.PixelIdxList{n});
%    widths(n) = max(j) - min(j);
% end
% 
% [h,bins] = hist(widths,20);
% [~,bestWidth] = max(h);
% dilatewidth = 0+1*round(bins(bestWidth)*2.5); % x1 width is conservative choice
% se = strel(ones(1,dilatewidth));
% input_image_dilate = ~imdilate(~input_image,se);
input_image_dilate = input_image;

%% Find rectangles
CC = bwconncomp(~input_image_dilate,4);
CCLoc = zeros(CC.NumObjects,4);
boundingBox = ones(size(input_image_dilate));
mask = zeros(size(input_image_dilate));
reducedBox = ones(size(input_image_dilate));
for n = 1:CC.NumObjects
   [i,j] = ind2sub(size(input_image_dilate), CC.PixelIdxList{n});
   CCLoc(n,1) = min(j);% + ceil(dilatewidth/2); %undo dilation at edge
   CCLoc(n,2) = max(j);% - ceil(dilatewidth/2);
   CCLoc(n,3) = min(i);
   CCLoc(n,4) = max(i);
   % for boundingBox rect
   boundingBox(CCLoc(n,3):CCLoc(n,4),[CCLoc(n,1),CCLoc(n,2)]) = 0;
   boundingBox([CCLoc(n,3),CCLoc(n,4)],CCLoc(n,1):CCLoc(n,2)) = 0;
   % for filled rect: boundingBox(min(i):max(i),min(j):max(j)) = 0;
   mask(CCLoc(n,3):CCLoc(n,4),CCLoc(n,1):CCLoc(n,2)) = 1;
   reducedBox(CCLoc(n,3),[CCLoc(n,1):CCLoc(n,2)]) = 0;
   reducedBox(CCLoc(n,3):CCLoc(n,4),CCLoc(n,1)) = 0;
end

%imshow(boundingBox)
end

