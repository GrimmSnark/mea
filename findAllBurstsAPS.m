% This script extract all bursts from a set of recordings.
% It works exactly like the script analyseBursts.
% The arguments are a cellstring of input filename (files)
% and the name of the output file (mat-file format).
%
% The output contains (among other variables):
% bursttime: start time of each burst
% burstend: end-time of bursts
% burstdur: their durations
% burstsize: burst size (number of spikes)

% 22/07/10 mhh
% adapted to APS spike trains
% takes only one input file at a time
%
% example:
% findAllBurstsAPS('Phase_01.mat','Phase_01_bursts.mat',0.75,0.05,1);

% 17/10/22 M Savage
% Adpated into scripts which use retinaWavesDefault and can be more easily
% run

% function [rate, bursttime, burstend, burstdur, burstsize, testelecs, isbad, meanrate, wlen, wskip] = findAllBurstsAPS(file)
function [waveEx] = findAllBurstsAPS(file, varargin)
%find all the bursts in the given spike files.
%This function was rewritten to return the data so
%that a single function call can produce output graphs from input spike
%data, without having to produce burst files inbetween. This was done for
%use on CARMEN. It is generally more efficient to save burst files and use
%them when working locally.
%
%Parameters
%
%rthres - Threshold for ISI rank. If set to 0, it will use the default (0.2)
%
%scthres - Threshold for spike count. if set to 0, will use the default (0.05)
%
%spiketrate_window - indow size for spike rate calculation (sec). if 0, it
%will use the default (1)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some parameters that can be amnually adjusted
% (they are different for the turtle data)
%
% Threshold for the ISI Rank:
% If the ISI rank drops below this value, then we may have a burst.
% rthres = 0.75;
%
% Threshold for the spike count
% scthres = 0.05;
%
% window size for spike rate calculation (sec)
% spiketrate_window = 1;
%
%Scaling is how many sections we split the window up into. We go through the spikes by this increment.
% scaling = 2;
%
% the APS array sampling frequency (Hz)
%freq = 7702;
%freq = 7572;
%freq = 7022; 
% freq = 7062.1;
%freq = 17855
%
% minimum  number of spikes required to accept a channel
% minNSpikes = 10;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load & combine spike data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% deals with if you are starting from the .bxr or the spk file
if strfind(file,'waveEx')
    load(file);
    ops = waveEx.ops;

    try
        spikeCh = waveEx.spikeData.spikes;
    catch
        spikeCh = waveEx.spikeData;
    end

    suffix = '';
elseif strfind(file,'Spk')
    spikeCh = load(file);
    ops = retinaWavesDefaults;
    suffix = '_waveEx';
end

% if strfind(file,'Spk')
%     spikeCh = load(file);
%     ops = retinaWavesDefaults;
%     suffix = '_waveEx';
% else
%     load(file);
%     ops = waveEx.ops;
%     spikeCh = waveEx.spikeData.spikes;
%     suffix = '';
% end

