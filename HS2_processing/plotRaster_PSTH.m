function plotRaster_PSTH(spikeFrames, binsize, fs, alignEventFrames, preAlignTime, postAlignTime)


%% plot raster per trial
figure('Units','normalized','Position',[0 0 .3 1])
ax = subplot(2,1,1); hold on

% alignment times in sec
preAlignInFrames = preAlignTime * fs;
postAlignInFrames = postAlignTime * fs;

% for each trial
for tr = 1:length(alignEventFrames)

    % trial times in frames
    trStart = alignEventFrames(tr)- preAlignInFrames;
    trEnd = alignEventFrames(tr)+ postAlignInFrames;

    % find inclusions for trial start and end
    trStartIndx = find(spikeFrames >trStart,1, 'first');
    trEndIndx = find(spikeFrames <trEnd,1, 'last');

    % get the spikes
    trSpikes = spikeFrames(trStartIndx:  trEndIndx);
    trSpikes = trSpikes / fs; % convert to sec
    trSpikes = trSpikes- (alignEventFrames(tr)/ fs); % rezero to alignment event

    % put into cell array for psth
    trSpikesStruct{tr} = trSpikes;


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

ax.XLim             = [-preAlignTime postAlignTime];
ax.YLim             = [0 length(alignEventFrames)];

ax.XLabel.String  	= 'Time [s]';
ax.YLabel.String  	= 'Trials';
xline(0, 'Color', 'r', 'LineWidth',2);

%% PSTH

all = [];
for iTrial = 1:length(trSpikesStruct)
    all             = [all; trSpikesStruct{iTrial}];               % Concatenate spikes of all trials
end

ax                  = subplot(2,1,2);

trialLen           = (preAlignTime + postAlignTime) * 1000;    % trial length ms                              
nbins                = trialLen/binsize;                        % Bin duration in [ms]
nobins              = 1000/binsize;                            % No of bins/sec

h                   = histogram(all,nbins);
h.FaceColor         = 'k';

mVal                = max(h.Values)+round(max(h.Values)*.1);
ax.XLim             = [-preAlignTime postAlignTime];
ax.YLim             = [0 mVal];
% ax.XTick            = [trialXLim(1): xtickIncrement : trialXLim(2)];
% ax.XTickLabels      = [trialXLim(1): xtickIncrement : trialXLim(2)- prestimTime];
ax.XLabel.String  	= 'Time [s]';
ax.YLabel.String  	= 'Spikes/Bin';
end