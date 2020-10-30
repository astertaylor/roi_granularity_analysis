function BandMasks = make_bands(expon, isize, NumBands)
    BandMasks = zeros(isize, isize, NumBands);
    "Mask Size"
    size(BandMasks)
   
    center=round((isize)/2); 
    
    Bands = flip(1:NumBands);
    
    radX = round(isize/2);
    RadiiX = 2*radX*power(expon,Bands);
    RadiiY = RadiiX;

    [X,Y] = meshgrid(1:(isize),1:(isize));
    for i = 1:NumBands
        if i==1
            BandScreen = (((X-center)/RadiiX(i)).^2+((Y-center)/RadiiY(i)).^2) <=1;
        else
            BandScreen1 = (((X-center)/RadiiX(i-1)).^2+((Y-center)/RadiiY(i-1)).^2) > 1; 
            BandScreen2 = ((X-center)/RadiiX(i)).^2+((Y-center)/RadiiY(i)).^2 <=1;
            BandScreen = BandScreen1.*BandScreen2;
            falsehoods = false(isize,isize);
            for j = 1:length(BandScreen)
                falsehoods(j) = true;
            end
        end

        BandMasks(:,:,i) = BandScreen;
    end
end
