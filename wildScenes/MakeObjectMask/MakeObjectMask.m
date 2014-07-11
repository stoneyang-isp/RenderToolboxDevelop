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

conditionsFile = 'ObjectMaskConditions.txt';

% Barrel-material

% Bottle-material

% Stacker-material
% Ring1-material
% Ring2-material
% Ring3-material
% Ring4-material
% Ring5-material

% Fasteners-material
% Keys-material
% Mallet1-material
% Mallet2-material

% Trim
% WallHanging centers
% PianoCase
% PianoLid


%% Choose batch renderer options.
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.recipeName = 'MakeWildScene';
hints.renderer = 'Mitsuba';
%hints.remodeler = 'InsertObjectRemodeler';

hints.whichConditions = 1;

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
