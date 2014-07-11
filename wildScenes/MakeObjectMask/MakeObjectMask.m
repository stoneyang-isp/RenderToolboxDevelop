%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
clear
clc
close all

%% Insert objects into a scene and try to map pixels to objects.

parentSceneFile = 'tame/scenes/IndoorPlant.dae';
objectFiles = { ...
    'tame/objects/Barrel.dae', ...
    'tame/objects/ChampagneBottle.dae', ...
    'tame/objects/RingToy.dae', ...
    'tame/objects/Xylophone.dae'};

% base mappings file with all white reflecances and lights
%   to be modified with area lights
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
hints.workingFolder = fileparts(mfilename('fullpath'));
hints.outputSubfolder = 'MakeWildScene';

hints.whichConditions = 1;

toneMapFactor = 100;
isScale = true;
hints.renderer = 'Mitsuba';
%hints.remodeler = 'InsertObjectRemodeler';

% render them all!
nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
radianceDataFiles = BatchRender(nativeSceneFiles, hints);
montageName = sprintf('WildScenes (%s)', hints.renderer);
montageFile = [montageName '.png'];
[SRGBMontage, XYZMontage] = ...
    MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
ShowXYZAndSRGB([], SRGBMontage, montageName);
