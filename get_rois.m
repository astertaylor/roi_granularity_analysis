function [roi_mat,labels] = get_rois(gray,roi_file, inFile)
    labels = [];
    roi_mat = [];
    if isempty(roi_file)
        roi_file = split(inFile,'.');
        roi_file = roi_file(1);
        roi_file = strcat(roi_file,'.zip');
    else
        roi_file = roi_file(1);
    end
    
    img_size = size(gray);
    sizex = img_size(1);
    sizey = img_size(2);
    
    rois = ReadImageJROI(roi_file);
    
    for i = 1:length(rois)
        roi = rois{i};
        
        if strcmp(roi.strType,'Rectangle')
            slice = zeros(sizex,sizey);
            points = roi.vnRectBounds;
            slice(points(1):points(3),points(2):points(4)) = ones(points(3)-(points(1)-1),points(4)-(points(2)-1));
        else
            slice = poly2mask(roi.mnCoordinates(:,1),roi.mnCoordinates(:,2), sizex,sizey);
        end
        
        roi_mat = cat(3,roi_mat,slice);
        
        labels = cat(2,labels,[string(roi.strName)]);
    end
    
%     roi_mat = getSmallestInnerRectangle(roi_mat);
end
