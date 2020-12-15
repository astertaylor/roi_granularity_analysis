function [energy_store,error_bars,wave_numbers] = getROIEnergy(gray,roi,nbins,njack,out_path,ind,labels,k,energy_store,error_bars) 

    m_img = cropImage(gray,roi);  

    isize = size(m_img);
    isize = isize(1);

    saveImage(m_img,out_path,"Images",labels(ind),'image');

    [fft_orig,spectrum] = performFFT(m_img);
    fft_orig(1,1) = 0;

    saveImage(abs(log(spectrum)),out_path,"Output",labels(ind),'figure');
    isize = size(spectrum);
    isize = isize(1);

    [band_energy,wave_numbers,P_error,~] = binData(fft_orig,k,nbins);

    [~,~,p] = jackknifeError(m_img,nbins,njack);
    J_error = polyval(p,log10(wave_numbers));
    J_error = 10.^J_error

    energy_store = cat(2,energy_store,band_energy);
    P_error
    error_bars = cat(2,error_bars,max(P_error,J_error));
    
end