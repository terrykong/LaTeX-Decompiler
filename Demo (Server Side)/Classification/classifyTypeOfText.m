function outStruct = classifyTypeOfText(classStruct)
% This will change 'text' blocks to 'captions', 'pagenumbers'
outStruct = classStruct;
%% Constants
captionDistFac = 2;
pageNumDistFac = 5;
pageNumVertFraction = 0.85; % pg num needs to be in the normalized vertical range [0.8,1]
pageNumHeightThresh = 0.01;
footerArea = 0.9;
%%

for i = 1:outStruct.blockNum
    %% If we find a figure, it should have a caption if 
    %  text appears < 3(line break distance)
    if isequal(outStruct.blockType{i},'figure')
        r = outStruct.pixelList{i}(:,1);
        c = outStruct.pixelList{i}(:,2);
        figBottom = max(r);
        I = find(r ~= figBottom);
        c(I) = nan;
        figL = [figBottom,min(c)];
        figR = [figBottom,max(c)];
        closestInd = 0;
        % Search for the text box right below
        for j = figBottom+1:size(outStruct.labeledMask,1)
            currentRow = outStruct.labeledMask(j,figL(2):figR(2));
            if any(currentRow)
                currentRow(currentRow == 0) = nan;
                closestInd = mode(currentRow);
                break;
            end
        end
        if closestInd
            outStruct.blockType{closestInd} = 'caption';
        else
            disp('Erroneous Figure')
        end
%         fprintf('j = %d\n',closestInd)
%         disp('@@@@@@@@CAPTION FOUND')
        continue;
    end
    %% Page numbers are text, but are small, centered, and have relatively
    %  big gaps between itself and any other block. Also they're typically
    %  at the bottom of the page
    if isequal(outStruct.blockType{i},'text')
        r = outStruct.pixelList{i}(:,1);
        c = outStruct.pixelList{i}(:,2);
        boundBox = [min(r),max(r),min(c),max(c)]; %top,down,left,right
        if ~isempty(outStruct.textLines{i})
            %% It can't be a page number if multiple textlines
             continue;
        elseif (boundBox(2)-boundBox(1))/size(outStruct.labeledMask,1) > pageNumHeightThresh
            continue;
        end
        lineBreakDist = boundBox(2)-boundBox(1);
        pageMiddle = size(outStruct.labeledMask,2)/2;
        if abs((boundBox(3)+boundBox(4))/2 - pageMiddle) > ...
                pageNumDistFac*lineBreakDist
            % If the boundBox isn't in the middle, it can't be a pg num
            continue;
        end
        if ((boundBox(1)+boundBox(2))/2) / size(outStruct.labeledMask,1) >= ...
                pageNumVertFraction
            outStruct.blockType{i} = 'pageNumber';
%             disp('@@@@@@@@PG NUM FOUND')
        end
    end
    %% Footers are any text blocks that are not page numbers that fall 
    %  within some normalized vertical range, [0.8,1]
    if isequal(outStruct.blockType{i},'text')
        r = outStruct.pixelList{i}(:,1);
        boxTop = min(r);
        if boxTop/size(outStruct.labeledMask,1) >= footerArea
            outStruct.blockType{i} = 'footer';
        end
    end
end