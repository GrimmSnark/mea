function catAndStatOnWaves( waveFile, binSize, timeStep, openGUIFlag, varargin)
%
% ATTENTION: see the FIX below
%
%Calculate CAT on waves generated by the analyseWaveAPS (or 
%AnalysisWaveAPSstats) function according to the recruited channels for 
%each wave and the time range of the waves.
%
%   INPUT
%   - waveFile:     The file containing the waves, i.e. the results of the 
%                   analyseWaveAPS function. Whether empty string the user 
%                   will be asked for locating the file.
%   - spikeFile:    The file containing the spike train for each electrode
%                   as sparse array. Whether empty string the user will be
%                   asked for locating the file.
%   - outFile:      The file tag where to save the output. Whether empty 
%                   string the user will be asked for locating the file.
%   - binSize:      The bin size in milliseconds used to calculate each
%                   Center of Activity (CA) point
%   - timeStep:     A value in the range (0 1] that specifies the time step
%                   between two seccussive CA as a fraction of the bin size
%   
%   OUTPUT to file
%   
%   - xxx_CATs:     Contains CATs
%   - xxx_waveStats:Contains following information on waves:
%                       - waveIndex: n x 1 array where at the ith position
%                                    there is the index of the original
%                                    wave according to the waveFile
%                       - waveBegin: wave start time in seconds
%                       - waveEnd:   wave end time in seconds
%                       - waveArea:  wave area in square microns
%                       - waveSpeed: wave speed in micron/s
%
% 17/10/22 M Savage
% Adpated into scripts which use retinaWavesDefault and can be more easily
% run


%ops.freq = 7702;
%ops.freq = 7572;
%ops.freq = 7022;

% ops.freq = 7062.1;

%ops.freq = 17855
% array side length in number of electrodes
% ops.aSide = 64;

% array fundamental element length in microns
% ops.eSize = 84;

% whether true, the algo consider only the spikes whithin the wave range,
% i.e. for each channel the spikes whithin the burst that has been detected
% as part of the wave; otherwise for each channel also spikes out from the
% bursts (but always within the absolute bound of the wave) will be
% considered and the CAT can be quite different from how you see the wave
% made up of only bursts
% onlySpikesInWaveRanges = true;

% to identify inconsistent CA point (ops.icap >= 1). The CAT will be truncated
% where less than ops.icap channels contribute to the trajectory
% ops.icap = 3;

% whether true ops.icap is based on the relative number of active channels for
% each wave (value = ops.icap/100*activeChs; ops.icap ranges between 1 and 100)
% ops.icapAsPercentage = false;

% if true CATs are numerated progressively, otherwise they will keep the
% number of the waves to which are referred
% progEnumeration = false;

% constraint on the min number of recruited channels and min CAT length
% minNoRecruitChs = 5;

% whether true ops.minNoRecruitChs is based on the total number of active 
% channels for the loaded experiment (value = ops.minNoRecruitChs/100*activeChs
% ; ops.minNoRecruitChs ranges between 1 and 100)
% mrcAsPercentage = false;
% minCatLength = 5;


%% deal with openGUI variable viewer
 if nargin< 4 || isempty(openGUIFlag)
     openGUIFlag = 1;
 end

%%

if isempty(waveFile)
    [fileName filePath] = uigetfile('*.mat','Select the mat file containing waves');
    waveFile = strcat(filePath,fileName);
end

% if isempty(spikeFile)
%     [fileName filePath] = uigetfile('*.mat','Select the mat file containing spike trains as sparse arrays');
%     spikeFile = strcat(filePath,fileName);
% end

load(waveFile);
ops = waveEx.ops;
ops.OpenGUI = openGUIFlag;
ops = retinaWavesDefaults(ops);
waves = waveEx.waves;

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

if (timeStep <= 0 || timeStep > 1)
    error('time step has to range in (0 1]');
end

if ops.icap < 1
    error('icap must be >= 1');
end
% bin size and time step in number of frames
binSize = binSize / 1000 * ops.freq;
timeStep = timeStep * binSize;


%waves.epos = waves.epos - 1; % FIX for new Matthias algo were channels range in [2 65]

if ops.mrcAsPercentage
    ops.minNoRecruitChs = length(waves.epos)*ops.minNoRecruitChs/100;
end

% number of waves
nWaves = length(waves.pburst);

remForMRC = 0;

