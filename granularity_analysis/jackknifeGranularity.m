clear;close;clc;
close all;

input_files = ["test_files\XB1S2995.CR2"]; %list of files to be analyzed, required
roi_files = ["test_files\XB1S2995_GRAN1.zip"];
out_files = []; %pathname to output, leave none for default
nbins = 15; %Number of bins in granularity analysis
njack = 2;

readraw;

for file_number = 1:length(input_files)
    in_file = input_files(file_number);
    if isempty(out_files)
        out_path = split(in_file,'.');
        out_path = out_path(1);
    else 
        out_path = out_files(file_number);
    end
    createDirs(out_path);
    roi_file = roi_files(file_number);
    
    gray = openFile(in_file);
    
    [rois,labels] = getROIs(gray,roi_file,in_file);
    
    [~,x] = ind2sub(size(rois(:,:,1)),find(rois(:,:,1)==1));
    
    roi_ul_x = min(x);
    roi_lr_x = max(x);
    isize = round(roi_lr_x-roi_ul_x);
    k = getWavenumbers(isize);
    
    dim = cat(2,size(rois),1);
    
    [energy_store,error_bars,wave_numbers] = getEnergy(gray,rois,nbins,njack,out_path,dim,labels,k);

    plotPowerSpectrum(energy_store,error_bars,labels,wave_numbers,dim(3));
    
    [delta_store,delta_errors] = plotDeltas(energy_store,error_bars,labels,wave_numbers,dim(3))

    save((strcat(out_path,".mat")),'energy_store','error_bars','delta_store','delta_errors','labels');
    saveas(2,fullfile(out_path,"granularity_bands.png"));

end