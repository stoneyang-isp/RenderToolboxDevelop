%% Pick a random position bound by a given box.
% like [x y z] where x, y, z fall in given ranges.
function position = GetRandomPosition(xRange, yRange, zRange)
x = xRange(1) + (xRange(2) - xRange(1))*rand();
y = yRange(1) + (yRange(2) - yRange(1))*rand();
z = zRange(1) + (zRange(2) - zRange(1))*rand();

position = [x y z];
