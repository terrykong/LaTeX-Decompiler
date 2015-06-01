function [ list, B ] = MWRScript( im )
% Vincent's test script in function form
[im, componentLocation] = outlineConnectedComponents(im);

imwrite(im,'outlinesCCs.jpg','jpg');
set(0,'RecursionLimit',500);

% [im2,mask,boundingBox,CCLoc] = oCCReduce(im);
% im = im2;
im = ~im;
%% Run those 2 lines if not done yet. If multiple time no worries
javaaddpath('../../whiteRectEnumJava/bin'); % assuming your matlab workspace is currently /LaTeX-Decompiler/whiterectEnum
import whiteRectEnumJava.*

%%
%     A = [im,ones(size(im,1),1)];
%     tic;
%
%     fst = RectangleNode(0,0,size(A,1));
%     tree = RectangleTree(fst);
%
%     nodeList = RectangleList([],[]);
%
%     [row,col] = find(A);
%     for k = 1:numel(row)
%         i = row(k);
%         j = col(k);
%         tree = tree.processPoint(nodeList,j-0.5,i-0.5,0,size(A,1));
%         % tree.debugCycles
%         %             tree.print();
%         %             input([num2str(i),' ',num2str(j)]);
%     end
%     list = nodeList.print()
%     toc;


%%
A = [im,ones(size(im,1),1)];

[row,col] = find(A);
tic
list = MatlabComp.processImage(row,col,size(A,1))';
toc

%%
% figure(1)
% imagesc(A,[0 1]); axis('image'); colorbar;
% 
B = 1-(A*0.5+0.5);
area = (list(1,:)-list(2,:)+1).*(list(3,:)-list(4,:)+1);
[s_area,s_ind] = sort(area,'descend');
count = 0;
for rect = list(:,s_ind)
    B(rect(1):rect(2),rect(3):rect(4)) = 1;
    count = count+1;
    if count == 100
        figure
        imshow(B); 
        imwrite(B,'MWR_image_partial.jpg','jpg');
    end
%     imagesc(B,[0 1]); axis('image'); colorbar;
%     rect
%     input('')
end
% 
figure
imshow(B); 


end

