function [badTrials] = bandpowerTBT(EEG, bands, nSD, specra)
% get_by_wavelet - this function performs bandpower analysis and returns a
%    logical matrix of rejected trials.
    elect = num2cell(1:EEG.nbchan);
    [~,start_ind]=  min (abs(EEG.times - specra.tStart)); % get window's start index.
    [~,end_ind]=  min (abs(EEG.times - specra.tEnd)); %  get window's end index.
    T_window_ind= start_ind:end_ind;
    band_pows = cellfun(@(x) get_bandpower(EEG, x, bands, T_window_ind),...
        elect, 'un', false); % apply bandpower analysis to each electrode.
    band_pows = cellfun(@(x) getRelativePow(x), band_pows, 'un', false); % transform to relative power.
    [lowerTH,upperTH] = cellfun(@(x) getBandpowerRange(x,nSD), band_pows, 'un', false); % find for each signal the bands' bounds.   
    badTrials = cellfun(@(x,y,z) findBandpowerBadTrials(x,y,z)...
        ,band_pows,lowerTH,upperTH,'un', false); % find bad trails.
    badTrials = cell2mat(badTrials');
end

function [bandpower_data] = get_bandpower(EEG, chan, bands, T_window_ind)
% get_bandpower - this function apply bandpower analysis for one signal on
%   provided bands ranges.
    bandpower_data = cellfun(@(x) bandpower(permute(EEG.data(chan,T_window_ind,:),[3 2 1])',EEG.srate,x),...
        bands, 'un', false);
end

function powMat = getRelativePow(bandsPow)
% getRelativePow - this function transform signal data to relative power
%   overall bands.
    powMat = cell2mat(bandsPow);
    all_power = sum(powMat);
    powMat = powMat./all_power;
    powMat = (num2cell(powMat,2));
end

function [lower,upper] = getBandpowerRange(bandpower, nSD)
% getBandpowerRange - this function finds lower and upper bands' bounds
%   according to provided nSD.
    [lower,upper] = cellfun(@(x) Utils.DS.getNsdAroundMean(x, nSD), bandpower, 'un', false);
end

function [badTrials] = findBandpowerBadTrials(band_power, lower, upper)
% findBandpowerBadTrials - this function finds bad trials according to 
%   provided lower and upper bounds.
    badBands = cellfun(@(x,y,z)  (x<y | x>z), band_power, lower, upper,'un', false);
    badTrials = sum(cell2mat(badBands)) > 0;
end