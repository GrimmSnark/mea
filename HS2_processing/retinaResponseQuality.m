function responseQuality = retinaResponseQuality(trialPSTHs)
% adapted from 
%Baden, T. et al. (2016) ‘The functional diversity of retinal ganglion cells in the mouse’, Nature

for i = 1:length(trialPSTHs)
    averageResponse = mean(trialPSTHs{i},1);
    varianceOfAverageResponse = var(averageResponse);

    trialVarience = var(trialPSTHs{i},[],2);
    meanOfTrailVarience = mean(trialVarience);
    responseQuality(i) = varianceOfAverageResponse/meanOfTrailVarience;
end
end