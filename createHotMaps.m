function createHotMaps(datFile)
% Function creates hotmaps and outlines retinal waves. Basically a
% translation of the alpha_shapes.R script by Stephen J. Eglen
%
% Written by MA Savage 28102022
%
% Inputs: datFile- fullfile to the data file to process, can be a
%                  _waveEx.mat or a hotMaps.mat file
%

%% load file
if contains(datFile,'hotMaps')
    load(datFile);
    overallHotMap2 = fliplr(overallHotMap); % flip needed to match existing figures?? 
    indxOverallHot = find(overallHotMap2);

elseif contains(datFile,'waveEx')
    load(datFile);
    overallHotMap2 = waveEx.hotMaps.overallHotMap;
    indxOverallHot = find(overallHotMap2);

end

%% get active electrode coordinates
[elecCoor(:,1), elecCoor(:,2)]  = ind2sub([64 64],indxOverallHot);

% create electrode colour mat
electrodeRGB = repmat([0.6 0.6 0.6], length(elecCoor),1);

% wave2Use = 54;
wave2Use = 11;

% active chans
if contains(datFile,'hotMaps')
    hotMap2Use = fliplr(hotMaps{wave2Use}); % flip needed to match existing figures?? 

elseif contains(datFile,'waveEx')
   hotMap2Use = waveEx.hotMaps.hotMaps{wave2Use};

end

% get active chan coordinates and RGB matrix
indxhotMap2Use = find(hotMap2Use);
[elecCoorWave(:,1), elecCoorWave(:,2)]  = ind2sub([64 64],indxhotMap2Use);
electrodeActiveRGB = repmat([0 1 0], length(elecCoorWave),1);

%% Figure creation

figH = figure();
figH.WindowState = 'maximized';
hold on

% draw MEA box
rectangle("Position",[0 1 64 64], "LineStyle","--");

% style axis
axis square
ylim([-1 65]);
xlim([-1 65]);

% get concave wave boundary (basically better alpha hull)
wavePoly  = concaveBoundary(elecCoorWave(:,1), elecCoorWave(:,2), 0.1);

% get the area of the polygon
ployA = polyarea(wavePoly.Vertices(:,1), wavePoly.Vertices(:,2));

%% plotting 

% plot the wave
plot(wavePoly, "LineWidth",2.5, "EdgeColor", 'k','FaceColor','none');

% plot electrode dots
% get which electrodes are inside the wave
inWaveFlag = find(inpolygon(elecCoor(:,1),elecCoor(:,2),wavePoly.Vertices(:,1), wavePoly.Vertices(:,2)));

% set them to black
electrodeRGB(inWaveFlag,:) = repmat([0 0 0], length(inWaveFlag),1);

% plot all the electrode
scatter(elecCoor(:,1),elecCoor(:,2),[] ,electrodeRGB, "filled");


% plot active electode dots
scatter(elecCoorWave(:,1),elecCoorWave(:,2),[] ,electrodeActiveRGB, "filled");

% add the title info
title(sprintf('W %i: d = %i/%i = %.2f; a = %4.1f', wave2Use, length(indxhotMap2Use), ...
    length(inWaveFlag) , length(indxhotMap2Use)/length(inWaveFlag), ployA ));

%% saving 
end

