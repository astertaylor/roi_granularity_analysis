input_files = ["XB1S1570.CR2"]; %list of files to be analyzed, required
out_files = [0]; %pathname to output, leave none for default
control_style = 'mean'; %style of controlling: mean, standard
fill_val = 255; %number to fill control with
NumBands = 7; %Number of bands in granularity analysis
save = 0; %Whether or not to save filter images
band_method = 'gaussian-x'; %Method of creating masks
band_arguments = [500,169,340,0.5,650,-1]; %Constants used in band-making:amplitude, sigmax, sigmay (Gaussian) exponential for decrease, x-radius, y-radius


main(input_files, out_files, control_style, fill_val, NumBands,save,band_method,band_arguments);

function create_dirs(out_path,save)
    mkdir(out_path,'Images');
    mkdir(out_path,'Output');
    mkdir(out_path,'Control_Output');
    mkdir(out_path,'Control_Images');
    mkdir(out_path,'Adjusted_Output');
    if save == 1 
        mkdir(out_path,'Filters');
    end
end

function gray=open_file(image_path) 
    image = imread(image_path);
    gray = rgb2gray(image);   

end

function [roi_mat,labels] = get_rois(gray)
    labels = [];
    roi_mat = [];
     ind = 0;
    for i = 1:100
        imshow(gray);
        user_entry = input("Name of ROI (leave empty for last one): ",'s');
        if isempty(user_entry)
            if ind == 0
                roi_mat = ones(size(gray));
            end
            return;
        else
            ind = 1;
            labels = cat(2,labels,[user_entry]);
            cutout = roipoly(gray);
            cutout = uint8(cutout);
             
            roi_mat = cat(3,roi_mat,cutout);                
            
        end 
    end
end

function size = find_bounds(rois)
max_width = 0;
max_height = 0;
dim = size(rois);
for ind = 1:dim(3)
    roi = rois(:,:,ind);
    [width,height] = width_height_measures(roi);
    if width>max_width
        max_width = width;
    end
    if height>max_height
        max_height = height;
    end
end
size = max(max_height,max_width);
end

function [width,height] = width_height_measures(roi)    
    [y,x] = ind2sub(size(roi),find(roi==1));
    
    roi_ul_x = min(x);
    roi_ul_y = min(y);
    roi_lr_x = max(x);
    roi_lr_y = max(y);
    width = (roi_lr_x-roi_ul_x);
    height = (roi_lr_y-roi_ul_y);
end
    
function m_img = crop_image(style,in_img,roi,size)
    [width,height] = width_height_measures(roi);
    centerX = round(width/2);
    centerY = round(height/2);
    center = round(size/2);
    
    [y,x] = ind2sub(size(roi),find(roi==1));
    
    roi_ul_x = min(x);
    roi_ul_y = min(y);
    roi_lr_x = max(x);
    roi_lr_y = max(y);
    width = int(roi_lr_x-roi_ul_x);
    height = int(roi_lr_y-roi_ul_y);
    
    m_img = in_img .* roi;
    m_img = m_img(roi_ul_y:(roi_ul_y+height), roi_ul_x:(roi_ul_x+width));
    
    pad = zeros(size,size);
    for i = 1:height
        for j = 1:width
            deltX = (centerX-j);
            deltY = (centerY-i);
            offsetX = (center-deltX);
            offsetY = (center-deltY);
            pad(offsetY,offsetX)=m_img(i,j);
        end
    end
    m_img = pad;
    
    if strcmp(style,'reflect')
        m_img = reflect_control(m_img,size,height,width);
    end
end

function pad = reflect_control(m_img,size,height,width)
    center = round(size/2);
    centerX = round(width/2);
    centerY = round(height/2);

    for ind = 1:height
        i = int8(ind+(center-centerY));
        mat = m_img(i,:);
        try 
            relevant = find(mat~=0);
        catch
            continue;
        end
        max_val = max(relevant);
        min_val = min(relevant);
        if max_val == min_val
            continue;
        end

        breaks = [];
        dim = size(relevant);
        for j = 1:(dim(1))
            if (relevant(j+1)-relevant(j))>1
                breaks=cat(breaks,relevant(j));
                breaks=cat(breaks,relevant(j+1));
            end
        end
                
        for j = 1:(size(breaks)/2)
            avg = round((breaks(j)+breaks(j+1))/2);
            left = breaks(j);
            right = breaks(j+1);
            rem1 = padarray(mat(0:left),[0,int8(avg-left)],"symmetric");
            rem2 = padarray(mat(right:end),[int8(right-avg),0],"symmetric");
            mat = cat(2,rem1,rem2);
        end
    end
            
    remain_right = int8(center-(max_val-centerX));
    remain_left = int8(center-(centerX-min_val));
        
    pad = padarray(mat,[remain_left,remain_right],"symmetric");
    
    min_val = centerY;
    max_val = min_val;
    for i = 1:width
        mat = m_img(:,int9(i+(center-centerY)));
        if find(mat~=0, 1, 'last' )>max_val
            max_val = find(mat~=0, 1, 'last' );
        end
        if find(mat~=0, 1 )<min_val
            min_val = find(mat~=0, 1 );
        end
    end
    
    pad = pad(min_val:max_val,:);
    
    pad = padarray(pad,[min_val,int(size-max_val)],"symmetric");   
