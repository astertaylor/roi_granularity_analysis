function gray=openFile(image_path) 
    dc = readraw;
    image = imread(dc,image_path); %open image
    gray = rgb2gray(image); %set to grayscale
end