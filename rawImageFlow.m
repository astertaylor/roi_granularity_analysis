% Flow for Aster to read raw images into Matlab and check attenuation
% curves
% Derya Akkaynak | August 5, 2020

% Step 1) first please download Adobe DNG converter for your operating
% system from here:
% https://helpx.adobe.com/photoshop/using/adobe-dng-converter.html
%
% Step 2) Convert your raw images to dng using the converter. Make sure in
% "Change Preferences", you choose Compatibility --> Custom, and CHECK both
% linear and uncompressed.
%

%% Step 3) Read in the DNG image into matlab:
% Update the path according to your files
I = readDNGfile('/Users/deryaakkaynak/Documents/Research/Github/Derya_Aster/Rawtest/dng/XB1S2681.dng');
I = I./2^16;

%% Step 4) Crop the white patch and extract its rgb values

imshow(I);
pix = imrect(gca);wait(pix);mask = createMask(pix);
close

rgb = getPatchMean(I,mask);
% Normalize
Irgb = rgb./sum(Irgb);
%% Step 5) Load Roger's camera curves, d65, attenuation curves and to the proper interpolation to make them all same WL intervals

% load Sc, Roger's camera
% load D65
% load IOP struct
% wl the wavelength range you chose to work with

depth = 18; % remember to update this with the appropriate depth for that image

thisRGB = zeros(numel(IOP),3);
for i = 1:numel(IOP)
    thisKd = interp1(IOP(i).wavelength,IOP(i).JerlovKd,wl);
    thisKd(isnan(thisKd)) = 0;
    
    for j = 1:3
        thisRGB(i,j) = sum(d65.*exp(-thisKd.*depth).*Sc(:,j));
    end
    thisRGB(i,:) = thisRGB(i,:)./sum(thisRGB(i,:));
    
end

% Computer the error
sse = ((thisRGB(:,1)-Irgb(1)).^2 + (thisRGB(:,2)-Irgb(2)).^2 + (thisRGB(:,3)-Irgb(3)).^2);

% visualize results
figure
subplot(211)
plot(1:10,thisRGB(:,1),'r-','linewidth',3);hold on; 
plot(1:10,thisRGB(:,2),'g-','linewidth',3);
plot(1:10,thisRGB(:,3),'b-','linewidth',3);
plot(1:10,Irgb(1),'ro','markeredgecolor','k','markerfacecolor','r','markersize',10,'linewidth',2)
plot(1:10,Irgb(2),'go','markeredgecolor','k','markerfacecolor','g','markersize',10,'linewidth',2)
plot(1:10,Irgb(3),'bo','markeredgecolor','k','markerfacecolor','b','markersize',10,'linewidth',2)
set(gca,'xtick',1:10)
set(gca,'xticklabel',{IOP.waterType})
xlabel('Water Type')
ylabel('Normalized RGB')
set(gca,'fontsize',20)
set(gca,'ylim',[0 1])

subplot(212)
p1 = plot(1:10,abs(thisRGB(:,1)-Irgb(1)),'r-','linewidth',3);hold on; 
p2 = plot(1:10,abs(thisRGB(:,2)-Irgb(2)),'g-','linewidth',3);
p3 = plot(1:10,abs(thisRGB(:,3)-Irgb(3)),'b-','linewidth',3);
p4 = plot(1:10,sse,'k-','linewidth',3);
set(gca,'ylim',[0 0.3]);
set(gca,'fontsize',20)
set(gca,'xticklabel',{IOP.waterType})
xlabel('Water Type')
ylabel('SSE')
legend([p1 p2 p3 p4],{'SSE_r','SSE_g','SSE_b','SSE_total'})

