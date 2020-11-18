function [filtered_images_small_u8,reverse] = reverse_calculate(masked_img,NumBands, BandMasks, fft_mod,isize)
        filtered_images = zeros(isize, (isize * (NumBands + 1)));
        filtered_images(:, 0:isize) = masked_img/255;
        for i = 1:7
            filtered_fft = ifftshift(BandMasks(:,:,i) * fft_mod);
            filtered_image = real(ifft2(filtered_fft));
            offset = (isize * (i + 1));
            filtered_images(:, offset:(offset+isize)) = filtered_image + 0.5;
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
