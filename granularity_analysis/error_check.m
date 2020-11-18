function error_vars = error_check(check_sizes, roi_size, NumBands,wh_mean,wh_std)
    band_data = zeros(NumBands,length(check_sizes));
    for ind = 1:length(check_sizes)
        square = check_sizes(ind);
        checkerboard = control_creator(square,[3000,3000],255,wh_mean,wh_std);
        energy_store = [];
        for roi_ind = 1:2
            if roi_ind == 1
                processed_check = checkerboard(1:roi_size, 1:roi_size);
            elseif roi_ind == 2
                parity = mod(ceil(roi_size/square),2);
                smallest_integer = ceil(roi_size/(2*square));
                first_value = smallest_integer*square-roi_size/2;
                if first_value ==0
                    first_value = first_value+square;
                end
               
                if ~parity
                    first_value = first_value + square/2;
                end
                    
                last_value = first_value+roi_size;
                processed_check = checkerboard(first_value:last_value,first_value:last_value);
            end
            
            isize = size(processed_check);
            isize = isize(1);
            
            BandMasks = make_bands(0.5, isize, NumBands);
            
            [~,spectrum] = perform_fft(processed_check);
                                   
            energy_store = band_energies(spectrum, BandMasks, NumBands,energy_store);
        end
%         energy_store = energy_store./(10^(floor(log10(max(energy_store(:))))-3));
%         energy_store = round(energy_store);
        %rounding to the 1000th, i.e., taking the maximum to be 10^3 and
        %then rounding to the nearest integer.
        for i = 1:NumBands
            %error is the absolute value of the percent error. 
            energy = (energy_store(i,:))
%             "Energy Mean"
%           %energy_mean = mean(energy)
            err_abs = abs(diff(energy));
%             "Energy Percent Error"
%             perc_err = err_abs/energy_mean;
            %here, we set NaNs and Infs to 0 in the data, NaNs are 0/0, and Infs
            %are float/0. both have no real comparison, and so must be dismissed.
            %The Infs are turned into NaN, which are then dismissed in the error
            %average.
%             perc_err(isnan(perc_err))=0;
%             perc_err(isinf(perc_err))=NaN;
            perc_err = err_abs
            band_data(i,((((ind-1)*2)+1):(ind*2))) = perc_err;
        end
    end
    "Band Data"
    band_data
    error_vars = zeros(NumBands,1);
    for i = 1:NumBands
        mean_band = band_data(i,:);
        error_vars(i) = mean(mean_band(~isnan(mean_band)));
    end
    "Errors"
    error_vars
end