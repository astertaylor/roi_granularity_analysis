function saveContours(gray,rois,labels)
    fig3 = figure(3);
    fig3.WindowState = 'maximized';
    dim = length(labels); %get numbers of ROI
    colors = colorcet('R4','N',dim); %set colors
    imshow(gray,[]); %start plot
    hold on
    for ind = 1:dim
        contour(rois(:,:,ind),'LineColor',colors(ind,:));
    end  
    legend(labels);
end
