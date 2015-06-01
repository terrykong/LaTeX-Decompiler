% test script
clear all; clc; close all;

%% Contrived Input
cd ..
imInit = imread('testIm/005.jpg');
cd Classification

im = im2bw(imInit,0.5);
% [im_bin2, componentLocation] = outlineConnectedComponents(im);
% [im_bin,mask,boundingBox,CCLoc] = oCCReduce(im);
% dilatewidth = 21;
% mask = imclose(mask,strel(ones(dilatewidth,1)));

%% Vincent's Input
cd .., cd whiteRectEnum
load('MWR_boxes_as_input'); %[top; down; left; right]
cd .., cd Classification

mask = processMWR(list,size(im));

imshow(mask)
% Classification
[classStruct] = classification(im,mask)
