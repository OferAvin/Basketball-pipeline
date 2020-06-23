function [allBadChanels,allBadTrails] = bandpowerTBT(EEG, bands, nSD, tStart, tEnd)
    
    elect = num2cell(1:EEG.nbchan);
    nElect = length(elect);
    
    [~,start_ind]=  min (abs(EEG.times - tStart));
    [~,end_ind]=  min (abs(EEG.times - tEnd));
    T_window_ind= start_ind:end_ind;
    
    band_pows= [];
    band_pows = cellfun(@(x) Utils.DS.get_bandpower(EEG, x, bands, T_window_ind),...
        elect, 'un', false);
    
    band_pows = cellfun(@(x) Utils.DS.getRelativePow(x), band_pows, 'un', false);
    
    [lowerTH,upperTH] = cellfun(@(x) Utils.DS.getBandpowerRange(x,nSD), band_pows, 'un', false);
    
    badTrials = cellfun(@(x,y,z) Utils.DS.findBandpowerBadTrials(x,y,z)...
        ,band_pows,lowerTH,upperTH,'un', false);
    
    allBadChanels = reshape(cell2mat(badTrials),nElect,[]);
    allBadTrails = sum(allBadChanels) > 0;
end