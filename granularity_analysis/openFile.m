function gray=openFile(image_path) 
    readraw;
    image = imread(image_path);
    gray = rgb2gray(image);
    gray = image;
end