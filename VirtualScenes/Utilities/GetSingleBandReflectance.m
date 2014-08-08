%% Make a spectrum string with reflectance in a single band.
% like '300:0 499:0 500:1 501:0 800:0'
function reflectance = GetSingleBandReflectance(wls, whichBand, magnitude)
low = wls(1);
target = wls(whichBand);
high = wls(end);
leftFlank = target-1;
rightFlank = target+1;
reflectance = sprintf('%d:0 %d:0 %d:%d %d:0 %d:0', ...
    low, leftFlank, target, magnitude, rightFlank, high);
