% test script
clear all; clc; close all;

%% Contrived Input
cd ..
imInit = imread('testIm/005.jpg');
cd Classification

im = im2bw(imInit,0.5);
[im_bin2, componentLocation] = outlineConnectedComponents(im);
[im_bin,mask,boundingBox,CCLoc] = oCCReduce(im);
dilatewidth = 21;
mask = imclose(mask,strel(ones(dilatewidth,1)));

%% First wave of classification (text or not text, that is the question)
blocks = bwconncomp(mask);
for i = 1:blocks.NumObjects
    if numel(blocks.PixelIdxList{i}) <= 10
        fprintf('component i = %d is too small\n',i)
        continue
    end
    fprintf('@@@ i = %d\n',i)
    [blockType, textLines] = classifyText(blocks.PixelIdxList{i}, im)
    subplot(312); title(blockType)
    pause;
   % return
end

%% Second wave of classification (local-to-global, e.g., caption, footer)