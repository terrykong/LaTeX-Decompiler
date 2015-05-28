function [ output_image ] = findCorners( lines, input_image)
% Find intersections of e
%   Detailed explanation goes here

for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    
    % Find longest lines as they will likely be edges
    lengths(k) = norm(lines(k).point1 - lines(k).point2);
    angles(k) = lines(k).theta;
end

[sorted_lengths,sorted_idx] = sort(lengths,'descend');

%% Find edges and corners of intersection
corners = [];
line_idx = [];
for n = 1:length(lines)
    line1 = lines(n);
    angle_line1 = lines(n).theta;
    
    %find slope/intercept of 1st line
    xy_line1 = [lines(n).point1;lines(n).point2];
    x = xy_line1(:,1);
    y = xy_line1(:,2);
    mb_line1 = pinv([x ones(2,1)])*y;
    
    for m = n+1:length(lines)
        line2 = lines(m);
        %find slope/intercept of 1st line
        xy_line2 = [lines(m).point1;lines(m).point2];
        angle_line2 = lines(m).theta;
        if(abs(angle_line1-angle_line2)<45) % if too close to parallel
            continue;
        end
        x = xy_line2(:,1);
        y = xy_line2(:,2);
        mb_line2 = pinv([x ones(2,1)])*y;
        
        % find intersection of lines
        if isnan(mb_line2(1))
            x_intersect = line2.point1(1);
            y_intersect = mb_line1(1)*x_intersect+mb_line1(2);
        elseif isnan(mb_line1(1))
            x_intersect = line1.point1(1);
            y_intersect = mb_line2(1)*x_intersect+mb_line2(2);
        else
            x_intersect = (mb_line2(2)-mb_line1(2))/(mb_line1(1)-mb_line2(1));
            y_intersect = mb_line1(1)*x_intersect+mb_line1(2);
        end
        corner = [y_intersect;x_intersect];
        in_bounds = all(corner>0) & (y_intersect<size(input_image,1)) & ...
            (x_intersect<size(input_image,2));
        in_line1 = (x_intersect<max(line1.point1(1), line1.point1(2))) & ...
            (x_intersect>min(line1.point1(1), line1.point1(2)));
        in_line2 = (x_intersect<max(line2.point1(1), line2.point1(2))) & ...
            (x_intersect>min(line2.point1(1), line2.point1(2)));
        dist_line1 = min(norm([x_intersect,y_intersect]-line1.point1),norm([x_intersect,y_intersect]-line1.point2));
        dist_line2 = min(norm([x_intersect,y_intersect]-line2.point1),norm([x_intersect,y_intersect]-line2.point2));
        close_to_line1 = in_line1 || (dist_line1<.25*norm(line1.point1-line1.point2));
        close_to_line2 = in_line2 || (dist_line2<.25*norm(line2.point1-line2.point2));
        
        if ~close_to_line1 || ~close_to_line2
           a = 2; 
        end
        
        if in_bounds && close_to_line1 && close_to_line2
            corners = [corners corner];
            line_idx = [line_idx [n;m]];
        end
    end
end

% Plot locations of corners
if size(corners,2) > 0
    hold on
    plot(corners(2,:),corners(1,:),'ro')
end

% If there were enough corners found, use for perspective transform
if size(corners,2) > 4
    %use convex hull to find outside points
    K = convhull(corners(2,:),corners(1,:));
    hold on
    plot(corners(2,K),corners(1,K),'c');
    max_area = 0;
    combo = zeros(4,1);
    % find which points will result in largest quadrilateral
    % Should also check how close points are to lines
    for pt1_idx = 1:length(K)-1
        for pt2_idx = pt1_idx+1:length(K)-1
            for pt3_idx = pt2_idx+1:length(K)-1
                for pt4_idx = pt3_idx+1:length(K)-1
                    indices = [pt1_idx,pt2_idx,pt3_idx,pt4_idx];
                    area = polyarea(corners(2,K(indices)),corners(1,K(indices)));
                    if area>max_area
                        max_area = area;
                        combo = indices;
                    end
                end
            end
        end
    end
    figure
    imshow(input_image);
    hold on
    plot(corners(2,K(combo)),corners(1,K(combo)),'g');
    
    corners = flipud(corners(:,K(combo)));
    [num_rows,num_cols] = size(input_image);
    output_corners = [0 num_cols; num_rows, num_cols; num_rows 0; 0 0];
    T = maketform('projective',corners',output_corners);
    [output_image,xdata,ydata] = imtransform(input_image,T);
    xmin = 1-xdata(1)+30;
    xmax = xdata(2)-30;
    ymin = 1-ydata(1)+30;
    ymax = ydata(2)-30; 

else % if we didn't find 4 corners
    
    %% Find angle of rotation and de-rotate
    % assume that the longest Hough line corresponds to the longest side of
    % the page, since we don't have enough edges to tell
    houghTheta = angles(sorted_idx(1))
    
    %% Find where longest Hough Transform lines map to after rotation
    % assume these correspone to  edge of paper
    % apply rotation matrix to lines
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
    output_image = imrotate(input_image,houghTheta,'bilinear');

end

output_image = output_image(max(ymin,1):min(ymax,size(output_image,1)),...
    max(xmin,1):min(xmax,size(output_image,2)));

figure
imshow(output_image)
title('findCorners output')
end

