function computeLayout(input_img_path, output_img_path)
%------------------------------------------------------------------------------
% INPUT:
% input_img_path 	- input image path
% output_img_path 	- output image path
%------------------------------------------------------------------------------
warning('off','all'); format compact;
if nargin < 2
    input_img_path =('./upload/test.jpg');
    output_img_path =('./output/test.jpg');
end

if(isempty(input_img_path))
    input_img_path =('./upload/test.jpg');
end
    
if(isempty(output_img_path))
    output_img_path =('./output/test.jpg');
end

% --------------------------------------------------------------------
%                                                        Load an image
% --------------------------------------------------------------------
% Need to rotate because of how the image is sent over from device
InputImg = imrotate(imread(input_img_path),270);
% --------------------------------------------------------------------
%                                       Convert the to required format
% --------------------------------------------------------------------
%InputImg = imresize(InputImg,min(1,640/size(InputImg,2)));
% --------------------------------------------------------------------
%                                                           Preprocess
% --------------------------------------------------------------------
cd Preprocessing/
tic
InputImgBin = preprocessDocument(InputImg);
fprintf('Preprocessing time: %0.1fsec\n',toc);
close all; %shouldn't be necessary
cd ..
% Print
h  = figure(1);
subplot('Position', [0 0 1 1]) 
imshow(InputImgBin); 
box off; grid off; axis off;
truesize(h, [size(InputImgBin,1) size(InputImgBin,2)]); %adjust figure
set(gcf,'PaperPositionMode','auto')
print(h,'-dpng','./output/preprocessed.png')
% --------------------------------------------------------------------
%                                                                  MWR
% --------------------------------------------------------------------
%% Run those 2 lines if not done yet. If multiple time no worries
javaaddpath('whiteRectEnumJava/bin'); % assuming workspace is in parent Directory of whiteRectEnumJava
import whiteRectEnumJava.*
set(0,'RecursionLimit',500);
% 
cd whiteRectEnum/
[imTopLeft,~,figmask,boundingBox,~,downFactor] = oCCReduce(InputImgBin);
imReduced = ~boundingBox;
A = [imReduced,ones(size(imReduced,1),1)];
[row,col] = find(A);
tic
list = MatlabComp.processImage(row,col,size(A,1))';
list([1,3],:) = (list([1,3],:)-1)*downFactor + 1;
list([2,4],:) = list([2,4],:)*downFactor;
list(2,list(2,:) > size(InputImgBin,1)-downFactor) = size(InputImgBin,1);
list(4,list(4,:) > size(InputImgBin,2)-downFactor) = size(InputImgBin,2);

fprintf('MWR time: %0.1fsec\n',toc);
close all; %shouldn't be necessary
cd ..
% --------------------------------------------------------------------
%                                                       Classification
% --------------------------------------------------------------------
cd Classification/
mask = processMWR(list,size(InputImgBin),figmask);
% Print
h  = figure(1);
subplot('Position', [0 0 1 1]) 
imshow(mask); 
box off; grid off; axis off;
truesize(h, [size(mask,1) size(mask,2)]); %adjust figure
set(gcf,'PaperPositionMode','auto')
print(h,'-dpng','../output/mask.png')
tic;
[classStruct] = classification(InputImgBin,mask);
fprintf('Classification time: %0.1fsec\n',toc);
set(gcf,'PaperPositionMode','auto')
print('-dpng','../output/classify.png')
cd ..

%Construct output image 

h  = figure(1);
%set(h, 'Position',[0 0 1920 1080]);
subplot('Position', [0 0 1 1]) 
imshow(imrotate(InputImg,90)); %rotate for the camera
box off;
grid off;
axis off;

truesize(h, [size(InputImg,2) size(InputImg,1)]); %adjust figure
%print(h,'-depsc','./output/output.eps')
%print(h,'-painters','-dbmp16m','./output/temp.bmp')

%convert figure to correct image perspective ratio
%outI = imread('./output/temp.bmp') ;
%imshow(outI); print -depsc figfig
%outI = imresize(outI, [size(InputImg,1) size(InputImg,2)]);
%imwrite(outI, output_img_path,'Quality',100);
print('-djpeg100',output_img_path);

end
