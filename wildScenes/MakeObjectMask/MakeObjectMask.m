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

% mappings file was generated, then modified
mappingsFile = 'ObjectMaskMappings.txt';
% white = {'300:1 800:1'};
% WriteDefaultMappingsFile( ...
%     parentSceneFile, mappingsFile, '', white, white);

% conditions file generated from objects
varNames = {'object1'};
varValues = objects';
conditionsFile = 'ObjectMaskConditions.txt';
WriteConditionsFile(conditionsFile, varNames, varValues);

%% Choose batch renderer options.
hints.imageWidth = 320;
hints.imageHeight = 240;
hints.recipeName = 'MakeWildScene';
hints.renderer = 'Mitsuba';
hints.remodeler = 'InsertObjectRemodeler';

hints.whichConditions = 1:4;

toneMapFactor = 100;
isScale = true;

% render them all!
nativeSceneFiles = MakeSceneFiles(parentScene, conditionsFile, mappingsFile, hints);
radianceDataFiles = BatchRender(nativeSceneFiles, hints);
montageName = sprintf('WildScene (%s)', hints.renderer);
montageFile = [montageName '.png'];
[SRGBMontage, XYZMontage] = ...
    MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
ShowXYZAndSRGB([], SRGBMontage, montageName);

%% Try to find the objects.
imageFolder = GetWorkingFolder('images', true, hints);
for oo = 1:numel(hints.whichConditions)
    
    rendering = load(radianceDataFiles{oo});
    imageSize = size(rendering.multispectralImage);
    
    objectMask = zeros(imageSize(1), imageSize(2), 'uint8');
    for ii = 1:imageSize(1)
        for jj = 1:imageSize(2)
            pixelSpectrum = squeeze(rendering.multispectralImage(ii,jj,:));
            if any(pixelSpectrum == 0)
                objectMask(ii,jj) = 255;
            end
        end
    end
    
    % save the mask image
    objectFile = objects{hints.whichConditions(oo)};
    [objectPath, objectName] = fileparts(objectFile);
    maskFile = fullfile(imageFolder, [objectName '-mask.png']);
    imwrite(objectMask, maskFile)
    
    % save the rendering by itself
    imageFile = fullfile(imageFolder, [objectName '-srgb.png']);
    MakeMontage(radianceDataFiles(oo), imageFile, toneMapFactor, isScale, hints);
end