% deal with varargin overrides
if ~isempty(varargin)
    varargin = reshape(varargin,2,  [])';

    for xx = 1:size(varargin, 1)
        if isstring(varargin{xx,2})
            eval(['ops.' varargin{xx,1} '=' varargin{xx,2} ';']);
        elseif isnumeric(varargin{xx,2}) && length(varargin{xx,2}) == 1
            eval(['ops.' varargin{xx,1} '=' num2str(varargin{xx,2}) ';']);
        elseif isnumeric(varargin{xx,2}) && length(varargin{xx,2}) > 1
            eval(['ops.' varargin{xx,1} '= [' num2str(varargin{xx,2}(:)') '];']);
        end
    end
end


c=1;
elecs = [];
for x=1:64
  for y=1:64
      chname = sprintf('Ch%02d_%02d', x, y);
%     chname2=['Ch',num2str(x),'_',num2str(y)];
    if isfield(spikeCh,chname)
      [i,j] = find(eval(['spikeCh.' chname]));
      if length(i)>ops.minNSpikes & length(i)
	epos(c,1)=x; % electrode position
	epos(c,2)=y; % electrode position
	spikes.times{c} = i/ops.freq;

	nspikes(c) = length(spikes.times{c}); % number of spikes
	maxt(c) = max(spikes.times{c}); % max spike time
	elecs = [elecs c];
	c=c+1;
      end
    end
  end
end

nochannels = c-1;
rectime = max(maxt(elecs));
ee = elecs;
testelecs = ee;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate Spike Rate and ISI Ranks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

max_elec_no = max(ee);
rate = cell(1, max_elec_no);

meanrate = zeros(1,max_elec_no);
wlen = zeros(1,max_elec_no);
wskip = zeros(1,max_elec_no);

for enum = ee,

  meanrate(enum) = length(spikes.times{enum})/max(spikes.times{enum});

  wlen(enum) = ops.spiketrate_window;
  wskip(enum) = wlen(enum)/ops.scaling;

  working_wlen = wlen(enum);
  working_wskip =  wskip(enum);
  % calculate ranks
  d = diff(spikes.times{enum});
  isitime = cumsum(d);
  [dd i]=sort(d);
  rankt = i; %/max(i);
  [dd i]=sort(isitime(rankt));
  isirank = i/max(i);

  %new spike rate calculation
  %% start it off
  %work out how many sliding windows we can fit in. This is the right
  %answer! You need the extra tiny bit added to make sure that exact integers
  %or multiples of .25 don't end up in the lower boundary - the original
  %code used strictly less than
  times_in_windows = ceil((spikes.times{enum} + 0.00001)/ working_wskip);

  % These are the indices we will need
  addbit = ops.scaling-1;
  number_of_windows = max(times_in_windows)-ops.scaling;
  scount = zeros(1, max(times_in_windows)-ops.scaling);

  for i = times_in_windows',
    scount(max(1, i-addbit):min(i,number_of_windows)) = scount(max(1, i-addbit):min(i, number_of_windows))+1;
  end
  % Now we can calculate the counts by adding up all the values that are
  % in the valid range.
  rate{enum} = scount/working_wlen;

  % find bursts
  rc = 1;
  r = isirank;
  t = spikes.times{enum}(2:length(spikes.times{enum}));

  [n v] = hist(scount,200);
  tmp = find((fliplr(cumsum(fliplr(n/sum(n)))))<ops.scthres);

  %%jpg. I have some files where this returns an error cos tmp is empty.
  %%Why? I don't know!! I am not sure what this bit does. But I will
  %%ignore it and just check for emptyness, though I must check with
  %%Matthias what this does
  if ~isempty(tmp)
      nthres = max(2,ceil(v(tmp(1))));
      nthresoff = ceil(v(tmp(1))*0.5);
      %nthres = max(1,round(v(tmp(1))));
      %            nthresoff = max(1,round(v(tmp(1))*0.5));

      burston = 0;
      bc = 1;
      dt = working_wlen;
      while rc < length(r)-nthres,
	  if burston == 0 & r(rc) < ops.rthres,
	      if t(rc+nthres) < t(rc)+dt,
		  burston = 1;
		  bursttime{enum}(bc) = t(rc);
		  brc = rc;
	      end
	  elseif burston == 1
	      if t(rc+nthresoff) > t(rc)+dt,
		  % if t(rc)-bursttime{enum}(bc) > 1,
		      burstend{enum}(bc) = t(rc);
		      burstdur{enum}(bc) = t(rc)-bursttime{enum}(bc);
		      burstsize{enum}(bc) = rc - brc;
		      bc = bc + 1;
		  % else
		  %     bursttime{enum}(bc) = [];
		  % end
		  burston = 0;
	      end
	  end
	  rc = rc + 1;
      end

      if burston == 1,
	  tmp = t(rc)-bursttime{enum}(bc);
	  burstend{enum}(bc) = bursttime{enum}(bc)+tmp;
	  burstdur{enum}(bc) = t(rc)-bursttime{enum}(bc);
	  burstsize{enum}(bc) = rc - brc;
	  bc = bc + 1;
      end
  end

end


%% Check for row saturation ie lines of activity across the entire chip,
% this is seen in a few recordings where the chip/system has bad contact
% M Savage 20230905

meaArr = nan(64,64);

for ch = 1:max_elec_no
   meaArr(epos(ch,1),epos(ch,2))=meanrate(ch);
end

% get median for all channels used in the chip
meaArrMedian = median(meaArr, 'omitnan');
medianSD = std(meaArrMedian);

% create activity threshold as 3 STDs above the mean of the median
activtyLim = (3*medianSD) + mean(meaArrMedian);


rows2Clean = find(meaArrMedian>activtyLim);

if ~isempty(rows2Clean)

    disp(['Removing electrode row(s): ' num2str(rows2Clean(:)) ' due to high noise, please check output!!!']);

    % find the indexes of the channels to delete
    channels2Keep = ~ismember(epos(:,2),rows2Clean);
    channels2Kill = ismember(epos(:,2),rows2Clean);

    % clean per channel
    rate(channels2Kill) = [];
    testelecs(channels2Kill) = [];
    epos(channels2Kill,:) = [];
    meanrate(channels2Kill) = [];
    nspikes(channels2Kill) = [];
    wlen(channels2Kill) = [];
    wskip(channels2Kill) = [];
    spikes.times(channels2Kill) = [];


    % clean stuff that only goes until last valid index,ie can be shorter than
    % channeels2Kill
    bursttime(channels2Kill(1:length(bursttime))) = [];
    burstend(channels2Kill(1:length(burstend))) = [];
    burstdur(channels2Kill(1:length(burstdur))) = [];
    burstsize(channels2Kill(1:length(burstsize))) = [];
end

% scount(channels2Kill) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% save the data
%[path name ext v]=fileparts(files);
[pathstr, name, ext] = fileparts(file);

% create experiment object

waveEx.dataFilepath = file;
waveEx.ops = ops;

% if the spike data does not exist already, create it
if ~isfield(waveEx, 'spikeData')
    waveEx.spikeData = spikeCh;
end

% burstOutput
bursts.rate = rate;
bursts.bursttime = bursttime;
bursts.burstend = burstend;
bursts.burstdur = burstdur;
bursts.burstsize = burstsize;
bursts.testelecs = testelecs;
bursts.epos = epos;
bursts.meanrate = meanrate;
bursts.wlen = wlen;
bursts.wskip = wskip;
bursts.scount = scount;
bursts.nspikes = nspikes;
bursts.spikes = spikes;

waveEx.bursts = bursts;

outfile = fullfile(pathstr,[name,suffix,ext]);
% save(outfile,'rate','bursttime', 'burstend', 'burstdur', 'burstsize', 'testelecs', 'epos', 'meanrate', 'wlen', 'wskip', 'scount', 'nspikes','spikes');

save(outfile, 'waveEx');

end