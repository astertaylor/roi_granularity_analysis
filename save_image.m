function save_image(image,out_path,folder,name,image_class)
    figure(2);
    imshow(image,[]);
    
    if strcmp('image',image_class)
        imwrite(10*image,strcat(out_path,"/",folder,"/",name,".png"));
    elseif strcmp('figure',image_class)
        imwrite(image/max(image(:)),strcat(out_path,"/",folder,"/",name,"_output.png"));
    end
end
