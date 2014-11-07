%% Generate a batch of blobbies to insert into scenes.

blender = '/Applications/Blender-2.68a/blender.app/Contents/MacOS/blender';
blobbieScript = '/Users/ben/Documents/Projects/RenderToolboxDevelop/Blobbies/PythonScripts/IsolatedBlobbie.py';
toolboxDirectory = fullfile(RenderToolboxRoot(), 'Utilities', 'BlenderPython');
exportsDirectory = fullfile(VirtualScenesRoot(), '..', 'Objects', 'Models');

sceneName = 'Blobbie';
objectName = 'Blobbie';
blobbieSubdivisions = 4;
angleX = pi/3;
angleY = -pi/5-pi/2;
angleZ = -pi/6+pi/2;
frequencyX = 9;
frequencyY = 11;
frequencyZ = -8;
gainX = 9/1000;
gainY = 9/1000;
gainZ = 9/1000;

command = sprintf(['%s --background ', ...
    '--python %s -- ', ...
    '--toolboxDirectory %s', ...
    '--exportsDirectory %s ', ...
    '--sceneName %s ', ...
    '--objectName %s ', ...
    '--blobbieSubdivisions %d', ...
    '--angleX %f --angleY %f --angleZ %f ', ...
    '--frequencyX %f --frequencyY %f --frequencyZ %f ', ...
    '--gainX %f --gainY %f --gainZ %f ', ...
    blender, ...
    blobbieScript, ...
    toolboxDirectory, ...
    exportsDirectory, ...
    sceneName, ...
    objectName, ...
    blobbieSubdivisions, ...
    angleX, angleY, angleZ, ...
    frequencyX, frequencyY, frequencyZ, ...
    gainX, gainY, gainZ);
