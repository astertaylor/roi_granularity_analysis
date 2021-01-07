function k = getWavenumbers(height,width)
    k1y = height*fftfreq(height) * 2.0 *pi;
    k1x = width*fftfreq(width) * 2.0 * pi; %set wavenumbers for axis 1
    [kx, ky] = meshgrid(k1x, k1y);
    k = sqrt(kx.^2 + ky.^2); %combine axes
    k(1,1) = 2.0 * pi;
end