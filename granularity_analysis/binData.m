function [Pkj,kaj,sPkj,bin] = binData(data,k,nbins)
    shape = size(data);
    N2 = shape(1)^2; %number of pixels
    lk = log10(k); %bin over log10(k)
    bindelt = (max(lk(:))-min(lk(:)))/nbins; %difference in bin edges
    edges = (((1:(nbins+1))-1)*bindelt)+min(lk(:)); %find bin edges
    [nj,edges,bin] = histcounts(lk, edges); %compute where bins would fall in bin
    Pkj = computeBins(abs(data).^2,nbins,bin); %sum power spectrum over bins
    Pkj2 = computeBins(abs(data).^4,nbins,bin); %sum square of power spectrum over bins
    lkaj = computeBins(lk,nbins,bin); %sum value of bins over bins
    nj = transpose(nj);
    Pkj = Pkj./nj / N2; %average over bins
    Pkj2 = Pkj2 / N2 / N2; %same again
    sPkj = sqrt(Pkj2./(nj.*(nj-1)) - Pkj.^2 ./(nj-1)); %compute the Poisson-error
    lkaj = lkaj ./ nj; %average value of wavenumber in each bin
    kaj = 10.^lkaj; %undoing log10
end

    