i = 0;
for w = 1 : nWaves
     
    % indexes of all the recruited channels for current wave
    chsIdx = waves.pburst{w};
    if length(chsIdx) < ops.minNoRecruitChs
        remForMRC = remForMRC + 1;
        continue;
    end
    
    if ops.icapAsPercentage
        ops.icap = length(chsIdx)*ops.icap/100;
    end
    
    % convert in number of frames burst limits for current wave and each ch
    waves.pbursttFrames = waves.pburstt{w} * ops.freq;
    waves.pburstetFrames = waves.pburstet{w} * ops.freq;
    
    % wave time range
    waveB = min(waves.pbursttFrames);
    waveE = max(waves.pburstetFrames);
     
    % Calculate CAT
    % ---------------------------------------------------------------------
    if waveB > waveE - binSize
        continue;
    end
    
    % bound for CA points
    lowerBound = waveB : timeStep : waveE - binSize;
    upperBound = waveB + binSize : timeStep : lowerBound(end) + binSize;    
        
    % number of points inside the trajectory
    nPnts = length(lowerBound);

    % row and col position for CAT
    catRow = zeros(nPnts, 1);
    catCol = zeros(nPnts, 1);
    % factors by which normalize CAT
    overallFactor = zeros(nPnts,1);
    % count of contributing channels at each CA point
    contrChsCount = zeros(nPnts, 1);
    
    countSpikes = 0;

    % load spike struct
    try
        spkStruct = waveEx.spikeData.spikes;
    catch
        spkStruct = waveEx.spikeData;
    end

    for c = 1 : length(chsIdx)
       
        % current channel
        chRow = waves.epos(chsIdx(c), 1);
        chCol = waves.epos(chsIdx(c), 2);
%         chString = ['Ch' num2str(chRow) '_' num2str(chCol)];
%         chString = sprintf('Ch%02d_%02d', chRow, chCol); % Fix for channels under 10
%         load(spikeFile, chString);
        
        % spike train for current ch as sparse array
%         spikes = eval(chString);
        spikes = eval(sprintf('spkStruct.Ch%02d_%02d', chRow, chCol));
        % spike time stamps in number of frames
        spikes = find(spikes);
        % only spikes within the wave range
        if ops.onlySpikesInWaveRanges
            spikes = spikes(spikes >= waves.pbursttFrames(c) & spikes <= waves.pburstetFrames(c));
        end
        
        countSpikes = countSpikes + length(spikes);
        
        for p = 1 : nPnts
           
            % number of spikes for current ch at current CA point
            factor = length(find(spikes >= lowerBound(p) & spikes < upperBound(p)));
            
            if factor ~= 0
                catRow(p) = catRow(p) + factor * chRow;
                catCol(p) = catCol(p) + factor * chCol;
                overallFactor(p) = overallFactor(p) + factor;
                contrChsCount(p) = contrChsCount(p) + 1;
            end
        end
        
%         clear(chString);
    end

    % Refine CAT
    % ---------------------------------------------------------------------

    [startPos endPos] = RefineCat(contrChsCount, ops.icap);

    % refine CAT
    catRow = catRow(startPos : endPos);
    catCol = catCol(startPos : endPos);
    overallFactor = overallFactor(startPos : endPos);
    
    
    catRow = catRow ./ overallFactor;
    catCol = catCol ./ overallFactor;
    % row values have to be reflected
    catRow = ops.aSide + 1 - catRow;
        
    if length(catRow) >= ops.minCatLength
        
        % Calculate wave stat
        % -----------------------------------------------------------------
        waveIndex(i + 1) = w;
        % wave time range
        waveBegin(i + 1) = waveB / ops.freq;
        waveEnd(i + 1) = waveE / ops.freq;

        % wave space range  
        waveNoChs(i +1) = length(chsIdx);        
        
        hotMapTmp = zeros(ops.aSide, ops.aSide);
        pos = waves.epos(chsIdx,:);
        for t = 1 : length(pos)
            hotMapTmp(pos(t,1), pos(t,2)) = 1;
        end
        hotMaps{i+1} = hotMapTmp;
        
        waveArea(i + 1) = WaveAreaConvexHull(waves.epos(chsIdx, :)) * ops.eSize^2;
        % wave area with concave hull + wave coverage (% of active
        % channels)
