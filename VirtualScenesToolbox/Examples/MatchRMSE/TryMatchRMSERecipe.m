clear;
clc;

wardLandArchive = '/Users/ben/Documents/Projects/RenderToolboxDevelop/VirtualScenesToolbox/Examples/MatchRMSE/Recipes/WardLand-05.zip';
matchRMSEMappings = '/Users/ben/Documents/Projects/RenderToolboxDevelop/VirtualScenesToolbox/Examples/MatchRMSE/Recipes/WardLand-05-MatchRMSEMappings.txt';

hints.renderer = 'Mitsuba';
hints.imageWidth = 640/4;
hints.imageHeight = 480/4;
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');

blankRecipe = BuildMatchRMSERecipe(wardLandArchive, matchRMSEMappings, hints);
working = GetWorkingFolder('', false, blankRecipe.input.hints);
resources = GetWorkingFolder('resources', false, blankRecipe.input.hints);
images = GetWorkingFolder('images', true, blankRecipe.input.hints);
renderings = GetWorkingFolder('renderings', true, blankRecipe.input.hints);

nSteps = 10;

%% Run a parameter sweep for object reflectance.
refSweepName = 'reflectance';
paramName = 'inserted-object-diffuse-1';
spectrumA = ResolveFilePath('mccBabel-14.spd', working);
spectrumB = ResolveFilePath('mccBabel-19.spd', working);

[spdFiles, refImageNames, refLambdas] = BuildSpectrumSweep( ...
    refSweepName, spectrumA.absolutePath, spectrumB.absolutePath, nSteps, resources);
recipe = BuildSweepConditions(blankRecipe, refSweepName, paramName, spdFiles, refImageNames);
recipe = ExecuteRecipe(recipe);

%% Run a parameter sweep for illumination.
illumSweepName = 'illumination';
paramName = 'base-light-illum-1';
spectrumA = ResolveFilePath('Sun.spd', working);
spectrumB = ResolveFilePath('Sky.spd', working);

[spdFiles, illumImageNames, illumLambdas] = BuildSpectrumSweep( ...
    illumSweepName, spectrumA.absolutePath, spectrumB.absolutePath, nSteps, resources);
recipe = BuildSweepConditions(blankRecipe, illumSweepName, paramName, spdFiles, illumImageNames);
recipe = ExecuteRecipe(recipe);

%% Run a parameter sweep for camera position.
cameraSweepName = 'camera';
paramName = 'camera-position';
offsetA = [0 0 0];
offsetB = [1 1 1]*.05;

[offsets, cameraImageNames, cameraLambdas] = BuildVectorSweep( ...
    cameraSweepName, offsetA, offsetB, nSteps);
recipe = BuildSweepConditions(blankRecipe, cameraSweepName, paramName, offsets, cameraImageNames);
recipe = ExecuteRecipe(recipe);

%% Run a parameter sweep for opject scale.
scaleSweepName = 'scale';
paramName = 'object-scale-1';
scaleA = [1.201800 1.511832 1.164367];
scaleB = scaleA*1.8;

[offsets, scaleImageNames, scaleLambdas] = BuildVectorSweep( ...
    scaleSweepName, scaleA, scaleB, nSteps);
recipe = BuildSweepConditions(blankRecipe, scaleSweepName, paramName, offsets, scaleImageNames);
recipe = ExecuteRecipe(recipe);

%% Plot RMSEs vs lambdas.
refRmses = ComputeSweepRMSE(recipe, refImageNames);
illumRmses = ComputeSweepRMSE(recipe, illumImageNames);
cameraRmses = ComputeSweepRMSE(recipe, cameraImageNames);
scaleRmses = ComputeSweepRMSE(recipe, scaleImageNames);

plot(refLambdas, refRmses, ...
    illumLambdas, illumRmses, ...
    cameraLambdas, cameraRmses, ...
    scaleLambdas, scaleRmses, ...
    'LineStyle', 'none', 'Marker', '.');
legend(refSweepName, illumSweepName, cameraSweepName, scaleSweepName);

%% Make a Big Montage to compare RMSEs.
toneMapFactor = 100;
isScale = true;
outFile = fullfile(images, 'MatchedRMSEs.png');
inFiles = cell(nSteps, 4);
for ii = 1:nSteps
    inFiles{ii, 1} = fullfile(renderings, [refImageNames{ii} '.mat']);
    inFiles{ii, 2} = fullfile(renderings, [illumImageNames{ii} '.mat']);
    inFiles{ii, 3} = fullfile(renderings, [cameraImageNames{ii} '.mat']);
    inFiles{ii, 4} = fullfile(renderings, [scaleImageNames{ii} '.mat']);
end

MakeMontage(inFiles, outFile, toneMapFactor, isScale);
