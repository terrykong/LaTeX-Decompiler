function [ rotTheta ] = determineSkew( input_image )
% Determine the angle to which the input image is rotated. The input
% document is assumed to be mostly text
global_thresh = graythresh(uint8(255*input_image));
binarized_image = input_image>global_thresh;

% downsample ? 

%% direction of gradient 
%http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.12.6258&rep=rep1&type=pdf
smoothing_kernel = [1 2 1];
grad_kernel = [1 0 -1];
Sobel_5 = conv2(smoothing_kernel'*smoothing_kernel,smoothing_kernel'*grad_kernel);

im_x = imfilter(double(binarized_image), Sobel_5);
im_y = imfilter(double(binarized_image), Sobel_5');

% If the gradient is 0 in both directions, throw out the pixel
pixels_with_gradient = find(im_x~=0 | im_y~=0);
x_grad_values = im_x(pixels_with_gradient);
y_grad_values = im_y(pixels_with_gradient);

gradient_angles = atand(y_grad_values(:)./x_grad_values(:));
thetaVec = -90 : 0.5 : 89.5;
angle_hist = hist(gradient_angles,thetaVec);
[sorted_hist,sorted_idx] = sort(angle_hist,'descend');
% normalized_value = sorted_hist(1:3)./sorted_hist(4);
% angle_hist(sorted_idx(1:3)) = angle_hist(sorted_idx(1:3)).*normalized_value;
angle_hist(thetaVec==45) = angle_hist(thetaVec==45) - round(.04*sum(angle_hist));
angle_hist(thetaVec==-45) = angle_hist(thetaVec==-45) - round(.04*sum(angle_hist));
angle_hist(thetaVec==0) = angle_hist(thetaVec==0) - round(.04*sum(angle_hist));
% percent45 = angle_hist(thetaVec==45)/sum(angle_hist);
% percentm45 = angle_hist(thetaVec==-45)/sum(angle_hist);
% percent0 = angle_hist(thetaVec==0)/sum(angle_hist);

% use overlapping coarse range to find clusters of peaks
num_half_degrees_per_bin = 20;
num_bins = 2*length(thetaVec)/num_half_degrees_per_bin-1;
coarse_hist = zeros(num_bins,1);
for bin = 0:num_bins - 1
    coarse_hist(bin+1) = sum(angle_hist(num_half_degrees_per_bin/2*bin+1:...
        num_half_degrees_per_bin/2*(bin+2)));
end
coarse_theta = thetaVec(num_half_degrees_per_bin/2*(0:num_bins-1)+1);
figure (1)
bar(coarse_theta, coarse_hist); grid on;
axis([min(thetaVec) max(thetaVec) 0 max(coarse_hist)+2]);
xlabel('\theta (degrees)'); ylabel('Number of Peaks');
[maxHist, rangeIdx] = max(coarse_hist);
bin_min = num_half_degrees_per_bin*(rangeIdx-1)/2+1;
bin_max = num_half_degrees_per_bin*(rangeIdx+1)/2;
angle_range = bin_min:bin_max;
% use fine range to determine exact angle
figure (2)
bar(thetaVec(angle_range), angle_hist(angle_range)); grid on; 
axis([thetaVec(angle_range(1)) thetaVec(angle_range(end)) 0 max(angle_hist)+2]);
xlabel('\theta (degrees)'); ylabel('Number of Peaks');
[maxHist, maxIdx] = max(angle_hist(angle_range));
max_val = thetaVec(angle_range(1)+maxIdx-1);
%find mean and round to the nearest .5
av_val = thetaVec(angle_range)*angle_hist(angle_range)'/(sum(angle_hist(angle_range)));
av_val = .5*(round(av_val*2));
meanIdx = find(thetaVec(angle_range) == av_val);
%find median
data_in_range = [];
for i = 1:length(angle_range)
    data_in_range = [data_in_range, thetaVec(angle_range(i))*ones(1,angle_hist(angle_range(i)))];
end
med_val = median(data_in_range);
med_val = .5*(round(med_val*2));
medIdx = find(thetaVec(angle_range) == med_val);
maxTheta = thetaVec(medIdx+angle_range(1)-1);
gradTheta = maxTheta

rotTheta = gradTheta;

% %% Hough transform
% % grabs angles running along 45 degrees
% angle_range = max(bin_min-10,1):min(bin_max+10,length(thetaVec));
% thetaVec = thetaVec; %(angle_range);
% [H,theta,rho] = hough(binarized_image, 'Theta', thetaVec);
% numPeaks = 40;
% thresh = 0.2*max(H(:));
% peaks = houghpeaks(H, numPeaks, 'Threshold', thresh);
% thetaHist = hist(theta(peaks(:,2)), thetaVec);
% figure (3); clf;
% subplot(2,1,1);
% warning off; imshow(imadjust(mat2gray(H)), 'XData', theta, 'YData', rho, ...
%  'InitialMagnification', 'fit'); axis on; axis normal; hold on; warning on;
% plot(theta(peaks(:,2)), rho(peaks(:,1)), 'ys');
% xlabel('\theta (degrees)'); ylabel('\rho');
% subplot(2,1,2);
% bar(thetaVec, thetaHist); grid on;
% axis([min(thetaVec) max(thetaVec) 0 max(thetaHist)+2]);
% xlabel('\theta (degrees)'); ylabel('Number of Peaks');
% [maxHist, maxIdx] = max(thetaHist);
% houghTheta = median(theta(peaks(:,2)));
% 
% %% Hough transform of inverse of image
% [H,theta,rho] = hough(~binarized_image, 'Theta', thetaVec);
% numPeaks = 40;
% thresh = 0.2*max(H(:));
% peaks = houghpeaks(H, numPeaks, 'Threshold', thresh);
% thetaHist = hist(theta(peaks(:,2)), thetaVec);
% figure (4); clf;
% subplot(2,1,1);
% warning off; imshow(imadjust(mat2gray(H)), 'XData', theta, 'YData', rho, ...
%  'InitialMagnification', 'fit'); axis on; axis normal; hold on; warning on;
% plot(theta(peaks(:,2)), rho(peaks(:,1)), 'ys');
% xlabel('\theta (degrees)'); ylabel('\rho');
% subplot(2,1,2);
% bar(thetaVec, thetaHist); grid on;
% axis([min(thetaVec) max(thetaVec) 0 max(thetaHist)+2]);
% xlabel('\theta (degrees)'); ylabel('Number of Peaks');
% [maxHist, maxIdx] = max(thetaHist);
% houghInvTheta = median(theta(peaks(:,2)));
% 
% [gradTheta, houghTheta, houghInvTheta]
end

