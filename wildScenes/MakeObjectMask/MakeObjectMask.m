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

nConditions = 1;
nObjects = 4;

allNames = {};
allValues = {};
for ii = 1:nObjects
    % choose object reflectance
    wls = 300:10:800;
    reflectance = GetSingleBandReflectance(wls, 10+ii, 1);
    reflectances = repmat({reflectance}, 1, nConditions);
    
    % choose the position for each object
    %   bound by a box that I determined by poking around in Blender
    xRange = [-6 2];
    yRange = [-2 2];
    zRange = [0 6];
    position = cell(1, nConditions);
    for cc = 1:nConditions
        position{cc} = GetRandomPosition(xRange, yRange, zRange);
    end
    
    % choose a random object for each condition
    object = objects(randi(numel(objects), [1, nConditions]));
    
    % pack up variable names and values
    objectName = sprintf('object-%d', ii);
    reflectanceName = sprintf('reflectance-%d', ii);
    positionName = sprintf('position-%d', ii);
    varNames = {objectName, reflectanceName, positionName};
    varValues = cat(2, object', reflectances', position');
    
    % append for conditions file creation
    allNames = cat(2, allNames, varNames);
    allValues = cat(2, allValues, varValues);
end

conditionsFile = 'ObjectMaskConditions.txt';
WriteConditionsFile(conditionsFile, allNames, allValues);

%% Choose batch renderer options.
hints.imageWidth = 320;
hints.imageHeight = 240;
hints.recipeName = 'MakeWildScene';
hints.renderer = 'Mitsuba';
hints.remodeler = 'InsertObjectRemodeler';

hints.whichConditions = 1:nConditions;

%% Render all objects!
nativeSceneFiles = MakeSceneFiles(parentScene, conditionsFile, mappingsFile, hints);
radianceDataFiles = BatchRender(nativeSceneFiles, hints);

%% Try to find the objects.
close all

toneMapFactor = 100;
isScale = true;

pixelThreshold = 0.1;
pixelMaskRgb = 255*[ ...
    0 0 1; ...
    0 1 0; ...
    0 1 1; ...
    1 0 0; ...
    1 0 1; ...
    1 1 0; ...
    1 1 1];

imageFolder = GetWorkingFolder('images', true, hints);
for cc = 1:numel(hints.whichConditions)
    rendering = load(radianceDataFiles{cc});
    imageSize = size(rendering.multispectralImage);
    
    % save the sRgb image
    objectName = sprintf('%d-MakeObjectMask', cc);
    imageFile = fullfile(imageFolder, [objectName '-srgb.png']);
    sRgbImage = MakeMontage(radianceDataFiles(cc), imageFile, toneMapFactor, isScale, hints);
    sRGBMasked = uint8(sRgbImage);
    
    wls = MakeItWls(rendering.S);
    %figure();

    for ii = 1:imageSize(1)
        for jj = 1:imageSize(2)
            pixelSpectrum = squeeze(rendering.multispectralImage(ii,jj,:));
            isHigh = pixelSpectrum > max(pixelSpectrum)*pixelThreshold;
            if sum(isHigh) == 1
                whichObject = find(isHigh);
                sRGBMasked(ii,jj,:) = pixelMaskRgb(whichObject,:);
                %line(wls, pixelSpectrum, 'Marker', 'none', 'LineStyle', '-')
            end
        end
    end
    %set(gca, 'XTickLabel', wls)
    
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
