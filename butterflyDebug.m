% Butterfly tests.

clear;close;clc

rootFolder = '/Users/deryaakkaynak/Documents/Research/Github/Derya_Aster/Suspect_data/';

Ioriginal = double(imread(fullfile(rootFolder,'Butterfly_origin.tiff')));
Ioriginal = Ioriginal./max(Ioriginal(:));

Id65 = double(imread(fullfile(rootFolder,'Butterfly_test_D65.tif')));
Id65 = Id65./max(Id65(:));

Ideep = double(imread(fullfile(rootFolder,'Butterfly_test_DJ4.tif'))); 
Ideep = Ideep./max(Ideep(:));

Ideep2 = double(imread(fullfile(rootFolder,'Butterfly_test_J4.tif'))); 
Ideep2 = Ideep2./max(Ideep2(:));

%% make mask
imshow(Ideep);
pix = impoly(gca);
wait(pix);
mask = createMask(pix);
close
%%
imshow(Ioriginal);
pix = impoly(gca);
wait(pix);
maskOriginal = createMask(pix);
close
%%
Id65_w = getPatchMean(Id65,mask);
Ideep_w = getPatchMean(Ideep,mask);
Ideep2_w = getPatchMean(Ideep2,mask);
Ioriginal_w = getPatchMean(Ioriginal,maskOriginal);

Itemp = whiteBalance2(Ioriginal,Ioriginal_w);
Itemp = insertText(Itemp,[100 100],'Original','fontsize',200);
imgs{1} = Itemp;

Itemp = whiteBalance2(Id65,Id65_w);
Itemp = insertText(Itemp,[100 100],'D65 --> D65','fontsize',200);
imgs{2} = Itemp; 

Itemp = whiteBalance2(Ideep,Ideep_w);
Itemp = insertText(Itemp,[100 100],'D65 --> Jerlov III','fontsize',200);
imgs{3} = Itemp;

Itemp = whiteBalance2(Ideep2,Ideep2_w);
Itemp = insertText(Itemp,[100 100],'Jerlov III --> Jerlov III','fontsize',200);
imgs{4} = Itemp;

montage(imgs)
%% Octopus image

clear;close;clc

rootFolder = '/Users/deryaakkaynak/Documents/Research/Github/Derya_Aster/Suspect_data/';

Ioriginal = double(imread(fullfile(rootFolder,'XB1S2681_origin.tiff')));
Ioriginal = Ioriginal./max(Ioriginal(:));

Id65 = double(imread(fullfile(rootFolder,'XB1S2681_test_D65.tif')));
Id65 = Id65./max(Id65(:));

Ideep = double(imread(fullfile(rootFolder,'XB1S2681_test_DJ6.tiff'))); 
Ideep = Ideep./max(Ideep(:));

Ideep2 = double(imread(fullfile(rootFolder,'XB1S2681_test_J6.tiff'))); 
Ideep2 = Ideep2./max(Ideep2(:));

Ideep3 = double(imread(fullfile(rootFolder,'XB1S2681_test_J6D.tif'))); 
Ideep3 = Ideep3./max(Ideep3(:));

%% make mask
imshow(Ideep);
pix = impoly(gca);
wait(pix);
mask = createMask(pix);
close
%%
imshow(Ioriginal);
pix = impoly(gca);
wait(pix);
maskOriginal = createMask(pix);
close
%%
Id65_w = getPatchMean(Id65,mask);
Ideep_w = getPatchMean(Ideep,mask);
Ideep2_w = getPatchMean(Ideep2,mask);
Ideep3_w = getPatchMean(Ideep3,mask);
Ioriginal_w = getPatchMean(Ioriginal,maskOriginal);

Itemp = whiteBalance2(Ioriginal,Ioriginal_w);
Itemp = insertText(Itemp,[100 100],'Original','fontsize',200);
imgs{1} = Itemp;

Itemp = whiteBalance2(Id65,Id65_w);
Itemp = insertText(Itemp,[100 100],'D65 --> D65','fontsize',200);
imgs{2} = Itemp; 

Itemp = whiteBalance2(Ideep,Ideep_w);
Itemp = insertText(Itemp,[100 100],'D65 --> Jerlov 3C','fontsize',200);
imgs{3} = Itemp;

Itemp = whiteBalance2(Ideep2,Ideep2_w);
Itemp = insertText(Itemp,[100 100],'Jerlov 3C --> Jerlov 3C','fontsize',200);
imgs{4} = Itemp;

Itemp = whiteBalance2(Ideep3,Ideep3_w);
Itemp = insertText(Itemp,[100 100],'Jerlov 3C --> D65','fontsize',200);
imgs{5} = Itemp;

montage(imgs,'size',[1 5])
