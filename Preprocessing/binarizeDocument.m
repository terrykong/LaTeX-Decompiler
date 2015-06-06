function [ binarized_image] = binarizeDocument( input_image )
% Binarizes the input image of a text document
%   Detailed explanation goes here

%% find global statistics
var_all = var(input_image(:));
mean_all = mean(input_image(:));

%% Determine Variance threshold

var_thresh = .4; 
% if the overall image has a very low variance or a very high variance, the
% variance threshold used in determining whether to apply Otsu's method to 
% particular block should be lower
% We use a piecewise linear function to model how the input image variance
% should modify the variance threshold
variance_factor = var_all;
if variance_factor > .10 % cap variance comparison
    variance_factor = .01;
elseif variance_factor >.06 
    variance_factor = .11-variance_factor;
end
% If there is a very low mean, the variance threshold should be lowered,
% since an overall darker image will have a lower contrast in general
var_thresh = var_thresh*mean_all*variance_factor;
%% Locally Adaptive Thresholding
[num_rows,num_cols] = size(input_image);
% parameters for local binarization: how to divide the image
window_size = 128;
step_size = 64; 
num_tiles_row = floor(num_rows / step_size);
num_tiles_col = floor(num_cols / step_size);
% variables to keep track of how many times each pixel is evaluated to be 1
% and how many times each pixel is evaluated in this algorithm (sliding
% windows evaluate corner/edge pixels fewer times)
binarized_image = zeros(num_rows,num_cols);
num_times_evaluated = zeros(size(binarized_image));

% apply windows to image
for row_tile= 1:num_tiles_row
    %find row boundaries
    min_row = (row_tile-1)*step_size + 1;
    max_row = min(min_row+window_size-1,num_rows);
    y_range = min_row:max_row;
    for col_tile = 1:num_tiles_col
        % find column boundaries
        min_col = (col_tile-1)*step_size + 1;
        max_col = min(min_col+window_size-1,num_cols);
        x_range = min_col:max_col;
        input_window = input_image(y_range,x_range);
        % calculate variance of input window
        var_local = var(input_window(:));
        % find the variance of the input window in relation to the range of 
        % the window. Portions of the image with high contrast (high 
        % max/min value) are more likely to contain text,and dividing 
        % max/min (rather than taking the difference) allows darker parts 
        % of the image (with low min and max values) to still be interpreted 
        % as having high variance 
        ratio_range = var_local*max(input_window(:))/min(input_window(:));
        if ratio_range > var_thresh
            % find local threshold and increment white pixel counter
            local_thresh = graythresh(uint8(255*input_window));
            thresholded_window = (input_window > local_thresh);
            
            binarized_image(y_range,x_range) = binarized_image(y_range,x_range)...
                + thresholded_window;
        else % low variance
            binarized_image(y_range,x_range) = binarized_image(y_range,x_range)...
                + 1; 
        end
        % increment the total number of times each pixel in the window was
        % evaluated
        num_times_evaluated(y_range,x_range) = num_times_evaluated(y_range,x_range) ...
            + ones(size(input_window));
    end
end

% Weight dark pixels more--local thresholding must evaluated a pixel to be 
% white more than 4/5 of the time, for the output to be considered white at
%that point
binarized_image = binarized_image./num_times_evaluated>.8;

figure
imshow(binarized_image)
imwrite(binarized_image,'bin_im.jpg','jpg')

end

