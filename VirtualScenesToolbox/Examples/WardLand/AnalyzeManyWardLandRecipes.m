%% Locate, unpack, and execute many WardLand recipes created earlier.
%
% Use this script to analyze many archived recipes rendered earlier, using
% RenderManyWardLandRecipes.
%
% You can configure a few recipe parameters at the top of this script.
%
% @ingroup WardLand

%% Overall Setup.
clear;
clc;

% location of packed-up recipes
projectName = 'WardLandDatabase';
recipeFolder = fullfile(getpref('VirtualScenes', 'recipesFolder'), projectName, 'Rendered');
if ~exist(recipeFolder, 'dir')
    disp(['Recipe folder not found: ' recipeFolder]);
end

% location of saved figures
figureFolder = fullfile(getpref('VirtualScenes', 'recipesFolder'), projectName, 'Figures');

% edit some batch renderer options
hints.renderer = 'Mitsuba';
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');

% analysis params
toneMapFactor = 10;
isScale = true;
filterWidth = 7;
lmsSensitivities = 'T_cones_ss2';

%% Analyze each packed up recipe.
archiveFiles = FindFiles(recipeFolder, '\.zip$');
nScenes = 2;%numel(archiveFiles);

reductions = cell(1, nScenes);
for ii = 1:nScenes
    % get the recipe
    recipe = UnpackRecipe(archiveFiles{ii}, hints);
    ChangeToWorkingFolder(recipe.input.hints);
    
    % run basic recipe analysis functions
    recipe = MakeRecipeRGBImages(recipe, toneMapFactor, isScale);
    recipe = MakeRecipeAlbedoFactoidImages(recipe, toneMapFactor, isScale);
    recipe = MakeRecipeShapeIndexFactoidImages(recipe);
    recipe = MakeRecipeIlluminationImages(recipe, filterWidth, toneMapFactor, isScale);
    recipe = MakeRecipeLMSImages(recipe, lmsSensitivities);
    
    % run spatial statistics analysis
    rgb = LoadRecipeProcessingImageFile(recipe, 'radiance', 'SRGBWard');
    xyz = LoadRecipeProcessingImageFile(recipe, 'radiance', 'XYZWard');
    lms = LoadRecipeProcessingImageFile(recipe, 'lms', 'radiance_ward_lms');
    [reductions{ii}, fig] = AnalyzeSpatialStats(rgb, double(xyz(:,:,2)), lms);
    
    % save figures for later
    set(fig, ...
        'Position', [100 100 1000 1000], ...
        'Name', sprintf('%d: %s', ii, recipe.input.hints.recipeName));
    drawnow();
    figureFile = fullfile(figureFolder, [recipe.input.hints.recipeName '.fig']);
    WriteImage(figureFile, fig);
    close(fig);
end

%% Show a grand summary across packed up recipes.
fig = SummarizeSpatialStats(reductions);
set(fig, ...
    'Position', [100 100 1000 1000], ...
    'Name', 'Two Point Correlations');
figureFile = fullfile(figureFolder, 'two-point-correlation-summary.fig');
WriteImage(figureFile, fig);
