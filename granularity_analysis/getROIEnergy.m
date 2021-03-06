function [energy_store,error_bars,wave_numbers] = getROIEnergy(gray,roi,nbins,njack,out_path,ind,labels,energy_store,error_bars,angle) 

    m_img = cropImage(gray,roi,angle);  %crop image
    
    [y,x] = ind2sub(size(m_img),find(m_img==1)); %grab boundary points
    
    isize = size(m_img);
    width = isize(2);
    height = isize(1); %find boundaries of ROI

    k = getWavenumbers(height,width); %grab wavenumbers

    isize = size(m_img);

    saveImage(m_img,out_path,"Images",labels(ind),'image'); %save image

    [fft_orig,spectrum] = performFFT(m_img); %get FFT
    fft_orig(1,1) = 0;

    saveImage(abs(log(spectrum)),out_path,"Output",labels(ind),'figure');
    isize = size(spectrum);

    [band_energy,wave_numbers,P_error,~] = binData(fft_orig,k,nbins); %bin the data, get Poisson error

    [~,~,p] = jackknifeError(m_img,nbins,njack);
    J_error = polyval(p,log10(wave_numbers));
    J_error = 10.^J_error %get jackknife error

    energy_store = cat(2,energy_store,band_energy);
    P_error
    error_bars = cat(2,error_bars,max(P_error,J_error)); %get maximum of P and J error
    
end