function outmask = processMWR(MWR,imSize,figmask)
outmask = ones(imSize);

% Use only top 2% of rectangles
topPercentage = 0.02;%
numRect = size(MWR,2);
areas = (MWR(2,:)-MWR(1,:)).*(MWR(4,:)-MWR(3,:));
[~,I] = sort(areas,'descend');
for i = 1:round(numRect*topPercentage)
    outmask(MWR(1,I(i)):MWR(2,I(i)),MWR(3,I(i)):MWR(4,I(i))) = 0;
end
outmask = or(outmask,figmask);
end