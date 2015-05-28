function [ output_image ] = removeDocumentMargins( input_image )
% Removes margins of input image of text document
%   Detailed explanation goes here

[num_rows, num_cols] = size(input_image);

%remove text via median filtering -- check w/ light background
image_no_text = medfilt2(input_image,[11 11]);
%get Canny edges
edge_im = edge(image_no_text,'canny',0.3,sqrt(8));
%make edges more visible
edge_im = imdilate(edge_im,strel('square',5));
figure
imshow(edge_im);

% Apply Hough to find directions of lines
thetaVec = -90:.5:89.5;
[H,theta,rho] = hough(edge_im, 'Theta', thetaVec);
numPeaks = 30;
thresh = 0.1*max(H(:));
peaks = houghpeaks(H, numPeaks, 'Threshold', thresh);
thetaHist = hist(theta(peaks(:,2)), thetaVec);
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
%% find theta value with highest number of peaks
maxHist = max(thetaHist);
all_maximums = find(thetaHist == maxHist);
best_theta = all_maximums;
% if there are multiple maximums, find which max has the most surrounding 
% values and the most hits at the perpendicular angle
if length(all_maximums) > 1 
    neighbor_hist = zeros(length(all_maximums),1);
    perpendicular_hist = zeros(length(all_maximums),1);
    for i = 1:length(all_maximums);
        index = all_maximums(i);
        neighbor_hist(i) = sum(thetaHist(max(index-5,1):min(index+5,length(thetaHist))));
        % account for differences of both + and - 90 degrees
        perpendicular_lines = thetaHist(abs(thetaVec-thetaVec(index)-90)<3);
        perpendicular_hist(i) = sum(perpendicular_lines);
        perpendicular_lines = thetaHist(abs(thetaVec-thetaVec(index)+90)<3);
        perpendicular_hist(i) = perpendicular_hist(i)+sum(perpendicular_lines);
    end
    % find which point has the most neighbors and perpendicular values
    total_neighbors = neighbor_hist+perpendicular_hist;
    best_theta = find(total_neighbors==max(total_neighbors));
    if length(best_theta)>1
        % in case of tie, choose the theta with most neighbors (in line
        % with text)
        best_theta = best_theta(find(neighbor_hist(best_theta) == ...
            max(neighbor_hist(best_theta)),1));
    end
    best_theta = all_maximums(best_theta);
end

houghTheta = theta(best_theta);
% will hopefully choose the angle that text is at, so we rotate by
% angle+-90
if houghTheta>0
    houghTheta = houghTheta-90;
elseif houghTheta<0
    houghTheta = houghTheta+90;
end

houghTheta
%%
% Find lines and plot them
lines = houghlines(edge_im,theta,rho,peaks,'FillGap',100,'MinLength',100);
figure, imshow(input_image), hold on
lengths = zeros(size(lines));
angles = zeros(size(lines));
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        
    % Find longest line, see if there are vaguely
    % intersecting lines
    lengths(k) = norm(lines(k).point1 - lines(k).point2);
    angles(k) = lines(k).theta;
end
         
[sorted_lengths,sorted_idx] = sort(lengths,'descend');
current_index = 0;
corners = zeros(4,2);
while true
    current_index = current_index+1;
    current_line = lines(sorted_idx(current_index));
    chosen_length = sorted_lengths(current_index);
    xy = [current_line.point1; current_line.point2];
    angle_longest = current_line.theta;
    % highlight the longest line segment
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','cyan');
    % find next longest line that's close to parallel
    parallel_idx = find(abs(angles(sorted_idx(2:end))-angle_longest)<10,1)
    if isempty(parallel_idx)
        % no opposite boundary, try next longest line
        continue;
    end
    % find next longest lines that are close to perpendicular
    perpendicular_idx = find(abs(angles(sorted_idx(2:end))-angle_longest)>80,2)
    
    %find intersections of parallel and perpendicular lines
    para_idx = [current_index;sorted_idx(parallel_idx+1)];
    perp_idx = sorted_idx(perpendicular_idx+1);
    corner_idx = 1;
    for para = 1:2
        for perp = 1:2
            para_pt1 = lines(para_idx(para)).point1;
            para_pt2 = lines(para_idx(para)).point2;
            m_para = (para_pt1(2)-para_pt2(2))/(para_pt1(1)-para_pt2(1));
            b_para = para_pt1(2) - m_para*para_pt1(1);
            perp_pt1 = lines(perp_idx(perp)).point1;
            perp_pt2 = lines(perp_idx(perp)).point2;
            m_perp = (perp_pt1(2)-perp_pt2(2))/(perp_pt1(1)-perp_pt2(1));
            b_perp = perp_pt1(2) - m_perp*perp_pt1(1);
            if isnan(m_perp)
                x_intersect = perp_pt1(1);
                y_intersect = m_para*x_intersect+b_para;
            elseif isnan(m_para)
                x_intersect = para_pt1(1);
                y_intersect = m_perp*x_intersect+b_perp;
            else
                x_intersect = (b_perp-b_para)/(m_para-m_perp);
                y_intersect = m_para*x_intersect+b_para;
            end
            corners(corner_idx,:) = [y_intersect;x_intersect];
            corner_idx = corner_idx+1;
        end
    end
