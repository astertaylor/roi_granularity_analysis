% Main script to extract the smallest square from inside a blob
% The blob is a binary image

clear;close;clc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a dummy image called "mask" with ROIs
% Aster will replace this part with the code to read ImageJ ROI in Matlab
%
% Create an empty binary image of size s x s x 1
s = 500;
I = zeros(s,s,1);

% Add 2 arbitrary shaped ROIs
imshow(I)
pix = impoly(gca);
wait(pix) % waits for the user to draw a closed polygon. double click when done to accept it
mask1 = createMask(pix);


pix2 = impoly(gca);
wait(pix2) % waits for the user to draw a closed polygon. double click when done to accept it
mask2 = createMask(pix2);

close;
% This is our dummy ROI
mask = logical(mask1 + mask2);

imshow(mask);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now cycle through the blobs and find the biggest square that fits in each
% blob, centered at its centroid

close all

% Find the squares
[L,n] = bwlabel(mask); % selects all blobs in image
LRout = cell(2,1);
Icropped = cell(2,1);

% Loop through all blobs and search for biggest squares inscribed
for i = 1:n
    thisMask = L == i;
    pts = LargestSquare(thisMask,0.1,0,0,0,0);
    Icropped{i} = poly2mask(pts(2:end,1),pts(2:end,2),s,s);
   
end

% Take a look at the squares found
figure
subplot(121)
imshow(mask)
hold on
contour(Icropped{1},1,'r')
subplot(122)
imshow(mask)
hold on
contour(Icropped{2},1,'r')

% Write each square to file - change this to match what you need
for i = 1:numel(Icropped)
    thisMask = Icropped{i};
    imwrite(thisMask,fullfile('.',['square_mask_',num2str(i),'.tif']))
end

