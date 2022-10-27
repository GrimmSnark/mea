function runWaveMaster(datFile, varargin)
% Runs the basic processing on a .bxr or SpkTs.mat file for the analysis of
% retina waves
%
% Written by MA Savage 27102022
%
% Inputs: datFile- fullfile to the data file to process, can be a .bxr or a
%                  SpkTs.mat file
%
%         varargin - can overwrite any input variable to the analysis files
%                    with the 'parameter name', variable format
%                    see also
%
% Output: Will output all figures and store experiment data into a
%         *Wave_Ex.mat structure in the location of the datFile

%% Defaults

bxrFlag = 0; % flag for bxr file type
%% read data

% if bxr file
if contains(datFile,'.bxr')
    readBrainWaveFile(datFile);
    bxrFlag = 1;
end

% find waveStruct file
[path] = fileparts(datFile);

waveStructFile = dir(fullfile(path, '*waveE*.mat'));
waveFile = fullfile(waveStructFile.folder, waveStructFile.name);

%% extract bursts
% deal with .bxr or SpkTs.mat
if bxrFlag == 1
    findAllBurstsAPS(waveFile, varargin{:});
else
    findAllBurstsAPS(datFile, varargin{:});
end

%% wave analysis
% run analyse waves
analyseWavesAPS_Stats(waveFile, varargin{:});


%% catStat analysis
% load waveEx.mat to get the options for bin size and timestep
load(waveFile);

% deal with varargin overrides
if ~isempty(varargin)
    for xx = 1:size(varargin,1)
        try
            eval(['ops.' varargin{xx,1} '=' num2str(varargin{xx,2}) ';'])
        catch
            eval(['ops.' varargin{xx,1} '=' varargin{xx,2} ';'])
        end
    end
end

% run cat stats
catAndStatOnWaves(waveFile, 1500, 0.2, varargin{:});
end