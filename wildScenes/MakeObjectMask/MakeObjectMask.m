%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Insert objects into a scene and try to map pixels to objects.
clear;

%% Locate files of interest.
wildPath = fileparts(mfilename('fullpath'));
parentScene = fullfile(wildPath, 'tame/scenes/IndoorPlant.dae');
objectPath = fullfile(wildPath, 'tame/objects');
objects = { ...
    fullfile(objectPath, 'Barrel.dae'), ...
    fullfile(objectPath, 'ChampagneBottle.dae'), ...
    fullfile(objectPath, 'RingToy.dae'), ...
    fullfile(objectPath, 'Xylophone.dae')};

% mappings file was auto-generated, then modified by hand
mappingsFile = 'ObjectMaskMappings.txt';
% white = {'300:1 800:1'};
% WriteDefaultMappingsFile( ...
%     parentSceneFile, mappingsFile, '', white, white);

% conditions file generated from objects
wls = 300:10:800;
reflectance1 = GetSingleBandReflectance(wls, 27, 1);
reflectances1 = repmat({reflectance1}, numel(objects), 1);
varNames = {'object1', 'reflectance1'};
varValues = cat(2, objects', reflectances1);
conditionsFile = 'ObjectMaskConditions.txt';
WriteConditionsFile(conditionsFile, varNames, varValues);

%% Choose batch renderer options.
hints.imageWidth = 320;
hints.imageHeight = 240;
hints.recipeName = 'MakeWildScene';
hints.renderer = 'Mitsuba';
hints.remodeler = 'InsertObjectRemodeler';

hints.whichConditions = 1;

%% Render all objects!
nativeSceneFiles = MakeSceneFiles(parentScene, conditionsFile, mappingsFile, hints);
radianceDataFiles = BatchRender(nativeSceneFiles, hints);

%% Try to find the objects.
close all
clc

toneMapFactor = 100;
isScale = true;

pixelThreshold = 0.1;
pixelMaskRgb = [0 255 0];

imageFolder = GetWorkingFolder('images', true, hints);
for oo = 1:numel(hints.whichConditions)
    rendering = load(radianceDataFiles{oo});
    imageSize = size(rendering.multispectralImage);
    
    % save the sRgb image
    objectFile = objects{hints.whichConditions(oo)};
    [objectPath, objectName] = fileparts(objectFile);
    imageFile = fullfile(imageFolder, [objectName '-srgb.png']);
    sRgbImage = MakeMontage(radianceDataFiles(oo), imageFile, toneMapFactor, isScale, hints);
    sRGBMasked = uint8(sRgbImage);
    
    wls = MakeItWls(rendering.S);
    
    for ii = 1:imageSize(1)
        for jj = 1:imageSize(2)
            pixelSpectrum = squeeze(rendering.multispectralImage(ii,jj,:));
            isHigh = pixelSpectrum > max(pixelSpectrum)*pixelThreshold;
            if sum(isHigh) == 1
                sRGBMasked(ii,jj,:) = pixelMaskRgb;
            end
        end
    end
    
    % save the mask image
    maskFile = fullfile(imageFolder, [objectName '-mask.png']);
    imwrite(sRGBMasked, maskFile)
    
    % show sRgb
    f = figure();
    subplot(1,2,1);
    imshow(uint8(sRgbImage));
    title('sRgb');
    
    % show sRGB covered by mask
    subplot(1,2,2);
    imshow(sRGBMasked);
    title('masked');
    
    % resize figure for convenience
    pos = get(f, 'Position');
    width = imageSize(2)*2.5;
    height = imageSize(1)*1.25;
    pos(3:4) = [width height];
    set(f, 'Position', pos);
end
