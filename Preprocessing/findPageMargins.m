function [ output_image ] = findPageMargins( input_image )
% given a binarized page that's rotated to the correct angle, find where
% the text starts and stops

output_image = input_image;
%% Find y bounds
y_projection = sum(input_image,2);
% add 1 to allow us to divide (so we can use matlab findpeaks)
y_projection = y_projection+1;
% find first place where there's a dip in the number of white pixels --
% either location of border or location of text
% make sure peaks differ from neighbors by at least 5 pixels
threshold = (1/median(y_projection))-(1/median(y_projection+5));
[y_peak_val,y_peak_loc] = findpeaks(1./y_projection,'Threshold',threshold);
% remove outliers -- most text lines will have same order of magnitude of
% pixels, so any peaks with too many or too few pixels should be tossed out
valid_peaks = y_peak_val>.5*median(y_peak_val) & y_peak_val<1.5*median(y_peak_val);
y_peak_loc = y_peak_loc(valid_peaks);

y_min = y_peak_loc(1);
y_max = y_peak_loc(end);

output_image = output_image(max(y_min-10,1):min(y_max+10,size(output_image,1)),:);

%% Find x bounds
x_projection = sum(output_image,1);
% look for at least 5 pixels in a row of no 
% add 1 to allow us to divide (so we can use matlab findpeaks)
x_projection = x_projection+1;
% make sure peaks differ from neighbors by at least 5 pixels
threshold = (1/median(x_projection))-(1/median(x_projection+5));
[x_peak_val,x_peak_loc] = findpeaks(1./x_projection,'Threshold',threshold);
% remove outliers -- most text lines will have same order of magnitude of
% pixels, so any peaks with too many or too few pixels should be tossed out
valid_peaks = x_peak_val>.5*median(x_peak_val) & x_peak_val<1.5*median(x_peak_val);
x_peak_loc = x_peak_loc(valid_peaks);

x_min = x_peak_loc(1);

x_max = x_peak_loc(end);

%% crop output image
output_image = output_image(:,max(x_min-10,1):min(x_max+10,size(output_image,2)));
figure
imshow(output_image)
end

