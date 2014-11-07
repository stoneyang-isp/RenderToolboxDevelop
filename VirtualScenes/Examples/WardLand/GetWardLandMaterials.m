%% Make up some matte and Ward material descriptions.
%   hints struct of RenderToolbox3 options
function [matteMaterials, wardMaterials] = GetWardLandMaterials(hints)

% use color checker diffuse spectra
colorCheckerSpectra = GetColorCheckerSpectra();
nSpectra = numel(colorCheckerSpectra);

% use arbitrary specular spectra
specShort = linspace(0, 0.5, nSpectra);
specLong = linspace(0.5, 0, nSpectra);

% build material descriptions
matteMaterials = cell(1, nSpectra);
wardMaterials = cell(1, nSpectra);
for ii = 1:nSpectra
    matteMaterials{ii} = BuildDesription('material', 'matte', ...
        {'diffuseReflectance'}, ...
        colorCheckerSpectra(ii), ...
        {'spectrum'});
    
    specularSpectrum = sprintf('300:%.1f 800:%.1f', ...
        specShort(ii), specLong(ii));
    wardMaterials{ii} = BuildDesription('material', 'anisoward', ...
        {'diffuseReflectance', 'specularReflectance'}, ...
        {colorCheckerSpectra{ii}, specularSpectrum}, ...
        {'spectrum', 'spectrum'});
end
