function [plotX, plotY, xCenter, yCenter, radius, a] = circleArcfit(x, y)
% Fits a circle through a set of points in the x - y plane and limits it to
% an arc which transits through the start and end point.
%
% Written by MA Savage 28102022, Adapted from algorithm by Bucher Izhak 
% 25 - Oct - 1991
%
% Inputs: x- vector of x locations to fit, usually 3 points
%
%         y- vector of y locations to fit, usually 3 points
%
% Outputs: plotX- the interpolated plot x line for the arc 
%
%          plotY- the interpolated plot y line for the arc 
%
%          xCenter- the x center of the circle
%
%          yCenter- the y center of the circle
%
%          radius- the radius of the circle
%
%          a- the coeffients of the circle equation
%             x ^ 2 + y ^ 2 + a(1) * x + a(2) * y + a(3) = 0
% USAGE :
% [plotX, plotY, xCenter, yCenter, radius, a] = circlefit(X, Y)

%% fit the circle
numPoints = numel(x);
xx = x .* x;
yy = y .* y;
xy = x .* y;
A = [sum(x),  sum(y),  numPoints;
    sum(xy), sum(yy), sum(y);
    sum(xx), sum(xy), sum(x)];
B = [-sum(xx + yy) ;
    -sum(xx .* y + yy .* y);
    -sum(xx .* x + xy .* y)];
a = A \ B;
xCenter = -.5 * a(1);
yCenter = -.5 * a(2);
radius  =  sqrt((a(1) ^ 2 + a(2) ^ 2) / 4 - a(3));

%% calculate the circle
% Define the angle theta as going from 0 to 360 degrees in 100 steps.
theta = linspace(0, 360, 1000);
% Define x and y using "Degrees" version of sin and cos.
x2 = radius * cosd(theta) + xCenter;
y2 = radius * sind(theta) + yCenter;

%% limit the circle to the arc required

% find the closest start and stop points to the arc start and stop
[dStart] = pdist2([x(1) y(1)], [x2' y2']);
[dStop] = pdist2([x(end) y(end)], [x2' y2']);

[~, startIn] = min(dStart);
[~, stopIn] = min(dStop);

% limit to the arc required
plotX= ([x2(stopIn:startIn)]);
plotY= ([y2(stopIn:startIn)]);
% plotX= ([x(end) x2(stopIn:startIn) x(1)]);
% plotY= ([y(end) y2(stopIn:startIn) y(1)]);


% if the line is not feasible in that direction, try reversing
if isempty(plotX)
    plotX= ([x2(stopIn:end) x2(1:startIn)]);
    plotY= ([y2(stopIn:end) y2(1:startIn)]);
%     plotX= ([x(end) x2(stopIn:end) x2(1:startIn) x(1)]);
%     plotY= ([x(end) y2(stopIn:end) y2(1:startIn) x(1)]);


    %     plot(plotX, plotY, 'b-', 'LineWidth', 2.5);
else
    %      plot(plotX, plotY, 'b-', 'LineWidth', 2.5);
end
end