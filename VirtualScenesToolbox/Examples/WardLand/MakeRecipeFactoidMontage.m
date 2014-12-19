%% Assemble processed factoids into a handy montage.
%   recipe should be a recipe from BuildWardLandRecipe()
%   scaleFactor should be a scalar for the montage size (could be large)
%   scaleMethod should be a filtering method like (box)
function recipe = MakeRecipeFactoidMontage(recipe, scaleFactor, scaleMethod)

if nargin < 2 || isempty(scaleFactor)
    scaleFactor = getpref('VirtualScenes', 'montageScaleFactor');
end

if nargin < 3 || isempty(scaleMethod)
    scaleMethod = getpref('VirtualScenes', 'montageScaleMethod');
end

if isempty(recipe.processing.factoids)
    disp('No factoids found, not making factoids montage.');
    return;
end

% organize factoid data and names into a grid
images = cell(3, 3);
names = cell(3, 3);
factoidNames = fieldnames(recipe.processing.factoids.factoidOutput);
nFactoids = numel(factoidNames);
for ii = 1:nFactoids
    name = factoidNames{ii};
    data = recipe.processing.factoids.factoidOutput.(name);
    images{ii} = 255 * data ./ max(data(:));
    names{ii} = name;
end

% write out a big montage
imageFolder = GetWorkingFolder('images', true, recipe.input.hints);
recipe.processing.montage = MakeImageMontage( ...
    fullfile(imageFolder, 'factoids.png'), images, names, scaleFactor, scaleMethod);
