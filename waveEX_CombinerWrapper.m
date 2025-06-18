function waveEX_CombinerWrapper(folder2Search)

fs = filesep;

list = dir([folder2Search fs '**' fs '*waveEx*']);

cellfun(@(x) strcmp('.-',x),list.name)


end