function output = square_control(m_img,roi)
    cutout = getInnerRectangle(roi);
    [y,x] = ind2sub(size(roi),find(roi==1));
    roi_ul_x = min(x);
    roi_ul_y = min(y);
    roi_lr_x = max(x);
    roi_lr_y = max(y);
    width = round(roi_lr_x-roi_ul_x);
    height = round(roi_lr_y-roi_ul_y);
    
    cutout = cutout(roi_ul_y:double(roi_ul_y+height), roi_ul_x:double(roi_ul_x+width));
    "Cutout Size"
    size(cutout)
    
    m_img = double(m_img) .* double(cutout);
    
    [y,x] = ind2sub(size(cutout),find(cutout==1));
    roi_ul_x = min(x);
    roi_ul_y = min(y);
    roi_lr_x = max(x);
    cutsize = round(roi_lr_x-roi_ul_x);
   
    output = m_img(roi_ul_y:double(roi_ul_y+cutsize), roi_ul_x:double(roi_ul_x+cutsize));
end
