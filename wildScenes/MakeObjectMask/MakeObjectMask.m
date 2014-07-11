%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
clear
clc
close all

%% Insert objects into a scene and try to map pixels to objects.

parentSceneFile = 'tame/scenes/GrandPiano.dae';
objectFiles = { ...
    'tame/objects/Barrel.dae', ...
    'tame/objects/ChampagneBottle.dae', ...
    'tame/objects/RingToy.dae', ...
    'tame/objects/Xylophone.dae'};

mappingsFile = 'ObjectMaskMappings.txt';
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
hints.imageWidth = 180;
hints.imageHeight = 120;
hints.workingFolder = fileparts(mfilename('fullpath'));
hints.outputSubfolder = 'MakeWildScene';

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