%         [a p] = WaveAreaAndCoverage2(ops.aSide, ops.aSide, waves.epos, chsIdx,
%         'savePng', ['wave_' num2str(w)]);
%         waveArea(i + 1) = a * ops.eSize^2;
%         waveCoverage(i + 1) = p;
        
        waveSize(i + 1) = countSpikes;
        % wave speed (um/s)
        waveSpeed(i + 1) = (catEuclideanLength(catRow, catCol) * ops.eSize) / (timeStep * (length(catRow) - 1) / ops.freq);
        
        % Store CAT
        % -----------------------------------------------------------------

        if ops.progEnumeration
            eval(['CATs.CATpoints_' num2str(i, '%04g') '= [catRow, catCol];']);
        else
            eval(['CATs.CATpoints_' num2str(w, '%04g') '= [catRow, catCol];']);
        end
        i = i + 1;
    end    
end


display(['total number of waves: ' num2str(nWaves)]);
display(['number of valid waves: ' num2str(i)]);
display(['waves removed because of insufficient number of recruited channels: ' num2str(remForMRC)]);
display(['waves removed because of insufficient CAT length (due also to ops.icap param): ' num2str(nWaves - i - remForMRC)]);



mean(waveNoChs);
mean(waveArea);
mean(waveSize);
mean(waveSpeed);

% if isempty(outfile)
%     [fileName filePath] = uiputfile('','Save data');
%     outfile = strcat(filePath,fileName);
% end

% get savepath name stub
[path, name, ext] = fileparts(waveFile);
filepathStruct = fullfile(path,name);

% root filepath for saving burst files
rootFilepathInd = strfind(filepathStruct, '_Spk');

% checks if empty (usually if you use the waveEx file)
if isempty(rootFilepathInd)
rootFilepathInd = strfind(filepathStruct, '_wave');
end

rootFilepath = waveFile(1:rootFilepathInd-1);

overallHotMap = zeros(ops.aSide, ops.aSide);
for t = 1 : length(waves.epos)
    overallHotMap(waves.epos(t,1), waves.epos(t,2)) = 1;
end
        
% save([outfile '_CATs.mat'], '-regexp', '^CATpoints*');
waveEx.CATs = CATs;

% save([outfile '_waveStats.mat'], 'waveIndex', 'waveBegin', 'waveEnd', 'waveNoChs', 'waveArea', 'waveSize', 'waveSpeed');
waveStats.waveIndex = waveIndex;
waveStats.waveBegin = waveBegin;
waveStats.waveEnd = waveEnd;
waveStats.waveNoChs = waveNoChs;
waveStats.waveArea = waveArea;
waveStats.waveSize = waveSize;
waveStats.waveSpeed = waveSpeed;

waveEx.waveStats = waveStats;

% save([rootFilepath '_hotMaps.mat'], 'hotMaps', 'overallHotMap');

waveEx.hotMaps.hotMaps = hotMaps;
waveEx.hotMaps.overallHotMap = overallHotMap;

save([filepathStruct '.mat'], 'waveEx');

close all
end

function a = WaveAreaConvexHull(chs)

chsVertices = zeros(length(chs) * 4, 2);
for i = 1 : length(chs)
    chsVertices((i - 1) * 4 + 1, :) = chs(i, :) + 0.5;
    chsVertices((i - 1) * 4 + 2, :) = chs(i, :) - 0.5;
    chsVertices((i - 1) * 4 + 3, :) = [chs(i, 1) + 0.5, chs(i, 2) - 0.5];
    chsVertices((i - 1) * 4 + 4, :) = [chs(i, 1) - 0.5, chs(i, 2) + 0.5];
end
 [notUsed a] = convhull(chsVertices(:, 1), chsVertices(:, 2));
 
end


function [startPos endPos] = RefineCat(contrChsCount, icap)

% position of valid CA (i.e. CA where more than a certain number of
% channels have contributed)
validCA = find(contrChsCount >= icap);

if isempty(validCA)
    startPos = 1;
    endPos = 1;
    return;
end

[b e] = GenerateIntervalsBasedOnAdjacentElements(validCA);
% lengths of intervals
lengths = e - b;
% the longest valid interval
maxLength = max(lengths);

% max length index (in case more than one interval has the same max
% length, take the first
maxLengthIdx = find(lengths == max(lengths));
maxLengthIdx = maxLengthIdx(1);
% start and end position
startPos = validCA(b(maxLengthIdx));
endPos = startPos + maxLength;    
end


function [s e] = GenerateIntervalsBasedOnAdjacentElements(data)

diffVector = diff(data);

endsIndexes = [find(diffVector > 1); length(data)];

s = zeros(length(endsIndexes), 1);
e = zeros(length(endsIndexes), 1);

begin = 1;
for i = 1 : length(s)
   s(i) = begin;
   e(i) = endsIndexes(i);
   begin = endsIndexes(i) + 1;
end    

end