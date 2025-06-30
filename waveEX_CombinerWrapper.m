function waveInfo = waveEX_CombinerWrapper(folder2Search)

%% get file list
fs = filesep;
list = dir([folder2Search fs '**' fs '*waveEx*']);
files2Keep = ~cellfun(@(x) contains(x,'._'),{list.name});
list = list(files2Keep);

% build data
waveInfo = table();
%% run through
for i = 1:length(list)

    % load
    load(fullfile(list(i).folder, list(i).name));
    % get wave number
    if isfield(waveEx, 'waveStats')
        numWaves = length(waveEx.waveStats.waveArea);

        % get type of experiment
        controlFlag = contains(list(i).name, ["control","cntrl", "CNTRL"]);
        probFlag = contains(list(i).name, ["prob","probenecid", "Probenecid", "PROB"]);
        washFlag = contains(list(i).name, ["wash", "WASH"]);

        % build temp wave struct
        tempWaveInfo = table();
        PDay = str2double(list(i).name(2));
        tempWaveInfo.PDay = repmat(PDay,numWaves, 1);
        tempWaveInfo.controlFlag =  repmat(controlFlag,numWaves, 1);
        tempWaveInfo.probFlag =  repmat(probFlag,numWaves, 1);
        tempWaveInfo.washFlag =  repmat(washFlag,numWaves, 1);
        tempWaveInfo.waveNumID = waveEx.waveStats.waveIndex';
        tempWaveInfo.waveChanNum = waveEx.waveStats.waveNoChs';
        tempWaveInfo.waveArea = waveEx.waveStats.waveArea';
        tempWaveInfo.waveSize = waveEx.waveStats.waveSize';
        tempWaveInfo.waveSpeed = waveEx.waveStats.waveSpeed';
        tempWaveInfo.waveTragectory = struct2cell(waveEx.CATs);
        tempWaveInfo.filePath = repmat({fullfile(list(i).folder, list(i).name)},numWaves, 1);


        waveInfo = [waveInfo; tempWaveInfo];

    else
        disp([fullfile(list(i).folder, list(i).name) ' does not have stats..'])
    end

    waveEx  = [];
    tempWaveInfo =[];
end


end
