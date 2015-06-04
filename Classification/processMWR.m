function outmask = processMWR(MWR,imSize,figmask)
outmask = ones(imSize);

% Use only top 5% of rectangles
topPercentage = 0.05;%
numRect = size(MWR,2);
areas = (MWR(2,:)-MWR(1,:)).*(MWR(4,:)-MWR(3,:));
[~,I] = sort(areas,'descend');
for i = 1:round(numRect*topPercentage)
    outmask(MWR(1,I(i)):MWR(2,I(i)),MWR(3,I(i)):MWR(4,I(i))) = 0;
end
outmask = or(outmask,figmask);
outmask = imfill(outmask,'holes');

% Check if there are at least 10 connected components. 
%hack
CC = bwconncomp(outmask);
if CC.NumObjects <= 10
    outmask = ones(imSize);
    topPercentage = topPercentage*2;
    numRect = size(MWR,2);
    areas = (MWR(2,:)-MWR(1,:)).*(MWR(4,:)-MWR(3,:));
    [~,I] = sort(areas,'descend');
    for i = 1:round(numRect*topPercentage)
        outmask(MWR(1,I(i)):MWR(2,I(i)),MWR(3,I(i)):MWR(4,I(i))) = 0;
    end
    outmask = or(outmask,figmask);
    outmask = imfill(outmask,'holes');
end