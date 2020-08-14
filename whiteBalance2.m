function I = whiteBalance2(I,wb)

for j = 1:3
    I(:,:,j) = I(:,:,j)./wb(j);
end

