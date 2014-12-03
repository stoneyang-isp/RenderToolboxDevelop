% Take the mean of a multi-spectral image under a 2D mask.
%   rawImage some m x n x p image
%   mask some m x n mask, nonzero where the mean should be taken
function [meanPixel, medianPixel] = MeanUnderMask(rawImage, mask)
imageSize = size(rawImage);
height= imageSize(1);
width = imageSize(2);
depth = imageSize(3);
sliceSize = height*width;

% does the mask have any area?
maskIndices = find(mask ~= 0);
if isempty(maskIndices)
    meanPixel = [];
    medianPixel = [];
    return;
end

% extrude the mask into the image depth and get 1D indices
nSamples = numel(maskIndices);
sampleIndices = repmat(maskIndices, [1, depth]);
cornerIndices = 1:sliceSize:numel(rawImage);
cornerOffsets = repmat(cornerIndices-1, [nSamples, 1]);
sampleIndices = sampleIndices + cornerOffsets;

% pick out the pixels under the mask
imageSample = zeros(nSamples, depth);
imageSample(:) = rawImage(sampleIndices);

% calculate pixel statistics
meanPixel = mean(imageSample, 1);
medianPixel = median(imageSample, 1);
