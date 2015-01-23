clear;
clc;

wardLandArchive = '/Users/ben/Documents/Projects/RenderToolboxDevelop/VirtualScenesToolbox/Examples/MatchRMSE/Recipes/WardLand-05.zip';
matchRMSEMappings = '/Users/ben/Documents/Projects/RenderToolboxDevelop/VirtualScenesToolbox/Examples/MatchRMSE/Recipes/WardLand-05-MatchRMSEMappings.txt';

hints.renderer = 'Mitsuba';
hints.imageWidth = 640/4;
hints.imageHeight = 480/4;
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');

recipe = BuildMatchRMSERecipe(wardLandArchive, matchRMSEMappings, hints);
working = GetWorkingFolder('', false, recipe.input.hints);

% Build a parameter sweep for object reflectance
nSteps = 4;
lambdas = linspace(0, 1, nSteps);

spectrumA = ResolveFilePath('mccBabel-14.spd', working);
[refWlsA, refMagsA] = ReadSpectrum(spectrumA.absolutePath);
spectrumB = ResolveFilePath('mccBabel-22.spd', working);
[refWlsB, refMagsB] = ReadSpectrum(spectrumB.absolutePath);

reflectanceFiles = cell(nSteps, 1);
imageNames = cell(nSteps, 1);
resources = GetWorkingFolder('resources', false, recipe.input.hints);
for ii = 1:nSteps
    imageNames{ii} = sprintf('reflectance-%02d', ii);
    reflectanceFiles{ii} = sprintf('reflectance-%02d.spd', ii);
    refMags = lambdas(ii)*refMagsA + (1-lambdas(ii))*refMagsB;
    WriteSpectrumFile(refWlsA, refMags, fullfile(resources, reflectanceFiles{ii}));
end

% write a new conditions file for the sweep
conditionsFile = ResolveFilePath(recipe.input.conditionsFile, working);
[varNames, varValues] = ParseConditions(conditionsFile.absolutePath);
newValues = repmat(varValues, nSteps, 1);
isParam = strcmp(varNames, 'inserted-object-diffuse-1');
newValues(:,isParam) = reflectanceFiles;
isImageName = strcmp(varNames, 'imageName');
newValues(:,isImageName) = imageNames;

newConditionsFile = fullfile(working, 'reflectanceConditions.txt');
WriteConditionsFile(newConditionsFile, varNames, newValues);
recipe.input.conditionsFile = newConditionsFile;

% go
recipe = ExecuteRecipe(recipe);
