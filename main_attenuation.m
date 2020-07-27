% This code calculates how white should appear at a certain depth at a
% certain water type for Roger's camera

clear;close;clc

% Load attenuation data - there are 10 water types with increasing
% turbidity
load('attenuationData.mat','IOP')
wavelength = IOP.wavelength;

% Load Roger's camera curves here, those will be Sc
% Make sure to interpolate the wavelengths to match 'wavelength', so they
% are the same length.
% load('CanonCurves.mat') or whatever it is called
% Sc = .....

% Add here D65 to be used for surface spectrum
% load('d65spectrum.mat') or whatever it is called
% d65 = ....

% Reflectance of a white color is flat across wavelengths
white = ones(numel(wavelength),1);


% We assume depth is known. Here I'm making it up for the example, you
% replace it with the relevant value:
d = 10;

% Select water type (1-10)
waterType = 1;
attenuationCoefficient  = IOP(waterType).ActualKd;

% rgb is the color of white for Roger's camera at this depth in this water
% type. If we are confident in the depth, we can easily find the best water
% type by minimizing the error with what we calculate here, versus what
% values are recorded in the imaged color chart.
rgb = zeros(1,3);
for j = 1:3
    rgb(j,j) = white.*Sc(j,:).*d65.*exp(-attenuationCoefficient.*d);
end

% Compare this rgb to RGB from the imaged color chart.

