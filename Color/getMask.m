function [rois,labels] = getMask(gray,roi_file, in_file)
    labels = [];
    if isempty(roi_file)
        roi_file = split(in_file,'.');
        roi_file = roi_file(1);
        roi_file = strcat(roi_file,'.zip');
    else
        roi_file = roi_file(1);
    end
    
    [sizex,sizey,~] = size(gray);
   
    rois = ReadImageJROI(roi_file); %open ROIs
    
    for i = 1:length(rois)
        roi = rois{i};
        
        if strcmp(roi.strType,'Rectangle')
            slice = zeros(sizex,sizey);
            points = roi.vnRectBounds;
            slice(points(1):points(3),points(2):points(4)) = ones(points(3)-(points(1)-1),points(4)-(points(2)-1));
%             slice = repmat(slice,[1 1 sizez]);
        else
            slice = poly2mask(roi.mnCoordinates(:,1),roi.mnCoordinates(:,2), sizex,sizey); %set ROI as area
%             slice = repmat(slice,[1 1 sizez]);
        end
        
        rois{i} = slice;
        
        labels = cat(2,labels,[strrep(string(roi.strName),'/','-')]);
    end
end
