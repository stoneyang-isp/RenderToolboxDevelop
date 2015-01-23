% Modify a MatchRMSE recipe to sweep over a named parameter.
%   recipe - a recipe from BuildMatchRMSERecipe()
%   sweepName - name for the new conditions file
%   paramName - name of a broken-out parameters from BuildMatchRMSERecipe()
%   paramValues - cell array of values to use for paramName
%   imageNames - cell array of output image names, same size as paramValues
function recipe = BuildSweepConditions(recipe, sweepName, paramName, paramValues, imageNames)

% get the original parameter names and values
working = GetWorkingFolder('', false, recipe.input.hints);
conditionsFile = ResolveFilePath(recipe.input.conditionsFile, working);
[varNames, varValues] = ParseConditions(conditionsFile.absolutePath);

% make a row for each value in paramValues
nSteps = numel(paramValues);
newValues = repmat(varValues, nSteps, 1);

% insert the new paramValues and imageNames
isParam = strcmp(varNames, paramName);
newValues(:,isParam) = paramValues;

isImageName = strcmp(varNames, 'imageName');
newValues(:,isImageName) = imageNames;

% write the new conditions file and wire it up
newConditionsFile = fullfile(working, [sweepName '-Conditions.txt']);
WriteConditionsFile(newConditionsFile, varNames, newValues);
recipe.input.conditionsFile = newConditionsFile;
