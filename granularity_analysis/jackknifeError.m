function [error,k_bins,p] = jackknifeError(data,nbins,njack)
    isize = size(data)
    isize = isize(1);
    ndivs = 2^njack;
    njack = 4^njack;
    delX = round(isize/ndivs)
    
    sample_set = [];
    ndivs*delX
    round_down = (ndivs*delX<=isize)
    if ~round_down
        dif_value = (ndivs*delX)-isize
        data = padarray(data,[dif_value,dif_value],128,'post');
        isize = size(data);
        isize = isize(1)
        delX = isize/ndivs;
    end
    
    for x_ind = 1:ndivs
        for y_ind = 1:ndivs
%             if round_down
            square = data(((x_ind-1)*delX+1):(x_ind*delX),((y_ind-1)*delX+1):(y_ind*delX));
%             elseif ~round_down
%                 if (y_ind == ndivs) & (x_ind ~= ndivs)
%                     square = padarray(data(((x_ind-1)*delX+1):(x_ind*delX),((y_ind-1)*delX+1):end),[0,dif_value],128,'post');
%                 elseif (x_ind == ndivs) & (y_ind ~= ndivs)
%                     square = padarray(data(((x_ind-1)*delX+1):end,((y_ind-1)*delX+1):(y_ind*delX)),[dif_value,0],128,'post');
%                 elseif (x_ind == ndivs) & (y_ind == ndivs)
%                     square = padarray(data(((x_ind-1)*delX+1):end,((y_ind-1)*delX+1):end),[dif_value,dif_value],128,'post');
%                 else 
%                     square = data(((x_ind-1)*delX+1):(x_ind*delX),((y_ind-1)*delX+1):(y_ind*delX));
%                 end
%             end 
            sample_set = cat(3,sample_set,square);
        end
    end
    
    power_spectra = [];
    isize = size(sample_set);
    isize = isize(1);
    k = getWavenumbers(isize);
    for index = 1:njack
        [fft,~] = performFFT(sample_set(:,:,index));
        [spectrum,k_bins,~] = binData(fft,k,nbins);
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