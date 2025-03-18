function data = readHS2_FLAME(hdf5Path)
% Function to read in Herdingspikes Lightning Cluster data hdf5 file
%
% Outputs data- struct containing all cluster data
%            filepath - hdf5 filepath
%            channelNames - struct containing
%                       1: cluster ID name
%                       2: Cluster centre X from top left(um)
%                       3: Cluster centre Y from top left(um)
%                       4: Cluster ID
%                       5: Average spk/s over full recording
%                       6: Total num of spikes
%
%            spiketimestamps - cell array for each cluster with spike frame
%                              times
%            Sampling - Sampling rate (Hz)
%            centres - Cluster centers in X/Y from top left(um)
%            cluster_id - cluster_id for each spike
%            times - spike times in frames

% Adpated from g_HS2Matlab - Gerrit
 %[channelNames,spiketimestamps,Sampling,centres,cluster_id,times] = g_HS2Matlab(HdfFile,idx)
% import v28 hdf5 files and convert to Matlab arrays
% HdfFile=spontHdfFile;
% minspkfreq=0.01;
% maxspkfreq=100;
% HdfFile=spontHdfFile;

%% read in data
centres = double(h5read(hdf5Path,'/centres'));
cluster_id = double(h5read(hdf5Path,'/cluster_id'));
times = double(h5read(hdf5Path,'/times'));
Sampling = double(h5read(hdf5Path,'/Sampling'));
centVersion = size(centres);
shapes = double(h5read(hdf5Path,'/shapes'));
cutout_length = double(h5read(hdf5Path,'/cutout_length'));
amplitudes = double(h5read(hdf5Path,'/Amplitude'));
spike_x = double(h5read(hdf5Path,'/x'));
spike_y = double(h5read(hdf5Path,'/y'));

%% process into table
units = double(tabulate(cluster_id));
       
nunits = length(units(:,1));
reclen = max(times)/Sampling; % just an approximation in seconds
spiketimestamps = cell(nunits,1);

%% grab spike times and other info
for i = 1:nunits
    if units(i,2)>0
        spiketimestamps{i}=times(cluster_id==units(i,1));
        channelNames{1,i} = cellstr(sprintf('Cluster%05d',units(i,1)));
        if centVersion(2) > 4  %new HS format
            channelNames{2,i} = centres(1,units(i,1)+1); % x
            channelNames{3,i} = centres(2,units(i,1)+1); % y
        else
            channelNames{2,i} = centres(units(i,1)+1,1);
            channelNames{3,i} = centres(units(i,1)+1,2);
        end
        
        channelNames{4,i} = units(i,1); % cluster ID
        channelNames{5,i} = units(i,2)/reclen; % average spikes/s for entire experiment
        channelNames{6,i} = units(i,2); % total num spikes
    else
        channelNames{1,i} = cellstr(sprintf('Cluster%05d',units(i,1)));
        channelNames{2,i} = nan;
        channelNames{3,i} = nan;
        channelNames{4,i} = units(i,1);
        channelNames{5,i} = 0;
        channelNames{6,i} = 0;
    end
    
end

%% split waveform shapes into structure
for i = 1:nunits
    if units(i,2)>0
        waveformsPerCluster{i} = shapes((cluster_id==units(i,1)),1:cutout_length);
        waveformClusterMeans(i,:) = mean(waveformsPerCluster{i},1);
    end
end

%% build output structure
data.filepath = hdf5Path;
data.channelNames = channelNames;
data.spiketimestamps  = spiketimestamps;
data.Sampling = Sampling;
data.centres = centres;
data.cluster_id = cluster_id;
data.times= times;
data.amplitudes = amplitudes;
data.spikeX = spike_x;
data.spikeY = spike_y;
data.waveformsPerCluster = waveformsPerCluster;
data.waveformClusterMeans = waveformClusterMeans;

end
