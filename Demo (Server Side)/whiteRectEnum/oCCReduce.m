%% Output
%
%   reducedBoxTopLeft (is downsampled by downFactor)
%   reducedBoxTop     (is downsampled by downFactor)
%   figmask           (= 1 for big bounding boxes (likely figures))
%                     (@ original resolution not downsampled))
%   boundingBox       (is downsampled by downFactor)
%   CCLoc             (corners of all bounding boxes, i.e. CC)
%   downFactor        (downsampled factor to keep largest dimension > 800)


function [reducedBoxTopLeft,...
          reducedBoxTop,...
          figmask,...
          boundingBox,...
          CCLoc,...
          downFactor] = oCCReduce( input_image )
% find connected components and returns:
% - image with filled boxes in place of all characters
% - vector with [xmin, xmax, ymin, ymax]
%   

%% Constants
figAreaThresh = 0.003; %CC bigger than 0.1% of image is probably an image
figAspectRatio = 5; % CC w/ aspect ratios bigger than this are not figs
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
figmask = zeros(size(input_image_dilate));
reducedBoxTopLeft = ones(size(input_image_dilate));
reducedBoxTop = ones(size(input_image_dilate));
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
   if (CCLoc(n,2)-CCLoc(n,1))*(CCLoc(n,4)-CCLoc(n,3)) > ...
           figAreaThresh*(prod(size(input_image_dilate)))
       % check if the object has a reasonable figure aspect ratio
       if (CCLoc(n,2)-CCLoc(n,1))/(CCLoc(n,4)-CCLoc(n,3)) > figAspectRatio || ...
           (CCLoc(n,4)-CCLoc(n,3))/(CCLoc(n,2)-CCLoc(n,1)) > figAspectRatio
           continue;
       else   
           figmask(CCLoc(n,3):CCLoc(n,4),CCLoc(n,1):CCLoc(n,2)) = 1;
       end
   end
   reducedBoxTopLeft(CCLoc(n,3),[CCLoc(n,1):CCLoc(n,2)]) = 0;
   reducedBoxTopLeft(CCLoc(n,3):CCLoc(n,4),CCLoc(n,1)) = 0;
   reducedBoxTop(CCLoc(n,3),[CCLoc(n,1):CCLoc(n,2)]) = 0;
end


%% Downsample everything so that the largest dimension is around 600
downFactor = max(1,floor(max(size(input_image))/600));

imBig = ~imdilate(~reducedBoxTopLeft,ones(downFactor));
reducedBoxTopLeft = imBig(1:downFactor:end,1:downFactor:end);

imBig = ~imdilate(~reducedBoxTop,ones(downFactor));
reducedBoxTop = imBig(1:downFactor:end,1:downFactor:end);

imBig = ~imdilate(~boundingBox,ones(downFactor));
boundingBox = imBig(1:downFactor:end,1:downFactor:end);

end

