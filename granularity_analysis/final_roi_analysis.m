clear;close;clc

input_files = ["XB1S1570.CR2"]; %list of files to be analyzed, required
%"checkerboard_1.png","checkerboard_2.png","checkerboard_3.png","checkerboard_4.png","checkerboard_5.png","checkerboard_6.png","checkerboard_7.png","checkerboard_8.png"
roi_files = ["XB1S1570_GRAN.zip"];
out_files = []; %pathname to output, leave none for default
NumBands = 7; %Number of bands in granularity analysis
save_images = 0; %Whether or not to save filter images
constants = 0.5; %Constants used in band-making: exponential for decrease
check_sizes = [4,8,16,32,64,128,256,512];

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
    dim = size(rois);
    wh_mean = zeros([dim(3),1]);
    wh_std = zeros([dim(3),1]);
    for ind = 1:dim(3)
        roi = rois(:,:,ind);
        m_img = crop_image(gray,roi);
        wh_mean(ind) = mean(m_img(:));
        wh_std(ind) = std(m_img(:));
    end
    wh_mean = mean(wh_mean)
    wh_std = mean(wh_std)
    error_bars = error_check(check_sizes,isize,NumBands,wh_mean,wh_std);

    energy_store = [];

    for ind = 1:dim(3)
        roi = rois(:,:,ind);
        m_img = crop_image(gray,roi);

        isize = size(m_img);
        isize = isize(1);

        BandMasks = make_bands(constants, isize, NumBands);

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

        fft_mod = fft_orig;
        spectrum_mod = spectrum;

        if save_images
            filtered, reverse = reverse_calculate(m_img, NumBands, BandMasks, fft_mod, isize);
            save_image(filtered, out_path, "Filters", ind+"_filtered_images",'image');
            save_image(reverse, out_path, "Filters", ind+"_reverse_image",'image');
        end



        energy_store = band_energies(spectrum_mod, BandMasks, NumBands,energy_store);
    end
    figure(3);
    imshow(BandMasks(:,:,7));

    figure();
    hold on
    colors = hsv(dim(3));
    colors(2,:)
    "Error Bars"
    error_bars
    (strcat(out_path,".mat"))
    save((strcat(out_path,".mat")),'energy_store','error_bars');

    for i = 1:dim(3)
        energy = energy_store(:,i);
        plot(energy,'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
%         if i==1
%             errorbar(energy,(error_bars.*energy),'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
%         else
%             errorbar(energy,(error_bars.*energy),'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
%         end
%         if i==1 
%             errorbar(energy,(error_bars),'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
%         else
%             errorbar(energy,(error_bars),'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
%         end
        
    end
    size(energy_store)
    ylabel("Relative power");
    xlabel("Granularity Band Index");
    hold off
    legend(labels);

    saveas(1,strcat(out_path,"/granularity_bands.png"));    
end