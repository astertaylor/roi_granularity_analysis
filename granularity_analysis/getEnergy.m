function [energy_store,error_bars,wave_numbers]=getEnergy(gray,rois,nbins,njack,outpath,dim,labels,k)
    energy_store = [];
    error_bars = [];
    for ind = 1:dim(3)
        roi = rois(:,:,ind);
        [energy_store,error_bars,wave_numbers]=getROIEnergy(gray,roi,nbins,njack,outpath,ind,labels,k,energy_store,error_bars);
    end
end