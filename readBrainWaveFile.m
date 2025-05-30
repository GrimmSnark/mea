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
% read in chan org for old biocam or new biocam (in FLAME)

try
    %% try the old version of biocam data

    % info = h5info(filePath);
    nCols =  h5read(filePath,'/3BRecInfo/3BMeaChip/NCols');
    nRows =  h5read(filePath,'/3BRecInfo/3BMeaChip/NRows');
    % layout = h5read(filePath,'/3BRecInfo/3BMeaChip/MeaType');

    % read in frame num
    StartFrame = 0;
    StopFrame = h5read(filePath,'/3BRecInfo/3BRecVars/NRecFrames');

    StartFrame = StartFrame + 1; % bump up to 1 indexing
    StopFrame = StopFrame + 1; % bump up to 1 indexing

    % read in sample freq
    SamplingFrequency = h5read(filePath, '/3BRecInfo/3BRecVars/SamplingRate');

    % SamplingFrequency = h5readatt(filePath, '/' ,'SamplingRate');


    % read in spike times (in frames)
    spikeT = h5read(filePath, '/3BResults/3BChEvents/SpikeTimes');
    spikeT = spikeT +1; % bump up to 1 indexing

    % spikeT = h5read(filePath, '/Well_A1/SpikeTimes');

    % read in spike chan indexes
    spikeChData = h5read(filePath, '/3BResults/3BChEvents/SpikeChIDs');

    % spikeChData = h5read(filePath, '/Well_A1/SpikeChIdxs');

catch
    %% then try the new version of the biocam

    nCols =  sqrt(length(h5read(filePath, '/Well_A1/StoredChIdxs')));
    nRows =  nCols;

    % read in frame num
    StartFrame = 0;
    StopFrame = max(max(h5read(filePath,'/TOC')));

    StartFrame = StartFrame + 1; % bump up to 1 indexing
    StopFrame = StopFrame + 1; % bump up to 1 indexing

    % read in sample freq

    experimentSettings = jsondecode(h5read(filePath, '/ExperimentSettings'));
    SamplingFrequency = experimentSettings.TimeConverter.FrameRate;


    % read in spike times (in frames)
    spikeT =h5read(filePath, '/Well_A1/SpikeTimes');
    spikeT = spikeT +1; % bump up to 1 indexing

    % read in spike chan indexes
    spikeChData = h5read(filePath, '/Well_A1/SpikeChIdxs');


end

% read in default options
ops = retinaWavesDefaults;

% overwrite sampling freq
ops.freq = SamplingFrequency;

%% create struct

% create all the channels
% run through all the colomns and rows

% for x =1:nRows
%     for y = 1: nCols
%         % get index from col/row
%         ind = sub2ind([nCols nRows], y, x);
% 
%         % get any spike channel indexes
%         % tic
%         % chanIndxs = find(spikeChData==ind);
%         % toc
% 
%         chanIndxs = ismember(spikeChData, ind);
% 
%         if ~any(chanIndxs)
%             % if no spikes create an empty variable
%             eval(sprintf('spikeCh.Ch%02d_%02d=chanIndxs;', x, y));
%         else
%             % get spike indexes for channel
% 
%             spikesForChan = spikeT(chanIndxs);
% 
%             spikeTrain = sparse(1,double(spikesForChan),1,1,StopFrame);
% 
%             eval(sprintf('spikeCh.Ch%02d_%02d=spikeTrain'';', x, y));
%         end
%     end
% end

chanCombs = combvec(1:nRows, 1:nCols);
len2Iterate = length(chanCombs);
parfor i = 1:len2Iterate
    ind = sub2ind([nCols nRows], chanCombs(2,i), chanCombs(1,i));
    chanIndxs = find(spikeChData==ind);

    if ~any(chanIndxs)
            % if no spikes create an empty variable
           spikeTrains{i}=chanIndxs;
        else
            % get spike indexes for channel
            spikesForChan = spikeT(chanIndxs);
            % spikeTrain{i} = sparse(double(1),double(spikesForChan),1,1,StopFrame);
            spikeTrain{i} = sparse(double(spikesForChan),1,1,StopFrame,1);

    end
end

for x = 1:len2Iterate
    % fix for if the  last channel (64 x 64) is empty
    try
        eval(sprintf('spikeCh.Ch%02d_%02d=spikeTrain{x};', chanCombs(1,x), chanCombs(2,x)));
    catch
        eval(sprintf('spikeCh.Ch%02d_%02d=[];', chanCombs(1,x), chanCombs(2,x)));
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