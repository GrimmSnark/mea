function createHotMaps(datFile, wave2Use)
% Function creates hotmaps and outlines retinal waves. Basically a
% translation of the alpha_shapes.R script by Stephen J. Eglen
%
% Written by MA Savage 28102022
%
% Inputs: datFile- fullfile to the data file to process, can be a
%                  _waveEx.mat or a hotMaps.mat file
%

%% defaults

if nargin < 2 || isempty(wave2Use)
    wave2Use = [];
end

%% load file

[path, name, ext] = fileparts(datFile);
filepathStruct = fullfile(path,name); % filename for save structure

if contains(datFile,'hotMaps')
    load(datFile);
    overallHotMap2 = fliplr(overallHotMap); % flip needed to match existing figures?? 
    indxOverallHot = find(overallHotMap2);

    % root filepath for saving figures
    rootFilepathInd = strfind(filepathStruct, '_hotMaps');
elseif contains(datFile,'waveEx')
    load(datFile);
    overallHotMap2 = waveEx.hotMaps.overallHotMap;
    indxOverallHot = find(overallHotMap2);

    rootFilepathInd = strfind(filepathStruct, '_wave');
end

% get the root file name
rootFilepath = datFile(1:rootFilepathInd-1);


%% Run through all the waves

% get hotmaps
if contains(datFile,'hotMaps')
    hotMaps = cellfun(@(x) fliplr(x), hotMaps, 'UniformOutput',false ); % flip needed to match existing figures??
elseif contains(datFile,'waveEx')
   hotMaps = waveEx.hotMaps.hotMaps;
end

if isempty(wave2Use)
    hotMaps2Plot = 1:length(hotMaps);
    plottingAll = 1;
elseif isnumeric(wave2Use)
    hotMaps2Plot = wave2Use;
    plottingAll = 0;
end

%% get the hotmap stats for excel
for xx = 1:length(hotMaps)

    % get active electrode coordinates
    [elecCoor(:,1), elecCoor(:,2)]  = ind2sub([64 64],indxOverallHot);

    currentHotmap = hotMaps{xx};

    % get active chan coordinates
    indxhotMap2Use = find(currentHotmap);
    [elecCoorWave{xx}(:,1), elecCoorWave{xx}(:,2)]  = ind2sub([64 64],indxhotMap2Use);

    % get wave polygon
    wavePoly{xx}  = concaveBoundary(elecCoorWave{xx}(:,1), elecCoorWave{xx}(:,2), 0.1);

    % get area
    ployA = area(wavePoly{xx});

    inWaveFlag{xx} = find(inpolygon(elecCoor(:,1),elecCoor(:,2),wavePoly{xx}.Vertices(:,1), wavePoly{xx}.Vertices(:,2)));

    % fill table
    wave(xx) = xx;	
    areaPoly(xx) = 	ployA;
    n.active(xx) = length(indxhotMap2Use);	
    n.inside(xx) = length(inWaveFlag{xx});	
    density(xx) = n.active(xx)/n.inside(xx);
end

% create table 
statsTab = table(wave',areaPoly', n.active', n.inside', density' );

% save table
writetable(statsTab, [rootFilepath,'_hotMaps_alphaMS.csv'] )

%% plotting

numFigs = ceil(length(hotMaps2Plot)/6);
% get subplot index for each session
waveSubIn = reshape(1:numFigs*6, 6,[] );
waveSubIn(waveSubIn > length(hotMaps2Plot)) = 0;

figCount = waveSubIn(1,:);
figCurr = 1;
for qq = hotMaps2Plot

    % deal with figure creation
    if sum(figCount==qq) > 0
        figH(figCurr) =  figure('units','normalized','outerposition',[0 0 0.5 1]);
        tiledlayout(figH(figCurr),3,2, "Padding","tight", TileSpacing="tight");
        figCurr = figCurr+1;
        
    end

% create electrode colour mat
electrodeRGB = repmat([0.6 0.6 0.6], length(elecCoor),1);

% active chans
electrodeActiveRGB = repmat([0 1 0], length(elecCoorWave{qq}),1);

nexttile

% draw MEA box
rectangle("Position",[0 1 64 64], "LineStyle","--");

% style axis
axis square
ylim([-1 65]);
xlim([-1 65]);
hold on

%% plotting 
pointSize = 5;

% plot the wave
plot(wavePoly{qq}, "LineWidth",2.5, "EdgeColor", 'k','FaceColor','none');

% set in wave electrodes to black
electrodeRGB(inWaveFlag{qq},:) = repmat([0 0 0], length(inWaveFlag{qq}),1);

% plot all the electrode
scatter(elecCoor(:,1),elecCoor(:,2),pointSize ,electrodeRGB, "filled");


% plot active electode dots
scatter(elecCoorWave{qq}(:,1), elecCoorWave{qq}(:,2),pointSize ,electrodeActiveRGB, "filled");

% add the title info
title(sprintf('W %i: d = %i/%i = %.2f; a = %4.1f', qq, n.active(qq), ...
    n.inside(qq) , density(qq), areaPoly(qq) ));

end

%% saving 
exportgraphics(figH(1),[rootFilepath,'_hotMaps_alphaMS.pdf'], "Resolution",300, 'ContentType','vector');

% try using the new version to make multipage pdf files
try
    for cc = 2:numFigs
        exportgraphics(figH(cc),[rootFilepath,'_hotMaps_alphaMS.pdf'], "Resolution",300, 'ContentType','vector', "Append", true);
    end
catch  % use old version of pdf appending
    
    fileNames{1} = [rootFilepath,'_hotMaps_alphaMS.pdf'];
    for cc = 2:numFigs
        exportgraphics(figH(cc),[rootFilepath,'_hotMaps_alphaMS_' num2str(cc) '.pdf'], "Resolution",300, 'ContentType','vector');
        fileNames{cc} = [rootFilepath,'_hotMaps_alphaMS_' num2str(cc) '.pdf'];
    end

    mergePdfs(fileNames,  [rootFilepath,'_hotMaps_alphaMS.pdf']);
    delete(fileNames{2:end});
end

end
