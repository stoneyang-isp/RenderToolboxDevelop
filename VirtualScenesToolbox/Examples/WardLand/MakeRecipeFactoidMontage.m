%% Assemble processed factoids into a handy montage.
%   @param recipe a recipe from BuildWardLandRecipe()
%   @param scaleFactor should be a scalar for the montage size (could be large)
%   @param scaleMethod should be a filtering method like (box)
%
% @details
% Assembles Mitsuba "factoid" data into a single, large summary montage.
% See RenderMitsubaFactoids().  @a scaleFactor and @a scaleMethod can be
% used to scale the resulting montage.  See MakeImageMontage().
%
% @details
% Returns the given @a recipe, updated with a new factoid montage:
%   - recipe.processing.montage will contain the file name of a new montage
%   of Mitsuba factoid images.
%   .
% @details
% Usage:
%   recipe = MakeRecipeFactoidMontage(recipe, scaleFactor, scaleMethod)
%
% @ingroup WardLand
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
    factoid = recipe.processing.factoids.factoidOutput.(name);
    
    names{ii} = name;
    
    % assume factoid channels B, G, R, flip to RGB
    rgbData = 255 * factoid.data ./ max(factoid.data(:));
    images{ii} = flip(rgbData, 3);
end

% write out a big montage
imageFolder = GetWorkingFolder('images', true, recipe.input.hints);
recipe.processing.montage = MakeImageMontage( ...
    fullfile(imageFolder, 'factoids.png'), images, names, scaleFactor, scaleMethod);
