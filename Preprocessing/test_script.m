
im = imread('test_images/2col-journalpaper-howtotex-page-001.jpg');
im2 = imread('test_images/2col-journalpaper-howtotex-page-002.jpg');

im_dark = imread('test_images/IMG_1752.jpg');
im_light = imread('test_images/IMG_1742.jpg');
im_med = imread('test_images/IMG_1754.jpg');
input1 = imread('test_images/input.jpg');
input2 = imread('test_images/input2.jpg');
% angle = [-44:13.5:44];
% for n = 1:length(angle)
%     im_rot = imrotate(im,angle(n),'bilinear');
%     disp(sprintf('actual angle: %d',angle(n)));
%     im_out0 = preprocessDocument(im_rot);  
% end
% 
% 
% angle = [-43:11.5:44];
% for n = 1:length(angle)
%     im2_rot = imrotate(im2,angle(n),'bilinear');
%     disp(sprintf('actual angle: %d',angle(n)));
%     im_out2 = preprocessDocument(im2_rot);  
% end
% 
im_out = preprocessDocument(im);
im2_out = preprocessDocument(im2);

im_out_dark = preprocessDocument(im_dark);
im_out_light = preprocessDocument(im_light);
im_out_med = preprocessDocument(im_med);

output1 = preprocessDocument(input1);
output2 = preprocessDocument(input2);