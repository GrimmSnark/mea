function [wavePoly, waveShapeX, waveShapeY] = concaveBoundary(coorX, coorY,scaleFactor)
% Creates a concave boundar around cloud of points. Similar to the alpha
% hull alpha_shapes.R script by Stephen J. Eglen
%
% Written by MA Savage 28102022
%
% Inputs: coorX- vector of x coordinates for the cloud of points
%
%         coorY- vector of y coordinates for the cloud of points
%
%         scaleFactor- scaling factor for the depth of the curve
%                      0.1 seems to do a good job

%% create boundary
boundaryInd = boundary(coorX, coorY);
% plot(coorX(boundaryInd), coorY(boundaryInd), 'k');

% get coordinates for boundary
boundaryCoorsX = coorX(boundaryInd);
boundaryCoorsY = coorY(boundaryInd);

waveShapeX = [];
waveShapeY = [];

% run through the boundary points to creat arcs
for i =1:length(boundaryCoorsX)-1

    % get mid point
    midPoint = [(boundaryCoorsX(i) + boundaryCoorsX(i+1))/2 (boundaryCoorsY(i) + boundaryCoorsY(i+1))/2];
    %          scatter(midPoint(1), midPoint(2), 'b');
    %          hold on

    % get line distance
    distLine = pdist([boundaryCoorsY(i) boundaryCoorsX(i); boundaryCoorsY(i+1) boundaryCoorsX(i+1)]);
    distLine = distLine* scaleFactor;

    % line vector
    v = [boundaryCoorsX(i+1) boundaryCoorsY(i+1)] - [boundaryCoorsX(i) boundaryCoorsY(i)];
    v = v / norm(v);

    % curve apex (create point at midpoint of boundary line further into
    % the shape, used to be 3rd point of arc)
    curveApex = [midPoint(1)-(v(2)*distLine), midPoint(2)+(v(1)*distLine)];
    %     scatter(curveApex(1), curveApex(2), 'r');

    curveX = [boundaryCoorsX(i); curveApex(1); boundaryCoorsX(i+1)];
    curveY = [boundaryCoorsY(i); curveApex(2); boundaryCoorsY(i+1)];

    % fit curve
    [arcShapeX,  arcShapeY]= circleArcfit(curveX, curveY);

    %     plot(arcShapeX, arcShapeY);

    % add to waveShape
    waveShapeX = [waveShapeX arcShapeX];
    waveShapeY = [waveShapeY arcShapeY];
end

% sort the points by euclidean distance
[waveXSorted, waveYSorted] = euclideanSortCoordinates(waveShapeX, waveShapeY);

% create polygon from the wave boundaries
% NB we remove the last 6 point to stop a weird polygon line draw bug
removeNum = 10;
warning('off');
wavePoly = polyshape(waveXSorted(1:end-removeNum), waveYSorted(1:end-removeNum), 'Simplify', true); 
warning('on');
end