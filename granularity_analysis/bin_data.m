function [Pkj,kaj,sPkj] = bin_data(data,k,nbins)
    shape = size(data);
    N2 = shape(1)^2;
    lk = log10(k);
    bindelt = (max(lk(:))-min(lk(:)))/nbins;
    edges = (((1:(nbins+1))-1)*bindelt)+min(lk(:));
    [nj,edges,bin] = histcounts(lk, edges); 
    figure(1);
    imshow(bin,[]);
    edges
    Pkj = compute_bins(abs(data).^2,nbins,bin);
    Pkj2 = compute_bins(abs(data).^4,nbins,bin);
    lkaj = compute_bins(lk,nbins,bin);
    nj = transpose(nj);
    Pkj = Pkj./nj / N2;
    Pkj2 = Pkj2 / N2 / N2;
    sPkj = sqrt(Pkj2./(nj.*(nj-1)) - Pkj.^2 ./(nj-1));
    lkaj = lkaj ./ nj;
    kaj = 10.^lkaj;
end

    