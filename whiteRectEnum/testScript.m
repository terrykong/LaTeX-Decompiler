imInit = imread('../testim/001.jpg');

n = 1700;
im = im2bw(imInit(1100:min(n,end),1100:min(n,end)),0.5);
% im = im2bw(imInit);
[im, componentLocation] = outlineConnectedComponents(im);
im = ~im;
set(0,'RecursionLimit',500);

%% Run those 2 lines if not done yet. If multiple time no worries
javaaddpath('../whiteRectEnumJava/bin'); % assuming your matlab workspace is currently /LaTeX-Decompiler/whiterectEnum
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
list = MatlabComp.processImage(row,col,size(A,1))'
toc

%%
% figure(1)
% imagesc(A,[0 1]); axis('image'); colorbar;
% 
% B = A*0.5+0.5;
% for rect = list
%     B = A*0.5+0.5;
%     B(rect(1):rect(2),rect(3):rect(4)) = 0;
% imagesc(B,[0 1]); axis('image'); colorbar;
% rect
% input('')
% end
% 
% imagesc(B,[0 1]); axis('image'); colorbar;
