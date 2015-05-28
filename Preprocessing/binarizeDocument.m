function [ binarized_image ] = binarizeDocument( input_image )
% Binarizes the input image of a text document
%   Detailed explanation goes here

%% find global threshold from Otsu's method
global_thresh = graythresh(uint8(255*input_image));
binarized_image = input_image>global_thresh;
figure
imshow(binarized_image)

%% Locally Adaptive Thresholding
[num_rows,num_cols] = size(input_image);
% parameters for local binarization
window_size = 64;
step_size = 16;
var_thresh = .01;

num_tiles_row = floor(num_rows / step_size);
num_tiles_col = floor(num_cols / step_size);
binarized_image = zeros(num_rows,num_cols);
num_times_evaluated = zeros(size(binarized_image));
% keep track of margins
max_bounds_text_tiles = zeros(2,1);
min_bounds_text_tiles = inf(2,1);
for row_tile= 1:num_tiles_row
    min_row = (row_tile-1)*step_size + 1;
    max_row = min(min_row+window_size-1,num_rows);
    y_range = min_row:max_row;
    for col_tile = 1:num_tiles_col
        min_col = (col_tile-1)*step_size + 1;
        max_col = min(min_col+window_size-1,num_cols);
        x_range = min_col:max_col;
        input_window = input_image(y_range,x_range);
        if var(input_window(:)) > var_thresh
            % find the first and last tiles with high variance--represents
            % where text is, and will provide our estimate of margin
            if min_row<min_bounds_text_tiles(1)
                min_bounds_text_tiles(1) = min_row;
            end
            if max_row>max_bounds_text_tiles(1)
                max_bounds_text_tiles(1) = max_row;
            end
            if min_col<min_bounds_text_tiles(2)
                min_bounds_text_tiles(2) = min_col;
            end
            if max_col>max_bounds_text_tiles(2)
                max_bounds_text_tiles(2) = max_col;
            end

            % find local threshold and increment counter
            local_thresh = graythresh(uint8(255*input_window));
            thresholded_window = (input_window > local_thresh);
            
            %% apply double threshold
            % not actually used-will certainly connect components, but
            % maybe too much? letters are all connected, but if we don't do
            % text recognition
            double_threshed = thresholded_window;
            % find values above otsu threshold by a small amount
            [mid_val_row,mid_val_col] = find( (input_window>local_thresh) & ...
                (input_window<1.1*local_thresh));
            % see if any of these values are in 8-neighborhood of values 
            % lower than the otsu threshold - if so mark them as black
            for i = 1:length(mid_val_row)
                double_threshed(mid_val_row(i),mid_val_col(i)) = all(all(thresholded_window(...
                    max(1,mid_val_row(i)-1):min(size(input_window,1),mid_val_row(i)+1),...
                    max(1,mid_val_col(i)-1):min(size(input_window,2),mid_val_col(i)+1))));
            end
            % use thresholded_window for single threshold, double_threshed
            % for double threshold (chunkier text)
            binarized_image(y_range,x_range) = binarized_image(y_range,x_range)...
                + thresholded_window;
        else
            binarized_image(y_range,x_range) = binarized_image(y_range,x_range)...
                + 1; %(mean(input_window(:)) > global_thresh);
        end
        num_times_evaluated(y_range,x_range) = num_times_evaluated(y_range,x_range) ...
            + ones(size(input_window));
    end
end

% if local thresholding evaluated as 1 more than half the time, consider
% the output to be 1 at that point
binarized_image = binarized_image./num_times_evaluated>.75;

binarized_image = binarized_image(min_bounds_text_tiles(1):max_bounds_text_tiles(1),...
    min_bounds_text_tiles(2):max_bounds_text_tiles(2));
figure
imshow(binarized_image)

% % http://liris.cnrs.fr/christian.wolf/papers/tr-rfv-2002-01.pdf
% % use a double threshold

end

