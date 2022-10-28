function [shapeXSorted, shapeYSorted] = euclideanSortCoordinates(shapeX, shapeY)
% Sorts a list of XY scatter points into an order of nearest
% neighbours/shortest distance. Required to convert to polyshape properly
%
% Written by MA Savage 28102022, Adapted from 
% www.mathworks.com/matlabcentral/answers/383787-sort-coordinates-based-on-closest-connectivity
%
% Inputs: shapeX- vector of x coordinates for the boundary shape
%
%         shapeY- vector of y coordinates for the boundary shape

%% 
numPoints = length(shapeX);
% logical flag for all points
beenSorted = false(1, numPoints);
% Make an array to store the order in which we sort the points.
sortOrder = ones(1, numPoints);
% Define a filasafe
maxIterations = numPoints + 1;
iterationCount = 1;
% Sort each point, finding which unsorted point is closest.
% Define a current index.  currentIndex will be 1 to start and then will vary.
currentIndex = 1;
while sum(beenSorted) < numPoints && iterationCount < maxIterations
  % Indicate current point has been sorted.
  sortOrder(iterationCount) = currentIndex; 
  beenSorted(currentIndex) = true; 
  % Get the x and y of the current point.
  thisX = shapeX(currentIndex);
  thisY = shapeY(currentIndex);
  % Compute distances to all other points
  distances = sqrt((thisX - shapeX) .^ 2 + (thisY - shapeY) .^ 2);
  % Don't consider visited points by setting their distance to infinity.
  distances(beenSorted) = inf;
  % Also don't want to consider the distance of a point to itself, which is 0 and would alsoways be the minimum distances of course.
  distances(currentIndex) = inf;
  % Find the closest point.  this will be our next point.
  [~, indexOfClosest] = min(distances);
  % Save this index
  iterationCount = iterationCount + 1;
  % Set the current index equal to the index of the closest point.
  currentIndex = indexOfClosest;
end

shapeXSorted = shapeX(sortOrder);
shapeYSorted = shapeY(sortOrder);

end