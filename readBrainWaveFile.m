function readBrainWaveFile(filePath)
% reads in and processes a .bxr file and extracts spike times for all
% channels in the MEA. Saves a _waveEx.mat file with all the data and
% options
%
% Written by MA Savage
%
% Inputs: filepath- fullfile to the .bxr file
%
% Usage: readBrainWaveFile('C:\Data\mouse\mea\testData\P4_20Feb19\test2\P4_ret1_20Feb19.bxr');

%% read in data
% read in chan org
% info = h5info(filePath);
nCols =  h5read(filePath,'/3BRecInfo/3BMeaChip/NCols');
nRows =  h5read(filePath,'/3BRecInfo/3BMeaChip/NRows');
% layout = h5read(filePath,'/3BRecInfo/3BMeaChip/MeaType');

% read in frame num
StartFrame = 0;
StopFrame = h5read(filePath,'/3BRecInfo/3BRecVars/NRecFrames');

% read in sample freq
SamplingFrequency = h5read(filePath, '/3BRecInfo/3BRecVars/SamplingRate');

% read in spike times (in frames)
spikeT = h5read(filePath, '/3BResults/3BChEvents/SpikeTimes');

% read in spike chan indexes
spikeChData = h5read(filePath, '/3BResults/3BChEvents/SpikeChIDs');

% read in default options
ops = retinaWavesDefaults;

% overwrite sampling freq
ops.freq = SamplingFrequency;

%% create struct

% create all the channels
% run through all the colomns and rows

for x =1:nRows
    for y = 1: nCols
        % get index from col/row
        ind = sub2ind([nCols nRows], y, x);

        % get any spike channel indexes
        chanIndxs = find(spikeChData==ind);

        if isempty(chanIndxs)
            % if no spikes create an empty variable
            eval(sprintf('spikeCh.Ch%02d_%02d=chanIndxs;', x, y));
        else
            % get spike indexes for channel
            spikesForChan = spikeT(chanIndxs);

            % create sparse double vector for spike train (nFrames x 1)
            spikeTrain = spalloc(StopFrame, 1, length(spikesForChan));

            % fill indexes with ones for spike frame IDs
            spikeTrain(spikesForChan) = 1;

            eval(sprintf('spikeCh.Ch%02d_%02d=spikeTrain;', x, y));
        end
    end
end

%% save stuff in the experiment object

% create experiment object
waveEx.dataFilepath = filePath;
waveEx.ops = ops;

% create spike data struct
spikeData.spikes = spikeCh;
spikeData.SamplingFrequency = SamplingFrequency;
spikeData.StartFrame = StartFrame;
spikeData.StopFrame = StopFrame;

% add to waveEx
waveEx.spikeData = spikeData;

% save stuff
[pathstr, name, ext] = fileparts(filePath); % get file parts
outfile = fullfile(pathstr,[name,'_waveEx.mat']); % create save path

save(outfile, 'waveEx');
end