function [ processed_image ] = preprocessDocument( input_image )
% Preprocesses image of text document
% input: n-m
% Binarizes image
% - uses _ method
% - local vs global
% Determines and corrects skew
% - to within __ degrees
% - uses __ method
% - slant detection? 
% rebinarizes after correcting for skew? 
% Removes margin

input_image = rgb2gray(im2double(input_image));

rectified_image = rectifyDocument(input_image);
processed_image = binarizeDocument(rectified_image);

end

