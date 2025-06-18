function [trialHists, trSpikesStructON,  edges] = createTrialPSTHs(spikeFrames, fs, stimON_Events, stimOFF_Events, preAlignTime, postAlignTime)

binsize = 50; %ms

for stimblk = 1:length(stimON_Events)-1

    % alignment times in sec
    preAlignInFrames = preAlignTime * fs;
    postAlignInFrames = postAlignTime * fs;

    % for each trial
    for tr = 1:length(stimON_Events{stimblk})

        % trial times in frames
        trStart = stimON_Events{stimblk}(tr)- preAlignInFrames;
        trEnd = stimOFF_Events{stimblk}(tr)+ postAlignInFrames;

        % find inclusions for trial start and end
        trStartIndx = find(spikeFrames >trStart,1, 'first');
        trEndIndx = find(spikeFrames <trEnd,1, 'last');

        % get the spikes
        trSpikes = spikeFrames(trStartIndx:  trEndIndx);
        trSpikes = trSpikes / fs; % convert to sec
        trSpikes = trSpikes- (stimON_Events{stimblk}(tr)/ fs); % rezero to alignment event

        % put into cell array for psth
        trSpikesStructON{stimblk}{tr} = trSpikes;
        trialLenSec(tr) = (trEnd-trStart)/fs;

        % wipe variables for next trial
        trSpikes = [];
    end

    %% PSTH


    trialLen            = mean(trialLenSec) * 1000;                % trial length ms
    binActual =[0 :0.05: trialLenSec]- preAlignTime;
    nbins               = round(trialLen/binsize);                        % Bin duration in [ms]
    nobins              = 1000/binsize;                            % No of bins/sec

    for iTrial = 1:length(trSpikesStructON{stimblk})
        [trialHistTemp, edges] = histcounts(trSpikesStructON{stimblk}{iTrial},binActual);
        % [trialHistTemp, edges] = histcounts(trSpikesStructON{iTrial}, nbins);
        % [trialHistTemp, edges] = histcounts(trSpikesStructON{iTrial},"BinWidth",50);
        trialHists{stimblk}(iTrial,:) = trialHistTemp;
    end
    %
    % countAverageSec     = mean(trialHists,1) * nobins;
    % subplot(211)
    % h                   = histogram('BinCounts', countAverageSec, 'BinEdges', edges);



    % all = [];
    % for iTrial = 1:length(trSpikesStructON)
    %     all             = [all; trSpikesStructON{iTrial}];               % Concatenate spikes of all trials
    % end
    %
    %  [counts, edges2]     = histcounts(all,binActual);
    % % [counts, edges2]     = histcounts(all,nbins);
    % countAverageSec2     = (counts/length(stimOFF_Events{stimblk})) * nobins;
    %
    %
    % subplot(212)
    % h                   = histogram('BinCounts', countAverageSec2, 'BinEdges', edges2);
    %  % h                   = histogram('BinCounts', countAverageSec2, "BinWidth",50);



end
end