function k = getWavenumbers(isize)
    k1d = fftfreq(isize) * 2.0 * pi;
    [kx, ky] = meshgrid(k1d, k1d);
    k = isize*sqrt(kx.^2 + ky.^2);
    k(1,1) = 2.0 * pi;
end