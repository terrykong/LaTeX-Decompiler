
im = imread('test_images/2col-journalpaper-howtotex-page-001.jpg');
im2 = imread('test_images/2col-journalpaper-howtotex-page-002.jpg');

im_dark = imread('test_images/IMG_1752.jpg');
im_light = imread('test_images/IMG_1742.jpg');
im_med = imread('test_images/IMG_1754.jpg');
angle = [-44:1.5:44];
for n = 1:length(angle)
    im_rot = imrotate(im,angle(n),'bilinear');
    disp(sprintf('actual angle: %d',angle(n)));
    preprocessDocument(im_rot);  
end


angle = [-44:2.5:44];
for n = 1:length(angle)
    im2_rot = imrotate(im2,angle(n),'bilinear');
    disp(sprintf('actual angle: %d',angle(n)));
    preprocessDocument(im2_rot);  
end

preprocessDocument(im_dark);
preprocessDocument(im_light);
preprocessDocument(im_med);