%% Use an RGB build of Mitsuba to record recipe scene factoids.
%   @param recipe a recipe from BuildWardLandRecipe()
%
% @details
% Uses an RGB build of the Mitsuba renderer to compute recipe "factoids"
% about the given WardLand @a recipe.  See RenderMitsubaFactoids().
%
% @details
% Returns the given @a recipe, updated with new factoids:
%   - recipe.processing.factoids will contain a struct of Mitsuba factoids
%   from RenderMitsubaFactoids()
%   .
% @details
% Usage:
%   recipe = MakeRecipeFactoids(recipe)
%
% @ingroup WardLand
function recipe = MakeRecipeFactoids(recipe)

recipe.processing.factoids = [];

if ~strcmp(recipe.input.hints.renderer, 'Mitsuba')
    return;
end

% invoke RGB mitsuba to gather scene factoids under each pixel
[f.status, f.result, f.newScene, f.exrOutput, f.factoidOutput] = ...
    RenderMitsubaFactoids( ...
    recipe.rendering.scenes{1}.mitsubaFile, ...
    '', '', {}, 'rgb', ...
    recipe.input.hints);

recipe.processing.factoids = f;
