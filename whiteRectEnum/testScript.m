imInit = imread('../testim/005.jpg');

n = 1700;
% im = im2bw(imInit(1100:min(n,end),1100:min(n,end)),0.5);
im = im2bw(imInit);
[im, componentLocation] = outlineConnectedComponents(im);

[imTopLeft,imTop,mask,boundingBox,CCLoc,downFactor] = oCCReduce(im);
imReduced = ~imTopLeft;

%% Run those 2 lines if not done yet. If multiple time no worries
javaaddpath('../whiteRectEnumJava/bin'); % assuming your matlab workspace is currently /LaTeX-Decompiler/whiterectEnum
import whiteRectEnumJava.*
set(0,'RecursionLimit',500);

%%
A = [imReduced,ones(size(imReduced,1),1)];

[row,col] = find(A);
tic
list = (MatlabComp.processImage(row,col,size(A,1))' - 1)*downFactor + 1;
toc

%%
% figure(1)
% imagesc(A,[0 1]); axis('image'); colorbar;
% 
B = im*0.5+0.5;
for i = 1:floor(size(list,2)/100)
    rect = list(:,i);
    B(rect(1):rect(2),rect(3):rect(4)) = 0;
    imagesc(B,[0 1]); axis('image'); colorbar;
%     rect
%     input('')
end
% 
imshow(B)
