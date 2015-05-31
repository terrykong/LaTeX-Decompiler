function [blockType, textLines] = classifyText(CCpixels,im)
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

%% Constants
low = 10; %pixels
peakThresh = 5;
singleLineOfTextThresh = 2;
outlierAspectRatioThresh = 8;
modeSearchRadius = 2;
passingRatio = 0.25; % if the weight is larger than this fraction of num of peaks
gauss_sum = @(n) n*(n+1)/2;
tinyTextAspectRatioThresh = 4;
tinyTextAreaThresh = 0.05^2; % Percentage
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
% Trim histogram
hHist = hHist(find(hHist,1,'first'):find(hHist,1,'last'));

hHist2 = conv(hHist,ones(1,low/2)/(low/2),'same');
Rh2 = xcorr(hHist2-mean(hHist2));
subplot(311); plot(hHist2); title('horizontal histogram')
subplot(312); imshow(mask)
subplot(313); plot(Rh2); title('horizontal autocorrelation')


% Check if the height is above the "low" threshold
if height < low
    %% It's either text, or unclassified
    % If variance of vertical histogram is high, it's probably text
    vHist = sum(mask.*im,1);
    vHist = vHist(find(vHist,1,'first'):find(vHist,1,'last'));
    if var(vHist) > singleLineOfTextThresh
        blockType = 'text';
    else
        blockType = 'noclass';
    end
    textLines = [];
    return;
%elseif width < low
else
    % Find f0=t0 from autocorrelation (noise level removed)
    hHist = conv(hHist,ones(1,low/2)/(low/2),'same'); %smooth out hist
    Rh = xcorr(hHist-mean(hHist));
    [~,loc] = findpeaks(Rh,'minpeakheight',max(Rh)/peakThresh,'minpeakdistance',low/2)
    if numel(loc) <= 3
        %% Need to think about this edge case (relies on aspect ratio)
        if height/width > outlierAspectRatioThresh || width/height > outlierAspectRatioThresh 
            % If aspect ratio is too big, it's probably not text or figure
            blockType = 'unsure';
            textLines = [];
            return;
        else
            if height*width < h_full*w_full*tinyTextAreaThresh
                %% Box is too small to be anything but something like page #
                blockType = 'text';
                textLines = [];
                return;
            else
                if height/width > tinyTextAspectRatioThresh || width/height > tinyTextAspectRatioThresh 
                    blockType = 'text';
                    textLines = [];
                    return;
                else
                    blockType = 'figure';
                    textLines = [];
                    return;
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
    if max(weight) > passingRatio*maxNumOfMatches
        %% Most likely text
        blockType = 'text';
        textLines = [];
        return;
    else
        blockType = 'figure';
        textLines = [];
        return;
    end
end
end

% Helper function that finds line breaks
function P = findLineBreaks()

end