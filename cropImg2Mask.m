function outImg = cropImg2Mask(inImg,mask)

s = size(inImg);
outImg = zeros(s);

if numel(s) == 3
    for i = 1:3
        thisLayer = inImg(:,:,i);
        thisLayer(mask) = 0;
        outImg(:,:,i) = thisLayer;
    end
    
else
    
    thisLayer = inImg(:,:,1);
    thisLayer(mask) = 0;
    outImg(:,:,1) = thisLayer;
    
end