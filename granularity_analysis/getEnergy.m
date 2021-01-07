function [energy_store,error_bars,wave_numbers]=getEnergy(gray,rois,nbins,njack,outpath,dim,labels,angles)
    energy_store = [];
    error_bars = [];
    for ind = 1:dim(3) %loops over ROIs 
        roi = rois(:,:,ind);
        angle = angles(ind);
        [energy_store,error_bars,wave_numbers]=getROIEnergy(gray,roi,nbins,njack,outpath,ind,labels,energy_store,error_bars,angle);
    end
end