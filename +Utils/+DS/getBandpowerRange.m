function [lower,upper] = getBandpowerRange(bandpower, nSD)
    [lower,upper] = cellfun(@(x) Utils.DS.getNsdAroundMean(x, nSD), bandpower, 'un', false);
end