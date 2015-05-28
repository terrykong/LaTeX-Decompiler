cd ..
imInit = imread('testIm/001.jpg');
cd whiteRectEnum

n = 1165;
im = ~im2bw(imInit(1125:min(n,end),1125:min(n,end)),0.5);

set(0,'RecursionLimit',500);

%%
A = [im,ones(size(im,1),1)];


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
figure(1)
imagesc(A,[0 1]); axis('image'); colorbar;

B = A*0.5+0.5;
for rect = listN
    B(rect(1):rect(2),rect(3):rect(4)) = 0;
end
figure(2)
imagesc(B,[0 1]); axis('image'); colorbar;