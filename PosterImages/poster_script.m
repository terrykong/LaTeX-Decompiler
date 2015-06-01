close all
clear all
clc

addpath ../Preprocessing ../whiteRectEnum ../testim
for n = [10:15]

    im = imread(['testim/',num2str(n,'%03d'),'.jpg']);
    cd(['im',num2str(n,'%03d')])
    addpath ../../Preprocessing ../../whiteRectEnum ../../testim

    im = preprocessDocument(im);
    imwrite(im,'preprocessed_image.jpg','jpg');
   
    [list,im] = MWRScript(im);
    
    str =['MWR_boxes_as_input_',num2str(n),'.mat']; 
    save(str,'list');
    imwrite(im,'MWR_image.jpg','jpg');
    cd ..
end
