function saveImage(image,out_path,folder,name,image_class)   
    if strcmp('image',image_class) %save images
        image = image/max(image(:)); %rescale image to [0,1]
        imwrite(image,fullfile(out_path,folder,strcat(name,".png"))); %write image
    elseif strcmp('figure',image_class)
        imwrite(image/max(image(:)),fullfile(out_path,folder,strcat(name,"_output.png"))); %save Fourier transforms
    end
end
