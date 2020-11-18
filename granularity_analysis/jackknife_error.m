function [error,k_bins,p] = jackknife_error(data,nbins,njack)
    isize = size(data);
    isize = isize(1);
    ndivs = 2^njack
    njack = 4^njack;
    delX = round(isize/ndivs);
    
    sample_set = [];
    
    size_value = (ndivs*delX<=isize);
    if ~size_value
        dif_value = isize-(ndivs*delX);
    end
    
    for x_ind = 1:ndivs
        for y_ind = 1:ndivs
            if size_value
                square = data(((x_ind-1)*delX+1):(x_ind*delX),((y_ind-1)*delX+1):(y_ind*delX));
            elseif ~size_value
                if (y_ind == ndivs) & (x_ind ~= ndivs)
                    square = padarray(data(((x_ind-1)*delX+1):(x_ind*delX),((y_ind-1)*delX+1):end),[0,dif_value],128,'post');
                elseif (x_ind == ndivs) & (y_ind ~= ndivs)
                    square = padarray(data(((x_ind-1)*delX+1):end,((y_ind-1)*delX+1):(y_ind*delX)),[dif_value,0],128,'post');
                elseif (x_ind == ndivs) & (y_ind == ndivs)
                    square = padarray(data(((x_ind-1)*delX+1):end,((y_ind-1)*delX+1):end),[dif_value,dif_value],128,'post');
                else 
                    square = data(((x_ind-1)*delX+1):(x_ind*delX),((y_ind-1)*delX+1):(y_ind*delX));
                end
            end 
            sample_set = cat(3,sample_set,square);
        end
    end
    
    power_spectra = [];
    isize = size(sample_set);
    isize = isize(1);
    k = get_wavenumbers(isize);
    for index = 1:njack
        [fft,~] = perform_fft(sample_set(:,:,index));
        [spectrum,k_bins,~] = bin_data(fft,k,nbins);
        power_spectra = cat(2,power_spectra,spectrum);
    end
    
    
    spectrum_prime = mean(power_spectra,2);
    error = zeros([nbins,1]);
    for index = 1:njack
        this_sample = power_spectra(:,(1:njack~=index));
        sample_error = (mean(this_sample,2) - spectrum_prime).^2;
        error = error+sample_error;
    end
    error = error*(njack-1)/njack;
    error = sqrt(error);

    p = polyfit(log10(k_bins),log10(error),1)
end