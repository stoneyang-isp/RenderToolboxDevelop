% Informal test of new TwoPointCorrelationDistribution()

clear
clc

naturalImages = '/Users/ben/Documents/Projects/UPennNaturalImages/tofu.psych.upenn.edu/zip_nxlhtvdlbb/cd16A';

imageFileA = fullfile(naturalImages, 'DSC_0001_LUM.mat');
imageDataA = load(imageFileA);
imageA = imageDataA.LUM_Image;

imageFileB = fullfile(naturalImages, 'DSC_0003_LUM.mat');
imageDataB = load(imageFileB);
imageB = imageDataB.LUM_Image;

binEdges = 0:5:200;
samplesPerBin = 5000;

subplot(3, 2, 1)
imshow(imageA, [0, max(imageA(:))])

subplot(3, 2, 2)
[inCorrelations, outCorrelations, nIn, binEdges] = ...
    TwoPointCorrelationDistribution(imageA, imageA, binEdges, samplesPerBin);
binTops = binEdges(2:end);
plot(binTops, inCorrelations, binTops, outCorrelations);
ylim([0, 1])

subplot(3, 2, 3)
imshow(imageB, [0, max(imageB(:))])

subplot(3, 2, 4)
[inCorrelations, outCorrelations, nIn, binEdges] = ...
    TwoPointCorrelationDistribution(imageB, imageB, binEdges, samplesPerBin);
binTops = binEdges(2:end);
plot(binTops, inCorrelations, binTops, outCorrelations);
ylim([0, 1])

subplot(3, 2, 6)
[inCorrelations, outCorrelations, nIn, binEdges] = ...
    TwoPointCorrelationDistribution(imageA, imageB, binEdges, samplesPerBin);
binTops = binEdges(2:end);
plot(binTops, inCorrelations, binTops, outCorrelations);
ylim([0, 1])

set(gcf(), 'Position', [100 100 1000 1000])
