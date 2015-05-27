%%
testIm = logical(floor(rand(200)+0.5));
% testIm = [false,false]
% testIm = false(2);
circ = [true(2,size(testIm,2)+4);true(size(testIm,1),2),testIm,true(size(testIm,1),2);true(2,size(testIm,2)+4)];

sides = zeros(0,4); % left top right bottom
rectangles = [];
for row = 3:(size(circ,1)-2)
    for col = 3:(size(circ,2)-2)
        if ~circ(row,col)
            fstCol = find(circ(row-1,col:end),1);
            fstRow = find(circ(row:end,col-1),1);
            maxCol = find(circ(row,col:end),1);
            maxRow = find(circ(row:end,col),1);
            foundRect = [];
            standbyRect = [];
            maxColInc = maxCol-2;
            for rowInc = (fstRow-1):(maxRow-1)
                x = find(circ(row+rowInc,col:(col+maxColInc)),1)-2;
                if numel(x) > 0
                    if x < maxColInc
                        if x < fstCol-2
                            break
                        end
                        foundRect = [foundRect;...
                            col,row,col+maxColInc,row+rowInc-1];
                        
                        testIm2 = double(testIm);
                        testIm2((row:(row+rowInc-1))-2,(col:(col+maxColInc))-2) = 2;
                        [testIm,testIm2];
                        
                        maxColInc = x;
                            
                    end
                end
            end
            
            % foundRect = [foundRect;...
            % col,row,col+maxColInc,row+maxRow-2];
            
            rectangles = [rectangles;foundRect];
        end
    end
end
rectangles = rectangles-2;