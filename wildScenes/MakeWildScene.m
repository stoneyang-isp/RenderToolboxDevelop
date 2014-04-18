%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render a wild scene with no special processing.
%parentSceneFile = 'TestScene3.dae';
parentSceneFile = 'GrandPiano.dae';

%% Choose batch renderer options.
hints.imageWidth = 320;
hints.imageHeight = 240;
hints.workingFolder = fileparts(mfilename('fullpath'));
hints.outputSubfolder = mfilename();

%% Cook up a silly mappings file.
mappingsFile = 'WildSceneMappings.txt';
WriteDefaultMappingsFile(parentSceneFile, mappingsFile);

%% Render with Mitsuba and PBRT.
toneMapFactor = 100;
isScale = true;
hints.renderer = 'Mitsuba';
nativeSceneFiles = MakeSceneFiles(parentSceneFile, '', mappingsFile, hints);
radianceDataFiles = BatchRender(nativeSceneFiles, hints);
montageName = sprintf('WildScene (%s)', hints.renderer);
montageFile = [montageName '.png'];
[SRGBMontage, XYZMontage] = ...
    MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
ShowXYZAndSRGB([], SRGBMontage, montageName);

