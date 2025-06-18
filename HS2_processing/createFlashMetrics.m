function [responseMetrics] = createFlashMetrics(data, stimON_Events, stimOFF_Events, preAlignTimeZScore, postAlignTimeZScore, prestimTimePSTH, postStimTimePSTH)

% preAlignTime = 1; %s
% postAlignTime = 1; %s
binsize = 50; % ms
fs = data.Sampling;

%% Run through all the clusters
% for each cluster
spikes = data.spiketimestamps;
parfor i = 1:length(data.spiketimestamps)
    spikeFrames = spikes{i};

    % Inter spike interval
    ISI{i} = mean(diff(spikeFrames));
    ISI_mean(i) = mean(ISI{i});

    %% ZScore
    [zScorePerClusterBlkON{i}, zScorePerClusterBlkOFF{i}] = stimAlignedZScore(spikeFrames, fs, stimON_Events, stimOFF_Events, preAlignTimeZScore, postAlignTimeZScore);

    %% create trial based PSTHs
    warning('off','MATLAB:colon:operandsNotRealScalar'); % stops Warning: Colon operands must be real scalars. This warning will become an error in a future release.
    [trialPSTHs{i}, trialSpikeStruct{i}, binEdges{i}] = createTrialPSTHs(spikeFrames, fs, stimON_Events, stimOFF_Events, prestimTimePSTH, postStimTimePSTH);
    warning('on','MATLAB:colon:operandsNotRealScalar');

    %% get response quality
    QI(i,:) = retinaResponseQuality(trialPSTHs{i});
end

%% Put everything into struct
responseMetrics.ISI = ISI;
responseMetrics.ISI_mean = ISI_mean;
responseMetrics.zScoreON = zScorePerClusterBlkON;
responseMetrics.zScoreOFF = zScorePerClusterBlkOFF;
responseMetrics.trialSpikes = trialSpikeStruct;
responseMetrics.trialPSTHs = trialPSTHs;
responseMetrics.PSTH_binEdges = binEdges{1};
responseMetrics.responseQuality = QI;
end