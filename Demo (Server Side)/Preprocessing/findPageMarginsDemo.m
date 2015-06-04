function [ output_image ] = findPageMarginsDemo( input_image )
% Assuming that the background is darker, there should be large horizontal
% and vertical streaks of black. Use this information and find the longest
% such streaks (this locates edges)
%
% This also assumes there are no characters or pertinent structures that
% are smaller than 4x4 pixels
%
% Assumes the center of the image touches the interiot of the document
%% Constants
medfiltSize = [4,4];
%%
[r,c] = size(input_image);
vHist = size(1,c);
hHist = size(1,r);
for i = 1:r
    hHist(i) = longestZeroSubstring(input_image(i,:));
end
for i = 1:c
    vHist(i) = longestZeroSubstring(input_image(:,i));
end
% 128 pixels matches "window_size" in binarizeDocument.m
%[~,hloc] = findpeaks(hHist,'minpeakheight',max(hHist)/2); 
%[~,vloc] = findpeaks(vHist,'minpeakheight',max(hHist)/2); 
[~,hloc] = find(hHist >= max(hHist)/2);
[~,vloc] = find(vHist >= max(vHist)/2);
hloclow = hloc(hloc < r/2);
hlochigh = hloc(hloc > r/2);
vloclow = vloc(vloc < c/2);
vlochigh = vloc(vloc > c/2);

% Image Boundaries should be maybe +50 pixels away from these locations
% This is b/c theta error = 2, and for 3000 pixel wide images, error
% rotation can be up to 50 pixels
forGoodMeasure = 50;
image_bk_rm = input_image(max(hloclow)+forGoodMeasure:min(hlochigh)-forGoodMeasure,...
                          max(vloclow)+forGoodMeasure:min(vlochigh)-forGoodMeasure);
% Make a copy of the image b/c we're going to alter it by denoising it
image_copy = medfilt2(~image_bk_rm,medfiltSize); 
vProj = sum(image_copy,2);
hProj = sum(image_copy,1);
validRowRange = find(vProj,1,'first'):find(vProj,1,'last');
validColRange = find(hProj,1,'first'):find(hProj,1,'last');
% not really median filt comp., more like buffering
medfiltCompensation = 3*ceil(medfiltSize);
% All done!
output_image = image_bk_rm(min(validRowRange)-medfiltCompensation(1):...
                           max(validRowRange)+medfiltCompensation(1),...
                           min(validColRange)-medfiltCompensation(2):...
                           max(validColRange)+medfiltCompensation(2));
end

function len = longestZeroSubstring(v)
len = 0;
best = 0;
for i = 1:length(v)
    if v(i) == 0
        len = len + 1;
    else
        if best < len
            best = len;
        end
        len = 0;
    end
end
len = best;
end