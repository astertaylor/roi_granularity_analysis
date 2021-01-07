function output=computeBins(input,nbins,bin_indices)
    output = zeros([nbins,1]);
    for ind = 1:nbins %loop over all bins
        binfo = (bin_indices == ind);
        output(ind,1) = sum(input(binfo)); %sum of all values in each bin
    end
end
        