function Q = getConeCatchQ(observer,signal)

% Observer: curves of the observer. N x M matrix, where column 1 is wavelength, colum 2-M is
% the observer's curves from Short WS to Long WS. N is the number of
% spectral bands.

% Signal is the spectra to which we are measuring the cone catch for, size
% N x 2. N is the number of spectral bands. Column 1 is wavelength, column
% 2 is the actual signal.


n = size(observer,2);

Q = zeros(1,n-1);
WL_obs = observer(:,1);

WL_signal = signal(:,1);

for i = 2:n
    k = 1/sum(observer(:,i));
    Q(i-1) = k.*sum(interp1(WL_signal,signal(:,2),WL_obs).*observer(:,i));
end

