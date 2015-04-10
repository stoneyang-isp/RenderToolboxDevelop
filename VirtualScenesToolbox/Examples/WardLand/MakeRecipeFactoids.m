%% Use an RGB build of Mitsuba to record recipe scene factoids.
%   @param recipe a recipe from BuildWardLandRecipe()
%
% @details
% Uses an RGB build of the Mitsuba renderer to compute recipe "factoids"
% about the given WardLand @a recipe.  See RenderMitsubaFactoids().
%
% @details
% Returns the given @a recipe, updated with new factoids in the "factoid"
% group.
%
% @details
% Usage:
%   recipe = MakeRecipeFactoids(recipe)
%
% @ingroup WardLand
function recipe = MakeRecipeFactoids(recipe)

if ~strcmp(recipe.input.hints.renderer, 'Mitsuba')
    return;
end

% invoke RGB mitsuba to gather scene factoids under each pixel
[status, result, newScene, exrOutput, factoidOutput] = ...
    RenderMitsubaFactoids( ...
    recipe.rendering.scenes{1}.mitsubaFile, ...
    '', '', {}, 'rgb', ...
    recipe.input.hints);

recipe = SetRecipeProcessingData(recipe, 'factoid', 'status', status);
recipe = SetRecipeProcessingData(recipe, 'factoid', 'result', result);
recipe = SetRecipeProcessingData(recipe, 'factoid', 'newScene', newScene);
recipe = SetRecipeProcessingData(recipe, 'factoid', 'exrOutput', exrOutput);
recipe = SetRecipeProcessingData(recipe, 'factoid', 'factoidOutput', factoidOutput);
