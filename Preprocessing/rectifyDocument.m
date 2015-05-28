function [ output_image ] = rectifyDocument( input_image )
% Determines skew of document, rotates it, and crops image to be size of
% document
% seems to work best with grayscale image (as opposed to binarized)
%   Applies median filter to remove text, then retrieves Canny edges.
%   Applies Hough transform to find lines in this edge image, and
%   determines angle and bounds from the longest lines

[num_rows, num_cols] = size(input_image);
%% Prepare the image for Hough
% downsample to speed up processing? grabs more hough lines in text :(
M = 1;
image_downsampled = input_image(1:M:end,1:M:end);
%remove text via median filtering -- not sure this actually helps, but in
%literature
image_no_text = medfilt2(image_downsampled,[9 9]);

%get Canny edges
canny_thresh = [.05 .2];
canny_sigma = sqrt(8);
edge_im = edge(image_no_text,'canny',canny_thresh,canny_sigma);

% %get LoG edges - not great: detects many false alarms if anything at all
% % values probably not super robust to all images
% log_thresh = [.05 .2];
% log_sigma = sqrt(8);
% edge_im = edge(input_image,'log',log_thresh,log_sigma);

%make edges more visible
edge_im = imdilate(edge_im,strel('square',5));

figure
imshow(edge_im)

% Next: try to find connected component of edges to determine skew and
% boundaries
%% Apply Hough to find directions of lines
thetaVec = -90:.5:89.5;
[H,theta,rho] = hough(edge_im, 'Theta', thetaVec);
numPeaks = 30;
thresh = 0.1*max(H(:));
peaks = houghpeaks(H, numPeaks, 'Threshold', thresh);
thetaHist = hist(theta(peaks(:,2)), thetaVec);
%% plot Hough results
figure; clf;
subplot(2,1,1);
warning off; imshow(imadjust(mat2gray(H)), 'XData', theta, 'YData', rho, ...
 'InitialMagnification', 'fit'); axis on; axis normal; hold on; warning on;
plot(theta(peaks(:,2)), rho(peaks(:,1)), 'ys');
xlabel('\theta (degrees)'); ylabel('\rho');
subplot(2,1,2);
bar(thetaVec, thetaHist); grid on;
axis([min(thetaVec) max(thetaVec) 0 max(thetaHist)+2]);
xlabel('\theta (degrees)'); ylabel('Number of Peaks');
[maxHist, maxIdx] = max(thetaHist);


%% Find Hough lines and plot them
lines = houghlines(edge_im,theta,rho,peaks,'FillGap',100,'MinLength',100);
lengths = zeros(size(lines));
angles = zeros(size(lines));

figure
imshow(edge_im);
hold on;
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        
    % Find longest lines as they will likely be edges
    lengths(k) = norm(lines(k).point1 - lines(k).point2);
    angles(k) = lines(k).theta;
end
         
[sorted_lengths,sorted_idx] = sort(lengths,'descend');

findCorners(lines,input_image);
%% Find angle of rotation and de-rotate
% assume that the longest Hough line corresponds to the longest side of
% the page
houghTheta = angles(sorted_idx(1))
output_image = imrotate(input_image,houghTheta,'bilinear');

%% Find where longest Hough Transform lines map to after rotation 
% to detect edge of paper
% apply rotation matrix to lines: assumption is that they will give max and
% min pixel position in x & y directions... perhaps not the most robust.
rot_mat = [cosd(houghTheta) sind(houghTheta); -sind(houghTheta) cosd(houghTheta)];
for i = 1:4
    longest_edges(:,2*i-1) = lines(sorted_idx(i)).point1';
    longest_edges(:,2*i) = lines(sorted_idx(i)).point2';
end
num_pts = size(longest_edges,2);
mid_pt_in = fliplr(size(input_image))/2;
mid_pt_out = fliplr(size(output_image))/2;
output_edges = (rot_mat*(M*longest_edges-repmat(mid_pt_in',1,num_pts))) + ...
    repmat(mid_pt_out',1,num_pts);

% find outline of paper-remove 30 pixels on all sides to account for
% small remaining angles (<.5 degrees)
xmin = round(min(output_edges(1,:)))+30;
ymin = round(min(output_edges(2,:)))+30;
xmax = round(max(output_edges(1,:)))-30;
ymax = round(max(output_edges(2,:)))-30;

output_image = output_image(max(ymin,1):min(ymax,size(output_image,1)),...
    max(xmin,1):min(xmax,size(output_image,2)));
figure
imshow(output_image);
end

