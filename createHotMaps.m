function createHotMaps()
% 
load('C:\PostDoc_Docs\code\R\R code alpha shapes for ps graphic output\P4_14Jun11_spont_ctl__hotMaps.mat');
overallHotMap2 = fliplr (overallHotMap);
indxOverallHot = find(overallHotMap2);

% load('C:\Data\mouse\mea\testData\P4_20Feb19\test2\P4_ret1_20Feb19_waveEx.mat');
% overallHotMap2 = waveEx.hotMaps.overallHotMap;
% indxOverallHot = find(overallHotMap2);
% 

[elecCoor(:,1), elecCoor(:,2)]  = ind2sub([64 64],indxOverallHot);

% electrode colours
electrodeRGB = repmat([0.6 0.6 0.6], length(elecCoor),1);

% wave2Use = 54;
wave2Use = 11;

% active chans
hotMap2Use = fliplr(hotMaps{wave2Use});
% hotMap2Use = waveEx.hotMaps.hotMaps{wave2Use};

% get active chans
indxhotMap2Use = find(hotMap2Use);
[elecCoorWave(:,1), elecCoorWave(:,2)]  = ind2sub([64 64],indxhotMap2Use);
electrodeActiveRGB = repmat([0 1 0], length(elecCoorWave),1);

% draw MEA box
rectangle("Position",[0 1 64 64], "LineStyle","--");
hold on
axis square
ylim([-1 65]);
xlim([-1 65]);

% get wave boundary
[waveShapeX, waveShapeY, wavePoly] = concaveBoundary(elecCoorWave(:,1), elecCoorWave(:,2), 0.1);
ployA = polyarea(wavePoly.Vertices(:,1), wavePoly.Vertices(:,2));

plot(wavePoly, "LineWidth",2.5, "EdgeColor", 'k','FaceColor','none');

% plot electrode dots
inWaveFlag = find(inpolygon(elecCoor(:,1),elecCoor(:,2),wavePoly.Vertices(:,1), wavePoly.Vertices(:,2)));
electrodeRGB(inWaveFlag,:) = repmat([0 0 0], length(inWaveFlag),1);
scatter(elecCoor(:,1),elecCoor(:,2),[] ,electrodeRGB, "filled"); 


% plot active electode dots
scatter(elecCoorWave(:,1),elecCoorWave(:,2),[] ,electrodeActiveRGB, "filled"); 

% title(['W ' num2str(wave2Use) ' d = ' num2str(length(indxhotMap2Use)) '/' num2str(length(inWaveFlag)) ' = '  num2str(length(indxhotMap2Use)/length(inWaveFlag)) ';' ' a= ' num2str(ployA)])
title(sprintf(['W %i: d = %i/%i = %.2f; a = %4.1f'], wave2Use, length(indxhotMap2Use), length(inWaveFlag) , length(indxhotMap2Use)/length(inWaveFlag), ployA ));
end

