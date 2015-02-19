%% Make up some illuminant spectra.
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Generates descriptions of area light sources, with various arbitrary
% spectra.
%
% @details
% Writes any necessary spectrum definition spm-files to the working
% "resources" folder as indicated by hints.workingFolder. See
% GetWorkingFolder().
%
% @details
% Returns a cell array of area light descriptions, as from
% BuildDesription().
%
% @details
% Usage:
%   spectra = GetWardLandIlluminantSpectra(hints)
%
% @ingroup WardLand
function spectra = GetWardLandIlluminantSpectra(hints)

if nargin < 1
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

% write out some spectrum files
resources = GetWorkingFolder('resources', false, hints);

% a plain white light
whiteArea = BuildDesription('light', 'area', ...
    {'intensity'}, ...
    {'300:1 800:1'}, ...
    {'spectrum'});

% a yellow sun light
load B_cieday
scale = 1.1;
spd = GenerateCIEDay(4000, B_cieday);
spd = scale * spd ./ max(spd);
wls = SToWls(S_cieday);
WriteSpectrumFile(wls, spd, fullfile(resources, 'Sun.spd'));
sunArea = BuildDesription('light', 'area', ...
    {'intensity'}, ...
    {'Sun.spd'}, ...
    {'spectrum'});

% a blue sky light
spd = GenerateCIEDay(20000, B_cieday);
spd = scale * spd ./ max(spd);
wls = SToWls(S_cieday);
WriteSpectrumFile(wls, spd, fullfile(resources, 'Sky.spd'));
skyArea = BuildDesription('light', 'area', ...
    {'intensity'}, ...
    {'Sky.spd'}, ...
    {'spectrum'});

spectra = {whiteArea, sunArea, skyArea};
