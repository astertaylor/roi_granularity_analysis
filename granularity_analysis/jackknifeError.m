function [error,k_bins,p] = jackknifeError(data,nbins,njack)
    isize = size(data) 
    ndivs = 2^njack; %set number of divisions
    njack = 4^njack; %set number of sub-images
    delX = round(isize(2)/ndivs); %expected size of each sub-image
    delY = round(isize(1)/ndivs); 
    
    sample_set = [];
    round_down = (ndivs*delX<=isize(2)) %calculate which way to pad sub-image
    if ~round_down
        dif_value = (ndivs*delX)-isize(2)
        data = padarray(data,[0,dif_value],128,'post');
        isize = size(data);
        delX = isize(2)/ndivs; %resetting size of sub-image based on rounding.
    end
    
    round_down = (ndivs*delY<=isize(1)) %calculate which way to pad sub-image
    if ~round_down
        dif_value = (ndivs*delY)-isize(1)
        data = padarray(data,[dif_value,0],128,'post');
        isize = size(data);
        delY = isize(1)/ndivs; %resetting size of sub-image based on rounding.
    end
    
    for x_ind = 1:ndivs
        for y_ind = 1:ndivs
            square = data(((y_ind-1)*delY+1):(y_ind*delY),((x_ind-1)*delX+1):(x_ind*delX));
            sample_set = cat(3,sample_set,square); %create set of squares
        end
    end
    
    power_spectra = [];
    isize = size(sample_set);
    k = getWavenumbers(isize(1),isize(2));
    for index = 1:njack
        [fft,~] = performFFT(sample_set(:,:,index));
        [spectrum,k_bins,~] = binData(fft,k,nbins);
        power_spectra = cat(2,power_spectra,spectrum); %create matrix of power spectra
    end
    
    spectrum_prime = mean(power_spectra,2); %mean of all
    error = zeros([nbins,1]);
    for index = 1:njack %jackknife calculations
        this_sample = power_spectra(:,(1:njack~=index)); 
        sample_error = (mean(this_sample,2) - spectrum_prime).^2;
        error = error+sample_error;
    end
    error = error*(njack-1)/njack;
    error = sqrt(error);

    p = polyfit(log10(k_bins),log10(error),1) %fits an exponential to the errors
end