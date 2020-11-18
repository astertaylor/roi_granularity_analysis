function [fft,spectrum] = perform_fft(m_img)
    mean_img = mean(m_img(:));
    
    weber = (m_img-mean_img)/mean_img;
    
    %2D FFT and power spectrum
    fft = fft2(weber);
    fft_centered = fftshift(fft);
    spectrum = (real(fft_centered .* conj(fft_centered)));
end
