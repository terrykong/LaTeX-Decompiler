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
                     'imageClassOverlay',zeros([size(im_bw),3]),...
                     'maskClassOverlay',zeros([size(im_bw),3]));
classStruct.blockType = {};
classStruct.textLines = {};

%% First wave of classification (text or not text, that is the question)
blocks = bwconncomp(mask);
for i = 1:blocks.NumObjects
    % It's possible somehow we get a CC that's really small
    if numel(blocks.PixelIdxList{i}) <= 10
        fprintf('component i = %d is too small\n',i)
        continue
    end
    fprintf('@@@ i = %d\n',i)
    [blockType, textLines] = classifyText(blocks.PixelIdxList{i}, im_bw)
    classStruct.blockNum = classStruct.blockNum + 1;
    classStruct.labeledMask(blocks.PixelIdxList{i}) = classStruct.blockNum;
    classStruct.blockType{end+1} = blockType;
    if isequal(blockType,'text')
        classStruct.textLines{end+1} = textLines;
    else
        classStruct.textLines{end+1} = [];
    end
    subplot(312); title(blockType)
    pause(0.01);
end

%% Second wave of classification (local-to-global, e.g., caption, footer)
