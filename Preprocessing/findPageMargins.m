function [ output_image ] = findPageMargins( input_image )
% given a binarized page that's rotated to the correct angle, find where
% the text starts and stops

output_image = input_image;
% if there's a line with significantly more black pixels, it's probably
% background/border, so remove
projection_ratio_bound = 2.7;
% Only look at peaks of projection onto axis that have values in range of
% median
peak_range_low = .3;
peak_range_high = 1.7;
% num pixels to add back on each side of image because it crops close
pixel_margin = 30; 
%% Find y bounds
y_projection = sum(~input_image,2);
% figure
% plot(y_projection)
% title('projection of pixels on y axis')

% find first place where there's a dip in the number of white pixels --
% either location of border or location of text
% make sure peaks differ from neighbors by at least 5 pixels
threshold =10; %(1/median(y_projection))-(1/median(y_projection+5));
[y_peak_val,y_peak_loc] = findpeaks(y_projection,'Threshold',threshold);
median_peak = median(y_peak_val);
% find outlier peaks from edges: look for large black components closest to
% center
y_start = find(y_projection(1:floor(end/2))>...
    projection_ratio_bound*median_peak,1,'last');
y_end = find(y_projection(ceil(end/2):end)>...
    projection_ratio_bound*median_peak,1,'first')+...
    ceil(length(y_projection)/2);
if isempty(y_start)
    y_start = 1;
end
if isempty(y_end)
    y_end = length(y_projection);
end

% Now that we've figured out where the edges are, look at the projection
% just within that range
[y_peak_val,y_peak_loc] = findpeaks(y_projection(y_start:y_end),'Threshold',threshold);
% remove outliers -- most text lines will have same order of magnitude of
% pixels, so any peaks with too many or too few pixels should be tossed out
median_peak = median(y_peak_val);
valid_peaks = y_peak_val>peak_range_low*median_peak & ...
    y_peak_val<peak_range_high*median_peak;
y_peak_loc = y_peak_loc(valid_peaks);

y_min = y_peak_loc(1)+y_start-1;
y_max = y_peak_loc(end)+y_start-1;

output_image = output_image(max(y_min-pixel_margin,1):...
    min(y_max+pixel_margin,size(output_image,1)),:);
% figure
% subplot(211)
% imshow(output_image)
%% Find x bounds
x_projection = sum(~output_image,1);

% make sure peaks differ from neighbors by at least 5 pixels
threshold = 10; %(1/median(x_projection))-(1/median(x_projection+5));
[x_peak_val,x_peak_loc] = findpeaks(x_projection,'Threshold',threshold);
median_peak = median(x_peak_val);
% find outlier peaks from edges: look for large black components closest to
% center
x_start = find(x_projection(1:floor(end/2))>...
    projection_ratio_bound*median_peak,1,'last');
x_end = find(x_projection(ceil(end/2):end)>...
    projection_ratio_bound*median_peak,1,'first')+...
    ceil(length(x_projection)/2);
if isempty(x_start)
    x_start = 1;
end
if isempty(x_end)
    x_end = length(x_projection);
end

% Now that we've figured out edges, look at the projection just inside doc
threshold = 5;
[x_peak_val,x_peak_loc] = findpeaks(x_projection(x_start:x_end),'Threshold',threshold);
% remove outliers -- most text lines will have same order of magnitude of
% pixels, so any peaks with too many or too few pixels should be tossed out
median_peak = median(x_peak_val);

valid_peaks = x_peak_val>peak_range_low*median_peak & ...
    x_peak_val<peak_range_high*median_peak;
x_peak_loc = x_peak_loc(valid_peaks);

x_min = x_peak_loc(1)+x_start-1;

x_max = x_peak_loc(end)+x_start-1;

output_image = output_image(:,max(x_min-pixel_margin,1):...
    min(x_max+pixel_margin,size(output_image,2)));
% subplot(212)
% imshow(output_image)
% figure
% subplot(211)
% plot(y_projection,1:length(y_projection))
% title('projection of pixels on y axis')
% subplot(212)
% plot(1:length(x_projection),x_projection)
% title('projection of pixels on x axis')

%% Find y projection and bounds again
%now that background in x-direction has been removed
y_projection = sum(~output_image,2);

threshold = 5;
[y_peak_val,y_peak_loc] = findpeaks(y_projection,'Threshold',threshold);
% remove outliers -- most text lines will have same order of magnitude of
% pixels, so any peaks with too many or too few pixels should be tossed out
median_peak = median(y_peak_val);
valid_peaks = y_peak_val>peak_range_low*median_peak & ...
    y_peak_val<peak_range_high*median_peak;
y_peak_loc = y_peak_loc(valid_peaks);

y_min = y_peak_loc(1);
y_max = y_peak_loc(end);

output_image = output_image(max(y_min-pixel_margin,1):...
    min(y_max+pixel_margin,size(output_image,1)),:);

%% display output image
figure
imshow(output_image)
end

