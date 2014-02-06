% Render some test scenes from Andy Lai Lin.
%
% These use Andy's optics version of his pbrt-v2-spectral renderer.  The
% PBRT_Optics renderer plugin encapsulates this version of of
% pbrt-v2-spectral in RenderToolbox3 style.
%

%% Set up.
PBRTOpticsConfigurationTemplate;

% locate scene files relative to this file
localPath = fileparts(mfilename('fullpath'));
if isempty(localPath)
    localPath = pwd();
end

% most hints ignored when calling RunPBRT_Optics directly
hints.isPlot = true;
hints.isCaptureCommandResults = false;

%% Render the "ideal lens" test scene.
pbrtFile = fullfile(localPath, '..', 'idealLens', 'pointTest.pbrt');
[status, result, output] = RunPBRT_Optics(pbrtFile, hints);

%% Render the "realistic lens" test scene.
pbrtFile = fullfile(localPath, '..', 'realisticLens', 'realisticPointTest.pbrt');
[status, result, output] = RunPBRT_Optics(pbrtFile, hints);