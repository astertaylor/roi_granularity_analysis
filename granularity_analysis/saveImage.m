function saveImage(image,out_path,folder,name,image_class)   
    if strcmp('image',image_class)
        image = image/max(image(:));
        imwrite(image,fullfile(out_path,folder,strcat(name,".png")));
    elseif strcmp('figure',image_class)
        imwrite(image/max(image(:)),fullfile(out_path,folder,strcat(name,"_output.png")));
    end
end
