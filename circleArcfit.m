function [plotX, plotY, xCenter, yCenter, radius, a] = circleArcfit(x, y)
% circlefit(): Fits a circle through a set of points in the x - y plane.
% USAGE :
% [xCenter, yCenter, radius, a] = circlefit(X, Y)
% The output is the center point (xCenter, yCenter) and the radius of the fitted circle.
% "a" is an optional output vector describing the coefficients in the circle's equation:
%     x ^ 2 + y ^ 2 + a(1) * x + a(2) * y + a(3) = 0
% by Bucher Izhak 25 - Oct - 1991

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

% Define the angle theta as going from 0 to 360 degrees in 100 steps.
theta = linspace(0, 360, 1000);
% Define x and y using "Degrees" version of sin and cos.
x2 = radius * cosd(theta) + xCenter;
y2 = radius * sind(theta) + yCenter;

[dStart] = pdist2([x(1) y(1)], [x2' y2']);
[dStop] = pdist2([x(end) y(end)], [x2' y2']);

[~, startIn] = min(dStart);
[~, stopIn] = min(dStop);


plotX= ([ x2(stopIn:startIn)]);
plotY= ([y2(stopIn:startIn)]);


if length(plotX) < 3
     plotX= ([ x2(stopIn:end) x2(1:startIn)]);
     plotY= ([y2(stopIn:end) y2(1:startIn)]);

%     plot(plotX, plotY, 'b-', 'LineWidth', 2.5);
else
%      plot(plotX, plotY, 'b-', 'LineWidth', 2.5);
end
end