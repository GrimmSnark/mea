function data = processRetinaFlashStimDataFN1_V2(clusterFilepath)

%% defaults

zScoreLower = 3; % minimum z score limit for responsivity

prestimTimeZScore = 1; % sec
stimTimeZScore = 1.5; % sec

prestimTimePSTH = 0.5; % sec
postStimTimePSTH = 1; % sec

responseQualityThreshold = 0.35; 

%% get the appropriate paths for stim on and off triggers
filepathPrefix = extractBefore(clusterFilepath, '_cluster');
stimOnFile = [filepathPrefix{:} '_triggerON.npy'];
stimOffFile = [filepathPrefix{:} '_triggerOFF.npy'];


%% load data
matSavePath = extractBefore(clusterFilepath, '.');
matSavePath = [matSavePath{:} '.mat'];

if ~exist(matSavePath)
    data = readHS2_FLAME(clusterFilepath);
    save(matSavePath, "data", "-v7.3");
else
    load(matSavePath);
end

stimOnFrames = double(readNPY(stimOnFile));
stimOffFrames = double(readNPY(stimOffFile));

%% split on frames into blocks
blockLimit = 10 * data.Sampling; % 10s

diffOn = diff(stimOnFrames);

% first stim on
blockOnStarts = 1;

% block stim on starts
stimOnBreaks = [blockOnStarts; find(diffOn > blockLimit)+1];

% block stim on ends
stimOnStopBreaks = [ find(diffOn > blockLimit) ;length(diffOn)+1];


for i =1:length(stimOnBreaks)
    stimOnPerBlock{i,:} = stimOnFrames(stimOnBreaks(i):stimOnStopBreaks(i));
end

% % plotting for testing
% blockOnStarts = [stimOnFrames(stimOnBreaks)];
% blockOnEnds = [stimOnFrames(stimOnStopBreaks)];
% scatter(stimOnFrames, ones(length(stimOnFrames))*100);
% hold on
% scatter(blockOnStarts, repmat(100.5, 1, length(blockOnStarts)));
% scatter(blockOnEnds, repmat(100.5, 1, length(blockOnEnds)));


%% split off frames into blocks

diffOff = diff(stimOffFrames);

% first stim on
blockOffStarts = 1;

% block stim on starts
stimOffBreaks = [blockOffStarts; find(diffOff > blockLimit)+1];

% block stim on ends
stimOffStopBreaks = [ find(diffOff > blockLimit) ;length(diffOff)+1];

for i =1:length(stimOffBreaks)
    stimOffPerBlock{i,:} = stimOffFrames(stimOffBreaks(i):stimOffStopBreaks(i));
end

%% make all the metrics we use to seperate out the cells
responseMetrics = createFlashMetrics(data, stimOnPerBlock, stimOffPerBlock, prestimTimeZScore, stimTimeZScore, prestimTimePSTH, postStimTimePSTH);

respondingClustersIndex = max(responseMetrics.responseQuality,[],2)>responseQualityThreshold;
respondingClusterIndxNum = find(respondingClustersIndex);

%% start the plotting

cellRasterFolder = extractBefore(clusterFilepath, '.');

if ~exist([cellRasterFolder{:} '_PSTHPlotsV2'])
    mkdir([cellRasterFolder{:} '_PSTHPlotsV2']);
end

% if ~exist([cellRasterFolder{:} '_cellPlots'])
%     mkdir([cellRasterFolder{:} '_cellPlots']);
% end

binsize = 50; % ms

% set(0,'DefaultFigureVisible','off');
count = 0;


for i = 1:length(respondingClusterIndxNum)

    curCl = respondingClusterIndxNum(i);
    clusterID = curCl-1;

    count = count +1;

    disp(['On ' num2str(count) ' of ' num2str(length(respondingClusterIndxNum))]);

    clusterResponses.ISI = responseMetrics.ISI{curCl};
    clusterResponses.ISI = responseMetrics.ISI_mean(curCl);
    clusterResponses.zScoreON = responseMetrics.zScoreON{curCl};
    clusterResponses.zScoreOFF = responseMetrics.zScoreOFF{curCl};
    clusterResponses.responseQuality = responseMetrics.responseQuality(curCl,:);
    clusterResponses.trialSpikes = responseMetrics.trialSpikes{curCl};
    clusterResponses.trialPSTHs = responseMetrics.trialPSTHs{curCl};
    clusterResponses.binEdges = responseMetrics.PSTH_binEdges;
    % clusterResponses.preStimTime = responseMetrics.preStimTime;
    % clusterResponses.preStimTime = responseMetrics.postStimTime;

    ax = plotAllRasterPSTHs_On_Off_ResponseV2(clusterResponses);

    sgtitle(['Cluster ID: ' num2str(clusterID) ' Spks: ' num2str(data.channelNames{6, curCl})]);
    tightfig;

    % saveName = sprintf('%s/cluster%04d.png',[cellRasterFolder{:} '_cellPlots'],i-1);
    saveName = sprintf('%s\\cluster%04d.png',[cellRasterFolder{:} '_PSTHPlotsV2'],clusterID);

    winHandle = gethwnd(gcf);
    cmndstr = sprintf('%s','MiniCap.exe -save ','"',saveName,'"',...
        ' -compress 9', ' -capturehwnd ', num2str(winHandle),' -exit');
    system(cmndstr);
    close
end
% end
% set(0,'DefaultFigureVisible','on');
end
