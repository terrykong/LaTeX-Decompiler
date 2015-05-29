clear all; clc; close all;
cd ..
imInit = imread('testIm/001.jpg');
cd whiteRectEnum
%cd .., open('testIm/005.jpg'), cd whiteRectEnum

numBlackPixels = [];
execTime = [];
for delta = 0%-20:5:10

    %r = 1000:1500; c = 800:1200;
    r = 1100:1200; c = 800:900;
    im = im2bw(imInit(r,c),0.5);
    [im3, componentLocation] = outlineConnectedComponents(im); 
    [im2,mask,boundingBox,CCLoc] = oCCReduce(im);
    im = im2;
%     figure; imshow(im); title(sprintf('N=%d,%%=%0.2f',sum(~im(:)),1)); print -depsc binary
%     figure; imshow(im3); title(sprintf('N=%d,%%=%0.2f',sum(~im3(:)),sum(~im3(:))/sum(~im(:)))); print -depsc CCunreduced
%     figure; imshow(mask); print -depsc CCunreduced
%     figure; imshow(boundingBox); title(sprintf('N=%d,%%=%0.2f',sum(~boundingBox(:)),sum(~boundingBox(:))/sum(~im(:)))); print -depsc boundingBox
%     figure; imshow(im2); title(sprintf('N=%d,%%=%0.2f',sum(~im2(:)),sum(~im2(:))/sum(~im(:)))); print -depsc CCreduced
%     return
    
    
% %     n = 1165+delta;
% %     im = im2bw(imInit(1125:min(n,end),1125:min(n,end)),0.5);
% %     [im, componentLocation] = outlineConnectedComponents(im);

    numBlackPixels(end+1) = sum(~im(:));
    
    im = ~im;
    set(0,'RecursionLimit',500);

    %%
    A = [im,ones(size(im,1),1)];
    tic; 

    fst = RectangleNode(0,0,size(A,1));
    tree = RectangleTree(fst);

    nodeList = RectangleList([],[]);

    [row,col] = find(A);
    for k = 1:numel(row)
        i = row(k);
        j = col(k);
        tree = tree.processPoint(nodeList,j-0.5,i-0.5,0,size(A,1));
        % tree.debugCycles
        %             tree.print();
        %             input([num2str(i),' ',num2str(j)]);
    end
    list = nodeList.print();
    listN = [];
    if numel(list) > 0
        listN = list;
        listN(list == 0) = -0.5;
        listN(list == size(A,1)) = size(A,1) + 0.5;
        listN(1,:) = round(listN(1,:)+1.5);
        listN(2,:) = round(listN(2,:)-0.5);
        listN(3,:) = round(listN(3,:)+1.5);
        listN(4,:) = round(listN(4,:)-0.5);
    end
    listN;
    toc;
    execTime(end+1) = toc;
%     figure(1)
%     imagesc(A,[0 1]); axis('image'); colorbar;
% 
%     B = A*0.5+0.5;
%     for rect = listN
%         B(rect(1):rect(2),rect(3):rect(4)) = 0;
%     end
%     figure(2)
%     imagesc(B,[0 1]); axis('image'); colorbar;
end