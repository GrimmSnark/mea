function runWaveMaster(datFile, varargin)
% Runs the basic processing on a .bxr or SpkTs.mat file for the analysis of
% retina waves
%
% Written by MA Savage 27102022
%
% Inputs: datFile- fullfile to the data file to process, can be a .bxr or a
%                  SpkTs.mat file. If you leave this empty '[]', then opens
%                  the file dialogue
%
%         varargin - can overwrite any input variable to the analysis files
%                    with the 'parameter name', variable format
%                    see also retinaWavesDefaults
%
% Output: Will output all figures and store experiment data into a
%         *Wave_Ex.mat structure in the location of the datFile

%% Defaults

bxrFlag = 0; % flag for bxr file type
%% read data

% if the dataFile is empty, open file dialogue
if  nargin <1 || isempty(datFile)
    [file,path] = uigetfile( {'*.mat;*.bxr'});
    % if you did not select a file
    if file == 0
        error('User has not selected a file to process, please rerun and do so....')
    else
        datFile = fullfile(path, file);
    end
end

% if bxr file
if contains(datFile,'.bxr')
    readBrainWaveFile(datFile);
    bxrFlag = 1;
end

% get path parts
[path, fileName] = fileparts(datFile);

%% extract bursts
% deal with .bxr or SpkTs.mat
if bxrFlag == 1

    % get waveEx.mat file if calculated by readBrainWaveFile
    waveStructFile = dir(fullfile(path, [fileName '*waveE*.mat']));
    waveFile = fullfile(waveStructFile.folder, waveStructFile.name);

    findAllBurstsAPS(waveFile, 0,varargin{:});
else

    % otherwise use SpkTs.mat
    findAllBurstsAPS(datFile, 0, varargin{:});
end

%% wave analysis

% get wavefile after it is certain it is generated
waveStructFile = dir(fullfile(path, [fileName '*waveE*.mat']));
waveFile = fullfile(waveStructFile.folder, waveStructFile.name);

% run analyse waves
analyseWavesAPS_Stats(waveFile, 0, varargin{:});


%% catStat analysis
% load waveEx.mat to get the options for bin size and timestep
load(waveFile);

% deal with varargin overrides
if ~isempty(varargin)
    for xx = 1:size(varargin,1)
        try
            eval(['ops.' varargin{xx,1} '=' num2str(varargin{xx,2}) ';']);
        catch
            eval(['ops.' varargin{xx,1} '=' varargin{xx,2} ';']);
        end
    end
end

% run cat stats
catAndStatOnWaves(waveFile, waveEx.ops.binSize, waveEx.ops.timeStep,0 , varargin{:});
end