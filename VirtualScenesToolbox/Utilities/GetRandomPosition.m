%% Pick a random position between two bounding boxes.
% innerBound [xMin xMax; yMin yMax; zMin zMax]
% outerBound [xMin xMax; yMin yMax; zMin zMax], superset of innerBound
function position = GetRandomPosition(innerBound, outerBound)
x = randInDonut(innerBound(1,:), outerBound(1,:));
y = randInDonut(innerBound(2,:), outerBound(2,:));
z = randInDonut(innerBound(3,:), outerBound(3,:));
position = [x y z];

% uniform rand in donut region between inner and outer.
%   outer(1) inner(1) inner(2) outer(2)
function r = randInDonut(inner, outer)

% how wide is the space of possible outcomes?
outerSpan = outer(2) - outer(1);
innerSpan = inner(2) - inner(1);
randSpan = outerSpan - innerSpan;

% choose r in the space of outcomes
r = randSpan * rand();

% place r somewhere in outer range
r = r + outer(1);

% exclude r from inner range
if randSpan > inner(1)
    r = r + inner(2);
end
