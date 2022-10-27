function [waveShapeX, waveShapeY, wavePoly] = concaveBoundary(coorX, coorY,scaleFactor)

boundaryInd = boundary(coorX, coorY);
% plot(coorX(boundaryInd), coorY(boundaryInd), 'k');

boundaryCoorsX = coorX(boundaryInd);
boundaryCoorsY = coorY(boundaryInd);

axis square
ylim([-1 65]);
xlim([-1 65]);

waveShapeX = [];
waveShapeY = [];
% run through the boundary points
for i =1:length(boundaryCoorsX)-1

    % get mid point
    midPoint = [(boundaryCoorsX(i) + boundaryCoorsX(i+1))/2 (boundaryCoorsY(i) + boundaryCoorsY(i+1))/2];
    %     scatter(midPoint(1), midPoint(2), 'b')

    % get line distance
    distLine = pdist([boundaryCoorsY(i) boundaryCoorsX(i); boundaryCoorsY(i+1) boundaryCoorsX(i+1)]);
    distLine = distLine* scaleFactor;

    % line vector
    v = [boundaryCoorsX(i+1) boundaryCoorsY(i+1)] - [boundaryCoorsX(i) boundaryCoorsY(i)];
    v = v / norm(v);

    % curve apex
    curveApex = [midPoint(1)-(v(2)*distLine), midPoint(2)+(v(1)*distLine)];
    %     scatter(curveApex(1), curveApex(2), 'r');

    % fit curve
    [arcShapeX,  arcShapeY]= circleArcfit([boundaryCoorsX(i) ;...
        curveApex(1);...
        boundaryCoorsX(i+1)], [boundaryCoorsY(i);...
        curveApex(2);...
        boundaryCoorsY(i+1)]);

    % add to waveShape
    waveShapeX = [waveShapeX arcShapeX];
    waveShapeY = [waveShapeY arcShapeY];


end

% [waveShapeX, indSort] = sort(waveShapeX);
% waveShapeY = waveShapeY(indSort);


numPoints = length(waveShapeX);
% Make a list of which points have been visited
beenVisited = false(1, numPoints);
% Make an array to store the order in which we visit the points.
visitationOrder = ones(1, numPoints);
% Define a filasafe
maxIterations = numPoints + 1;
iterationCount = 1;
% Visit each point, finding which unvisited point is closest.
% Define a current index.  currentIndex will be 1 to start and then will vary.
currentIndex = 1;
while sum(beenVisited) < numPoints && iterationCount < maxIterations
  % Indicate current point has been visited.
  visitationOrder(iterationCount) = currentIndex; 
  beenVisited(currentIndex) = true; 
  % Get the x and y of the current point.
  thisX = waveShapeX(currentIndex);
  thisY = waveShapeY(currentIndex);
  % Compute distances to all other points
  distances = sqrt((thisX - waveShapeX) .^ 2 + (thisY - waveShapeY) .^ 2);
  % Don't consider visited points by setting their distance to infinity.
  distances(beenVisited) = inf;
  % Also don't want to consider the distance of a point to itself, which is 0 and would alsoways be the minimum distances of course.
  distances(currentIndex) = inf;
  % Find the closest point.  this will be our next point.
  [minDistance, indexOfClosest] = min(distances);
  % Save this index
  iterationCount = iterationCount + 1;
  % Set the current index equal to the index of the closest point.
  currentIndex = indexOfClosest;
end

waveXSorted = waveShapeX(visitationOrder);
waveYSorted = waveShapeY(visitationOrder);

wavePoly = polyshape(waveXSorted(1:end-6), waveYSorted(1:end-6), 'Simplify', true);
% wavePoly = boundary(waveXSorted',waveYSorted');
% plot(wavePoly, "LineWidth",2.5, "EdgeColor", 'k','FaceColor','none');
% subplot(212)
% plot(waveXSorted(1:end-7), waveYSorted(1:end-7))

end