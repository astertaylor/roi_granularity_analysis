function quanta = getPatchQuanta(I,rois,camera,wns)
dim = length(rois);
quanta = cell(dim,1);
wns = wns';
camera = [wns,camera];
for index = 1:dim
    patch = rois{index};
    RGB = getPatchMean(I,patch);
    signal = wns./wns-1;
    for i = 1:3
        signal = signal + RGB(i)./camera(:,i+1);
    end
    signal = [wns,signal];
    quanta{index} = getConeCatchQ(camera,signal);
end
    
