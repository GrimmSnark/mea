function ax = plotAllRasterPSTHs_On_Off_ResponseV2(responseMetrics)

titleText = [{'Scotopic'}, {'Mesotopic'}, {'Photopic'}];

figH = figure('units','normalized','outerposition',[0 0 1 1], 'Color','white', 'MenuBar','none');
%% plot raster per trial

for stimblk = 1:length(responseMetrics.trialSpikes)
    ax(stimblk) = subplot(2,3,stimblk); hold on

    trialSpikesCnd = responseMetrics.trialSpikes{stimblk};
    xSpikePos = [];
    ySpikePos = [];
    % for each trial
    for tr = 1:length(trialSpikesCnd)
        trSpikes =trialSpikesCnd{tr};


        % build plottings
        xSpikePosTemp = repmat(trSpikes',2,1);
        xSpikePos = [xSpikePos xSpikePosTemp];

        ySpikePosTemp(1,:) = tr-1;                % Y-offset for raster plot
        ySpikePosTemp(2,:) = tr;
        ySpikePosTemp = repmat(ySpikePosTemp, 1, size(xSpikePosTemp,2));

        ySpikePos = [ySpikePos ySpikePosTemp];

        % wipe variables for next trial
        trSpikes = [];
        ySpikePosTemp = [];
        xSpikePosTemp = [];
        % disp(['Len X: ' num2str(length(xSpikePos)) ' Len Y: ' num2str(length(ySpikePos))])
    end

    plot(xSpikePos, ySpikePos, 'Color', 'k');

    currAx = ax(stimblk);
    currAx.XLim             = [-0.5 responseMetrics.binEdges(end)];
    currAx.YLim             = [0 length(trialSpikesCnd)];

    currAx.XLabel.String  	= 'Time [s]';
    currAx.YLabel.String  	= 'Trials';
    xline(0, 'Color', 'r', 'LineWidth',2);
    xline(2, 'Color', 'r', 'LineWidth',2);

    title([titleText{stimblk} ' Z ON: ' num2str(responseMetrics.zScoreON(stimblk)) ' Z OFF: '  num2str(responseMetrics.zScoreOFF(stimblk)) ' QI: ' num2str(responseMetrics.responseQuality(stimblk))] );

    %% PSTH

    ax(stimblk+3)   = subplot(2,3,stimblk+3);
    binsize = 50; %ms
    % nbins               = (range(responseMetrics.binEdges)*1000)/binsize;                        % Bin duration in [ms]
    nobins              = 1000/binsize;                            % No of bins/sec

    meanPSTH = mean(responseMetrics.trialPSTHs{stimblk});
    countAverageSec     = (meanPSTH/length(responseMetrics.trialSpikes)) * nobins;


    h                   = histogram('BinCounts', countAverageSec, 'BinEdges', responseMetrics.binEdges);
    h.FaceColor         = 'k';

    hold on
    xline(0, 'Color', 'r', 'LineWidth',2);
    xline(2, 'Color', 'r', 'LineWidth',2)

    mVal                = max(h.Values)+round(max(h.Values)*.1);

    currAx = ax(stimblk+3);
    currAx.XLim             = [-0.5 responseMetrics.binEdges(end)];

    % fix for empty histogram
    if mVal == 0
        mVal = 1;
    end

    currAx.YLim             = [0 mVal];
    currAx.XLabel.String  	= 'Time [s]';
    currAx.YLabel.String  	= 'Average Spikes Per Sec';

end

 subplotEvenAxes(ax, [0 1 0] , [4 5 6])
end