clear;close;clc;
input_files = ["XB1S8298.CR2"]; %list of files to be analyzed, required
roi_files = ["test_roi.zip"]; %ROI file location
out_files = []; %pathname to output, leave none for default
nbins = 15; %Number of bins in granularity analysis
njack = 2; %how many splits in the jackknife, 

for file_number = 1:length(input_files)
    close all;
    in_file = input_files(file_number);
    if isempty(out_files)
        out_path = split(in_file,'.');
        out_path = out_path(1); %set outpath correctly based on input
    else 
        out_path = out_files(file_number);
    end
    createDirs(out_path); %make directories
    roi_file = roi_files(file_number); %grab ROI
    
    gray = openFile(in_file); %get image
    
    [rois,labels,angles] = getROIs(gray,roi_file,in_file); %get ROI masks and names
    
    saveContours(gray,rois,labels);
    saveas(3,fullfile(out_path,"full_image.png")); %save image
    
    dim = cat(2,size(rois),1); %set number of ROIs, add a 1 in case we only have 1
    
    [energy_store,error_bars,wave_numbers] = getEnergy(gray,rois,nbins,njack,out_path,dim,labels,angles); 
    %get data out: energy, error, wavenumber for band

    plotPowerSpectrum(energy_store,error_bars,labels,wave_numbers,dim(3)); %plot power spectrum
    
    [delta_store,delta_errors] = plotDeltas(energy_store,error_bars,labels,wave_numbers,dim(3)) %plot delta

    save((fullfile(out_path,"stat_data.mat")),'energy_store','error_bars','delta_store','delta_errors','labels');
    %save data to file
    saveas(2,fullfile(out_path,"granularity_bands.png")); %save image
end