end

function [fft,spectrum] = perform_fft(m_img,roi)
    mean_img = nan_mean(m_img,roi);
    
    weber = (m_img-mean_img)/mean_img;
    
    %2D FFT and power spectrum
    fft = fft2(weber);
    fft_centered = fftshift(fft);
    spectrum = real(fft_centered * conj(fft_centered));
end

function control = control_creator(style,fill,gray,roi,size)
    [y,x] = ind2sub(size(roi),find(roi==1));
    
    roi_ul_x = min(x);
    roi_ul_y = min(y);
    roi_lr_x = max(x);
    roi_lr_y = max(y);
    width = int(roi_lr_x-roi_ul_x);
    height = int(roi_lr_y-roi_ul_y);
    
    centerX = round(width/2);
    centerY = round(height/2);
    
    center = round(size/2);
    pattern = false;
    if strcmp(style,"mean")
        fill_val = nan_mean(gray,roi);
        pattern = true;
    end
    if strcmp(style,"standard")
        fill_val = fill;
        pattern = true;
    end
    if pattern == true
        cont = int8(ones(size(gray))*fill_val);
        control = cont.*roi;
        control = control(roi_ul_y:(roi_ul_y+size), roi_ul_x:(roi_ul_x+size));
        pad = int8(zeros(size,size));
        for i = 1:height
            for j = 1:width
                deltX = int8(centerX-j);
                deltY = int8(centerY-i);
                offsetX = int8(center-deltX);
                offsetY = int8(center-deltY);
                pad(offsetY,offsetX)=control(i,j);
            end
        end
        control = pad;
    end
end

function save_image(image,out_path,folder,name,image_class)
    if strcmp('image',image_class)
        imwrite(image,strcat(out_path,"/",folder,"/",name,".png"));
    elseif strcmp('figure',image_class)
        imwrite(image,strcat(out_path,"/",folder,"/",name,"_output.png"));
    end
end

function nan_mean = nan_mean(m_img, roi)
    mask = m_img(roi==1);
    nan_mean = mean(mask);
end

function [fft_mod,spectrum_mod]=subtract_control(fft,fft_cont)            
    best_score = abs(mean(fft-fft_cont));
    best_const = 1;
    vals = linspace(-2,2,200);
    for i = 1:length(vals)
        const = vals(i);
        test = fft-(const*fft_cont);
        if mean(abs(test))<best_score
            best_score = mean(abs(test));
            best_const = const;
        end
    end
                    
    fft_mod = fft-(best_const*fft_cont);
    fft_centered_mod = fftshift(fft_mod);
    spectrum_mod = real(fft_centered_mod*conj(fft_centered_mod));
end

function output = gauss2d(xy,amp,x0,y0,sigx, sigy)
    x,y=xy;
    inner1 = (x-x0)^2/(2*sigx^2);
    inner2 = (y-y0)^2/(2*sigy^2);
    output = amp*exp(-(inner1+inner2));
end

