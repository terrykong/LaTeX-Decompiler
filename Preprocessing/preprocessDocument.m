function [ processed_image ] = preprocessDocument( input_image )
% Preprocesses image of text document
% input: n-m
% Binarizes image
% - uses locally adaptive thresholding
% - sets all low variance locations to 1
% Determines and corrects skew
% - for angles within the range -45<theta<45
% - uses Hough transform on smaller blocks of the image
% Removes margin
% - projects pixels onto x/y axes and detects where the peaks from text
% occur
% Maybe: slant detection, homography of image?

input_image = rgb2gray(im2double(input_image));
binarized_image = binarizeDocument(input_image);
rotated_image = determineBlockSkew(binarized_image);
processed_image = findPageMargins(rotated_image);

end

