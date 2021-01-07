function m_img = cropImage(in_img,roi,angle)
    m_img = double(in_img) .* double(roi); %set all values outside ROI to 0
    
    m_img = imrotate(m_img,-angle);
    
    roi = imrotate(roi,-angle); %rotate ROIs to find the edges
    [y,x] = ind2sub(size(roi),find(roi==1)); %find edges of ROI
   
    roi_ul_x = min(x);
    roi_ul_y = min(y);
    roi_lr_x = max(x);
    roi_lr_y = max(y);
    width = round(roi_lr_x-roi_ul_x);
    height = round(roi_lr_y-roi_ul_y); %find boundaries of ROI
    
    m_img = m_img(roi_ul_y:double(roi_ul_y+height), roi_ul_x:double(roi_ul_x+width)); %crop to edges of ROI
    
    if height>width 
        m_img = imrotate(m_img,90);
    end
 
   % m_img = squareControl(m_img,roi);
end
