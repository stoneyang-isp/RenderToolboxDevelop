%% Sandbox for playing with Mitsuba's field integrator.

% This is a cut and paste from some testing I was doing earlier.
% It won't work without a bit of tidying up.
% BSH

hints = recipes{2}.input.hints;
ChangeToWorkingFolder(hints);
sceneFile = '/Users/ben/Documents/MATLAB/virtual-scenes/working/WardLand-02/scenes/Mitsuba/ward-field.xml';
[status, result, output] = RunMitsuba(sceneFile, hints)

[sliceInfo, data] = ReadMultichannelEXR(output);
{sliceInfo.name}'

slice = data(:,:,2); 
imshow(slice ./ max(slice(:)));
