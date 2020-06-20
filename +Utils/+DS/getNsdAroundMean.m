%this function returns the valuses which are nSD around the vector's mean
function [lower upper] =  getNsdAroundMean(vec, nSD)
    meanVec = mean(vec);
    sdVec = std(vec);
    lower = meanVec - nSD*sdVec;
    upper = meanVec + nSD*sdVec;
end    