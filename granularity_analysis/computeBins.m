function output=computeBins(input,nbins,bin_indices)
    output = zeros([nbins,1]);
    for ind = 1:nbins
        binfo = (bin_indices == ind);
        output(ind,1) = sum(input(binfo));
    end
end
        