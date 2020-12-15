function [energy_store,error_bars] = getEnergy(gray,roi,isize,,nbins,njack,outpath,dim) 
    m_img = crop_image(gray,roi);  

    isize = size(m_img);
    isize = isize(1);

    save_image(m_img,out_path,"Images",labels(ind),'image');

    [fft_orig,spectrum] = perform_fft(m_img);
    fft_orig(1,1) = 0;

    save_image(abs(log(spectrum)),out_path,"Output",labels(ind),'figure');
    isize = size(spectrum);
    isize = isize(1);

    [band_energy,wave_numbers,P_error,~] = bin_data(fft_orig,k,nbins);

    [~,~,p] = jackknife_error(m_img,nbins,njack);
    J_error = polyval(p,log10(wave_numbers));
    J_error = 10.^J_error

    energy_store = cat(2,energy_store,band_energy);
    P_error
    error_bars = cat(2,error_bars,max(P_error,J_error));
    
end