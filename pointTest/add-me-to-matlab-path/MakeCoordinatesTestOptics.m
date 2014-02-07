%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render the CoordinatesTest scene with realistic optics

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
parentSceneFile = 'CoordinatesTest.dae';
mappingsFile = 'CoordinatesTestOpticsMappings.txt';
conditionsFile = 'CoordinatesTestOpticsConditions.txt';

%% Mess with the camera focus.
focalLength = 50;
nConditions = 9;
down = -0.004;
up = 0.006;
filmDistance = focalLength + linspace(down, up, nConditions);
WriteConditionsFile(conditionsFile, {'filmdistance'}, num2cell(filmDistance'));

% I'm not sure how to bring the scene into focus...

%% Choose batch renderer options.
hints.imageWidth = 160;
hints.imageHeight = 120;
hints.outputSubfolder = mfilename();
hints.isCaptureCommandResults = false;

%% Render with Mitsuba and PBRT.
toneMapFactor = 100;
isScale = true;
for renderer = {'PBRT_Optics'}
    hints.renderer = renderer{1};
    nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
    radianceDataFiles = BatchRender(nativeSceneFiles, hints);
    montageName = sprintf('CoordinatesTestOptics (%s)', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end

