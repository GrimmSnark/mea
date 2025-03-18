function data = processRetinaFlashStimDataFN1(clusterFilepath)

%% defaults

zScoreLower = 1; % spks/s over entire recording
spikeTotalLower = 100;

%% get the appropriate paths
filepathPrefix = extractBefore(clusterFilepath, '_cluster');
stimOnFile = [filepathPrefix{:} '_triggerON.npy'];
stimOffFile = [filepathPrefix{:} '_triggerOFF.npy'];


%% load data
matSavePath = extractBefore(clusterFilepath, '.');
matSavePath = [matSavePath{:} '.mat'];


if ~exist(matSavePath)
    data = readHS2_FLAME(clusterFilepath);
    save(matSavePath, "data");
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

%% get firing rate for prestim and on/off responses
[zScorePerClusterBlkON, zScorePerClusterBlkOFF] = createZScores4FlashData(data, stimOnPerBlock, stimOffPerBlock);

%% start the plotting

cellRasterFolder = extractBefore(clusterFilepath, '.');

if ~exist([cellRasterFolder{:} '_cellPlots'])
    mkdir([cellRasterFolder{:} '_cellPlots']);
end

binsize = 50; % ms
numValidClusters = sum([data.channelNames{5,:}]>zScoreLower);
set(0,'DefaultFigureVisible','off');
count = 0;


for i = 1:length(data.spiketimestamps)
    if any(zScorePerClusterBlkON(i,:)  >zScoreLower) || any(abs(zScorePerClusterBlkOFF(i,:))  >zScoreLower)
        if data.channelNames{6,i} >= spikeTotalLower

            count = count +1;

            waveforms = data.waveformsPerCluster{i};
            spikeTimes = data.spiketimestamps{i};

            disp(['Plotting ' num2str(count) ' of ' num2str(numValidClusters) ' (min ' num2str(zScoreLower) ' zScore)']);
            plotRaster_PSTH_On_Off_Response(waveforms,spikeTimes, binsize, data.Sampling, stimOnPerBlock{3}, stimOffPerBlock{3}, 0.5, 1);

            sgtitle(['Cluster ID: ' num2str(data.channelNames{4,i}) ' (Total spks number: ' num2str(data.channelNames{6, i}) ') ZScore ON/OFF: ' num2str(max(zScorePerClusterBlkON(i,:))) '/' num2str(max(abs(zScorePerClusterBlkOFF(i,:)))) ]);
            tightfig;

            saveName = sprintf('%s/cluster%04d.png',[cellRasterFolder{:} '_cellPlots'],i-1);
            saveas(gcf, saveName );
            close
        end
    end
end
set(0,'DefaultFigureVisible','on');
end
