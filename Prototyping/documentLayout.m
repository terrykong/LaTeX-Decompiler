clear all; clc; close all; format compact

%% Binarize Image
I = imread('textimg.png');
T = graythresh(rgb2gray(I));
Ibin = rgb2gray(I) < T*255;
Ibin = imdilate(Ibin,strel('square',3));
imagesc(Ibin(250:450,200:400)); colormap('gray')

%% Find Connected Regions via Labelling
%%%%%%%%%%%% need to figure out how to remove noise like connected
%%%%%%%%%%%% components
CC = bwlabel(Ibin',4)';
max(CC(:))
A = zeros(max(CC(:))); %adjacency matrix
W = zeros(max(CC(:))); %weight matrix
tic
for i = 1:max(CC(:))
    %imshow((CC==i)*0.75 + 0.25*Ibin); pause(0.1)
    %disp(i);
    [ri,ci] = find(CC == i);
    left_i = min(ci);
    right_i = max(ci);
    up_i = min(ri);
    down_i = max(ri);
    for j = i+1:max(CC(:))
        [rj,cj] = find(CC == j);
        left_j = min(cj);
        right_j = max(cj);
        up_j = min(rj);
        down_j = max(rj);
        if abs(down_j-down_i) > 3*abs(down_j-up_j)
            break
        end
        %dx(i,j)
        L = max(left_i,left_j);
        R = min(right_i,right_j);
        dx = max(L-R,0);
        %dy(i,j)
        U = max(up_i,up_j);
        D = min(down_i,down_j);
        dy = max(U-D,0);
        dist = max(dx,dy);
        W(i,j) = dist;
    end
end
toc
%% Calculate Spanning Tree
W = W+W';
A = (W ~= 0);
[w_st,ST,A_st] = kruskal(A,W);