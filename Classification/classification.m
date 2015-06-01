function [classStruct] = classification(im_bw,mask)
% Function that classifies each CC in the mask 
%
% Input:
%   - im_bw = binary image
%   - mask  = cover mask
%
% Output:
%   - classStruct = class information
classStruct = struct('blockNum',0,...
                     'labeledMask',zeros(size(mask)),...
                     'blockType',[],... %name of block type
                     'textLines',[],... %only text blocks have these
                     'maskClassOverlay',zeros([size(im_bw),3]),...
                     'pixelList',[],...
                     'boundRect',[]);
classStruct.blockType = {};
classStruct.textLines = {};
classStruct.pixelList = {};

color = struct('text',          [0.9,0.9,0.2],... %yellow
               'figure',        [1,0,0],... %red
               'pageNumber',    [0,1,0],... %green
               'footer',        [0,1,1],... %cyan
               'caption',       [1,0,1],... %magenta
               'noclass',       [0,0,1]);   %blue

%% First wave of classification (text or not text, that is the question)
blocks = bwconncomp(mask);
for i = 1:blocks.NumObjects
    % It's possible somehow we get a CC that's really small
    if numel(blocks.PixelIdxList{i}) <= 10
        fprintf('component i = %d is too small\n',i)
        continue
    end
    fprintf('@@@ i = %d\n',i)
    %[blockType, textLines, classifyReason] = classifyText(blocks.PixelIdxList{i}, im_bw);
    [blockType, textLines, classifyReason] = classifyText(blocks.PixelIdxList{i}, im_bw)
    classStruct.blockNum = classStruct.blockNum + 1;
    classStruct.labeledMask(blocks.PixelIdxList{i}) = classStruct.blockNum;
    classStruct.blockType{end+1} = blockType;
    if isequal(blockType,'text')
        classStruct.textLines{end+1} = textLines;
    else
        classStruct.textLines{end+1} = [];
    end
    [r,c] = ind2sub(size(mask),blocks.PixelIdxList{i});
    classStruct.pixelList{end+1} = [r,c];
    classStruct.boundRect = [classStruct.boundRect,[min(r);max(r);min(c);max(c)]];
    %subplot(122); title(blockType); xlabel(['reason: ' classifyReason])
    %pause(0.0001);
end

%% Second wave of classification (local-to-global, e.g., caption, footer)
classStruct = classifyTypeOfText(classStruct);

%% Produce visually pleasing output with bound
boxBlocksWithColor(im_bw,classStruct,color)