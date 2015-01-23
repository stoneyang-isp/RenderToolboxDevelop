%% Make a new MatchRMSE recipe based on an existing WardLand recipe.
%   wardLandArchive is the file name to an existing WardLand recipe archive
%   matchRMSEMappings is a hand-made mappings file for wardLandArchive
%   hints is RenderToolbox3 options from GetDefaultHints()
%
%   wardLandArchive should have been created by MakeManyWardLandRecipes.
%
%   matchRMSEMappings has to be a hand-crafted mappings file based on the
%   original mappings file in wardLandArchive.  It only needs to contain
%   the mappings for the "ward" group.  It must break out certain values as
%   variables using standard names:
%       - (camera-position) increment to apply to camera translation
%       - (camera-rotation-z) increment to apply to camera z-rotation
%       - (camera-rotation-y) increment to apply to camera y-rotation
%       - (camera-rotation-x) increment to apply to camera x-rotation
%       - (base-light-illum-1) spectrum for a light in the base scene
%       - (base-object-diffuse-1) diffuse reflectance for an object in
%       the base scene
%       - (base-object-specular-1) specular reflectance for an object in
%       the base scene
%       - (inserted-light-illum-1) sprctrum for an inserted light
%       - (inserted-object-diffuse-1) diffuse reflectance for an inserted
%       object
%       - (inserted-object-specular-1) specular reflectance for an inserted
%       object
%
%   We have to do this by hand because there's no good way for the computer
%   to tell which objets in the scene are interesting/ripe for RMSE
%   manipulations.
%
%   The new recipe will have all of the above parameters broken out in a
%   new conditions file, with default values.
%
%   The new conditions file will also have broken-out values for inserted
%   lights and objects, with their original values:
%       - (light-position-1) position of an inserted light
%       - (light-rotation-1) rotation of an inserted light
%       - (light-scale-1) scaling of an inserted light
%       - (object-position-1) position of an inserted object
%       - (object-rotation-1) rotation of an inserted object
%       - (object-scale-1) scaling of an inserted object
%
%   Now all of these parameters can be modified for MatchRMSE parameter
%   sweeps, based on the original recipe in wardLandArchive.
function recipe = BuildMatchRMSERecipe(wardLandArchive, matchRMSEMappings, hints)

if nargin < 3
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

% unpack the archive and copy some hints for convenience
recipe = UnpackRecipe(wardLandArchive, hints);
recipe.input.hints.renderer = hints.renderer;
recipe.input.hints.workingFolder = hints.workingFolder;
recipe.input.hints.imageWidth = hints.imageWidth;
recipe.input.hints.imageHeight = hints.imageHeight;

% copy in the new mappings file and wire it up
working = GetWorkingFolder('', false, recipe.input.hints);
copyfile(matchRMSEMappings, working);

[mappingsPath, mappingsBase, mappingsExt] = fileparts(matchRMSEMappings);
recipe.input.mappingsFile = fullfile(working, [mappingsBase, mappingsExt]);

% simplify the execution
toneMapFactor = 100;
isScale = true;
recipe.input.executive = { ...
    @MakeRecipeSceneFiles, ...
    @MakeRecipeRenderings, ...
    @(recipe) MakeRecipeMontage(recipe, toneMapFactor, isScale)};

% read the old conditions file and extract the "ward" condition
conditionsFile = ResolveFilePath(recipe.input.conditionsFile, working);
[varNames, varValues] = ParseConditions(conditionsFile.absolutePath);
isGroupName = strcmp(varNames, 'groupName');
isWard = strcmp(varValues(:,isGroupName), 'ward');
wardValues = varValues(isWard, :);

% append names and values for the hooks in the new mappings file
hookNames = { ...
    'camera-position', ...
    'camera-z-rotation', ...
    'camera-y-rotation', ...
    'camera-x-rotation', ...
    'base-light-illum-1', ...
    'base-object-diffuse-1', ...
    'base-object-specular-1', ...
    'inserted-light-illum-1', ...
    'inserted-object-diffuse-1', ...
    'inserted-object-specular-1', ...
    };

hookValues = { ...
    '0 0 0', ...
    '0', ...
    '0', ...
    '0', ...
    '300:1 800:1', ...
    '300:1 800:1', ...
    '300:.1 800:.1', ...
    '300:1 800:1', ...
    '300:1 800:1', ...
    '300:.1 800:.1', ...
    };

% write out the new conditions file for the new recipe
newNames = cat(2, varNames, hookNames);
newValues = cat(2, wardValues, hookValues);
newConditionsFile = fullfile(working, 'MatchRMSEConditions.txt');
WriteConditionsFile(newConditionsFile, newNames, newValues);
recipe.input.conditionsFile = newConditionsFile;
