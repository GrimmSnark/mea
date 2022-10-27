function ops = retinaWavesDefaults()
% This function holds all the defaults for processing Brainwave data

%% findAllBursts

% Threshold for the ISI Rank:
% If the ISI rank drops below this value, then we may have a burst.
ops.rthres = 0.75;

% Threshold for the spike count
ops.scthres = 0.05;

% window size for spike rate calculation (sec)
ops.spiketrate_window = 1;

%Scaling is how many sections we split the window up into. We go through the spikes by this increment.
ops.scaling = 2;

% the APS array sampling frequency (Hz)
ops.freq = 7062.1;

% minimum  number of spikes required to accept a channel
ops.minNSpikes = 10;

%% analyseWaves

% plot the burst data in this time window:
% NEW: now also applies to movie and 36 waves plot
ops.showtime = [0 1400];

% save the figures as .ps files (1 = yes)
ops.save_figs = 1;

% save the data as mywaves.mat file (1 = yes)
ops.save_data = 1;

% make a movie of the waves (1 = yes)
ops.show_movie = 1;

% do a raster plot of the wave bursts (1 = yes)
ops.show_raster = 1;

% show a panel of up to 36 successive waves (1 = yes)
ops.show36 = 1;

% smallest wave size to be shown in the 36-waves-plot
ops.minwavesize = 10;

% compute some wave statistics and show them
ops.do_stats = 1;

% plot cumulative histograms for sizes/durations? (stats only)
ops.cumhists = 1;

% how many monte carlo steps for p-value estimate?
% to get meningful results, this should be 1000 or so
% keep it small to reduce runtime
% 0 means the fits are not done at all
ops.monte_carlo_steps = 000;

% Wave detection parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% test if spike amplitudes satisfy quality criterium
ops.testForGaussian = 0;

% minimum number of spikes in a burst to include in analysis
% increasing this gets rid of noisy channels where spurious bursts were detected
ops.minNSpikes = 10;

% all the following parameters are now used for all data sets
% but may have to be adjusted

% the maximum variance allowed in the local centre of mass trajectory
% P4 (Fig 2): 12
% P9 (control_SpkTs_bursts.mat Fig 3): 5
% P12 (Phase_00_SpkTs_bursts.mat Fg 3): 5
% P5 (P05_AllPhases_Spikes_bursts.mat fig 3): 12
ops.searchradius = 40; % 10 default

% this is how many steps we look into the past to compute the centre of mass trajectories:
% a good default is ~20 or more, but it should be increased if small waves are not split properly
ops.nprev = 20;  % Fig 2 = 30

% minimum and maximum burst durations
% for this algorithm it is better to keep these short
% then it's possible to step through the waves in small steps...
%default values 2 (min) and 3 (max)
ops.minburstdur = 2;
ops.maxburstdur = 3;

%% catAndStatOnWaves

% The bin size in milliseconds used to calculate each Center of Activity (CA) point
ops.binSize = 1500;

%  A value in the range (0 1] that specifies the time step between two seccussive CA as a fraction of the bin size
ops.timeStep = 0.2;

% array side length in number of electrodes
ops.aSide = 64;
% array fundamental element length in microns
ops.eSize = 84;

% whether true, the algo consider only the spikes whithin the wave range,
% i.e. for each channel the spikes whithin the burst that has been detected
% as part of the wave; otherwise for each channel also spikes out from the
% bursts (but always within the absolute bound of the wave) will be
% considered and the CAT can be quite different from how you see the wave
% made up of only bursts
ops.onlySpikesInWaveRanges = true;

% to identify inconsistent CA point (icap >= 1). The CAT will be truncated
% where less than icap channels contribute to the trajectory
ops.icap = 3;

% whether true ICAP is based on the relative number of active channels for
% each wave (value = icap/100*activeChs; icap ranges between 1 and 100)
ops.icapAsPercentage = false;

% if true CATs are numerated progressively, otherwise they will keep the
% number of the waves to which are referred
ops.progEnumeration = false;

% constraint on the min number of recruited channels and min CAT length
ops.minNoRecruitChs = 5;

% whether true minNoRecruitChs is based on the total number of active 
% channels for the loaded experiment (value = minNoRecruitChs/100*activeChs
% ; minNoRecruitChs ranges between 1 and 100)
ops.mrcAsPercentage = false;
ops.minCatLength = 5;


end