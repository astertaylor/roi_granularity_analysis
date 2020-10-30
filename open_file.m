function gray=open_file(image_path) 
    readraw;
    image = imread(image_path);
    gray = rgb2gray(image);   
%   gray = 255*mat2gray(gray);
    gray = gray-mean(gray(:));
    std_dev = std(double(gray(:)));
    gray = gray/std_dev;
    gray = gray + 5;
    "Gray Minimum"
    min(gray(:))
end