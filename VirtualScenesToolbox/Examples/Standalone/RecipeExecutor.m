%% Render Recipes as a standalone Matlab executable.
%   @param recipeFile packed-up recipe archive from PackUpRecipe()
%   @param whichExecutives passed to ExecuteRecipe()
%   @param beforeScript optional script to run before executing recipe
%   @param afterScript optional script to run after executing recipe
%
% @details
% Expects 1-3 parameters from the command line.  These should all be file
% names that can be found from the current directly.  If @a beforeScript is
% found, it's executed first.  Then the given @a recipeFile is unarchived
% and executed.  Then, if @a afterScript is found, it's executed.  Will
% attempt to execute @a afterScript even if there's an error during recipe
% execution.
%
% @details
% Something we would like to solve: recipes invoke "random" functions
% specified in their "executive" cell array via feval().  For this to work,
% we need to tell MCC about them explicitly ("%#function" pragma or command
% args).  We can add a bunch of "best guess" pragmas here.  Can we find a
% way to incorporate "random" user functions without having to build a
% separate standalone for each recipe?
%
% @details
% Usage as a regular function in Matlab:
%   function RecipeExecutor(recipeFile, whichExecutives, beforeScript, afterScript)
%
% Usage as a standalone on the command line:
%   ./run_RecipeExecutor.sh/Applications/MATLAB/MATLAB_Compiler_Runtime/v84 recipeFile [whichExecutives] [beforeScript] [afterScript]
%
function RecipeExecutor(recipeFile, whichExecutives, beforeScript, afterScript)

%% Include these functions.

% batch renderer
%#function MakeRecipeRenderings, MakeRecipeSceneFiles

% renderer plugins
%#function RTB_VersionInfo_PBRT, RTB_Render_PBRT, RTB_ImportCollada_PBRT, RTB_DataToRadiance_PBRT, RTB_ApplyMappings_PBRT
%#function RTB_VersionInfo_Mitsuba, RTB_Render_Mitsuba, RTB_ImportCollada_Mitsuba, RTB_DataToRadiance_Mitsuba, RTB_ApplyMappings_Mitsuba
%#function RTB_VersionInfo_SampleRenderer, RTB_Render_SampleRenderer, RTB_ImportCollada_SampleRenderer, RTB_DataToRadiance_SampleRenderer, RTB_ApplyMappings_SampleRenderer

% remodeler plugins
%#function RTB_BeforeAll_SampleRemodeler, RTB_AfterCondition_SampleRemodeler, RTB_BeforeCondition_SampleRemodeler
%#function RTB_BeforeAll_MaterialSphere, RTB_BeforeCondition_MaterialSphere
%#function RTB_BeforeCondition_InsertObjectRemodeler

if nargin < 1 || isempty(recipeFile)
    recipeFile = '';
end

if nargin < 2 || isempty(whichExecutives)
    whichExecutives = [];
end
if ischar(whichExecutives)
    whichExecutives = eval(whichExecutives);
end

if nargin < 3 || isempty(beforeScript)
    beforeScript = '';
end

if nargin < 4 || isempty(afterScript)
    afterScript = '';
end

if ~exist(recipeFile, 'file')
    error('RecipeExecutor:NoSuchRecipe', ...
        'recipeFile not found: %s', recipeFile);
end

% Get the Recipe.
recipe = UnpackRecipe(recipeFile);

% Set Up.
if exist(beforeScript, 'file')
    run(beforeScript);
end

% Execute the Recipe.
recipe = ExecuteRecipe(recipe, whichExecutives, false);

% Tear Down.
if exist(afterScript, 'file')
    run(afterScript);
end