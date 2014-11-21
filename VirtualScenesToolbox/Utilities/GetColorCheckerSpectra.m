%% Get a list of ColorChecker spectra files.
%   whichSquares optional indices in 1:24 to choose which spectra
function spectra = GetColorCheckerSpectra(whichSquares)

if nargin < 1 || isempty(whichSquares)
    whichSquares = 1:24;
end

% locate the data files
spectrumFolder = fullfile( ...
    RenderToolboxRoot(), 'RenderData', 'Macbeth-ColorChecker');
spectrumFiles = FindFiles(spectrumFolder, 'mccBabel-\d+.spd');
nSquares = numel(spectrumFiles);
spectra = cell(1, nSquares);
squareNumber = zeros(1, nSquares);
for ii = 1:numel(spectrumFiles)
    [absPath, nameBase, nameExt] = fileparts(spectrumFiles{ii});
    spectra{ii} = [nameBase, nameExt];
    squareNumber(ii) = sscanf(nameBase(10:end), '%f');
end

% sort them by square number
spectra(squareNumber) = spectra;

% choose specific squares
spectra = spectra(whichSquares);
