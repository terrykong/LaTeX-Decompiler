function [ output_im ] = determineBlockSkew( input_image )
% Processes smaller blocks of the input image
%   Returns data about variance, the hough transform theta peaks
[num_rows, num_cols] = size(input_image);

%% Find out where the image has high variance
% and apply Hough ONLY there (to save time)
var_win_size = 64; 
win_ratio = 8; % better but slower 6
num_windows_row = ceil(num_rows/var_win_size);
num_windows_col = ceil(num_rows/var_win_size);
var_map = zeros(num_windows_row,num_windows_col);
for n = 1:num_windows_row
    row_start = (n-1)*var_win_size+1;
    row_end = min(row_start+var_win_size,num_rows);
    for m = 1:num_windows_col
        col_start = (m-1)*var_win_size+1;
        col_end = min(col_start+var_win_size,num_cols);
        
        block = input_image(row_start:row_end,col_start:col_end);
        var_map(n,m) = var(block(:));
    end
end

% set a threshold for "high" variance
var_map = var_map>.15*max(var_map(:));

hough_win_size = var_win_size*win_ratio;
num_hough_rows = floor(num_windows_row/win_ratio);
num_hough_cols = floor(num_windows_col/win_ratio);
thetaVec = -90:.5:89.5;
hough_data = zeros(size(thetaVec));
var_thresh = 0.01;
for n = 1:num_hough_rows
    for m = 1:num_hough_cols
        % If the current larger Hough block contains multiple high variance
        % blocks, find the Hough peaks
        high_var = sum(sum((var_map((n-1)*win_ratio+1:min(n*win_ratio,num_windows_row),...
            (m-1)*win_ratio+1:min(m*win_ratio,num_windows_col))))) > .25*win_ratio^2;
        if high_var
            row_start = (n-1)*hough_win_size+1;
            row_end = min(row_start+hough_win_size,num_rows);
            col_start = (m-1)*hough_win_size+1;
            col_end = min(col_start+hough_win_size,num_cols);
            block = input_image(row_start:row_end,col_start:col_end);
            [H,theta,rho] = hough(~block, 'Theta', thetaVec);
            % Find the top 30 peaks
            numPeaks = 30;
            thresh = 0.3*max(H(:));
            peaks = houghpeaks(H, numPeaks, 'Threshold', thresh);
            lines = houghlines(~block,theta,rho,peaks,'FillGap',100,'MinLength',100);
            thetaHist = hist(theta(peaks(:,2)), thetaVec);
            hough_data = hough_data+thetaHist;
            
            %% Plotting - comment out to remove figures
%             figure
%             subplot(211)
%             imshow(block)
%             hold on;
%             for k = 1:length(lines)
%                 xy = [lines(k).point1; lines(k).point2];
%                 plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
%                 
%             end
%             
%             subplot(212)
%             plot(thetaVec,thetaHist)
%             figure; clf;
%             subplot(2,1,1);
%             warning off; imshow(imadjust(mat2gray(H)), 'XData', theta, 'YData', rho, ...
%                 'InitialMagnification', 'fit'); axis on; axis normal; hold on; warning on;
%             plot(theta(peaks(:,2)), rho(peaks(:,1)), 'ys');
%             xlabel('\theta (degrees)'); ylabel('\rho');
%             subplot(2,1,2);
%             bar(thetaVec, thetaHist); grid on;
%             axis([min(thetaVec) max(thetaVec) 0 max(thetaHist)+2]);
%             xlabel('\theta (degrees)'); ylabel('Number of Peaks');
%             [maxHist, maxIdx] = max(thetaHist);
            
        end
    end
end

%% Plot total hough results
% Plot sum of histograms
% figure
% plot(thetaVec,hough_data)
% realize that we can also look at perpendicular lines, combine them 
% eg combine 0 and -90, 30 and -60, etc
hough_data_perp = hough_data(thetaVec<0)+hough_data(thetaVec>=0);
% throw out 45 degrees because there are a lot of relics-we'll limit our
% scope, reorder to show from -44.5 to +44.5
hough_data_perp = [hough_data_perp(end/2+2:end),hough_data_perp(1:end/2)];
theta_perp = -44.5:.5:44.5;
% figure
% plot(theta_perp,hough_data_perp)

% find the theta that shows up the most (if there are multiple maximums,
% find the median)
max_index = hough_data_perp == max(hough_data_perp);
theta_guess = median(theta_perp(max_index))
original_image = zeros(size(input_image,1),size(input_image,2),2);
original_image(:,:,1) = input_image;
original_image(:,:,2) = ones(size(input_image));
rotated_im = imrotate(original_image,theta_guess,'bilinear');
output_im = rotated_im(:,:,1);
% make new pixels from imrotate black
output_im(rotated_im(:,:,2)==0) = 1;
% figure
% imshow(output_im);
end
