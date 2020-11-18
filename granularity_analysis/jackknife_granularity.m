clear;close;clc;
close all;

input_files = ["XB1S1570.CR2"]; %list of files to be analyzed, required
%"checkerboard_1.png","checkerboard_2.png","checkerboard_3.png","checkerboard_4.png","checkerboard_5.png","checkerboard_6.png","checkerboard_7.png","checkerboard_8.png"
roi_files = ["XB1S1570_GRAN.zip"];
out_files = []; %pathname to output, leave none for default
nbins = 15; %Number of bins in granularity analysis
njack = 2;

readraw;

for file_number = 1:length(input_files)
    clf();
    in_file = input_files(file_number);
    if isempty(out_files)
        out_path = split(in_file,'.');
        out_path = out_path(1);
    else 
        out_path = out_files(file_number);
    end
    create_dirs(out_path);
    roi_file = roi_files(file_number);

    gray = open_file(in_file);

    [rois,labels] = get_rois(gray,roi_file,in_file);
    
    [~,x] = ind2sub(size(rois(:,:,1)),find(rois(:,:,1)==1));
    
    roi_ul_x = min(x);
    roi_lr_x = max(x);
    isize = round(roi_lr_x-roi_ul_x);
    k = get_wavenumbers(isize);
   

    dim = size(rois);

    energy_store = [];
    error_bars = [];
    

    for ind = 1:dim(3)
        roi = rois(:,:,ind);
        m_img = crop_image(gray,roi);

        isize = size(m_img);
        isize = isize(1);


        if dim(1)==0
            continue
        elseif dim(2) == 0
            continue
        end

        save_image(m_img,out_path,"Images",labels(ind),'image');

        [fft_orig,spectrum] = perform_fft(m_img);
        save_image(abs(log(spectrum)),out_path,"Output",labels(ind),'figure');
        isize = size(spectrum);
        isize = isize(1);

        [band_energy,wave_numbers,P_error] = bin_data(fft_orig,k,nbins);
        
        [~,~,p] = jackknife_error(m_img,nbins,njack);
        J_error = polyval(p,log10(wave_numbers));
        J_error = 10.^J_error
        
        energy_store = cat(2,energy_store,band_energy);
        P_error
        error_bars = cat(2,error_bars,max(P_error,J_error))
    end

    figure();
    hold on;
    colors = hsv(dim(3));
    colors(2,:)
    "Error Bars"
    error_bars
    x_vals = wave_numbers;

    for i = 1:dim(3)
        energy = energy_store(:,i);
        if i==1 
            errorbar(x_vals,energy,(error_bars(:,i)),'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
        else
            errorbar(x_vals,energy,(error_bars(:,i)),'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
        end
        
    end
    size(energy_store)
    ylabel("Binned Power Spectrum");
    xlabel("Wavenumber");
    set(gca,'xscale','log');
    set(gca,'yscale','log');
    hold off
    legend(labels);
    
    figure();
    hold on
    colors = hsv(dim(3));
    colors(2,:);
    delta_x = x_vals.^2;
    delta_store = [];
    delta_errors = [];
    for i = 1:dim(3)
        energy = energy_store(:,i);
        delta_y = sqrt(energy.*delta_x/(2*pi));
        delta_store = cat(2,delta_store,delta_y);
        error = error_bars(:,i);
        delta_error = sqrt((delta_x.*(error.^2)./energy)/(8*pi));
        delta_errors = cat(2,delta_errors,delta_error);
        errorbar(x_vals,delta_y,delta_error,'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
    end
    ylabel("Binned Delta");
    xlabel("Wavenumber");
    set(gca,'xscale','log');
    set(gca,'yscale','log');
    hold off
    legend(labels);

    
    save((strcat(out_path,".mat")),'energy_store','error_bars','delta_store','delta_errors');
    saveas(1,strcat(out_path,"/granularity_bands.png"));    
end