function energy_store = bandEnergies(spectrum,band_masks,num_bands,energy_store)
    band_energy=zeros(NumBands);
    band_energy=band_energy(:,1);
    "Band Energy Size"
    size(band_energy)
    for i = 1:7
        cut = band_masks(:,:,i) .* spectrum;
        band_energy(i) = sum(cut(:));
    end
%     band_energy = band_energy/sum(band_energy(:));
    
    energy_store = cat(2,energy_store,band_energy)
end
