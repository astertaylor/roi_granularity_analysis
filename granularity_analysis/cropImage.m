function m_img = cropImage(in_img,roi)
    
    [y,x] = ind2sub(size(roi),find(roi==1));
    
    roi_ul_x = min(x);
    roi_ul_y = min(y);
    roi_lr_x = max(x);
    roi_lr_y = max(y);
    width = round(roi_lr_x-roi_ul_x);
    height = round(roi_lr_y-roi_ul_y);
    
    m_img = double(in_img) .* double(roi);
    
    m_img = m_img(roi_ul_y:double(roi_ul_y+height), roi_ul_x:double(roi_ul_x+width));

    m_img = squareControl(m_img,roi);
end
