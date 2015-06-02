function [blockType, textLines, classifyReason] = classifyText(CCpixels,im,plotFlag)
% Input:
%   - CCpixels = list of pixels for 1 connected component
%   - im       = binary image
%
% Output:
%   - blocktype = string that identifies the pixel
%
%   Main assumption: - Lines of text are separated by at least 10 pixels.
%                      Otherwise, you won't be able to use OCR after doc-
%                      layout analysis.
%                    - Horizontal histograms with periodic structure are
%                       assumed to be text. 

if nargin <= 2
    plotFlag = false;
end

%% Constants
low = 10; %pixels
peakThreshFac = 3;
singleLineOfTextThresh = 2;
outlierAspectRatioThresh = 8;
modeSearchRadius = 2;
passingRatio = 0.7; % if the weight is larger than this fraction of num of peaks
gauss_sum = @(n) n*(n+1)/2;
tinyTextAspectRatioThresh = 4;
tinyTextAreaThresh = 0.05^2; % Percentage
oddShapedCCThresh = 0.9;
%%

% Calculate the two key numbers: height and width
[h_full,w_full] = size(im); 
[i,j] = ind2sub(size(im), CCpixels);
height = max(i) - min(i);
width = max(j) - min(j);
% Create mask
mask = zeros(size(im));
mask(CCpixels) = 1;
% Create Horizontal histogram
hHist = sum(mask.*im,2);
% Trim histogram of leading and trialing zeros
validRange = find(hHist,1,'first'):find(hHist,1,'last');
hHist = hHist(find(hHist,1,'first'):find(hHist,1,'last'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plotFlag
    hHist2 = conv(hHist,ones(1,low/2)/(low/2),'same');
    hHist2 = hHist2-mean(hHist2);
    hHist3 = (hHist2 >= 0).*hHist2;
    hHist2 = hHist2(find(hHist3,1,'first'):find(hHist3,1,'last'));
    Rh2 = xcorr(hHist2-mean(hHist2));

    subplot(221); plot(find(hHist3,1,'first'):find(hHist3,1,'last'),hHist2,'r-','linewidth',1.5);
    title('horizontal histogram')
    hHist2 = conv(hHist,ones(1,low/2)/(low/2),'same');
    hHist2 = hHist2-mean(hHist2);
    hold on; plot(hHist2); hold off;

    subplot(122); imshow(0.5*mask+0.5*mask.*im)
    subplot(223); plot(Rh2); title('horizontal autocorrelation')
    if height >= low
        hold on;     
        [~,loc2] = findpeaks(Rh2,'minpeakheight',max(Rh2)/peakThreshFac,'minpeakdistance',low/2);
        plot(loc2,Rh2(loc2),'ro'); plot(loc2,Rh2(loc2),'r*')
        hold off;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Check if the height is above the "low" threshold
if height < low
    %% It's either text, or unclassified
    % If variance of vertical histogram is high, it's probably text
    vHist = sum(mask.*im,1);
    vHist = vHist(find(vHist,1,'first'):find(vHist,1,'last'));
    if var(vHist) > singleLineOfTextThresh
        blockType = 'text';
        classifyReason = 'too small';
    else
        blockType = 'noclass';
        classifyReason = 'too small';
    end
    textLines = [];
    return;
%elseif width < low
else
    % Find f0=t0 from autocorrelation (noise level removed)
    % Trim Histogram of border effects
    hHist = conv(hHist,ones(1,low/2)/(low/2),'same'); %smooth out hist
    hHist = hHist-mean(hHist); %mean removed
    hHistEnv = (hHist >= 0).*hHist;
    validRange = validRange(find(hHistEnv,1,'first'):find(hHistEnv,1,'last'));
    hHist = hHist(find(hHistEnv,1,'first'):find(hHistEnv,1,'last'));
    Rh = xcorr(hHist-mean(hHist));
    [~,loc] = findpeaks(Rh,'minpeakheight',max(Rh)/peakThreshFac,'minpeakdistance',low/2)
    if numel(loc) <= 3
        %% Need to think about this edge case (relies on aspect ratio)
        if height/width > outlierAspectRatioThresh || width/height > outlierAspectRatioThresh 
            % If aspect ratio is too big, it's probably not text or figure
%             blockType = 'unsure';
%             textLines = [];
%             return;
            % If variance of vertical histogram is high, it's probably text
            vHist = sum(mask.*im,1);
            vHist = vHist(find(vHist,1,'first'):find(vHist,1,'last'));
            if var(vHist) > singleLineOfTextThresh
                blockType = 'text';
                classifyReason = 'not enough peak/HUGE asp. rat.';
            else
                blockType = 'noclass';
                classifyReason = 'not enough peak/large asp. rat./low variance';
            end
            textLines = [];
            return;
        else
            if height*width < h_full*w_full*tinyTextAreaThresh
                %% Box is too small to be anything but something like page #
                blockType = 'text';
                classifyReason = 'box area too small';
                textLines = [];
                return;
            else
                if height/width > tinyTextAspectRatioThresh || width/height > tinyTextAspectRatioThresh 
                    blockType = 'text';
                    classifyReason = 'not enough peak/large asp. rat.';
                    textLines = [];
                    return;
                else
                    % If the area of the CC significantly smaller than
                    % bounding box, it's text not a figure
                    if length(CCpixels)/(height*width) < oddShapedCCThresh
                        blockType = 'text';
                        classifyReason = 'not enough peak/square-ish asp. rat/odd shaped CC';
                        textLines = [];
                        return;
                    else
                        blockType = 'figure';
                        classifyReason = 'not enough peak/square-ish asp. rat';
                        textLines = [];
                        return;
                    end
                end
            end
        end
    end
    dist = pdist(loc);
    dist_u = unique(dist); % also sorts
    maxDist = max(dist_u);
    weight = zeros(1,length(dist_u));
    for n = 1:length(dist_u)
        current = dist_u(n);
        fac = 1;
        while current <= maxDist
            weight(n) = weight(n) + sum(abs(dist-current) <= modeSearchRadius);
            
            fac = fac + 1;
            current = dist_u(n)*fac;
        end
        weight(n) = weight(n) - 1; %subtract 1 b/c peak counts itself
    end
    % Max weight is the best guess
    maxNumOfMatches = gauss_sum(length(loc)-1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if plotFlag
        subplot(223); xlabel(max(weight)/maxNumOfMatches)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [maxweight,I] = max(weight);
    if maxweight > passingRatio*maxNumOfMatches
        %% Most likely text
        blockType = 'text';
        classifyReason = 'found f0';
        textLines = findLineBreaks(mask,hHist,validRange,dist_u(I));
        return;
    else
        blockType = 'figure';
        classifyReason = 'couldn''t find f0';
        textLines = [];
        return;
    end
end
end

% Helper function that finds line breaks
function P = findLineBreaks(mask,hHist,validRange,f0)
%
% P = [r1,c1,r2,c2]; where r and c are column vectors and 
%                    [r1,c1] is the left point and [r2,c2]  is the
%                    right point of a line break
P = [];
index = 1;
while index <= length(validRange)
    currentRange = validRange(index:min(index+f0-1,length(validRange)));
    currentHist = hHist(index:min(index+f0-1,length(validRange)));
    [~,I] = min(currentHist);
    [~,c1] = min(mask(currentRange(I),:));
    [~,c2] = max(mask(currentRange(I),:));
    P = [P;currentRange(I),c1,currentRange(I),c2];
    index = index + f0;
end

end