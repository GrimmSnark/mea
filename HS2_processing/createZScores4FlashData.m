function [zScorePerClusterBlkON, zScorePerClusterBlkOFF] = createZScores4FlashData(data, stimOnFrames, stimOffFrames)

% get the baseline frame periods
baselineFrames(1,:) = [1 stimOnFrames{1}(1)-1];
baselineFrames(2,:) = [stimOffFrames{1}(end) stimOnFrames{2}(1)];
baselineFrames(3,:) =  [stimOffFrames{2}(end) stimOnFrames{3}(1)];

% clean stim structures to remove single stims
% stimOnFrames(end) = [];
% stimOffFrames(end) = [];

% stimOnFramesUnzipped = [stimOnFrames{:}];
% stimOnFramesUnzipped = stimOnFramesUnzipped(:);
%
% stimOffFramesUnzipped = [stimOffFrames{:}];
% stimOffFramesUnzipped = stimOffFramesUnzipped(:);

for c = 1:length(data.spiketimestamps)

    spikeFrames = data.spiketimestamps{c};

    %% get the baseline firing rates for alll baselines before stim blocks
    baselineGrand = [];
    for i = 1:size(baselineFrames,1)
        % find inclusions for baseline start and end
        trStartIndx = find(spikeFrames >baselineFrames(i,1),1, 'first');
        trEndIndx = find(spikeFrames <baselineFrames(i,2),1, 'last');
        baselineLenFrames = baselineFrames(i,2)- baselineFrames(i,1);
        baselineLenSec = baselineLenFrames/data.Sampling;

        % get the spikes
        baselineSpikes = spikeFrames(trStartIndx:  trEndIndx);
        baselineSpikes = baselineSpikes / data.Sampling; % convert to sec

        baselineSpk_sec = histcounts(baselineSpikes, round(baselineLenSec));
        baselineGrand = [baselineGrand baselineSpk_sec];
    end

    baselineMean(c) = mean(baselineGrand);
    baselineSD(c) = std(baselineGrand);

    %% stim ON firing rate
    for bl = 1:3 %length(stimOnFrames)
        currentFrameONs = stimOnFrames{bl};
        currentFrameOFFs = stimOffFrames{bl};

        numOnSpikes = 0;
        numOffSpikes = 0;
        stimOnLenFramesTotal =0;
        stimOffLenFramesTotal =0;

        for tr = 1:length(currentFrameONs)-1

            % get the spikes across stim on for each blk
            trON_StartIndx = find(spikeFrames >currentFrameONs(tr),1, 'first');
            trON_EndIndx = find(spikeFrames <currentFrameOFFs(tr),1, 'last');
            stimOnLenFrames = currentFrameOFFs(tr) - currentFrameONs(tr);
            stimOnLenFramesTotal = [stimOnLenFramesTotal + stimOnLenFrames];

            numOnSpikes = [numOnSpikes + length(spikeFrames(trON_StartIndx:  trON_EndIndx))];

            % get the spikes across stim off for each blk
            trOFF_StartIndx = find(spikeFrames >currentFrameOFFs(tr),1, 'first');
            trOFF_EndIndx = find(spikeFrames <currentFrameONs(tr+1),1, 'last');
            stimOFFLenFrames = currentFrameONs(tr+1) - currentFrameOFFs(tr);
            stimOffLenFramesTotal = [stimOffLenFramesTotal + stimOFFLenFrames];

            numOffSpikes = [numOffSpikes + length(spikeFrames(trOFF_StartIndx:  trOFF_EndIndx))];
        end

        stimOnLenSecTotal = stimOnLenFramesTotal/data.Sampling;
        stimOnSpksPerSec(c,bl) = numOnSpikes/stimOnLenSecTotal;

        stimOffLenSecTotal = stimOffLenFramesTotal/data.Sampling;
        stimOffSpksPerSec(c,bl) = numOffSpikes/stimOffLenSecTotal;

        zScorePerClusterBlkON(c,bl) = (stimOnSpksPerSec(c,bl) - baselineMean(c)) / baselineSD(c);
        zScorePerClusterBlkOFF(c,bl) = (stimOffSpksPerSec(c,bl) - baselineMean(c)) / baselineSD(c);

    end
end

end