function BandMasks = make_bands(constants, band_method, size, NumBands)
    BandMasks = zeros(size, size, NumBands);
    
    amp,sigX,sigY,expon,radX,radY = constants;
            
    center=np.round((size)/2); 
    
    Bands = flip(1:NumBands);

      
    if strcmp(band_method,'linear')
        RadiiX=((1:NumBands)+1)*((radX)/(NumBands));
        if radY == -1 
            RadiiY = RadiiX;
        else
            RadiiY=((1:NumBands)+1)*((radY)/(NumBands));
        end
    
    elseif strcmp(band_method,'exponential')
        RadiiX = 2*radX*power(expon,Bands);
        if radY == -1
            RadiiY = RadiiX;
        else
            RadiiY = 2*radY*power(expon,Bands);
        end
        
    elseif strcmp(band_method,'gaussian-x')
        RadiiX = (radX/expon)* power(expon,Bands);
        Heights = gauss2d([center+RadiiX,(center*ones(NumBands))],amp,center,center,sigX,sigY);

    elseif strcmp(band_method,'gaussian-z')
        Heights = amp*(1-power(expon,Bands));
        
    elseif strcmp(band_method,'gaussian-fit')
        BandMasks = 'fit';
    end

    X=linspace(center-size,center+size,size);
    Y=linspace(center-size,center+size,size).';
    for i = 1:NumBands
        if contains(band_method,'gaussian')
                if i == 0
                    BandScreen = gauss2d([X,Y],amp,center,center,sigX,sigY) > Heights(i);
                else
                    BandScreen1 = gauss2d([X,Y],amp,center,center,sigX,sigY)<Heights(i-1);
                    BandScreen2 = gauss2d([X,Y],amp,center,center,sigX,sigY)>Heights(i);
                    BandScreen = find(BandScreen1 & BandScreen2);
                    falsehoods = false(size,size);
                    for j = 1:length(BandScreen)
                        falsehoods(j) = true;
                    end
                end
        
        else
            if i==0
                BandScreen = (((X-center)/RadiiX(i))^2+((Y-center)/RadiiY(i))^2) <=1;
            else
                BandScreen1 = (((X-center)/RadiiX(i-1))^2+((Y-center)/RadiiY(i-1))^2) > 1; 
                BandScreen2 = ((X-center)/RadiiX(i))^2+((Y-center)/RadiiY(i))^2 <=1;
                BandScreen = find(BandScreen1 & BandScreen2);
                falsehoods = false(size,size);
                for j = 1:length(BandScreen)
                    falsehoods(j) = true;
                end
            end
        end
        
        BandMasks(:,:,i) = BandScreen;
        
    end
end
    

function band_energy = band_energies(spectrum,BandMasks,NumBands)
    band_energy=zeros(NumBands);
    for i = 1:7
        cut = BandMasks(:,:,i) * spectrum;
        band_energy(i) = sum(cut(:));
    end
    band_energy = band_energy/sum(band_energy(:));
    
    plot(band_energy);
    ylabel("Relative power");
    xlabel("Granularity Band Index");
end

function [filtered_images_small_u8,reverse] = reverse_calculate(masked_img,NumBands, BandMasks, fft_mod,size)
        filtered_images = zeros(size, (size * (NumBands + 1)));
        filtered_images(:, 0:size) = masked_img/255;
        for i = 1:7
            filtered_fft = ifftshift(BandMasks(:,:,i) * fft_mod);
            filtered_image = real(ifft2(filtered_fft));
            offset = (size * (i + 1));
            filtered_images(:, offset:(offset+size)) = filtered_image + 0.5;
        end
        filtered_images_small=filtered_images;
        
        filtered_images_small_u8 = (filtered_images_small * 200);
        filtered_images_small_u8(filtered_images_small_u8 > 255) = 255;
        filtered_images_small_u8(filtered_images_small_u8 < 0) = 0;
        filtered_images_small_u8 = uint8(filtered_images_small_u8);
        
        reverse = ifftshift(fft_mod);
        reverse = 20*real(ifft2(reverse));
        
        reverse = 255*reverse/max(reverse(:));
end

    
function main(input_files, out_files, control_style, fill_val, NumBands,save,band_method,band_arguments)
    constants = band_arguments;
    for file_number = 1:length(input_files)
        in_file = input_files(file_number);
        if isempty(out_files)
            out_path = split(in_file,'.');
            out_path = out_file(1);
        else 
            out_path = out_files(file_number);
        end
        create_dirs(out_path, save);

        gray = open_file(in_file);
        
        [rois,labels] = get_rois(gray);
        
        size = find_bounds(rois);
        
        BandMasks = make_bands(constants, band_method, size, NumBands);

        dim = size(rois);
        
        for ind = 1:dim(3)
            roi = rois(:,:,ind);
            m_img = crop_image(gray,roi,size);
            
            if dim(1)==0
                continue
            elseif dim(2) == 0
                continue
            end
            save_image(m_img,out_path,"Images",ind,'image');
            
            fft_orig,spectrum = perform_fft(m_img, roi);
            save_image(spectrum,out_path,"Output",ind,'figure');
            

            control = control_creator(control_style, fill_val, gray, mask, roi, size);
            save_image(control,out_path,"Control_Images", ind+"_control",'image');

            fft_cont,spectrum_cont = perform_fft(control,roi);
            save_image(spectrum_cont,out_path,"Control_Output",ind+"_control",'figure');

            fft_mod,spectrum_mod = subtract_control(fft_orig,fft_cont);
            save_image(spectrum_mod,out_path,"Adjusted_Output",ind+"_adjusted",'figure');


            if save
                filtered, reverse = reverse_calculate(m_img, NumBands, BandMasks, fft_mod, size);
                save_image(filtered, out_path, "Filters", ind+"_filtered_images",'image');
                save_image(reverse, out_path, "Filters", ind+"_reverse_image",'image');
            end


            
            band_energies(spectrum_mod, BandMasks, NumBands);
        end
        
        legend(labels)
        savefig(out_path+"/granularity_bands.png")
        clf()
    end
end