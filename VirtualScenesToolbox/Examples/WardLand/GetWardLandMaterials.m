%% Make up some matte and Ward material descriptions.
%   hints struct of RenderToolbox3 options
function [matteMaterials, wardMaterials, filePaths] = GetWardLandMaterials(hints)

% use color checker diffuse spectra
[colorCheckerSpectra, filePaths] = GetColorCheckerSpectra();
nSpectra = numel(colorCheckerSpectra);

% use arbitrary specular spectra
specShort = linspace(0, 0.5, nSpectra);
specLong = linspace(0.5, 0, nSpectra);

% build material descriptions and copy resource files
matteMaterials = cell(1, nSpectra);
wardMaterials = cell(1, nSpectra);
resources = GetWorkingFolder('resources', false, hints);
for ii = 1:nSpectra
    % matte materail
    matteMaterials{ii} = BuildDesription('material', 'matte', ...
        {'diffuseReflectance'}, ...
        colorCheckerSpectra(ii), ...
        {'spectrum'});
    
    % ward material
    specularSpectrum = sprintf('300:%.1f 800:%.1f', ...
        specShort(ii), specLong(ii));
    wardMaterials{ii} = BuildDesription('material', 'anisoward', ...
        {'diffuseReflectance', 'specularReflectance'}, ...
        {colorCheckerSpectra{ii}, specularSpectrum}, ...
        {'spectrum', 'spectrum'});
    
    % resource file
    copyfile(filePaths{ii}, resources);
end

