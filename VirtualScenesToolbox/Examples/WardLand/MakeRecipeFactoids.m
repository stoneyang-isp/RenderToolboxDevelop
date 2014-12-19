% Use an RGB build of Mitsuba to record recipe scene factoids.
%   recipe should be a recipe from BuildWardLandRecipe()
function recipe = MakeRecipeFactoids(recipe)

recipe.processing.factoids = [];

if ~strcmp(recipe.input.hints.renderer, 'Mitsuba')
    return;
end

% invoke RGB mitsuba to gather scene factoids under each pixel
[f.status, f.result, f.newScene, f.exrOutput, f.factoidOutput] = ...
    RenderMitsubaFactoids( ...
    recipe.rendering{1}.colladaFile, ...
    '', '', {}, ...
    recipe.input.hints);

recipe.processing.factoids = f;
