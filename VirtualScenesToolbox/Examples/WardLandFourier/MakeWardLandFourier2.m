%% Locate WardLand renderings and do *more* spatial frequency analysis.
%
% This script performs spatial frequency analysis on luminance images from
% WardLand recipes.
%
% You should run this script after you've already executed some WardLand
% renderings, as with ExecuteWardLandReferenceRecipes.
%
% You can edit some parameters at the top of this script to change things
% like which recipe and renderer to get data for.
%
% @ingroup WardLand

%% Overall Setup.
clear;
clc;

% locate the renderings
hints.recipeName = 'Blobbies';
hints.renderer = 'Mitsuba';
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');

% locate natural images
naturalImages = '/Users/ben/Documents/Projects/UPennNaturalImages/tofu.psych.upenn.edu/zip_nxlhtvdlbb/cd16A';

% for sRGB conversion
toneMapFactor = 100;
isScale = true;

% for frequency distribution analysis by rings
nBands = 25;

%% Make "Fourier Structs" that can be analyzed unifoirmly.
wardStruct = WardLandRenderingFourierStruct(hints, 'ward', 'ward', toneMapFactor, isScale);
boringStruct = WardLandRenderingFourierStruct(hints, 'boring', 'boring', toneMapFactor, isScale);
illuminationStruct = WardLandImageFourierStruct(hints, 'illumination', 'diffuse-interp.png', 'illumination');
reflectanceStruct = WardLandImageFourierStruct(hints, 'reflectance', 'diffuse-interp.png', 'reflectance');
rgStruct = WardLandImageFourierStruct(hints, 'dkl', 'diffuseReflectanceInterp-rg.png', 'reflect. r-g');
byStruct = WardLandImageFourierStruct(hints, 'dkl', 'diffuseReflectanceInterp-by.png', 'reflect. b-y');

cropSize = size(byStruct.grayscale);
roadStruct = NaturalImageFourierStruct(naturalImages, 'DSC_0001', 'natural road', cropSize);
fenceStruct = NaturalImageFourierStruct(naturalImages, 'DSC_0003', 'natural fence', cropSize);

fourierStructs = [ ...
    roadStruct, ...
    fenceStruct, ...
    wardStruct, ...
    boringStruct, ...
    illuminationStruct, ...
    reflectanceStruct, ...
    rgStruct, ...
    byStruct];

%% Do spatial frequency analysis on all the structs.
fourierStructs = AnalyzeFourierStruct(fourierStructs, nBands);

%% Plot results for all the structs.
[fourierStructs, plotFig] = PlotFourierStruct(fourierStructs);
[fourierStructs, summaryFig] = SummarizeFourierStruct(fourierStructs);
