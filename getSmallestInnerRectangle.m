function cutout_mat = getSmallestInnerRectangle(rois)

%% Now cycle through the blobs and find the biggest square that fits in each
% blob, centered at its centroid

img_size = size(rois);
sizex = img_size(1);
sizey = img_size(2);

Icropped = cell(2,1);
pts_store = [];

% Loop through all blobs and search for biggest squares inscribed
min_size = sizey;

for i = 1:img_size(3)
    thisMask = rois(:,:,i);
    pts = LargestSquare(thisMask,0.1,0,0,0,0);
    if pts(1) == 1
        continue
    end
    if (pts(3,1)-pts(2,1))<min_size
        min_size = (pts(3,1)-pts(2,1));
    end
    pts_store = cat(3,pts_store,pts);
end
dim = size(pts_store);
for i = 1:dim(3)
    pts = pts_store(1:3,1:2,i);
    uly = pts(2,1);
    ulx = pts(3,2);
    pts = cat(1,pts,[uly+min_size+2,ulx+min_size]);
    pts = cat(1,pts,[uly,ulx+min_size]);
    Icropped{i} = poly2mask(pts(2:end,1),pts(2:end,2),sizex,sizey);
end

% Take a look at the squares found

cutout_mat = [];
% Write each square to file - change this to match what you need
for i = 1:numel(Icropped)
    thisMask = Icropped{i};
    cutout_mat = cat(3,cutout_mat,thisMask);
end
