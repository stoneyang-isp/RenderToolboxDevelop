%% Build a parameter sweep with interpolated vector elements.
%   sweepName name for output images
%   vectorA starting vector
%   vectorB ending vector
%   nSteps how many steps in the sweep
function [vectors, imageNames, lambdas] = BuildVectorSweep(sweepName, vectorA, vectorB, nSteps)

% read in the original vectors
magsA = StringToVector(vectorA);
magsB = StringToVector(vectorB);

% compute several interpolated vectors
lambdas = linspace(0, 1, nSteps);
vectors = cell(nSteps, 1);
imageNames = cell(nSteps, 1);
for ii = 1:nSteps
    imageNames{ii} = sprintf('%s-%02d', sweepName, ii);
    interpMags = lambdas(ii) .* magsB + (1-lambdas(ii)) .* magsA;
    vectors{ii} = VectorToString(interpMags);
end
