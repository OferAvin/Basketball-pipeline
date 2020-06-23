function powMat = getRelativePow(bandsPow)
    powMat = cell2mat(bandsPow);
    powMat(:,end+1) = sum(powMat,2);
    powMat = powMat(:,1:end)./powMat(:,end);
    powMat = num2cell(powMat,1);
    powMat = powMat(1:end-1);
end