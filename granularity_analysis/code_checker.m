square = 8;
checkerboard = control_creator(square,[3336,5010]);

rois = ReadImageJROI("XB1S1570_GRAN.zip");
  
labels = [];
roi_mat = [];

for i = 1:length(rois)
    roi = rois{i};

    if strcmp(roi.strType,'Rectangle')
        slice = zeros(3336,5010);
        points = roi.vnRectBounds;
        slice(points(1):points(3),points(2):points(4)) = ones(points(3)-(points(1)-1),points(4)-(points(2)-1));
    else
        slice = poly2mask(roi.mnCoordinates(:,1),roi.mnCoordinates(:,2), sizex,sizey);
    end

    roi_mat = cat(3,roi_mat,slice);

    labels = cat(2,labels,[string(roi.strName)]);
end

roi_list = getSmallestInnerRectangle(roi_mat);

energy_store = [];
for roi_ind = 1:4
    roi = roi_list(:,:,roi_ind);
    processed_check = crop_image(checkerboard,roi);

    isize = size(processed_check);
    isize = isize(1);

    BandMasks = make_bands(0.5, isize, NumBands);

    [~,spectrum] = perform_fft(processed_check);

    energy_store = band_energies(spectrum, BandMasks, NumBands,energy_store);
end
band_data = [];
energy_store = energy_store./(10^(floor(log10(max(energy_store(:))))-3));
energy_store = round(energy_store);
%rounding to the 1000th, i.e., taking the maximum to be 10^3 and
%then rounding to the nearest integer.
for i = 1:NumBands
    %error is the absolute value of the percent error. 
    energy = (energy_store(i,:))
    "Energy Mean"
    energy_mean = mean(energy)
    err_abs = abs(energy-energy_mean);
    "Energy Percent Error"
    perc_err = err_abs./energy;
    %here, we set NaNs and Infs to 0 in the data, NaNs are 0/0, and Infs
    %are float/0. both have no real comparison, and so must be dismissed.
    %The Infs are turned into NaN, which are then dismissed in the error
    %average.
    perc_err(isnan(perc_err))=0;
    perc_err(isinf(perc_err))=NaN;
    cat(1,band_data,perc_err)
end
band_data