%     xy_para = [lines(para_idx(para)).point1;lines(para_idx(para)).point2];
%         x = xy_para(:,1);
%         y = xy_para(:,2);
%         mb_para(:,para) = pinv([x ones(2,1)])*y;
%     end
%     for perp = 1:2
%         xy_perp = [lines(perp_idx(perp)).point1;lines(perp_idx(perp)).point2];
%         x = xy_perp(:,1);
%         y = xy_perp(:,2);
%         mb_perp(:,perp) = pinv([x ones(2,1)])*y;
%     end
%     corners(:,1) = pinv([mb_para(1,1), -1; mb_perp(1,1), -1])*[mb_para(2,1);mb_perp(2,1)];
%     corners(:,2) = pinv([mb_para(1,2), -1; mb_perp(1,1), -1])*[mb_para(2,2);mb_perp(2,1)];
%     corners(:,3) = pinv([mb_para(1,1), -1; mb_perp(1,2), -1])*[mb_para(2,1);mb_perp(2,2)];
%     corners(:,4) = pinv([mb_para(1,2), -1; mb_perp(1,2), -1])*[mb_para(2,2);mb_perp(2,2)];
    if any(corners<0) | any(corners(1,:)>num_rows) | any(corners(2,:)>num_cols)
        continue
    end
    %     y = xy(:,2);
%     x = xy(:,1);
%     [mb_l] = pinv([x ones(2,1)])*y;
%     perpendicular_idx = find(abs(theta-angle_longest)>80 & lengths>.5*chosen_length);
%     if length(perpendicular_idx) <2
%         % try next line b/c Hough doesn't see 2 sides
%         continue
%     end
%     % find where each perpendicular line intersects the longest line
%     edges = zeros(2,length(perpendicular_idx));
%     for n = 1:length(perpendicular_idx)
%         xy_perp = [lines(perpendicular_idx(n)).point1; lines(perpendicular_idx(n)).point2];
%         y = xy(:,2);
%         x = xy(:,1);
%         [mb_perp] = pinv([x ones(2,1)])*y;
%         edges(:,n) = pinv([mb_l(1), -1; mb_perp(1), -1])*[mb_l(2);mb_perp(2)];  
%         % check if edge is inside box/relatively close to actual segment
%         if edges(1,n) < 0 || edges(1,n)>num_rows || edges(2,n) < 0 || edges(2,n)>num_cols
%             edges(:,n) = nan(2,0);
%         end
%         inside_segment = (edges(1,n)<max(xy_perp(:,1))) & (edges(1,n)>min(xy_perp(:,1)));
%         if ~inside_segment
%             dist = min(norm(edges(:,n)-xy_perp(1,:)'),norm(edges(:,n)-xy_perp(2,:)'));
%             if dist > .1*norm(xy_perp(1,:)-xy_perp(2,:)) % large distance
%                 edges(:,n) = nan(2,0);
%             end
%         end
%     end
    %re-sort corners to be clockwise from topleft
    % K = convhull(x,y)
    break;
end

output_image = imrotate(input_image,houghTheta,'bilinear');

% Find where edges map to
rot_mat = [cosd(houghTheta) sind(houghTheta); -sind(houghTheta) cosd(houghTheta)];
for i = 1:4
    longest_edges(:,2*i-1) = lines(sorted_idx(i)).point1';
    longest_edges(:,2*i) = lines(sorted_idx(i)).point2';
end
corners = [0 0;num_cols 0; num_cols num_rows; 0 num_rows]';
num_pts = size(longest_edges,2);
mid_pt_in = fliplr(size(input_image))/2;
mid_pt_out = fliplr(size(output_image))/2;
output_corners = (rot_mat*(corners-repmat(mid_pt_in',1,4))) + ...
    repmat(mid_pt_out',1,4);
output_edges = (rot_mat*(longest_edges-repmat(mid_pt_in',1,num_pts))) + ...
    repmat(mid_pt_out',1,num_pts);
xmin = round(min(output_edges(1,:)))+30;
ymin = round(min(output_edges(2,:)))+30;
xmax = round(max(output_edges(1,:)))-30;
ymax = round(max(output_edges(2,:)))-30;
figure
imshow(input_image)
hold on
plot(longest_edges(1,:),longest_edges(2,:))

figure
imshow(output_image)
hold on
plot(output_edges(1,:),output_edges(2,:))

output_image = output_image(max(ymin,1):min(ymax,size(output_image,1)),...
    max(xmin,1):min(xmax,size(output_image,2)));
figure
imshow(output_image);
% output_corners = [0 0; 0 num_cols; num_rows, num_cols; num_rows 0];
% T = maketform('projective',corners,output_corners);
% [transformed,xdata,ydata] = imtransform(input_image,T);
% transformed = transformed(1+xdata(1):end,1+ydata(1):end);
% figure
% imshow(transformed)
end

