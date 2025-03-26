function ax = plotAllRasterPSTHs_On_Off_Response(spikeFrames, binsize, fs, stimON_Events, stimOFF_Events, preAlignTime, postAlignTime)


figH = figure('units','normalized','outerposition',[0 0 1 1]);
%% ON stim %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot raster per trial

for stimblk = 1:length(stimON_Events)
    ax(stimblk*2-1) = subplot(2,6,(stimblk*2-1)); hold on

    % alignment times in sec
    preAlignInFrames = preAlignTime * fs;
    postAlignInFrames = postAlignTime * fs;

    % for each trial
    for tr = 1:length(stimON_Events{stimblk})

        % trial times in frames
        trStart = stimON_Events{stimblk}(tr)- preAlignInFrames;
        trEnd = stimON_Events{stimblk}(tr)+ postAlignInFrames;

        % find inclusions for trial start and end
        trStartIndx = find(spikeFrames >trStart,1, 'first');
        trEndIndx = find(spikeFrames <trEnd,1, 'last');

        % get the spikes
        trSpikes = spikeFrames(trStartIndx:  trEndIndx);
        trSpikes = trSpikes / fs; % convert to sec
        trSpikes = trSpikes- (stimON_Events{stimblk}(tr)/ fs); % rezero to alignment event

        % put into cell array for psth
        trSpikesStructON{tr} = trSpikes;


        % build plottings
        xSpikePos = repmat(trSpikes',2,1);

        ySpikePos(1,:) = tr-1;                % Y-offset for raster plot
        ySpikePos(2,:) = tr;
        ySpikePos = repmat(ySpikePos, 1, length(xSpikePos));

        plot(xSpikePos, ySpikePos, 'Color', 'k');

        % wipe variables for next trial
        ySpikePos = [];
        trSpikes = [];
    end

    currAx = ax(stimblk*2-1);
    currAx.XLim             = [-preAlignTime postAlignTime];
    currAx.YLim             = [0 length(stimON_Events{stimblk})];

    currAx.XLabel.String  	= 'Time [s]';
    currAx.YLabel.String  	= 'Trials';
    xline(0, 'Color', 'r', 'LineWidth',2);

    title('Flash ON Aligned');

    %% PSTH

    all = [];
    for iTrial = 1:length(trSpikesStructON)
        all             = [all; trSpikesStructON{iTrial}];               % Concatenate spikes of all trials
    end

    ax(stimblk*2-1+6)   = subplot(2,6,(stimblk*2-1+6));

    trialLen            = (preAlignTime + postAlignTime) * 1000;    % trial length ms
    nbins               = trialLen/binsize;                        % Bin duration in [ms]
    nobins              = 1000/binsize;                            % No of bins/sec

    [counts, edges]     = histcounts(all,nbins);
    countAverageSec     = (counts/length(stimON_Events{stimblk})) * nobins;


    h                   = histogram('BinCounts', countAverageSec, 'BinEdges', edges);
    h.FaceColor         = 'k';

    hold on
    xline(0, 'Color', 'r', 'LineWidth',2);

    mVal                = max(h.Values)+round(max(h.Values)*.1);

    currAx = ax(stimblk*2-1+6);
    currAx.XLim             = [-preAlignTime postAlignTime];

    % fix for empty histogram
    if mVal == 0
        mVal = 1;
    end

    currAx.YLim             = [0 mVal];
    % ax.XTick            = [trialXLim(1): xtickIncrement : trialXLim(2)];
    % ax.XTickLabels      = [trialXLim(1): xtickIncrement : trialXLim(2)- prestimTime];
    currAx.XLabel.String  	= 'Time [s]';
    currAx.YLabel.String  	= 'Average Spikes Per Sec';

end





%% OFF stim %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot raster per trial

for stimblk = 1:length(stimOFF_Events)
    ax(stimblk*2) = subplot(2,6,(stimblk*2)); hold on

    % alignment times in sec
    preAlignInFrames = preAlignTime * fs;
    postAlignInFrames = postAlignTime * fs;

    % for each trial
    for tr = 1:length(stimOFF_Events{stimblk})

        % trial times in frames
        trStart = stimOFF_Events{stimblk}(tr)- preAlignInFrames;
        trEnd = stimOFF_Events{stimblk}(tr)+ postAlignInFrames;

        % find inclusions for trial start and end
        trStartIndx = find(spikeFrames >trStart,1, 'first');
        trEndIndx = find(spikeFrames <trEnd,1, 'last');

        % get the spikes
        trSpikes = spikeFrames(trStartIndx:  trEndIndx);
        trSpikes = trSpikes / fs; % convert to sec
        trSpikes = trSpikes- (stimOFF_Events{stimblk}(tr)/ fs); % rezero to alignment event

        % put into cell array for psth
        trSpikesStructOFF{tr} = trSpikes;


        % build plottings
        xSpikePos = repmat(trSpikes',2,1);

        ySpikePos(1,:) = tr-1;                % Y-offset for raster plot
        ySpikePos(2,:) = tr;
        ySpikePos = repmat(ySpikePos, 1, length(xSpikePos));

        plot(xSpikePos, ySpikePos, 'Color', 'k');

        % wipe variables for next trial
        ySpikePos = [];
        trSpikes = [];
    end

    currAx = ax(stimblk*2);
    currAx.XLim             = [-preAlignTime postAlignTime];
    currAx.YLim             = [0 length(stimOFF_Events{stimblk})];

    currAx.XLabel.String  	= 'Time [s]';
    currAx.YLabel.String  	= 'Trials';
    xline(0, 'Color', 'r', 'LineWidth',2);

    title('Flash OFF Aligned');

    %% PSTH

    all = [];
    for iTrial = 1:length(trSpikesStructOFF)
        all             = [all; trSpikesStructOFF{iTrial}];               % Concatenate spikes of all trials
    end

    ax(stimblk*2+6)                  = subplot(2,6,(stimblk*2+6));

    trialLen            = (preAlignTime + postAlignTime) * 1000;    % trial length ms
    nbins               = trialLen/binsize;                        % Bin duration in [ms]
    nobins              = 1000/binsize;                            % No of bins/sec

    [counts, edges]     = histcounts(all,nbins);
    countAverageSec     = (counts/length(stimOFF_Events{stimblk})) * nobins;


    h                   = histogram('BinCounts', countAverageSec, 'BinEdges', edges);
    h.FaceColor         = 'k';

    hold on
    xline(0, 'Color', 'r', 'LineWidth',2);

    currAx = ax(stimblk*2+6);
    mVal                = max(h.Values)+round(max(h.Values)*.1);
    currAx.XLim             = [-preAlignTime postAlignTime];

    % fix for empty histogram
    if mVal == 0
        mVal = 1;
    end

    currAx.YLim             = [0 mVal];
    % ax.XTick            = [trialXLim(1): xtickIncrement : trialXLim(2)];
    % ax.XTickLabels      = [trialXLim(1): xtickIncrement : trialXLim(2)- prestimTime];
    currAx.XLabel.String  	= 'Time [s]';
    currAx.YLabel.String  	= 'Average Spikes Per Sec';

end
end