function [roi_mat,labels,angles] = getROIs(gray,roi_file, inFile)
    labels = [];
    angles = [];
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
    
    rois = ReadImageJROI(roi_file); %open ROIs
    
    for i = 1:length(rois)
        roi = rois{i};
        
        if strcmp(roi.strType,'Rectangle')
            slice = zeros(sizex,sizey);
            points = roi.vnRectBounds;
            slice(points(1):points(3),points(2):points(4)) = ones(points(3)-(points(1)-1),points(4)-(points(2)-1));
        else
            slice = poly2mask(roi.mnCoordinates(:,1),roi.mnCoordinates(:,2), sizex,sizey); %set ROI as area
        end
        
        delY = roi.mnCoordinates(2,1)-roi.mnCoordinates(1,1);
        delX = roi.mnCoordinates(2,2)-roi.mnCoordinates(1,2);
        angles = cat(2,angles,atand(delY/delX));
        
        roi_mat = cat(3,roi_mat,slice);
        
        labels = cat(2,labels,[strrep(string(roi.strName),'/','-')]);
    end
    
end
