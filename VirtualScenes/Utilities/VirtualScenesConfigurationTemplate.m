% Set up machine-specific Virtual Scenes configuration, like where to find
% BaseScenes, and image processing default parameters.
%
% This script is intended as a template only.  You should make a copy of
% this script and save it in a folder separate from Virtual Scenes.  You
% should customize that copy with values that are specific to your machine.
%
% The goal of this script is to set Matlab preference values that
% you want to use for your machine.  These include file paths where
% Virtual Scenes should look for BaseScenes, Objects, and Lights, image
% processing default parameters, and where to write ouptut files.
%
% When you first install Virtual Scenes, you should copy this script,
% customize it, and run it.  You can run it again, any time you want to
% make sure your Virtual Scenes preferences are correct.
%

% clear out any old preferences
prefName = 'VirtualScenes';
if ispref(prefName)
    rmpref(prefName);
end

% 3D model locations
setpref(prefName, 'modelRepository', VirtualScenesRoot());

% where to save output recipes
setpref(prefName, 'outputFolder', fullfile(GetUserFolder(), 'virtual-scenes'));

% image processing defaults
setpref(prefName, 'toneMapFactor', 100);
setpref(prefName, 'toneMapScale', true);
setpref(prefName, 'pixelThreshold', 0.01);
setpref(prefName, 'filterWidth', 7);
setpref(prefName, 'lmsSensitivities', 'T_cones_ss2');
setpref(prefName, 'dklSensitivities', 'T_CIE_Y2');

% scaling for large montages
setpref(prefName, 'montageScaleFactor', 1);
setpref(prefName, 'montageScaleMethod', 'lanczos3');