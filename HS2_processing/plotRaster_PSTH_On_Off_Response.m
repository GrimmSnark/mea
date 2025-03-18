function plotRaster_PSTH_On_Off_Response(waveforms, spikeFrames, binsize, fs, stimON_Events, stimOFF_Events, preAlignTime, postAlignTime)

%% plot waveforms
figure('Units','normalized','Position',[0 0 1 1])

subplot(3,2,1); hold on

for w = 1:size(waveforms,1)
    plot(waveforms(w,:),'LineWidth',0.5,'Color',[ 0 0 0 0.01]);
end

plot(mean(waveforms,1), 'LineWidth',2, 'Color','g' );
xlim([0 size(waveforms,2)]);
title('Spike Waveforms');

%% plot Interspike interval
subplot(3,2,2);
spikeTimesMillSecs = (spikeFrames / fs) * 1000 ;
ISIs = diff(spikeTimesMillSecs);
percentageViolation = sum(ISIs < 1)/numel(ISIs);
ISIs(ISIs > 1000) = [];
histogram(ISIs, BinWidth=1);
xlim([0 200])
xline(1, LineWidth= 2, Color= 'r');
title(sprintf('ISIs: %2.5f%% violation of 1ms refactory period',percentageViolation))
xlabel('Time [ms]');
ylabel('Inter spike interval Counts')


%% ON stim %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot raster per trial
ax = subplot(3,2,3); hold on

% alignment times in sec
preAlignInFrames = preAlignTime * fs;
postAlignInFrames = postAlignTime * fs;

% for each trial
for tr = 1:length(stimON_Events)

    % trial times in frames
    trStart = stimON_Events(tr)- preAlignInFrames;
    trEnd = stimON_Events(tr)+ postAlignInFrames;

    % find inclusions for trial start and end
    trStartIndx = find(spikeFrames >trStart,1, 'first');
    trEndIndx = find(spikeFrames <trEnd,1, 'last');

    % get the spikes
    trSpikes = spikeFrames(trStartIndx:  trEndIndx);
    trSpikes = trSpikes / fs; % convert to sec
    trSpikes = trSpikes- (stimON_Events(tr)/ fs); % rezero to alignment event

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

ax.XLim             = [-preAlignTime postAlignTime];
ax.YLim             = [0 length(stimON_Events)];

ax.XLabel.String  	= 'Time [s]';
ax.YLabel.String  	= 'Trials';
xline(0, 'Color', 'r', 'LineWidth',2);

title('Flash ON Aligned');

%% PSTH

all = [];
for iTrial = 1:length(trSpikesStructON)
    all             = [all; trSpikesStructON{iTrial}];               % Concatenate spikes of all trials
end

ax                  = subplot(3,2,5);

trialLen           = (preAlignTime + postAlignTime) * 1000;    % trial length ms                              
nbins                = trialLen/binsize;                        % Bin duration in [ms]
nobins              = 1000/binsize;                            % No of bins/sec

h                   = histogram(all,nbins);
h.FaceColor         = 'k';

hold on
xline(0, 'Color', 'r', 'LineWidth',2);

mVal                = max(h.Values)+round(max(h.Values)*.1);
ax.XLim             = [-preAlignTime postAlignTime];

% fix for empty histogram
if mVal == 0
    mVal = 1;
end

ax.YLim             = [0 mVal];
% ax.XTick            = [trialXLim(1): xtickIncrement : trialXLim(2)];
% ax.XTickLabels      = [trialXLim(1): xtickIncrement : trialXLim(2)- prestimTime];
ax.XLabel.String  	= 'Time [s]';
ax.YLabel.String  	= 'Spikes/Bin';




%% OFF stim %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% plot raster per trial
ax = subplot(3,2,4); hold on

% alignment times in sec
preAlignInFrames = preAlignTime * fs;
postAlignInFrames = postAlignTime * fs;

% for each trial
for tr = 1:length(stimOFF_Events)

    % trial times in frames
    trStart = stimOFF_Events(tr)- preAlignInFrames;
    trEnd = stimOFF_Events(tr)+ postAlignInFrames;

    % find inclusions for trial start and end
    trStartIndx = find(spikeFrames >trStart,1, 'first');
    trEndIndx = find(spikeFrames <trEnd,1, 'last');

    % get the spikes
    trSpikes = spikeFrames(trStartIndx:  trEndIndx);
    trSpikes = trSpikes / fs; % convert to sec
    trSpikes = trSpikes- (stimOFF_Events(tr)/ fs); % rezero to alignment event

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

ax.XLim             = [-preAlignTime postAlignTime];
ax.YLim             = [0 length(stimOFF_Events)];

ax.XLabel.String  	= 'Time [s]';
ax.YLabel.String  	= 'Trials';
xline(0, 'Color', 'r', 'LineWidth',2);

title('Flash OFF Aligned');

%% PSTH

all = [];
for iTrial = 1:length(trSpikesStructOFF)
    all             = [all; trSpikesStructOFF{iTrial}];               % Concatenate spikes of all trials
end

ax                  = subplot(3,2,6);

trialLen           = (preAlignTime + postAlignTime) * 1000;    % trial length ms                              
nbins                = trialLen/binsize;                        % Bin duration in [ms]
nobins              = 1000/binsize;                            % No of bins/sec

h                   = histogram(all,nbins);
h.FaceColor         = 'k';

hold on
xline(0, 'Color', 'r', 'LineWidth',2);

mVal                = max(h.Values)+round(max(h.Values)*.1);

% fix for empty histogram
if mVal == 0
    mVal = 1;
end

ax.XLim             = [-preAlignTime postAlignTime];
ax.YLim             = [0 mVal];
% ax.XTick            = [trialXLim(1): xtickIncrement : trialXLim(2)];
% ax.XTickLabels      = [trialXLim(1): xtickIncrement : trialXLim(2)- prestimTime];
ax.XLabel.String  	= 'Time [s]';
ax.YLabel.String  	= 'Spikes/Bin';
end