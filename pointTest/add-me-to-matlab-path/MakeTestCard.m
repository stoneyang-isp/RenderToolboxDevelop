%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render a test as several distances and focuses
clear

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
parentSceneFile = 'TestCard.dae';
mappingsFile = 'TestCardMappings.txt';
conditionsFile = 'TestCardConditions.txt';

%% Choose batch renderer options.
hints.imageWidth = 200;
hints.imageHeight = 200;
hints.outputSubfolder = mfilename();
hints.isCaptureCommandResults = false;

%% Render with Mitsuba and PBRT.
toneMapFactor = 100;
isScale = true;
for renderer = {'PBRT_Optics'}
    hints.renderer = renderer{1};
    nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
    radianceDataFiles = BatchRender(nativeSceneFiles, hints);
    montageName = sprintf('Test Card (%s)', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end

