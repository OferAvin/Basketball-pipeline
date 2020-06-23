function [badTrials] = findBandpowerBadTrials(bandpower, lower, upper)
    badBands = cellfun(@(x,y,z) Utils.DS.isOutOfRange(x,y,z), bandpower, lower, upper,'un', false);
    badTrials = sum(cell2mat(badBands),2) > 0;
    badTrials = badTrials';
end