function [zScorePerClusterBlkON, zScorePerClusterBlkOFF] = stimAlignedZScore(spikeFrames, fs, stimON_Events, stimOFF_Events, preAlignTime , postAlignTime)

for stimblk = 1:length(stimON_Events)

    % alignment times in sec
    preAlignInFrames = preAlignTime * fs;
    postAlignInFrames = postAlignTime * fs;

    % for each trial

    %% ON stim %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tr = 1:length(stimON_Events{stimblk})

        % get prestim spikes
        preStimStart = stimON_Events{stimblk}(tr)- preAlignInFrames;
        preStimSpikesON{stimblk}{tr} = spikeFrames(preStimStart < spikeFrames &  spikeFrames < stimON_Events{stimblk}(tr));
        preStimSpikeMeanON{stimblk}(tr) = numel(preStimSpikesON{stimblk}{tr})/preAlignTime;


        % stim spikes
        stimEnd = stimON_Events{stimblk}(tr)+ postAlignInFrames;
        stimSpikesON{stimblk}{tr} = spikeFrames(stimON_Events{stimblk}(tr) < spikeFrames &  spikeFrames <stimEnd);
        stimSpikeMeanON{stimblk}(tr) = numel(stimSpikesON{stimblk}{tr})/postAlignTime;
    end

    %% OFF stim %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tr = 1:length(stimOFF_Events{stimblk})

        % get prestim spikes
        preStimStart = stimOFF_Events{stimblk}(tr)- preAlignInFrames;
        preStimSpikesOFF{stimblk}{tr} = spikeFrames(preStimStart < spikeFrames &  spikeFrames < stimOFF_Events{stimblk}(tr));
        preStimSpikeMeanOFF{stimblk}(tr) = numel(preStimSpikesOFF{stimblk}{tr})/preAlignTime;


        % stim spikes
        stimEnd = stimOFF_Events{stimblk}(tr)+ postAlignInFrames;
        stimSpikesOFF{stimblk}{tr} = spikeFrames(stimOFF_Events{stimblk}(tr) < spikeFrames &  spikeFrames <stimEnd);
        stimSpikeMeanOFF{stimblk}(tr) = numel(stimSpikesOFF{stimblk}{tr})/postAlignTime;
    end

    % fix for no spikes in prestim period
    if sum(preStimSpikeMeanON{stimblk}) < 1
        preStimSpikeMeanON{stimblk}(end) = 1;
    end

    % fix for no spikes in prestim period
    if sum(preStimSpikeMeanOFF{stimblk}) < 1
        preStimSpikeMeanOFF{stimblk}(end) = 1;
    end

    zScorePerClusterBlkON(stimblk) = (mean(stimSpikeMeanON{stimblk}) - mean( preStimSpikeMeanON{stimblk})) / std( preStimSpikeMeanON{stimblk});
    zScorePerClusterBlkOFF(stimblk) = (mean(stimSpikeMeanOFF{stimblk}) - mean( preStimSpikeMeanOFF{stimblk})) / std( preStimSpikeMeanOFF{stimblk});
end

end