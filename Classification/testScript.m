% test script
clear all; clc; close all; format compact

%% Contrived Input
cd ..
imInit = imread('testIm/005.jpg');
cd Classification

im = im2bw(imInit,0.5);
% [im_bin2, componentLocation] = outlineConnectedComponents(im);
[imTopLeft,imTop,figmask,boundingBox,CCLoc,downFactor] = oCCReduce(im);
% dilatewidth = 21;
% mask = imclose(mask,strel(ones(dilatewidth,1)));

%% Vincent's Input
cd .., cd whiteRectEnum
load('MWR_boxes_as_input'); %[top; down; left; right]
cd .., cd Classification

mask = processMWR(list,size(im),figmask);

imshow(mask)

%% Classification
[classStruct] = classification(im,mask);
