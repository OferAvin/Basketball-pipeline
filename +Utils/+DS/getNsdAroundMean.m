function valsInBound =  getNsdAroundMean(vec, nSD)
    meanVec = mean(vec);
    sdVec = std(vec);
    lower = meanVec - nSD*sdVec;
    upper = meanVec + nSD*sdVec;
    valsInBound = vec(vec >= lower & vec <=upper);
end    