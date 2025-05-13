function plotSingleClusterPSTHsRetinaFlashStimDataFN1(clusterFilepath, clusters2Plot, prestimTime, stimTime)

%% get the appropriate paths
filepathPrefix = extractBefore(clusterFilepath, '_cluster');
stimOnFile = [filepathPrefix{:} '_triggerON.npy'];
stimOffFile = [filepathPrefix{:} '_triggerOFF.npy'];

%% load data
data = readHS2_FLAME(clusterFilepath);

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

%% get firing rate for prestim and on/off responses
% [zScorePerClusterBlkON, zScorePerClusterBlkOFF] = createZScores4FlashData(data, stimOnPerBlock, stimOffPerBlock);
[zScorePerClusterBlkON, zScorePerClusterBlkOFF] = createZScoreTrialFlashData(data, stimOnPerBlock, stimOffPerBlock, prestimTime, stimTime);

%% start the plotting

cellRasterFolder = extractBefore(clusterFilepath, '.');

if ~exist([cellRasterFolder{:} '_PSTHPlots'])
    mkdir([cellRasterFolder{:} '_PSTHPlots']);
end

binsize = 50; % ms

for i =1:length(clusters2Plot)
    spikeTimes = data.spiketimestamps{clusters2Plot(i)};
    ax = plotAllRasterPSTHs_On_Off_Response(spikeTimes, binsize, data.Sampling, stimOnPerBlock(1:3), stimOffPerBlock(1:3), prestimTime, stimTime);


    sgtitle(['Cluster ID: ' num2str(data.channelNames{4,clusters2Plot(i)}) ' (Spks: ' num2str(data.channelNames{6, clusters2Plot(i)}) ') ZScore ON/OFF: ' num2str(zScorePerClusterBlkON(clusters2Plot(i),1:3)) '/' num2str(zScorePerClusterBlkOFF(clusters2Plot(i),1:3)) ]);
    subplotEvenAxes(ax, [0 1 0] , 7:12);
    tightfig;

    % saveName = sprintf('%s/cluster%04d.png',[cellRasterFolder{:} '_cellPlots'],i-1);
    saveName = sprintf('%s/cluster%04d.png',[cellRasterFolder{:} '_PSTHPlots'],clusters2Plot(i)-1);
    saveas(gcf, saveName );
    close
end
end