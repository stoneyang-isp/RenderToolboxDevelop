%% Locate, unpack, and execute many WardLand recipes created earlier.
%
% Use this script to render many archived recipes created earlier, using
% MakeManyWardLandRecipes.
%
% You can configure a few recipe parameters at the top of this script.
% The values will apply to all generated recipes.  For example, you can
% change the output image size here, when you execute the recipes.  You
% don't have to generate new recipes to change the image size.
%
% @ingroup WardLand

%% Overall Setup.
clear;
clc;

% location of packed-up recipes
projectName = 'WardLandDatabase';
recipeFolder = ...
    fullfile(getpref('VirtualScenes', 'recipesFolder'), projectName);
if ~exist(recipeFolder, 'dir')
    disp(['Recipe folder not found: ' recipeFolder]);
end

% edit some batch renderer options
hints.renderer = 'Mitsuba';
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');
hints.imageWidth = 640 / 2;
hints.imageHeight = 480 / 2;

% leave out the mask renderings
hints.whichConditions = 1:3;

% analysis params
toneMapFactor = 10;
isScale = true;
filterWidth = 7;
lmsSensitivities = 'T_cones_ss2';
dklSensitivities = 'T_CIE_Y21';

diagonal = sqrt(hints.imageWidth*hints.imageWidth + hints.imageHeight*hints.imageHeight);
binEdges = 0:5:diagonal/2;
samplesPerBin = 1000;


%% Choose basic execution.
executive = { ...
    @MakeRecipeSceneFiles, ...
    @MakeRecipeRenderings, ...
    @(recipe)MakeRecipeRGBImages(recipe, toneMapFactor, isScale), ...
    };

%% Locate and render each packed-up recipe.
archiveFiles = FindFiles(recipeFolder, '\.zip$');
nScenes = numel(archiveFiles);
recipes = cell(1, nScenes);
for ii = 1:2%nScenes
    recipes{ii} = UnpackRecipe(archiveFiles{ii}, hints);
    recipes{ii}.input.hints.renderer = hints.renderer;
    recipes{ii}.input.hints.workingFolder = hints.workingFolder;
    recipes{ii}.input.hints.imageWidth = hints.imageWidth;
    recipes{ii}.input.hints.imageHeight = hints.imageHeight;
    recipes{ii}.input.hints.whichConditions = hints.whichConditions;
    recipes{ii}.input.executive = executive;
    recipes{ii} = ExecuteRecipe(recipes{ii});
end

%% Analyze renderings for each recipe.
for ii = 1:2%nScenes
    ChangeToWorkingFolder(recipes{ii}.input.hints);
    
    recipes{ii} = MakeRecipeAlbedoFactoidImages(recipes{ii}, toneMapFactor, isScale);
    recipes{ii} = MakeRecipeShapeIndexFactoidImages(recipes{ii});
    
    recipes{ii} = MakeRecipeIlluminationImages(recipes{ii}, filterWidth, toneMapFactor, isScale);
    recipes{ii} = MakeRecipeBoringComparison(recipes{ii}, toneMapFactor, isScale);
    
    recipes{ii} = MakeRecipeLMSImages(recipes{ii}, lmsSensitivities);
    recipes{ii} = MakeRecipeDKLImages(recipes{ii}, lmsSensitivities);
    
    recipes{ii} = MakeRecipeImageMontage(recipes{ii});
end

%% Summarize renderings.
for ii = 1:2%nScenes
    figure();
    set(gcf(), 'Position', [100 100 1000 1000]);
    
    subplot(3,3,1);
    imshow(LoadRecipeProcessingImageFile(recipes{ii}, 'radiance', 'SRGBWard'));
    title('ward srgb')
    drawnow();
    
    subplot(3,3,2);
    XYZ = LoadRecipeProcessingImageFile(recipes{ii}, 'radiance', 'SRGBWard');
    Y = XYZ(:,:,2);
    imshow(Y);
    title('ward Y')
    drawnow();
    
    subplot(3,3,3);
    hist(double(Y(:)));
    title('hist of ward Y')
    drawnow();
    
    subplot(3,3,4);
    LMS = LoadRecipeProcessingImageFile(recipes{ii}, 'lms', 'radiance_ward_lms');
    L = LMS(:,:,1);
    M = LMS(:,:,2);
    S = LMS(:,:,3);
    LxL = TwoPointCorrelationDistribution(L, L, binEdges, samplesPerBin);
    plot(binEdges(2:end), LxL);
    title('L x L')
    ylim([-0.2 1])
    drawnow();
    
    subplot(3,3,5);
    LxS = TwoPointCorrelationDistribution(L, S, binEdges, samplesPerBin);
    plot(binEdges(2:end), LxS);
    title('L x S')
    ylim([-0.2 1])
    drawnow();
    
    subplot(3,3,6);
    SxS = TwoPointCorrelationDistribution(S, S, binEdges, samplesPerBin);
    plot(binEdges(2:end), SxS);
    title('S x S')
    ylim([-0.2 1])
    drawnow();
    
    subplot(3,3,7);
    LxM = TwoPointCorrelationDistribution(L, M, binEdges, samplesPerBin);
    plot(binEdges(2:end), LxM);
    title('L x M')
    ylim([-0.2 1])
    drawnow();
    
    subplot(3,3,8);
    MxM = TwoPointCorrelationDistribution(M, M, binEdges, samplesPerBin);
    plot(binEdges(2:end), MxM);
    title('M x M')
    ylim([-0.2 1])
    drawnow();
    
    subplot(3,3,9);
    MxS = TwoPointCorrelationDistribution(M, S, binEdges, samplesPerBin);
    plot(binEdges(2:end), MxS);
    title('M x S')
    ylim([-0.2 1])
    drawnow();
end