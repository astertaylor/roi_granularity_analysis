function [fft,spectrum] = performFFT(m_img)
    mean_img = mean(m_img(:));
    
    weber = (m_img-mean_img)/mean_img; %compute the Weber contrast
    
    %2D FFT and power spectrum
    fft = fftn(weber); %Fourier transform Weber contrast
    fft_centered = fftshift(fft);
    spectrum = (real(fft_centered .* conj(fft_centered)));
end
